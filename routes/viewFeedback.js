var express = require('express');
var router = express.Router();
const url = require('url');    

const { Pool } = require('pg')

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

router.get('/', function(req, res, next) {
    reservationId = parseInt(req.query.viewFeedbackId);
    user = req.app.locals.user; 

    if (!user.isLogin) {
      res.redirect('login');
    }
    
    var query = "select f.restaurantName, f.branchArea, f.mealTypeName, to_char(f.vacancyDate, 'Day DD-Mon-YYYY') as vacancyDate, f.comments, f.rating from (restaurant.feedback natural join restaurant.reservation) f where f.reservationid = " +  reservationId + ";";
    pool.query(query, (err, data) =>{
        feedbackdata = data.rows[0];
        console.log(feedbackdata);
        res.render('viewFeedback', {title: 'View Feedback Details', feedbackdata: feedbackdata});
    })
  });

module.exports = router;