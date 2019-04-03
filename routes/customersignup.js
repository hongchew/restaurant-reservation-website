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


router.get('/', function(req, res, next) {
  res.render('customerSignup', {  });
});

// POST
router.post('/', function(req, res, next) {
  console.log("test");
	
  var name    = req.body.name;
  var email = req.body.email;
  var password = req.body.password;
  var accountType = "customer";
  console.log(name);
  var sql_query = 'INSERT INTO RESTAURANT.Users VALUES';
	
	// // Construct Specific SQL Query
	var insert_query = sql_query + "('" + email + "','" + name + "','" + password + "','" + accountType + "')";
	
	pool.query(insert_query, (err, data) => {
    console.log(err);
		res.redirect('/listrestaurant')
	});
});

module.exports = router;
