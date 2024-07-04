const express = require("express");
const router = express.Router();
const dailytrackprogress = require("../controllers/DailyTrackProgressCont");


   router.post('/weightFood', dailytrackprogress.weightFood);//for mobile -- back
   router.post('/weightbyUSER', dailytrackprogress.weightbyUSER);//for mobile -- back
   router.post('/buttonINFOCURRENT', dailytrackprogress.buttonINFOCURRENT);//for mobile -- back

//    router.post('/CalTotCaloriesdayofWeek', weeklytrackprogress.CalTotCaloriesdayofWeek);//for mobile -- back
//     router.post('/CalTotGivenNutdayofWeek', weeklytrackprogress.CalTotGivenNutdayofWeek);//for mobile -- back
//     router.post('/CalTotGoalLeftdayofWeek', weeklytrackprogress.CalTotGoalLeftdayofWeek);//for mobile -- back
 

//     router.post('/summaryshowdayofWeek', weeklytrackprogress.summaryshowdayofWeek);//for mobile -- back



module.exports = router;