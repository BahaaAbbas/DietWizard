const express = require("express");
const router = express.Router();
const idealintake = require("../controllers/WaterIntakeCont");


router.post('/idealintake', idealintake.getidealintake);//for mobile -- back
router.post('/setgoalintake', idealintake.setgoalintake);//for mobile -- back
router.post('/logwaterdaily', idealintake.logwaterdaily);//for mobile   -- checked 
router.post('/showloggedwater', idealintake.showloggedwater);//for mobile -- checked
router.post('/saveeditloggedwater', idealintake.saveeditloggedwater);//for mobile -- checked
router.post('/deleteditloggedwater', idealintake.deleteditloggedwater);//for mobile -- checked
router.post('/get7daysarray', idealintake.get7daysarray);//for mobile -- checked


router.post('/PutNotificationWater', idealintake.PutNotificationWater);//for mobile -- checked

module.exports = router;