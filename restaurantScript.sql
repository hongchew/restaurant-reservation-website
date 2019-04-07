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
    generalManagerEmail varchar(50) REFERENCES RESTAURANT.GeneralManager(generalManagerEmail) 
);

CREATE TABLE RESTAURANT.Cuisine
(
    cuisineName VARCHAR(50) primary key
);

CREATE TABLE RESTAURANT.MenuItem
(
    restaurantName varchar(50) references RESTAURANT.Restaurant(RestaurantName) ON DELETE CASCADE,
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
    address varchar(50),
    openingHour integer,
    closingHour integer,
    capacity integer,
    PRIMARY KEY(restaurantName, branchArea)
);

CREATE TABLE RESTAURANT.Manages(
    managerEmail varchar(50) references RESTAURANT.Manager(managerEmail) on delete cascade,
    restaurantName varchar(50),
    branchArea varchar(50),
    PRIMARY KEY(managerEmail, restaurantName, branchArea),
    FOREIGN KEY (restaurantName, branchArea) references RESTAURANT.Branch(restaurantName, branchArea) on DELETE CASCADE
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
    rating NUMERIC(2,1) default 0,
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
end;
$$
language plpgsql;

--Create new vacancy instancy if new reservation of the day--
CREATE OR REPLACE FUNCTION new_reservation_OTD()
    RETURNS trigger AS
$$
DECLARE bArea varchar;
        capacity1 integer;
BEGIN
SELECT branchArea into bArea
FROM RESTAURANT.Vacancy v
WHERE v.restaurantName = NEW.restaurantName and v.branchArea = NEW.branchArea and v.mealTypeName = NEW.mealTypeName and v.vacancyDate = NEW.vacancyDate;--check if vacancy instance created--
SELECT capacity into capacity1
FROM RESTAURANT.Branch
WHERE NEW.restaurantName = restaurantName and NEW.branchArea = branchArea; --get capacity of branch--
IF (bArea IS NULL) THEN
    Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancyDate, vacancy) VALUES (NEW.restaurantName, NEW.branchArea, NEW.mealTypeName, NEW.vacancyDate, capacity1 );
END IF;
RETURN NEW;
end;
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



/*
Insert into User
*/
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('test1@gmail.com','GM1','password','GeneralManager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('test2@gmail.com','GM2','password','GeneralManager');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('cust1@gmail.com','Cust1','password','Customer');
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('manager1@gmail.com','Manager1','password','Manager');



/*
Insert into Restaurant
*/
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('restaurant1','test1@gmail.com');
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('restaurant2','test2@gmail.com');

/*
Insert into Region
*/
Insert into RESTAURANT.Region(regionName) VALUES('East');
Insert into RESTAURANT.Region(regionName) VALUES('North');


/*
Insert into Branch
*/
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity) 
VALUES('restaurant1','Bedok','East','S123456','0800','2200','100');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity) 
VALUES('restaurant1','Simei','East','S123457','0800','2200','80');
Insert into RESTAURANT.Branch (restaurantName, branchArea, regionName, address, openingHour, closingHour, capacity) 
VALUES('restaurant2','Yishun','North','S123459','0800','2200','30');

/*
Insert into Manages
*/
Insert into RESTAURANT.Manages (managerEmail, restaurantName, branchArea) VALUES ('manager1@gmail.com', 'restaurant1', 'Bedok');

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
Insert into RESTAURANT.Vacancy (restaurantName, branchArea, mealTypeName, vacancydate, vacancy) VALUES ('restaurant1', 'Bedok', 'lunch', '2019-04-05', '200');

/*
Insert into Reservation
*/
INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('restaurant1', 'Bedok', 'breakfast', '2019-03-05', 'cust1@gmail.com', '2', 'FALSE');