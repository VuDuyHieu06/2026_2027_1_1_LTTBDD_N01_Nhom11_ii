# 🍳 Smart Recipe & Cooking Step-by-Step

**Ứng dụng Sổ tay Công thức Nấu ăn Cá nhân** – Bài tập lớn môn *Lập trình thiết bị di động* (Flutter / Dart).

- **Mã học phần / nhóm:** 2026_2027_1_1_LTTBDD_N01_Nhom11_ii
- **Repository:** https://github.com/VuDuyHieu06/2026_2027_1_1_LTTBDD_N01_Nhom11_ii

## 📖 Giới thiệu

Smart Recipe & Cooking Step-by-Step là sổ tay điện tử cung cấp thông tin công thức và hướng dẫn nấu ăn chi tiết từng bước, dành cho người học nấu ăn, sinh viên và người nội trợ. Ứng dụng tập trung vào tra cứu và hướng dẫn; **không** có tính năng thương mại điện tử (bán hàng, đặt hàng, thanh toán) và **không** quản lý chi tiêu.

## ✨ Tính năng chính

| Nhóm | Tính năng |
|---|---|
| Tài khoản | Đăng ký, đăng nhập, đăng xuất; phân quyền **Admin** / **User** |
| Công thức | Danh sách dạng lưới; tìm kiếm theo tên; lọc theo danh mục và món chay |
| Chi tiết món | Nguyên liệu, độ khó, thời gian, kcal; điều chỉnh khẩu phần (định lượng tự nhân tỉ lệ) |
| Hướng dẫn từng bước | Giao diện Stepper (tiếp tục / quay lại / chọn bước), thông báo khi hoàn thành |
| Bộ đếm giờ | Đếm ngược thời gian nấu: bắt đầu, tạm dừng, đặt lại |
| Yêu thích | Lưu / bỏ lưu công thức yêu thích |
| Thực đơn tuần | Thêm / xóa món theo ngày và bữa; tổng kcal ngày; tạo ngẫu nhiên theo mục tiêu (giảm cân, duy trì, tăng cân) |
| Tư vấn BMI | Tính BMI, đề xuất mục tiêu và ngân sách kcal/ngày (Mifflin-St Jeor) |
| Checklist nguyên liệu | Tự tổng hợp từ thực đơn, thêm thủ công, tích chọn; gợi ý món theo nguyên liệu đã tích |
| Quản trị (Admin) | Thêm / sửa / xóa công thức, chọn ảnh từ thiết bị (chỉ nhận `.jpg`) |
| Đa ngôn ngữ | Tiếng Việt và tiếng Anh, đổi tức thời và được ghi nhớ |
| Thông tin nhóm | Trang giới thiệu thành viên và nhiệm vụ |

## 🛠 Công nghệ & kiến trúc

- **Framework:** Flutter (SDK ^3.10.4), **ngôn ngữ:** Dart, giao diện Material 3.
- **Quản lý trạng thái:** `ChangeNotifier` + `ListenableBuilder` (không dùng thư viện ngoài).
- **Lưu trữ:** dữ liệu mẫu trong bộ nhớ (`MockData`), lưu bền vững bằng `shared_preferences`; `MySqlService` ghi nhật ký SQL mô phỏng, lược đồ nằm trong `database/mysql_schema.sql`.
- **Thư viện:** `shared_preferences`, `image_picker`.
- **Kiến trúc phân lớp:**
  - *Presentation:* `screens/`, `widgets/`, `main.dart`
  - *State & Business Logic:* `state/app_state_controller.dart`
  - *Data:* `models/`, `data/mock_data.dart`, `l10n/app_strings.dart`, `services/mysql_service.dart`

## 📂 Cấu trúc thư mục

```
lib/
├── main.dart                     # Khởi chạy app, MainAppShell (5 tab)
├── data/mock_data.dart           # Dữ liệu mẫu
├── l10n/app_strings.dart         # Chuỗi Anh – Việt
├── models/                       # Recipe, Ingredient, MealPlanItem, AppUser, TeamMember
├── services/mysql_service.dart   # Nhật ký SQL mô phỏng
├── state/app_state_controller.dart
├── screens/                      # auth, home_recipe, recipe_detail, recipe_form,
│                                 # meal_planner, bmi_advisor, checklist, team_settings
└── widgets/                      # recipe_card, meal_slot_card
```

## 🚀 Cài đặt và chạy

```bash
git clone https://github.com/VuDuyHieu06/2026_2027_1_1_LTTBDD_N01_Nhom11_ii
cd 2026_2027_1_1_LTTBDD_N01_Nhom11_ii
flutter pub get
flutter run
```

Tài khoản thử nghiệm: `admin` / `123456` (quản trị viên), `user` / `123456` (người dùng).

## 👥 Thành viên và phân công

| STT | Họ và tên | MSSV | Vai trò |
|---|---|---|---|
| 1 | Vũ Duy Hiếu | 24100060 | Phân hệ Công thức, ràng buộc ảnh `.jpg`, bộ đếm giờ |
| 2 | Nguyễn Đức Quân | 24100473 | MySQL Service, thực đơn ngẫu nhiên, tư vấn BMI – kcal |

### Thành viên 1 – Vũ Duy Hiếu (24100060)

- Thiết kế CSDL MySQL bảng `recipes`, `ingredients` và các lớp mô hình.
- Màn hình Trang chủ: tìm kiếm và lọc món ăn.
- Màn hình Chi tiết món ăn: bộ đếm giờ nấu và Stepper hướng dẫn từng bước.
- Màn hình Thêm / Sửa / Xóa món ăn (Admin) có kiểm tra định dạng ảnh `.jpg`.
- Viết báo cáo SRS/SAD phần phân hệ Công thức và Biểu đồ lớp.

### Thành viên 2 – Nguyễn Đức Quân (24100473)

- Thiết kế `MySqlService`, `AppUser` và từ điển Anh – Việt.
- Màn hình Đăng nhập / Đăng ký và phân quyền Admin – User.
- Màn hình Thực đơn tuần: tạo ngẫu nhiên theo ngày / tuần và chế độ ăn.
- Màn hình Tư vấn BMI: gợi ý món không vượt ngân sách kcal.
- Màn hình Checklist nguyên liệu và Cài đặt đa ngôn ngữ.

> Cả hai thành viên cùng tham gia viết code và báo cáo, và đều có thể trình bày mọi phần của dự án.

## 📄 Giấy phép

Dự án phục vụ mục đích học tập. Mọi quyền được bảo lưu bởi nhóm phát triển.