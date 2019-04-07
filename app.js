var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

/* --- V7: Using dotenv     --- */
require('dotenv').load();

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

/* --- V2: Adding Web Pages --- */
var aboutRouter = require('./routes/about');
/* ---------------------------- */

/* --- V3: Basic Template   --- */
var tableRouter = require('./routes/table');
var loopsRouter = require('./routes/loops');
/* ---------------------------- */

/* --- V4: Database Connect --- */
var selectRouter = require('./routes/select');
/* ---------------------------- */

/* --- V5: Adding Forms     --- */
var formsRouter = require('./routes/forms');
/* ---------------------------- */

/* --- V6: Modify Database  --- */
var insertRouter = require('./routes/insert');
/* ---------------------------- */
var loginRouter = require('./routes/login');
var adminRouter = require('./routes/admin');

var customerSignupRouter = require('./routes/customersignup');

var createGeneralManager = require('./routes/createGeneralManager');
var listRestaurantRouter = require('./routes/listRestaurant');
var createReservationRouter = require('./routes/createReservation');

var userInfo = require('./routes/userInfo');
var createManager = require('./routes/createManager');

var listBookingsRouter =  require('./routes/listBookings');
var bookmarkRouter = require('./routes/bookmark');

var listDishes = require('./routes/listdishes');
var restaurantDetailsRouter = require('./routes/restaurantDetails');
var createFeedbackRouter = require('./routes/createFeedback');
var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);

/* --- V2: Adding Web Pages --- */
app.use('/about', aboutRouter);
/* ---------------------------- */

/* --- V3: Basic Template   --- */
app.use('/table', tableRouter);
app.use('/loops', loopsRouter);
/* ---------------------------- */

/* --- V4: Database Connect --- */
app.use('/select', selectRouter);
/* ---------------------------- */

/* --- V5: Adding Forms     --- */
app.use('/forms', formsRouter);
/* ---------------------------- */
app.use('/login', loginRouter);
app.use('/admin', adminRouter);

/* --- V6: Modify Database  --- */
var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/insert', insertRouter);
/* ---------------------------- */

app.use('/customersignup', customerSignupRouter);

app.use('/createGeneralManager', createGeneralManager);

app.use('/listRestaurant', listRestaurantRouter);
app.use('/createReservation', createReservationRouter);
app.use('/listBookings', listBookingsRouter);

app.use('/userInfo', userInfo);
app.use('/createManager', createManager);
app.use('/bookmark', bookmarkRouter);
app.use('/listDishes', listDishes);
app.use('/restaurantDetails', restaurantDetailsRouter);
app.use('/createFeedback', createFeedbackRouter);

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

module.exports = app;
