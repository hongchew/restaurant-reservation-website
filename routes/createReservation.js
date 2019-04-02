var express = require('express');
var router = express.Router();
const url = require('url');    



const { Pool } = require('pg')

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});
var restaurantName;
var branchArea;

// GET
router.get('/', function (req, res, next) {
    restaurantName = req.query.restaurantName;
    branchArea = req.query.branchArea;
    res.render('createReservation', { title: 'Create Reservation', data: req.query });
});


// POST
router.post('/', function (req, res, next) {
    

    console.log("*************************");
console.log(req.body);
console.log(req.body.mealType);
console.log("*****Document*******");

var customerEmail = "cust1@gmail.com"; //***************need to change***********************
var mealType = req.body.mealType;
var pax = req.body.pax;
var vacancyDate = req.body.date;

var insert_query = "INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('" + restaurantName +"', '" + branchArea +"', '" + mealType + "', '" + vacancyDate + "', '" + customerEmail +"', '"+ pax + "', 'FALSE')"; 

pool.query(insert_query, (err, data) => {
    console.log(err);
    res.redirect('/listRestaurant'); /********Change route too!!!********* */
})
    

});

module.exports = router;
