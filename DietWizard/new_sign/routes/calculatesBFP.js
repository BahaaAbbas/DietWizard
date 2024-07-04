const express = require("express");
const router = express.Router();
const BFP = require("../controllers/calculateBFP");
 
 
 

router.post('/calculateBFP',  BFP.postcalculateBFP);



module.exports = router;