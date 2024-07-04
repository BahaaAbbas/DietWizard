const express = require("express");
const router = express.Router();
const coachrating = require("../controllers/CoachRatingCont");


    router.post('/canRatingOrNOT', coachrating.canRatingOrNOT);//for mobile -- back
    router.post('/rateCoach', coachrating.rateCoach);//for mobile -- back
    router.get('/INFOrateCoaches', coachrating.INFOrateCoaches);//for mobile -- back
    router.get('/FilterByNumRates', coachrating.FilterByNumRates);//for mobile -- back
     router.get('/FilterByHighestRating', coachrating.FilterByHighestRating);//for mobile -- back





module.exports = router;