var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: '********',
  port: 5432,
})

/* SQL Query */
var sql_query_login = 'SELECT * FROM RESTAURANT.users';

// GET
router.get('/', function(req, res, next) {
  res.render('login', { title: 'Login User', error: false });
});

// POST
router.post('/', function(req, res, next) {
  // Retrieve Information
  var email = req.body.email;
  var password = req.body.password;
  console.log("test");
  // Construct Specific SQL Query
  var retrieve_query =
    sql_query_login +
    " where email = '" +
    email +
    "'" +
    "AND password='" +
    password +
    "'";

  pool.query(retrieve_query, (err, data) => {
    if (data.rows.length == 0) {
      res.render('login', { title: 'Login User', error: true });
    } else {
      var user = {
        name: data.rows[0].name,
        email: data.rows[0].email,
        accountType: data.rows[0].accounttype,
        login: true
      };

      req.app.locals.user = user;

      if (user.accountType == 'Customer') {
        res.redirect('/listrestaurant');
      }

      if (user.accountType == 'GeneralManager') {
        res.redirect('/create');
      }
    }
  });
});

module.exports = router;
