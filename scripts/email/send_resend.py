"""Send the Liora update email through Resend, one message per recipient.

usage: send_resend.py <repo> test <email>
       send_resend.py <repo> all
"""
import json, ssl, sys, urllib.request
from pathlib import Path

repo = Path(sys.argv[1])
mode = sys.argv[2]

env = {}
for line in (repo / ".env/resend.env").read_text().splitlines():
    if "=" in line and not line.lstrip().startswith("#"):
        k, v = line.split("=", 1)
        env[k.strip()] = v.strip().strip('"').strip("'")

mail_dir = repo / "scripts/email"
html = (mail_dir / "liora-actualizacion.html").read_text(encoding="utf-8")
txt_lines = (mail_dir / "liora-actualizacion.txt").read_text(encoding="utf-8").splitlines()
subject = txt_lines[1].split(":", 1)[1].strip()
text = "\n".join(txt_lines[3:]).strip() + "\n"

if mode == "test":
    recipients = [sys.argv[3]]
else:
    seen, recipients = set(), []
    for r in (mail_dir / "testers.txt").read_text().split():
        if r.lower() not in seen:
            seen.add(r.lower())
            recipients.append(r)

print(f"Asunto: {subject}\nDestinatarios: {len(recipients)}")

payload = [
    {"from": env["RESEND_FROM"], "to": [r], "subject": subject, "html": html, "text": text}
    for r in recipients
]
results = []
for i in range(0, len(payload), 100):
    req = urllib.request.Request(
        "https://api.resend.com/emails/batch",
        data=json.dumps(payload[i : i + 100]).encode(),
        headers={
            "Authorization": f"Bearer {env['RESEND_API_KEY']}",
            "Content-Type": "application/json",
            "User-Agent": "liora-mailer/1.0",
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(req, context=ssl.create_default_context(cafile="/etc/ssl/cert.pem")) as resp:
            body = json.loads(resp.read())
    except urllib.error.HTTPError as e:
        print("ERROR", e.code, e.read().decode())
        sys.exit(1)
    results += body.get("data", [])

for r, res in zip(recipients, results):
    print(r, "->", res.get("id"))
print(f"Enviados: {len(results)}/{len(recipients)}")
