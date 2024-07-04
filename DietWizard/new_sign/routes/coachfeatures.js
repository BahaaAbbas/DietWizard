const express = require("express");
const router = express.Router();
 
 

const CoachFeatures = require("../controllers/coachfeature");


const multer = require('multer');

const upload = multer({ dest: 'uploads/' });

router.post('/signupcoach',upload.single('image'), CoachFeatures.postSiginupcoachPage);
router.get('/getcoach/:name', CoachFeatures.GetcoachPage);
router.get('/getallcoach', CoachFeatures.GetAllcoachPage);
router.get('/GetAllcoachPageInformation', CoachFeatures.GetAllcoachPageInformation);
router.delete('/deletecoach/:idcoach', CoachFeatures.deletecoach);

router.post('/activatecoach/:idcoach', CoachFeatures.activatecoach);

router.get('/statuscoach/:nameuser', CoachFeatures.checkStatus);


router.post('/sendnotificationfromcoach/:email', CoachFeatures.SendNotification);// from coach to user





router.get('/showcoaches', CoachFeatures.getShowCoachesWeb);//for web
router.post('/activatecoachweb/:idcoach', CoachFeatures.activatecoachweb);//for web
router.delete('/deletecoachweb/:idcoach', CoachFeatures.deletecoachweb);//for web

module.exports = router;