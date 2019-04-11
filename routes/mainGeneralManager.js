var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
})

/* SQL Query */
var sql_query_login = 'SELECT * FROM RESTAURANT.users';

var currentGeneralManager;
// GET
router.get('/', function(req, res, next) {
    currentGeneralManager = req.app.locals.user;
    console.log(currentGeneralManager)
    if(!currentGeneralManager.email || currentGeneralManager.accountType != 'GeneralManager'){
        res.redirect("/login");
    }
    var email = `${currentGeneralManager.email}`;
    var complex_query = 
    `
    with branchesUnderGeneralManager as (
        select * 
        from RESTAURANT.Branch b
        where b.restaurantName = (
            select restaurantName 
            from RESTAURANT.Restaurant r
            where r.generalManagerEmail = '${email}'
        )
    )
    
    select b.restaurantName, b.branchArea, coalesce(count(*),0) as numReservation
    from branchesUnderGeneralManager b
    left join RESTAURANT.Reservation r
    on b.restaurantName = r.restaurantName and b.branchArea = r.branchArea
    group by b.restaurantName, b.branchArea
    `
    pool.query(complex_query, (err,data)=> {
        if(err){
            console.log("GET query err: " + err.message);
        }else{
            console.log(data.rows);
            table = data.rows;
            console.log("***Check main query ");
            res.render('mainGeneralManager', { data: data.rows});
        }
    })
    
});


module.exports = router;
