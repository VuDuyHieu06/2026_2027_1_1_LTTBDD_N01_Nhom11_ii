-- ============================================================================
-- CƠ SỞ DỮ LIỆU MYSQL: SỔ TAY CÔNG THỨC NẤU ĂN & LẬP THỰC ĐƠN TUẦN
-- Database: recipe_meal_planner (MySQL 8.0+ / MariaDB 10.4+)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS recipe_meal_planner
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE recipe_meal_planner;

-- 1. Bảng Tài khoản người dùng & Phân quyền (Admin / User)
CREATE TABLE IF NOT EXISTS users (
  id VARCHAR(36) PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  role ENUM('admin', 'user') NOT NULL DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bảng Công thức món ăn (Hỗ trợ lưu bất kỳ đường dẫn URL ảnh hoặc đường dẫn ảnh từ thiết bị)
CREATE TABLE IF NOT EXISTS recipes (
  id VARCHAR(36) PRIMARY KEY,
  title_vi VARCHAR(150) NOT NULL,
  title_en VARCHAR(150) NOT NULL,
  category_id ENUM('main', 'soup', 'veg', 'dessert') NOT NULL DEFAULT 'main',
  image_url TEXT,
  prep_time_minutes INT NOT NULL DEFAULT 25,
  difficulty_vi VARCHAR(30) NOT NULL DEFAULT 'Dễ',
  difficulty_en VARCHAR(30) NOT NULL DEFAULT 'Easy',
  default_servings INT NOT NULL DEFAULT 2,
  calories INT NOT NULL DEFAULT 300,
  is_vegetarian BOOLEAN NOT NULL DEFAULT FALSE,
  is_favorite BOOLEAN NOT NULL DEFAULT FALSE,
  steps_vi_json JSON NOT NULL,
  steps_en_json JSON NOT NULL
);

-- 3. Bảng Nguyên liệu của từng món ăn
CREATE TABLE IF NOT EXISTS ingredients (
  id VARCHAR(36) PRIMARY KEY,
  recipe_id VARCHAR(36) NOT NULL,
  name_vi VARCHAR(120) NOT NULL,
  name_en VARCHAR(120) NOT NULL,
  amount DECIMAL(8,2) NOT NULL DEFAULT 1.0,
  unit_vi VARCHAR(30) NOT NULL,
  unit_en VARCHAR(30) NOT NULL,
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- 4. Bảng Thực đơn tuần (7 ngày x 3 bữa: breakfast, lunch, dinner)
CREATE TABLE IF NOT EXISTS meal_plan_items (
  id VARCHAR(36) PRIMARY KEY,
  day_of_week TINYINT NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  meal_type ENUM('breakfast', 'lunch', 'dinner') NOT NULL,
  recipe_id VARCHAR(36) NOT NULL,
  diet_goal ENUM('weight_loss', 'maintain', 'weight_gain') DEFAULT 'maintain',
  FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- 5. Bảng Hồ sơ Chiều cao - Cân nặng (BMI) & Ngân sách Calo của người dùng
CREATE TABLE IF NOT EXISTS user_bmi_profiles (
  user_id VARCHAR(36) PRIMARY KEY,
  height_cm DECIMAL(5,1) NOT NULL DEFAULT 165.0,
  weight_kg DECIMAL(5,1) NOT NULL DEFAULT 60.0,
  age INT NOT NULL DEFAULT 21,
  gender ENUM('male', 'female') NOT NULL DEFAULT 'male',
  bmi_value DECIMAL(4,1) NOT NULL DEFAULT 22.0,
  recommended_goal ENUM('weight_loss', 'maintain', 'weight_gain') NOT NULL DEFAULT 'maintain',
  daily_calorie_limit INT NOT NULL DEFAULT 1850,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Dữ liệu mẫu ban đầu
INSERT IGNORE INTO users (id, username, password_hash, full_name, role) VALUES
('u_admin', 'admin', '123456', 'Quản trị viên Hệ thống (Admin)', 'admin'),
('u_user', 'user', '123456', 'Người dùng Đầu bếp tại gia', 'user');

INSERT IGNORE INTO recipes (
  id, title_vi, title_en, category_id, image_url, prep_time_minutes,
  difficulty_vi, difficulty_en, default_servings, calories, is_vegetarian, is_favorite,
  steps_vi_json, steps_en_json
) VALUES
(
  'r1', 'Phở Bò Truyền Thống Hà Nội', 'Traditional Hanoi Beef Pho', 'main',
  'assets/images/pho_bo.jpg', 45, 'Trung bình', 'Medium', 2, 480, FALSE, TRUE,
  '["Nướng thơm hành tím, gừng tươi cùng hoa hồi, thảo quả.", "Đun sôi nồi nước dùng xương bò 25 phút.", "Chần bánh phở tươi rồi xếp thịt bò lên trên."]',
  '["Char shallots, ginger, star anise, and cardamom.", "Simmer beef bone broth for 25 minutes.", "Blanch noodles and ladle boiling broth over sliced beef."]'
),
(
  'r2', 'Gỏi Cuốn Tôm Thịt Thanh Mát', 'Fresh Shrimp & Pork Spring Rolls', 'main',
  'assets/images/goi_cuon.jpg', 25, 'Dễ', 'Easy', 2, 310, FALSE, FALSE,
  '["Luộc chín tôm sú, bóc vỏ bổ đôi.", "Làm ẩm bánh tráng, xếp rau, bún, tôm thịt rồi cuộn chặt tay."]',
  '["Boil prawns and slice in half.", "Moisten rice paper, layer greens, vermicelli, prawns and roll tightly."]'
),
(
  'r3', 'Canh Bí Đỏ Đậu Hũ Non Thuần Chay', 'Vegan Pumpkin & Silken Tofu Soup', 'soup',
  'assets/images/canh_bi_do.jpg', 20, 'Dễ', 'Easy', 2, 220, TRUE, TRUE,
  '["Đun bí đỏ và nấm hương với 700ml nước 12 phút.", "Thả đậu hũ non cắt khối vào nồi canh, nêm gia vị chay."]',
  '["Simmer pumpkin and shiitake in 700ml water for 12 mins.", "Add cubed silken tofu and season lightly."]'
),
(
  'r4', 'Chè Hạt Sen Long Nhãn Thanh Nhiệt', 'Lotus Seed & Longan Sweet Soup', 'dessert',
  'assets/images/che_hat_sen.jpg', 30, 'Dễ', 'Easy', 4, 190, TRUE, FALSE,
  '["Ninh mềm hạt sen tươi 20 phút.", "Lồng hạt sen vào cùi nhãn tươi, đun nhẹ với đường phèn."]',
  '["Simmer lotus seeds for 20 minutes.", "Tuck lotus seeds inside longan fruit and simmer with rock sugar."]'
),
(
  'r5', 'Ức Gà Áp Chảo Salad Bơ (Eat Clean)', 'Pan-Seared Chicken Breast & Avocado Salad', 'main',
  'assets/images/uc_ga_salad.jpg', 20, 'Dễ', 'Easy', 1, 280, FALSE, TRUE,
  '["Ướp ức gà với tiêu đen và dầu ô liu 10 phút.", "Áp chảo ức gà mỗi mặt 4 phút rồi trộn cùng bơ sáp và xà lách."]',
  '["Marinate chicken breast with black pepper and olive oil.", "Pan-sear 4 mins per side and toss with avocado salad."]'
),
(
  'r6', 'Bò Lúc Lắc Khoai Tây Chiên Giàu Đạm', 'Shaking Beef Cubes with Crispy Fries', 'main',
  'assets/images/bo_luc_lac.jpg', 30, 'Trung bình', 'Medium', 2, 620, FALSE, FALSE,
  '["Cắt thịt bò thăn thành khối vuông 2cm, ướp dầu hào và tỏi băm.", "Xào bò lửa lớn cùng ớt chuông và hành tây."]',
  '["Cube beef tenderloin into 2cm pieces and marinate.", "Wok-toss over high flame with bell peppers and onions."]'
),
(
  'r7', 'Cơm Tấm Sườn Nướng Mật Ong', 'Grilled Honey Pork Chop Broken Rice', 'main',
  'assets/images/com_tam_suon.jpg', 35, 'Trung bình', 'Medium', 2, 680, FALSE, TRUE,
  '["Ướp sườn cốt lết với mật ong, sả băm và nước mắm 20 phút.", "Nướng sườn chín vàng hai mặt, ăn kèm cơm tấm và đồ chua."]',
  '["Marinate pork chop with honey, lemongrass, and fish sauce.", "Grill golden brown on both sides and serve over broken rice."]'
),
(
  'r8', 'Bún Chả Hà Nội Truyền Thống', 'Hanoi Grilled Pork & Vermicelli (Bun Cha)', 'main',
  'assets/images/bun_cha.jpg', 40, 'Trung bình', 'Medium', 2, 550, FALSE, TRUE,
  '["Băm thịt nạc vai, viên chả tròn và ướp cùng thịt ba chỉ thái lát.", "Nướng chả trên than hoa, ăn kèm bún tươi và nước mắm đu đủ xanh."]',
  '["Shape minced pork patties and marinate with sliced pork belly.", "Char-grill pork and serve with vermicelli and papaya dipping broth."]'
),
(
  'r9', 'Cá Hồi Áp Chảo Sốt Chanh Dây', 'Pan-Seared Salmon with Passion Fruit Glaze', 'main',
  'assets/images/ca_hoi_chanh_day.jpg', 20, 'Dễ', 'Easy', 2, 460, FALSE, FALSE,
  '["Áp chảo phi lê cá hồi với bơ lạt và măng tây xanh mỗi mặt 3 phút.", "Đun sánh nước cốt chanh dây với mật ong rồi rưới lên cá."]',
  '["Pan-sear salmon fillet with butter and asparagus for 3 mins per side.", "Reduce passion fruit juice with honey and drizzle over salmon."]'
),
(
  'r10', 'Đậu Hũ Sốt Cà Chua Thuần Chay', 'Vegan Braised Tofu in Tomato Sauce', 'main',
  'assets/images/dau_hu_sot_ca.jpg', 20, 'Dễ', 'Easy', 2, 340, TRUE, FALSE,
  '["Chiên vàng đều các mặt đậu hũ trắng cắt quân cờ.", "Xào nhuyễn cà chua chín rồi thả đậu hũ vào rim nhỏ lửa 8 phút."]',
  '["Pan-fry cubed firm tofu until golden.", "Simmer diced tomatoes into a rich sauce and braise tofu for 8 minutes."]'
),
(
  'r11', 'Mì Xào Rau Củ Nấm Đông Cô Chay', 'Vegan Stir-Fried Noodles with Shiitake & Veggies', 'main',
  'assets/images/mi_xao_chay.jpg', 20, 'Dễ', 'Easy', 2, 420, TRUE, TRUE,
  '["Trụng sơ mì vắt chay qua nước sôi rồi trộn chút dầu mè.", "Xào nấm đông cô, cải ngọt, cà rốt rồi cho mì vào đảo lửa lớn."]',
  '["Blanch vegan noodles briefly and toss with sesame oil.", "Stir-fry shiitake, bok choy, and carrots, then toss with noodles."]'
),
(
  'r12', 'Canh Chua Cá Lóc Nam Bộ', 'Southern Vietnamese Sweet & Sour Fish Soup', 'soup',
  'assets/images/canh_chua_ca_loc.jpg', 30, 'Trung bình', 'Medium', 3, 290, FALSE, TRUE,
  '["Đun sôi nước cốt me chua, thả cá lóc cắt khúc vào nấu chín.", "Cho dứa, cà chua, đậu bắp, bạc hà và giá đỗ vào đun thêm 3 phút."]',
  '["Boil tamarind broth and poach snakehead fish slices.", "Add pineapple, tomato, okra, taro stem, and bean sprouts."]'
),
(
  'r13', 'Canh Rong Biển Thịt Bằm Thanh Đạm', 'Seaweed & Minced Pork Clear Soup', 'soup',
  'assets/images/canh_rong_bien.jpg', 15, 'Dễ', 'Easy', 2, 180, FALSE, FALSE,
  '["Ngâm nở rong biển khô 5 phút, ướp thịt nạc băm với gừng.", "Đun sôi nước với thịt băm, thả rong biển và đậu hũ non vào nấu 2 phút."]',
  '["Soak dried seaweed for 5 mins and season minced pork with ginger.", "Simmer pork broth, add seaweed and silken tofu for 2 minutes."]'
),
(
  'r14', 'Canh Cua Rau Đay Mồng Tơi', 'Field Crab Soup with Malabar Spinach & Jute Mallow', 'soup',
  'assets/images/canh_cua_rau_day.jpg', 25, 'Dễ', 'Easy', 3, 210, FALSE, FALSE,
  '["Khuấy đều gạch và nước lọc cua đồng, đun lửa vừa cho thịt cua đóng tảng.", "Thả rau đay, mồng tơi và mướp hương thái vát vào nấu chín mềm."]',
  '["Bring filtered crab broth to a gentle simmer until crab meat forms rafts.", "Add chopped jute mallow, Malabar spinach, and loofah until tender."]'
),
(
  'r15', 'Canh Nấm Hạt Sen Táo Đỏ Thuần Chay', 'Vegan Lotus Seed, Red Dates & Mushroom Soup', 'soup',
  'assets/images/canh_nam_hat_sen.jpg', 30, 'Dễ', 'Easy', 3, 160, TRUE, TRUE,
  '["Hầm hạt sen tươi, táo đỏ và cà rốt tỉa hoa trong 20 phút.", "Cho nấm đùi gà cắt lát vào đun sôi thêm 5 phút, nêm hạt nêm chay."]',
  '["Simmer lotus seeds, red dates, and sliced carrots for 20 minutes.", "Add king oyster mushrooms and simmer 5 more minutes."]'
),
(
  'r16', 'Súp Gà Ngô Non Nấm Hương', 'Sweet Corn & Chicken Egg Drop Soup', 'soup',
  'assets/images/sup_ga_ngo_non.jpg', 25, 'Dễ', 'Easy', 3, 320, FALSE, FALSE,
  '["Luộc chín ức gà xé sợi, đun sôi nước luộc gà cùng hạt ngô ngọt và nấm hương.", "Khuấy bột năng tạo độ sánh rồi đổ từ từ lòng trắng trứng gà vào tạo vân."]',
  '["Shred poached chicken breast and simmer broth with sweet corn and shiitake.", "Thicken with tapioca starch and drizzle beaten egg whites in a swirl."]'
),
(
  'r17', 'Sữa Chua Hy Lạp Trái Cây & Hạt Chia', 'Greek Yogurt Bowl with Berries & Chia Seeds', 'dessert',
  'assets/images/sua_chua_hy_lap.jpg', 10, 'Dễ', 'Easy', 1, 150, TRUE, TRUE,
  '["Múc sữa chua Hy Lạp không đường ra bát.", "Xếp dâu tây, việt quất cắt đôi và rắc hạt chia, hạnh nhân lát lên trên."]',
  '["Scoop unsweetened Greek yogurt into a chilled bowl.", "Top with halved strawberries, blueberries, chia seeds, and sliced almonds."]'
),
(
  'r18', 'Bánh Flan Caramel Trứng Sữa Mềm Mịn', 'Silky Classic Crème Caramel Flan', 'dessert',
  'assets/images/banh_flan.jpg', 35, 'Trung bình', 'Medium', 4, 240, FALSE, FALSE,
  '["Thắng đường vàng cánh gián làm lớp caramel đáy khuôn.", "Khuấy đều trứng gà và sữa tươi ấm, lọc qua rây rồi hấp cách thủy 25 phút."]',
  '["Caramelize sugar to golden amber and coat ramekin bottoms.", "Whisk eggs with warm milk, strain, and steam gently for 25 minutes."]'
),
(
  'r19', 'Sinh Tố Bơ Chuối Sữa Hạt Tăng Cơ', 'Creamy Avocado Banana & Nut Milk Smoothie', 'dessert',
  'assets/images/sinh_to_bo_chuoi.jpg', 10, 'Dễ', 'Easy', 1, 350, TRUE, TRUE,
  '["Cho thịt bơ sáp, chuối chín, sữa hạnh nhân và bơ đậu phộng vào máy xay.", "Xay nhuyễn mịn cùng đá viên trong 45 giây rồi thưởng thức."]',
  '["Combine ripe avocado, banana, almond milk, and peanut butter in a blender.", "Blend with ice cubes for 45 seconds until creamy."]'
),
(
  'r20', 'Chè Khúc Bạch Hạnh Nhân Nhãn Tươi', 'Almond Panna Cotta & Lychee Sweet Soup', 'dessert',
  'assets/images/che_khuc_bach.jpg', 30, 'Trung bình', 'Medium', 4, 280, FALSE, FALSE,
  '["Đun sữa tươi, kem tươi với gelatin làm thạch khúc bạch, để lạnh cắt miếng.", "Nấu nước đường phèn lá dứa, thả nhãn tươi và hạnh nhân rang vàng vào."]',
  '["Prepare almond milk panna cotta cubes with gelatin and chill.", "Serve in pandan rock sugar syrup with fresh longan and toasted almond flakes."]'
),
(
  'r21', 'Tàu Hũ Nước Đường Gừng Trân Châu Chay', 'Warm Ginger Silken Tofu Pudding with Tapioca Pearls', 'dessert',
  'assets/images/tau_hu_gung.jpg', 20, 'Dễ', 'Easy', 2, 170, TRUE, FALSE,
  '["Đun sôi nước đường nâu cùng gừng tươi đập dập thái lát.", "Hớt từng lát mỏng tàu hũ non vào bát, chan nước đường gừng nóng và trân châu trắng."]',
  '["Simmer brown sugar syrup with freshly sliced ginger.", "Scoop warm silken tofu ribbons into bowls and ladle hot ginger syrup and pearls."]'
);