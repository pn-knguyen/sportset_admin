# 🏟️ SportSet Admin

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-Academic-4CAF50?style=for-the-badge)](LICENSE)

**Ứng dụng quản trị toàn diện cho hệ thống đặt sân thể thao SportSet.**
Quản lý cơ sở · Đặt sân · Nhân viên · Doanh thu — tất cả trong một nền tảng duy nhất.

![Android](https://img.shields.io/badge/Android-✅-3DDC84?style=flat-square&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-✅-000000?style=flat-square&logo=apple&logoColor=white)
![Web](https://img.shields.io/badge/Web-✅-4285F4?style=flat-square&logo=googlechrome&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✅-0078D4?style=flat-square&logo=windows&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✅-000000?style=flat-square&logo=macos&logoColor=white)

---

## 📖 Giới thiệu

**SportSet Admin** là ứng dụng quản trị backend dành cho chủ sân và quản lý cơ sở thể thao trong hệ sinh thái SportSet. Được xây dựng bằng Flutter và Firebase, ứng dụng cho phép vận hành toàn bộ hoạt động kinh doanh — từ quản lý sân, nhân viên, đến theo dõi doanh thu realtime — trên mọi nền tảng.

```text
SportSet App  ──[khách hàng đặt sân]──▶  Firestore  ◀──[admin quản lý]──  SportSet Admin
```

---

## ✨ Tính năng nổi bật

### 📊 Dashboard — Tổng quan hoạt động realtime

- Doanh thu hôm nay và so sánh với hôm qua
- Số lượng đơn đặt sân trong ngày
- Luồng hoạt động gần đây cập nhật realtime từ Firestore

### 🏢 Quản lý cơ sở (Facility)

- Thêm / sửa / xóa cơ sở thể thao
- Upload hình ảnh đại diện cho cơ sở
- Chọn vị trí trực tiếp trên **Google Maps** và lưu tọa độ GPS
- Cấu hình giờ hoạt động, tiện ích đi kèm

### 🏸 Quản lý sân (Court)

- Bảng giá linh hoạt: ngày thường / cuối tuần
- Hỗ trợ **sân con** (nhiều đơn vị trên cùng một sân lớn)
- Phân loại theo môn thể thao
- Theo dõi trạng thái: còn trống · đã đặt · đóng cửa

### 🎟️ Voucher & Khuyến mãi

- Mã giảm giá theo **%** hoặc **số tiền cố định**
- Cấu hình thời hạn, số lượng, giá trị đơn tối thiểu
- Giới hạn số lần sử dụng mỗi khách hàng
- Theo dõi số lượt đã dùng / tổng số phát hành

### 👥 Quản lý nhân viên (Staff)

- Tạo tài khoản liên kết trực tiếp với cơ sở
- 5 vị trí: Admin · Manager · Staff · Coach · Receptionist
- Gán nhóm quyền và ảnh đại diện
- Theo dõi trạng thái: hoạt động · nghỉ · tạm khóa

### 🔐 Phân quyền & Bảo mật (RBAC)

- Nhóm quyền (Permission Groups) theo chức năng
- Kiểm soát truy cập dựa trên vai trò **(Role-Based Access Control)**
- Tài khoản admin mặc định tự động khởi tạo khi chạy lần đầu

### 📋 Quản lý đặt sân (Booking)

- Danh sách toàn bộ đơn booking
- Chi tiết: khách hàng · sân · thời gian · giá · trạng thái

### 👤 Khách hàng & Đánh giá

- Hồ sơ và lịch sử đặt sân của từng khách hàng
- Xem và quản lý đánh giá / nhận xét từ khách hàng

### 💰 Báo cáo doanh thu

- Thống kê doanh thu theo ngày
- So sánh xu hướng và phân tích số lượng đơn hàng

---

## 🛠️ Tech Stack

| Layer | Công nghệ | Mục đích |
|---|---|---|
| UI Framework | Flutter 3.10.3+ | Cross-platform UI |
| Language | Dart 3.0+ | Business logic |
| Database | Cloud Firestore | Realtime NoSQL database |
| Auth | Firebase Auth | Xác thực người dùng |
| Storage | Firebase Storage | Lưu trữ hình ảnh |
| Maps | Google Maps Flutter | Chọn vị trí cơ sở |
| Location | Geolocator + Geocoding | GPS & địa chỉ |
| Media | Image Picker | Chọn ảnh từ thiết bị |

---

## 🚀 Cài đặt & Chạy

### Yêu cầu

- Flutter SDK `>= 3.10.3`
- Dart SDK `>= 3.0.0`
- Firebase project (Firestore + Auth + Storage)
- Google Maps API Key

### Bắt đầu nhanh

```bash
# 1. Clone repository
git clone <repository-url>
cd sportset_admin

# 2. Cài đặt dependencies
flutter pub get

# 3. Cấu hình Firebase
#    → Tạo project tại console.firebase.google.com
#    → Chạy lệnh sau và làm theo hướng dẫn:
flutterfire configure
#    → File firebase_options.dart sẽ được tạo tự động

# 4. Thêm Google Maps API Key
#    Android → android/app/src/main/AndroidManifest.xml
#    iOS     → ios/Runner/AppDelegate.swift

# 5. Khởi chạy
flutter run
```

### Build production

```bash
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle
flutter build ios --release          # iOS
flutter build web --release          # Web
flutter build windows --release      # Windows
```

---

## 📁 Cấu trúc thư mục

```text
lib/
├── main.dart                        # Entry point & khởi tạo Firebase
├── firebase_options.dart            # Cấu hình Firebase (auto-generated)
│
├── models/                          # Data models
│   ├── facility.dart                # Cơ sở thể thao
│   ├── court.dart                   # Sân (bảng giá, sân con)
│   ├── sport.dart                   # Loại môn thể thao
│   ├── voucher.dart                 # Mã khuyến mãi
│   ├── staff.dart                   # Nhân viên
│   ├── customer.dart                # Khách hàng
│   ├── permission.dart              # Nhóm quyền
│   └── review.dart                  # Đánh giá
│
├── services/                        # Business logic & Firebase queries
│   ├── facility_service.dart
│   ├── court_service.dart
│   ├── voucher_service.dart
│   ├── staff_service.dart
│   ├── permission_service.dart
│   ├── access_control_service.dart  # RBAC
│   └── setup_service.dart           # Khởi tạo dữ liệu mặc định
│
├── screens/
│   ├── auth/                        # Đăng nhập
│   ├── home/                        # Dashboard
│   ├── booking/                     # Quản lý đặt sân
│   ├── account/                     # Tài khoản cá nhân
│   └── management/                  # Trung tâm quản lý
│       ├── facility/  court/  sport/
│       ├── voucher/   staff/  permission/
│       ├── customer/  review/ revenue/
│       └── account/
│
├── widgets/                         # Shared UI components
└── routes/                          # Định nghĩa routes
```

---

## 🗄️ Firestore Schema

```text
firestore/
├── facilities   ← Cơ sở thể thao (tên, địa chỉ, GPS, ảnh, giờ mở cửa)
├── courts       ← Sân tập (giá, loại sân, môn thể thao, trạng thái)
├── sports       ← Loại môn thể thao
├── vouchers     ← Mã khuyến mãi (loại, giá trị, hạn dùng, số lượt)
├── staff        ← Nhân viên (vị trí, cơ sở, nhóm quyền)
├── permissions  ← Nhóm quyền truy cập
├── bookings     ← Đơn đặt sân (khách hàng, sân, thời gian, giá)
├── customers    ← Khách hàng
├── reviews      ← Đánh giá từ khách hàng
└── accounts     ← Tài khoản admin / staff
```

---

## 🌐 Hệ sinh thái SportSet

SportSet Admin là một phần trong hệ thống hai ứng dụng dùng chung Firebase:

| Ứng dụng | Đối tượng | Chức năng chính |
|---|---|---|
| SportSet App | Khách hàng | Tìm sân · Đặt sân · Thanh toán · Đánh giá |
| SportSet Admin | Quản trị viên | Quản lý cơ sở · Nhân viên · Doanh thu |

---

## 📄 Giấy phép

Dự án được xây dựng phục vụ mục đích **học tập và nghiên cứu**.

---

Made with ❤️ using Flutter & Firebase
