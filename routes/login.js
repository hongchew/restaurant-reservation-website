var express = require('express');
var router = express.Router();
const { Pool } = require('pg');

const { Pool } = require('pg')
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'postgres',
  password: '********',
  port: 5432,
})

/* SQL Query */
var sql_query_login = 'SELECT * FROM "ProjectSample".users';

// GET
router.get('/', function(req, res, next) {
  res.render('login', { title: 'Login User', error: false });
});

// POST
router.post('/', function(req, res, next) {
  // Retrieve Information
  var email = req.body.email;
  var password = req.body.password;

  // Construct Specific SQL Query
  // var retrieve_query = "select name from customer_info where email = 'test@email.com'";
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
        name: data.rows[0].username,
        email: data.rows[0].email,
        accountType: data.rows[0].accounttype,
        isLogIn: true
      };

      req.app.locals.user = user;

      if (user.accountType == 'Customer') {
        res.redirect('/');
      }

      if (user.accountType == 'Manager') {
        res.redirect('/manageRestaurant');
      }
    }
  });
});

module.exports = router;
