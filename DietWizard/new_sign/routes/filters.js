const express = require("express");
const router = express.Router();
 
const Filter = require("../controllers/filter");


router.get('/filter', Filter.getFilter);



module.exports = router;