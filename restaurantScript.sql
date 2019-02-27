DROP SCHEMA RESTAURANT CASCADE;
CREATE SCHEMA RESTAURANT;

CREATE TABLE RESTAURANT.Users(
    email varchar(50) PRIMARY KEY,
    username varchar(50) NOT NULL,
    password varchar(50) NOT NULL,
    accountType varchar(50) NOT null,
    Check(accountType = 'Customer' OR accountType = 'Admin')
);

CREATE TABLE RESTAURANT.Bookmark(
    email varchar(50) PRIMARY KEY
);

CREATE TABLE RESTAURANT.Reservation(
    email varchar(50) PRIMARY KEY
);


CREATE TABLE RESTAURANT.Reward(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.UserReward(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.Restaurant(
    restaurantName varchar(50) PRIMARY KEY,
    cuisineType varchar(50)
);
CREATE TABLE RESTAURANT.Feedback(
    email varchar(50),
    restaurantName varchar(50),
    rating NUMERIC(2,1) default 0,
    primary key(email, restaurantName),
    foreign key(restaurantName) REFERENCES RESTAURANT.Restaurant ON DELETE CASCADE,
    foreign key(email) REFERENCES RESTAURANT.Users,
    CHECK(rating >= 0.0 and rating <= 5.0)
);
CREATE TABLE RESTAURANT.Menu(
    restaurantName varchar(50),
    foodName varchar(50),
    price NUMERIC(7,2) NOT NULL,
    primary key(restaurantName, foodName),
    foreign key(restaurantName) REFERENCES RESTAURANT.Restaurant ON DELETE CASCADE
);
CREATE TABLE RESTAURANT.Branch(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.Vacancy(
    email varchar(50) PRIMARY KEY
);