const express = require("express");
const router = express.Router();
 
const Recipe = require("../controllers/recipe");


router.get('/recipes', Recipe.getAllRecipeMobile);
router.get('/recipesmobile', Recipe.getRecipeMobile);


module.exports = router;