# Ficha App Store · campos comunes a los dos idiomas

## Información de la app
- Categoría principal: Libros
- Categoría secundaria: Educación (opcional; si dudas, déjala vacía)
- Clasificación por edades (App Store): 4+ (sin contenido sensible, sin web abierta, sin cuentas)
- Clasificación por edades (Google Play, cuestionario IARC rellenado el 5 nov 2026, guardado y pendiente de enviar a revisión): ESRB Everyone, PEGI 3, USK todas las edades, IARC / Rusia / Corea del Sur 3+. Brasil queda ClassInd 14 solo por las compras dentro de la app (Liora Plus); no hay descriptores de violencia, sexo, lenguaje ni drogas. No se puede bajar Brasil sin ocultar la compra.
- Derechos de uso (Copyright): `2026 <tu nombre o el de tu empresa>` (pendiente de confirmar)
- Idioma principal: el de tu elección. Los textos de `app-store-es.md` y `app-store-en.md` se cargan como localizaciones.
- Google Play no tiene español (México). La ficha usa English (United States) en-US, Spanish (Latin America) es-419 y Spanish (Spain) es-ES. El subtítulo de App Store va en la descripción corta de Play (máx. 80). Borrador guardado el 5 nov 2026; faltan icono 512×512, gráfico destacado 1024×500 y capturas de teléfono (las de iPhone 1320×2868 superan la relación 2:1 de Play).

## URLs
- Privacidad: `https://www.somosliora.app/privacy` (EN) y `https://www.somosliora.app/es/privacy` (ES)
- Soporte: `https://www.somosliora.app` (confirmar que existe una página de contacto)
- Marketing: opcional, `https://www.somosliora.app`

## Privacidad de la app ("Nutrición de privacidad")
- La app no tiene cuentas. Confirma el cuestionario con lo que realmente envían Firebase y RevenueCat (identificadores y datos de compra). No marques "No se recopilan datos" sin revisarlo.

## Capturas
Carpeta: `~/Code/node/store-screenshots/projects/mi-app/output/exports/set-3/`
- ES: `es/app-store/iphone-grande-1320x2868/` (01 a 05, en ese orden)
- EN: `en/app-store/iphone-grande-1320x2868/` (01 a 05, en ese orden)
- Basta con las de 1320x2868 (iPhone 6.9"); Connect escala el resto. La carpeta `iphone-mediana-1206x2622` es opcional.
- Aviso: el interior del teléfono en las capturas ES está en inglés (se hicieron con el simulador en inglés). Conviene rehacer las referencias con el simulador en español antes de subir la ficha en español.

## Información para la revisión
- Inicio de sesión: no necesario (la app no tiene cuentas).
- Notas para el revisor:

```
Liora has no accounts or login. Books and progress stay on the device.
In-app purchase "Liora Plus" (product ID: plus, non-consumable, one-time):
open the Profile tab, tap "Premium", then "Unlock". It unlocks three sections:
Month in review, Time per book and Appearance. A "Restore purchase" button is on
the same screen. To import a book you can use any EPUB file or download one from
the in-app catalog (Discover tab).
```

## Compra integrada `plus`
- Asociarla a la versión 1.0 con el build 1.0.0 (2) en "Compras integradas y suscripciones".
- Captura de revisión: la pantalla `PremiumPage` final (precio real, botón de restaurar).
