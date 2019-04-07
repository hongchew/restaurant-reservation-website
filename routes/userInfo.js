var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

var email = 'cust1@gmail.com';
var pastReservations = null;
var upcomingReservation = null;
router.get('/', function(req, res, next) {
  var customer = req.app.locals.user;
  var pastReservationsQuery =
    "SELECT r.reservationId, r.restaurantName, r.branchArea, r.mealTypeName, r.vacancyDate, r.numDiner, COALESCE(f.feedbackid,0) as feedback FROM RESTAURANT.Reservation r join RESTAURANT.Customer c on r.customerEmail = c.customerEmail LEFT JOIN RESTAURANT.Feedback f on f.reservationId=r.reservationId WHERE c.customerEmail = '" +
    email +
    "' AND r.vacancyDate < NOW() ORDER BY r.vacancyDate";

  var upcomingReservationsQuery =
    "SELECT r.reservationId, r.restaurantName, r.branchArea, r.mealTypeName, r.vacancyDate, r.numDiner FROM RESTAURANT.Reservation r join RESTAURANT.Customer c on r.customerEmail = c.customerEmail WHERE c.customerEmail = '" +
    email +
    "' AND r.vacancyDate >= NOW() ORDER BY r.vacancyDate";

  pool.query(pastReservationsQuery, (err, data) => {
    pastReservations = data;
    console.log(data.rows.feedback);
    pool.query(upcomingReservationsQuery, (err, data) => {
      console.log(data.rows);
      upcomingReservation = data;
      res.render('userInfo', {
        title: 'User Information',
        user: customer,
        data2: upcomingReservation.rows,
        data1: pastReservations.rows
      });
    });
  });
  router.post('/', function(req, res, next) {
    if (req.body.feedbackIndex != null) {
      var index = parseInt(req.body.feedbackIndex);
      var restaurantName = pastReservations.rows[index].restaurantname;
      var reservationId = pastReservations.rows[index].reservationid;
      var branchArea  = pastReservations.rows[index].brancharea;
      var passInfo = {
        restaurantName: restaurantName,
        reservationId: reservationId,
        branchArea: branchArea
      };

      res.redirect(url.format({
        pathname: "/createFeedback",
        query: passInfo
      }));
    }
  });
});

module.exports = router;
