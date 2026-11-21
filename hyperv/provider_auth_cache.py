"""Transfer one provider's file-backed login over a private process pipe."""
import json
import os
from pathlib import Path
import sys
import tempfile


FILES = {
    "codex": ".codex/auth.json",
    "claude": ".claude/.credentials.json",
    "agy": ".gemini/antigravity-cli/antigravity-oauth-token",
}


def login_fields(provider, data):
    if not isinstance(data, dict):
        raise ValueError("Unrecognized provider login.")
    if provider == "codex":
        if data.get("auth_mode") != "chatgpt":
            raise ValueError("Sign in to Codex with ChatGPT first.")
        section = "tokens"
        required = ("access_token", "refresh_token", "id_token")
        optional = ("account_id",)
        result = {"auth_mode": "chatgpt", "last_refresh": data.get("last_refresh")}
    elif provider == "claude":
        section = "claudeAiOauth"
        required = ("accessToken", "refreshToken")
        optional = ("expiresAt", "refreshTokenExpiresAt", "scopes", "subscriptionType", "subscriptionTypeSource",
                    "rateLimitTier", "accountUuid", "organizationUuid")
        result = {}
    elif provider == "agy":
        section = "token"
        required = ("access_token", "refresh_token", "token_type")
        optional = ("expiry", "expires_in")
        result = {k: data[k] for k in ("auth_method", "id_token_email") if isinstance(data.get(k), str)}
    else:
        raise ValueError("Unknown provider.")
    tokens = data.get(section)
    if not isinstance(tokens, dict) or not all(isinstance(tokens.get(k), str) and tokens[k] for k in required):
        raise ValueError(f"Incomplete {provider} OAuth login. Sign in again.")
    result[section] = {k: tokens[k] for k in (*required, *optional) if k in tokens}
    return result


def cache_path(home, provider):
    path = home / FILES[provider]
    if path.resolve() != home.resolve() / FILES[provider]:
        raise ValueError("The provider login path contains a symlink.")
    return path


def install_login(home, provider, data):
    login = login_fields(provider, data)
    path = cache_path(home, provider)
    path.parent.mkdir(parents=True, mode=0o700, exist_ok=True)
    if provider == "claude" and path.exists():
        # Claude can store other credential types in this file.
        existing = json.loads(path.read_text())
        login = {**existing, **login}
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as f:
            temporary = Path(f.name)
            json.dump(login, f)
        os.replace(temporary, path)
    finally:
        if temporary:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    action, provider = sys.argv[1:]
    if provider not in FILES or action not in ("export", "import"):
        sys.exit("Expected export or import and a supported provider.")
    try:
        if action == "export":
            if sys.stdout.isatty():
                sys.exit("Run the shared-login helper to send the login directly to the worker.")
            data = json.loads(cache_path(Path.home(), provider).read_text())
            json.dump(login_fields(provider, data), sys.stdout)
        else:
            install_login(Path.home(), provider, json.load(sys.stdin))
    except (OSError, ValueError, TypeError):
        sys.exit(f"Could not {action} the {provider} file-backed OAuth login. Check provider sign-in and file permissions.")
