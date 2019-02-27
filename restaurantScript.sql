DROP SCHEMA RESTAURANT CASCADE;
CREATE SCHEMA RESTAURANT;

CREATE TABLE RESTAURANT.Users(
    email varchar(50) PRIMARY KEY,
    username varchar(50),
    password varchar(50),
    accountType varchar(50) NOT null,
    Check(accountType = 'Customer' OR accountType = 'Admin')
);

CREATE TABLE RESTAURANT.Bookmark(
    email varchar(50) PRIMARY KEY
);

CREATE TABLE RESTAURANT.Reservation(
    email varchar(50) PRIMARY KEY
);

CREATE TABLE RESTAURANT.Feedback(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.Reward(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.UserReward(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.Restaurant(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.Menu(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.Branch(
    email varchar(50) PRIMARY KEY
);
CREATE TABLE RESTAURANT.Vacancy(
    email varchar(50) PRIMARY KEY
);