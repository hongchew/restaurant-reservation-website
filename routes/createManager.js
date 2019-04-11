var express = require('express');
var router = express.Router();
const { Pool } = require('pg');
const pool = new Pool({
    connectionString:process.env.DATABASE_URL
});

var restaurantName;

router.get('/', function(req, res, next) {
  if(req.app.locals.user == null || req.app.locals.user.accountType != 'GeneralManager'){
    res.redirect("/login");
  } else {
    res.render('createManager');
  }
  
});

// POST
router.post('/', function(req, res, next) {
  var generalManagerEmail =req.app.locals.user.email;

  var getRestaurantNameQuery = "SELECT restaurantName FROM RESTAURANT.Restaurant WHERE generalManagerEmail ='" + generalManagerEmail + "';";
  console.log("Before insert query for create manager");
  pool.query(getRestaurantNameQuery, (err,data) => {
    if(data.rows.length ==0) {
        console.log("General Manager is not associated with any Restaurants")
    } else{
        restaurantName = data.rows[0].restaurantname; 
        console.log(restaurantName);

        var name = req.body.name;
        var email = req.body.email;
        var rawbranchArea = req.body.brancharea;
        var branchArea = rawbranchArea.replace(/'/g,"''");
        var password = req.body.password;
        var accountType = 'Manager';
        var regionName = req.body.regionname;
        var address = req.body.address;
        var openingHour = req.body.openinghour;
        var closingHour = req.body.closinghour;
        var capacity = req.body.capacity;
        console.log("*****printing body******");
      
        var retrieve_query =
        "select * from RESTAURANT.Users WHERE email = '" + email + "';";
      
      
        var insertManagerQuery =
        "INSERT INTO RESTAURANT.Users VALUES" +
          "('" +
          email +
          "','" +
          name +
          "','" +
          password +
          "','" +
          accountType +
          "');";
      
        var insertBranchQuery = "INSERT INTO RESTAURANT.Branch VALUES" + "('" + restaurantName +
          "','" +
          branchArea +
          "','" +
          regionName +
          "','" +
          email +
          "','" +
          address +
          "','" +
          openingHour +
          "','" +
          closingHour +
          "','" +
          capacity +
          "','" +
          0.0 +
          "');";

          console.log("before entering insert query");
          pool.query(retrieve_query, (err, data) => {
            console.log(data.rows);
            if (data.rows[0] == null) {
              pool.query(insertManagerQuery, (err, data) => {
              });
            }
              pool.query(insertBranchQuery, (err, data) => {
                res.redirect('/listdishes'); 
              });
          });
    }
  });


 
  
  
});

module.exports = router;
