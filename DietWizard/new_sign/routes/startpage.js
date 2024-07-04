const express = require("express");
const router = express.Router();
const Start = require("../controllers/startspage");


router.get('/', Start.getStartpage);



module.exports = router;