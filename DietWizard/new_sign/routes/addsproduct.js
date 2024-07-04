const express = require("express");
const router = express.Router();
const Add = require("../controllers/addproduct");
 
const multer = require('multer');

// const storage = multer.memoryStorage();
// const upload = multer({ storage: storage });

const upload = multer({ dest: 'uploads/' });
 



router.post('/addproduct',upload.single('image'), Add.getAdd);//for mobile  

router.post('/addproductweb',upload.single('image'), Add.getAddweb);//for web







module.exports = router;



 