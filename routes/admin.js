var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

var user;
var allReservations;

router.get('/', function(req, res, next) {
  user = req.app.locals.user;
  console.log(user);
  if(user.accountType != 'Admin'){
    res.redirect("/login");
  }

  var query = "select *, to_char(vacancyDate, ' Day DD-Mon-YYYY') as date, case when status = 1 then 'Fulfilled' when status = 0 then 'Pending' when status = -1 then 'No Show' end as statustext from restaurant.reservation;"
  pool.query(query, (err, data)=>{
    if(err){
      console.log("Err ALL: " + err.message);      
    }
    allReservations = data.rows;
    res.render('admin', { title: 'View All Past Bookings', allReservations: allReservations });
  });  
});

router.post('/', function(req, res, next) {
  var id = req.body.reservationToDeleteId
  var query = "delete from restaurant.reservation where reservationid = " + id + ";"; 
  pool.query(query, (err, data)=>{
    if(err){
      console.log("Err DELETE: " + err.message);
    }

    res.redirect('admin');
  });
});

module.exports = router;
