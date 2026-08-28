# short term vars to hold secrets
locals {
  github_token = data.infisical_secrets.github.secrets["GITHUB_TOKEN"].value
  github_owner = data.infisical_secrets.github.secrets["GITHUB_OWNER"].value
}
