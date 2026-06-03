-- ============================================
-- ASIAHUB MVP — База данных
-- ============================================
-- Запусти в PostgreSQL: psql -U postgres -f database.sql



-- Пользователи
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'customer' CHECK (role IN ('customer', 'admin')),
    bonus_points INTEGER DEFAULT 0,
    language VARCHAR(5) DEFAULT 'uk' CHECK (language IN ('uk', 'en')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Категории заведений/магазинов
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    type VARCHAR(20) NOT NULL CHECK (type IN ('restaurant', 'shop')),
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Партнёры (рестораны и магазины)
CREATE TABLE partners (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    description TEXT,
    description_en TEXT,
    type VARCHAR(20) NOT NULL CHECK (type IN ('restaurant', 'shop')),
    category_id INTEGER REFERENCES categories(id),
    address VARCHAR(500),
    phone VARCHAR(20),
    image_url VARCHAR(500),
    logo_url VARCHAR(500),
    rating DECIMAL(2,1) DEFAULT 0,
    delivery_time VARCHAR(50),        -- "30-45 хв"
    min_order DECIMAL(10,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    working_hours VARCHAR(100),       -- "10:00-22:00"
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Категории товаров/блюд в рамках партнёра
CREATE TABLE menu_categories (
    id SERIAL PRIMARY KEY,
    partner_id INTEGER REFERENCES partners(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    name_en VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Товары / Блюда
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    partner_id INTEGER REFERENCES partners(id) ON DELETE CASCADE,
    menu_category_id INTEGER REFERENCES menu_categories(id) ON DELETE SET NULL,
    name VARCHAR(200) NOT NULL,
    name_en VARCHAR(200),
    description TEXT,
    description_en TEXT,
    price DECIMAL(10,2) NOT NULL,
    old_price DECIMAL(10,2),          -- для акций/скидок
    image_url VARCHAR(500),
    weight VARCHAR(50),               -- "250г" или "500мл"
    is_available BOOLEAN DEFAULT true,
    is_popular BOOLEAN DEFAULT false,
    spicy_level INTEGER DEFAULT 0 CHECK (spicy_level BETWEEN 0 AND 3),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Заказы
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    status VARCHAR(30) DEFAULT 'pending' 
        CHECK (status IN ('pending','confirmed','preparing','delivering','completed','cancelled')),
    total_amount DECIMAL(10,2) NOT NULL,
    delivery_address VARCHAR(500) NOT NULL,
    delivery_phone VARCHAR(20) NOT NULL,
    delivery_name VARCHAR(100) NOT NULL,
    payment_method VARCHAR(20) DEFAULT 'card' CHECK (payment_method IN ('card', 'cash')),
    payment_status VARCHAR(20) DEFAULT 'pending' CHECK (payment_status IN ('pending','paid','failed','refunded')),
    bonus_used INTEGER DEFAULT 0,
    bonus_earned INTEGER DEFAULT 0,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Позиции заказа
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    partner_id INTEGER REFERENCES partners(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(10,2) NOT NULL,      -- цена на момент заказа
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Отзывы
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    partner_id INTEGER REFERENCES partners(id) ON DELETE CASCADE,
    order_id INTEGER REFERENCES orders(id),
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Промокоды
CREATE TABLE promo_codes (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_percent INTEGER,
    discount_amount DECIMAL(10,2),
    min_order DECIMAL(10,2) DEFAULT 0,
    max_uses INTEGER DEFAULT 100,
    used_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- SEED DATA — Реальные заведения из документации
-- ============================================

-- Категории
INSERT INTO categories (name, name_en, type, icon) VALUES
('Японська кухня', 'Japanese cuisine', 'restaurant', '🍣'),
('Китайська кухня', 'Chinese cuisine', 'restaurant', '🥡'),
('В''єтнамська кухня', 'Vietnamese cuisine', 'restaurant', '🍜'),
('Паназійська кухня', 'Pan-Asian cuisine', 'restaurant', '🥢'),
('Корейська кухня', 'Korean cuisine', 'restaurant', '🍚'),
('Азійські продукти', 'Asian products', 'shop', '🏪'),
('Снеки та напої', 'Snacks & drinks', 'shop', '🧃');

-- Партнёры (из документации)
INSERT INTO partners (name, name_en, description, description_en, type, category_id, address, image_url, rating, delivery_time, min_order) VALUES
('ЯПІКО', 'YAPIKO', 'У ресторані Япіко ви можете скуштувати всі популярні страви з розділу суші: класичні нігірі, гункани, а також роли, сети і спринг роли.', 'At YAPIKO restaurant you can taste all popular sushi dishes: classic nigiri, gunkan, as well as rolls, sets and spring rolls.', 'restaurant', 1, 'вул. Сумська, 25, Харків', '/images/yapiko.jpg', 4.5, '30-45 хв', 200),

('Roll Club', 'Roll Club', 'Roll Club пропонує величезну різноманітність ролів та суші-сетів з доставкою. Ці страви, безперечно, радують і дарують відмінний настрій.', 'Roll Club offers a huge variety of rolls and sushi sets with delivery.', 'restaurant', 1, 'вул. Пушкінська, 50, Харків', '/images/rollclub.jpg', 4.3, '25-40 хв', 150),

('PanAzia', 'PanAzia', 'Це перший фаст-фуд кафе паназіатської кухні у місті. Тут ви можете поласувати стравами азіатської, японської, в''єтнамської та тайської кухні.', 'The first pan-Asian fast food cafe in the city.', 'restaurant', 4, 'вул. Клочківська, 12, Харків', '/images/panazia.jpg', 4.6, '20-35 хв', 100),

('Mao', 'Mao', 'Ресторан китайської кухні в центрі Харкова, що спеціалізується на простих та автентичних стравах від шеф-кухаря з Китаю.', 'Chinese cuisine restaurant in the center of Kharkiv, specializing in simple and authentic dishes.', 'restaurant', 2, 'вул. Алчевських, 30, Харків', '/images/mao.jpg', 4.7, '35-50 хв', 250),

('GA.GA', 'GA.GA', 'Готуєм кращий Фо Бо на районі', 'We cook the best Pho Bo in the neighborhood', 'restaurant', 3, 'вул. Гагаріна, 1, Харків', '/images/gaga.jpg', 4.4, '25-40 хв', 150),

('YOKAI', 'YOKAI', 'Той самий sushi burger, Food truck з vibe of Asia', 'The famous sushi burger, Food truck with vibe of Asia', 'restaurant', 4, 'вул. Героїв Праці, 7, Харків', '/images/yokai.jpg', 4.2, '15-30 хв', 100),

('Osama Sushi', 'Osama Sushi', 'Найсмачніші суші у твоєму місті, обирайте страви, які вам подобаються — про все інше ми подбаємо.', 'The tastiest sushi in your city.', 'restaurant', 1, 'вул. Університетська, 18, Харків', '/images/osama.jpg', 4.1, '30-45 хв', 120),

('В''єтнамська кухня', 'Vietnamese Kitchen', 'Якщо ти любиш в''єтнамську кухню, наш заклад завжди є відкритим для тебе!', 'If you love Vietnamese cuisine, our place is always open for you!', 'restaurant', 3, 'пр. Науки, 44, Харків', '/images/vietnam.jpg', 4.3, '30-40 хв', 130),

('Barbaris', 'Barbaris', 'Магазин азійських продуктів та делікатесів', 'Asian products and delicacies shop', 'shop', 6, 'ТЦ Караван, Харків', '/images/barbaris.jpg', 4.0, '60-90 хв', 300);

-- Категории меню для ЯПІКО
INSERT INTO menu_categories (partner_id, name, name_en, sort_order) VALUES
(1, 'Роли', 'Rolls', 1),
(1, 'Суші нігірі', 'Nigiri sushi', 2),
(1, 'Сети', 'Sets', 3),
(1, 'Гарячі страви', 'Hot dishes', 4),
(1, 'Напої', 'Drinks', 5);

-- Товары ЯПІКО
INSERT INTO products (partner_id, menu_category_id, name, name_en, description, price, weight, is_popular, spicy_level) VALUES
(1, 1, 'Філадельфія класик', 'Philadelphia classic', 'Лосось, вершковий сир, огірок, рис, норі', 259, '250г', true, 0),
(1, 1, 'Каліфорнія з крабом', 'California crab', 'Крабове м''ясо, авокадо, огірок, ікра тобіко', 229, '230г', true, 0),
(1, 1, 'Дракон рол', 'Dragon roll', 'Вугор, авокадо, вершковий сир, соус унагі', 319, '280г', true, 1),
(1, 1, 'Спайсі лосось', 'Spicy salmon', 'Лосось, спайсі соус, зелена цибуля', 199, '220г', false, 2),
(1, 2, 'Нігірі лосось', 'Nigiri salmon', 'Свіжий лосось на рисі', 89, '35г', false, 0),
(1, 2, 'Нігірі тунець', 'Nigiri tuna', 'Тунець на рисі', 99, '35г', false, 0),
(1, 3, 'Сет Філадельфія', 'Philadelphia set', '32 шт — Філадельфія класик, лосось, з огірком, з авокадо', 699, '1100г', true, 0),
(1, 3, 'Сет Мікс', 'Mix set', '40 шт — Філадельфія, Каліфорнія, Дракон, Спайсі', 899, '1400г', true, 1),
(1, 4, 'Рамен з куркою', 'Chicken ramen', 'Насичений бульйон, локшина, курка, яйце аджитама, зелена цибуля', 189, '450г', false, 1),
(1, 4, 'Вок з овочами', 'Veggie wok', 'Локшина удон, овочі мікс, соєвий соус, кунжут', 159, '350г', false, 0),
(1, 5, 'Зелений чай', 'Green tea', 'Японський зелений чай', 49, '300мл', false, 0),
(1, 5, 'Лимонад юдзу', 'Yuzu lemonade', 'Освіжаючий лимонад з цитрусом юдзу', 79, '400мл', false, 0);

-- Товары Roll Club
INSERT INTO menu_categories (partner_id, name, name_en, sort_order) VALUES
(2, 'Роли', 'Rolls', 1),
(2, 'Суші-сети', 'Sushi sets', 2),
(2, 'Боули', 'Bowls', 3);

INSERT INTO products (partner_id, menu_category_id, name, name_en, description, price, weight, is_popular, spicy_level) VALUES
(2, 6, 'Філадельфія преміум', 'Philadelphia premium', 'Подвійний лосось, вершковий сир, авокадо', 289, '270г', true, 0),
(2, 6, 'Темпура рол', 'Tempura roll', 'Креветка темпура, авокадо, спайсі майо', 249, '260г', false, 1),
(2, 7, 'Сет Рол Кінг', 'Roll King set', '48 шт — найпопулярніші роли', 999, '1600г', true, 0),
(2, 8, 'Поке з лососем', 'Salmon poke', 'Рис, лосось, авокадо, едамаме, соус понзу', 219, '400г', true, 0);

-- Товары Mao
INSERT INTO menu_categories (partner_id, name, name_en, sort_order) VALUES
(4, 'Локшина', 'Noodles', 1),
(4, 'Дім сами', 'Dim sum', 2),
(4, 'Основні страви', 'Main dishes', 3);

INSERT INTO products (partner_id, menu_category_id, name, name_en, description, price, weight, is_popular, spicy_level) VALUES
(4, 9, 'Дан Дан локшина', 'Dan Dan noodles', 'Класична сичуанська локшина з м''ясним соусом', 179, '400г', true, 3),
(4, 9, 'Бі Фун з морепродуктами', 'Bi Fun with seafood', 'Рисова локшина, креветки, кальмар, овочі', 229, '380г', false, 1),
(4, 10, 'Сяо Лун Бао', 'Xiao Long Bao', 'Парові пельмені з бульйоном всередині (8 шт)', 159, '200г', true, 0),
(4, 10, 'Дім сами з креветкою', 'Shrimp dim sum', 'Класичні гонконгські дім сами (6 шт)', 189, '180г', false, 0),
(4, 11, 'Качка по-пекінськи', 'Peking duck', 'Хрустка качка з млинцями та соусом хойсін', 459, '600г', true, 0),
(4, 11, 'Мапо тофу', 'Mapo tofu', 'Гостре тофу по-сичуанськи з м''ясним фаршем', 149, '350г', false, 3);

-- Товары PanAzia
INSERT INTO menu_categories (partner_id, name, name_en, sort_order) VALUES
(3, 'Воки', 'Wok', 1),
(3, 'Супи', 'Soups', 2),
(3, 'Рис та карі', 'Rice & curry', 3);

INSERT INTO products (partner_id, menu_category_id, name, name_en, description, price, weight, is_popular, spicy_level) VALUES
(3, 12, 'Пад Тай з куркою', 'Pad Thai chicken', 'Рисова локшина, курка, арахіс, соус тамарінд', 169, '380г', true, 1),
(3, 12, 'Вок з яловичиною', 'Beef wok', 'Удон, яловичина, броколі, перець, соєвий соус', 199, '400г', false, 1),
(3, 13, 'Том Ям з креветками', 'Tom Yam shrimp', 'Гострий тайський суп з креветками та грибами', 189, '350г', true, 2),
(3, 13, 'Фо Бо', 'Pho Bo', 'В''єтнамський суп з яловичиною та рисовою локшиною', 169, '450г', true, 0),
(3, 14, 'Карі з куркою', 'Chicken curry', 'Жовте тайське карі, кокосове молоко, рис', 179, '420г', false, 2);

-- Товары GA.GA
INSERT INTO menu_categories (partner_id, name, name_en, sort_order) VALUES
(5, 'Фо', 'Pho', 1),
(5, 'Бан Мі', 'Banh Mi', 2);

INSERT INTO products (partner_id, menu_category_id, name, name_en, description, price, weight, is_popular, spicy_level) VALUES
(5, 15, 'Фо Бо класичний', 'Classic Pho Bo', 'Яловичий бульйон 12 годин, рисова локшина, м''ясо, зелень', 179, '500г', true, 0),
(5, 15, 'Фо Га', 'Pho Ga', 'Курячий бульйон, рисова локшина, курка', 159, '480г', false, 0),
(5, 16, 'Бан Мі з куркою', 'Banh Mi chicken', 'В''єтнамський сендвіч з маринованою куркою', 129, '280г', true, 1);

-- Товары магазина Barbaris
INSERT INTO menu_categories (partner_id, name, name_en, sort_order) VALUES
(9, 'Снеки', 'Snacks', 1),
(9, 'Напої', 'Drinks', 2),
(9, 'Соуси та приправи', 'Sauces & spices', 3),
(9, 'Локшина та рис', 'Noodles & rice', 4);

INSERT INTO products (partner_id, menu_category_id, name, name_en, description, price, weight, is_popular, spicy_level) VALUES
(9, 17, 'Покі чіпси васабі', 'Wasabi poki chips', 'Японські рисові чіпси з васабі', 89, '60г', true, 2),
(9, 17, 'Моті манго', 'Mango mochi', 'Японський десерт моті з начинкою манго (6 шт)', 149, '210г', true, 0),
(9, 17, 'Крекери з водоростями', 'Seaweed crackers', 'Хрусткі крекери з норі', 69, '50г', false, 0),
(9, 18, 'Рамуне — Оригінал', 'Ramune Original', 'Японська газована вода з кулькою', 79, '200мл', true, 0),
(9, 18, 'Мілкіс банан', 'Milkis banana', 'Корейський молочний газований напій', 59, '250мл', false, 0),
(9, 18, 'Матча латте мікс', 'Matcha latte mix', 'Порошок для приготування матча латте (10 стіків)', 199, '120г', false, 0),
(9, 19, 'Соєвий соус Кіккоман', 'Kikkoman soy sauce', 'Класичний японський соєвий соус', 129, '250мл', true, 0),
(9, 19, 'Шрірача', 'Sriracha', 'Гострий тайський соус', 109, '250мл', false, 3),
(9, 20, 'Удон', 'Udon noodles', 'Товста пшенична локшина', 79, '300г', false, 0),
(9, 20, 'Рис для суші', 'Sushi rice', 'Круглозернистий рис преміум', 149, '1кг', true, 0);

-- Промокод для тесту
INSERT INTO promo_codes (code, discount_percent, min_order, expires_at) VALUES
('ASIA10', 10, 200, '2026-12-31'),
('FIRST20', 20, 300, '2026-12-31');

-- Админ-пользователь (пароль: admin123 — bcrypt хэш)
INSERT INTO users (name, email, password, role) VALUES
('Admin', 'admin@asiahub.ua', '$2a$10$xVqYLGEiGo0R1qqvFQMwAeXMaFmBklTVFUMz2B/Mi7HNlVDqJhXHG', 'admin');