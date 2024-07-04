const express = require("express");
const router = express.Router();
 
const Excersises = require("../controllers/excersise");


router.get('/exercises', Excersises.getExercisesWeb);
router.post('/removeExercise', Excersises.postRemoveExercises);


router.get('/exercises/:category', Excersises.getExercisesCategory);
router.get('/exercisesmobile/:category', Excersises.getExercisesCategoryMobile);






module.exports = router;