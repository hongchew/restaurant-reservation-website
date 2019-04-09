var express = require('express');
var router = express.Router();
const url = require('url');    



const { Pool } = require('pg')

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});
var restaurantName;
var branchArea;
var user;
var restaurantDetails;
var menuItems;
var avgPrice;
var feedbackList;

// GET
router.get('/', function (req, res, next) {
    restaurantName = req.query.restaurantName;
    branchArea = req.query.branchArea;
    user = req.app.locals.user;

    var restaurantQuery = "SELECT * FROM Restaurant.Branch WHERE restaurantName = '" + restaurantName + "' and branchArea = '" + branchArea + "';";
    var menuQuery = "SELECT * FROM Restaurant.menuItem WHERE restaurantName = '" + restaurantName +"' ORDER BY cuisinename, price ASC;"; 
    var avgpriceQuery = "SELECT avgPrice FROM Restaurant.restaurant WHERE restaurantName = '" + restaurantName +"';";
    var feedbackQuery = "SELECT customeremail, comments, rating FROM Restaurant.Reservation NATURAL JOIN Restaurant.Feedback WHERE restaurantname = '" + restaurantName + "' AND brancharea = '" + branchArea + "' ORDER BY feedbackId DESC;";

    if (user.isLogin == true) {
		pool.query(restaurantQuery, (err, restaurantData) => {
            restaurantDetails = restaurantData.rows;
            // console.log(restaurantDetails);
        });
        pool.query(avgpriceQuery, (err, avgPriceData) => {
            avgPrice = avgPriceData.rows;
            // console.log(restaurantDetails);
        });
        pool.query(feedbackQuery, (err, feedbackData) => {
            feedbackList = feedbackData.rows;
            console.log(feedbackList);
        });

        pool.query(menuQuery, (err, menuData) => {
            menuItems = menuData.rows;
            // console.log(menuItems);
			res.render('restaurantDetails', { title: 'Restaurant Details', data: restaurantDetails, menu: menuItems, avgPrice: avgPrice, feedbacks: feedbackList});
        });
        
	} else {
		res.redirect('login');
	}
});


// // POST
// router.post('/', function (req, res, next) {
    

// });

module.exports = router;
