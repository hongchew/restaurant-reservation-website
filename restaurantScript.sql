DROP SCHEMA RESTAURANT
CASCADE;
CREATE SCHEMA RESTAURANT;

CREATE TABLE RESTAURANT.Users
(
    userId SERIAL PRIMARY KEY,
    email varchar(50) UNIQUE NOT NULL,
    name varchar(50) NOT NULL,
    password varchar(50) NOT NULL,
    accountType varchar(50) NOT NULL
);

CREATE TABLE RESTAURANT.Manager (
    userId integer PRIMARY KEY references RESTAURANT.Users(userId) on delete cascade
);

CREATE TABLE RESTAURANT.GeneralManager{
    userId integer PRIMARY KEY REFERENCES RESTAURANT.Users(userId) ON DELETE CASCADE,
    restaurantId integer FOREIGN KEY REFERENCES RESTAURANT.Restaurant(restaurantId) ON DELETE CASCADE
}

CREATE TABLE RESTAURANT.Manages(
    userId integer references RESTAURANT.Manager(userId),
    restaurantId integer,
    branchArea varchar(50),
    regionId integer,
    PRIMARY KEY(managerId, restaurantId, branchArea, regionId),
    FOREIGN KEY (restaurantId, branchArea, regionId) references RESTAURANT.Branch(restaurantId, branchArea, regionId) on DELETE CASCADE,
    FOREIGN KEY (managerId) references RESTAURANT.Manager(userId) on DELETE CASCADE
);

CREATE TABLE RESTAURANT.Admin (
    userId integer PRIMARY KEY references RESTAURANT.Users(userId) on delete cascade
);

CREATE TABLE RESTAURANT.Customer (
    userId integer PRIMARY KEY references RESTAURANT.Users(userId) on delete cascade,
);

CREATE TABLE RESTAURANT.Restaurant
(
    restaurantId SERIAL PRIMARY KEY,
    restaurantName varchar(50),
    generalManagerId
);

CREATE TABLE RESTAURANT.MenuItem
(
    restaurantId integer,
    menuName varchar(50),
    price NUMERIC(7,2) NOT NULL,
    cuisineId integer,
    primary key(restaurantId, menuName),
    foreign key(restaurantId) REFERENCES RESTAURANT.Restaurant(restaurantId) ON DELETE CASCADE,
    foreign key(cuisineId) REFERENCES RESTAURANT.Cuisine(cuisineId)
);
CREATE TABLE RESTAURANT.Cuisine
(
    cuisineId SERIAL PRIMARY KEY,
    cuisineName VARCHAR(50)
)

CREATE TABLE RESTAURANT.Region(
    regionId SERIAL PRIMARY KEY,
    regionName varchar(50),
);  

CREATE TABLE RESTAURANT.Branch
(
    restaurantId integer,
    branchArea varchar(50),
    regionId integer,
    address varchar(50),
    openingHour integer,
    closingHour integer,
    capacity integer,
    PRIMARY KEY(restaurantId, branchArea),
    FOREIGN KEY(restaurantId) references RESTAURANT.Restaurant(restaurantId) ON DELETE CASCADE,
    FOREIGN KEY(regionId) references RESTAURANT.region(regionId) ON DELETE CASCADE
);

CREATE TABLE RESTAURANT.Bookmark
(
    bookmarkId SERIAL PRIMARY KEY,
    userId integer,
    resutaurantId integer,
    branchArea varchar(50),
    foreign key (branchArea,restaurantId) references RESTAURANT.Branch(branchArea, restaurantId) ON DELETE CASCADE,    
    foreign key (userId) references RESTAURANT.Customer(userId) ON DELETE CASCADE,
);

CREATE TABLE RESTAURANT.MealType(
    mealTypeId SERIAL PRIMARY KEY,
    mealTypeName varchar(50),
); 

CREATE TABLE RESTAURANT.Reservation
(
    reservationId SERIAL PRIMARY KEY,
    restaurantId integer,
    branchArea varchar(50),
    mealtypeId integer,
    vacancyDate date,
    userId integer NOT NULL,
    name varchar(50),
    feedbackId integer,
    numDiner integer NOT NULL,
    status boolean,
    check(numDiner > 0),
    -- check(mealType = 'Breakfast' OR mealType = 'Lunch' OR mealType = 'Dinner'),
    foreign key(userId) references RESTAURANT.Customer(userId) ON DELETE CASCADE,
    FOREIGN KEY(restaurantId, branchArea, mealtypeId, vacancyDate) references RESTAURANT.Vacancy(restaurantId, branchArea, mealtypeId, vacancyDate),
    FOREIGN KEY(feedbackId) references RESTAURANT.Feedback(feedbackId)
);

CREATE TABLE RESTAURANT.Feedback
(
    feedbackId SERIAL PRIMARY KEY,
    reservationId integer,
    rating NUMERIC(2,1) default 0,
    comments varchar(50),
    foreign key(reservationId) references RESTAURANT.Reservation(reservationId) ON DELETE CASCADE
    CHECK(rating >= 0.0 and rating <= 5.0)
);


CREATE TABLE RESTAURANT.Vacancy
(
    restaurantId integer,
    branchArea varchar(50),
    mealTypId integer,
    vacancyDate date,
    mealTypeId integer,
    vacancy integer,
    PRIMARY KEY(restaurantId,branchArea, mealTypeId, vacancyDate),
    foreign key(mealTypeId) REFERENCES RESTAURANT.MealType(mealTypeId) on delete cascade,
    FOREIGN KEY(restaurantId, branchArea) REFERENCES RESTAURANT.branch(restaurantId, branchArea)
);



