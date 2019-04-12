var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});


/* SQL Query */
var allDishesQuery;
var allRestaurantsQuery;
var restaurantName;

router.get('/', function (req, res, next) {
    if (req.app.locals.user == null || req.app.locals.user.accountType != 'GeneralManager') {
        res.redirect("/login");
    } else {
        email = req.app.locals.user.email;
        allDishesQuery = "SELECT * FROM Restaurant.MenuItem NATURAL JOIN Restaurant.restaurant WHERE generalmanageremail='" + email + "' ORDER BY restaurantname, menuname;";
        allRestaurantsQuery = "SELECT restaurantname FROM RESTAURANT.Restaurant WHERE generalmanageremail='" + email + "';";
        pool.query(allDishesQuery, (err, data1) => {
            pool.query(allRestaurantsQuery, (err, data2) => {
                restaurantName = data2.rows[0].restaurantname;
                res.render('listDishes', { title: 'List Dishes', dish: data1.rows, restaurantName: data2.rows });
                console.log(data1.rows);
            });
        });
    }
});

router.post('/', function (req, res, next) {
    var flag = req.body.flag;
    if (flag == "edit") {
        var menuname = req.body.menuname;
        res.redirect(url.format({
            pathname: "/editDish",
            query: { menuname: menuname, restaurantname: restaurantName }
        }));
    } else if (flag == "remove") {
        var menuname = req.body.menuname;
        var deleteQuery = "DELETE FROM RESTAURANT.MenuItem WHERE menuname = '" + menuname + "' AND restaurantname ='" + restaurantName + "';";
        pool.query(deleteQuery, (err, data) => {
            console.log(data);
            console.log(err);
            res.redirect("/listdishes");
        });
    } else {
        var menuName = req.body.menuName;
        var price = req.body.price;
        var rawCuisineName = req.body.cuisineName;
        var cuisineName = rawCuisineName.replace(/'/g, "''");
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
                res.redirect("/listdishes");
            });
        });
    }



});

module.exports = router;