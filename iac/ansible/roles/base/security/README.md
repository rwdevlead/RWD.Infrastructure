# base/security

Applies baseline system security hardening.

## Components

- Fail2ban (enabled by default)
- Sysctl hardening (light)
- Optional UFW firewall (disabled by default)

## Safety

- No SSH lockouts
- No Docker conflicts
- Firewall is opt-in

## Recommended Usage

Enable firewall only on non-Docker hosts.
