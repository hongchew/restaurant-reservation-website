DROP TABLE if exists RESTAURANT cascade;
create schema RESTAURANT;

CREATE TABLE RESTAURANT.User(
    email varchar(50) PRIMARY KEY,
    name varchar(50),
    password varchar(50),
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
    email varchar(50) PRIMARY KEY,
);

CREATE TABLE RESTAURANT.Feedback(
    email varchar(50) PRIMARY KEY,
);
CREATE TABLE RESTAURANT.Reward(
    email varchar(50) PRIMARY KEY,
);
CREATE TABLE RESTAURANT.UserReward(
    email varchar(50) PRIMARY KEY,
);
CREATE TABLE RESTAURANT.Restaurant(
    email varchar(50) PRIMARY KEY,
);
CREATE TABLE RESTAURANT.Menu(
    email varchar(50) PRIMARY KEY,
);
CREATE TABLE RESTAURANT.Branch(
    rname varchar(50) references RESTAURANT.Restaurant (rname),
    location varchar(50),
    openingHour time,
    closingHour time,
    capacity integer,
    primary key(rname, location),
);
CREATE TABLE RESTAURANT.Vacancy(
    email varchar(50) PRIMARY KEY,
);