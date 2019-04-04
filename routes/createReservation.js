var express = require('express');
var router = express.Router();
const url = require('url');    



const { Pool } = require('pg')

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});
var restaurantName;
var branchArea;
var rubbish;

// GET
router.get('/', function (req, res, next) {
    rubbsh = "test";
    restaurantName = req.query.restaurantName;
    branchArea = req.query.branchArea;
    res.render('createReservation', { title: 'Create Reservation', data: req.query, rubbish: rubbish });
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
var check_query ="SELECT * FROM RESTAURANT.Vacancy WHERE bArea = 'Nothing';";
// pool.query(insert_query, (err, data) => {
//     console.log(err);
//     console.log("*********** HERE'S THE ERROR ABOVE*****************")
//     res.redirect('/listRestaurant'); /********Change route too!!!********* */
// })

pool.query(check_query, (err, data) => {
    if(typeof data === 'undefined'){
    console.log(data.rows);
    }
    res.redirect('/listRestaurant');
})
    

});

module.exports = router;
