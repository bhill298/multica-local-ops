# Run an extra Multica worker

A base URL or API key in the agent editor configures the program on the
selected runtime. For example, two agents can use different gateways on the
same Codex worker. Create an extra worker when you want a separate home,
login or executable. It gets its own Docker container, volume and Multica
daemon in Ubuntu. Stock Multica handles enrollment, agents, keys and custom
runtime profiles. The installer creates no extra workers by default.

## Create and enroll

From PowerShell in this checkout:

```powershell
$worker = @{Action='ExtraWorker'; WorkerName='gateway'}
./hyperv/Connect-Guest.ps1 @worker -WorkerAction Create -Provider codex
./hyperv/Connect-Guest.ps1 @worker -WorkerAction Shell
```

Choose `codex`, `claude` or `agy` for the base image and installed tools.
From the **daily** dashboard, create a personal access token for this worker.
In its Linux shell, run `multica login --token` and paste the token at the
prompt. Check `multica workspace list` and use `multica workspace switch
<workspace-id>` if needed. This token connects the daemon to Multica. A
model API key belongs in the agent's provider configuration. Exit the shell
and start the worker:

```powershell
./hyperv/Connect-Guest.ps1 @worker -WorkerAction Start
```

Create an agent in the daily dashboard. Select the runtime on the machine
named `extra-gateway`. Set its model, instructions and any provider-specific
environment variables or arguments there. The provider CLI still has to
support the endpoint and protocol. Multica stores agent environment values
in its database in plaintext. **Manage installation** shows agents, runtimes
and containers from the two workspaces.

## Use a Python script with LiteLLM

The [example](../hyperv/examples/litellm-worker.py) sends one text request
to an OpenAI-compatible Chat Completions endpoint. It reads Multica's input
on stdin, retrieves the assigned issue title and description through the
stock CLI when available, and returns text to the run. It implements the
single-turn part of the Claude stream-JSON protocol and requires neither a
Claude subscription nor the Claude executable. It has no tool loop, chat
history, streaming or usage accounting. Use a full provider CLI for those
features. Your own script can use any protocol family stock Multica supports.

Open the **running** worker's shell again. Install the example in the
persistent home, then register a machine-bound profile:

```sh
mkdir -p ~/.local/bin
install -m 700 /opt/examples/litellm-worker.py ~/.local/bin/gateway-text
multica runtime profile create --display-name GatewayText --protocol-family claude --command-name gateway-text
multica runtime profile set-path <profile-id> --path "$HOME/.local/bin/gateway-text"
exit
```

Use the profile ID from the create command. From Windows, run the worker
helper with `-WorkerAction Stop` and then `-WorkerAction Start`. In the daily
agent editor select **GatewayText** on **extra-gateway**, and set these
environment variables:

| Variable | Value |
| --- | --- |
| `GATEWAY_BASE_URL` | Your gateway's API base, including `/v1` if required |
| `GATEWAY_MODEL` | Model or alias configured in LiteLLM |
| `GATEWAY_API_KEY` | A key issued for this agent |

Set the agent model to the same alias for clarity. The example reads
`GATEWAY_MODEL` for its request. With the stock Codex or Claude CLI you
would use that CLI's own endpoint and key settings instead.

A gateway in another container can join the Ubuntu Docker network
`multica-vm_web`, e.g. with the network alias `litellm`. The daily worker
can then use `http://litellm:4000/v1` without publishing a Windows port.
That network also contains the daily web and API and any other extra
workers. Use authentication on the gateway. For a remote gateway use HTTPS.
Loopback inside the worker reaches only that container. Host and LAN blocks
still apply to a gateway running on Windows. This helper leaves those
rules in place and does not install LiteLLM.

## Use a custom executable on the Ubuntu admin daemon

A profile attached to the admin daemon runs directly on Ubuntu with the
admin user's sudo access. Add it from the **admin** workspace and create a
separate admin agent for it. The built-in VM Admin agent can keep using Codex.
From Windows, open `./hyperv/Connect-Guest.ps1 -Action Shell`, then run:

```sh
sudo -Hu multica-vm-admin env PATH=/opt/multica-owner-bin:/usr/bin:/bin MULTICA_SERVER_URL=http://127.0.0.1:43231 bash
mkdir -p ~/.local/bin
install -m 700 /opt/multica-local/hyperv/examples/litellm-worker.py ~/.local/bin/gateway-text
multica runtime profile create --display-name AdminGateway --protocol-family claude --command-name gateway-text
multica runtime profile set-path <profile-id> --path "$HOME/.local/bin/gateway-text"
exit
sudo systemctl restart multica-vm-admin
```

Wait for idle admin jobs before restarting. Select **AdminGateway** in the
admin dashboard and set the same three variables. An Ubuntu loopback
endpoint works here. A gateway container can publish its port to Ubuntu's
`127.0.0.1` for this purpose. Treat the script and its dependencies as
VM administrator code.

## Stop, update or remove

**Stop** keeps the home and enrollment. **Start** reuses them and picks up
the current base image. A running worker restarts with Docker on guest
boot. A deliberately stopped worker stays stopped. Exit worker shells and
stop extra workers before a Multica upgrade, then start them afterward.
The updater names running extra containers if they block an upgrade.

```powershell
./hyperv/Connect-Guest.ps1 @worker -WorkerAction Stop
./hyperv/Connect-Guest.ps1 @worker -WorkerAction Start
```

Before retiring a worker, archive or reassign its agents in Multica. To
remove a custom profile, run `multica runtime profile delete <profile-id>`
and `multica runtime profile unset-path <profile-id>` in its shell. Then:

```powershell
./hyperv/Connect-Guest.ps1 @worker -WorkerAction Remove
```

**Remove deletes this worker's container and home volume**, including
locally installed scripts and logins. The project input and exchange belong
to the VM and survive. Revoke the worker's Multica token in the daily
dashboard. The stock CLI can remove its offline runtime with `multica
runtime delete <runtime-id>` after you check the machine name.

The [Compose file](../hyperv/extra-worker.compose.yaml) gives extras the
daily project's read-only input and writable exchange. They have sudo
inside their own containers, share the daily web network and receive no
Docker socket, guest root mount, admin credentials or KVM device. The
standard three workers retain KVM. The worker name and base are stored in
`/var/lib/multica-local/extra-workers` on Ubuntu. Home volumes are named
`multica-extra-<name>_home`. Changes outside a persistent mount disappear
when the container is recreated.

During the live test, a disposable daily container and a second profile
on the Ubuntu admin daemon each completed an issue through the Python
example. Local fixtures checked the request path, synthetic bearer key,
model and actual issue text. Multica recorded the returned answer in both
runs. Stop/Start preserved the daily runtime ID, and the management page
showed both agents. The test used a compatible fixture in place of a
running LiteLLM distribution.
