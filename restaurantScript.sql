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
    rewardName varchar(50) PRIMARY KEY,
    description varchar(60),
    cost int(4) NOT NULL,
    check(cost > 0)
);
CREATE TABLE RESTAURANT.UserReward(
    userRewardID SERIAL PRIMARY KEY,
    rewardName varchar(50) references RESTAURANT.Reward(rewardName),
    email varchar(50) references RESTAURANT.Users(email),
    check(rewardName is NOT NULL and email is NOT NULL)
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