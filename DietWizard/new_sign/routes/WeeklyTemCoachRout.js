const express = require("express");
const router = express.Router();
const weeklytemcoach = require("../controllers/WeeklyTemCoachCont");


   router.post('/savedayofWeek', weeklytemcoach.savedayofWeek);//for mobile -- back
   router.post('/showdayofWeek', weeklytemcoach.showdayofWeek);//for mobile -- back

   router.post('/CalTotCaloriesdayofWeek', weeklytemcoach.CalTotCaloriesdayofWeek);//for mobile -- back
    router.post('/CalTotGivenNutdayofWeek', weeklytemcoach.CalTotGivenNutdayofWeek);//for mobile -- back
    router.post('/CalTotGoalLeftdayofWeek', weeklytemcoach.CalTotGoalLeftdayofWeek);//for mobile -- back
 

    router.post('/summaryshowdayofWeek', weeklytemcoach.summaryshowdayofWeek);//for mobile -- back



module.exports = router;