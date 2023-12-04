CREATE DATABASE IF NOT EXISTS `food_delivery` DEFAULT CHARACTER SET = 'utf8' DEFAULT COLLATE 'utf8_general_ci';
USE `food_delivery`;

# drop database food_delivery;
CREATE TABLE IF NOT EXISTS user
(
    id                int primary key auto_increment,
    first_name        varchar(50)  not null,
    last_name         varchar(50)  not null,
    birth_date        date         not null,
    phone             varchar(20),
    email             varchar(50)  not null unique,
    password          varchar(255) not null,
    user_kind         varchar(20)  not null,
    registration_date datetime default now()
);

CREATE TABLE IF NOT EXISTS customer
(
    id      int primary key auto_increment,
    user_id int not null,
    foreign key (user_id) references user (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS address
(
    id             int primary key auto_increment,
    street_address varchar(100) not null,
    city           varchar(50)  not null,
    state          varchar(50)  not null,
    postal_code    varchar(20)
);

CREATE TABLE IF NOT EXISTS customer_address
(
    id          int primary key auto_increment,
    customer_id int not null,
    address_id  int not null,
    foreign key (customer_id) references customer (id),
    foreign key (address_id) references address (id)
);

CREATE TABLE IF NOT EXISTS restaurant
(
    id         int primary key auto_increment,
    name       varchar(255) not null unique,
    address_id int          not null,
    foreign key (address_id) references address (id)
);

CREATE TABLE IF NOT EXISTS payer_information
(
    id               int primary key auto_increment,
    customer_id      int          not null,
    card_number      varchar(20)  not null,
    card_holder_name varchar(100) not null,
    expiration_date  date         not null,
    security_code    varchar(10)  not null,
    foreign key (customer_id) references customer (id)
);

CREATE TABLE IF NOT EXISTS product
(
    id            int primary key auto_increment,
    name          varchar(100) not null,
    description   text,
    price         decimal(4, 2),
    restaurant_id int          not null,
    foreign key (restaurant_id) references restaurant (id)
);

CREATE TABLE IF NOT EXISTS delivery_order
(
    id          int not null primary key auto_increment,
    customer_id int not null,
    address_id  int not null,
    restaurant_id int not null,
    order_date  datetime    default now(),
    status      varchar(20) default 'CREATED',
    rating      int         check ( rating is null || (rating >= 1 and rating <= 5 )),
    foreign key (customer_id) references customer (id),
    foreign key (address_id) references address (id),
    foreign key (restaurant_id) references restaurant (id)
);

CREATE TABLE IF NOT EXISTS order_item
(
    id         int primary key auto_increment,
    order_id   int not null,
    product_id int not null,
    quantity   int not null,
    foreign key (order_id) references delivery_order (id),
    foreign key (product_id) references product (id)
);

CREATE TABLE IF NOT EXISTS courier
(
    id             int primary key auto_increment,
    user_id        int         not null,
    license_number varchar(20) not null,
    foreign key (user_id) references user (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS route
(
    id         int primary key auto_increment,
    courier_id int not null,
    foreign key (courier_id) references courier (id)
);

CREATE TABLE IF NOT EXISTS route_order
(
    id       int primary key auto_increment,
    route_id int not null,
    order_id int not null,
    foreign key (route_id) references route (id),
    foreign key (order_id) references delivery_order (id)
);

CREATE TABLE IF NOT EXISTS order_status_log
(
    id         int primary key auto_increment,
    event_date datetime default now(),
    order_id   int         not null,
    status     varchar(20) not null,
    foreign key (order_id) references delivery_order (id)
);

CREATE TRIGGER order_status_log_insert
    AFTER INSERT
    ON delivery_order
    FOR EACH ROW
    INSERT INTO order_status_log (order_id, status)
    VALUES (NEW.id, NEW.status);

CREATE TRIGGER order_status_log_update
    AFTER UPDATE
    ON delivery_order
    FOR EACH ROW
    INSERT INTO order_status_log (order_id, status)
    VALUES (NEW.id, NEW.status);

################
##### DATA #####
################

-- Inserting addresses
INSERT INTO address (street_address, city, state, postal_code)
VALUES ('123 Main St', 'Cityville', 'Stateville', '12345'),
       ('456 Oak St', 'Townsville', 'Regionville', '54321'),
       ('789 Elm St', 'Villageton', 'Countyville', '67890'),
       ('101 Pine St', 'Metropolis', 'Provinceville', '24680'),
       ('222 Cedar St', 'Hamletville', 'Territoryville', '13579'),
       ('555 Maple St', 'Burgville', 'Districtville', '97531'),
       ('777 Walnut St', 'Townberg', 'Regionburg', '86420'),
       ('999 Oakwood St', 'Citytown', 'Stateland', '54321'),
       ('444 Birch St', 'Villageburg', 'Countyland', '13579'),
       ('888 Willow St', 'Hamletland', 'Territorytown', '98765'),
       ('333 Pinecrest St', 'Burgberg', 'Districttown', '36912'),
       ('666 Spruce St', 'Townville', 'Regiontown', '25874'),
       ('111 Cedarwood St', 'Cityberg', 'Statetown', '75319'),
       ('777 Oakhurst St', 'Villagetown', 'Countytown', '64237'),
       ('555 Elmwood St', 'Hamletville', 'Territorytown', '98123'),
       ('222 Maplewood St', 'Burgtown', 'Districttown', '45678'),
       ('888 Pinehurst St', 'Townland', 'Regiontown', '24680'),
       ('999 Birchwood St', 'Cityville', 'Stateville', '86420'),
       ('333 Willowwood St', 'Villagetown', 'Countyville', '53124'),
       ('111 Walnutwood St', 'Hamletland', 'Territoryland', '97531'),
       ('444 Cedarwood St', 'Burgtown', 'Districtland', '64237'),
       ('777 Sprucewood St', 'Townville', 'Regionland', '35791'),
       ('555 Oakcrest St', 'Citytown', 'Stateburg', '82649'),
       ('888 Maplehurst St', 'Villageland', 'Countyburg', '21473'),
       ('999 Pinecrest St', 'Hamletville', 'Territoryburg', '94678'),
       ('333 Cedarhurst St', 'Burgland', 'Districtville', '51924'),
       ('111 Elmwood St', 'Townland', 'Regionville', '79386'),
       ('444 Birchwood St', 'Cityville', 'Stateburg', '32819'),
       ('777 Willowhurst St', 'Villageland', 'Countyland', '64782');

-- Inserting customer users
INSERT INTO user (first_name, last_name, birth_date, phone, email, password, user_kind)
VALUES ('John', 'Doe', '1990-05-15', '+123456789', 'john@example.com', 'password123', 'customer'),
       ('Alice', 'Smith', '1985-09-20', '+987654321', 'alice@example.com', 'securepwd456', 'customer'),
       ('Bob', 'Johnson', '1995-02-10', '+111222333', 'bob@example.com', 'strongpwd789', 'customer'),
       ('Emma', 'Brown', '1988-11-25', '+444555666', 'emma@example.com', 'pwd1234', 'customer'),
       ('Michael', 'Davis', '1992-03-18', '+777888999', 'michael@example.com', 'pass9876', 'customer'),
       ('Sophia', 'Wilson', '1997-07-30', '+222333444', 'sophia@example.com', 'userpass', 'customer'),
       ('Olivia', 'Martinez', '1986-12-10', '+555666777', 'olivia@example.com', 'mypassword', 'customer'),
       ('Ethan', 'Anderson', '1993-09-05', '+999000111', 'ethan@example.com', 'secure123', 'customer'),
       ('Ava', 'Garcia', '1999-05-20', '+333444555', 'ava@example.com', 'passpass', 'customer'),
       ('William', 'Lopez', '1989-08-15', '+666777888', 'william@example.com', 'willpass', 'customer'),
       ('Mia', 'Harris', '1994-04-12', '+111222333', 'mia@example.com', 'miapwd', 'customer'),
       ('James', 'Miller', '1991-01-28', '+888999000', 'james@example.com', 'jamespass', 'customer'),
       ('Charlotte', 'Lee', '1996-06-22', '+444555666', 'charlotte@example.com', 'charpass', 'customer'),
       ('Benjamin', 'Clark', '1987-10-08', '+222333444', 'benjamin@example.com', 'benpass', 'customer'),
       ('Amelia', 'Taylor', '1998-02-14', '+777888999', 'amelia@example.com', 'amelia123', 'customer'),
       ('Lucas', 'Lewis', '1990-07-01', '+555666777', 'lucas@example.com', 'lucaspass', 'customer'),
       ('Harper', 'Adams', '1995-03-29', '+999000111', 'harper@example.com', 'harperpass', 'customer'),
       ('Evelyn', 'White', '1988-09-18', '+333444555', 'evelyn@example.com', 'evelynpwd', 'customer'),
       ('Alexander', 'Hall', '1997-12-05', '+666777888', 'alexander@example.com', 'alexpass', 'customer'),
       ('Daniel', 'Turner', '1992-04-23', '+111222333', 'daniel@example.com', 'danielpwd', 'customer');

-- Inserting customers
INSERT INTO customer (user_id)
VALUES (1),
       (2),
       (3),
       (4),
       (5),
       (6),
       (7),
       (8),
       (9),
       (10),
       (11),
       (12),
       (13),
       (14),
       (15),
       (16),
       (17),
       (18),
       (19),
       (20);

-- Inserting entries in customer_address table
INSERT INTO customer_address (customer_id, address_id)
VALUES (1, 1),
       (2, 2),
       (3, 3),
       (4, 4),
       (5, 5),
       (6, 6),
       (7, 7),
       (8, 8),
       (9, 9),
       (10, 10),
       (11, 11),
       (12, 12),
       (13, 13),
       (14, 14),
       (15, 15),
       (16, 16),
       (17, 17),
       (18, 18),
       (19, 19),
       (20, 20);

-- Inserting payments for customers
INSERT INTO payer_information (customer_id, card_number, card_holder_name, expiration_date, security_code)
VALUES (1, '1234567890123456', 'John Doe', '2025-10-01', '123'),
       (2, '9876543210987654', 'Alice Smith', '2024-12-01', '456'),
       (3, '1111222233334444', 'Bob Johnson', '2026-08-01', '789'),
       (4, '4444333322221111', 'Emma Brown', '2023-09-01', '234'),
       (5, '5555666677778888', 'Michael Davis', '2025-11-01', '567'),
       (6, '9999888877776666', 'Sophia Wilson', '2024-06-01', '890'),
       (7, '1111222233334444', 'Olivia Martinez', '2026-03-01', '123'),
       (8, '4444555566667777', 'Ethan Anderson', '2023-07-01', '456'),
       (9, '8888777766665555', 'Ava Garcia', '2025-09-01', '789'),
       (10, '2222333344445555', 'William Lopez', '2024-04-01', '234'),
       (11, '1212121212121212', 'Mia Harris', '2026-12-01', '567'),
       (12, '3434343434343434', 'James Miller', '2023-05-01', '890'),
       (13, '5656565656565656', 'Charlotte Lee', '2025-07-01', '123'),
       (14, '7878787878787878', 'Benjamin Clark', '2024-11-01', '456'),
       (15, '9898989898989898', 'Amelia Taylor', '2026-02-01', '789'),
       (16, '2323232323232323', 'Lucas Lewis', '2023-10-01', '234'),
       (17, '4545454545454545', 'Harper Adams', '2025-01-01', '567'),
       (18, '6767676767676767', 'Evelyn White', '2024-08-01', '890'),
       (19, '7979797979797979', 'Alexander Hall', '2026-04-01', '123'),
       (20, '9898989898989898', 'Daniel Turner', '2023-06-01', '456');

-- Inserting users as couriers
INSERT INTO user (first_name, last_name, birth_date, phone, email, password, user_kind)
VALUES ('David', 'Wilson', '1993-08-21', '+123456789', 'david@example.com', 'pwd1234', 'courier'),
       ('Sophie', 'Garcia', '1990-11-17', '+987654321', 'sophie@example.com', 'securepwd456', 'courier'),
       ('Oliver', 'Brown', '1987-04-29', '+111222333', 'oliver@example.com', 'strongpwd789', 'courier'),
       ('Grace', 'Miller', '1995-02-12', '+444555666', 'grace@example.com', 'pwd1234', 'courier'),
       ('Aiden', 'Taylor', '1998-06-06', '+777888999', 'aiden@example.com', 'pass9876', 'courier'),
       ('Chloe', 'Anderson', '1991-09-30', '+222333444', 'chloe@example.com', 'userpass', 'courier'),
       ('Elijah', 'Martinez', '1996-03-14', '+555666777', 'elijah@example.com', 'mypassword', 'courier'),
       ('Lily', 'Harris', '1994-07-27', '+999000111', 'lily@example.com', 'secure123', 'courier'),
       ('Lucy', 'Clark', '1989-12-03', '+333444555', 'lucy@example.com', 'passpass', 'courier'),
       ('Leo', 'Turner', '1992-10-08', '+666777888', 'leo@example.com', 'willpass', 'courier');

-- Inserting 10 couriers
INSERT INTO courier (user_id, license_number)
VALUES (21, 'AB123456'),
       (22, 'CD789012'),
       (23, 'EF345678'),
       (24, 'GH901234'),
       (25, 'IJ567890'),
       (26, 'KL123456'),
       (27, 'MN789012'),
       (28, 'OP345678'),
       (29, 'QR901234'),
       (30, 'ST567890');

-- Inserting unique addresses for restaurants
INSERT INTO address (street_address, city, state, postal_code)
VALUES ('321 Cherry Ln', 'Villageville', 'Countyshire', '54321'),
       ('456 Apple Ave', 'Orangetown', 'Fruitburg', '12345'),
       ('789 Lemon St', 'Citrusville', 'Juiceburg', '67890'),
       ('101 Pineapple Rd', 'Tropical City', 'Exotictown', '24680'),
       ('222 Watermelon Dr', 'Melonville', 'Fruitland', '13579'),
       ('555 Mango Blvd', 'Juicetown', 'Citrusland', '97531'),
       ('777 Grapevine Ln', 'Wineville', 'Vinetown', '86420'),
       ('999 Olive St', 'Oilburg', 'Greenville', '54321'),
       ('444 Berry Ave', 'Berrytown', 'Fruitland', '13579'),
       ('888 Banana Dr', 'Banana City', 'Tropicalburg', '98765'),
       ('333 Plum Ln', 'Plumtown', 'Fruitville', '36912'),
       ('666 Pomegranate Rd', 'Pomeland', 'Fruitland', '25874'),
       ('111 Avocado Blvd', 'Avocadoville', 'Guacamoleburg', '75319'),
       ('777 Papaya St', 'Papayaland', 'Tropicalburg', '64237'),
       ('555 Cranberry Ave', 'Cranberrytown', 'Berryland', '98123'),
       ('222 Blueberry Ln', 'Blueberryville', 'Fruitland', '45678'),
       ('888 Kiwi Dr', 'Kiwitown', 'Tropicalburg', '24680'),
       ('999 Dragon Fruit Rd', 'Dragonfruit City', 'Exotictown', '86420'),
       ('333 Persimmon Ave', 'Persimmontown', 'Fruitland', '53124'),
       ('111 Lychee St', 'Lycheetown', 'Exotictown', '97531');

-- Inserting restaurants with unique addresses
INSERT INTO restaurant (name, address_id)
VALUES ('Savory Bites', 21),
       ('Flavorsome Grills', 22),
       ('Zesty Zings', 23),
       ('Seasoned Eats', 24),
       ('Fresh Harvest Cafe', 25),
       ('Crispy Crust', 26),
       ('Bun N Patty', 27),
       ('Pizzeria Italia', 28),
       ('Wok & Roll', 29),
       ('Barbecue Bay', 30),
       ('Sashimi Spot', 31),
       ('Deliicious Delights', 32),
       ('Wrap It Up', 33),
       ('Fried Feast', 34),
       ('Vegetarian Delight', 35),
       ('Seaside Seafood', 36),
       ('Sweet Tooth Treats', 37),
       ('Juicy Junction', 38),
       ('Tropical Temptations', 39),
       ('Berry Blast Cafe', 40);

-- Inserting products for restaurants
INSERT INTO product (name, description, price, restaurant_id)
VALUES ('Cheeseburger', 'Juicy beef patty with cheese', 8.99, 1),
       ('Margherita Pizza', 'Classic pizza with tomato and mozzarella', 10.99, 2),
       ('Chicken Teriyaki', 'Grilled chicken in teriyaki sauce', 12.50, 3),
       ('Spicy Tofu Stir-fry', 'Tofu and vegetables in spicy sauce', 9.99, 4),
       ('Caesar Salad', 'Fresh romaine lettuce with Caesar dressing', 7.99, 5),
       ('Pepperoni Pizza', 'Pizza with spicy pepperoni slices', 11.50, 6),
       ('Classic Burger', 'Traditional beef burger with lettuce and tomato', 9.50, 7),
       ('Pesto Pasta', 'Pasta in basil pesto sauce', 10.99, 8),
       ('Crispy Fried Chicken', 'Golden-fried chicken pieces', 8.99, 9),
       ('Taco Trio', 'Assorted tacos with various fillings', 13.50, 10),
       ('Pad Thai', 'Thai stir-fried noodles with peanuts', 11.99, 11),
       ('Smoked Ribs', 'Slow-cooked smoked pork ribs', 15.99, 12),
       ('Sashimi Platter', 'Assorted fresh raw fish slices', 18.50, 13),
       ('Deli Sandwich', 'Assorted deli meats in a sandwich', 9.99, 14),
       ('Veggie Wrap', 'Wrap filled with assorted vegetables', 7.50, 15),
       ('Popcorn Chicken', 'Crispy bite-sized chicken pieces', 6.99, 16),
       ('Caprese Salad', 'Fresh tomatoes, mozzarella, and basil', 8.50, 17),
       ('Grilled Fish', 'Freshly grilled fish fillet', 12.99, 18),
       ('Chocolate Brownie', 'Rich chocolate brownie with nuts', 5.99, 19),
       ('Fresh Fruit Juice', 'Assorted fresh fruit juice', 4.50, 20),
       ('Veggie Pizza', 'Pizza loaded with assorted veggies', 10.50, 1),
       ('Sushi Combo', 'Assorted sushi rolls and nigiri', 16.50, 2),
       ('Steak Frites', 'Juicy steak with crispy fries', 19.99, 3),
       ('Vegetable Curry', 'Assorted vegetables in curry sauce', 11.50, 4),
       ('Greek Salad', 'Salad with feta cheese and olives', 8.99, 5),
       ('BBQ Chicken Pizza', 'Pizza with BBQ chicken topping', 12.50, 6),
       ('Fish Burger', 'Burger made with grilled fish fillet', 10.99, 7),
       ('Lasagna', 'Layered pasta dish with meat and cheese', 13.99, 8),
       ('Mango Sticky Rice', 'Thai dessert with mango and sticky rice', 6.50, 9),
       ('Quesadilla', 'Mexican dish with cheese and fillings', 9.50, 10);


-- Inserting 50 delivery orders with different statuses and order dates
INSERT INTO delivery_order (customer_id, restaurant_id, address_id, order_date, status)
VALUES
    -- Orders in CREATED state with order_date equal to NOW()
    (1, 1, 1, now(), 'CREATED'),
    (2, 2, 2, now(), 'CREATED'),
    (3, 3, 3, now(), 'CREATED'),
    (4, 4, 4, now(), 'CREATED'),
    (5, 5, 5, now(), 'CREATED'),
    (6, 6, 6, now(), 'CREATED'),
    (7, 7, 7, now(), 'CREATED'),
    (8, 8, 8, now(), 'CREATED'),
    (9, 9, 9, now(), 'CREATED'),
    (10, 10, 10, now(), 'CREATED'),
    (11, 11, 11, now(), 'CREATED'),
    (12, 12, 12, now(), 'CREATED'),
    (13, 13, 13, now(), 'CREATED'),
    (14, 1, 14, now(), 'CREATED'),
    (15, 2, 15, now(), 'CREATED'),
    (16, 3, 16, now(), 'CREATED'),
    (17, 4, 17, now(), 'CREATED'),
    (18, 5, 18, now(), 'CREATED'),
    (19, 1, 19, now(), 'CREATED'),
    (20, 1, 20, now(), 'CREATED'),

    -- Remaining orders with statuses COMPLETED or CANCELED
    (1, 19, 1, '2023-07-18', 'COMPLETED'),
    (2, 20, 2, '2022-11-11', 'CANCELED'),
    (3, 2, 3, '2023-08-19', 'COMPLETED'),
    (4, 1, 4, '2021-09-11', 'CANCELED'),
    (5, 3, 5, '2019-03-30', 'COMPLETED'),
    (6, 4, 6, '2023-02-28', 'COMPLETED'),
    (7, 5, 7, '2019-12-25', 'CANCELED'),
    (8, 6, 8, '2022-06-28', 'COMPLETED'),
    (9, 7, 9, '2019-03-12', 'CREATED'),
    (10, 8, 10, '2019-01-06', 'COMPLETED'),

    -- Adding more orders in COMPLETED or CANCELED states
    (11, 9, 11, '2021-03-11', 'CANCELED'),
    (12, 10, 12, '2022-02-28', 'COMPLETED'),
    (13, 11, 13, '2023-01-25', 'COMPLETED'),
    (14, 12, 14, '2022-08-02', 'CANCELED'),
    (15, 13, 15, '2019-12-17', 'COMPLETED'),
    (16, 14, 16, '2022-05-05', 'CANCELED'),
    (17, 15, 17, '2023-10-25', 'COMPLETED'),
    (18, 16, 18, '2023-12-31', 'COMPLETED'),
    (19, 20, 19, '2021-04-01', 'CANCELED'),
    (20, 1, 1, '1019-10-07', 'COMPLETED');


###############
### QUERIES ###
###############

-- Inserting order items for the existing delivery orders with a maximum of 3 items per order
-- The product_id is randomly picked from the products of the restaurant
INSERT INTO order_item (order_id, product_id, quantity)
SELECT o.id       AS order_id,
       (select p.id from product p where p.restaurant_id = o.restaurant_id order by rand() limit 1) AS product_id, -- pick random products from the restaurant
       1 + FLOOR(RAND() * (3)) AS quantity    -- Random number between 1 and 3
FROM delivery_order o
ORDER BY RAND()
LIMIT 50;

-- Create random ratings for 8 orders with status COMPLETED
-- We're rating only 8 orders because of the question #5 of the PDF
UPDATE delivery_order
SET rating = 1 + FLOOR(RAND() * 5)
WHERE status = 'COMPLETED'
limit 8;

INSERT INTO route (courier_id)
VALUES (1),
       (1),
       (1),
       (2),
       (3),
       (3),
       (4),
       (5),
       (6),
       (7),
       (7),
       (8),
       (9),
       (10);

INSERT INTO route_order (route_id, order_id)
VALUES (1, 1),
       (1, 2),
       (11, 3),
       (1, 4),
       (1, 5),
       (2, 6),
       (2, 7),
       (2, 8),
       (12, 9),
       (2, 10),
       (3, 11),
       (3, 12),
       (3, 13),
       (3, 14),
       (13, 15),
       (4, 16),
       (4, 17),
       (4, 18),
       (4, 19),
       (14, 20),
       (5, 21),
       (5, 22),
       (5, 23),
       (5, 24),
       (5, 25),
       (6, 26),
       (6, 27),
       (6, 28),
       (6, 29),
       (6, 30),
       (7, 31),
       (7, 32),
       (7, 33),
       (7, 34),
       (7, 35),
       (8, 36),
       (8, 37),
       (8, 38),
       (9, 39),
       (10, 40);

# Update 2 orders to COMPLETED to test trigger
UPDATE delivery_order
set status = 'COMPLETED'
WHERE status = 'CREATED'
limit 2;

# Update 2 orders to COMPLETED to test trigger
UPDATE delivery_order
set status = 'CANCELED'
WHERE status = 'CREATED'
limit 2;

# Query for log table to check the behavior of the trigger
SELECT * from order_status_log;

# 1. List all the customer’s names, dates, and products or services used/booked/rented/bought by
# these customers in a range of two dates.
select CONCAT(u.first_name, ' ', u.last_name) as 'customer name',
       o.order_date                           as 'order date',
       p.name                                 as 'product name'
from user u
         join customer c on u.id = c.user_id
         join delivery_order o on c.id = o.customer_id
         join order_item oi on o.id = oi.order_id
         join product p on oi.product_id = p.id
where o.order_date between '2021-01-01' and '2023-05-01';

# 2. List the best three customers/products/services/places (you are free to define the criteria for
# what means “best”)

# Query best consumers (top 3) by total amount spent.
# Cancelled orders are not included in the calculation.
select CONCAT(u.first_name, ' ', u.last_name) as 'customer name',
       sum(p.price * oi.quantity) as 'amount spent' from user u
join customer c on u.id = c.user_id
join delivery_order o on c.id = o.customer_id
join order_item oi on o.id = oi.order_id
join product p on oi.product_id = p.id
where o.status != 'CANCELED'
group by u.id, u.first_name
order by `amount spent` desc
limit 3;

# Query best restaurants (top 3) by total amount sold
# Cancelled orders are not included in the calculation.
select r.name as 'restaurant name',
       sum(p.price * oi.quantity) as 'amount sold'
from restaurant r
join product p on r.id = p.restaurant_id
join order_item oi on p.id = oi.product_id
join delivery_order o on oi.order_id = o.id
where o.status != 'CANCELED'
group by r.id, r.name
order by `amount sold` desc
limit 3;

# Query best couriers (top 3) by total routes
# Here we are counting also routes with canceled orders because
# we want to know how many routes a courier has been assigned to
select c.id, CONCAT(u.first_name, ' ', u.last_name) as 'courier name', count(distinct r.id) as 'total routes'
from courier c
join user u on c.user_id = u.id
join route r on c.id = r.courier_id
group by c.id
order by `total routes` desc
limit 3;

# Query best products (top 3) by number of orders
select p.name as 'product name', count(distinct oi.order_id) as 'total orders'
from product p
join order_item oi on p.id = oi.product_id
group by p.id
order by `total orders` desc
limit 3;

# 3. Get the average amount of sales/bookings/rents/deliveries for a period that involves 2 or more
# years, as in the following example. This query only returns one record:
# this question is missing as I don't understand what is being asked
TODO

# 4. Get the total sales/bookings/rents/deliveries by geographical location (city/country)
select a.city, sum(p.price * oi.quantity) as 'total sales'
from address a
join customer_address ca on a.id = ca.address_id
join customer c on ca.customer_id = c.id
join delivery_order o on c.id = o.customer_id
join order_item oi on o.id = oi.order_id
join product p on oi.product_id = p.id
where o.status != 'CANCELED'
group by a.city
order by `total sales` desc;

#G Creating views

CREATE VIEW invoice_head_totals AS
SELECT
    o.id AS order_id,
    u.first_name AS customer_first_name,
    u.last_name AS customer_last_name,
    u.email AS customer_email,
    CONCAT(a.street_address, ', ', a.city, ', ', a.state, ', ', a.postal_code) AS delivery_full_address,
    r.name AS restaurant_name,
    CONCAT(ad.street_address, ', ', ad.city, ', ', ad.state, ', ', ad.postal_code) AS restaurant_full_address,
    o.order_date,
    SUM(oi.quantity * p.price) AS total_amount
FROM
    delivery_order o
JOIN customer c ON o.customer_id = c.id
JOIN user u ON u.id = c.user_id 
JOIN address a ON o.address_id = a.id
JOIN restaurant r ON o.restaurant_id = r.id
JOIN address ad ON r.address_id = ad.id
JOIN order_item oi ON o.id = oi.order_id
JOIN product p ON oi.product_id = p.id
WHERE o.status != 'CANCELED'
GROUP BY
    1,2,3,4,5,6,7;
   

CREATE VIEW invoice_details AS
SELECT
    o.id AS order_id,
    p.name AS product_name,
    p.description AS product_description,
    oi.quantity,
    p.price AS unit_price,
    oi.quantity * p.price AS total_price
FROM
    delivery_order o
JOIN order_item oi ON o.id = oi.order_id
JOIN product p ON oi.product_id = p.id
WHERE o.status != 'CANCELED';