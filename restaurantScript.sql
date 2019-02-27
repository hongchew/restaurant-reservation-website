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
    reservationId   integer     PRIMARY KEY IDENTITY,
    username        varchar(50) NOT NULL,
    date            date        NOT NULL,
    mealType        varchar(50) NOT NULL,
    numDiner        integer     NOT NULL,
    rname           varchar(50) NOT NULL,
    location        varchar(50) NOT NULL,  
    check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner'),
    foreign key(username) references RESTAURANT.Users(username),
    foreign key(rname, location) references RESTAURANT.Branch(rname, location)    
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
    rname           varchar(50),
    location        varchar(50),
    date            date,
    mealType        varchar(50),
    vacancy         integer NOT NULL,
    check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner')
    primary key(rname, location, date, mealType),
    foreign key(rname, location) references RESTAURANT.Branch(rname, location),
);