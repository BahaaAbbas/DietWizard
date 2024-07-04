const express = require("express");
const router = express.Router();
const ShowUser = require("../controllers/showuser");


router.get('/showusers', ShowUser.getShowUser);//for web
router.delete('/deleteusers/:iduser', ShowUser.DeleteUser);//for web




router.get('/CategoryUserAndCoach', ShowUser.getShowUserAndCoach);//for web 

module.exports = router;
