const express = require("express");
const router = express.Router();
 
const CategoryExcersises = require("../controllers/CategoryExercise");


router.get('/CategoryExercise', CategoryExcersises.getCategoryExercise);
router.post('/CategoryExercise', CategoryExcersises.postCategoryExercise);


module.exports = router;