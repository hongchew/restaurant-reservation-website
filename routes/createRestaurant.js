var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

var user;

router.get('/', function(req, res, next) {
    user = req.app.locals.user;
    console.log(user);
    if(user.accountType != 'Admin'){
      res.redirect("/login");
    }
    var query = "select  * from restaurant.restaurant";
    pool.query(query, (err, data)=>{
        if(err){
            console.log("***Err ALL_REST: " + err.message);
        }
        console.log(data.rows);
        res.render('createRestaurant', {title: 'Restaurants Administration', data:data.rows});
    });
    ;
});

router.post('/', function(req, res, next){
    var flag = req.body.flag;
    
    if(flag == 'create'){
        var restaurantname = req.body.restaurantname;
        var gmemail = req.body.gmemail;
        var gmname = req.body.gmname;
        var gmpassword = req.body.gmpassword;


        var query = "Insert into RESTAURANT.Users  (email,name,password,accountType) VALUES('" + gmemail + "','" + gmname + "','" + gmpassword + "','GeneralManager');";
        console.log(query);
        pool.query(query, (err, data)=>{
            if(err){
                console.log("***Err CREATE_GM: " + err.message);
            }
            var query = "Insert into RESTAURANT.Restaurant (restaurantName, generalManagerEmail) VALUES('" + restaurantname +"','" + gmemail +"');";
            console.log(query);
            pool.query(query, (err, data)=>{
                if(err){
                    console.log("***Err CREATE_REST: " + err.message);
                }
                res.redirect('createRestaurant');
            });
        });
    }else if(flag == 'delete'){

        var deletename = req.body.restauranttodelete;
        var query = "Delete from restaurant.restaurant where restaurantname = '" + deletename + "';";
        console.log(query);
        pool.query(query, (err, data) =>{
            if(err){
                console.log("***Err DELETE_REST: " + err.message);
            }
            res.redirect('createRestaurant');
        });
    }
});

module.exports = router;