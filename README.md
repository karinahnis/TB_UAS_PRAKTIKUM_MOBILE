# 🎟️ Educational Ticketing App — Flutter

Aplikasi mobile ticketing untuk pembelian tiket event, dibuat dengan Flutter sebagai Tugas Besar Praktikum Pemrograman Mobile.

---

## 👥 Pembagian Tugas Tim

| Anggota | Bagian | File Panduan |
|---------|--------|--------------|
| **Karina** | Setup Project + Auth + Profile | [`GUIDE_KARINA.md`](./GUIDE_KARINA.md) |
| **Tabina** | Catalogue (Categories & Events) | [`GUIDE_TABINA.md`](./GUIDE_TABINA.md) |
| **Anyelir** | Orders + Payments + Tickets | [`GUIDE_ANYELIR.md`](./GUIDE_ANYELIR.md) |

---

## 🔗 Base URL API

```
http://35.255.129.123:8080
```

---

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| Flutter | Framework UI |
| Dart | Bahasa pemrograman |
| Provider | State management |
| Dio | HTTP client |
| SharedPreferences | Simpan JWT token lokal |
| qr_flutter | Generate QR code untuk tiket |
| intl | Format tanggal & mata uang |

---

## 📁 Struktur Folder Project

```
lib/
├── main.dart
├── core/
│   ├── constants.dart          # BASE_URL, dll
│   ├── api_client.dart         # Dio instance + interceptor token
│   └── exceptions.dart         # Custom exception classes
├── models/
│   ├── user.dart
│   ├── category.dart
│   ├── event.dart
│   ├── order.dart
│   ├── payment.dart
│   └── ticket.dart
├── services/
│   ├── auth_service.dart
│   ├── catalogue_service.dart
│   ├── order_service.dart
│   ├── payment_service.dart
│   └── ticket_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── catalogue_provider.dart
│   ├── order_provider.dart
│   └── ticket_provider.dart
├── pages/
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── home/
│   │   └── home_page.dart
│   ├── catalogue/
│   │   ├── event_list_page.dart
│   │   └── event_detail_page.dart
│   ├── order/
│   │   ├── order_list_page.dart
│   │   ├── order_detail_page.dart
│   │   └── checkout_page.dart
│   ├── payment/
│   │   └── payment_page.dart
│   ├── ticket/
│   │   ├── ticket_list_page.dart
│   │   └── ticket_detail_page.dart
│   └── profile/
│       └── profile_page.dart
└── widgets/
    ├── event_card.dart
    ├── order_card.dart
    ├── ticket_card.dart
    └── loading_indicator.dart
```

---

## 📦 pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  dio: ^5.4.3
  shared_preferences: ^2.2.3
  qr_flutter: ^4.1.0
  intl: ^0.19.0
  cached_network_image: ^3.3.1
```

---

## 🔄 Alur Kerja Tim (Git)

```
main
 ├── feature/karina-auth-profile     ← Karina push di sini
 ├── feature/tabina-catalogue        ← Tabina push di sini
 └── feature/anyelir-orders-tickets  ← Anyelir push di sini
```

### Urutan Merge ke Main:
1. Karina selesai → PR ke `main` → merge
2. Tabina pull dari `main` (dapat fondasi Karina) → kerjakan → PR → merge
3. Anyelir pull dari `main` (dapat fondasi Karina + Tabina) → kerjakan → PR → merge

---

## 📌 Catatan Penting

- **JWT Token** disimpan di `SharedPreferences` dengan key `"access_token"`
- Semua request yang butuh auth harus menyertakan header: `Authorization: Bearer <token>`
- Interceptor Dio di `api_client.dart` akan otomatis menyisipkan token ke setiap request
- Jika response `401`, arahkan user ke halaman Login
- Format harga menggunakan `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')`
