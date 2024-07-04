const express = require("express");
const router = express.Router();
const filluser = require("../controllers/filluserChoice");



router.post('/fill', filluser.postfilluserchoices);//for mobile
router.post('/getUserGoal', filluser.getUserGoal);//for mobile

router.post('/startcurrentgoal', filluser.startcurrentgoal);//for mobile


router.post('/changeworkWeek', filluser.changeworkWeek);//for workWeek
router.post('/changeminWork', filluser.changeminWork);//for minWork
router.post('/changefatprotiencarbsPer', filluser.changefatprotiencarbsPer);//for changefatprotiencarbsPer
router.post('/changeTDEE', filluser.changeTDEE);//for TDEE

router.post('/changestartweight', filluser.changestartweight);//for changestartweight
router.post('/changegoalweight', filluser.changegoalweight);//for changegoalweight
router.post('/changecurrentweight', filluser.changecurrentweight);//for changecurrentweight
router.post('/changeweeklytarget', filluser.changeweeklytarget);//for changeweeklytarget
router.post('/changeactivitylevel', filluser.changeactivitylevel);//for changeactivitylevel



router.post('/changeTDEE2', filluser.changeTDEE2);//for test commands


module.exports = router;