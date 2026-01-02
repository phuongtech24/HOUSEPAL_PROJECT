# 🏠 HousePal - Ứng dụng Quản lý Nhà trọ/Chung cư

Dự án phát triển ứng dụng mobile bằng Flutter, hỗ trợ quản lý công việc, chi tiêu và sinh hoạt chung trong ngôi nhà.

## 👥 Phân công & Cấu trúc Nhánh (Branch Strategy)

Dự án được chia thành các nhánh lớn theo thành viên (Base Branch). Từ mỗi nhánh thành viên, code được tách nhỏ thành các nhánh tính năng (Feature Branches) độc lập để dễ dàng quản lý và review code.

### 🗺️ Sơ đồ cây phân nhánh

```text
main (Nhánh gốc tổng hợp)
│
├── 👤 Nhánh: Phuong (Base của Phương)
│   ├── 🌿 feature/authentication  (Đăng nhập, Đăng ký)
│   ├── 🌿 feature/expenses        (Quản lý chi tiêu, quỹ chung)
│   └── 🌿 feature/house_setup     (Tạo nhà, mời thành viên)
│
├── 👤 Nhánh: Dung (Base của Dũng)
│   ├── 🌿 feature/profile         (Hồ sơ cá nhân, chỉnh sửa thông tin)
│   └── 🌿 feature/bulletin_board  (Bảng tin, thông báo chung)
│
└── 👤 Nhánh: Tuan (Base của Tuấn)
    ├── 🌿 feature/chores          (Phân công việc nhà)
    └── 🌿 feature/homes           (Màn hình trang chủ/Dashboard)
└── 👤 Nhánh: dev (nhánh phát triển)

📋 Chi tiết Phân công nhiệm vụ
Dưới đây là danh sách các nhánh tính năng được phát triển bởi từng thành viên:

1. 👤 Thành viên: Phương (Nhánh gốc: Phuong)
feature/authentication:

Xây dựng màn hình Đăng nhập (Login), Đăng ký (Register).

Xử lý logic xác thực với Firebase Auth.

feature/expenses:

Quản lý quỹ chung, thêm khoản chi tiêu mới.

Tính năng chia tiền (Split bill) và tối ưu hóa nợ.

feature/house_setup:

Luồng Onboarding cho người dùng mới.

Chức năng Tạo nhà mới hoặc Tham gia vào nhà có sẵn.

2. 👤 Thành viên: Dũng (Nhánh gốc: Dung)
feature/profile:

Hiển thị và chỉnh sửa thông tin cá nhân.

Quản lý cài đặt tài khoản, đăng xuất.

feature/bulletin_board:

Bảng tin chung của nhà.

Tạo thông báo, ghim tin quan trọng cho các thành viên.

3. 👤 Thành viên: Tuấn (Nhánh gốc: Tuan)
feature/chores:

Danh sách việc nhà cần làm.

Gán việc cho thành viên, bảng xếp hạng chăm chỉ.

feature/homes:

Màn hình Trang chủ (Dashboard) tổng quan.

Hiển thị tóm tắt trạng thái của ngôi nhà sau khi đăng nhập.

🚀 Hướng dẫn chạy dự án (How to run)
Để kiểm tra từng tính năng riêng biệt, vui lòng checkout sang nhánh tương ứng:

Chạy Authentication: git checkout feature/authentication

Chạy Expenses: git checkout feature/expenses

Chạy Chores: git checkout feature/chores

Chạy Profile: git checkout feature/profile

Lưu ý: Sau khi chuyển nhánh, hãy chạy lệnh flutter pub get để cập nhật thư viện trước khi bấm Run.

Developed by HousePal Team - 2025


