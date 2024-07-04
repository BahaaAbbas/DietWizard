const express = require("express");
const router = express.Router();
const customfoodexe = require("../controllers/CustomFoodExeCont");


 router.post('/savecustomFood', customfoodexe.savecustomFood);//for mobile -- back
 router.post('/savecustomExe', customfoodexe.savecustomExe);//for mobile -- back
 router.post('/getcustomFood', customfoodexe.getcustomFood);//for mobile -- back
 router.post('/getcustomExe', customfoodexe.getcustomExe);//for mobile -- back


module.exports = router;