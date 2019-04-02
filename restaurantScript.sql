DROP SCHEMA RESTAURANT
CASCADE;
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
    generalManagerEmail varchar(50) PRIMARY KEY references RESTAURANT.Users(email) on delete cascade,
    restaurantName varchar(50) references RESTAURANT.Restaurant(restaurantName)
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
    generalManagerEmail varchar(50) REFERENCES RESTAURANT.GeneralManager(email) 
);

CREATE TABLE RESTAURANT.Cuisine
(
    cuisineName VARCHAR(50) primary key
);

CREATE TABLE RESTAURANT.MenuItem
(
    restaurantName varchar(50) references RESTAURANT.Restaurant ON DELETE CASCADE,
    menuName varchar(50),
    price NUMERIC(7,2) NOT NULL,
    cuisineName varchar(50) references RESTAURANT.Cuisine(cuisineName),
    primary key(restaurantId, menuName)
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
    PRIMARY KEY(restaurantName, branchArea),
);

CREATE TABLE RESTAURANT.Manages(
    managerEmail varchar(50) references RESTAURANT.Manager(managerEmail) on delete cascade,
    restaurantName varchar(50),
    branchArea varchar(50),
    PRIMARY KEY(managerEmail, restaurantId, branchArea),
    FOREIGN KEY (restaurantName, branchArea) references RESTAURANT.Branch(restaurantName, branchArea) on DELETE CASCADE
);

CREATE TABLE RESTAURANT.Bookmark
(
    customerEmail integer references RESTAURANT.Customer(customerEmail) ON DELETE CASCADE,    
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
    customerEmail NOT NULL references RESTAURANT.Customer(customerEmail) on delete cascade,
    numDiner integer NOT NULL,
    status boolean,
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





/*
Insert into User
*/
Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('test1@gmail.com','GM1','password','GeneralManager');
Insert into RESTAURANT.GeneralManager (generalManagerId,restaurantId) VALUES('1','1');


/*
Insert into Restaurant
*/
Insert into RESTAURANT.Restaurant (restaurantName, generalManagerId) VALUES('restaurant1','1');

/*
Insert into Region
*/
Insert into RESTAURANT.Region(regionName) VALUES('East');

/*
Insert into Branch
*/
Insert into RESTAURANT.Branch (restaurantId, branchArea, regionId, address, openingHour, closingHour, capacity) 
VALUES('1','Bedok','1','S123456','0800','2200','100');
Insert into RESTAURANT.Branch (restaurantId, branchArea, regionId, address, openingHour, closingHour, capacity) 
VALUES('1','Simei','1','S123457','0800','2200','80');

