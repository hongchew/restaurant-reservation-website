var express = require('express');
var router = express.Router();
const url = require('url');

const { Pool } = require('pg')

const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


/* SQL Query */

router.get('/', function (req, res, next) {
		res.render('bookmark');
});

module.exports = router;