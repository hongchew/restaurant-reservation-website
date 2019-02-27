DROP SCHEMA RESTAURANT
CASCADE;
CREATE SCHEMA RESTAURANT;

CREATE TABLE RESTAURANT.Users
(
    email varchar(50) PRIMARY KEY,
    name varchar(50) NOT NULL,
    password varchar(50) NOT NULL,
    accountType varchar(50) NOT null,
    Check(accountType = 'Customer' OR accountType = 'Admin')
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
    openingHour time,
    closingHour time,
    capacity integer,
    primary key(restaurantName, location)
);

CREATE TABLE RESTAURANT.Bookmark
(
    username varchar(50),
    restaurantName varchar(50),
    location varchar(50),
    primary key (username, restaurantName, location),
    foreign key (username) references RESTAURANT.Users,
    foreign key (restaurantName, location) references RESTAURANT.Branch (restaurantName, location)
);

CREATE TABLE RESTAURANT.Reservation
(
    reservationId integer PRIMARY KEY,
    username varchar(50) NOT NULL,
    date date NOT NULL,
    mealType varchar(50) NOT NULL,
    numDiner integer NOT NULL,
    restaurantName varchar(50) NOT NULL,
    location varchar(50) NOT NULL,
    check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner'),
    foreign key(username) references RESTAURANT.Users(username),
    foreign key(restaurantName, location) references RESTAURANT.Branch(restaurantName, location)
);


CREATE TABLE RESTAURANT.Reward
(
    rewardName varchar(50) PRIMARY KEY,
    description varchar(60),
    cost int(4) NOT NULL,
    check(cost > 0)
);
CREATE TABLE RESTAURANT.UserReward
(
    userRewardID SERIAL PRIMARY KEY,
    rewardName varchar(50) references RESTAURANT.Reward(rewardName),
    email varchar(50) references RESTAURANT.Users(email),
    check(rewardName is NOT NULL and email is NOT NULL)
);

CREATE TABLE RESTAURANT.Feedback
(
    email varchar(50),
    restaurantName varchar(50),
    rating NUMERIC(2,1) default 0,
    primary key(email, restaurantName),
    foreign key(restaurantName) REFERENCES RESTAURANT.Restaurant ON DELETE CASCADE,
    foreign key(email) REFERENCES RESTAURANT.Users,
    CHECK(rating >= 0.0 and rating <= 5.0)
);
CREATE TABLE RESTAURANT.Menu
(
    restaurantName varchar(50),
    foodName varchar(50),
    price NUMERIC(7,2) NOT NULL,
    primary key(restaurantName, foodName),
    foreign key(restaurantName) REFERENCES RESTAURANT.Restaurant ON DELETE CASCADE
);

CREATE TABLE RESTAURANT.Vacancy
(
    rname varchar(50),
    location varchar(50),
    date date,
    mealType varchar(50),
    vacancy integer NOT NULL,
    check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner')
    primary key
    (rname, location, date, mealType),
    foreign key
    (rname, location) references RESTAURANT.Branch
    (rname, location) ON
    DELETE CASCADE,
);