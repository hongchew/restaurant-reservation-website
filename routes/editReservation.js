var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});


router.get('/', function(req, res, next) {
    var editReservationId = req.query.editReservationId;

    var query = "select * from restaurant.reservation natural join restaurant.branch where reservationid = " + editReservationId +";";
    console.log(query);
    pool.query(query, (err, data)=>{
        if(err){
            console.log("***Err EDIT :" + err.message);
        }
        console.log(data.rows);
        res.render('editReservation', {title: "Edit Reservation", editReservation: data.rows });
    })
    

});

router.post('/', function(req, res, next) {
    var updatedMealType = req.body.updatedMealType;
    var updatedDate = req.body.updatedDate;
    var updatedNumDiner = parseInt(req.body.updatedNumDiner);
    var editReservationId = req.body.id;

    var query = "update restaurant.reservation set vacancydate = '" + updatedDate + "', mealtypename = '" + updatedMealType + "', numdiner = " + updatedNumDiner + " where reservationid = " + editReservationId + ";";
    console.log(query);
    pool.query(query, (err, data)=>{
        if(err){
            console.log("***Err EDIT: " + err.message);
        }
        res.redirect("/userinfo");
    })

});

module.exports = router;