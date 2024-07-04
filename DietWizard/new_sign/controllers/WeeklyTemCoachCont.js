
const express = require('express');

const router = express.Router();
const path = require('path');

const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices = require('../models/userChoices');
const waterintake = require('../models/Waterintake');
const progressphoto = require('../models/progressphotos');
const customfoodexe = require('../models/CustomFoodExe');
const coachmodel = require('../models/coach');
const coachesListUser = require('../models/CoachesListUser');
const weeklyTemCoach = require('../models/WeeklyTemCoach'); 
const historicaldiary = require('../models/historicalDiary');

const fs = require('fs');

const multer = require('multer');
const { param } = require('../routes/WeeklyTemCoachRout');

exports.savedayofWeek = async (req, res) => {
    console.log("Heelo week");

    try {
        const { coachemail, traineeEmail, weekdate, dayLogs } = req.body;
        // Log the entire request body, with proper stringification of nested objects
        console.log(JSON.stringify(req.body, null, 2));

        // Extract day logs information
        let allTodayDates;
        let allNoteContents;
        let allBreakfasts = [];
        let allLunches = [];
        let allDinners = [];
        let allSnacks = [];
        let allExercises = [];

        dayLogs.forEach(day => {
            const todayDate = day.todaydate;
            const breakfast = day.mealsExe.breakfast;
            const lunch = day.mealsExe.lunch;
            const dinner = day.mealsExe.dinner;
            const snack = day.mealsExe.snack;
            const exercises = day.exerc;
            const noteContent = day.noteCont;

            // Concatenate values to arrays
            allBreakfasts = allBreakfasts.concat(breakfast);
            allLunches = allLunches.concat(lunch);
            allDinners = allDinners.concat(dinner);
            allSnacks = allSnacks.concat(snack);
            allExercises = allExercises.concat(exercises);

            // Update the last todayDate and noteContent
            allTodayDates = todayDate;
            allNoteContents = noteContent;
        });

        const coachcheck = await coachesListUser.findOne({ coachemail: coachemail }); // check if coach exist in the table
        const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail }); // check if trainee email exist in the table

        if (coachcheck) { // if coach exists in table..
            if (traineecheck) { // if trainee exists in table..

                const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail }); // check if this coach logged any weektemplate yet..

                if (!fillInfo) { // if not logged anything yet

                    const weeklyTemCoachSchema = new weeklyTemCoach({
                        coachid: coachcheck.coachid,
                        coachemail: coachemail,
                        trainees: [{
                            traineeEmail: traineeEmail,
                            weekLog: [{
                                weekdate: weekdate,
                                logs: [{
                                    todaydate: allTodayDates,
                                    mealsExe: {
                                        breakfast: allBreakfasts,
                                        lunch: allLunches,
                                        dinner: allDinners,
                                        snack: allSnacks,
                                    },
                                    exerc: allExercises,
                                    noteCont: allNoteContents
                                }]
                            }]
                        }]
                    });
                    await weeklyTemCoachSchema.save();
                    return res.status(200).json('Done adding dayofweek record');

                } else { // if logged for week template with email checked

                    // Find the trainee
                    const traineeIndex = fillInfo.trainees.findIndex(trainee => trainee.traineeEmail === traineeEmail);
                    if (traineeIndex !== -1) { // if trainee is found

                        // Find the week log entry
                        const weekLogIndex = fillInfo.trainees[traineeIndex].weekLog.findIndex(week => week.weekdate === weekdate);
                        if (weekLogIndex !== -1) { // if current record week date exists

                            // Find the day log entry
                            const dayIndex = fillInfo.trainees[traineeIndex].weekLog[weekLogIndex].logs.findIndex(log => log.todaydate === allTodayDates);
                            if (dayIndex === -1) { // if the day date is not found, add a new entry
                                fillInfo.trainees[traineeIndex].weekLog[weekLogIndex].logs.push({
                                    todaydate: allTodayDates,
                                    mealsExe: {
                                        breakfast: allBreakfasts,
                                        lunch: allLunches,
                                        dinner: allDinners,
                                        snack: allSnacks,
                                    },
                                    exerc: allExercises,
                                    noteCont: allNoteContents
                                });
                            } else { // if the day date is found, update it
                                fillInfo.trainees[traineeIndex].weekLog[weekLogIndex].logs[dayIndex] = {
                                    todaydate: allTodayDates,
                                    mealsExe: {
                                        breakfast: allBreakfasts,
                                        lunch: allLunches,
                                        dinner: allDinners,
                                        snack: allSnacks,
                                    },
                                    exerc: allExercises,
                                    noteCont: allNoteContents
                                };
                            }

                            await fillInfo.save();
                            return res.status(200).json('Done updating');

                        } else { // if current record week date is not found, create a new entry
                            fillInfo.trainees[traineeIndex].weekLog.push({
                                weekdate: weekdate,
                                logs: [{
                                    todaydate: allTodayDates,
                                    mealsExe: {
                                        breakfast: allBreakfasts,
                                        lunch: allLunches,
                                        dinner: allDinners,
                                        snack: allSnacks,
                                    },
                                    exerc: allExercises,
                                    noteCont: allNoteContents
                                }]
                            });

                            await fillInfo.save();
                            return res.status(200).json('Done adding new week entry');
                        }
                    } else { // if trainee is not found, create a new trainee entry
                        fillInfo.trainees.push({
                            traineeEmail: traineeEmail,
                            weekLog: [{
                                weekdate: weekdate,
                                logs: [{
                                    todaydate: allTodayDates,
                                    mealsExe: {
                                        breakfast: allBreakfasts,
                                        lunch: allLunches,
                                        dinner: allDinners,
                                        snack: allSnacks,
                                    },
                                    exerc: allExercises,
                                    noteCont: allNoteContents
                                }]
                            }]
                        });

                        await fillInfo.save();
                        return res.status(200).json('Done adding new trainee entry');
                    }
                }
            } else { // if trainee does not exist in table..
                return res.status(400).json('Trainee does not exist for this coach in database');
            }
        } else { // if coach does not exist in table..
            return res.status(400).json('Coach does not exist in our database');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
};

// exports.savedayofWeek = async (req, res) => {
//     console.log("Heelo week");

//     try {
//         const { coachemail, traineeEmail, weekdate, dayLogs } = req.body;
//                 // Log the entire request body, with proper stringification of nested objects
//               //  console.log(JSON.stringify(req.body, null, 2));

//         // Extract day logs information
//         let allTodayDates;
//         let allNoteContents;
//         let allBreakfasts = [];
//         let allLunches = [];
//         let allDinners = [];
//         let allSnacks = [];
//         let allExercises = [];

//         dayLogs.forEach(day => {
//             const todayDate = day.todaydate;
//             const breakfast = day.mealsExe.breakfast;
//             const lunch = day.mealsExe.lunch;
//             const dinner = day.mealsExe.dinner;
//             const snack = day.mealsExe.snack;
//             const exercises = day.exerc;
//             const noteContent = day.noteCont;

//             // Concatenate values to arrays
//             allBreakfasts = allBreakfasts.concat(breakfast);
//             allLunches = allLunches.concat(lunch);
//             allDinners = allDinners.concat(dinner);
//             allSnacks = allSnacks.concat(snack);
//             allExercises = allExercises.concat(exercises);

//             // Update the last todayDate and noteContent
//             allTodayDates = todayDate;
//             allNoteContents = noteContent;
//         });

//         const coachcheck = await coachesListUser.findOne({ coachemail: coachemail }); // check if coach exist in the table
//         const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail });// check if trainee email exist in the table
       
 
       
        
//         if (coachcheck) { // if coach exist in table..
//             if(traineecheck){// if trainee exist in table..

//             const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail }); // check if this coach logged any weektemplate yet..
//             if (!fillInfo) { //if not logged anything yet

//                  const weeklyTemCoachSchema = new weeklyTemCoach({

//                     coachid: coachcheck.coachid,
//                     coachemail: coachemail,
//                     trainees: [{
//                         traineeEmail: traineeEmail,
//                         weekLog: [{
//                             weekdate: weekdate,
//                             logs: [{
//                                 todaydate: allTodayDates,
//                                 mealsExe: {
//                                     breakfast: allBreakfasts,
//                                     lunch: allLunches,
//                                     dinner: allDinners,
//                                     snack: allSnacks,
//                                 },
//                                 exerc: allExercises,
//                                 noteCont: allNoteContents
//                             }]
//                         }]
//                     }]
//                 });
//                 await weeklyTemCoachSchema.save();
//                 return res.status(200).json('Done adding dayofweek record');


          
//         } //end if not logged anything


//         else { // if logged for week template with email checked

//             // check if the current record week date exists
//             const weekIndex = fillInfo.trainees.findIndex(trainee => trainee.weekLog[0].weekdate === weekdate);
//             if (weekIndex !== -1) { // if current record week date exists

//                 // find the index of the day date in the current record
//                 const dayIndex = fillInfo.trainees[weekIndex].weekLog[0].logs.findIndex(log => log.todaydate === allTodayDates);
//                 if (dayIndex === -1) { // if the day date is not found, add a new entry
//                     fillInfo.trainees[weekIndex].weekLog[0].logs.push({
//                         todaydate: allTodayDates,
//                         mealsExe: {
//                             breakfast: allBreakfasts,
//                             lunch: allLunches,
//                             dinner: allDinners,
//                             snack: allSnacks,
//                         },
//                         exerc: allExercises,
//                         noteCont: allNoteContents
//                     });
//                 } else { // if the day date is found, update it
//                     fillInfo.trainees[weekIndex].weekLog[0].logs[dayIndex] = {
//                         todaydate: allTodayDates,
//                         mealsExe: {
//                             breakfast: allBreakfasts,
//                             lunch: allLunches,
//                             dinner: allDinners,
//                             snack: allSnacks,
//                         },
//                         exerc: allExercises,
//                         noteCont: allNoteContents
//                     };
//                 }

//                 await fillInfo.save();
//                 return res.status(200).json('Done updating');

//             } else { // if current record week date is not found, create a new entry
//                 fillInfo.trainees.push({
//                     traineeEmail: traineeEmail,
//                     weekLog: [{
//                         weekdate: weekdate,
//                         logs: [{
//                             todaydate: allTodayDates,
//                             mealsExe: {
//                                 breakfast: allBreakfasts,
//                                 lunch: allLunches,
//                                 dinner: allDinners,
//                                 snack: allSnacks,
//                             },
//                             exerc: allExercises,
//                             noteCont: allNoteContents
//                         }]
//                     }]
//                 });

//                 await fillInfo.save();
//                 return res.status(200).json('Done adding new week entry');
//             }
//         }

//         }//  trainee check found in table..

//         else {//  trainee check not found in table..
//             return res.status(400).json('Trainee does not exist for this coach in database');
//         }
//         } //  coach check in table..
//         else {
//             return res.status(400).json('Coach does not exist in our database');
//         }
//     } catch (e) {
//         console.error(e);
//         res.sendStatus(500);
//     }
// }

exports.showdayofWeek = async (req, res) => {
    try {
        const { coachemail, traineeEmail, weekdate, dayLogs } = req.body;

        console.log('Received request body:', JSON.stringify(req.body, null, 2));

        let allTodayDates;
        let allNoteContents = "";
        let allBreakfasts = [];
        let allLunches = [];
        let allDinners = [];
        let allSnacks = [];
        let allExercises = [];

        dayLogs.forEach(day => {
            allTodayDates = day.todaydate;
            console.log("Todaydate From dayLogs= " + allTodayDates);
        });

        const coachcheck = await coachesListUser.findOne({ coachemail: coachemail });
        const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail });

        console.log('Coach check:', coachcheck);
        console.log('Trainee check:', traineecheck);

        if (coachcheck) {
            if (traineecheck) {
                const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail });

                console.log('Fill info:', fillInfo);

                if (!fillInfo) {
                    return res.status(400).json('Coach does not have any logged yet.');
                } else {
                    const weekLog = fillInfo.trainees.find(trainee => trainee.traineeEmail === traineeEmail)?.weekLog;
                    
                    console.log('Week log:', weekLog);

                    if (weekLog) {
                        const logArray = weekLog.find(week => week.weekdate === weekdate)?.logs || [];
                        let logsExist = false;

                        logArray.forEach(log => {
                            if (log.todaydate === allTodayDates) {
                                logsExist = true;
                                allBreakfasts = log.mealsExe.breakfast;
                                allLunches = log.mealsExe.lunch;
                                allDinners = log.mealsExe.dinner;
                                allSnacks = log.mealsExe.snack;
                                allExercises = log.exerc;
                                allNoteContents = log.noteCont;
                            }
                        });

                        console.log('Logs exist:', logsExist);

                        if (logsExist) {
                            const responseObj = {
                                allBreakfasts: allBreakfasts,
                                allLunches: allLunches,
                                allDinners: allDinners,
                                allSnacks: allSnacks,
                                allExercises: allExercises,
                                allNoteContents: allNoteContents
                            };
                            console.log(`Logsexist = ${logsExist} -- we found and returned`);
                            res.json(responseObj);
                        } else {
                            const responseObj = {
                                allBreakfasts: [],
                                allLunches: [],
                                allDinners: [],
                                allSnacks: [],
                                allExercises: [],
                                allNoteContents: ""
                            };
                            console.log(`Logsexist = ${logsExist} -- not exist `);
                            res.status(200).json(responseObj);
                        }
                    } else {
                        const responseObj = {
                            allBreakfasts: [],
                            allLunches: [],
                            allDinners: [],
                            allSnacks: [],
                            allExercises: [],
                            allNoteContents: ""
                        };
                        console.log(` not exist for this week `);
                        res.status(200).json(responseObj);
                    }
                }
            } else {
                return res.status(400).json('Trainee does not exist for this coach in database');
            }
        } else {
            return res.status(400).json('Coach does not exist in our database');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}


// exports.showdayofWeek = async (req, res) => {
//     try {
//         const { coachemail, traineeEmail, weekdate, dayLogs } = req.body;

//         console.log('Received request body:', JSON.stringify(req.body, null, 2));
//        //console.log(JSON.stringify(req.body, null, 2));

//         // Extract day logs information
//         let allTodayDates;
//         let allNoteContents = "";
//         let allBreakfasts = [];
//         let allLunches = [];
//         let allDinners = [];
//         let allSnacks = [];
//         let allExercises = [];

//         dayLogs.forEach(day => {
//             allTodayDates = day.todaydate;
//             console.log("Todaydate From dayLogs= "+allTodayDates);
//         });

//         const coachcheck = await coachesListUser.findOne({ coachemail: coachemail });
//         const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail });

//         if (coachcheck) {
//             if (traineecheck) {
//                 const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail });

//                 if (!fillInfo) {
//                     return res.status(400).json('Coach does not have any logged yet.');
//                 } else {
//                     const weekLog = fillInfo.trainees.find(trainee => trainee.traineeEmail === traineeEmail)?.weekLog;
//                     if (weekLog) {
//                         const logArray = weekLog.find(week => week.weekdate === weekdate)?.logs || [];
//                         let logsExist = false;

//                         logArray.forEach(log => {
//                             if (log.todaydate === allTodayDates) {
//                                 logsExist = true;
//                                 allBreakfasts = log.mealsExe.breakfast;
//                                 allLunches = log.mealsExe.lunch;
//                                 allDinners = log.mealsExe.dinner;
//                                 allSnacks = log.mealsExe.snack;
//                                 allExercises = log.exerc;
//                                 allNoteContents = log.noteCont;
//                             }
//                         });

//                         if (logsExist) {
//                             const responseObj = {
//                                 allBreakfasts: allBreakfasts,
//                                 allLunches: allLunches,
//                                 allDinners: allDinners,
//                                 allSnacks: allSnacks,
//                                 allExercises: allExercises,
//                                 allNoteContents: allNoteContents
//                             };
//                             console.log(`Logsexist = ${logsExist} -- we found and returned`);
//                             res.json(responseObj);
//                         } else {
//                             const responseObj = {
//                                 allBreakfasts: [],
//                                 allLunches: [],
//                                 allDinners: [],
//                                 allSnacks: [],
//                                 allExercises: [],
//                                 allNoteContents: ""
//                             };
//                             console.log(`Logsexist = ${logsExist} -- not exist `);
//                             res.status(200).json(responseObj);
//                         }
//                     } else {
//                         const responseObj = {
//                             allBreakfasts: [],
//                             allLunches: [],
//                             allDinners: [],
//                             allSnacks: [],
//                             allExercises: [],
//                             allNoteContents: ""
//                         };
//                         console.log(` not exist for this week `);
//                         res.status(200).json(responseObj);
//                     }
//                 }
//             } else {
//                 return res.status(400).json('Trainee does not exist for this coach in database');
//             }
//         } else {
//             return res.status(400).json('Coach does not exist in our database');
//         }
//     } catch (e) {
//         console.error(e);
//         res.sendStatus(500);
//     }
// }




exports.CalTotCaloriesdayofWeek = async (req, res) => {
    try {
        const { coachemail, traineeEmail, weekdate, dayLogs } = req.body;

        // Log the entire request body for debugging purposes
        //console.log(JSON.stringify(req.body, null, 2));

        // Declare variables outside the loop
        let allTodayDates;
        let totalCaloriesBreakfast = 0;
        let totalCaloriesLunch = 0;
        let totalCaloriesDinner = 0;
        let totalCaloriesSnack = 0;
        let totalCaloriesOVERALL = 0;
        let totalCaloriesGOALS = 0;

        // Extract the date from dayLogs
        dayLogs.forEach(day => {
            const todayDate = day.todaydate;
            allTodayDates = todayDate;
        });

        // Find coach and trainee records
        const coachcheck = await coachesListUser.findOne({ coachemail: coachemail });
        const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail });
        const searchNutri = await userChoices.findOne({ email: traineeEmail });

        let fillInfohistorical = await historicaldiary.findOne(
            {
            email: traineeEmail,
            'daydate.todaydate': allTodayDates
            },
            { 'daydate.$': 1 } 
		);

            //****UPDATE---------------- */
        if (!fillInfohistorical) {
            // If no record is found for the exact todaydate, find the most recent date before todaydate
            fillInfohistorical = await historicaldiary.findOne(
                {
                    email: traineeEmail,
                    'daydate.todaydate': { $lte: allTodayDates }
                },
                { 'daydate.$': 1 }
            ).sort({ 'daydate.todaydate': -1 });

            if (!fillInfohistorical) {
                // Handle the case where no historical data is found
                return res.status(400).json('No historical data found.');
            }
        }
	
    //****UPDATE---------------- */

        if (coachcheck && traineecheck) { // Both coach and trainee exist
            const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail });

            if (!fillInfo) { // If no existing week log record
                return res.status(400).json('No weekly log record found for this coach.');
            } else {
                // Find the week log for the specified weekdate
                const weekLog = fillInfo.trainees.find(trainee => trainee.traineeEmail === traineeEmail)?.weekLog || [];
                const logArray = weekLog.find(week => week.weekdate === weekdate)?.logs || [];

                // Find the log for the specified todaydate
                const logForDate = logArray.find(day => day.todaydate === allTodayDates);

                if (!logForDate) { // If no log found for the specified todaydate

                    totalCaloriesGOALS =   parseFloat(fillInfohistorical.daydate[0].afterTDEE);

                    const responseObj = {
                        allTodayDates: allTodayDates,
                        totalCaloriesBreakfast: 0,
                        totalCaloriesLunch: 0,
                        totalCaloriesDinner: 0,
                        totalCaloriesSnack: 0,
                        totalCaloriesOVERALL: 0,
                        totalCaloriesGOALS: totalCaloriesGOALS,
                        totalCaloriesUNIT: 'Kcal',
                    };
                    return res.status(200).json(responseObj);
                } else { // If log found for the specified todaydate
                    // Calculate total calories for each meal type
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalCaloriesBreakfast += meal.totCalories;
                    });

                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalCaloriesLunch += meal.totCalories;
                    });

                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalCaloriesDinner += meal.totCalories;
                    });

                    logForDate.mealsExe.snack.forEach(meal => {
                        totalCaloriesSnack += meal.totCalories;
                    });

                    totalCaloriesOVERALL = totalCaloriesBreakfast + totalCaloriesLunch + totalCaloriesDinner + totalCaloriesSnack;
                    totalCaloriesGOALS =   parseFloat(fillInfohistorical.daydate[0].afterTDEE);

                    // Construct the response object
                    const responseObj = {
                        allTodayDates: allTodayDates,
                        totalCaloriesBreakfast: totalCaloriesBreakfast,
                        totalCaloriesLunch: totalCaloriesLunch,
                        totalCaloriesDinner: totalCaloriesDinner,
                        totalCaloriesSnack: totalCaloriesSnack,
                        totalCaloriesOVERALL: totalCaloriesOVERALL,
                        totalCaloriesGOALS: totalCaloriesGOALS,
                        totalCaloriesUNIT: 'Kcal',
                    };

                    // Return the response object
                    return res.status(200).json(responseObj);
                }
            }
        } else {
            console.log('Coach or trainee does NOT exist');
            return res.status(400).json('Coach or trainee does NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
};



exports.CalTotGivenNutdayofWeek = async (req, res) => {
    try {
        const { coachemail, traineeEmail, weekdate, dayLogs,givenNute } = req.body;
     


        console.log('givenNute: ',givenNute);
        
        // Declare variables outside the loop
        let allTodayDates;
        let totalgivenNuteBreakfast = 0;
        let totalgivenNuteLunch = 0;
        let totalgivenNuteDinner = 0;
        let totalgivenNutenack = 0;
        let totalgivenNuteOVERALL=0;
        let totalgivenNuteGOALS=0;

        
        //------------------------------------------
   

        dayLogs.forEach(day => {
            const todayDate = day.todaydate;
          
            allTodayDates = todayDate;
  
        });

      
      //console.log('All Today Dates -- showfn :', allTodayDates);

       // Find coach and trainee records
       const coachcheck = await coachesListUser.findOne({ coachemail: coachemail });
       const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail });
       const searchNutri = await userChoices.findOne({ email: traineeEmail });

       let fillInfohistorical = await historicaldiary.findOne(
        {
        email: traineeEmail,
        'daydate.todaydate': allTodayDates
        },
        { 'daydate.$': 1 } 
    );

    
            //****UPDATE---------------- */
            if (!fillInfohistorical) {
                // If no record is found for the exact todaydate, find the most recent date before todaydate
                fillInfohistorical = await historicaldiary.findOne(
                    {
                        email: traineeEmail,
                        'daydate.todaydate': { $lte: allTodayDates }
                    },
                    { 'daydate.$': 1 }
                ).sort({ 'daydate.todaydate': -1 });
    
                if (!fillInfohistorical) {
                    // Handle the case where no historical data is found
                    return res.status(400).json('No historical data found.');
                }
            }
        
        //****UPDATE---------------- */



       if (coachcheck && traineecheck) { // Both coach and trainee exist
           const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail });

           if (!fillInfo) { // If no existing week log record
               return res.status(400).json('No weekly log record found for this coach.');
           } else {
               // Find the week log for the specified weekdate
               const weekLog = fillInfo.trainees.find(trainee => trainee.traineeEmail === traineeEmail)?.weekLog || [];
               const logArray = weekLog.find(week => week.weekdate === weekdate)?.logs || [];

               // Find the log for the specified todaydate
               const logForDate = logArray.find(day => day.todaydate === allTodayDates);

               if (!logForDate) { // If no log found for the specified todaydate

                   
                   
                if(givenNute === 'totFat'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goaltotFat);
                }
                else if(givenNute === 'satFat'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalsatFat);
                }
                else if(givenNute === 'protein'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalprotein);
                }
                else if(givenNute === 'sodium'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalsodium);
                }
                else if(givenNute === 'potassium'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalpotassium);
                }
                else if(givenNute === 'cholesterol'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalcholesterol);
                }
                else if(givenNute === 'carbs'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalcarbs);
                }
                else if(givenNute === 'fiber'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalfiber);
                }
                else if(givenNute === 'sugar'){ 
                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalsugar);
                }

                
                const responseObj = {
                    allTodayDates : allTodayDates,
                    totalgivenNuteBreakfast: 0,
                    totalgivenNuteLunch: 0,
                    totalgivenNuteDinner: 0,
                    totalgivenNutenack: 0,
                    totalgivenNuteOVERALL: 0,

                    totalgivenNuteUNIT: getNutrientUnit(givenNute),
                    totalgivenNuteGOALS:totalgivenNuteGOALS,
              

                };
                return res.status(200).json(responseObj);

               } else { // If log found for the specified todaydate
                   // Calculate given nute 
                         
               
                
                   if(givenNute === 'totFat'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.totFat);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.totFat);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.totFat);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.totFat);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;

                    totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goaltotFat);

                }

                else if(givenNute === 'satFat'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.satFat);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.satFat);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.satFat);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.satFat);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;

                        totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalsatFat);


                }

                else if(givenNute === 'protein'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.protein);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.protein);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.protein);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.protein);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;

                         totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalprotein);

                }

                
                else if(givenNute === 'sodium'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.sodium);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.sodium);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.sodium);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.sodium);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;

                        totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalsodium);

                }
                           
                else if(givenNute === 'potassium'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.potassium);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.potassium);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.potassium);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.potassium);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;

                                     totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalpotassium);                        

                }
                else if(givenNute === 'cholesterol'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.cholesterol);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.cholesterol);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.cholesterol);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.cholesterol);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;

                                                totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalcholesterol);    

                }
                else if(givenNute === 'carbs'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.carbs);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.carbs);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.carbs);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.carbs);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;
                                                totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalcarbs);    

                }
                else if(givenNute === 'fiber'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.fiber);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.fiber);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.fiber);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.fiber);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;
                                                totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalfiber);   

                }
                else if(givenNute === 'sugar'){
 
                    logForDate.mealsExe.breakfast.forEach(meal => {
                        totalgivenNuteBreakfast +=  parseFloat(meal.sugar);
                        
                    });
    
                    logForDate.mealsExe.lunch.forEach(meal => {
                        totalgivenNuteLunch +=  parseFloat(meal.sugar);
                    });
    
                    logForDate.mealsExe.dinner.forEach(meal => {
                        totalgivenNuteDinner +=  parseFloat(meal.sugar);
                    });
    
                    logForDate.mealsExe.snack.forEach(meal => {
                        totalgivenNutenack +=  parseFloat(meal.sugar);
                    });
    
                    totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                                + totalgivenNuteDinner +  totalgivenNutenack;
                                                totalgivenNuteGOALS =   parseFloat(fillInfohistorical.daydate[0].goalsugar);   

                }



                // Construct the response object
                const responseObj = {
                    allTodayDates : allTodayDates,
                    totalgivenNuteBreakfast: totalgivenNuteBreakfast,
                    totalgivenNuteLunch: totalgivenNuteLunch,
                    totalgivenNuteDinner: totalgivenNuteDinner,
                    totalgivenNutenack: totalgivenNutenack,
                    totalgivenNuteOVERALL:totalgivenNuteOVERALL,
                    totalgivenNuteUNIT: getNutrientUnit(givenNute),
                    totalgivenNuteGOALS:totalgivenNuteGOALS,

                };

                // Return the response object
                return res.status(200).json(responseObj);

               }
           }
       } else {
           console.log('Coach or trainee does NOT exist');
           return res.status(400).json('Coach or trainee does NOT exist');
       }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}


function getNutrientUnit(nutrient) {
    switch (nutrient) {
        case 'totFat':
        case 'satFat':
        case 'protein':
        case 'carbs':
        case 'fiber':
        case 'sugar':
            return 'g';
        case 'sodium':
        case 'potassium':
        case 'cholesterol':
            return 'mg';
        // Return null or empty string for unknown nutrients
        default:
            return ''; // or return '';
    }
}


exports.CalTotGoalLeftdayofWeek = async (req, res) => {
    try {
        const { coachemail, traineeEmail, weekdate, dayLogs } = req.body;
     


      
        
        // Declare variables outside the loop
        let allTodayDates;
        let totalgivenNuteBreakfast = 0;
        let totalgivenNuteLunch = 0;
        let totalgivenNuteDinner = 0;
        let totalgivenNutenack = 0;
        let totalgivenNuteOVERALL=0;
        let totalgivenNuteGOALS=0;
        //------------------------------------------
          //------------------------------------------
          let TotalTotFat = 0;
          let GoalTotFat = 0;
          let LeftTotFat = 0;

          let TotalSatFat = 0;
          let GoalSatFat = 0;
          let LeftSatFat = 0;

          let TotalProtein = 0;
          let GoalProtein = 0;
          let LeftProtein = 0;

          let TotalSodium = 0;
          let GoalSodium = 0;
          let LeftSodium = 0;

          let TotalPotassium = 0;
          let GoalPotassium = 0;
          let LeftPotassium = 0;

          let TotalCholesterol = 0;
          let GoalCholesterol = 0;
          let LeftCholesterol = 0;

          let TotalCarbs = 0;
          let GoalCarbs = 0;
          let LeftCarbs = 0;

          let TotalFiber = 0;
          let GoalFiber = 0;
          let LeftFiber = 0;

          let TotalSugar = 0;
          let GoalSugar = 0;
          let LeftSugar = 0;


        dayLogs.forEach(day => {
            const todayDate = day.todaydate;
          
            allTodayDates = todayDate;
  
        });

      
      //console.log('All Today Dates -- showfn :', allTodayDates);

       // Find coach and trainee records
       const coachcheck = await coachesListUser.findOne({ coachemail: coachemail });
       const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail });
       const searchNutri = await userChoices.findOne({ email: traineeEmail });

       let fillInfohistorical = await historicaldiary.findOne(
        {
        email: traineeEmail,
        'daydate.todaydate': allTodayDates
        },
        { 'daydate.$': 1 } 
    );

    
            //****UPDATE---------------- */
            if (!fillInfohistorical) {
                // If no record is found for the exact todaydate, find the most recent date before todaydate
                fillInfohistorical = await historicaldiary.findOne(
                    {
                        email: traineeEmail,
                        'daydate.todaydate': { $lte: allTodayDates }
                    },
                    { 'daydate.$': 1 }
                ).sort({ 'daydate.todaydate': -1 });
    
                if (!fillInfohistorical) {
                    // Handle the case where no historical data is found
                    return res.status(400).json('No historical data found.');
                }
            }
        
        //****UPDATE---------------- */


       if (coachcheck && traineecheck) { // Both coach and trainee exist
           const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail });

           if (!fillInfo) { // If no existing week log record
               return res.status(400).json('No weekly log record found for this coach.');
           } else {
               // Find the week log for the specified weekdate
               const weekLog = fillInfo.trainees.find(trainee => trainee.traineeEmail === traineeEmail)?.weekLog || [];
               const logArray = weekLog.find(week => week.weekdate === weekdate)?.logs || [];

               // Find the log for the specified todaydate
               const logForDate = logArray.find(day => day.todaydate === allTodayDates);

               if (!logForDate) { // If no log found for the specified todaydate

                
                //-------------------------------
                GoalTotFat =   parseFloat(fillInfohistorical.daydate[0].goaltotFat);
                     
                if(GoalTotFat >= TotalTotFat ) {
                   LeftTotFat = GoalTotFat - TotalTotFat;
                }
                else {

                   LeftTotFat = 0;
                }
                //-------------------------------
                GoalSatFat =   parseFloat(fillInfohistorical.daydate[0].goalsatFat);

                if(GoalSatFat >= TotalSatFat ) {
                    LeftSatFat = GoalSatFat - TotalSatFat;
                }
                else {
                    
                    LeftSatFat = 0;
                }
                //-------------------------------
                GoalProtein =   parseFloat(fillInfohistorical.daydate[0].goalprotein);

                if(GoalProtein >= TotalProtein ) {
                    LeftProtein = GoalProtein - TotalProtein;
                }
                else {
                    
                    LeftProtein = 0;
                }
                //-------------------------------
                GoalSodium =   parseFloat(fillInfohistorical.daydate[0].goalsodium);

                if(GoalSodium >= TotalSodium ) {
                    LeftSodium = GoalSodium - TotalSodium;
                }
                else {
                    
                    LeftSodium = 0;
                }
                //-------------------------------
                GoalPotassium =   parseFloat(fillInfohistorical.daydate[0].goalpotassium);

                if(GoalPotassium >= TotalPotassium ) {
                    LeftPotassium = GoalPotassium - TotalPotassium;
                }
                else {
                    
                    LeftPotassium = 0;
                }
                     
                //-------------------------------
                GoalCholesterol =   parseFloat(fillInfohistorical.daydate[0].goalcholesterol);

                if(GoalCholesterol >= TotalCholesterol ) {
                    LeftCholesterol = GoalCholesterol - TotalCholesterol;
                }
                else {
                    
                    LeftCholesterol = 0;
                }
                  
                //-------------------------------

                GoalCarbs =   parseFloat(fillInfohistorical.daydate[0].goalcarbs);

                if(GoalCarbs >= TotalCarbs ) {
                    LeftCarbs = GoalCarbs - TotalCarbs;
                }
                else {
                    
                    LeftCarbs = 0;
                }
                //-------------------------------
                GoalFiber =   parseFloat(fillInfohistorical.daydate[0].goalfiber);

                if(GoalFiber >= TotalFiber ) {
                  LeftFiber = GoalFiber - TotalFiber;
                }
                else {
                    
                  LeftFiber = 0;
                }
                //-------------------------------
                GoalSugar =   parseFloat(fillInfohistorical.daydate[0].goalsugar);

                if(GoalSugar >= TotalSugar ) {
                    LeftSugar = GoalSugar - TotalSugar;
                }
                else {
                    
                    LeftSugar = 0;
                }
                        
                //-------------------------------

           









                const responseObj = {
                    allTodayDates: allTodayDates,
                
                    // Fill the variables with zeros inside the response object
                    TotalTotFat: Number(0).toFixed(2),
                    GoalTotFat: GoalTotFat.toFixed(2),
                    LeftTotFat: LeftTotFat.toFixed(2),
                    totFatUNIT: 'g',
                
                    TotalSatFat: Number(0).toFixed(2),
                    GoalSatFat: GoalSatFat.toFixed(2),
                    LeftSatFat: LeftSatFat.toFixed(2),
                    satFatUNIT: 'g',
                
                    TotalProtein: Number(0).toFixed(2),
                    GoalProtein: GoalProtein.toFixed(2),
                    LeftProtein: LeftProtein.toFixed(2),
                    proteinUNIT: 'g',
                
                    TotalSodium: Number(0).toFixed(2),
                    GoalSodium: GoalSodium.toFixed(2),
                    LeftSodium: LeftSodium.toFixed(2),
                    sodiumUNIT: 'mg',
                
                    TotalPotassium: Number(0).toFixed(2),
                    GoalPotassium: GoalPotassium.toFixed(2),
                    LeftPotassium: LeftPotassium.toFixed(2),
                    potassiumUNIT: 'mg',
                
                    TotalCholesterol: Number(0).toFixed(2),
                    GoalCholesterol: GoalCholesterol.toFixed(2),
                    LeftCholesterol: LeftCholesterol.toFixed(2),
                    cholesterolUNIT: 'mg',
                
                    TotalCarbs: Number(0).toFixed(2),
                    GoalCarbs: GoalCarbs.toFixed(2),
                    LeftCarbs: LeftCarbs.toFixed(2),
                    carbsUNIT: 'g',
                
                    TotalFiber: Number(0).toFixed(2),
                    GoalFiber: GoalFiber.toFixed(2),
                    LeftFiber: LeftFiber.toFixed(2),
                    fiberUNIT: 'g',
                
                    TotalSugar: Number(0).toFixed(2),
                    GoalSugar: GoalSugar.toFixed(2),
                    LeftSugar: LeftSugar.toFixed(2),
                    sugarUNIT: 'g',
                };
                
                return res.status(200).json(responseObj);



               } else { // If log found for the specified todaydate
                   // Calculate total calories for each meal type

                    
                if(true){
 
                    totalgivenNuteBreakfast = 0;
                    totalgivenNuteLunch = 0;
                    totalgivenNuteDinner = 0;
                    totalgivenNutenack = 0;
                   

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.totFat);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.totFat);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.totFat);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.totFat);
                   });
   
                   TotalTotFat = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;

                                              
                    GoalTotFat =   parseFloat(fillInfohistorical.daydate[0].goaltotFat);
                    
                    if(GoalTotFat >= TotalTotFat ) {
                       LeftTotFat = GoalTotFat - TotalTotFat;
                    }
                    else {

                       LeftTotFat = 0;
                    }

                   
               }

               if(true){

                   totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.satFat);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.satFat);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.satFat);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.satFat);
                   });
   
                   TotalSatFat = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;


                   GoalSatFat =   parseFloat(fillInfohistorical.daydate[0].goalsatFat);

                   if(GoalSatFat >= TotalSatFat ) {
                       LeftSatFat = GoalSatFat - TotalSatFat;
                       console.log(`
                       $Left= ${LeftSatFat} ,
                       $Goal= ${GoalSatFat} ,
                       $Total= ${TotalSatFat} ,

                       `);

                   }
                   else {
                       
                       LeftSatFat = 0;
                   }
                          

               }

                if(true){

                   totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.protein);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.protein);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.protein);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.protein);
                   });
   
                   TotalProtein = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;


                   GoalProtein =   parseFloat(fillInfohistorical.daydate[0].goalprotein);

                   if(GoalProtein >= TotalProtein ) {
                       LeftProtein = GoalProtein - TotalProtein;
                   }
                   else {
                       
                       LeftProtein = 0;
                   }
                                                    

                   


               }

               
                if(true){

                    totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.sodium);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.sodium);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.sodium);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.sodium);
                   });
   
                   TotalSodium = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;


                   GoalSodium =   parseFloat(fillInfohistorical.daydate[0].goalsodium);

                   if(GoalSodium >= TotalSodium ) {
                       LeftSodium = GoalSodium - TotalSodium;
                   }
                   else {
                       
                       LeftSodium = 0;
                   }
                                                       
                           
                                               

               }
                          
                if(true){

                     totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.potassium);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.potassium);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.potassium);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.potassium);
                   });
   
                   TotalPotassium = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;

                                                                                               
                        GoalPotassium =   parseFloat(fillInfohistorical.daydate[0].goalpotassium);

                   if(GoalPotassium >= TotalPotassium ) {
                       LeftPotassium = GoalPotassium - TotalPotassium;
                   }
                   else {
                       
                       LeftPotassium = 0;
                   }
                                                       
                           
                                               


               }
                if(true){

                     totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.cholesterol);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.cholesterol);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.cholesterol);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.cholesterol);
                   });
   

                   TotalCholesterol = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;


                   GoalCholesterol =   parseFloat(fillInfohistorical.daydate[0].goalcholesterol);

                   if(GoalCholesterol >= TotalCholesterol ) {
                       LeftCholesterol = GoalCholesterol - TotalCholesterol;
                   }
                   else {
                       
                       LeftCholesterol = 0;
                   }
                                                                                   
                                                       

               }
                if(true){

                    totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.carbs);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.carbs);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.carbs);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.carbs);
                   });
   
                   TotalCarbs = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;


                 GoalCarbs =   parseFloat(fillInfohistorical.daydate[0].goalcarbs);

               if(GoalCarbs >= TotalCarbs ) {
                   LeftCarbs = GoalCarbs - TotalCarbs;
               }
               else {
                   
                   LeftCarbs = 0;
               }
                                                                               

               }
                if(true){

                   totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.fiber);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.fiber);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.fiber);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.fiber);
                   });
   
                   TotalFiber = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;

                      
                   GoalFiber =   parseFloat(fillInfohistorical.daydate[0].goalfiber);

                 if(GoalFiber >= TotalFiber ) {
                   LeftFiber = GoalFiber - TotalFiber;
                 }
                 else {
                     
                   LeftFiber = 0;
                 }
                          
               }
                if(true){

                   totalgivenNuteBreakfast = 0;
                   totalgivenNuteLunch = 0;
                   totalgivenNuteDinner = 0;
                   totalgivenNutenack = 0;

                   logForDate.mealsExe.breakfast.forEach(meal => {
                       totalgivenNuteBreakfast +=  parseFloat(meal.sugar);
                       
                   });
   
                   logForDate.mealsExe.lunch.forEach(meal => {
                       totalgivenNuteLunch +=  parseFloat(meal.sugar);
                   });
   
                   logForDate.mealsExe.dinner.forEach(meal => {
                       totalgivenNuteDinner +=  parseFloat(meal.sugar);
                   });
   
                   logForDate.mealsExe.snack.forEach(meal => {
                       totalgivenNutenack +=  parseFloat(meal.sugar);
                   });
   
                   TotalSugar = totalgivenNuteBreakfast + totalgivenNuteLunch 
                                               + totalgivenNuteDinner +  totalgivenNutenack;

                                             
                      GoalSugar =   parseFloat(fillInfohistorical.daydate[0].goalsugar);

                   if(GoalSugar >= TotalSugar ) {
                       LeftSugar = GoalSugar - TotalSugar;
                   }
                   else {
                       
                       LeftSugar = 0;
                   }
                                              

               }



               // Construct the response object
               const responseObj = {
                   allTodayDates : allTodayDates,
                   // Fill the variables with zeros inside the response object
                      TotalTotFat: TotalTotFat.toFixed(2),
                      GoalTotFat: GoalTotFat.toFixed(2),
                      LeftTotFat: LeftTotFat.toFixed(2),
                      totFatUNIT: 'g',

                      TotalSatFat: TotalSatFat.toFixed(2),
                      GoalSatFat: GoalSatFat.toFixed(2),
                      LeftSatFat: LeftSatFat.toFixed(2),
                      satFatUNIT: 'g',

                      TotalProtein: TotalProtein.toFixed(2),
                      GoalProtein: GoalProtein.toFixed(2),
                      LeftProtein: LeftProtein.toFixed(2),
                       proteinUNIT: 'g',


                      TotalSodium: TotalSodium.toFixed(2),
                      GoalSodium: GoalSodium.toFixed(2),
                      LeftSodium: LeftSodium.toFixed(2),
                        sodiumUNIT: 'mg',

                      TotalPotassium: TotalPotassium.toFixed(2),
                      GoalPotassium: GoalPotassium.toFixed(2),
                      LeftPotassium: LeftPotassium.toFixed(2),
                        potassiumUNIT: 'mg',


                      TotalCholesterol: TotalCholesterol.toFixed(2),
                      GoalCholesterol: GoalCholesterol.toFixed(2),
                      LeftCholesterol: LeftCholesterol.toFixed(2),
                      cholesterolUNIT: 'mg',

                      TotalCarbs: TotalCarbs.toFixed(2),
                      GoalCarbs: GoalCarbs.toFixed(2),
                      LeftCarbs: LeftCarbs.toFixed(2),
                      carbsUNIT: 'g',

                      TotalFiber: TotalFiber.toFixed(2),
                      GoalFiber: GoalFiber.toFixed(2),
                      LeftFiber: LeftFiber.toFixed(2),
                      fiberUNIT: 'g',

                      TotalSugar: TotalSugar.toFixed(2),
                      GoalSugar: GoalSugar.toFixed(2),
                      LeftSugar: LeftSugar.toFixed(2),
                      sugarUNIT: 'g'
                              

               };

               // Return the response object
               return res.status(200).json(responseObj);
           
               }
           }
       } else {
           console.log('Coach or trainee does NOT exist');
           return res.status(400).json('Coach or trainee does NOT exist');
       }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}



exports.summaryshowdayofWeek = async (req, res) => {
    try {
        const { coachemail, traineeEmail, weekdate } = req.body;

        // Function to generate all dates within the weekdate range
        const getDatesInRange = (startDate, endDate) => {
            const dates = [];
            let currentDate = new Date(startDate);
            while (currentDate <= endDate) {
                dates.push(new Date(currentDate));
                currentDate.setDate(currentDate.getDate() + 1);
            }
            return dates;
        };

        // Split the weekdate range into start and end dates
        const [startDate, endDate] = weekdate.split(' - ').map(date => new Date(date));

        // Get all dates within the weekdate range
        const weekDates = getDatesInRange(startDate, endDate).map(date => date.toISOString().split('T')[0]);

        // Find coach and trainee records
        const coachcheck = await coachesListUser.findOne({ coachemail: coachemail });
        const traineecheck = await coachesListUser.findOne({ "coach.traineeEmail": traineeEmail });

        if (coachcheck && traineecheck) { // Both coach and trainee exist
            const fillInfo = await weeklyTemCoach.findOne({ coachemail: coachemail });

            if (!fillInfo) { // If no existing week log record
                return res.status(400).json('No weekly log record found for this coach.');
            } else {
                // Find the week log for the specified weekdate
                const weekLog = fillInfo.trainees.find(trainee => trainee.traineeEmail === traineeEmail)?.weekLog || [];
                const logArray = weekLog.find(week => week.weekdate === weekdate)?.logs || [];

                // Initialize response object
                let responseObj = [];

                // Iterate through each date in the weekDates
                weekDates.forEach(date => {
                    let dayLog = logArray.find(log => log.todaydate === date);

                    if (!dayLog) {
                        // If the day log does not exist
                        responseObj.push({
                            todaydate: date,
                            totalCaloriesFood: "Not Logged Yet",
                            totalProteinFood: "Not Logged Yet",
                            totalCarbsFood: "Not Logged Yet",
                            totalTotFatFood: "Not Logged Yet",
                            totalCaloriesExercise: "Not Logged Yet"
                        });
                    } else {
                        // If the day log exists, calculate the required values
                        let totalCaloriesFood = 0;
                        let totalProteinFood = 0;
                        let totalCarbsFood = 0;
                        let totalTotFatFood = 0;
                        let totalCaloriesExercise = 0;
                        let exerciseLogged = false;

                        const meals = dayLog.mealsExe;
                        if (meals) {
                            // Calculate total nutrients from food
                            ['breakfast', 'lunch', 'dinner', 'snack'].forEach(mealTime => {
                                meals[mealTime].forEach(meal => {
                                    totalCaloriesFood += parseFloat(meal.totCalories);
                                    totalProteinFood += parseFloat(meal.protein);
                                    totalCarbsFood += parseFloat(meal.carbs);
                                    totalTotFatFood += parseFloat(meal.totFat);
                                });
                            });
                        }

                        const exercises = dayLog.exerc;
                        if (exercises) {
                            // Calculate total calories from exercise
                            exercises.forEach(exercise => {
                                totalCaloriesExercise += parseFloat(exercise.totCalories);
                                exerciseLogged = true;
                            });
                        }

                        // Prepare the response for the current day
                        responseObj.push({
                            todaydate: dayLog.todaydate,
                            totalCaloriesFood: totalCaloriesFood > 0 ? totalCaloriesFood : "Not Logged Yet",
                            totalProteinFood: totalProteinFood > 0 ? totalProteinFood : "Not Logged Yet",
                            totalCarbsFood: totalCarbsFood > 0 ? totalCarbsFood : "Not Logged Yet",
                            totalTotFatFood: totalTotFatFood > 0 ? totalTotFatFood : "Not Logged Yet",
                            totalCaloriesExercise: exerciseLogged ? totalCaloriesExercise : "Not Logged Yet"
                        });
                    }
                });

                // Return the response object
                return res.status(200).json(responseObj);
            }
        } else {
            console.log('Coach or trainee does NOT exist');
            return res.status(400).json('Coach or trainee does NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
}
