var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

var email
var pastReservations = null;
var upcomingReservation = null;
var submitFeedbackReservation = null;
router.get('/', function (req, res, next) {
  email = req.app.locals.user.email;
  var customer = req.app.locals.user;
  if (!customer.email) {
    res.redirect("/login");
  }
  var pastReservationsQuery = "select r.reservationId, r.restaurantName, r.branchArea, r.mealTypeName, to_char(r.vacancyDate, ' Day DD-Mon-YYYY') as vacancydate, case when status = 1 then 'Fulfilled' when status = -1 then 'No Show' end as status, r.numdiner, (select 1 from restaurant.feedback where reservationid = r.reservationid) as checkfeedback from restaurant.reservation r where status <> 0 and r.customeremail = '" + email + "';";
  /*   var pastReservationsQuery =
      "SELECT r.reservationId, r.restaurantName, r.branchArea, r.mealTypeName, to_char(r.vacancyDate, ' Day DD-Mon-YYYY') as vacancyDate, r.numDiner, COALESCE(f.feedbackid,0) as feedback FROM RESTAURANT.Reservation r join RESTAURANT.Customer c on r.customerEmail = c.customerEmail LEFT JOIN RESTAURANT.Feedback f on f.reservationId=r.reservationId WHERE c.customerEmail = '" +
      email +
      "' AND r.vacancyDate < NOW() ORDER BY r.vacancyDate"; */

  /*   var upcomingReservationsQuery =
      "SELECT r.reservationId, r.restaurantName, r.branchArea, r.mealTypeName, to_char(r.vacancyDate, 'Day DD-Mon-YYYY') as vacancyDate, r.numDiner FROM RESTAURANT.Reservation r join RESTAURANT.Customer c on r.customerEmail = c.customerEmail WHERE c.customerEmail = '" +
      email +
      "' AND r.vacancyDate >= NOW() ORDER BY r.vacancyDate"; */

  var upcomingReservationsQuery = "SELECT r.reservationid, r.restaurantname, r.brancharea, r.mealtypename, to_char(r.vacancydate, 'Day DD-Mon-YYYY') as vacancydate, r.numdiner FROM restaurant.reservation r where r.status = 0 and r.customeremail = '" + email + "';";

  var submitFeedbackQuery = "select r.reservationid, r.restaurantname, r.brancharea, r.mealtypename, to_char(r.vacancydate, 'Day DD-Mon-YYYY') as vacancydate, r.numdiner from restaurant.reservation r where not exists (select 1 from restaurant.feedback f where  f.reservationid = r.reservationid) and r.status = 1 and r.customeremail = '" + email + "';";
  pool.query(pastReservationsQuery, (err, data) => {
    pastReservations = data;
    console.log(data.rows);

    pool.query(upcomingReservationsQuery, (err, data) => {
      console.log(data.rows);
      upcomingReservation = data;

      pool.query(submitFeedbackQuery, (err, data) => {
        submitFeedbackReservation = data;
        console.log(data.rows);

        res.render('userInfo', {
          title: 'Reservation Records',
          user: customer,
          data3: submitFeedbackReservation.rows,
          data2: upcomingReservation.rows,
          data1: pastReservations.rows
        });
      });
    });
  });
});



  router.post('/', function(req, res, next) {
    flag = req.body.flag;
    if(flag == 'submit'){
      if (req.body.feedbackIndex != null) {
        var index = parseInt(req.body.feedbackIndex);
        var restaurantName = submitFeedbackReservation.rows[index].restaurantname;
        var reservationId = submitFeedbackReservation.rows[index].reservationid;
        var branchArea  = submitFeedbackReservation.rows[index].brancharea;
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
    }else if(flag == 'view'){
      var viewFeedbackId = parseInt(req.body.viewFeedbackId);
      res.redirect(url.format({
        pathname: "/viewFeedback",
        query: {viewFeedbackId: viewFeedbackId}
      }))

    }else if(flag == 'remove'){
      var query = "delete from restaurant.reservation where reservationid =  " ;
      var deleteId = req.body.reservationToDeleteId;
      query = query + deleteId + ";";
      console.log(query);
      pool.query(query, (err, data)=>{
        if(err){
          console.log("***DELETE Err: " + err.message);
        }
        res.redirect("/userInfo");
      })
    }else if(flag == 'edit'){
      var editReservationId = req.body.reservationToEditId;
      res.redirect(url.format({
        pathname: "/editReservation",
        query: {editReservationId: editReservationId}
      }))
    }
});

module.exports = router;
