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

