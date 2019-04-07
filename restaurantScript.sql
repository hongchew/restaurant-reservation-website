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
    status boolean, --true means come already, false means haven't come
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
    comments varchar(50),
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
    RETURN NULL;
END IF;
RETURN NEW;
END;
$$
language plpgsql;


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
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('test1@gmail.com','GM1','password','GeneralManager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('test2@gmail.com','GM2','password','GeneralManager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('cust1@gmail.com','Cust1','password','Customer');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager1@gmail.com','Manager1','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager2@gmail.com','Manager2','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager3@gmail.com','Manager3','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager4@gmail.com','Manager4','password','Manager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager5@gmail.com','Manager5','password','Manager');


/*
Insert into Restaurant
*/
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('restaurant1','test1@gmail.com');
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('restaurant2','test2@gmail.com');

/*
Insert into Region
*/


Insert into RESTAURANT.Region(regionName) VALUES('North');
Insert into RESTAURANT.Region(regionName) VALUES('South');
Insert into RESTAURANT.Region(regionName) VALUES('East');
Insert into RESTAURANT.Region(regionName) VALUES('West');
Insert into RESTAURANT.Region(regionName) VALUES('Central');



/*
Insert into Branch
*/
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('restaurant1','Bedok','East','S123456','0800','2200','100', 'manager1@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('restaurant1','Simei','East','S123457','0800','2200','80', 'manager2@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('restaurant2','Yishun','North','S123459','0800','2200','30', 'manager3@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('restaurant2','Woodlands','North','S123451','1200','2200','30', 'manager4@gmail.com');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity, managerEmail) 
VALUES('restaurant1','Jurong','West','S123456','1900','2200','100', 'manager5@gmail.com');
/*
Insert into Manages
*/
--Insert into RESTAURANT.Manages (managerEmail, restaurantName, branchArea) VALUES ('manager1@gmail.com', 'restaurant1', 'Bedok');

/*
Insert into Meal Type
*/
Insert into RESTAURANT.MealType (mealTypeName) VALUES ('breakfast');
Insert into RESTAURANT.MealType (mealTypeName) VALUES ('lunch');
Insert into RESTAURANT.MealType (mealTypeName) VALUES ('dinner');

/*
Insert into Vacancy
*/
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('restaurant1', 'Bedok', 'breakfast', '2019-04-05', '200');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('restaurant1', 'Bedok', 'breakfast', '2019-03-05', '200');
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('restaurant1', 'Bedok', 'lunch', '2019-04-05', '200');

/*
Insert into Reservation
*/
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('restaurant1', 'Bedok', 'breakfast', '2019-04-05', 'cust1@gmail.com', '2', 'TRUE');
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('restaurant1', 'Bedok', 'breakfast', '2019-03-05', 'cust1@gmail.com', '2', 'TRUE');

INSERT INTO RESTAURANT.Cuisine values('Chinese'), ('Western'), ('Peranakan'), ('Indian'),('Drinks');

/*
Insert into Menu Item
*/

INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Bandung', '1.00', 'Drinks');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Chicken Rice', '4.00', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Ice Milo', '1.50', 'Drinks');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Hot Coffee', '0.90', 'Drinks');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Maggi Goreng', '5.00', 'Indian');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Laksa', '3.40', 'Chinese');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Chicken Chop', '9.80', 'Western');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Roti Prata (Plain)', '1.00', 'Indian');
INSERT INTO RESTAURANT.MenuItem (restaurantName, menuName, price, cuisineName) VALUES ('restaurant1', 'Roti Prata (Egg)', '1.50', 'Indian');

/*
Insert into Feedback
*/

INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('1','2','nice');
INSERT INTO RESTAURANT.Feedback(reservationId,rating,comments) VALUES('2','3','nicer');
