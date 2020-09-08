# About this repo
This repo is used to provision CSESoc owned servers and accounts. It uses git secret to encrypt secrets. You'll need to be added by another collaborator in order to decrypt secrets. See [git secret](http://git-secret.io/) for more information.

## Repo Dependencies:

You'll need the following tools to do anything useful with this repo.

  - [Git Secret](http://git-secret.io/).
  - [Ansible](http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)\

# Exec Handover

Congratulations new CSESoc Dev Head. You have now inherited all of CSESoc's production infrastructure!

Being dev head is a reasonably simple task once you get your head around all of the tooling outlined in this repo. Some of the most difficult tasks you'll need to deal with will include:

- Adding new deployment stacks in rancher
- Upgrading the deployment environment Linux distribution
- Renewing [SSL Certificates](ssl)

Fortunately for you, this is all documented in this repo. If you find any of the documentation lacking in any way, feel free to make modifications so that future dev heads can benefit from the newfound knowledge. 

If you are unsure of why something is a particular way and not another, or wish to get help using the tooling exposed in this repo, please get in contact with a previous dev head.    
 
# Servers under management

### CSESoc CSE Account

The CSE account is used for hosting services that depend on CSE provided services, such as `mlalias` and `pp`. The account is completely provisioned using playbooks in this repo.

### Wheatley - `wheatley.cse.unsw.edu.au`

Wheatley is a server running on a CSE managed hypervisor. It is provisioned using playbooks in this repo. We moved from away from `glados` to `wheatley` in April 2018.

Wheatley runs the following services:

- Rancher Frontend/UI
- Rancher Agent: Wheatley can run docker containers.

**Backups**

Data in the `/containers` directory is backed up to the `ssh://csesoc@cse.unsw.edu.au:~/backups` every night at midnight.

**Software Updates**

Wheatley is configured to automatically install software updates nightly. Wheatley should be checked in on at a regular frequency to ensure critical updates are being applied and that system reboots are occurring to apply critical kernel patches.

When a new dist version is released, you will need to undertake the `dist-upgrade` process for Ubuntu to upgrade.  

# Permitting User Access

For the most part, collaborators can simply be added as users to the Rancher instance, and **do not** need SSH access to the underlying hosts. This will give those users permissions to launch new stacks and manage them.

# Adding Additional Collaborators

To add a new infrastructure collaborator you must:

1. Add the user to the git secret collaborators for this repo (`git secret tell your@gpg.email`).
2. Re-encrypt all secret files. (`git secret hide -c`).
3. Add the user's ssh public key to the authorised_keys in `ssh-access.playbook.yml` and apply the playbook to all hosts in the inventory (`ansible-playbook playbooks/ssh-access.playbook.yml`). This will permit the new collaborator SSH access to all CSESoc owned hosts.
5. Commit and push all of these changes.

# Removing Collaborators

Memberships to the dev team are transient. People may come and go. For this reason it's important to know how to secure the CSESoc deployment environment.

1. Remove the user from the git secret collaborators for this repo (`git secret killperson your@gpg.email`)
2. (Optional): Rotate all affected secrets. If the member leaving goes rogue they will still have access to any unchanged secrets. This means they can still access the infrastructure. To resolve this any secrets they have had access to should be rotated.
3. Re-encrypt all the secret files. (`git secret hide -c`)
4. Remove the user's ssh public key to the authorised_keys in `ssh-access.playbook.yml` and apply the playbook to all hosts in the inventory (`ansible-playbook playbooks/ssh-access.playbook.yml`). This will remove access via SSH access to all CSESoc owned hosts.
5. Remove the user's personal account from all associated services (e.g. [rancher](https://wheatley.cse.unsw.edu.au:7654), [csesoc-website](https://www.csesoc.unsw.edu.au) etc.)
6. Commit and push all of these changes.

# Secrets

In order to ensure all users of this repo have the latest set of configuration secrets, they are checked in with git secret. Unfortunately this opens a large risk to accidentally committing un-encrypted secrets.

Please read the [`git secret` manual](http://git-secret.io/) before attempting to check in any secret keys. When committing be diligent before pushing.

You can encrypt new files by doing `git secret add  <filenames>`. New files should be added to `.gitignore` to avoid their unencrypted counterpart from being checked in (can do this automatically with `git secret add -i <filenames>`. Once added to the git secret index, you must encrypt them. Do this by running `git secret hide -m -d`. This command will encrypt and delete the plaintext version of your secrets. You should be able to safely check in your new secrets. Once checked in, you can reveal the secrets: `git secret reveal`.

You can query which files are encrypted at any time by running `git secret list`. You can remove unencrypted files by running `git secret hide -d`.


## Decrypting the repo

To access the secrets stored in this repo, you must decrypt them. In order to be able to decrypt it, another user must have added you as a git secret collaborator.

```bash
git secret reveal
```

# Using Ansible / Running Playbooks

A playbook declares configuration and manual steps required to provision a machine. The playbooks in this repo can be found in the [playbooks](ansible/playbooks/) dir.

Before running playbooks, ensure you have decrypted the repo. Failure to decrypt the repo will result in copying encrypted secrets to target servers.

**Install Ansible Dependencies**

```bash
ansible-galaxy install -r requirements.yml
```

## Playbook Usage

```bash
# Provision all hosts SSH authorized_keys
ansible-playbook  playbooks/ssh-access.playbook.yml
# Provision CSE account (you should not need to run this unless setting up an entirely new environment)
ansible-playbook  -l cse playbooks/cse-cgi.playbook.yml
# Provision Wheatley System (you should not need to run this unless setting up an entirely new environment)
ansible-playbook  -l wheatley playbooks/wheatley-sys.playbook.yml
# Provision Wheatley Apps
ansible-playbook  -l wheatley playbooks/wheatley-apps.playbook.yml
```

The `wheatley-sys.playbook.yml` playbook will provision the system with the SSH `authorised_keys` defined in`ssh-access.playbook.yml`. This playbook can be individually run on other hosts to configure SSH access.

# SSL Certificates
Read more about SSL (including how to renew certificates) in the [ssl dir](ssl).

After renewing certificates you will need to re-run playbooks to ensure the updated certs are copied.

# Rancher

Rancher is open source software that combines everything an organization needs to adopt and run containers in production.

All CSESoc services must be deployed via Rancher. Deploying an application within Rancher will mean it is monitored and guaranteed to be backed up. In addition to this, it will mean that inbound traffic can be easily routed to it and terminated with an SSL certificate at no additional effort to the deployer.

## Accessing Rancher
The rancher UI is exposed on port `7654` over `ssl`. Access it at [https://wheatley.cse.unsw.edu.au:7654](https://wheatley.cse.unsw.edu.au:7654)
