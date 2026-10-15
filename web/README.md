# Decisor Web

Cliente web estático y responsive. Funciona en navegadores modernos con `crypto.getRandomValues`, `localStorage`, `dialog` y, opcionalmente, vibración/sonido del navegador.

## Ejecutar y comprobar

Abre `index.html` o usa un servidor estático desde la raíz del repositorio:

```powershell
python -m http.server 8080
```

Luego visita `http://localhost:8080/web/`. Para validar la lógica local:

```powershell
node --check web/app.js
node web/test-data.js
```

## Datos y accesibilidad

Los ajustes, opciones e historial (máximo 50 jugadas) permanecen solo en `localStorage`. Datos corruptos se descartan de forma segura. Las ruletas incluyen leyenda de texto y color; los resultados usan regiones live y los diálogos permiten teclado, Escape y foco nativo.

## Límites actuales

No incluye PWA, analítica, anuncios ni sincronización entre navegadores.

## Interacción

- Se bloquean cambios de modo y edición mientras se sortea; el estado muestra “Sorteando…” hasta el resultado.
- El editor admite una opción por línea (hasta 12, con 60 caracteres cada una), ejemplos opcionales y deshacer la última eliminación. El historial también permite deshacer su limpieza.
- Las áreas de juego tienen desplazamiento propio para pantallas horizontales, texto ampliado y teclado. El CTA queda separado del contenido.
- Se respeta `prefers-reduced-motion`; el texto sobre resultados de color se calcula por contraste. Los botones táctiles tienen al menos 48 px.
- Si el navegador bloquea el acceso a almacenamiento, se puede seguir jugando sin persistencia.
