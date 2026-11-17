# <Module Name> Module

<Concise summary of what infrastructure this Terraform module provisions and on which provider (Proxmox VE / GitHub).>

## Features

- <Key capability 1>
- <Key capability 2>
- <Key capability 3>

## Usage

```hcl
module "<instance_name>" {
  source = "../../../modules/<provider>/<module-name>"

  # Required inputs
  <required_var> = <value>
}
```

## Inputs

| Name | Description | Type | Default | Required |
| :--- | :--- | :--- | :--- | :--- |
| `<var_name>` | <Variable description> | `<type>` | n/a | yes |
| `<optional_var>` | <Variable description> | `<type>` | `<default>` | no |

## Outputs

| Name | Description |
| :--- | :--- |
| `<output_name>` | <Output description> |

## Notes

- <Lifecycle caveats (`ignore_changes`), provider limitations, guest-agent prerequisites, or state/import notes.>
