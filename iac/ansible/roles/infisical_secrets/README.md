# Infisical Secrets role

## Purpose

This role logs in to Infisical and reads secrets from configured paths, merging them into a single `secrets` fact for callers.

## Defaults

The role provides a default list of paths to read in `defaults/main.yml`:

- `infisical_secret_paths` (default):
  - `/`
  - `/ansible/mail`

You can override this in a playbook or inventory:

vars:
infisical_secret_paths: - "/" - "/my/other/path"

## Secrets structure

The role sets a `secrets` fact with these properties:

- Nested maps for paths: e.g. `secrets.ansible.mail.OUTLOOK_MAIL_USER`.
- Dotted-key mapping preserved: `secrets['ansible.mail']['OUTLOOK_MAIL_USER']`.
- Root secrets promoted: keys under `/` are merged into top-level `secrets` so `secrets.SECRET` works.

## Usage example

- Access a namespaced secret:

  {{ "{{ secrets.ansible.mail.OUTLOOK_MAIL_USER }}" }}

- Access a promoted root secret:

  {{ "{{ secrets.SECRET }}" }}

## Notes

- This role relies on the external `infisical.vault` Ansible collection; do not vendor it into this repo.
- The merging strategy is last-merge-wins for key collisions (recursive combine).
- For larger deployments you may prefer to drive `infisical_secret_paths` from inventory/group_vars.
