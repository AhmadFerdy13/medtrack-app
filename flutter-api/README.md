# MedTrack — Backend API

## Deskripsi Aplikasi

MedTrack adalah aplikasi pemantauan jadwal minum obat dan riwayat kesehatan pribadi. Backend ini menyediakan RESTful API yang dibangun menggunakan Laravel dengan autentikasi JWT untuk mengelola data obat dan jadwal minum obat secara aman.

## Fitur Utama

- **Autentikasi JWT**: Register, Login, Logout, Get Profile, Refresh Token
- **CRUD Medicine**: Kelola data obat pribadi pengguna
- **CRUD Medication Schedule**: Kelola jadwal minum obat dengan relasi ke data obat
- **Data Isolasi**: Setiap user hanya dapat mengakses data miliknya sendiri
- **Validasi Request**: Validasi input pada setiap proses tambah dan ubah data

## Teknologi yang Digunakan

- **Framework**: Laravel 13.x
- **Autentikasi**: JWT (tymon/jwt-auth)
- **Database**: MariaDB / MySQL
- **PHP**: >= 8.3

## Struktur Database

### Tabel `users`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | bigint | Primary Key |
| name | string | Nama pengguna |
| email | string | Email (unique) |
| password | string | Password (hashed) |
| created_at | timestamp | Waktu dibuat |
| updated_at | timestamp | Waktu diperbarui |

### Tabel `medicines`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | bigint | Primary Key |
| user_id | bigint | FK → users |
| name | string | Nama obat |
| type | string | Jenis: tablet, capsule, syrup, injection, ointment |
| dosage | string | Dosis obat |
| unit | string | Satuan (mg, ml, dll) |
| usage_instruction | text | Instruksi penggunaan (nullable) |
| notes | text | Catatan tambahan (nullable) |
| created_at | timestamp | Waktu dibuat |
| updated_at | timestamp | Waktu diperbarui |

### Tabel `medication_schedules`
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | bigint | Primary Key |
| user_id | bigint | FK → users |
| medicine_id | bigint | FK → medicines |
| start_date | date | Tanggal mulai |
| end_date | date | Tanggal selesai (nullable) |
| time | string | Waktu minum obat (misal "08:00") |
| frequency | string | once_daily, twice_daily, three_times_daily, as_needed |
| status | string | active, completed, skipped |
| notes | text | Catatan (nullable) |
| created_at | timestamp | Waktu dibuat |
| updated_at | timestamp | Waktu diperbarui |

## Relasi Data

- **User** → hasMany → **Medicine**
- **User** → hasMany → **MedicationSchedule**
- **Medicine** → hasMany → **MedicationSchedule**
- **Medicine** → belongsTo → **User**
- **MedicationSchedule** → belongsTo → **User**
- **MedicationSchedule** → belongsTo → **Medicine**

## Endpoint API

### Autentikasi
| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| POST | `/api/auth/register` | Registrasi user baru | ❌ |
| POST | `/api/auth/login` | Login dan dapatkan token | ❌ |
| POST | `/api/auth/logout` | Logout dan invalidasi token | ✅ |
| GET | `/api/auth/me` | Ambil profil user login | ✅ |
| GET | `/api/auth/refresh` | Refresh token JWT | ✅ |

### Medicine
| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| GET | `/api/medicines` | Daftar semua obat user | ✅ |
| POST | `/api/medicines` | Tambah obat baru | ✅ |
| GET | `/api/medicines/{id}` | Detail obat | ✅ |
| PUT | `/api/medicines/{id}` | Update obat | ✅ |
| DELETE | `/api/medicines/{id}` | Hapus obat | ✅ |

### Medication Schedule
| Method | Endpoint | Deskripsi | Auth |
|--------|----------|-----------|------|
| GET | `/api/medication-schedules` | Daftar semua jadwal user | ✅ |
| POST | `/api/medication-schedules` | Tambah jadwal baru | ✅ |
| GET | `/api/medication-schedules/{id}` | Detail jadwal | ✅ |
| PUT | `/api/medication-schedules/{id}` | Update jadwal | ✅ |
| DELETE | `/api/medication-schedules/{id}` | Hapus jadwal | ✅ |

## Cara Menjalankan Backend

1. Clone repository
2. Install dependencies:
   ```bash
   composer install
   ```
3. Copy file environment:
   ```bash
   cp .env.example .env
   ```
4. Konfigurasi `.env` (database, JWT_SECRET):
   ```env
   DB_CONNECTION=mariadb
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=db_flutter_api
   DB_USERNAME=root
   DB_PASSWORD=root
   ```
5. Generate application key:
   ```bash
   php artisan key:generate
   ```
6. Generate JWT secret:
   ```bash
   php artisan jwt:secret
   ```
7. Jalankan migration:
   ```bash
   php artisan migrate:fresh
   ```
8. Jalankan server:
   ```bash
   php artisan serve
   ```

## Akun Pengujian

Buat akun melalui endpoint register:
```json
{
    "name": "Ahmad Test",
    "email": "ahmad@test.com",
    "password": "password123",
    "password_confirmation": "password123"
}
```

## Penjelasan JWT

JWT (JSON Web Token) digunakan untuk autentikasi stateless pada API. Alur kerja:

1. **Register**: User mendaftarkan akun dengan name, email, dan password. Password di-hash otomatis.
2. **Login**: User mengirim email dan password. Jika valid, server mengembalikan token JWT.
3. **Akses Resource**: Token JWT dikirim pada header `Authorization: Bearer <token>` di setiap request ke endpoint yang dilindungi.
4. **Refresh Token**: Token yang mendekati kedaluwarsa dapat di-refresh untuk mendapatkan token baru tanpa login ulang.
5. **Logout**: Token diinvalidasi sehingga tidak dapat digunakan lagi.

Package yang digunakan: `tymon/jwt-auth` dengan guard `api` pada konfigurasi auth Laravel.

## Format Response

Semua endpoint menggunakan format response JSON yang konsisten:

### Sukses
```json
{
    "success": true,
    "message": "Pesan berhasil",
    "data": {}
}
```

### Error
```json
{
    "success": false,
    "message": "Pesan error",
    "data": null
}
```
