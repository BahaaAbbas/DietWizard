const express = require("express");
const router = express.Router();
const coachesListUser = require("../controllers/CoachesListUserCont");


  router.get('/returnuserforsearch', coachesListUser.returnuserforsearch);//for mobile -- back
  router.post('/saveusertrainee', coachesListUser.saveusertrainee);//for mobile -- back
 router.post('/showusertrainee', coachesListUser.showusertrainee);//for mobile -- back

 router.post('/returncoachnameandnumtrainees', coachesListUser.returncoachnameandnumtrainees);//for mobile -- back

 router.post('/areYou', coachesListUser.areYou);//for mobile -- back
//  router.post('/getcustomExe', coachesListUser.getcustomExe);//for mobile -- back


module.exports = router;