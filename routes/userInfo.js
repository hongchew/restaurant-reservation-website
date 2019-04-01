var express = require('express');
var router = express.Router();

const { Pool } = require('pg');

const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});

router.get('/', function (req, res, next)) {
    var user = req.app.locals.user;
    var reservationsQuery = "SELECT * FROM RESTAURANT.Reservation WHERE userid = '" + user.userId + "'";
    
    pool.query(reservationsQuery, (err,data) => {

    }
    )


}