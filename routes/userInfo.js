var express = require('express');
var router = express.Router();

const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

var email = 'cust1@gmail.com';


router.get('/', function (req, res, next) {
        var user = req.app.locals.user;
        var pastReservationsQuery = "SELECT r.reservationId, r.restaurantName, r.branchArea, r.mealTypeName, r.vacancyDate, r.numDiner FROM RESTAURANT.Reservation r join RESTAURANT.Customer c on r.customerEmail = c.customerEmail WHERE c.customerEmail = '" + email + "' AND r.vacancyDate < NOW() ORDER BY r.vacancyDate";
        
        var upcomingReservationsQuery = "SELECT r.reservationId, r.restaurantName, r.branchArea, r.mealTypeName, r.vacancyDate, r.numDiner FROM RESTAURANT.Reservation r join RESTAURANT.Customer c on r.customerEmail = c.customerEmail WHERE c.customerEmail = '" + email + "' AND r.vacancyDate >= NOW() ORDER BY r.vacancyDate";

        var pastReservations=null;
        var upcomingReservation=null;
    pool.query(pastReservationsQuery, (err,data) => {
        
        pastReservations = data;
        pool.query(upcomingReservationsQuery, (err,data) => {
            console.log(data.rows);
            upcomingReservation = data;
            res.render('userInfo', {title:'User Information', data2: upcomingReservation.rows, data1:pastReservations.rows});

    });
        
    });
    
    

    
});

module.exports = router;
