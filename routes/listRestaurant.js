var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')
// --- V7: Using Dot Env ---
// const pool = new Pool({
//   user: 'postgres',
//   host: 'localhost',
//   database: 'postgres',
//   password: '********',
//   port: 5432,
// })

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


/* SQL Query */
var sql_query
var table;
var user;
var restaurantName
var branchArea
var failRestaurant
var failBranch
var failDate
var failVacancy

router.get('/', function (req, res, next) {
	console.log("hello");
	user = req.app.locals.user;
	var region = req.app.locals.user;
	region = req.query.regionName;
	openingHour = req.query.openingHour;
	closingHour = req.query.closingHour;
	var searchTerm = req.query.searchWord;
	var errorMessage = req.query.errorMessage;
	var booleanError = false;
	console.log(req.query);
	// console.log(req.query.regionName);
	// console.log(req.query.openingHour);
	// console.log(req.query.closingHour);
	console.log(req.query.searchTerm);
	console.log(searchTerm);

	if (region != null) {
		console.log("region query");
		sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE regionName = '" + region + "' ORDER BY restaurantName,branchArea ASC;";
	} else if (openingHour != null) {
		sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE openingHour < 1030 ORDER BY restaurantName,branchArea ASC;";
	} else if (closingHour != null) {
		if (closingHour == 'Lunch') {
			sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE closingHour > 1200  and openingHour < 1300 ORDER BY restaurantName,branchArea ASC;";
		} else {
			sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE closingHour > 1900 ORDER BY restaurantName,branchArea ASC;";
		}
	} else if (searchTerm != null) {
		sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE branchArea ILIKE '%" + searchTerm + "%' OR restaurantName ILIKE '%" + searchTerm + "%' ORDER BY restaurantName,branchArea ASC;";
	} else if (errorMessage != null) {
		booleanError = true;
		failRestaurant = req.query.failRestaurant;
		failBranch = req.query.failBranch;
		failDate = req.query.failDate;
		failVacancy = req.query.failVacancy;

	} else {
		console.log("else")
		sql_query = 'SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant ORDER BY restaurantName,branchArea ASC';
	}

	if (req.app.locals.user == null || req.app.locals.user.accountType != 'Customer') {
		res.redirect('login');
	} else {

		pool.query(sql_query, (err, data) => {
			table = data.rows;
			// console.log(table);
			res.render('listRestaurant', { title: 'Restaurants Available', data: data.rows, error: booleanError, restaurant: failRestaurant, branch: failBranch, date: failDate, vacancy: failVacancy });

		});
	}
});

router.post('/', function (req, res, next) {
	req.app.locals.reservationStatus.error = false;
	console.log("***** refresh page ********")
	console.log(req.body.bookmarkIndex);
	console.log(req.body.reservationIndex);
	console.log(req.body.viewDetails);
	console.log(req.body.searchValueInput);
	console.log("***done print**");
	// console.log(req.body.reservationIndex);
	var test = req.body.searchValueInput;
	console.log("Printing...." + test);
	if (req.body.bookmarkIndex != null)  //ADD BOOKMARK
	{
		console.log("**inside***");
		var index = parseInt(req.body.bookmarkIndex);
		var email = req.app.locals.user.email; // ********************************change******************
		restaurantName = table[index].restaurantname;
		console.log("**enddd***");
		branchArea = table[index].brancharea;

		var insert_query = "INSERT INTO RESTAURANT.bookmark (customerEmail, restaurantName, branchArea) VALUES ('" + email + "', '" + restaurantName + "', '" + branchArea + "');";
		console.log(insert_query);

		pool.query(insert_query, (err, data) => {
			console.log(err);

			res.redirect('/listRestaurant');
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
	} else if (test.length > 0) /* NOT FUNCTIONING!!!! */ {
		// var search = req.body.searchValueinput;
		console.log("***Inside Search***");

		var passInfo = {
			searchWord: test
		}

		res.redirect(url.format({
			pathname: "/listRestaurant",
			query: passInfo
		}));


	}
	console.log(req.body.searchValueInput);

})

module.exports = router;