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
    username varchar(50),
    rname varchar(50),
    location varchar(50),
    primary key (username, rname, location),
    foreign key (username) references RESTAURANT.User,
    foreign key (rname) references RESTAURANT.Restaurant,
    foreign key (location) references RESTAURANT.Restaurant (location)
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
    restaurantName varchar(50) PRIMARY KEY,
    cuisineType varchar(50)
);
CREATE TABLE RESTAURANT.Menu(
    restaurantName varchar(50),
    foodName varchar(50),
    price NUMERIC(7,2) NOT NULL,
    primary key(restaurantName, foodName),
    foreign key(restaurantName) REFERENCES RESTAURANT.Restaurant
);
CREATE TABLE RESTAURANT.Branch(
<<<<<<< HEAD
    rname varchar(50) references RESTAURANT.Restaurant (rname),
    location varchar(50),
    openingHour time,
    closingHour time,
    capacity integer,
    primary key(rname, location),
=======
    email varchar(50) PRIMARY KEY
>>>>>>> 122965917999ab5237e0f6f638f3cb2f020e286e
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