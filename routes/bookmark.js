var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


/* SQL Query */

var sql_query;
var table;
var user;
var restaurantName
var branchArea

router.get('/', function (req, res, next) {
	user = req.app.locals.user;
	sql_query = " SELECT * FROM RESTAURANT.Bookmark NATURAL JOIN Restaurant.Branch NATURAL JOIN Restaurant.restaurant WHERE customeremail ='" + user.email + "';";
	console.log("hello");
	user = req.app.locals.user;
	if (user.isLogin == true) {
		pool.query(sql_query, (err, data) => {
			table = data.rows;
			// console.log(table);
			res.render('bookmark', { title: 'Bookmarked Restaurants', data: data.rows });
		});
	} else {
		res.redirect('login');
	}
});


router.post('/', function (req, res, next) {
	console.log("***** refresh page ********")
	console.log(req.body.bookmarkIndex);
	console.log(req.body.reservationIndex);
	console.log(req.body.viewDetails);
	// console.log(req.body.reservationIndex);
	if (req.body.bookmarkIndex != null) { //ADD BOOKMARK
		console.log("**inside***");
		var index = parseInt(req.body.bookmarkIndex);
		var email = req.app.locals.user.email; // ********************************change******************
		restaurantName = table[index].restaurantname;
		console.log("**enddd***");
		branchArea = table[index].brancharea;

		var delete_query = "DELETE FROM RESTAURANT.Bookmark WHERE customerEmail ='" + req.app.locals.user.email + "' and restaurantName = '" + restaurantName + "' and branchArea = '" + branchArea + "';";

		pool.query(delete_query, (err, data) => {
			console.log(err);
			
			res.redirect('/Bookmark');
		})
	} else if (req.body.reservationIndex != null) //making reservation.
	{
		var index = parseInt(req.body.reservationIndex);
		var email = req.app.locals.user.email; // ********************************change******************
		restaurantName = table[index].restaurantname;
		branchArea = table[index].brancharea;

		var passInfo = {
			restaurantName: restaurantName,
			branchArea: branchArea
		}

		res.redirect(url.format({
			pathname: "/createReservation",
			query: passInfo
		}));
	} else if (req.body.viewDetails != null) {
		var index = parseInt(req.body.viewDetails);
		restaurantName = table[index].restaurantname;
		branchArea = table[index].brancharea;

		var passInfo = {
			restaurantName: restaurantName,
			branchArea: branchArea
		}

		res.redirect(url.format({
			pathname: "/restaurantDetails",
			query: passInfo
		}));
	}
})
module.exports = router;