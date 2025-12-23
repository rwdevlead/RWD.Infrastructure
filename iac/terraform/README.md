Summerize all the terraform files and modules with links to each

each folder in the terraform folder is a destination. example github repositories or proxmox server.

add a note that ubuntu no longer has qemu guest agent installed with img file. Highligh to bring to attention.

how to make a template in proxmox
If you want to keep it all in Terraform, do this:

1. Step A (The Build):

- template = false

- started = true

- Run terraform apply.

- Result: The VM boots, Cloud-Init runs, installs your tools, and runs your cleanup/sealing commands.

Step B (The Seal):

- Change the file to template = true and started = false.

- Run terraform apply again.

- Result: Terraform sees the change, stops the VM, and converts it to a template.

A Warning on the Cleanup Script

If you include truncate -s 0 /etc/machine-id in your runcmd, the VM will technically be "broken" until it reboots (as the machine-id is cleared). This is perfect for a template, but it's why Step B (shutting it down immediately after the script runs) is so important.
