var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

/* --- V7: Using dotenv     --- */
require('dotenv').load();



/ *--- Routers --- */
var usersRouter = require('./routes/users');
var indexRouter = require('./routes/index');
var loginRouter = require('./routes/login');
var adminRouter = require('./routes/admin');
var viewFeedbackRouter = require('./routes/viewFeedback');
var editReservationRouter = require('./routes/editReservation');
var customerSignupRouter = require('./routes/customersignup');
var mainGeneralManager = require('./routes/mainGeneralManager');
var listRestaurantRouter = require('./routes/listRestaurant');
var createReservationRouter = require('./routes/createReservation');
var userInfo = require('./routes/userInfo');
var createManager = require('./routes/createManager');
var listBookingsRouter =  require('./routes/listBookings');
var bookmarkRouter = require('./routes/bookmark');
var listDishes = require('./routes/listdishes');
var restaurantDetailsRouter = require('./routes/restaurantDetails');
var createFeedbackRouter = require('./routes/createFeedback');
var editDishRouter = require('./routes/editDish');
var createRestaurantRouter = require('./routes/createRestaurant');
var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));



/* --- V6: Modify Database  --- */
var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
/* ---------------------------- */
app.use('/', indexRouter);
app.use('/users', usersRouter);
app.use('/login', loginRouter);
app.use('/admin', adminRouter);
app.use('/customersignup', customerSignupRouter);
app.use('/mainGeneralManager', mainGeneralManager);
app.use('/listRestaurant', listRestaurantRouter);
app.use('/createReservation', createReservationRouter);
app.use('/listBookings', listBookingsRouter);
app.use('/userInfo', userInfo);
app.use('/createManager', createManager);
app.use('/bookmark', bookmarkRouter);
app.use('/listDishes', listDishes);
app.use('/restaurantDetails', restaurantDetailsRouter);
app.use('/createFeedback', createFeedbackRouter);
app.use('/viewFeedback', viewFeedbackRouter)
app.use('/editReservation', editReservationRouter)
app.use('/editDish', editDishRouter);
app.use('/createRestaurant', createRestaurantRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

//Global varaible
app.locals.user = {
  email: null,
  name: null,
  accountType: null,
  isLogIn: false
}
app.locals.reservationStatus = {
  error: false
}

module.exports = app;
