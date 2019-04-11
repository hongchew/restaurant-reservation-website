var express = require('express');
var router = express.Router();
const url = require('url');



const { Pool } = require('pg')

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});
var restaurantName;
var branchArea;
var user;

// GET
router.get('/', function (req, res, next) {
    restaurantName = req.query.restaurantName;
    branchArea = req.query.branchArea;
    user = req.app.locals.user;
    var sql_query = "SELECT * FROM Restaurant.Branch WHERE restaurantName = '" + restaurantName + "' and branchArea = '" + branchArea + "';";
    if (req.app.locals.user == null || req.app.locals.user.accountType != 'Customer') {
        res.redirect('login');
    } else {

        pool.query(sql_query, (err, data) => {
            table = data.rows;
            res.render('createReservation', { title: 'Create Reservation', data: data.rows, });
        });
    }

});


// POST
router.post('/', function (req, res, next) {


    console.log("*************************");
    console.log(req.body);
    console.log(req.body.mealType);
    console.log("*****Document*******");

    var customerEmail = req.app.locals.user.email; //***************need to change***********************
    var mealType = req.body.mealType;
    var pax = req.body.pax;
    var vacancyDate = req.body.date;

    var insert_query = "INSERT INTO RESTAURANT.Reservation (restaurantName, branchArea, mealTypeName, vacancyDate, customerEmail, numDiner, status) VALUES ('" + restaurantName + "', '" + branchArea + "', '" + mealType + "', '" + vacancyDate + "', '" + customerEmail + "', '" + pax + "', '0')";
    var check_query = "SELECT * FROM RESTAURANT.Vacancy WHERE bArea = 'Nothing';";
    pool.query(insert_query, (err, data) => {
        if (err) {
            var errorMessage = "Resturant has been fully reserved on that day. Reservation UNSUCCESSFUL";
            req.app.locals.reservationStatus.error = true;
            var passInfo = {
                errorMessage: errorMessage,
                failRestaurant: restaurantName,
                failBranch: branchArea,
                failDate: vacancyDate,
                failVacancy: pax

            }

            res.redirect(url.format({
                pathname: "/listRestaurant",
                query: passInfo
            }));
            console.log("*********** HERE'S THE ERROR ABOVE*****************")
        } else {
            res.redirect('/listRestaurant');
        }

    })


});

module.exports = router;
