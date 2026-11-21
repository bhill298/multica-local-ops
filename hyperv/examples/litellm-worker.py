#!/usr/bin/env python3
"""One text turn through a Chat Completions gateway, using Multica's Claude protocol family."""
import json
import os
import subprocess
import sys
from urllib.request import HTTPRedirectHandler, Request, build_opener


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, *args):
        return None


def main():
    if "--version" in sys.argv:
        print("litellm-worker 1.0.0")
        return
    if "--resume" in sys.argv or "--continue" in sys.argv:
        raise ValueError("This example handles fresh, single-turn runs only.")
    message = json.loads(sys.stdin.readline())["message"]
    prompt = "\n".join(block["text"] for block in message["content"] if block["type"] == "text")
    # Multica can send a pointer to an issue instead of putting its contents in the prompt.
    if os.environ.get("MULTICA_TASK_ID"):
        tasks = json.loads(subprocess.check_output(["multica", "agent", "tasks", os.environ["MULTICA_AGENT_ID"],
                                                    "--output", "json"]))
        task = next(row for row in tasks if row["id"] == os.environ["MULTICA_TASK_ID"])
        if task.get("issue_id"):
            issue = json.loads(subprocess.check_output(["multica", "issue", "get", task["issue_id"], "--output", "json"]))
            prompt += "\n\n" + issue["title"] + "\n" + (issue.get("description") or "")
    url = os.environ["GATEWAY_BASE_URL"].rstrip("/") + "/chat/completions"
    body = {"model": os.environ["GATEWAY_MODEL"], "messages": [{"role": "user", "content": prompt}]}
    headers = {"Content-Type": "application/json", "Authorization": "Bearer " + os.environ["GATEWAY_API_KEY"]}
    request = Request(url, data=json.dumps(body).encode(), headers=headers)
    with build_opener(NoRedirect()).open(request, timeout=120) as response:
        text = json.load(response)["choices"][0]["message"]["content"]
    if not isinstance(text, str) or not text.strip():
        raise ValueError("Gateway returned no text.")
    print(json.dumps({"type": "assistant", "message": {"role": "assistant", "content": [{"type": "text", "text": text}]}}))
    print(json.dumps({"type": "result", "subtype": "success", "is_error": False, "result": text}))


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        # URLs, headers, prompts and gateway response bodies can all contain secrets.
        print(f"Gateway worker failed ({type(error).__name__}). Check its configuration and endpoint.", file=sys.stderr)
        sys.exit(1)
