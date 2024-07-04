const express = require("express");
const router = express.Router();
const bmi = require("../controllers/calculatebmi");
 
 
 

router.post('/calculateBMI',  bmi.postcalculatebmi);



module.exports = router;