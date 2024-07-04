const express = require("express");
const router = express.Router();
const Showproduct = require("../controllers/showproduct");


router.get('/showproducts', Showproduct.getShowproduct);//for web

router.get('/products', Showproduct.getShowproductmobile);//for mobile


module.exports = router;