diseñada con un tema oscuro para una experiencia visual robusta y moderna, con elementos visuales que añaden un toque de diversión sin comprometer la funcionalidad o la percepción de seguridad.

Scope y prioridad

- Este AGENTS.md aplica a todo el árbol `lib/ui` y tiene prioridad sobre otros AGENTS.md del repo para cualquier archivo dentro de esta carpeta.
- Objetivo: lineamientos visuales y de interacción del MVP “Decisor”. Se armoniza con el PRD raíz; donde haya conflicto, prevalece el PRD funcional.

Tokens obligatorios (no hardcode)

- Usar siempre tokens desde `lib/core` (p. ej. `AppColors`, `AppText`, `Spacing`, `ThemeData`).
- Prohibido hardcodear colores, tamaños de texto y paddings en widgets de `lib/ui`.

Paleta de colores

- Base de UI (según guía):
  - Fondo: `#2C3E50` (ó `#2D3250`).
  - Texto principal: `#FFFFFF`.
  - Texto secundario: `#BDC3C7` (ó `#A9A9A9`).
  - Acentos e iconos: `#1ABC9C` (ó `#4ECDC4`).
  - Acentos oscuros/acciones: `#16A085` (ó `#3BA082`).
  - Separadores/bordes: `#4A6572` (ó `#3B3B3B`).
- Excepción ruletas (PRD):
  - Segmentos ruleta 4 colores: `#F7D154` (Amarillo), `#2D7FF9` (Azul), `#E34D4D` (Rojo), `#28C76F` (Verde), 25% cada uno.
  - Contraste de texto en segmentos: negro sobre amarillo/verde; blanco sobre azul/rojo. Mantener AA mínimo.

Tipografía

- Fuente: del sistema (Roboto en Android, San Francisco en iOS) o Lato si se incluye. Debe integrarse vía `ThemeData`.
- Mapeo a TextTheme:
  - Resultado principal: `headlineMedium`/`displaySmall` (28–32sp efectivas).
  - Títulos de sección: `titleLarge` (~24sp, Bold/Semibold).
  - Labels/ayudas: `bodyMedium` (14–16sp) y `bodySmall` (12–14sp).
- No fijar tamaños inline; extender el tema si se requiere un tamaño específico.

Espaciado y layout

- Grid de 8pt: `xs=4, s=8, m=12, l=16, xl=24`.
- Zona central: ruleta o resultado centrado; tamaño ruleta = `min(ancho, altoDisponible) * 0.8`.
- Footer: botón “Jugar” con padding `l`; separarlo del banner con `m`.
- Breakpoints: optimizar para 5–7” y tablets; mantener CTA visible y accesible.

Accesibilidad

- Semantics: el resultado debe anunciar “resultado: X”. CTA con rol button y `enabled=false` al animar.
- Objetivos táctiles ≥ 48dp; contrastes mínimo AA.
- Focus y navegación por teclado accesibles en emuladores cuando aplique.

Animación e interacción

- 60 FPS; duración total a resultado < 5 s.
- Usar `AnimationController` + `Transform.rotate` para ruletas; `AnimatedBuilder` para limitar repaints; `RepaintBoundary` en la ruleta.
- Bloquear toques múltiples: el botón “Jugar” se deshabilita durante el estado “girando/lanzando”.

Ads (AdMob)

- Banner adaptativo fijo al fondo. Nunca cubre el CTA.
- No refrescar ni solicitar nuevos banners durante una animación en curso.
- Si falla la carga, hacerlo en silencio (sin UI intrusiva).

Estados, validaciones y errores

- Número aleatorio: validar `min < max`. Mensajes claros, no bloqueantes.
- Operación offline: la app funciona; Ads fallan en silencio.
- Historial y settings: se persisten vía `SharedPreferences` (no UI bloqueante si no está disponible).

Analítica (desde la UI)

- Disparar `play_start` {mode} al tocar “Jugar”.
- Disparar `play_result` {mode, value} cuando se muestra el resultado.
- `settings_changed` {sound, haptics} al togglear.
- `ad_impression_banner`, `ad_error` según callbacks de Ads.

Componentes UI del MVP

- AppBar: título y selector de modo (tabs o segmented control).
- Zona central: ruleta (4 colores o personalizada) o resultado grande (cara/sello, número).
- CTA: botón primario “Jugar”, ancho adaptativo, deshabilitado al animar.
- Banner: contenedor fijo inferior para AdMob; reservar espacio para evitar solape con CTA.

Lineamientos particulares (iconos de acceso rápido)

- La cuadrícula de iconos no forma parte del MVP. Si se usa en el futuro como lanzador/selector, aplicar:
  - Icono grande en acento `#1ABC9C`, texto descriptivo `#FFFFFF` debajo.
  - Microinteracción al presionar (ligero scale o brillo), manteniendo 60 FPS.
  - Mantener la paleta base; respetar objetivos táctiles y Semantics.

Checklist de revisión UI

- Sin colores/tamaños hardcode: todos desde tokens.
- Contraste AA en textos sobre segmentos y fondo.
- CTA no tapado por el banner; deshabilitado al animar.
- Duración total < 5 s; 60 FPS sostenidos.
- Semantics y anuncios de resultado correctos.
