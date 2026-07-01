# MedTrack — Frontend Flutter

## Deskripsi Aplikasi

MedTrack adalah aplikasi mobile pemantauan jadwal minum obat dan riwayat kesehatan pribadi. Dibangun menggunakan Flutter dengan state management flutter_bloc, terintegrasi dengan backend Laravel RESTful API.

## Fitur Utama

- **Autentikasi**: Register, Login, Logout dengan JWT
- **Dashboard**: Ringkasan statistik obat dan jadwal
- **Manajemen Obat**: CRUD data obat pribadi
- **Manajemen Jadwal**: CRUD jadwal minum obat
- **Profil Pengguna**: Lihat informasi akun
- **Penyimpanan Token Aman**: Menggunakan flutter_secure_storage

## Teknologi yang Digunakan

- **Framework**: Flutter
- **State Management**: flutter_bloc
- **HTTP Client**: http
- **Penyimpanan Token**: flutter_secure_storage
- **Equality**: equatable
- **Internasionalisasi**: intl

## Struktur Project

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart        # URL endpoint API
│   ├── network/
│   │   └── api_service.dart          # HTTP client wrapper + JWT
│   └── storage/
│       └── secure_storage.dart       # Penyimpanan token JWT
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/user_model.dart
│   │   │   └── repositories/auth_repository.dart
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   └── presentation/
│   │       ├── splash_screen.dart
│   │       ├── login_page.dart
│   │       ├── register_page.dart
│   │       └── profile_page.dart
│   ├── medicine/
│   │   ├── data/
│   │   │   ├── models/medicine_model.dart
│   │   │   └── repositories/medicine_repository.dart
│   │   ├── bloc/
│   │   │   ├── medicine_bloc.dart
│   │   │   ├── medicine_event.dart
│   │   │   └── medicine_state.dart
│   │   └── presentation/
│   │       └── medicine_form_page.dart
│   ├── schedule/
│   │   ├── data/
│   │   │   ├── models/schedule_model.dart
│   │   │   └── repositories/schedule_repository.dart
│   │   ├── bloc/
│   │   │   ├── schedule_bloc.dart
│   │   │   ├── schedule_event.dart
│   │   │   └── schedule_state.dart
│   │   └── presentation/
│   │       ├── schedule_detail_page.dart
│   │       └── schedule_form_page.dart
│   └── dashboard/
│       └── presentation/
│           └── dashboard_page.dart
└── main.dart
```

## Cara Menjalankan Frontend

1. Pastikan Flutter SDK sudah terinstal
2. Clone repository
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Sesuaikan base URL API di `lib/core/constants/api_constants.dart`:
   ```dart
   // Untuk emulator Android (Android Studio):
   static const String baseUrl = 'http://10.0.2.2:8000/api';
   
   // Untuk BlueStacks:
   static const String baseUrl = 'http://10.0.2.2:8000/api';
   
   // Untuk device fisik (ganti dengan IP LAN):
   static const String baseUrl = 'http://192.168.x.x:8000/api';
   ```
5. Pastikan backend Laravel sudah berjalan:
   ```bash
   php artisan serve
   ```
6. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Halaman Aplikasi

| No | Halaman | Deskripsi |
|----|---------|-----------|
| 1 | Splash Screen | Cek token JWT, redirect otomatis |
| 2 | Login Page | Form login dengan email & password |
| 3 | Register Page | Form registrasi akun baru |
| 4 | Dashboard Page | Ringkasan statistik + aksi cepat |
| 5 | Medicine List | Daftar obat dengan aksi edit/hapus |
| 6 | Medicine Form | Form tambah/edit obat |
| 7 | Schedule List | Daftar jadwal dengan indikator status |
| 8 | Schedule Detail | Detail jadwal + info obat |
| 9 | Schedule Form | Form tambah/edit jadwal |
| 10 | Profile Page | Info user + tombol logout |

## Penjelasan flutter_bloc

Aplikasi ini menggunakan pattern BLoC (Business Logic Component) untuk memisahkan logika bisnis dari tampilan UI.

### Arsitektur BLoC

1. **Event**: Input/aksi dari user (contoh: `AuthLoginRequested`, `MedicineCreate`)
2. **State**: Kondisi UI saat ini (contoh: `AuthLoading`, `MedicineLoaded`)
3. **BLoC**: Menerima Event, menjalankan logika bisnis, dan mengeluarkan State baru

### Alur Kerja

```
User Tap → Event dikirim ke BLoC → BLoC memanggil Repository → 
Repository memanggil API → Data dikembalikan → BLoC emit State baru → 
UI rebuild sesuai State
```

### BLoC yang Digunakan

- **AuthBloc**: Mengelola autentikasi (login, register, logout, cek status)
- **MedicineBloc**: Mengelola CRUD data obat
- **ScheduleBloc**: Mengelola CRUD jadwal minum obat

### Widget BLoC

- `BlocProvider`: Menyediakan instance BLoC ke widget tree
- `MultiBlocProvider`: Menyediakan beberapa BLoC sekaligus
- `BlocBuilder`: Rebuild UI saat state berubah
- `BlocListener`: Menjalankan side effect (navigasi, snackbar) saat state berubah
- `BlocConsumer`: Kombinasi BlocBuilder + BlocListener

## Akun Pengujian

Buat akun melalui halaman Register di aplikasi, atau gunakan endpoint API:
```json
{
    "name": "Ahmad Test",
    "email": "ahmad@test.com",
    "password": "password123",
    "password_confirmation": "password123"
}
```
