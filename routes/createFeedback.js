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
  if (req.app.locals.user == null || req.app.locals.user.accountType != 'Customer') {
    res.redirect('login');
  } else {
    res.render('createFeedback', { ...req.query });
  }
});

// POST
router.post('/', function(req, res, next) {
  console.log('*************************');
  console.log(req.body);
  console.log('*****Document*******');
  var rating = req.body.rating;
  reservationId = parseInt(reservationId);
  var rawComments = req.body.comments;
  var comments = rawComments.replace(/'/g,"''");
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
