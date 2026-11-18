# Correos de actualización de Liora

Nota corta a los testers cuando sale una versión nueva. Se envía con Resend.

## Archivos

- `liora-actualizacion.html`: el correo con diseño. Se reescribe en cada envío y el historial queda en git.
- `liora-actualizacion.txt`: la versión en texto plano. La línea 2 (`Asunto: …`) es el asunto que se envía.
- `testers.txt`: los destinatarios, uno por línea. **No está en git** porque el repo es público.
- `send_resend.py`: envía el correo con un mensaje por destinatario, para que nadie vea las direcciones de los demás.
- `../../.env/resend.env`: `RESEND_API_KEY` y `RESEND_FROM`. Es local y no está en git.

## Proceso

1. **Juntar los cambios** desde la última versión enviada:
   - Esta app: `git log --no-merges <commit del último aumento de versión>..HEAD`
   - flutter_readium (rama `prod`, en `../flutter_readium`): `git log origin/prod --since=<fecha de la última versión>`
2. **Escribir el correo** en el `.html` y el `.txt`, con los mismos textos en los dos. Actualiza la fecha, el asunto, el título, el texto de vista previa oculto y las secciones.
   - Escribe en lenguaje simple, para lectores y no para desarrolladores. Habla de lo que la persona puede hacer, no de cómo funciona por dentro.
   - Usa la primera persona y trata de "tú" a quien lee. Mantén el pie y la frase de baja ("basta").
3. **Revisar en el navegador:** `open scripts/email/liora-actualizacion.html`
4. **Enviar una prueba a ti mismo:**
   ```sh
   python3 -I scripts/email/send_resend.py "$PWD" test tu@correo.com
   ```
   Revísala en Gmail, incluida la carpeta de spam.
5. **Enviar a todos**, solo cuando la prueba esté bien:
   ```sh
   python3 -I scripts/email/send_resend.py "$PWD" all
   ```
   El script quita los duplicados sin importar mayúsculas y muestra el id de Resend de cada correo.

## Notas

- El Python de python.org no trae certificados, así que el script usa `/etc/ssl/cert.pem` de macOS.
- La API de lotes de Resend acepta hasta 100 correos por llamada, y el script los divide en grupos solo.
- Historial de envíos: 7 nov 2026 (importar PDF) y 14 nov 2026 (PDF como un libro, 32 destinatarios).
