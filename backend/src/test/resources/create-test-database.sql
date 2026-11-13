CREATE DATABASE IF NOT EXISTS smarttravel_test
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'smarttravel_test'@'localhost' IDENTIFIED BY 'smarttravel_test';
GRANT ALL PRIVILEGES ON smarttravel_test.* TO 'smarttravel_test'@'localhost';
