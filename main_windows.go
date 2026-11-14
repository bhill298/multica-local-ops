//go:build windows

// A one-shot, user-level supervisor for an unmodified Multica CLI.
package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"time"
)

type config struct {
	CLI            string `json:"cli"`
	Profile        string `json:"profile"`
	WorkspacesRoot string `json:"workspaces_root"`
	CodexArgs      string `json:"codex_args"`
	LogDir         string `json:"log_dir"`
}

func environment(args string) []string {
	env := []string{}
	for _, value := range os.Environ() {
		key := strings.ToUpper(strings.SplitN(value, "=", 2)[0])
		if key == "MULTICA_CODEX_ARGS" || strings.HasPrefix(key, "MULTICA_LOCAL_APPROVAL_") {
			continue
		}
		env = append(env, value)
	}
	return append(env, "MULTICA_CODEX_ARGS="+args)
}

func appendLog(path string) (*os.File, error) {
	if info, err := os.Stat(path); err == nil && info.Size() > 4*1024*1024 {
		if err := os.Rename(path, path+"."+time.Now().UTC().Format("20060102T150405.000000000")); err != nil {
			return nil, err
		}
	}
	return os.OpenFile(path, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0600)
}

func supervise(cfg config) error {
	if !filepath.IsAbs(cfg.CLI) || !filepath.IsAbs(cfg.WorkspacesRoot) || !filepath.IsAbs(cfg.LogDir) || cfg.Profile == "" || cfg.CodexArgs == "" {
		return fmt.Errorf("absolute paths, profile and Codex arguments are required")
	}
	if err := os.MkdirAll(cfg.LogDir, 0700); err != nil {
		return err
	}
	log, err := appendLog(filepath.Join(cfg.LogDir, "supervisor.jsonl"))
	if err != nil {
		return err
	}
	defer log.Close()
	record := func(event string, fields any) {
		_ = json.NewEncoder(log).Encode(map[string]any{"at": time.Now().UTC(), "event": event, "details": fields})
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	status := exec.CommandContext(ctx, cfg.CLI, "--profile", cfg.Profile, "daemon", "status", "--output", "json")
	status.SysProcAttr = &syscall.SysProcAttr{HideWindow: true, CreationFlags: 0x08000000}
	status.Env = environment(cfg.CodexArgs)
	raw, err := status.Output()
	var health struct {
		Status string `json:"status"`
		PID    int    `json:"pid"`
	}
	if err == nil && json.Unmarshal(raw, &health) == nil && health.Status == "running" && health.PID > 0 {
		return nil
	}
	output, err := appendLog(filepath.Join(cfg.LogDir, "daemon-console.log"))
	if err != nil {
		return err
	}
	defer output.Close()
	// Foreground mode retains this hidden console. DETACHED_PROCESS and
	// CREATE_NO_WINDOW strip it, allowing descendants to create visible consoles.
	start := func(breakaway bool) (*exec.Cmd, error) {
		cmd := exec.Command(cfg.CLI, "--profile", cfg.Profile, "daemon", "start", "--foreground", "--no-auto-update", "--no-auto-reload", "--workspaces-root", cfg.WorkspacesRoot)
		flags := uint32(0x10)
		if breakaway {
			flags |= 0x01000000
		}
		cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true, CreationFlags: flags}
		cmd.Env = environment(cfg.CodexArgs)
		cmd.Stdout = output
		cmd.Stderr = output
		return cmd, cmd.Start()
	}
	cmd, err := start(true)
	if errors.Is(err, syscall.ERROR_ACCESS_DENIED) {
		cmd, err = start(false)
	}
	if err != nil {
		record("start_failed", err.Error())
		return err
	}
	record("started", map[string]any{"pid": cmd.Process.Pid, "mode": "foreground_hidden_console"})
	return cmd.Process.Release()
}

func main() {
	if len(os.Args) != 2 {
		os.Exit(2)
	}
	raw, err := os.ReadFile(os.Args[1])
	if err != nil {
		os.Exit(2)
	}
	var cfg config
	if json.Unmarshal(raw, &cfg) != nil {
		os.Exit(2)
	}
	if supervise(cfg) != nil {
		os.Exit(1)
	}
}
