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

router.get('/', function (req, res, next) {
	console.log("hello");
	user = req.app.locals.user;
	var region = req.app.locals.user;
	region = req.query.regionName;
	openingHour = req.query.openingHour;
	closingHour = req.query.closingHour;
	console.log(req.query.regionName);
	console.log(req.query.openingHour);
	console.log(req.query.closingHour);
	if(region != null)
	{
		console.log("region query");
		sql_query ="SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE regionName = '" + region +"' ORDER BY restaurantName,branchArea ASC;";
	} else if (openingHour != null)
	{
		sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE openingHour < 1030 ORDER BY restaurantName,branchArea ASC;";
	} else if (closingHour != null) 
	{
		if(closingHour == 'Lunch'){
		sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE closingHour > 1200  and openingHour < 1300 ORDER BY restaurantName,branchArea ASC;";
		} else {
			sql_query = "SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant WHERE closingHour > 1900 ORDER BY restaurantName,branchArea ASC;";
		}
	} else 
	{
		console.log("else")
		sql_query = 'SELECT * FROM Restaurant.Branch natural join Restaurant.Restaurant ORDER BY restaurantName,branchArea ASC';
	}
	
		if (user.isLogin == true) {
		pool.query(sql_query, (err, data) => {
			table = data.rows;
			// console.log(table);
			res.render('listRestaurant', { title: 'Restaurants Available', data: data.rows });
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
	console.log(req.body.searchValueInput);
	console.log("***done print**");
	// console.log(req.body.reservationIndex);
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
	} else if (req.body.viewDetails != null) 
	{
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
	} else if (req.body.searchValueinput != null) /* NOT FUNCTIONING!!!! */
	{
		var search = req.body.searchValueinput;
		console.log("***Inside Search***");
		res.redirect(url.format({
			pathname: "/listRestaurant",
			query: search
		}));
	}
	console.log(req.body.searchValueInput);

})

module.exports = router;