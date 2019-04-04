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
    pool.query(pastReservationsQuery, (err,data) => {
        // var reservationId = data.rows[0].reservationId;
        // var restaurantName = data.rows[0].restaurantName;
        // var branchArea = data.rows[0].branchArea;
        // var mealTypeName = data.rows[0].mealTypeName;
        // var vacancyDate = data.rows[0].vacancyDate;
        // var numDiner = data.rows[0].numDiner;
        pastReservations = data;
    });
        var currReservation=null;
    pool.query(upcomingReservationsQuery, (err,data) => {
            currReservation = data;
    });
    res.render('userInfo', {title:'User Information', data2: currReservation.rows, data1: pastReservations.rows});
});

module.exports = router;
