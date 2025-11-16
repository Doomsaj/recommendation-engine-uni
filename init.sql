DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ecommerce_db;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    registration_date DATE NOT NULL,
    country VARCHAR(100),
    age INT,
    gender ENUM('M', 'F', 'Other'),
    INDEX idx_registration (registration_date)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(500) NOT NULL,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),
    price DECIMAL(10, 2) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    tags VARCHAR(500),
    description TEXT,
    stock_quantity INT DEFAULT 100,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_brand (brand),
    INDEX idx_price (price)
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    order_date DATETIME NOT NULL,
    order_status ENUM('pending', 'completed', 'cancelled') DEFAULT 'completed',
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_user (user_id),
    INDEX idx_product (product_id),
    INDEX idx_date (order_date)
) ENGINE=InnoDB;

INSERT INTO users (email, name, registration_date, country, age, gender)
SELECT
    CONCAT('user', n, '@example.com'),
    CONCAT('User ', n),
    DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 400) DAY),
    ELT(FLOOR(1 + RAND() * 5), 'USA', 'Canada', 'UK', 'Germany', 'Australia'),
    FLOOR(18 + RAND() * 50),
    ELT(FLOOR(1 + RAND() * 2), 'M', 'F')
FROM (
    SELECT (@row_number := @row_number + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t3,
        (SELECT @row_number := 0) r
    LIMIT 1000
) numbers;

INSERT INTO products (name, category, subcategory, price, brand, tags, description) VALUES
('iPhone 15 Pro Max', 'Electronics', 'Smartphones', 1199.99, 'Apple', 'smartphone,ios,premium', 'Latest iPhone'),
('Samsung Galaxy S24', 'Electronics', 'Smartphones', 999.99, 'Samsung', 'smartphone,android', 'Flagship Samsung'),
('Google Pixel 8', 'Electronics', 'Smartphones', 699.99, 'Google', 'smartphone,camera', 'Best camera phone'),
('MacBook Pro M3', 'Electronics', 'Laptops', 2499.99, 'Apple', 'laptop,professional', 'Pro laptop'),
('Dell XPS 15', 'Electronics', 'Laptops', 1599.99, 'Dell', 'laptop,windows', 'Premium laptop'),
('iPad Pro', 'Electronics', 'Tablets', 1099.99, 'Apple', 'tablet,ios', 'Professional tablet'),
('AirPods Pro', 'Electronics', 'Audio', 249.99, 'Apple', 'earbuds,wireless', 'Premium earbuds'),
('Sony WH-1000XM5', 'Electronics', 'Audio', 399.99, 'Sony', 'headphones,anc', 'Noise cancelling'),
('Apple Watch Series 9', 'Electronics', 'Wearables', 429.99, 'Apple', 'smartwatch', 'Latest smartwatch'),
('Kindle Paperwhite', 'Electronics', 'E-readers', 139.99, 'Amazon', 'ereader,books', 'E-reader');

INSERT INTO products (name, category, subcategory, price, brand, tags)
SELECT
    CONCAT('Electronics Product ', n),
    'Electronics',
    ELT(FLOOR(1 + RAND() * 4), 'Smartphones', 'Laptops', 'Audio', 'Accessories'),
    ROUND(50 + RAND() * 1950, 2),
    ELT(FLOOR(1 + RAND() * 5), 'Apple', 'Samsung', 'Sony', 'Dell', 'HP'),
    'electronics,tech'
FROM (
    SELECT (@row_number2 := @row_number2 + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
        (SELECT @row_number2 := 10) r
    LIMIT 90
) numbers;

INSERT INTO products (name, category, subcategory, price, brand, tags, description) VALUES
('Levi 501 Jeans', 'Clothing', 'Jeans', 69.99, 'Levis', 'jeans,denim', 'Classic jeans'),
('Nike Air Max', 'Clothing', 'Shoes', 129.99, 'Nike', 'shoes,sneakers', 'Running shoes'),
('Adidas Ultraboost', 'Clothing', 'Shoes', 179.99, 'Adidas', 'shoes,running', 'Comfort shoes'),
('North Face Jacket', 'Clothing', 'Outerwear', 249.99, 'North Face', 'jacket,winter', 'Winter jacket'),
('Patagonia Fleece', 'Clothing', 'Outerwear', 149.99, 'Patagonia', 'fleece,outdoor', 'Outdoor fleece'),
('Ralph Lauren Polo', 'Clothing', 'Tops', 89.99, 'Ralph Lauren', 'polo,classic', 'Classic polo'),
('Lululemon Leggings', 'Clothing', 'Activewear', 98.99, 'Lululemon', 'leggings,yoga', 'Yoga pants'),
('Converse Chuck Taylor', 'Clothing', 'Shoes', 59.99, 'Converse', 'sneakers,casual', 'Classic sneakers'),
('Vans Old Skool', 'Clothing', 'Shoes', 64.99, 'Vans', 'sneakers,skate', 'Skate shoes'),
('H&M T-Shirt', 'Clothing', 'Tops', 12.99, 'HM', 'tshirt,basic', 'Basic tee');

INSERT INTO products (name, category, subcategory, price, brand, tags)
SELECT
    CONCAT('Clothing Item ', n),
    'Clothing',
    ELT(FLOOR(1 + RAND() * 4), 'Tops', 'Bottoms', 'Shoes', 'Outerwear'),
    ROUND(15 + RAND() * 285, 2),
    ELT(FLOOR(1 + RAND() * 5), 'Nike', 'Adidas', 'Zara', 'HM', 'Uniqlo'),
    'clothing,fashion'
FROM (
    SELECT (@row_number3 := @row_number3 + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
        (SELECT @row_number3 := 10) r
    LIMIT 90
) numbers;

INSERT INTO products (name, category, subcategory, price, brand, tags) VALUES
('Dyson Vacuum', 'Home', 'Appliances', 599.99, 'Dyson', 'vacuum,cleaning'),
('KitchenAid Mixer', 'Home', 'Kitchen', 449.99, 'KitchenAid', 'mixer,baking'),
('Instant Pot', 'Home', 'Kitchen', 99.99, 'Instant Pot', 'cooker,kitchen'),
('Nespresso Machine', 'Home', 'Kitchen', 199.99, 'Nespresso', 'coffee,espresso'),
('Le Creuset Dutch Oven', 'Home', 'Cookware', 379.99, 'Le Creuset', 'cookware,premium'),
('Casper Mattress', 'Home', 'Bedroom', 1095.00, 'Casper', 'mattress,sleep'),
('Philips Hue Lights', 'Home', 'Smart Home', 199.99, 'Philips', 'smart,lighting'),
('Ring Doorbell', 'Home', 'Smart Home', 99.99, 'Ring', 'doorbell,security'),
('iRobot Roomba', 'Home', 'Appliances', 799.99, 'iRobot', 'robot,vacuum'),
('Ninja Air Fryer', 'Home', 'Kitchen', 129.99, 'Ninja', 'airfryer,cooking');

INSERT INTO products (name, category, subcategory, price, brand, tags)
SELECT
    CONCAT('Home Product ', n),
    'Home',
    ELT(FLOOR(1 + RAND() * 3), 'Kitchen', 'Bedroom', 'Appliances'),
    ROUND(25 + RAND() * 975, 2),
    ELT(FLOOR(1 + RAND() * 5), 'Dyson', 'KitchenAid', 'Philips', 'Samsung', 'LG'),
    'home,living'
FROM (
    SELECT (@row_number4 := @row_number4 + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t2,
        (SELECT @row_number4 := 10) r
    LIMIT 90
) numbers;

INSERT INTO products (name, category, subcategory, price, brand, tags)
SELECT
    CONCAT('Beauty Product ', n),
    'Beauty',
    ELT(FLOOR(1 + RAND() * 3), 'Skincare', 'Makeup', 'Haircare'),
    ROUND(10 + RAND() * 190, 2),
    ELT(FLOOR(1 + RAND() * 5), 'Olaplex', 'Fenty', 'CeraVe', 'Glossier', 'MAC'),
    'beauty,cosmetics'
FROM (
    SELECT (@row_number5 := @row_number5 + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
        (SELECT @row_number5 := 0) r
    LIMIT 50
) numbers;

INSERT INTO products (name, category, subcategory, price, brand, tags)
SELECT
    CONCAT('Sports Product ', n),
    'Sports',
    ELT(FLOOR(1 + RAND() * 3), 'Fitness', 'Outdoor', 'Equipment'),
    ROUND(20 + RAND() * 480, 2),
    ELT(FLOOR(1 + RAND() * 5), 'Nike', 'Adidas', 'Yeti', 'REI', 'Patagonia'),
    'sports,fitness'
FROM (
    SELECT (@row_number6 := @row_number6 + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
        (SELECT @row_number6 := 0) r
    LIMIT 50
) numbers;

INSERT INTO products (name, category, subcategory, price, brand, tags)
SELECT
    CONCAT('Book Title ', n),
    'Books',
    ELT(FLOOR(1 + RAND() * 3), 'Fiction', 'Non-Fiction', 'Self-Help'),
    ROUND(10 + RAND() * 40, 2),
    ELT(FLOOR(1 + RAND() * 5), 'Penguin', 'HarperCollins', 'Simon Schuster', 'Random House', 'Macmillan'),
    'books,reading'
FROM (
    SELECT (@row_number7 := @row_number7 + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
        (SELECT @row_number7 := 0) r
    LIMIT 50
) numbers;

INSERT INTO products (name, category, subcategory, price, brand, tags)
SELECT
    CONCAT('Toy Item ', n),
    'Toys',
    ELT(FLOOR(1 + RAND() * 3), 'Building', 'Games', 'Action'),
    ROUND(15 + RAND() * 185, 2),
    ELT(FLOOR(1 + RAND() * 5), 'LEGO', 'Mattel', 'Hasbro', 'Fisher-Price', 'Nerf'),
    'toys,kids'
FROM (
    SELECT (@row_number8 := @row_number8 + 1) AS n
    FROM
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) t1,
        (SELECT 0 UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) t2,
        (SELECT @row_number8 := 0) r
    LIMIT 50
) numbers;

DELIMITER $$

CREATE PROCEDURE generate_orders(IN num_orders INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE random_user_id INT;
    DECLARE random_product_id INT;
    DECLARE random_quantity INT;
    DECLARE random_date DATETIME;
    DECLARE random_status VARCHAR(20);

    DECLARE min_user INT;
    DECLARE max_user INT;
    DECLARE min_product INT;
    DECLARE max_product INT;

    SELECT MIN(user_id), MAX(user_id) INTO min_user, max_user FROM users;
    SELECT MIN(product_id), MAX(product_id) INTO min_product, max_product FROM products;

    WHILE i < num_orders DO
        SET random_user_id = min_user + FLOOR(RAND() * (max_user - min_user + 1));

        SET random_product_id = min_product + FLOOR(RAND() * (max_product - min_product + 1));

        SET random_quantity = 1 + FLOOR(RAND() * 3);

        SET random_date = DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND() * 600) DAY);

        IF RAND() > 0.05 THEN
            SET random_status = 'completed';
        ELSE
            SET random_status = 'cancelled';
        END IF;

        INSERT IGNORE INTO orders (user_id, product_id, quantity, order_date, order_status)
        VALUES (random_user_id, random_product_id, random_quantity, random_date, random_status);

        SET i = i + 1;

        IF i % 5000 = 0 THEN
            SELECT CONCAT('Generated ', i, ' orders...') AS progress;
        END IF;
    END WHILE;

    SELECT CONCAT('✅ Successfully generated ', i, ' orders') AS result;
END$$

DELIMITER ;

CALL generate_orders(40000);

DROP PROCEDURE IF EXISTS generate_orders;