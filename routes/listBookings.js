var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


var table;
var branchArea;
var restName;
var currentManager;
var msg = null;

module.exports = router;


router.get('/', function (req, res, next) {
    console.log("***GET listBooking.js ");

    currentManager = req.app.locals.user
    console.log(currentManager);

    pool.query("SELECT branchArea FROM Restaurant.Manages WHERE managerEmail = '" + currentManager.email + "';", (err, result)=>{
        console.log(result.rows);
        if(err){
            console.log("branchArea err: " + err.message);
        }else{
            branchArea = result.rows[0].branchArea;
        }
    });

    console.log("***Check 1 ");

    pool.query("SELECT restaurantName FROM Restaurant.Manages WHERE managerEmail = '" + currentManager.email + "';", (err, result)=>{
        console.log(result.rows);
        if(err){
            console.log("restName err: " + err.message);
        }else{
            restName = result.rows[0].restaurantName;
        }
    });
    
    console.log("***Check 2 ");  
    
    console.log("***Check 3 ");
    
    var query = "SELECT * FROM Restaurant.Reservation WHERE status = FALSE AND restaurantName = '" + restName + "' AND branchArea = '" + branchArea + "';";
    
    pool.query(query, (err, data) => {
        if(err){
            console.log("final err: " + err.message);
        }else{
            //console.log(data);
            console.log(data.rows);
            table = data.rows;
            res.render('listBookings', { title: 'Pending Bookings', data: data.rows, msg:msg });
        }
    });

    console.log("***Exit GET listBookings.js ");
});

router.post('/', function (req, res, next) {
    var updateStatement = "UPDATE Reservation SET status = TRUE WHERE reservationId = " + req.body.resId;
    pool.query(updateStatement, (err, results)=>{'SELECT * FROM Restaurant.Reservation WHERE status = FALSE AND'
        console.log(req.body.resId + " is updated");
        msg = "Reservation status of resId " + req.body.resId + " had been updated";

        res.render('listBookings', { title: 'Pending Bookings', data: data.rows, msg:msg });
    });
});