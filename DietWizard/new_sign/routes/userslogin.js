const express = require("express");
const router = express.Router();
const login = require("../controllers/userlogin");


router.get('/login', login.getLoginPage);
router.post('/login', login.postLoginPage);//for mobile

router.post('/getchatname', login.getchatname);//for mobile

router.post('/loginweb', login.postLoginPageWeb);//for web

module.exports = router;