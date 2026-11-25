# PrestaControl App (`prestacontrol_app`)

**Autor:** Julio Rodriguez  

Aplicación móvil Flutter (Material 3) para gestionar cartera de préstamos consumiendo la API REST `prestamoservice` con autenticación JWT y almacenamiento seguro (`flutter_secure_storage`).

## Requisitos
- Flutter SDK (canal stable)
- API `prestamoservice` ejecutándose (local o Render)

## Ejecución en emulador o celular
```powershell
flutter pub get
# Emulador Android (apunta al localhost de tu PC)
flutter run --dart-define=API_URL=http://10.0.2.2:8080

# Celular físico en la misma red WiFi
flutter run --dart-define=API_URL=http://<IP-DE-TU-PC>:8080

# Contra Render
flutter run --dart-define=API_URL=https://<tu-servicio>.onrender.com
```

## Pruebas estáticas y unitarias
```powershell
flutter analyze
flutter test
```

## Generar APK Release
```powershell
flutter build apk --release --dart-define=API_URL=https://<tu-servicio>.onrender.com
```
El APK queda en `build/app/outputs/flutter-apk/app-release.apk`.
