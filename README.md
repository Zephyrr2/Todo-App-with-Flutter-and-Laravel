📝 Todo App with Flutter & Laravel
---

## 📋 Deskripsi Aplikasi
Aplikasi Todo List ini merupakan aplikasi full-stack yang dibangun menggunakan Flutter di sisi frontend dan Laravel untuk backend API. Aplikasi ini memungkinkan pengguna untuk:

- Menambahkan tugas
- Menghapus tugas
- Menandai tugas sebagai selesai
- Menyimpan data melalui API RESTful

## 📱 Halaman-Halaman Aplikasi
- Halaman Utama: Menampilkan daftar semua tugas
- Halaman Tambah: Formulir untuk menambahkan tugas

## 🗄️ Database yang Digunakan
- MySQL 

## 🔗 API (Laravel)
- GET /api/tasks – Ambil semua tugas
- POST /api/tasks – Tambah tugas
- GET /api/tasks/{id} – Ambil tugas berdasarkan ID
- PUT /api/tasks/{id} – Perbarui tugas
- DELETE /api/tasks/{id} – Hapus tugas

## 🛠️ Software yang Digunakan
- Flutter (Frontend)
- Laravel (Backend)
- MySQL (Database)

## 🧰 Cara Instalasi
### ⚙️ Backend (Laravel)
1. Masuk ke folder backend:
   ```bash
   cd todoapp

2. Salin .env.example menjadi .env dan atur konfigurasi database.

3. Install dependensi:
   ```bash
   composer install

3. Jalankan migrasi:
   ```bash
   php artisan migrate

4. Jalankan server:
   ```bash
   php artisan serve

5. API tersedia di: http://127.0.0.1:8000/api

## 📱 Frontend (Flutter)
1. Masuk ke folder frontend:
   ```bash
   cd todo_app

2. Install dependensi:
   ```bash
   flutter pub get

3. Jalankan aplikasi:
   ```bash
   flutter run

## ▶️ Cara Menjalankan
- Pastikan backend Laravel aktif di http://127.0.0.1:8000
- Jalankan Flutter app di emulator atau perangkat fisik
- Aplikasi akan menampilkan dan memanipulasi data dari backend secara realtime

## 🎥 Demo
https://github.com/user-attachments/assets/cfcb8fbc-7131-4c9c-a30b-2a841f4ce0ac

## 👤 Identitas Pembuat
# Gilang Arga Pradana
