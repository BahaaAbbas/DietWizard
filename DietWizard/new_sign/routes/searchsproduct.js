const express = require("express");
const router = express.Router();
const Search = require("../controllers/searchproduct");


router.post('/searchpro', Search.getSearch);
router.get('/searchproduct', Search.getSearchs);


module.exports = router;