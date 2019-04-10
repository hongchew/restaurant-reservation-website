var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});


router.get('/', function(req, res, next) {
    var menuname = req.query.menuname;
    var restaurantname = req.query.restaurantname;
    console.log(menuname);
    console.log(restaurantname);
    var query = "select restaurantname, menuname, price, cuisinename from restaurant.menuitem where restaurantname = '" + restaurantname + "' and menuname = '" + menuname + "';";
    console.log(query);
    pool.query(query, (err, data)=>{
        if(err){
            console.log("***Err EDIT :" + err.message);
        }
        console.log(data.rows);
        res.render('editDish', {title: "Edit Dish", editDish: data.rows });
    })
    

});

router.post('/', function(req, res, next) {

    var updatedprice = req.body.updateprice;
    var menuname = req.body.menuname;
    var restaurantname = req.body.restaurantname;
    console.log(updatedprice);
    console.log(menuname);
    console.log(restaurantname);
 
    var updateQuery = "UPDATE RESTAURANT.MenuItem set price = '" + updatedprice + "' where menuname = '" + menuname + "' and restaurantname = '" + restaurantname+ "';";
    console.log(updateQuery);
    pool.query(updateQuery, (err, data)=>{
        if(err){
            console.log("***Err EDIT: " + err.message);
        }
        res.redirect("/listDishes");
    })

});

module.exports = router;