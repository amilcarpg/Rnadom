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
