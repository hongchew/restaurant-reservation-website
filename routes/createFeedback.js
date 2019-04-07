var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});
var restaurantName;
var branchArea;
var reservationId;
var user;

// GET
router.get('/', function(req, res, next) {
  restaurantName = req.query.restaurantName;
  reservationId = req.query.reservationId;
  branchArea = req.query.branchArea;
  user = req.app.locals.user;
  if (user.isLogin == true) {
    res.render('createFeedback', { ...req.query });
  } else {
    res.redirect('login');
  }
});

// POST
router.post('/', function(req, res, next) {
  console.log('*************************');
  console.log(req.body);
  console.log('*****Document*******');
  var rating = req.body.rating;
  reservationId = parseInt(reservationId);
  var comments = req.body.comments;
  console.log(rating);
  var insert_query =
    "INSERT INTO RESTAURANT.Feedback (reservationId, rating, comments) VALUES ('" +
    reservationId +
    "', '" +
    rating +
    "', '" +
    comments +
    "')";
  pool.query(insert_query, (err, data) => {
    console.log(err);
    console.log("*********** HERE'S THE ERROR ABOVE*****************");
    res.redirect('/listRestaurant'); /********Change route too!!!********* */
  });
});

module.exports = router;
