const express = require("express");
const router = express.Router();
const changepassword = require("../controllers/changepassword");


router.post('/changepassword', changepassword.changepass);



module.exports = router;