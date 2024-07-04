const express = require("express");
const router = express.Router();
const Delete = require("../controllers/deleteproduct");


router.post('/deletepro', Delete.getDelete);



module.exports = router;