if (location.pathname === "/manage") {
  const el = id => document.getElementById(id);
  el("manage").hidden = false;
  const keyRequired = document.documentElement.hasAttribute("data-key-required");
  const headers = {};
  if (keyRequired) {
    const fragment = location.hash.slice(1);
    if (/^[a-f0-9]{64}$/.test(fragment)) localStorage.setItem("multicaOperator", fragment);
    const key = localStorage.getItem("multicaOperator");
    if (key) headers.Authorization = "Bearer " + key;
  }
  if (location.hash) history.replaceState(null, "", "/manage");
  let busy = false;
  function table(title, columns, rows) {
    const h = document.createElement("h2");
    h.textContent = title;
    const t = document.createElement("table");
    const head = t.createTHead().insertRow();
    for (const label of columns) {
      const th = document.createElement("th");
      th.scope = "col";
      th.textContent = label;
      head.append(th);
    }
    const body = t.createTBody();
    for (const row of rows) {
      const tr = body.insertRow();
      for (const item of row) tr.insertCell().textContent = item;
    }
    el("details").append(h, t);
  }
  function status(s) {
    el("summary").textContent = "VM: " + s.vm + " · Windows boot autostart: " + s.boot + " · Last host check: " + new Date(s.checked).toLocaleString();
    el("details").replaceChildren();
    if (s.guest) {
      table("Agents", ["Workspace", "Agent", "Runtime", "Status"], (s.guest.agents || []).map(a => [a.workspace, a.name, a.runtime, a.status]));
      table("Worker runtimes", ["Workspace", "Runtime", "Provider", "Status"], s.guest.workers.map(w => [w.workspace, w.name || w.provider, w.provider, w.status]));
      table("Containers", ["Container", "Image", "Status"], s.guest.containers.map(c => [c.name, c.image, c.status]));
      if (s.guest.errors.length) el("details").append(s.guest.errors.join(" "));
    } else if (s.detail) el("details").append(s.detail);
    const boot = el("boot");
    boot.hidden = !["enabled","disabled"].includes(s.boot);
    boot.dataset.action = s.boot === "enabled" ? "boot-off" : "boot-on";
    boot.textContent = s.boot === "enabled" ? "Disable boot autostart" : "Enable boot autostart";
  }
  async function request(path, options = {}) {
    const response = await fetch(path, {...options, headers:{...headers, ...options.headers}});
    if (!response.ok) throw Error((await response.text()).trim());
    return response;
  }
  async function action(a) {
    if (busy) return;
    busy = true;
    const buttons = document.querySelectorAll("button");
    buttons.forEach(b => b.disabled = true);
    try {
      const job = async () => (await request("/api/job")).json();
      let j = await job();
      el("controls").hidden = false;
      if (!j.running) {
        await request("/api/action", {method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({action:a})});
      }
      do {
        j = await job();
        if (j.running) {
          el("summary").textContent = "Running: " + j.action + "…";
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
      } while (j.running);
      if (j.ok && j.action === "status") status(JSON.parse(j.message));
      else {
        el("result").textContent = j.message;
        el("summary").textContent = j.ok ? "Operation completed." : "Operation failed.";
        if (j.action !== "status") setTimeout(() => action("status"), 300);
      }
    } catch (error) {
      el("summary").textContent = error.message;
      if (keyRequired && el("controls").hidden) el("result").textContent = "On Windows run ./hyperv/Connect-Guest.ps1 -Action Manage from the installer checkout.";
    } finally { busy = false; buttons.forEach(b => b.disabled = false); }
  }
  document.querySelectorAll("button").forEach(b => b.onclick = () => {
    const a = b.dataset.action;
    if (["stop","restart","install"].includes(a) && !confirm(b.textContent + "? This can interrupt access to both dashboards.")) return;
    action(a);
  });
  action("status");
  setInterval(() => { if (!document.hidden && !el("controls").hidden) action("status"); }, 60000);
}
