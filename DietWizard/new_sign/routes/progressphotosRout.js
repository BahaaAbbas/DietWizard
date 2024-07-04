const express = require("express");
const router = express.Router();
const progressphoto = require("../controllers/progressphotosCont");

//showprogressphotos
router.post('/setprogressphoto', progressphoto.setprogressphoto);//for mobile -- back
router.post('/showprogressphotos', progressphoto.showprogressphotos);//for mobile -- back
router.post('/updateprogressphotos', progressphoto.updateprogressphotos);//for mobile -- back
router.post('/deleteprogressphotos', progressphoto.deleteprogressphotos);//for mobile -- back



module.exports = router;