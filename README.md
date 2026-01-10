# 🏠 HousePal - Ứng dụng Quản lý Nhà trọ/Chung cư
Dự án phát triển ứng dụng mobile bằng Flutter, hỗ trợ quản lý công việc, chi tiêu và sinh hoạt chung trong ngôi nhà.
## 👥 Phân công & Cấu trúc Nhánh (Branch Strategy)
Dự án được chia thành các nhánh lớn theo thành viên (Base Branch). Từ mỗi nhánh thành viên, code được tách nhỏ thành các nhánh tính năng (Feature Branches) độc lập để dễ dàng quản lý và review code.

🗺️ Sơ đồ cây phân nhánh
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

1. 👤 Thành viên: Phương (Nhánh gốc: Phuong)
- feature/authentication: Login, Register, Firebase Auth.
- feature/expenses: Quản lý quỹ, chia tiền (Split bill).
- feature/house_setup: Onboarding, Tạo nhà mới.

2. 👤 Thành viên: Dũng (Nhánh gốc: Dung)
- feature/profile: Chỉnh sửa thông tin cá nhân, cài đặt.
- feature/bulletin_board: Bảng tin chung, ghim tin quan trọng.

3. 👤 Thành viên: Tuấn (Nhánh gốc: Tuan)
- feature/chores: Phân công việc nhà, bảng xếp hạng.
- feature/homes: Dashboard tổng quan.

🚀 Hướng dẫn chạy dự án (How to run)
Để kiểm tra từng tính năng riêng biệt, vui lòng checkout sang nhánh tương ứng:
- Chạy Authentication: git checkout feature/authentication
- Chạy Expenses: git checkout feature/expenses

- Chạy Chores: git checkout feature/chores
- Chạy Profile: git checkout feature/profile
Lưu ý: Sau khi chuyển nhánh, hãy chạy lệnh `flutter pub get` để cập nhật thư viện.

---
Developed by HousePal Team - 2025
'''