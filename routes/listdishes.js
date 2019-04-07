var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


/* SQL Query */
var allDishesQuery = 'SELECT * FROM Restaurant.MenuItem ORDER BY restaurantName, menuName';
var allRestaurantsQuery = 'SELECT restaurantName FROM RESTAURANT.Restaurant';

router.get('/', function (req, res, next) {
	pool.query(allDishesQuery, (err, data1) => {
        pool.query(allRestaurantsQuery, (err,data2) => {
            res.render('listDishes', { title: 'List Dishes', dish: data1.rows, restaurantName : data2.rows });
        console.log(data1.rows);
        console.log(data2.rows);
        });
	});
});

router.post('/', function (req, res, next) {
    var restaurantName = req.body.restaurantName;
    var menuName = req.body.menuName;
    var price = req.body.price;
    var cuisineName = req.body.cuisineName;

    var insertQuery = "INSERT INTO RESTAURANT.MenuItem values ('" +
    restaurantName + 
    "','"
    menuName + 
    "','" +
    price +
    "','" +
    cuisineName +
    "')";
    pool.query(insertManagerQuery, (err, data) => {
        res.render('listdishes');
    });
});

module.exports = router;