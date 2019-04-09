var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


var table;
var currentManager;
var currentBranch;
var msg;

module.exports = router;


router.get('/', function (req, res, next) {
    console.log("***GET listBooking.js ");

    currentManager = req.app.locals.user;
    console.log(currentManager);
    if(!currentManager.email || currentManager.accountType != 'Manager'){
        res.redirect("/login");
    }
    
    pool.query("select * from Restaurant.Branch where manageremail = '" + currentManager.email + "';" , (err, data) => {
        if(err){
            console.log("currentBranch query err: " + err.message);
        }else{
            console.log(data.rows[0]);
            currentBranch = data.rows[0];
            console.log("***Check currentBranch query ");

        }
    });

    query = "select reservationid, customeremail, numdiner, mealtypename, to_char(vacancydate, 'Day DD-Mon-YYYY') as vacancydate from (restaurant.reservation natural join restaurant.branch) rb where rb.status = 0 and rb.manageremail = '" + currentManager.email + "' order by rb.vacancydate asc;";

    pool.query(query, (err, data) => {
        if(err){
            console.log("GET query err: " + err.message);
        }else{
            console.log(data.rows);
            table = data.rows;
            console.log("***Check main query ");
            res.render('listBookings', { title: 'Pending Bookings', currentBranch:currentBranch, data: data.rows, msg:msg});
            msg = null;
        }
    });

    console.log("***Exit GET listBookings.js ");
});

router.post('/', function (req, res, next) {
    console.log(req.body.resId);
    flag = req.body.flag;
    console.log(req.body.resId);
    var updateStatement;
    if(flag == "fulfilled"){
        updateStatement = "UPDATE Restaurant.Reservation SET status = 1 WHERE reservationId = " + req.body.resId;
        console.log(updateStatement);
        pool.query(updateStatement, (err, results)=>{
            
            if(err){
                console.log("POST query err: " + err.message);
            }else{
                console.log(req.body.resId + " is updated");
                msg = "Reservation status of resId " + req.body.resId + " had been marked as fulfilled";
                res.redirect("/listBookings");
            }
        });
    }else if(flag == "noshow"){ 
        updateStatement = "UPDATE Restaurant.Reservation SET status = -1 WHERE reservationId = " + req.body.resId;
        console.log(updateStatement);
        pool.query(updateStatement, (err, results)=>{
            
            if(err){
                console.log("POST query err: " + err.message);
            }else{
                console.log(req.body.resId + " is updated");
                msg = "Reservation status of resId " + req.body.resId + " had been marked as no show";
                res.redirect("/listBookings");
            }
        });
    }else{ //logout
        req.app.locals.user = null;
        res.redirect("/login");
    }
});