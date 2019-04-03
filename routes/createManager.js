var express = require('express');
var router = express.Router();
const { Pool } = require('pg');
const pool = new Pool({
    connectionString:process.env.DATABASE_URL
});
router.get('/', function(req, res, next) {
  res.render('createGeneralManager', { emailUsed: false });
});

// POST
router.post('/', function(req, res, next) {
var restaurantName;
  var getRestaurantNameQuery = "SELECT restaurantName FROM RESTAURANT.Restaurant WHERE generalManagerEmail =" + user.email;
  pool.query(getRestaurantNameQuery, (err,data) => {
    if(data.rows.length ==0) {
        console.log("General Manager is not associated with any Restaurants")
    } else{
        restaurantName = data[0].restaurantName;
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
    address +
    "','" +
    openingHour +
    "','" +
    closingHour +
    "','" +
    capacity +
    "')";

  pool.query(retrieve_query, (err, data) => {
    res.render('createManager');
  });
});

module.exports = router;
