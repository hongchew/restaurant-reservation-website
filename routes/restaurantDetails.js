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

// GET
router.get('/', function (req, res, next) {
    restaurantName = req.query.restaurantName;
    branchArea = req.query.branchArea;
    user = req.app.locals.user;

    var restaurantQuery = "SELECT * FROM Restaurant.Branch WHERE restaurantName = '" + restaurantName + "' and branchArea = '" + branchArea + "';";
    var menuQuery = "SELECT * FROM Restaurant.menuItem WHERE restaurantName = '" + restaurantName +"' ORDER BY cuisinename, price ASC;"; 
    var avgpriceQuery = "SELECT avgPrice FROM Restaurant.restaurant WHERE restaurantName = '" + restaurantName +"';";

    if (user.isLogin == true) {
		pool.query(restaurantQuery, (err, restaurantData) => {
            restaurantDetails = restaurantData.rows;
            console.log(restaurantDetails);
        });
        pool.query(avgpriceQuery, (err, avgPriceData) => {
            avgPrice = avgPriceData.rows;
            console.log(restaurantDetails);
        });

        pool.query(menuQuery, (err, menuData) => {
            menuItems = menuData.rows;
            // console.log(menuItems);
			res.render('restaurantDetails', { title: 'Restaurant Details', data: restaurantDetails, menu: menuItems, avgPrice: avgPrice});
        });
        
	} else {
		res.redirect('login');
	}
});


// // POST
// router.post('/', function (req, res, next) {
    

// });

module.exports = router;
