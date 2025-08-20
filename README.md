# ⚙️ Proxmox LXC Dev Environment Provisioning

This project automates the creation and provisioning of **development-ready LXC containers** on a Proxmox host. Each LXC is created in isolation, automatically installs essential development tools, and cleans itself up — giving you a fresh environment for each project.

---

## 🛠️ How It Works

- You run create-lxc.sh, passing a VM ID, hostname, and (optional) password.
- The script creates a new LXC container from a standard Debian template.
- It injects setup.sh into the container.
- A one-time systemd service (setup-provision.service) is added to the container to run setup.sh on first boot.
- The container is restarted.
- On boot, the provisioning service runs setup.sh, installs tools, then removes itself.
- The container ends up with a clean development environment, and no leftover provisioning services.

## 🧠 Why This Exists

Setting up isolated dev environments manually in Proxmox is repetitive and error-prone. With this solution:

- You run a single script
- A container is created, started, and configured
- Your standard dev tools (`curl`, `sudo`, `git`, `node`, `npm`) are pre-installed
- The container is **ready to develop in** as soon as it's online

This enables effortless multi-project development and testing using LXCs.

---

## 🗂️ File Structure

Here’s how your host system should be organized:

```bash
   ├── create-lxc.sh
   ├── hook.sh
   └── setup.sh
```

- Place the setup and creation files directly in `/var/lib/lxc-scripts/` on your Proxmox host.
- Make both scripts executable using:

```bash
   chmod +x /var/lib/lxc-scripts/*.sh
```
## 🚀 Steps to Use
1. Ensure the Debian Template Exists

This setup assumes you’re using the following template:

```bash
   local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst
```
2. 🖥️ Adding the Script to Proxmox GUI (Snippet)

```bash
   mkdir -p /var/lib/vz/snippets
```
Then place the hook.sh script in that snippet directory

```bash
   chmod +x /var/lib/vz/snippets/hook.sh
```

3. Run the Create Script

To create a new dev container:

```bash
   /var/lib/lxc-scripts/create-lxc.sh <VMID> <hostname>
```

by default the username is password is:

```bash
   Username: root
   Password: changeme
```

## 📋 What Happens Inside the Container

When the container first boots:

/root/setup.sh is executed by systemd
The script:
- Updates and upgrades the system
- Installs sudo, curl, git, nodejs, and npm
- Removes itself and the provisioning service after completion
- This ensures containers are not only set up but also clean of setup tools afterward.

## Troubleshooting

You may need to stop and destroy the LXC from the root shell, if it doesnt provision correctley

```bash
   lxc-stop <VMID>
```
```bash
   pct destroy <VMID>
```

## 🔍 Viewing Setup Logs

To view logs from the setup process (to verify or debug):

```bash
   pct exec <VMID> -- journalctl -u setup-provision.service -b
```

## 🧩 Extend It Further

You can modify setup.sh to:

- Add project folders
- Install Docker, PostgreSQL, Python, etc.
- Clone repositories
- Add users or SSH keys

It’s your sandbox — this just gets you started fast.

## 🤝 Contribute / Customize

- Feel free to fork and improve this! A few enhancement ideas:
- Add user creation and SSH key injection
- Provision Docker and docker-compose
- Project-specific templates

## 🧨 Quick Recap

✅ Isolated LXCs per project
✅ Node, Git, Curl pre-installed
✅ No manual setup — fully automated
✅ Systemd provisioning that self-destructs
✅ CLI + GUI support for container creation

