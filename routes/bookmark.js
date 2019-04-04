var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


/* SQL Query */
var email = "cust1@gmail.com";
var sql_query = "'SELECT * FROM Restaurant.Bookmark WHERE email='"+ email +"' ORDER BY restaurantName,branchArea ASC'";
var table;

router.get('/', function (req, res, next) {
	console.log("hello");
	pool.query(sql_query, (err, data) => {
		table = data.rows;
		res.render('listRestaurant', { title: 'Bookmarks', data: data.rows });
		console.log(data.rows);
	});
});

router.post('/', function (req, res, next) {
	console.log("***** refresh page ********")
	console.log(req.body.bookmarkIndex);
	console.log(req.body.reservationIndex);
	// console.log(req.body.reservationIndex);
	if (req.body.reservationIndex == null) { //ADD BOOKMARK
		var index = parseInt(req.body.bookmarkIndex);
		var email = "cust1@gmail.com"; // ********************************change******************
		var restaurantName = table[index].restaurantname;
		var branchArea = table[index].brancharea;

		var insert_query = "INSERT INTO RESTAURANT.bookmark (customerEmail, restaurantName, branchArea) VALUES ('" + email + "', '" + restaurantName + "', '" + branchArea + "');";
		console.log(insert_query);

		pool.query(insert_query, (err, data) => {
			console.log(err);
			res.redirect('/listRestaurant');
		})
	} else //making reservation.
	{
		var index = parseInt(req.body.reservationIndex);
		var email = "cust1@gmail.com"; // ********************************change******************
		var restaurantName = table[index].restaurantname;
		var branchArea = table[index].brancharea;

		var passInfo ={
			email: email,
			restaurantName: restaurantName,
			branchArea: branchArea
		}
		
		res.redirect(url.format({
			pathname: "/createReservation",
			query: passInfo
		}));
	}



})


function addBookmark(button) { //not working !

	alert(button.parentNode.parentNode.rowIndex);
}

module.exports = router;