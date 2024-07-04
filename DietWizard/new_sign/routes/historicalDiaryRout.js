const express = require("express");
const router = express.Router();
const historicaldiary = require("../controllers/historicalDiaryCont");



router.post('/loginHistorical', historicaldiary.loginHistorical); //for login..


router.post('/saveDiaryinfo', historicaldiary.saveDiaryinfo);//for mobile -- back
router.post('/showDiaryinfo', historicaldiary.showDiaryinfo);//for mobile -- back


router.post('/CalTotCaloriesDiaryinfo', historicaldiary.CalTotCaloriesDiaryinfo);//for mobile -- back
router.post('/CalTotGivenNutDiaryinfo', historicaldiary.CalTotGivenNutDiaryinfo);//for mobile -- back
router.post('/CalTotGoalLeftNutDiaryinfo', historicaldiary.CalTotGoalLeftNutDiaryinfo);//for mobile -- back


router.post('/WelcomeCaloriesDiaryinfo', historicaldiary.WelcomeCaloriesDiaryinfo);//for mobile -- back
router.post('/WelcomeMacrosDiaryinfo', historicaldiary.WelcomeMacrosDiaryinfo);//for mobile -- back


router.post('/TraineesInfo', historicaldiary.TraineesInfo);//for mobile -- back
router.post('/TDEEInfoHistorical', historicaldiary.TDEEInfoHistorical);//for mobile -- back
router.post('/LASTDAYBACKHistorical', historicaldiary.LASTDAYBACKHistorical);//for mobile -- back

router.get('/FetchforPreset', historicaldiary.FetchforPreset);//for mobile -- back











module.exports = router;