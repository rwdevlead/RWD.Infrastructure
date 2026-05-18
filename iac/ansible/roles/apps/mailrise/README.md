# apps/mailrise

Deploys MailRise SMTP alert router.

## Responsibilities

- Render MailRise config
- Deploy container via Docker Compose

## Ports

- SMTP: configurable (default 8025)

## Notes

- No web UI
- Credentials should be stored in Ansible Vault

## Working Test Script

```bash
ka8kgj on Jims-MBP at 󰋜 ~ swaks --to alerts@mailrise.xyz --server 192.168.50.14 --port 8025
or swaks --to alerts@mailrise.xyz --server mailrise.local.rwdevs.com --port 8025
```

### should return this:

```bash
=== Trying 192.168.50.14:8025...
=== Connected to 192.168.50.14.
<- 220 c706c1d44589 Mailrise 1.4.0
-> EHLO jims-mbp
<- 250-c706c1d44589
<- 250-SIZE 33554432
<- 250-8BITMIME
<- 250-SMTPUTF8
<- 250-AUTH LOGIN PLAIN
<- 250 HELP
-> MAIL FROM:<ka8kgj@jims-mbp>
<- 250 OK
-> RCPT TO:<alerts@mailrise.xyz>
<- 250 OK
-> DATA
<- 354 End data with <CR><LF>.<CR><LF>
-> Date: Sun, 17 May 2026 20:37:27 -0400
-> To: alerts@mailrise.xyz
-> From: ka8kgj@jims-mbp
-> Subject: test Sun, 17 May 2026 20:37:27 -0400
-> Message-Id: <20260517203727.041366@jims-mbp>
-> X-Mailer: swaks v20240103.0 jetmore.org/john/code/swaks/
->
-> This is a test mailing
->
->
-> .
<- 250 OK
-> QUIT
<- 221 Bye
=== Connection closed with remote host.
```
