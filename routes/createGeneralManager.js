var express = require('express');
var router = express.Router();
const { Pool } = require('pg');
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: '********',
  port: 5432
});
router.get('/', function(req, res, next) {
  res.render('createGeneralManager', { emailUsed: false });
});

// POST
router.post('/', function(req, res, next) {
  console.log('test');

  var name = req.body.name;
  var email = req.body.email;
  var rawRestaurantName = req.body.restaurantname;
  var restaurantName = rawRestaurantName.replace(/'/g,"''");
  var password = req.body.password;
  var accountType = 'GeneralManager';
  console.log(restaurantName);
  var sql_insert_query = 'INSERT INTO RESTAURANT.Users VALUES';
  var sql_insert_restaurant = 'INSERT INTO RESTAURANT.Restaurant VALUES';
  var retrieve_query =
    "select * from RESTAURANT.Users WHERE email = '" + email + "'";

  var insert_query =
    sql_insert_query +
    "('" +
    email +
    "','" +
    name +
    "','" +
    password +
    "','" +
    accountType +
    "')";

  var insert_restaurant = 
    sql_insert_restaurant +
    "('" +
    restaurantName +
    "','" +
    email +
    "')";

  pool.query(retrieve_query, (err, data) => {
    if (data.rows.length == 0) {
      pool.query(insert_query, (err, data) => {
      });
      pool.query(insert_restaurant, (err, data) => {
        res.redirect('/mainGeneralManager');
      });
    } else{
      res.render('createGeneralManager', {emailUsed: true});
    }
  });
});

module.exports = router;
