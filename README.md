# Tira Suerte

Monorepo de un decisor aleatorio offline con dos clientes independientes:

- [flutter/](flutter/README.md): Android, iOS y Windows con AdMob opcional.
- [web/](web/README.md): navegador moderno, sin dependencias ni backend.

## Inicio rápido

```powershell
Set-Location flutter
flutter pub get
flutter run
```

La web se sirve como archivos estáticos desde `web/`. Los artefactos Flutter se generan bajo `flutter/build/`.

## Capacidades comunes

Cara o sello, número aleatorio, ruleta de cuatro colores, ruleta personalizada, sonido/vibración opcional e historial local de las últimas 50 jugadas. No hay cuentas, backend ni sincronización entre dispositivos.

## Validación manual

- Prueba teclado y lector de pantalla: el resultado debe anunciarse y no depender solo de color.
- Prueba móvil, tablet y modo avión.
- Borra o altera el almacenamiento local: ambas apps deben iniciar con valores seguros.
