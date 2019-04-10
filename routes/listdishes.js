var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});


/* SQL Query */
var allDishesQuery = 'SELECT * FROM Restaurant.MenuItem ORDER BY restaurantname, menuname;';
var allRestaurantsQuery = 'SELECT restaurantname FROM RESTAURANT.Restaurant;';

router.get('/', function (req, res, next) {
    pool.query(allDishesQuery, (err, data1) => {
        pool.query(allRestaurantsQuery, (err, data2) => {
            res.render('listDishes', { title: 'List Dishes', dish: data1.rows, restaurantName: data2.rows });
            console.log(data1.rows);
            console.log(data2.rows);
        });
    });
});

router.post('/', function (req, res, next) {
    var flag = req.body.flag;
    if (flag == "edit") {
        var menuname = req.body.menuname;
        var restaurantname = req.body.restaurantname;
        res.redirect(url.format({
          pathname: "/editDish",
          query: {menuname: menuname , restaurantname: restaurantname}
        }));
    } else if (flag == "remove") {
        var menuname = req.body.menuname;
        var restaurantname = req.body.restaurantname;
        var deleteQuery = "DELETE FROM RESTAURANT.MenuItem WHERE menuname = '" + menuname + "' AND restaurantname ='" + restaurantname + "';";
        pool.query(deleteQuery, (err,data) => {
            console.log(data);
            console.log(err);
            pool.query(allDishesQuery, (err, data1) => {
                pool.query(allRestaurantsQuery, (err, data2) => {
                    res.render('listDishes', { title: 'List Dishes', dish: data1.rows, restaurantName: data2.rows });
                    console.log(data1.rows);
                    console.log(data2.rows);
                });
            });
        });
    } else {
        var restaurantName = req.body.restaurantName;
        var menuName = req.body.menuName;
        var price = req.body.price;
        var cuisineName = req.body.cuisineName;
        console.log(restaurantName);
        console.log(menuName);
        console.log(price);
        console.log(cuisineName);

        var insertQuery = "INSERT INTO RESTAURANT.MenuItem VALUES('" +
            restaurantName +
            "','" +
            menuName +
            "','" +
            price +
            "','" +
            cuisineName +
            "');";
        pool.query(insertQuery, (err, data) => {
            console.log(data);
            console.log(err);
        });
        pool.query(allDishesQuery, (err, data1) => {
            pool.query(allRestaurantsQuery, (err, data2) => {
                console.log(data1.rows);
                console.log(data2.rows);
                res.render('listDishes', { title: 'List Dishes', dish: data1.rows, restaurantName: data2.rows });
            });
        });
    }



});

module.exports = router;