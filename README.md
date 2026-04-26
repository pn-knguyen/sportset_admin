# SportSet Admin

Ứng dụng quản lý dành cho hệ thống đặt sân thể thao **SportSet**, xây dựng bằng Flutter và Firebase. Cung cấp đầy đủ các công cụ để quản lý cơ sở, sân tập, nhân viên, voucher, đơn đặt sân, khách hàng và doanh thu.

---

## Tính năng chính

### Dashboard

- Doanh thu trong ngày và so sánh với hôm qua
- Số lượng đơn đặt sân hôm nay
- Luồng hoạt động gần đây (realtime từ Firestore)

### Quản lý cơ sở (Facility)

- Thêm / sửa / xóa cơ sở thể thao
- Upload hình ảnh cơ sở
- Chọn vị trí trên Google Maps và lưu tọa độ GPS
- Quản lý giờ hoạt động và tiện ích

### Quản lý sân (Court)

- Tạo sân với nhiều mức giá (ngày thường / cuối tuần)
- Hỗ trợ sân con (nhiều đơn vị trên cùng một sân)
- Phân loại theo môn thể thao
- Quản lý trạng thái sân (còn trống / đã đặt / đóng cửa)

### Quản lý môn thể thao (Sport)

- Thêm / sửa loại môn thể thao (cầu lông, tennis, bóng đá, …)
- Gán icon đại diện cho từng môn

### Quản lý Voucher / Khuyến mãi

- Tạo mã giảm giá theo % hoặc số tiền cố định
- Cấu hình ngày hết hạn, giới hạn số lượng, giá trị đơn tối thiểu
- Giới hạn sử dụng mỗi khách hàng
- Theo dõi số lượng đã dùng / tổng số

### Quản lý nhân viên (Staff)

- Tạo tài khoản nhân viên liên kết với cơ sở
- Các vị trí: Admin, Manager, Staff, Coach, Receptionist
- Gán nhóm quyền, ảnh đại diện
- Theo dõi trạng thái hoạt động

### Quản lý quyền & tài khoản

- Nhóm quyền (Permission Groups) theo chức năng
- Kiểm soát truy cập theo vai trò (RBAC)
- Tài khoản admin mặc định được tạo tự động khi khởi chạy lần đầu

### Quản lý khách hàng & đánh giá

- Danh sách khách hàng và lịch sử đặt sân
- Xem và quản lý đánh giá / nhận xét từ khách hàng

### Quản lý đặt sân (Booking)

- Danh sách toàn bộ đơn đặt sân
- Chi tiết: khách hàng, sân, thời gian, trạng thái, giá

### Báo cáo doanh thu

- Thống kê doanh thu theo ngày
- Số lượng đơn và biểu đồ phân tích

---

## Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter 3.10.3+ |
| Ngôn ngữ | Dart |
| Database | Cloud Firestore |
| Xác thực | Firebase Auth |
| Lưu trữ file | Firebase Storage |
| Bản đồ | Google Maps Flutter |
| Định vị | Geolocator + Geocoding |
| Upload ảnh | Image Picker |

---

## Cài đặt & Chạy

### Yêu cầu

- Flutter SDK `>= 3.10.3`
- Dart SDK `>= 3.0.0`
- Firebase project đã được cấu hình (Firestore, Auth, Storage)
- Google Maps API Key

### Các bước

```bash
# 1. Clone repository
git clone <repository-url>
cd sportset_admin

# 2. Cài đặt dependencies
flutter pub get

# 3. Cấu hình Firebase
# - Tạo project trên Firebase Console
# - Chạy: flutterfire configure
# - File firebase_options.dart sẽ được tạo tự động

# 4. Cấu hình Google Maps API Key
# Android: android/app/src/main/AndroidManifest.xml
# iOS: ios/Runner/AppDelegate.swift

# 5. Chạy ứng dụng
flutter run
```

### Build production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## Cấu trúc thư mục

```
lib/
├── main.dart                   # Entry point
├── firebase_options.dart       # Firebase config (auto-generated)
├── models/                     # Data models
│   ├── facility.dart
│   ├── court.dart
│   ├── sport.dart
│   ├── voucher.dart
│   ├── staff.dart
│   ├── customer.dart
│   ├── permission.dart
│   └── review.dart
├── services/                   # Firebase & business logic
│   ├── facility_service.dart
│   ├── court_service.dart
│   ├── voucher_service.dart
│   ├── staff_service.dart
│   ├── permission_service.dart
│   ├── access_control_service.dart
│   └── ...
├── screens/                    # UI Screens
│   ├── auth/                   # Đăng nhập
│   ├── home/                   # Dashboard
│   ├── booking/                # Quản lý đặt sân
│   ├── account/                # Tài khoản
│   └── management/             # Hub quản lý
│       ├── facility/
│       ├── court/
│       ├── sport/
│       ├── voucher/
│       ├── staff/
│       ├── permission/
│       ├── customer/
│       ├── review/
│       └── revenue/
├── widgets/                    # Shared widgets
└── routes/                     # App routes
```

---

## Firestore Collections

| Collection | Mô tả |
|---|---|
| `facilities` | Cơ sở thể thao |
| `courts` | Sân tập |
| `sports` | Loại môn thể thao |
| `vouchers` | Mã khuyến mãi |
| `staff` | Nhân viên |
| `permissions` | Nhóm quyền |
| `bookings` | Đơn đặt sân |
| `customers` | Khách hàng |
| `reviews` | Đánh giá |
| `accounts` | Tài khoản admin |

---

## Platforms

| Platform | Hỗ trợ |
|---|---|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |

---

## Ứng dụng liên quan

Dự án này là **Admin Panel**. Hệ thống SportSet bao gồm:

- **SportSet App** — Ứng dụng dành cho khách hàng (đặt sân, thanh toán, đánh giá)
- **SportSet Admin** — Ứng dụng này, dành cho quản trị viên và nhân viên

---

## Giấy phép

Dự án phục vụ mục đích học tập và nghiên cứu.
