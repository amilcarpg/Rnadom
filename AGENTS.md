Actualizo el PRD: la app será un “decisor” con varios modos. La ruleta de 4 colores queda como un modo más.

# PRD — “Decisor”

## 1. Objetivo

Resolver decisiones al azar en segundos. Monetizar con banner fijo inferior.


1. **Cara o Sello**

   * Acción: “Lanzar”.
   * Resultado: Cara | Sello.
   * Opciones: sonido/vibración.

2. **Número aleatorio**

   * Rango configurable `min..max` (por defecto 1..10).
   * Validaciones: `min < max`, límites sugeridos −1e9..1e9.

3. **Ruleta 4 colores**

   * Amarillo, Azul, Rojo, Verde. 25% cada uno.
   * Resultado con realce visual y texto.

4. **Ruleta personalizada (N opciones)**

   * Agregar/editar/eliminar opciones (texto y color).
   * Máx. 12 opciones en MVP.
   * Guardado local del último set.

### Comunes a todos los modos

* Botón único **“Jugar”** que gira/laza/sortea.
* Estado “girando” bloquea doble toque.
* Sonido y haptics toggles.
* Accesibilidad y etiquetas Semantics.

## 3. No funcionales

* 60 FPS en animación.
* Tiempo a resultado < 5 s.
* Tamaño < 20 MB.
* Crash-free ≥ 99.5%.
* Funciona offline; los anuncios fallan en silencio.

## 4. Monetización

* **AdMob banner adaptativo** fijo abajo.
* No cubre CTA. No refresca durante animación.
* V1+: interstitial cada N “jugadas” con capping.

## 5. UX/UI

* AppBar: título y selector de modo (tabs o segmented control).
* Zona central: ruleta o resultado grande.
* Footer: botón **Jugar** sobre el banner.
* Colores sugeridos:

  * Amarillo #F7D154, Azul #2D7FF9, Rojo #E34D4D, Verde #28C76F.
* Tipos: sistema; resultado 28–32sp.
* TalkBack/VoiceOver anuncia “resultado: X”.

## 6. Reglas de negocio

* Aleatoriedad uniforme por modo.
* Ruleta personalizada: todas las opciones tienen el mismo peso en MVP.
* RNG: `Random.secure()` con fallback `Random()`.

## 7. Datos y privacidad

* `SharedPreferences`: ajustes, último rango, set de ruleta personalizada, historial.
* Sin PII. Solo SDK Ads y Analytics.

## 8. Analítica (Firebase)

Eventos:

* `play_start` {mode}
* `play_result` {mode, value}
* `settings_changed` {sound, haptics}
* `ad_impression_banner`, `ad_error`

KPIs: DAU, retención D1/D7, jugadas/sesión, TTS, fill rate, eCPM, crash-free.

## 9. Criterios de aceptación

* CA1: 50k resultados simulados por modo con desviación ≤ 2% respecto a uniforme.
* CA2: Banner visible sin solapar CTA en 5–7” y tablets.
* CA3: Botón bloqueado durante animación en todos los modos.
* CA4: Modo ruleta personalizada persiste opciones tras reinicio.

## 10. Arquitectura y stack

* **Flutter 3.x**, **Dart**.
* Estado: `Provider` (MVP).
* Ads: `google_mobile_ads`.
* Persistencia: `shared_preferences`.
* Navegación simple con `go_router` o `MaterialApp` + tabs.
* Animación: `AnimationController` + `Transform.rotate`.
* Paquetes opcionales: `vibration`, `audioplayers`.

Estructura:

```
/lib/core   (constantes, theme)
/lib/domain (models: Mode, OptionItem, Result)
/lib/services (rng, ads, analytics, storage)
/lib/state  (providers)
/lib/ui     (screens/widgets por modo)
```

Modelos clave:

* `Mode { id, name }`
* `OptionItem { id, label, color }`
* `Result { mode, value, timestamp }`
* `Settings { soundOn, hapticsOn, rangeMin, rangeMax }`

## 11. Pruebas

* Unit: RNG uniforme, validación de rangos, CRUD de opciones.
* Widget: animación termina y emite resultado correcto.
* Integración: flujo completo por modo, offline con Ads fallando.
* Manual: rotación, tamaños de fuente, distintos DPIs.

## 12. Riesgos y mitigación

* Percepción de sesgo: publicar “cómo funciona la aleatoriedad” y validar con simulaciones.
* Rechazo por ubicación de ads: respetar guías AdMob.
* Abandono por latencia: precarga de animación y audios.

## 13. Roadmap breve

* v1.1: pesos por opción, temas claro/oscuro, compartir resultado.
* v1.2: interstitial con capping, exportar historial, presets de ruletas.
* v1.3: sonidos temáticos y haptics avanzados.

## 14. Backlog MVP

1. Esqueleto app y tema.
2. Selector de modo.
3. Cara/Sello.
4. Número aleatorio con validaciones.
5. Ruleta 4 colores.
6. Ruleta personalizada (CRUD + persistencia).
7. Historial común.
8. Ajustes sonido/haptics.
9. Integración AdMob banner.
10. Analytics y QA.


