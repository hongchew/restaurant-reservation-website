var express = require('express');
var router = express.Router();
const { Pool } = require('pg');
const pool = new Pool({
    connectionString:process.env.DATABASE_URL
});
router.get('/', function(req, res, next) {
  res.render('createManager');
});

// POST
router.post('/', function(req, res, next) {
  var generalManagerEmail = "test1@gmail.com";
var restaurantName;
  var getRestaurantNameQuery = "SELECT restaurantName FROM RESTAURANT.Restaurant WHERE generalManagerEmail ='" + generalManagerEmail + "'";
  pool.query(getRestaurantNameQuery, (err,data) => {
    if(data.rows.length ==0) {
        console.log("General Manager is not associated with any Restaurants")
    } else{
        restaurantName = data.rows[0].restaurantName;
    }
  });

  var name = req.body.name;
  var email = req.body.email;
  var branchArea = req.body.branchArea;
  var password = req.body.password;
  var accountType = 'Manager';
  var regionName = req.body.regionName;
  var address = req.body.address;
  var openingHour = req.body.openingHour;
  var closingHour = req.body.closingHour;
  var capacity = req.body.capacity;

  var retrieve_query =
  "select * from RESTAURANT.Users WHERE email = '" + email + "'";


  var insertManagerQuery =
  "INSERT INTO RESTAURANT.Users VALUES" +
    "('" +
    email +
    "','" +
    name +
    "','" +
    password +
    "','" +
    accountType +
    "')";

  var insertBranchQuery = "INSERT INTO RESTAURANT.Branch VALUES" + "('" + restaurantName +
    "','" +
    branchArea +
    "','" +
    regionName +
    "','" +
    email +
    "','" +
    address +
    "','" +
    openingHour +
    "','" +
    closingHour +
    "','" +
    capacity +
    "','" +
    0.0 +
    "')";

    pool.query(retrieve_query, (err, data) => {
      if (data.rows.length == 0) {
        pool.query(insertManagerQuery, (err, data) => {
        });
        pool.query(insertBranchQuery, (err, data) => {
          res.redirect('/listrestaurant');
        });
      } else{
        res.render('createManager');
      }
    });
  
  
});

module.exports = router;
