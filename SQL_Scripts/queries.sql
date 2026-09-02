-- ========================================================
-- ЧАСТЬ 1: ПРОЕКТИРОВАНИЕ И СОЗДАНИЕ СХЕМЫ ДАННЫХ (ЗВЕЗДА)
-- ========================================================

-- 1. Создаем справочник тарифных планов (Dim_Plans)
CREATE TABLE Dim_Plans (
    Plan_ID INT PRIMARY KEY,
    Plan_Name VARCHAR(50),
    Monthly_Price DECIMAL(10, 2)
);

INSERT INTO Dim_Plans VALUES 
(1, 'Basic', 9.99),
(2, 'Standard', 14.99),
(3, 'Premium', 19.99);

-- 2. Создаем справочник пользователей (Dim_Users)
CREATE TABLE Dim_Users (
    User_ID INT PRIMARY KEY,
    Country VARCHAR(50),
    Age INT,
    Registration_Date DATE
);

INSERT INTO Dim_Users VALUES
(101, 'Australia', 28, '2025-01-10'),
(102, 'Russia', 34, '2025-01-15'),
(103, 'Australia', 22, '2025-02-01'),
(104, 'United Kingdom', 45, '2025-02-12'),
(105, 'Russia', 19, '2025-03-03');

-- 3. Создаем таблицу фактов подписок (Fact_Subscriptions)
CREATE TABLE Fact_Subscriptions (
    Subscription_ID INT PRIMARY KEY,
    User_ID INT,
    Plan_ID INT,
    Start_Date DATE,
    End_Date DATE,
    Status VARCHAR(20)
);

INSERT INTO Fact_Subscriptions VALUES
(1001, 101, 1, '2025-01-10', '2025-04-10', 'Cancelled'),
(1002, 102, 3, '2025-01-15', NULL, 'Active'),
(1003, 103, 2, '2025-02-01', '2025-03-01', 'Cancelled'),
(1004, 104, 2, '2025-02-12', NULL, 'Active'),
(1005, 105, 1, '2025-03-03', NULL, 'Active');


-- ========================================================
-- ЧАСТЬ 2: МАРКЕТИНГОВАЯ И ПРОДУКТОВАЯ АНАЛИТИКА В SQL
-- ========================================================

-- Запрос 1: Первичный анализ и расчет базовых метрик (Количество, возраст, выручка)
SELECT 
    (SELECT COUNT(User_ID) FROM Dim_Users) AS Total_Users,
    (SELECT AVG(Age) FROM Dim_Users) AS Avg_Age,
    SUM(p.Monthly_Price) AS Total_Active_Revenue
FROM Fact_Subscriptions s
JOIN Dim_Plans p ON s.Plan_ID = p.Plan_ID
WHERE s.Status = 'Active';

-- Запрос 2: Анализ динамики доходов. Накопительный итог (Running Total) через Оконные функции
SELECT 
    u.Registration_Date,
    u.User_ID,
    p.Monthly_Price,
    SUM(p.Monthly_Price) OVER (ORDER BY u.Registration_Date) AS Running_Total_Revenue
FROM Dim_Users u
JOIN Fact_Subscriptions s ON u.User_ID = s.User_ID
JOIN Dim_Plans p ON s.Plan_ID = p.Plan_ID;

-- Запрос 3: Расчет бизнес-метрики оттока клиентов (Churn Rate) через условную агрегацию CASE WHEN
SELECT 
    COUNT(User_ID) AS Total_Customers,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Churned_Customers,
    (SUM(CASE WHEN Status = 'Cancelled' THEN 1.0 ELSE 0 END) / COUNT(User_ID)) * 100 AS Churn_Rate_Percent
FROM Fact_Subscriptions;
