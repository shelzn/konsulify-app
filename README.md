# Konsulify Mobile App

Aplikasi mobile Flutter untuk layanan konsultasi online Konsulify.

## Stack

- Flutter + Dart
- Material 3
- Riverpod
- GoRouter
- Dio
- flutter_secure_storage
- image_picker

## Menjalankan Aplikasi

Install dependency:

```bash
flutter pub get
```

Jalankan di emulator Android:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Jalankan di device fisik dengan IP komputer:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api/v1
```

## Struktur

```text
lib/
  app/
  core/
    api/
    storage/
    widgets/
  features/
    auth/
    home/
    category/
    consultant/
    booking/
    profile/
    admin/
```

## Status Implementasi

- Theme dan Material 3
- Route guard Guest/User/Admin
- Bottom navigation User
- Login, Register, Forgot Password page
- Home katalog
- Daftar dan detail konsultan
- Booking history dan form create booking tersambung ke API
- Profile page
- Admin dashboard dan menu master data awal
- Dio client dengan JWT interceptor
- Secure storage untuk token
