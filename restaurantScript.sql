DROP SCHEMA RESTAURANT CASCADE;
CREATE SCHEMA RESTAURANT;

CREATE TABLE RESTAURANT.Users
(
    email varchar(50) primary key,
    name varchar(50) NOT NULL,
    password varchar(50) NOT NULL,
    accountType varchar(50) NOT NULL
);

CREATE TABLE RESTAURANT.Manager (
    managerEmail varchar(50) PRIMARY KEY references RESTAURANT.Users(email) on delete cascade
);

CREATE TABLE RESTAURANT.GeneralManager(
    generalManagerEmail varchar(50) PRIMARY KEY references RESTAURANT.Users(email) on delete cascade
    -- restaurantName varchar(50) references RESTAURANT.Restaurant(restaurantName)
);

CREATE TABLE RESTAURANT.Admin (
    adminEmail varchar(50) PRIMARY KEY references RESTAURANT.Users(email) on delete cascade
);

CREATE TABLE RESTAURANT.Customer (
    customerEmail varchar(50) PRIMARY KEY references RESTAURANT.Users(email) on delete cascade
);

CREATE TABLE RESTAURANT.Restaurant
(
    restaurantName varchar(50) primary key,
    generalManagerEmail varchar(50) REFERENCES RESTAURANT.GeneralManager(generalManagerEmail),
    avgPrice NUMERIC(7,2) DEFAULT '0'   
);

CREATE TABLE RESTAURANT.Cuisine
(
    cuisineName VARCHAR(50) primary key
);

CREATE TABLE RESTAURANT.MenuItem
(
    restaurantName varchar(50) references RESTAURANT.Restaurant(restaurantName) ON DELETE CASCADE,
    menuName varchar(50),
    price NUMERIC(7,2) NOT NULL,
    cuisineName varchar(50) references RESTAURANT.Cuisine(cuisineName),
    primary key(restaurantName, menuName)
);

CREATE TABLE RESTAURANT.Region(
    regionName varchar(50) PRIMARY KEY
);  

CREATE TABLE RESTAURANT.Branch
(
    restaurantName varchar(50) references RESTAURANT.Restaurant ON DELETE CASCADE,
    branchArea varchar(50),
    regionName varchar(50) references RESTAURANT.Region(regionName) on delete cascade, 
    managerEmail varchar(50) references RESTAURANT.Manager(managerEmail),
    address varchar(50),
    openingHour integer,
    closingHour integer,
    capacity integer,
    rating NUMERIC(2,1) default '0',
    PRIMARY KEY(restaurantName, branchArea)
);

CREATE TABLE RESTAURANT.Bookmark
(
    customerEmail varchar(50) references RESTAURANT.Customer(customerEmail) ON DELETE CASCADE,    
    restaurantName varchar(50),
    branchArea varchar(50),
    PRIMARY KEY(customerEmail, restaurantName, branchArea),
    foreign key (branchArea,restaurantName) references RESTAURANT.Branch(branchArea, restaurantName) ON DELETE CASCADE
);

CREATE TABLE RESTAURANT.MealType(
    mealTypeName varchar(50) primary key
); 

CREATE TABLE RESTAURANT.Vacancy
(
    restaurantName varchar(50),
    branchArea varchar(50),
    mealTypeName varchar(50) references RESTAURANT.MealType(mealTypeName) on delete cascade,
    vacancyDate date,
    vacancy integer,
    PRIMARY KEY(restaurantName,branchArea, mealTypeName, vacancyDate),
    FOREIGN KEY(restaurantName, branchArea) REFERENCES RESTAURANT.branch(restaurantName, branchArea)
);

CREATE TABLE RESTAURANT.Reservation
(
    reservationId SERIAL PRIMARY KEY,
    restaurantName varchar(50),
    branchArea varchar(50),
    mealTypeName varchar(50),
    vacancyDate date,
    customerEmail varchar(50) NOT NULL references RESTAURANT.Customer(customerEmail) on delete cascade,
    numDiner integer NOT NULL,
    status integer, --(-1 = no show, 0 = not fulfilled, 1 = fulfilled)
    check(numDiner > 0),
    -- check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner'),
    FOREIGN KEY(restaurantName, branchArea, mealTypeName, vacancyDate) references RESTAURANT.Vacancy(restaurantName, branchArea, mealTypeName, vacancyDate)
);

--Does not capture the constraint that one reservation only can have one feedback
CREATE TABLE RESTAURANT.Feedback
(
    feedbackId SERIAL PRIMARY KEY,
    reservationId integer NOT NULL,
    rating NUMERIC(2,1) default '0',
    comments varchar(250),
    foreign key(reservationId) references RESTAURANT.Reservation(reservationId) ON DELETE CASCADE,
    CHECK(rating >= 0.0 and rating <= 5.0)
);
--Slots into corresponding table based on user type--
CREATE OR REPLACE FUNCTION accountTypeUpdate()
    RETURNS trigger AS
$$
BEGIN 
if new.accountType = 'Customer' THEN
    insert into RESTAURANT.customer VALUES (new.email);
    elsif new.accountType='GeneralManager' THEN
        insert into RESTAURANT.GeneralManager VALUES (new.email);
    elsif new.accountType='Admin' THEN
        insert into RESTAURANT.Admin VALUES (new.email);
    elsif new.accountType='Manager' THEN
        insert into RESTAURANT.Manager VALUES (new.email);
end if;
return new;
END;
$$
language plpgsql;

--Create new vacancy instancy if new reservation of the day--
CREATE OR REPLACE FUNCTION new_reservation_OTD()
    RETURNS trigger AS
$$
DECLARE bArea varchar;
        capacity1 integer;
        branchCapacity integer;
BEGIN
SELECT branchArea into bArea
FROM RESTAURANT.Vacancy v
WHERE v.restaurantName = NEW.restaurantName and v.branchArea = NEW.branchArea and v.mealTypeName = NEW.mealTypeName and v.vacancyDate = NEW.vacancyDate;--check if vacancy instance created--
SELECT v.vacancy into capacity1
FROM RESTAURANT.Vacancy v
WHERE v.restaurantName = NEW.restaurantName and v.branchArea = NEW.branchArea and v.mealTypeName = NEW.mealTypeName and v.vacancyDate = NEW.vacancyDate; --get capacity of branch--
SELECT capacity into branchCapacity
FROM RESTAURANT.Branch b
WHERE b.restaurantName = NEW.restaurantName and b.branchArea = NEW.branchArea;
IF ((bArea IS NULL)) THEN
    Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancyDate, vacancy) VALUES (NEW.restaurantName, NEW.branchArea, NEW.mealTypeName, NEW.vacancyDate, branchCapacity-NEW.numDiner);
    elsif (capacity1 >= NEW.numDiner) THEN
    update RESTAURANT.Vacancy SET vacancy = vacancy - new.numdiner 
    WHERE restaurantName = NEW.restaurantName and branchArea = NEW.branchArea and mealTypeName = NEW.mealTypeName and vacancyDate = NEW.vacancyDate;--check if vacancy instance created--
    elsif (capacity1 < NEW.numDiner) THEN
    RAISE EXCEPTION 'Resturant has been fully reserved on that day. Reservation UNSUCCESSFUL';
END IF;
RETURN NEW;
END;
$$
language plpgsql;

--Calculates the new Average Price--
CREATE OR REPLACE FUNCTION calAvgPrice()
RETURNS TRIGGER AS
$$
DECLARE initialTotalPrice NUMERIC(7,2);
BEGIN
SELECT coalesce(sum(price),0) INTO initialTotalPrice
FROM RESTAURANT.MenuItem m
WHERE m.restaurantName = new.restaurantName;
UPDATE RESTAURANT.Restaurant
SET avgPrice = (initialTotalPrice+new.price)/
(SELECT count(*)+1 
FROM RESTAURANT.MenuItem m 
WHERE m.restaurantName = new.restaurantName)
WHERE restaurantname = new.restaurantName;

RETURN NEW;
END;    
$$
language plpgsql;

CREATE OR REPLACE FUNCTION calculateNewRating()
RETURNS trigger AS
$$
DECLARE newRating NUMERIC(2,1);
        bArea varchar;
        rName varchar;
BEGIN
SELECT r.restaurantName, r.branchArea, COALESCE(AVG(f.rating),0) INTO rName, bArea, newRating
FROM RESTAURANT.Reservation r 
JOIN RESTAURANT.Feedback f 
ON f.reservationId = r.reservationId
GROUP BY (r.restaurantName, r.branchArea);
UPDATE RESTAURANT.Branch 
SET rating = newRating
WHERE branchArea = bArea and restaurantName = rName;
RETURN NEW;
END;
$$
language plpgsql;


--TRIGGERS--
CREATE TRIGGER newUserInsertedTrigger
AFTER INSERT ON RESTAURANT.Users
for each row
execute procedure accountTypeUpdate();

CREATE TRIGGER newVacancy
BEFORE INSERT ON RESTAURANT.Reservation
for each row
EXECUTE PROCEDURE new_reservation_OTD();

CREATE TRIGGER avgPrice
BEFORE INSERT OR UPDATE ON RESTAURANT.MenuItem
for each row
EXECUTE PROCEDURE calAvgPrice();

CREATE TRIGGER updateAverageRating
AFTER INSERT OR UPDATE ON RESTAURANT.Feedback
for each row
EXECUTE PROCEDURE calculateNewRating();

/*
Insert into User
*/
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('admin@gmail.com','admin','password','Admin');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('generalmanager1@gmail.com','GM1','password','GeneralManager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('generalmanager2@gmail.com','GM2','password','GeneralManager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('generalmanager3@gmail.com','GM3','password','GeneralManager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('cust1@gmail.com','Cust1','password','Customer');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('cust2@gmail.com','Cust1','password','Customer');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager1@gmail.com','Manager1','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager2@gmail.com','Manager2','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager3@gmail.com','Manager3','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager4@gmail.com','Manager4','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager5@gmail.com','Manager5','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager6@gmail.com','Manager3','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager7@gmail.com','Manager4','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager8@gmail.com','Manager5','password','Manager');


/*
Insert into Restaurant
*/
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('Singapore Special','generalmanager1@gmail.com');
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('Special23','generalmanager2@gmail.com');
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('House Of Seafood','generalmanager3@gmail.com');


/*
Insert into Region
*/


Insert into RESTAURANT.Region(regionName) VALUES('North');
Insert into RESTAURANT.Region(regionName) VALUES('South');
Insert into RESTAURANT.Region(regionName) VALUES('East');
Insert into RESTAURANT.Region(regionName) VALUES('West');
Insert into RESTAURANT.Region(regionName) VALUES('Central');

/*
Insert into Meal Type
*/
Insert into RESTAURANT.MealType (mealTypeName) VALUES ('Breakfast');
Insert into RESTAURANT.MealType (mealTypeName) VALUES ('Lunch');
Insert into RESTAURANT.MealType (mealTypeName) VALUES ('Dinner');



/*
Insert into Branch
*/
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('Singapore Special','Bedok','East','S123456','0800','2200','100', 'manager1@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('Singapore Special','Simei','East','S123457','0800','2130','80', 'manager2@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('Singapore Special','Jurong','West','S123456','1900','2200','100', 'manager5@gmail.com');

Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('Special23','Yishun','North','S123459','1100','2300','30', 'manager3@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('Special23','Woodlands','North','S123451','1200','2200','60', 'manager4@gmail.com');


Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('House Of Seafood','Harbourfront','South','S232010','1100','2300','120', 'manager6@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('House Of Seafood','Plaza Singapura','Central','S193021','1100','2300','60', 'manager7@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('House Of Seafood','Novena','Central','S092140','1700','2300','70', 'manager8@gmail.com');

/*
Insert into Vacancy
*/
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('Singapore Special', 'Bedok', 'Breakfast', '2019-04-20', '100');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('Singapore Special', 'Bedok', 'Breakfast', '2019-03-21', '100');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('Singapore Special', 'Simei', 'Lunch', '2019-04-20', '80');

Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('Special23', 'Yishun', 'Lunch', '2019-04-22', '30');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('Special23', 'Woodlands', 'Lunch', '2019-03-20', '60');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('Special23', 'Yishun', 'Lunch', '2019-04-23', '30');

Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('House Of Seafood', 'Harbourfront', 'Breakfast', '2019-04-05', '120');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('House Of Seafood', 'Plaza Singapura', 'Breakfast', '2019-03-05', '60');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('House Of Seafood', 'Novena', 'Lunch', '2019-04-05', '70');

/*
Insert into Reservation
*/
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Singapore Special', 'Bedok', 'Breakfast', '2019-04-20', 'cust1@gmail.com', '4', '0');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('House Of Seafood', 'Harbourfront', 'Lunch', '2019-03-21', 'cust1@gmail.com', '8', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('House Of Seafood', 'Harbourfront', 'Dinner', '2019-03-11', 'cust1@gmail.com', '4', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Singapore Special', 'Jurong', 'Dinner', '2019-04-06', 'cust1@gmail.com', '7', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Singapore Special', 'Jurong', 'Dinner', '2019-04-08', 'cust1@gmail.com', '2', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('House Of Seafood', 'Harbourfront', 'Dinner', '2019-04-20', 'cust1@gmail.com', '10', '0');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('House Of Seafood', 'Novena', 'Dinner', '2019-04-22', 'cust1@gmail.com', '2', '0');

INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Singapore Special', 'Simei', 'Lunch', '2019-04-25', 'cust2@gmail.com', '4', '0');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Special23', 'Yishun', 'Dinner', '2019-03-17', 'cust2@gmail.com', '4', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Special23', 'Yishun', 'Lunch', '2019-03-24', 'cust2@gmail.com', '6', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Singapore Special', 'Bedok', 'Breakfast', '2019-03-27', 'cust2@gmail.com', '11', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Singapore Special', 'Bedok', 'Lunch', '2019-03-21', 'cust2@gmail.com', '9', '1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Singapore Special', 'Jurong', 'Dinner', '2019-03-10', 'cust2@gmail.com', '12', '-1');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Special23', 'Woodlands', 'Dinner', '2019-04-27', 'cust2@gmail.com', '15', '0');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('Special23', 'Yishun', 'Dinner', '2019-04-28', 'cust2@gmail.com', '5', '0');



INSERT INTO RESTAURANT.Cuisine values('Chinese'), ('Western'), ('Peranakan'), ('Indian'),('Drinks / Dessert');

/*
Insert into Menu Item
*/

INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Bandung', '1.00', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Chicken Rice', '4.00', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Ice Milo', '1.50', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Hot Coffee', '0.90', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Maggi Goreng', '5.00', 'Indian');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Laksa', '3.40', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Chicken Chop', '9.80', 'Western');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Roti Prata (Plain)', '1.00', 'Indian');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Singapore Special', 'Roti Prata (Egg)', '1.50', 'Indian');

INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Ice Lemon Tea', '1.80', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Chicken Rice', '4.50', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Ice Milo', '1.50', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Hot Coffee', '1.10', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Maggi Goreng', '4.80', 'Indian');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Laksa', '3.40', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Chicken Cutlet', '9.20', 'Western');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Fishball Noodle', '3.80', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('Special23', 'Murtabak', '7.00', 'Indian');

INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Ice Lemon Tea', '2.50', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Fish n Chips', '12.30', 'Western');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Vanilla Milkshake', '4.80', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Chocolate Ice Blended', '4.50', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Chilli Crab (1kg)', '48.00', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Banana Split Ice-Cream', '10.50', 'Drinks / Dessert');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Grilled Crayish', '16.80', 'Western');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Softshell Crab Spaghetti', '14.20', 'Western');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('House Of Seafood', 'Seafood Aglio Olio', '13.00', 'Western');


/*
Insert into Feedback
*/
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('2','3','Staffs are not very attentive.');
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('3','4','Food is nice and pleasant ambience.');
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('4','4','Dinner was actually not too bad.');
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('8','3','Dinner was okay. Food a litter pricey.');
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('9','2','Food does''t really suit my taste.');
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('10','5','Very nice local food. Will bring my friend here in future to eat.');
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('11','2','Staff aren''t very attentive and not clear of what is on the menu. Maybe just a temporary staff but manager could have trained them better.');

