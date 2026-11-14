//go:build windows

package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestEnvironmentRemovesBrokerAndReplacesPolicy(t *testing.T) {
	t.Setenv("MULTICA_LOCAL_APPROVAL_TOKEN_FILE", "must-not-inherit")
	t.Setenv("MULTICA_CODEX_ARGS", "old-policy")
	t.Setenv("MULTICA_OPS_TEST_KEEP", "kept")
	joined := strings.Join(environment("new-policy"), "\n")
	if strings.Contains(joined, "must-not-inherit") || strings.Contains(joined, "old-policy") || !strings.Contains(joined, "MULTICA_CODEX_ARGS=new-policy") || !strings.Contains(joined, "MULTICA_OPS_TEST_KEEP=kept") {
		t.Fatal("incorrect inherited environment")
	}
}

func TestAppendLogPreservesPreviousContents(t *testing.T) {
	path := filepath.Join(t.TempDir(), "events.jsonl")
	for _, value := range []string{"first\n", "second\n"} {
		f, err := appendLog(path)
		if err != nil {
			t.Fatal(err)
		}
		if _, err = f.WriteString(value); err != nil {
			t.Fatal(err)
		}
		f.Close()
	}
	raw, err := os.ReadFile(path)
	if err != nil || string(raw) != "first\nsecond\n" {
		t.Fatalf("lost prior log: %q %v", raw, err)
	}
}

func TestRejectIncompleteConfiguration(t *testing.T) {
	if supervise(config{}) == nil {
		t.Fatal("accepted incomplete configuration")
	}
}
