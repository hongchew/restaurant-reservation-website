var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});

//SQL Queries
var sql_query = 'SELECT * FROM Restaurant.Reservation WHERE ';
var table;

module.exports = router;


router.get('/', function (req, res, next) {
	console.log("***GET listBooking.js ");
	pool.query(sql_query, (err, data) => {
		table = data.rows;
		res.render('listRestaurant', { title: 'Restaurants Available', data: data.rows });
		console.log(data.rows);
	});
});