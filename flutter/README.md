# Tira Suerte Flutter

Aplicación Flutter offline para resolver decisiones al azar: cara o sello, número aleatorio, ruleta de cuatro colores y ruleta personalizada.

## Desarrollo

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

El historial de las últimas 50 jugadas se conserva localmente mediante `SharedPreferences` y puede limpiarse desde el icono de historial.

En desarrollo Android e iOS usan los IDs de prueba oficiales de AdMob. El banner es opcional: si no puede cargarse, la aplicación sigue funcionando.

## Configuración de release

Las credenciales no se guardan en Git.

1. Crea `android/key.properties` a partir de `android/key.properties.example` y registra un keystore de release.
2. Crea `android/release.properties` a partir de `android/release.properties.example` y define:

```properties
applicationId=com.tuorganizacion.decisor
adMobAppId=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
```

3. Copia `ios/Flutter/AdMob.xcconfig.example` como `ios/Flutter/AdMob.xcconfig` y coloca el mismo App ID de AdMob.
4. Configura el Bundle Identifier final y el perfil de firma en Xcode para Runner.

Android detiene las tareas release si falta identidad, App ID de AdMob o firma. Luego ejecuta:

```powershell
flutter build appbundle --release
flutter build ipa --release
```

## Validación manual

- Verifica el CTA en teléfonos de 5–7 pulgadas y tabletas: debe quedar siempre encima del banner.
- Activa TalkBack/VoiceOver y confirma que cada resultado se anuncia como “resultado: …”.
- Prueba modo avión: todas las jugadas deben funcionar aunque no se cargue publicidad.
- Prueba lector de pantalla, teclado y tamaños móvil/tablet; cada resultado debe anunciarse y el historial debe persistir tras reiniciar.

## UX y jugadas

- Durante una jugada se bloquean el selector de modo, el swipe entre modos y la edición de opciones.
- La ruleta personalizada permite pegar una opción por línea (máximo 12, 60 caracteres cada una), agregar ejemplos y deshacer la última eliminación mientras el editor permanece abierto.
- Las opciones se guardan en orden y cada jugada conserva una copia de su conjunto de opciones.
- Los juegos permiten desplazamiento con teclado abierto o texto ampliado; las ruletas incluyen leyenda accesible. El ajuste de movimiento reducido del dispositivo evita la animación.

## Firebase Analytics opcional

La app fija `firebase_core` en 4.2.1 y `firebase_analytics` en 12.0.4 para mantener compatibilidad con Kotlin 2.2.0 del proyecto. Las actualizaciones de Firebase deben validarse también compilando Android release.

La app incluye `firebase_core` y `firebase_analytics`, pero la colección queda desactivada por defecto hasta configurar un proyecto real. No se han incluido identificadores de Firebase de ejemplo ni de producción.

Para Android/iOS, configura la app en Firebase y ejecuta con `--dart-define=ANALYTICS_ENABLED=true`. Se admite la configuración nativa habitual o proporcionar las opciones explícitas:

```powershell
flutter run --dart-define=ANALYTICS_ENABLED=true --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=... --dart-define=FIREBASE_MESSAGING_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
```

En iOS puede proporcionarse también `FIREBASE_IOS_BUNDLE_ID`. Los datos pertenecen a la app registrada para la plataforma; no se deben reutilizar los App IDs entre Android e iOS. Si se usa configuración nativa Android, completa también la configuración de Google Services indicada por Firebase.

Eventos: `play_start`, `play_result`, `settings_changed`, `ad_impression_banner` desde la impresión real, y `ad_error`. Los booleanos se envían como 0/1. Un fallo o timeout de inicialización no bloquea el juego; Windows no inicializa Analytics. La web estática continúa sin Analytics.

La descarga de dependencias Android requiere que Java confíe en los certificados HTTPS de Google Maven y Maven Central. Un error `PKIX path building failed` impide validar el APK hasta corregir el almacén de confianza del entorno.
