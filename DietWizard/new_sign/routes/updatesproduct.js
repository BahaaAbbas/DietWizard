const express = require("express");
const router = express.Router();
const Update = require("../controllers/updateproduct");


router.post('/updatepro', Update.getUpdate);



module.exports = router;