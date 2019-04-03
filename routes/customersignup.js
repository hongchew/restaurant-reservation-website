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
  res.render('customerSignup', {emailUsed: false});
});

// POST
router.post('/', function(req, res, next) {
  console.log('test');

  var name = req.body.name;
  var email = req.body.email;
  var password = req.body.password;
  var accountType = 'Customer';
  console.log(name);
  var sql_insert_query = 'INSERT INTO RESTAURANT.Users VALUES';
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
  pool.query(retrieve_query, (err, data) => {
    if (data.rows.length == 0) {
      pool.query(insert_query, (err, data) => {
        console.log(err);
        var user = {
          email: email,
          accountType: accountType,
          login: true
        }
        req.app.locals.user = user;
        res.redirect('/listrestaurant');
      });
    } else{
      res.render('customersignup', {emailUsed: true});
    }
  });
});

module.exports = router;
