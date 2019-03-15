DROP SCHEMA RESTAURANT
CASCADE;
CREATE SCHEMA RESTAURANT;

CREATE TABLE RESTAURANT.Users
(
    userId SERIAL PRIMARY KEY,
    email varchar(50) UNIQUE NOT NULL,
    name varchar(50) NOT NULL,
    password varchar(50) NOT NULL,
    
);

CREATE TABLE RESTAURANT.Manager (
    userId varchar(50) PRIMARY KEY references RESTAURANT.Users(userId) on delete cascade,

);
CREATE TABLE RESTAURANT.Manages(
    userId varchar(50)
    restaurantName varchar(50),
    location varchar(50),
    primary key(userId, restaurantName, location)
    foreign key(userId) references RESTAURANT.Manager(userId)
    foreign key (restaurantName, location) references RESTAURANT.Restaurant

);

CREATE TABLE RESTAURANT.Admin (
    userId varchar(50) PRIMARY KEY references RESTAURANT.Users(userId) on delete cascade
);

CREATE TABLE RESTAURANT.Customer (
    userId varchar(50) PRIMARY KEY references RESTAURANT.Users(userId) on delete cascade,
    rewardpoints integer
);

CREATE TABLE RESTAURANT.Restaurant
(
    restaurantName varchar(50) PRIMARY KEY,
    cuisineType varchar(50)
);
CREATE TABLE RESTAURANT.Branch
(
    restaurantName varchar(50) references RESTAURANT.Restaurant (restaurantName),
    location varchar(50),
    managerId integer references RESTAURANT.Managers(userId),
    openingHour time,
    closingHour time,
    capacity integer,
    primary key(restaurantName, location)
);

CREATE TABLE RESTAURANT.Bookmark
(
    userId varchar(50),
    restaurantName varchar(50),
    location varchar(50),
    primary key (userId, restaurantName, location),
    foreign key (userId) references RESTAURANT.Customer(userId) ON DELETE CASCADE,
    foreign key (restaurantName, location) references RESTAURANT.Branch (restaurantName, location) ON DELETE CASCADE
);

CREATE TABLE RESTAURANT.Reservation
(
    reservationId SERIAL PRIMARY KEY,
    userId varchar(50) NOT NULL,
    date date NOT NULL,
    mealType varchar(50) NOT NULL,
    numDiner integer NOT NULL,
    restaurantName varchar(50) NOT NULL,
    location varchar(50) NOT NULL,
    status integer NOT NULL,
    check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner'),
    foreign key(userId) references RESTAURANT.Customer(userId) ON DELETE CASCADE,
    foreign key(restaurantName, location) references RESTAURANT.Branch(restaurantName, location) ON DELETE CASCADE
);

CREATE TABLE RESTAURANT.Reward
(
    rewardName varchar(50) PRIMARY KEY,
    description varchar(60),
    cost numeric(4,0) NOT NULL,
    check(cost > 0)
);

CREATE TABLE RESTAURANT.Redeem
(
    userRewardID SERIAL PRIMARY KEY,
    rewardName varchar(50) references RESTAURANT.Reward(rewardName),
    userId varchar(50) references RESTAURANT.Customer(userId),
    check(rewardName is NOT NULL and userId is NOT NULL)
);

CREATE TABLE RESTAURANT.Feedback
(
    userId varchar(50),
    restaurantName varchar(50) NOT NULL,
    location varchar(50) NOT NULL,
    rating NUMERIC(2,1) default 0,
    comments varchar(50),
    primary key(userId, restaurantName, location),
    foreign key(restaurantName, location) references RESTAURANT.Branch(restaurantName, location) ON DELETE CASCADE
    foreign key(userId) REFERENCES RESTAURANT.Users(userId),
    CHECK(rating >= 0.0 and rating <= 5.0)
);
CREATE TABLE RESTAURANT.Menu
(
    restaurantName varchar(50),
    foodName varchar(50),
    price NUMERIC(7,2) NOT NULL,
    primary key(restaurantName, foodName),
    foreign key(restaurantName) REFERENCES RESTAURANT.Restaurant(restaurantName) ON DELETE CASCADE
);

CREATE TABLE RESTAURANT.Vacancy
(
    restaurantName varchar(50),
    location varchar(50),
    date date,
    mealType varchar(50),
    vacancy integer NOT NULL,
    check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner'),
    primary key (restaurantName, location, date, mealType),
    foreign key (restaurantName, location) references RESTAURANT.Branch(restaurantName, location) ON DELETE CASCADE
);

CREATE TABLE RESTAURANT.Promotion
(
    promotionName varchar(50),
    restaurantName varchar(50),
    promoDetails varchar(50),
    foreign key (restaurantName, location) references RESTAURANT.Branch(restaurantName, location) ON DELETE CASCADE
);



