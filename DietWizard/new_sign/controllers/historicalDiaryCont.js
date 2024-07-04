const express = require('express');

const router = express.Router();
const path = require('path');

const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const coachmodel =require('../models/coach');
const userChoices = require('../models/userChoices');
const waterintake = require('../models/Waterintake');
const progressphoto = require('../models/progressphotos');
const customfoodexe = require('../models/CustomFoodExe');
const diaryinfo = require('../models/Diaryinfo');
const historicaldiary = require('../models/historicalDiary');
const dailytrackprogress = require('../models/DailyTrackProgress');
const coachrating = require('../models/CoachRating');

const fs = require('fs');
const multer = require('multer');



exports.loginHistorical = async (req, res) => {
    try {
      const { email } = req.body;
      console.log(email);
  
      const user = await userModel.findOne({ email: email });
  
      const TodaytargetDate = new Date().toISOString().slice(0, 10);
      const today = new Date(TodaytargetDate);
      today.setDate(today.getDate() - 1);
      const PreviousDayDate = today.toISOString().slice(0, 10);
  
      console.log(TodaytargetDate);
      console.log(PreviousDayDate);
  
      const TodayTargetfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': TodaytargetDate
      },
      { 'daydate.$': 1 } 
    );
  
      const PreviousDayfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': PreviousDayDate
      },
      { 'daydate.$': 1 } 
    );

    const dailytrackprogressToday = await dailytrackprogress.findOne({
      email: email,
      'daydate.todaydate': TodaytargetDate
    },
    { 'daydate.$': 1 } 
  );

    const coachratingcheck = await coachrating.findOne({ $or: [{ email: email }] });

    const isUserCoach = await userModel.findOne({ email: email, type: 'coach' });
    const ForCoachID = await coachmodel.findOne({ email: email});




  
      if (user) {
        // Find the user in userChoices collection
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !PreviousDayfillInfohistorical) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else { // here

          
         


          if (!TodayTargetfillInfohistorical) { // if for today not found 
            console.log('User info NOT found for today day, now looking for Previous Day..');

            if (PreviousDayfillInfohistorical && PreviousDayfillInfohistorical.daydate.length > 0) {
              const previousDayData = PreviousDayfillInfohistorical.daydate[0];
  
              // Update the  field
              await historicaldiary.findOneAndUpdate(
                { email: email },
                { 
                  $push: { 
                    daydate: {

                        mealsExe: {
                            breakfast: [],
                            lunch: [],
                            dinner: [],
                            snack: []
                        },
                        exerc: [],
                        noteCont: "",

                      todaydate: TodaytargetDate,
                      beforeTDEE: previousDayData.beforeTDEE,
                      afterTDEE: previousDayData.afterTDEE,
                      target: previousDayData.target,
                      activity: previousDayData.activity,
                      sex: previousDayData.sex,
                      age: previousDayData.age,
                      height: previousDayData.height,
                      startweight: previousDayData.startweight,
                      currentweight: previousDayData.currentweight,
                      goalWeight: previousDayData.goalWeight,
                      goalweeklyPer: previousDayData.goalweeklyPer,
                      goalcarbsPer: previousDayData.goalcarbsPer,
                      goalprotienPer: previousDayData.goalprotienPer,
                      goalfatPer: previousDayData.goalfatPer,
                      goalworkWeek: previousDayData.goalworkWeek,
                      goalminWork: previousDayData.goalminWork,
                      goaltotFat: previousDayData.goaltotFat,
                      goalsatFat: previousDayData.goalsatFat,
                      goalprotein: previousDayData.goalprotein,
                      goalsodium: previousDayData.goalsodium,
                      goalpotassium: previousDayData.goalpotassium,
                      goalcholesterol: previousDayData.goalcholesterol,
                      goalcarbs: previousDayData.goalcarbs,
                      goalfiber: previousDayData.goalfiber,
                      goalsugar: previousDayData.goalsugar,
                    }
                  }
                },
                { new: true }
     
              );


              if(!dailytrackprogressToday){

                // Use the most recent entry to fill the new one
                let burnedCal =  parseFloat(previousDayData.beforeTDEE);
                let burnedCalString = `+${burnedCal}`;

                let RemainingCal =  parseFloat(previousDayData.afterTDEE);
                let RemainingCalString = `+${RemainingCal}`;
    
                await dailytrackprogress.findOneAndUpdate(
                  { email: email },
                  {
                    $push: {
                      daydate: {
                        todaydate: TodaytargetDate,
                     
                        beforeTDEE: previousDayData.beforeTDEE,
                        afterTDEE: previousDayData.afterTDEE,
                        remaining: RemainingCalString,
                        burned: burnedCalString,
                        currentweight: previousDayData.currentweight,
                        goalWeight: previousDayData.goalWeight,
                        goalweeklyPer: previousDayData.goalweeklyPer,
                      
                      }
                    }
                  },
                  { new: true }
                );
    
            }



                	   
            




              return res.status(200).json('Today Historical data updated successfully');
            } else {
              console.log('No previous day data found., looking for solution..');

            //   // Fetch the most recent entry in the collection
            // const recentEntry = await historicaldiary.findOne(
            //   { email: email },
            //   {},
            //   { sort: { 'daydate.todaydate': -1 } }
            // );

            const recentEntry = await historicaldiary.findOne(
              {
                email: email,
                'daydate.todaydate': { $lt: TodaytargetDate }
              },
              { 'daydate.$': 1 } // Project only the matched subdocument
            ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry

                if (recentEntry && recentEntry.daydate.length > 0) {
                  console.log('Using the first entry in the collection to populate today\'s data.');
                 const recentEntryDayData = recentEntry.daydate[0];
                 // Update the field with today's entry
                await historicaldiary.findOneAndUpdate(
                  { email: email },
                  {
                    $push: {
                      daydate: {
                        mealsExe: {
                          breakfast: [],
                          lunch: [],
                          dinner: [],
                          snack: []
                        },
                        exerc: [],
                        noteCont: "",
                        todaydate: TodaytargetDate,
                        beforeTDEE: recentEntryDayData.beforeTDEE,
                        afterTDEE: recentEntryDayData.afterTDEE,
                        target: recentEntryDayData.target,
                        activity: recentEntryDayData.activity,
                        sex: recentEntryDayData.sex,
                        age: recentEntryDayData.age,
                        height: recentEntryDayData.height,
                        startweight: recentEntryDayData.startweight,
                        currentweight: recentEntryDayData.currentweight,
                        goalWeight: recentEntryDayData.goalWeight,
                        goalweeklyPer: recentEntryDayData.goalweeklyPer,
                        goalcarbsPer: recentEntryDayData.goalcarbsPer,
                        goalprotienPer: recentEntryDayData.goalprotienPer,
                        goalfatPer: recentEntryDayData.goalfatPer,
                        goalworkWeek: recentEntryDayData.goalworkWeek,
                        goalminWork: recentEntryDayData.goalminWork,
                        goaltotFat: recentEntryDayData.goaltotFat,
                        goalsatFat: recentEntryDayData.goalsatFat,
                        goalprotein: recentEntryDayData.goalprotein,
                        goalsodium: recentEntryDayData.goalsodium,
                        goalpotassium: recentEntryDayData.goalpotassium,
                        goalcholesterol: recentEntryDayData.goalcholesterol,
                        goalcarbs: recentEntryDayData.goalcarbs,
                        goalfiber: recentEntryDayData.goalfiber,
                        goalsugar: recentEntryDayData.goalsugar
                      }
                    }
                  },
                  { new: true }
                );

                const TodayTargetfillInfohistorical = await historicaldiary.findOne({
                  email: email,
                  'daydate.todaydate': TodaytargetDate
                },
                { 'daydate.$': 1 } 
              );

                const TodayDayData = TodayTargetfillInfohistorical.daydate[0];

                if(!dailytrackprogressToday){
    
                  // Use the most recent entry to fill the new one
                  let burnedCal =  parseFloat(TodayDayData.beforeTDEE);
                  let burnedCalString = `+${burnedCal}`;
    
                  let RemainingCal =  parseFloat(TodayDayData.afterTDEE);
                  let RemainingCalString = `+${RemainingCal}`;
      
                  await dailytrackprogress.findOneAndUpdate(
                    { email: email },
                    {
                      $push: {
                        daydate: {
                          todaydate: TodaytargetDate,
                       
                          beforeTDEE: TodayDayData.beforeTDEE,
                          afterTDEE: TodayDayData.afterTDEE,
                          remaining: RemainingCalString,
                          burned: burnedCalString,
                          currentweight: TodayDayData.currentweight,
                          goalWeight: TodayDayData.goalWeight,
                          goalweeklyPer: TodayDayData.goalweeklyPer,
                        
                        }
                      }
                    },
                    { new: true }
                  );
      
              }

                           //-----setupcoachRating
                           if(isUserCoach){
                            if(!coachratingcheck){
                                
                                const newCoachRatingshema = new coachrating({
                                  coachid: ForCoachID.idcoach,
                                  coachemail: email,
                                  currentRate: '0',
                                  NumOfRates: '0',
                                  trainees: []
                              });
                      
                              await newCoachRatingshema.save();
            
                        }
                      }
            
                      //-----setupcoachRating
            

                
              return res.status(200).json('UPDATE FROM FIRST ENTRY.. LETS See');


                } else {
                  console.log('No entries found in the collection.');
                  // Handle the case where no data is available
                  return;
                }

            }
          } else { // if for today found -- then send response ok..
            console.log('Already Exist Historical Info for Today --> SKIPPED..');

            const TodayDayData = TodayTargetfillInfohistorical.daydate[0];

            if(!dailytrackprogressToday){

              // Use the most recent entry to fill the new one
              let burnedCal =  parseFloat(TodayDayData.beforeTDEE);
              let burnedCalString = `+${burnedCal}`;

              let RemainingCal =  parseFloat(TodayDayData.afterTDEE);
              let RemainingCalString = `+${RemainingCal}`;
  
              await dailytrackprogress.findOneAndUpdate(
                { email: email },
                {
                  $push: {
                    daydate: {
                      todaydate: TodaytargetDate,
                   
                      beforeTDEE: TodayDayData.beforeTDEE,
                      afterTDEE: TodayDayData.afterTDEE,
                      remaining: RemainingCalString,
                      burned: burnedCalString,
                      currentweight: TodayDayData.currentweight,
                      goalWeight: TodayDayData.goalWeight,
                      goalweeklyPer: TodayDayData.goalweeklyPer,
                    
                    }
                  }
                },
                { new: true }
              );
  
          }




            return res.status(200).json('Already Exist Historical Info for Today --> SKIPPED..');
          }
        
      
        }// here
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };

  exports.saveDiaryinfo = async (req, res) => {
    try {
      const { email, daydate , remainingProgress } = req.body;
      console.log(`remaning = ${remainingProgress}`);
  
      // Declare variables outside the loop
      let allTodayDates;
      let allNoteContents;
      let allBreakfasts = [];
      let allLunches = [];
      let allDinners = [];
      let allSnacks = [];
      let allExercises = [];
  
      daydate.forEach(day => {
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
  
      // Now you can use these arrays of values outside the loop
      console.log('All Today Dates -- savefn:', allTodayDates);
  
      const userFillChoices = await userChoices.findOne({ email: email });
  
      const TodayfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': allTodayDates
      });

      const TodayHistForProgressDaily = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': allTodayDates
      },
      { 'daydate.$': 1 } 
    );

      const dailytrackprogressToday = await dailytrackprogress.findOne({
        email: email,
        'daydate.todaydate': allTodayDates
      },
      { 'daydate.$': 1 } 
    );
  
      if (userFillChoices) {
        if (!TodayfillInfohistorical) {
          // If no existing diaryinfohistorical record for the email - send back msg
          // Get the most recent entry for the user
          const recentfillInfohistorical = await historicaldiary.findOne(
            { 
              email: email,
              'daydate.todaydate': { $lt: allTodayDates }

            },
            null,
            { sort: { 'daydate.todaydate': -1 }, limit: 1 } // Sort in descending order by todaydate and limit to 1
          );
  
          if (!recentfillInfohistorical) {
            console.log('No historical data found for this user');
            return res.status(400).json('No historical data found for this user');
          } else {
            const recentDaydate = recentfillInfohistorical.daydate[0];
            
            // Use the most recent entry to fill the new one
            await historicaldiary.findOneAndUpdate(
              { email: email },
              {
                $push: {
                  daydate: {
                    todaydate: allTodayDates,
                    mealsExe: {
                      breakfast: allBreakfasts,
                      lunch: allLunches,
                      dinner: allDinners,
                      snack: allSnacks
                    },
                    exerc: allExercises,
                    noteCont: allNoteContents,
                    beforeTDEE: recentDaydate.beforeTDEE,
                    afterTDEE: recentDaydate.afterTDEE,
                    target: recentDaydate.target,
                    activity: recentDaydate.activity,
                    sex: recentDaydate.sex,
                    age: recentDaydate.age,
                    height: recentDaydate.height,
                    startweight: recentDaydate.startweight,
                    currentweight: recentDaydate.currentweight,
                    goalWeight: recentDaydate.goalWeight,
                    goalweeklyPer: recentDaydate.goalweeklyPer,
                    goalcarbsPer: recentDaydate.goalcarbsPer,
                    goalprotienPer: recentDaydate.goalprotienPer,
                    goalfatPer: recentDaydate.goalfatPer,
                    goalworkWeek: recentDaydate.goalworkWeek,
                    goalminWork: recentDaydate.goalminWork,
                    goaltotFat: recentDaydate.goaltotFat,
                    goalsatFat: recentDaydate.goalsatFat,
                    goalprotein: recentDaydate.goalprotein,
                    goalsodium: recentDaydate.goalsodium,
                    goalpotassium: recentDaydate.goalpotassium,
                    goalcholesterol: recentDaydate.goalcholesterol,
                    goalcarbs: recentDaydate.goalcarbs,
                    goalfiber: recentDaydate.goalfiber,
                    goalsugar: recentDaydate.goalsugar
                  }
                }
              },
              { new: true }
            );



                        // Use the most recent entry to fill the new one
                        let burnedCal =  parseFloat(recentDaydate.beforeTDEE);
                        let burnedCalString = `+${burnedCal}`;

                        let RemainingCal =  parseFloat(recentDaydate.afterTDEE);
                        let RemainingCalString = `+${RemainingCal}`;
            

                        
                        await dailytrackprogress.findOneAndUpdate(
                          { email: email },
                          {
                            $push: {
                              daydate: {
                                todaydate: allTodayDates,
                             
                                beforeTDEE: recentDaydate.beforeTDEE,
                                afterTDEE: recentDaydate.afterTDEE,
                                remaining: RemainingCalString,
                                burned: burnedCalString,
                                currentweight: recentDaydate.currentweight,
                                goalWeight: recentDaydate.goalWeight,
                                goalweeklyPer: recentDaydate.goalweeklyPer,
                              
                              }
                            }
                          },
                          { new: true }
                        );





            const responseObj = {
              allBreakfasts: [],
              allLunches: [],
              allDinners: [],
              allSnacks: [],
              allExercises: [],
              allNoteContents: ""
          };
          res.status(200).json(responseObj);
  
           // return res.status(200).json('Filled info based on the most recent entry');
          }
        } else {
          // If existing diaryinfohistorical for email record
            console.log('LOG FROM exist save email');
          // If record exists for todayDate, update the existing entry
          const updateFields = {
            'daydate.$.mealsExe.breakfast': allBreakfasts,
            'daydate.$.mealsExe.lunch': allLunches,
            'daydate.$.mealsExe.dinner': allDinners,
            'daydate.$.mealsExe.snack': allSnacks,
            'daydate.$.exerc': allExercises,
            'daydate.$.noteCont': allNoteContents
          };
  
          await historicaldiary.updateOne(
            { email: email, 'daydate.todaydate': allTodayDates },
            { $set: updateFields }
          );

          //--------------------------------------------------------


           




          if (remainingProgress === null || remainingProgress === 0) {
            remainingProgress = parseFloat(TodayHistForProgressDaily.daydate[0].afterTDEE);
        }
        console.log(remainingProgress);
          let RemainingCalString;
          let burnedCalString;

          if(remainingProgress > 0) {
             RemainingCalString = `+${remainingProgress}`;
          }
          else if(remainingProgress < 0) {
             RemainingCalString = `${remainingProgress}`;
          }
          else if(remainingProgress == 0) {
             RemainingCalString = `${remainingProgress}`;
          }


          let befTDEECalc = parseFloat( TodayHistForProgressDaily.daydate[0].beforeTDEE);
          let aftTDEECalc = parseFloat( TodayHistForProgressDaily.daydate[0].afterTDEE);
    
          
          let burnedCal =  (befTDEECalc - (aftTDEECalc - remainingProgress)).toFixed(2);

          if(burnedCal > 0) {
             burnedCalString = `+${burnedCal}`;
          }
          else if(burnedCal < 0) {
             burnedCalString = `${burnedCal}`;
          }
          else if(burnedCal == 0) {
             burnedCalString = `${burnedCal}`;
          }

          console.log('LOG FROM exist save email2222222222');
          //console.log('TodayHistForProgressDaily:', TodayHistForProgressDaily);
          console.log('Remaining Progress:', RemainingCalString);
          console.log('Burned Calories:', burnedCalString);


            if(!dailytrackprogressToday){ // no dailytrackprogressToday for this date...

        const newEntry = {
                todaydate: allTodayDates,
                beforeTDEE: befTDEECalc.toString(),
                afterTDEE: aftTDEECalc.toString(),
                remaining: RemainingCalString,
                burned: burnedCalString,
                currentweight: TodayHistForProgressDaily.daydate[0].currentweight,
                goalWeight: TodayHistForProgressDaily.daydate[0].goalWeight,
                goalweeklyPer: TodayHistForProgressDaily.daydate[0].goalweeklyPer,
            };

            await dailytrackprogress.updateOne(
                { email: email },
                { $push: { daydate: newEntry } }
            );

            
            }
            else { // there is date log for this daydate


        const updateFieldsdailyprogress = {
         
          'daydate.$.beforeTDEE': TodayHistForProgressDaily.daydate[0].beforeTDEE,
          'daydate.$.afterTDEE': TodayHistForProgressDaily.daydate[0].afterTDEE,
          'daydate.$.remaining': RemainingCalString,
          'daydate.$.burned': burnedCalString,
          'daydate.$.currentweight': TodayHistForProgressDaily.daydate[0].currentweight,
          'daydate.$.goalWeight': TodayHistForProgressDaily.daydate[0].goalWeight,
          'daydate.$.goalweeklyPer': TodayHistForProgressDaily.daydate[0].goalweeklyPer,
      };

  
          await dailytrackprogress.updateOne(
            { email: email, 'daydate.todaydate': allTodayDates },
            { $set: updateFieldsdailyprogress }
          );

        }

          //----------------------------------------------
          return res.status(200).json('Done updating Food & Exe in historicaldiary...');
        }
      } else {
        console.log('User does NOT exist');
        return res.status(400).json('User does NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };
  

exports.showDiaryinfo = async (req, res) => {
  try {
    const { email, daydate } = req.body;

    // Declare variables outside the loop
    let allTodayDates;
    let allNoteContents;
    let allBreakfasts = [];
    let allLunches = [];
    let allDinners = [];
    let allSnacks = [];
    let allExercises = [];

    daydate.forEach(day => {
      const todayDate = day.todaydate;
      allTodayDates = todayDate;
    });

    console.log('All Today Dates -- showfn:', allTodayDates);

    const userFillChoices = await userChoices.findOne({ email: email });

    const TodayfillInfohistorical = await historicaldiary.findOne({
      email: email,
      'daydate.todaydate': allTodayDates
    },
    { 'daydate.$': 1 } 
  );

    

    if (userFillChoices) {
      if (!TodayfillInfohistorical) {
        // If no existing diaryinfohistorical email record, error 400
        // Get the most recent entry for the user
        const recentfillInfohistorical = await historicaldiary.findOne(
          { email: email },
          { daydate: { $slice: -1 } } // This returns the last entry in the daydate array
        );

        if (!recentfillInfohistorical) {
          console.log('No historical data found for this user');
          return res.status(400).json('No historical data found for this user');
        } else {
          const recentDaydate = recentfillInfohistorical.daydate[0];

          // Use the most recent entry to fill the new one
          const newEntry = {
            todaydate: allTodayDates,
            mealsExe: {
              breakfast: [],
              lunch: [],
              dinner: [],
              snack: []
            },
            exerc: [],
            noteCont: "",
            beforeTDEE: recentDaydate.beforeTDEE,
            afterTDEE: recentDaydate.afterTDEE,
            target: recentDaydate.target,
            activity: recentDaydate.activity,
            sex: recentDaydate.sex,
            age: recentDaydate.age,
            height: recentDaydate.height,
            startweight: recentDaydate.startweight,
            currentweight: recentDaydate.currentweight,
            goalWeight: recentDaydate.goalWeight,
            goalweeklyPer: recentDaydate.goalweeklyPer,
            goalcarbsPer: recentDaydate.goalcarbsPer,
            goalprotienPer: recentDaydate.goalprotienPer,
            goalfatPer: recentDaydate.goalfatPer,
            goalworkWeek: recentDaydate.goalworkWeek,
            goalminWork: recentDaydate.goalminWork,
            goaltotFat: recentDaydate.goaltotFat,
            goalsatFat: recentDaydate.goalsatFat,
            goalprotein: recentDaydate.goalprotein,
            goalsodium: recentDaydate.goalsodium,
            goalpotassium: recentDaydate.goalpotassium,
            goalcholesterol: recentDaydate.goalcholesterol,
            goalcarbs: recentDaydate.goalcarbs,
            goalfiber: recentDaydate.goalfiber,
            goalsugar: recentDaydate.goalsugar
          };

          await historicaldiary.findOneAndUpdate(
            { email: email },
            { $push: { daydate: newEntry } },
            { new: true }
          );


          const responseObj = {
            allBreakfasts: [],
            allLunches: [],
            allDinners: [],
            allSnacks: [],
            allExercises: [],
            allNoteContents: ""
        };
        res.status(200).json(responseObj);
          //return res.status(200).json('Filled info based on the most recent entry');
        }
      } else {
        const logArray = TodayfillInfohistorical.daydate;
        let logsExist = false;

        for (const loga of logArray) {
          if (loga.todaydate === allTodayDates) {
            logsExist = true;

            allBreakfasts = loga.mealsExe.breakfast;
            allLunches = loga.mealsExe.lunch;
            allDinners = loga.mealsExe.dinner;
            allSnacks = loga.mealsExe.snack;
            allExercises = loga.exerc;
            allNoteContents = loga.noteCont;
          }
        }

        if (logsExist) {
          // If logs exist for today's date, send the response
          const responseObj = {
            allBreakfasts: allBreakfasts,
            allLunches: allLunches,
            allDinners: allDinners,
            allSnacks: allSnacks,
            allExercises: allExercises,
            allNoteContents: allNoteContents
          };

          return res.json(responseObj);
        } else {
          return res.status(404).json('No logs found for the given date.');
        }
      }
    } else {
      console.log('User does NOT exist');
      return res.status(404).json('User does NOT exist');
    }
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
};



exports.CalTotCaloriesDiaryinfo = async (req, res) => {
  try {

      const { email, daydate } = req.body;

      console.log('Email:', email);
      
      // Declare variables outside the loop
      let allTodayDates;
      let totalCaloriesBreakfast = 0;
      let totalCaloriesLunch = 0;
      let totalCaloriesDinner = 0;
      let totalCaloriesSnack = 0;
      let totalCaloriesOVERALL=0;
      let totalCaloriesGOALS = 0;
      
      daydate.forEach(day => {
          const todayDate = day.todaydate;
        
          allTodayDates = todayDate;

      });

    
    //console.log('All Today Dates -- showfn :', allTodayDates);

      const userFillChoices = await userChoices.findOne({ email: email });
      const searchNutri = await userChoices.findOne({ email: email });

      const TodayfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': allTodayDates
      },
      { 'daydate.$': 1 } 
    );

      if (userFillChoices) {
         
          if (!TodayfillInfohistorical) {
              // If no existing diaryinfo email record, error 400
              return res.status(400).json('User does not have any logged yet.');
          }   else {
            const logForDate = TodayfillInfohistorical.daydate.find(day => day.todaydate === allTodayDates);
    
            if (!logForDate) {
              totalCaloriesGOALS = parseFloat(TodayfillInfohistorical.daydate[0].afterTDEE);
    
              const responseObj = {
                allTodayDates: allTodayDates,
                totalCaloriesBreakfast: 0,
                totalCaloriesLunch: 0,
                totalCaloriesDinner: 0,
                totalCaloriesSnack: 0,
                totalCaloriesOVERALL: 0,
                totalCaloriesGOALS: totalCaloriesGOALS,
                totalCaloriesUNIT: 'Kcal'
              };
              return res.status(200).json(responseObj);
            } else {
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
    
              totalCaloriesGOALS =  parseFloat(TodayfillInfohistorical.daydate[0].afterTDEE);
    
              // Construct the response object
              const responseObj = {
                allTodayDates: allTodayDates,
                totalCaloriesBreakfast: totalCaloriesBreakfast,
                totalCaloriesLunch: totalCaloriesLunch,
                totalCaloriesDinner: totalCaloriesDinner,
                totalCaloriesSnack: totalCaloriesSnack,
                totalCaloriesOVERALL: totalCaloriesOVERALL,
                totalCaloriesGOALS: totalCaloriesGOALS,
                totalCaloriesUNIT: 'Kcal'
              };
    
              // Return the response object
              return res.status(200).json(responseObj);
            }
          }
      } else {
          console.log('User does NOT exist');
          return res.status(400).json('User does NOT exist');
      }
  } catch (e) {
      console.error(e);
      res.sendStatus(500);
  }
}

// exports.CalTotGivenNutDiaryinfo = async (req, res) => {
//   try {

//       const { email, daydate , givenNute} = req.body;

//       console.log('Email: ', email);
//       console.log('givenNute: ',givenNute);
      
//       // Declare variables outside the loop
//       let allTodayDates;
//       let totalgivenNuteBreakfast = 0;
//       let totalgivenNuteLunch = 0;
//       let totalgivenNuteDinner = 0;
//       let totalgivenNutenack = 0;
//       let totalgivenNuteOVERALL=0;
//       let totalgivenNuteGOALS=0;
//       //------------------------------------------
 
//       let GoalTotFat = 0;
//       let GoalSatFat = 0;

//       let GoalProtein = 0;

//       let GoalSodium = 0;

//       let GoalPotassium = 0;

//       let GoalCholesterol = 0;

//       let GoalCarbs = 0;

//       let GoalFiber = 0;
//         let GoalSugar = 0;


      
//       daydate.forEach(day => {
//           const todayDate = day.todaydate;
        
//           allTodayDates = todayDate;

//       });

    
//     //console.log('All Today Dates -- showfn :', allTodayDates);

//       const userFillChoices = await userChoices.findOne({ email: email });
//       const searchNutri = await userChoices.findOne({ email: email });

//       const TodayfillInfohistorical = await historicaldiary.findOne({
//         email: email,
//         'daydate.todaydate': allTodayDates
//       });


//       if (userFillChoices) {
        

//           if (!TodayfillInfohistorical) {
//               // If no existing diaryinfo email record, error 400
//               return res.status(400).json('User does not have any logged yet.');
//           }  else {

//       // Find the record for the specified todaydate
//       const logForDate = fillInfo.daydate.find(day => day.todaydate === allTodayDates);

//       if (!logForDate) {
//           // If no record found for the specified date, return empty arrays with 200 OK

//           if(givenNute === 'totFat'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].totFat);
//           }
//           else if(givenNute === 'satFat'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].satFat);
//           }
//           else if(givenNute === 'protein'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].protein);
//           }
//           else if(givenNute === 'sodium'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].sodium);
//           }
//           else if(givenNute === 'potassium'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].potassium);
//           }
//           else if(givenNute === 'cholesterol'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].cholesterol);
//           }
//           else if(givenNute === 'carbs'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].carbs);
//           }
//           else if(givenNute === 'fiber'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].fiber);
//           }
//           else if(givenNute === 'sugar'){ 
//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].sugar);
//           }

          
//           const responseObj = {
//               allTodayDates : allTodayDates,
//               totalgivenNuteBreakfast: 0,
//               totalgivenNuteLunch: 0,
//               totalgivenNuteDinner: 0,
//               totalgivenNutenack: 0,
//               totalgivenNuteOVERALL: 0,

//               totalgivenNuteUNIT: getNutrientUnit(givenNute),
//               totalgivenNuteGOALS:totalgivenNuteGOALS,
        

//           };
//           return res.status(200).json(responseObj);
//       } else {
//           // If record found for the specified date, calculate total calories for each meal type
        
          
         
          
//           if(givenNute === 'totFat'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.totFat);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.totFat);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.totFat);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.totFat);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

//               totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].totFat);

//           }

//           else if(givenNute === 'satFat'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.satFat);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.satFat);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.satFat);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.satFat);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

//                   totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].satFat);


//           }

//           else if(givenNute === 'protein'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.protein);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.protein);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.protein);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.protein);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

//                    totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].protein);

//           }

          
//           else if(givenNute === 'sodium'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.sodium);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.sodium);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.sodium);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.sodium);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

//                   totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].sodium);

//           }
                     
//           else if(givenNute === 'potassium'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.potassium);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.potassium);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.potassium);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.potassium);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

//                                           totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].potassium);                        

//           }
//           else if(givenNute === 'cholesterol'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.cholesterol);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.cholesterol);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.cholesterol);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.cholesterol);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

//                                           totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].cholesterol);    

//           }
//           else if(givenNute === 'carbs'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.carbs);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.carbs);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.carbs);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.carbs);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;
//                                           totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].carbs);    

//           }
//           else if(givenNute === 'fiber'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.fiber);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.fiber);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.fiber);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.fiber);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;
//                                           totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].fiber);   

//           }
//           else if(givenNute === 'sugar'){

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.sugar);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.sugar);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.sugar);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.sugar);
//               });

//               totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;
//                                           totalgivenNuteGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].sugar);   

//           }



//           // Construct the response object
//           const responseObj = {
//               allTodayDates : allTodayDates,
//               totalgivenNuteBreakfast: totalgivenNuteBreakfast,
//               totalgivenNuteLunch: totalgivenNuteLunch,
//               totalgivenNuteDinner: totalgivenNuteDinner,
//               totalgivenNutenack: totalgivenNutenack,
//               totalgivenNuteOVERALL:totalgivenNuteOVERALL,
//               totalgivenNuteUNIT: getNutrientUnit(givenNute),
//               totalgivenNuteGOALS:totalgivenNuteGOALS,

//           };

//           // Return the response object
//           return res.status(200).json(responseObj);
//       }

//           }
//       } else {
//           console.log('User does NOT exist');
//           return res.status(400).json('User does NOT exist');
//       }
//   } catch (e) {
//       console.error(e);
//       res.sendStatus(500);
//   }
// }

// function getNutrientUnit(nutrient) {
//   switch (nutrient) {
//       case 'totFat':
//       case 'satFat':
//       case 'protein':
//       case 'carbs':
//       case 'fiber':
//       case 'sugar':
//           return 'g';
//       case 'sodium':
//       case 'potassium':
//       case 'cholesterol':
//           return 'mg';
//       // Return null or empty string for unknown nutrients
//       default:
//           return ''; // or return '';
//   }
// }




exports.CalTotGivenNutDiaryinfo = async (req, res) => {
  try {
      const { email, daydate, givenNute } = req.body;

      console.log('Email: ', email);
      console.log('givenNute: ', givenNute);
      console.log('Request Body:', req.body); // Log the entire request body

      let allTodayDates;
      let totalgivenNuteBreakfast = 0;
      let totalgivenNuteLunch = 0;
      let totalgivenNuteDinner = 0;
      let totalgivenNuteSnack = 0;
      let totalgivenNuteOVERALL = 0;
      let totalgivenNuteGOALS = 0;

      daydate.forEach(day => {
          allTodayDates = day.todaydate;
      });

      const userFillChoices = await userChoices.findOne({ email: email });
      const searchNutri = await userChoices.findOne({ email: email });

      const TodayfillInfohistorical = await historicaldiary.findOne({
          email: email,
          'daydate.todaydate': allTodayDates
      },
      { 'daydate.$': 1 } 
    );

      if (!userFillChoices) {
          console.log('User does NOT exist');
          return res.status(400).json('User does NOT exist');
      }

      if (!TodayfillInfohistorical) {
          return res.status(400).json('User does not have any logged yet.');
      }

      const logForDate = TodayfillInfohistorical.daydate.find(day => day.todaydate === allTodayDates);

      if (!logForDate) {
          totalgivenNuteGOALS = parseFloat(getGoalValue(TodayfillInfohistorical.daydate[0], givenNute));

          const responseObj = {
              allTodayDates: allTodayDates,
              totalgivenNuteBreakfast: 0,
              totalgivenNuteLunch: 0,
              totalgivenNuteDinner: 0,
              totalgivenNuteSnack: 0,
              totalgivenNuteOVERALL: 0,
              totalgivenNuteUNIT: getNutrientUnit(givenNute),
              totalgivenNuteGOALS: totalgivenNuteGOALS
          };
          console.log('Response Object:', responseObj); // Log the response object before sending
          return res.status(200).json(responseObj);
      }

      logForDate.mealsExe.breakfast.forEach(meal => {
          totalgivenNuteBreakfast += parseFloat(meal[givenNute]);
      });

      logForDate.mealsExe.lunch.forEach(meal => {
          totalgivenNuteLunch += parseFloat(meal[givenNute]);
      });

      logForDate.mealsExe.dinner.forEach(meal => {
          totalgivenNuteDinner += parseFloat(meal[givenNute]);
      });

      logForDate.mealsExe.snack.forEach(meal => {
          totalgivenNuteSnack += parseFloat(meal[givenNute]);
      });

      totalgivenNuteOVERALL = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNuteSnack;
      totalgivenNuteGOALS = parseFloat(getGoalValue(TodayfillInfohistorical.daydate[0], givenNute));

      const responseObj = {
          allTodayDates: allTodayDates,
          totalgivenNuteBreakfast: totalgivenNuteBreakfast,
          totalgivenNuteLunch: totalgivenNuteLunch,
          totalgivenNuteDinner: totalgivenNuteDinner,
          totalgivenNuteSnack: totalgivenNuteSnack,
          totalgivenNuteOVERALL: totalgivenNuteOVERALL.toFixed(2), // if not worked back here .. and remove .toFixed(2)
          totalgivenNuteUNIT: getNutrientUnit(givenNute),
          totalgivenNuteGOALS: totalgivenNuteGOALS
      };

      console.log('Response Object:', responseObj); // Log the final response object before sending

      return res.status(200).json(responseObj);

  } catch (e) {
      console.error(e);
      res.sendStatus(500);
  }
};

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
      default:
          return '';
  }
}

function getGoalValue(dayRecord, nutrient) {
  switch (nutrient) {
      case 'totFat':
          return dayRecord.goaltotFat;
      case 'satFat':
          return dayRecord.goalsatFat;
      case 'protein':
          return dayRecord.goalprotein;
      case 'sodium':
          return dayRecord.goalsodium;
      case 'potassium':
          return dayRecord.goalpotassium;
      case 'cholesterol':
          return dayRecord.goalcholesterol;
      case 'carbs':
          return dayRecord.goalcarbs;
      case 'fiber':
          return dayRecord.goalfiber;
      case 'sugar':
          return dayRecord.goalsugar;
      default:
          return 0;
  }
}


// exports.CalTotGoalLeftNutDiaryinfo = async (req, res) => {
//   try {

//       const { email, daydate } = req.body;

//       console.log('Email: ', email);
     
      
//       // Declare variables outside the loop
//       let allTodayDates;
//       let totalgivenNuteBreakfast = 0;
//       let totalgivenNuteLunch = 0;
//       let totalgivenNuteDinner = 0;
//       let totalgivenNutenack = 0;
//       let totalgivenNuteOVERALL=0;
//       //------------------------------------------
//       let TotalTotFat = 0;
//       let GoalTotFat = 0;
//       let LeftTotFat = 0;

//       let TotalSatFat = 0;
//       let GoalSatFat = 0;
//       let LeftSatFat = 0;

//       let TotalProtein = 0;
//       let GoalProtein = 0;
//       let LeftProtein = 0;

//       let TotalSodium = 0;
//       let GoalSodium = 0;
//       let LeftSodium = 0;

//       let TotalPotassium = 0;
//       let GoalPotassium = 0;
//       let LeftPotassium = 0;

//       let TotalCholesterol = 0;
//       let GoalCholesterol = 0;
//       let LeftCholesterol = 0;

//       let TotalCarbs = 0;
//       let GoalCarbs = 0;
//       let LeftCarbs = 0;

//       let TotalFiber = 0;
//       let GoalFiber = 0;
//       let LeftFiber = 0;

//       let TotalSugar = 0;
//       let GoalSugar = 0;
//       let LeftSugar = 0;


      
//       daydate.forEach(day => {
//           const todayDate = day.todaydate;
        
//           allTodayDates = todayDate;

//       });

    
//     //console.log('All Today Dates -- showfn :', allTodayDates);

//       const userFillChoices = await userChoices.findOne({ email: email });
//       const searchNutri = await userChoices.findOne({ email: email });

//       const TodayfillInfohistorical = await historicaldiary.findOne({
//         email: email,
//         'daydate.todaydate': allTodayDates
//       });

//       if (userFillChoices) {
        

//           if (!TodayfillInfohistorical) {
//               // If no existing diaryinfo email record, error 400
//               return res.status(400).json('User does not have any logged yet.');
//           }  else {

//       // Find the record for the specified todaydate
//       const logForDate = TodayfillInfohistorical.daydate.find(day => day.todaydate === allTodayDates);

//       if (!logForDate) {
//           // If no record found for the specified date, return empty arrays with 200 OK

//           //-------------------------------
//           GoalTotFat =   parseFloat(TodayfillInfohistorical.daydate[0].totFat);
               
//           if(GoalTotFat >= TotalTotFat ) {
//              LeftTotFat = GoalTotFat - TotalTotFat;
//           }
//           else {

//              LeftTotFat = 0;
//           }
//           //-------------------------------
//           GoalSatFat =   parseFloat(TodayfillInfohistorical.daydate[0].satFat);

//           if(GoalSatFat >= TotalSatFat ) {
//               LeftSatFat = GoalSatFat - TotalSatFat;
//           }
//           else {
              
//               LeftSatFat = 0;
//           }
//           //-------------------------------
//           GoalProtein =   parseFloat(TodayfillInfohistorical.daydate[0].protein);

//           if(GoalProtein >= TotalProtein ) {
//               LeftProtein = GoalProtein - TotalProtein;
//           }
//           else {
              
//               LeftProtein = 0;
//           }
//           //-------------------------------
//           GoalSodium =   parseFloat(TodayfillInfohistorical.daydate[0].sodium);

//           if(GoalSodium >= TotalSodium ) {
//               LeftSodium = GoalSodium - TotalSodium;
//           }
//           else {
              
//               LeftSodium = 0;
//           }
//           //-------------------------------
//           GoalPotassium =   parseFloat(TodayfillInfohistorical.daydate[0].potassium);

//           if(GoalPotassium >= TotalPotassium ) {
//               LeftPotassium = GoalPotassium - TotalPotassium;
//           }
//           else {
              
//               LeftPotassium = 0;
//           }
               
//           //-------------------------------
//           GoalCholesterol =   parseFloat(TodayfillInfohistorical.daydate[0].cholesterol);

//           if(GoalCholesterol >= TotalCholesterol ) {
//               LeftCholesterol = GoalCholesterol - TotalCholesterol;
//           }
//           else {
              
//               LeftCholesterol = 0;
//           }
            
//           //-------------------------------

//           GoalCarbs =   parseFloat(TodayfillInfohistorical.daydate[0].carbs);

//           if(GoalCarbs >= TotalCarbs ) {
//               LeftCarbs = GoalCarbs - TotalCarbs;
//           }
//           else {
              
//               LeftCarbs = 0;
//           }
//           //-------------------------------
//           GoalFiber =   parseFloat(TodayfillInfohistorical.daydate[0].fiber);

//           if(GoalFiber >= TotalFiber ) {
//             LeftFiber = GoalFiber - TotalFiber;
//           }
//           else {
              
//             LeftFiber = 0;
//           }
//           //-------------------------------
//           GoalSugar =   parseFloat(TodayfillInfohistorical.daydate[0].sugar);

//           if(GoalSugar >= TotalSugar ) {
//               LeftSugar = GoalSugar - TotalSugar;
//           }
//           else {
              
//               LeftSugar = 0;
//           }
                  
//           //-------------------------------

     









//           const responseObj = {
//               allTodayDates: allTodayDates,
          
//               // Fill the variables with zeros inside the response object
//               TotalTotFat: Number(0).toFixed(2),
//               GoalTotFat: GoalTotFat.toFixed(2),
//               LeftTotFat: LeftTotFat.toFixed(2),
//               totFatUNIT: 'g',
          
//               TotalSatFat: Number(0).toFixed(2),
//               GoalSatFat: GoalSatFat.toFixed(2),
//               LeftSatFat: LeftSatFat.toFixed(2),
//               satFatUNIT: 'g',
          
//               TotalProtein: Number(0).toFixed(2),
//               GoalProtein: GoalProtein.toFixed(2),
//               LeftProtein: LeftProtein.toFixed(2),
//               proteinUNIT: 'g',
          
//               TotalSodium: Number(0).toFixed(2),
//               GoalSodium: GoalSodium.toFixed(2),
//               LeftSodium: LeftSodium.toFixed(2),
//               sodiumUNIT: 'mg',
          
//               TotalPotassium: Number(0).toFixed(2),
//               GoalPotassium: GoalPotassium.toFixed(2),
//               LeftPotassium: LeftPotassium.toFixed(2),
//               potassiumUNIT: 'mg',
          
//               TotalCholesterol: Number(0).toFixed(2),
//               GoalCholesterol: GoalCholesterol.toFixed(2),
//               LeftCholesterol: LeftCholesterol.toFixed(2),
//               cholesterolUNIT: 'mg',
          
//               TotalCarbs: Number(0).toFixed(2),
//               GoalCarbs: GoalCarbs.toFixed(2),
//               LeftCarbs: LeftCarbs.toFixed(2),
//               carbsUNIT: 'g',
          
//               TotalFiber: Number(0).toFixed(2),
//               GoalFiber: GoalFiber.toFixed(2),
//               LeftFiber: LeftFiber.toFixed(2),
//               fiberUNIT: 'g',
          
//               TotalSugar: Number(0).toFixed(2),
//               GoalSugar: GoalSugar.toFixed(2),
//               LeftSugar: LeftSugar.toFixed(2),
//               sugarUNIT: 'g',
//           };
          
//           return res.status(200).json(responseObj);
//       } else {
//           // If record found for the specified date, calculate total calories for each meal type
        
          
         
          
//           if(true){

//                totalgivenNuteBreakfast = 0;
//                totalgivenNuteLunch = 0;
//                totalgivenNuteDinner = 0;
//                totalgivenNutenack = 0;
              

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.totFat);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.totFat);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.totFat);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.totFat);
//               });

//               TotalTotFat = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

                                         
//                GoalTotFat =   parseFloat(TodayfillInfohistorical.daydate[0].totFat);
               
//                if(GoalTotFat >= TotalTotFat ) {
//                   LeftTotFat = GoalTotFat - TotalTotFat;
//                }
//                else {

//                   LeftTotFat = 0;
//                }

              
//           }

//           if(true){

//               totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.satFat);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.satFat);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.satFat);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.satFat);
//               });

//               TotalSatFat = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;


//               GoalSatFat =   parseFloat(TodayfillInfohistorical.daydate[0].satFat);

//               if(GoalSatFat >= TotalSatFat ) {
//                   LeftSatFat = GoalSatFat - TotalSatFat;
//                   console.log(`
//                   $Left= ${LeftSatFat} ,
//                   $Goal= ${GoalSatFat} ,
//                   $Total= ${TotalSatFat} ,

//                   `);

//               }
//               else {
                  
//                   LeftSatFat = 0;
//               }
                     

//           }

//            if(true){

//               totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.protein);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.protein);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.protein);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.protein);
//               });

//               TotalProtein = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;


//               GoalProtein =   parseFloat(TodayfillInfohistorical.daydate[0].protein);

//               if(GoalProtein >= TotalProtein ) {
//                   LeftProtein = GoalProtein - TotalProtein;
//               }
//               else {
                  
//                   LeftProtein = 0;
//               }
                                               

              


//           }

          
//            if(true){

//                totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.sodium);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.sodium);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.sodium);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.sodium);
//               });

//               TotalSodium = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;


//               GoalSodium =   parseFloat(TodayfillInfohistorical.daydate[0].sodium);

//               if(GoalSodium >= TotalSodium ) {
//                   LeftSodium = GoalSodium - TotalSodium;
//               }
//               else {
                  
//                   LeftSodium = 0;
//               }
                                                  
                      
                                          

//           }
                     
//            if(true){

//                 totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.potassium);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.potassium);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.potassium);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.potassium);
//               });

//               TotalPotassium = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

                                                                                          
//                    GoalPotassium =   parseFloat(TodayfillInfohistorical.daydate[0].potassium);

//               if(GoalPotassium >= TotalPotassium ) {
//                   LeftPotassium = GoalPotassium - TotalPotassium;
//               }
//               else {
                  
//                   LeftPotassium = 0;
//               }
                                                  
                      
                                          


//           }
//            if(true){

//                 totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.cholesterol);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.cholesterol);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.cholesterol);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.cholesterol);
//               });


//               TotalCholesterol = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;


//               GoalCholesterol =   parseFloat(TodayfillInfohistorical.daydate[0].cholesterol);

//               if(GoalCholesterol >= TotalCholesterol ) {
//                   LeftCholesterol = GoalCholesterol - TotalCholesterol;
//               }
//               else {
                  
//                   LeftCholesterol = 0;
//               }
                                                                              
                                                  

//           }
//            if(true){

//                totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.carbs);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.carbs);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.carbs);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.carbs);
//               });

//               TotalCarbs = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;


//             GoalCarbs =   parseFloat(TodayfillInfohistorical.daydate[0].carbs);

//           if(GoalCarbs >= TotalCarbs ) {
//               LeftCarbs = GoalCarbs - TotalCarbs;
//           }
//           else {
              
//               LeftCarbs = 0;
//           }
                                                                          

//           }
//            if(true){

//               totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.fiber);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.fiber);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.fiber);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.fiber);
//               });

//               TotalFiber = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

                 
//               GoalFiber =   parseFloat(TodayfillInfohistorical.daydate[0].fiber);

//             if(GoalFiber >= TotalFiber ) {
//               LeftFiber = GoalFiber - TotalFiber;
//             }
//             else {
                
//               LeftFiber = 0;
//             }
                     
//           }
//            if(true){

//               totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.sugar);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.sugar);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.sugar);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.sugar);
//               });

//               TotalSugar = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

                                        
//                  GoalSugar =   parseFloat(TodayfillInfohistorical.daydate[0].sugar);

//               if(GoalSugar >= TotalSugar ) {
//                   LeftSugar = GoalSugar - TotalSugar;
//               }
//               else {
                  
//                   LeftSugar = 0;
//               }
                                         

//           }



//           // Construct the response object
//           const responseObj = {
//               allTodayDates : allTodayDates,
//               // Fill the variables with zeros inside the response object
//                  TotalTotFat: TotalTotFat.toFixed(2),
//                  GoalTotFat: GoalTotFat.toFixed(2),
//                  LeftTotFat: LeftTotFat.toFixed(2),
//                  totFatUNIT: 'g',

//                  TotalSatFat: TotalSatFat.toFixed(2),
//                  GoalSatFat: GoalSatFat.toFixed(2),
//                  LeftSatFat: LeftSatFat.toFixed(2),
//                  satFatUNIT: 'g',

//                  TotalProtein: TotalProtein.toFixed(2),
//                  GoalProtein: GoalProtein.toFixed(2),
//                  LeftProtein: LeftProtein.toFixed(2),
//                   proteinUNIT: 'g',


//                  TotalSodium: TotalSodium.toFixed(2),
//                  GoalSodium: GoalSodium.toFixed(2),
//                  LeftSodium: LeftSodium.toFixed(2),
//                    sodiumUNIT: 'mg',

//                  TotalPotassium: TotalPotassium.toFixed(2),
//                  GoalPotassium: GoalPotassium.toFixed(2),
//                  LeftPotassium: LeftPotassium.toFixed(2),
//                    potassiumUNIT: 'mg',


//                  TotalCholesterol: TotalCholesterol.toFixed(2),
//                  GoalCholesterol: GoalCholesterol.toFixed(2),
//                  LeftCholesterol: LeftCholesterol.toFixed(2),
//                  cholesterolUNIT: 'mg',

//                  TotalCarbs: TotalCarbs.toFixed(2),
//                  GoalCarbs: GoalCarbs.toFixed(2),
//                  LeftCarbs: LeftCarbs.toFixed(2),
//                  carbsUNIT: 'g',

//                  TotalFiber: TotalFiber.toFixed(2),
//                  GoalFiber: GoalFiber.toFixed(2),
//                  LeftFiber: LeftFiber.toFixed(2),
//                  fiberUNIT: 'g',

//                  TotalSugar: TotalSugar.toFixed(2),
//                  GoalSugar: GoalSugar.toFixed(2),
//                  LeftSugar: LeftSugar.toFixed(2),
//                  sugarUNIT: 'g'
                         

//           };

//           // Return the response object
//           return res.status(200).json(responseObj);
//       }

//           }
//       } else {
//           console.log('User does NOT exist');
//           return res.status(400).json('User does NOT exist');
//       }
//   } catch (e) {
//       console.error(e);
//       res.sendStatus(500);
//   }
// }




exports.CalTotGoalLeftNutDiaryinfo = async (req, res) => {
  try {
    const { email, daydate } = req.body;
    console.log('Email:', email);

    // Initialize variables
    let allTodayDates;
    let totalgivenNuteBreakfast = 0;
    let totalgivenNuteLunch = 0;
    let totalgivenNuteDinner = 0;
    let totalgivenNutenack = 0;
    let totalgivenNuteOVERALL = 0;

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

    // Extract the dates from the request body
    daydate.forEach(day => {
      const todayDate = day.todaydate;
      allTodayDates = todayDate;
    });

    // Fetch user choices and historical data
    const userFillChoices = await userChoices.findOne({ email: email });
    const TodayfillInfohistorical = await historicaldiary.findOne({
      email: email,
      'daydate.todaydate': allTodayDates
    },
    { 'daydate.$': 1 } 
  );

    if (userFillChoices) {
      if (!TodayfillInfohistorical) {
        return res.status(400).json('User does not have any logged yet.');
      } else {
        const logForDate = TodayfillInfohistorical.daydate.find(day => day.todaydate === allTodayDates);

        if (!logForDate) {
          // Fill goal values and left values with data from the first daydate entry if logForDate is not found
          GoalTotFat = parseFloat(TodayfillInfohistorical.daydate[0].goaltotFat);
          LeftTotFat = GoalTotFat >= TotalTotFat ? GoalTotFat - TotalTotFat : 0;

          GoalSatFat = parseFloat(TodayfillInfohistorical.daydate[0].goalsatFat);
          LeftSatFat = GoalSatFat >= TotalSatFat ? GoalSatFat - TotalSatFat : 0;

          GoalProtein = parseFloat(TodayfillInfohistorical.daydate[0].goalprotein);
          LeftProtein = GoalProtein >= TotalProtein ? GoalProtein - TotalProtein : 0;

          GoalSodium = parseFloat(TodayfillInfohistorical.daydate[0].goalsodium);
          LeftSodium = GoalSodium >= TotalSodium ? GoalSodium - TotalSodium : 0;

          GoalPotassium = parseFloat(TodayfillInfohistorical.daydate[0].goalpotassium);
          LeftPotassium = GoalPotassium >= TotalPotassium ? GoalPotassium - TotalPotassium : 0;

          GoalCholesterol = parseFloat(TodayfillInfohistorical.daydate[0].goalcholesterol);
          LeftCholesterol = GoalCholesterol >= TotalCholesterol ? GoalCholesterol - TotalCholesterol : 0;

          GoalCarbs = parseFloat(TodayfillInfohistorical.daydate[0].goalcarbs);
          LeftCarbs = GoalCarbs >= TotalCarbs ? GoalCarbs - TotalCarbs : 0;

          GoalFiber = parseFloat(TodayfillInfohistorical.daydate[0].goalfiber);
          LeftFiber = GoalFiber >= TotalFiber ? GoalFiber - TotalFiber : 0;

          GoalSugar = parseFloat(TodayfillInfohistorical.daydate[0].goalsugar);
          LeftSugar = GoalSugar >= TotalSugar ? GoalSugar - TotalSugar : 0;

          const responseObj = {
            allTodayDates: allTodayDates,
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

          return res.status(200).json(responseObj);
        } else {
          // Calculate total nutrients for each meal type
          const calculateNutrients = (meals, nutrient) => {
            return meals.reduce((total, meal) => total + parseFloat(meal[nutrient]), 0);
          };

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'totFat');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'totFat');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'totFat');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'totFat');
          TotalTotFat = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalTotFat = parseFloat(TodayfillInfohistorical.daydate[0].goaltotFat);
          LeftTotFat = GoalTotFat >= TotalTotFat ? GoalTotFat - TotalTotFat : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'satFat');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'satFat');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'satFat');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'satFat');
          TotalSatFat = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalSatFat = parseFloat(TodayfillInfohistorical.daydate[0].goalsatFat);
          LeftSatFat = GoalSatFat >= TotalSatFat ? GoalSatFat - TotalSatFat : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'protein');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'protein');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'protein');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'protein');
          TotalProtein = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalProtein = parseFloat(TodayfillInfohistorical.daydate[0].goalprotein);
          LeftProtein = GoalProtein >= TotalProtein ? GoalProtein - TotalProtein : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'sodium');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'sodium');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'sodium');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'sodium');
          TotalSodium = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalSodium = parseFloat(TodayfillInfohistorical.daydate[0].goalsodium);
          LeftSodium = GoalSodium >= TotalSodium ? GoalSodium - TotalSodium : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'potassium');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'potassium');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'potassium');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'potassium');
          TotalPotassium = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalPotassium = parseFloat(TodayfillInfohistorical.daydate[0].goalpotassium);
          LeftPotassium = GoalPotassium >= TotalPotassium ? GoalPotassium - TotalPotassium : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'cholesterol');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'cholesterol');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'cholesterol');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'cholesterol');
          TotalCholesterol = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalCholesterol = parseFloat(TodayfillInfohistorical.daydate[0].goalcholesterol);
          LeftCholesterol = GoalCholesterol >= TotalCholesterol ? GoalCholesterol - TotalCholesterol : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'carbs');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'carbs');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'carbs');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'carbs');
          TotalCarbs = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalCarbs = parseFloat(TodayfillInfohistorical.daydate[0].goalcarbs);
          LeftCarbs = GoalCarbs >= TotalCarbs ? GoalCarbs - TotalCarbs : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'fiber');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'fiber');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'fiber');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'fiber');
          TotalFiber = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalFiber = parseFloat(TodayfillInfohistorical.daydate[0].goalfiber);
          LeftFiber = GoalFiber >= TotalFiber ? GoalFiber - TotalFiber : 0;

          totalgivenNuteBreakfast = calculateNutrients(logForDate.mealsExe.breakfast, 'sugar');
          totalgivenNuteLunch = calculateNutrients(logForDate.mealsExe.lunch, 'sugar');
          totalgivenNuteDinner = calculateNutrients(logForDate.mealsExe.dinner, 'sugar');
          totalgivenNutenack = calculateNutrients(logForDate.mealsExe.snack, 'sugar');
          TotalSugar = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalSugar = parseFloat(TodayfillInfohistorical.daydate[0].goalsugar);
          LeftSugar = GoalSugar >= TotalSugar ? GoalSugar - TotalSugar : 0;

          const responseObj = {
            allTodayDates: allTodayDates,
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

          return res.status(200).json(responseObj);
        }
      }
    } else {
      return res.status(400).json('User does NOT exist');
    }
  } catch (e) {
    console.log(e);
    res.sendStatus(500);
  }
};

exports.WelcomeCaloriesDiaryinfo = async (req, res) => {
  try {

      const { email, daydate } = req.body;

      console.log('Email:', email);
      
      // Declare variables outside the loop
      let allTodayDates;
      let totalCaloriesBreakfast = 0;
      let totalCaloriesLunch = 0;
      let totalCaloriesDinner = 0;
      let totalCaloriesSnack = 0;
      let totalCaloriesOVERALL=0;
      let totalCaloriesExerOVERALL = 0;
      let totalCaloriesRemaningOVERALL = 0;
      let totalCaloriesGOALS = 0;
     
      
      daydate.forEach(day => {
          const todayDate = day.todaydate;
        
          allTodayDates = todayDate;

      });

    
    //console.log('All Today Dates -- showfn :', allTodayDates);

      const userFillChoices = await userChoices.findOne({ email: email });
      const searchNutri = await userChoices.findOne({ email: email });
      const TodayfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': allTodayDates
      },
      { 'daydate.$': 1 } 
    );

      if (userFillChoices) {
   

          if (!TodayfillInfohistorical) {
              // If no existing diaryinfo email record, error 400
              return res.status(400).json('User does not have any logged yet.');
          }  else {

      // Find the record for the specified todaydate
      const logForDate = TodayfillInfohistorical.daydate.find(day => day.todaydate === allTodayDates);

      if (!logForDate) {
          // If no record found for the specified date, return empty arrays with 200 OK
          totalCaloriesGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].afterTDEE);

          const responseObj = {
              allTodayDates : allTodayDates,
              totalCaloriesBreakfast: 0,
              totalCaloriesLunch: 0,
              totalCaloriesDinner: 0,
              totalCaloriesSnack: 0,
              totalCaloriesOVERALL: 0,
              totalCaloriesGOALS:totalCaloriesGOALS,
              totalCaloriesExerOVERALL:0,
              totalCaloriesRemaningOVERALL:totalCaloriesGOALS,
              totalCaloriesUNIT : 'Kcal',

          };
          return res.status(200).json(responseObj);
      } else {
          // If record found for the specified date, calculate total calories for each meal type
        
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

          logForDate.exerc.forEach(exer => {
              totalCaloriesExerOVERALL += exer.totCalories;
          });

          totalCaloriesOVERALL = totalCaloriesBreakfast + totalCaloriesLunch 
                                      + totalCaloriesDinner +  totalCaloriesSnack;

                  totalCaloriesGOALS =   parseFloat(TodayfillInfohistorical.daydate[0].afterTDEE);

                  totalCaloriesRemaningOVERALL = totalCaloriesGOALS - totalCaloriesOVERALL + totalCaloriesExerOVERALL;

          // Construct the response object
          const responseObj = {
              allTodayDates : allTodayDates,
              totalCaloriesBreakfast: totalCaloriesBreakfast,
              totalCaloriesLunch: totalCaloriesLunch,
              totalCaloriesDinner: totalCaloriesDinner,
              totalCaloriesSnack: totalCaloriesSnack,
              totalCaloriesOVERALL:totalCaloriesOVERALL,
              totalCaloriesGOALS:totalCaloriesGOALS,
              totalCaloriesExerOVERALL:totalCaloriesExerOVERALL,
              totalCaloriesRemaningOVERALL:totalCaloriesRemaningOVERALL,
              totalCaloriesUNIT: 'Kcal',

          };

          // Return the response object
          return res.status(200).json(responseObj);
      }

          }
      } else {
          console.log('User does NOT exist');
          return res.status(400).json('User does NOT exist');
      }
  } catch (e) {
      console.error(e);
      res.sendStatus(500);
  }
}


// exports.WelcomeMacrosDiaryinfo = async (req, res) => {
//   try {

//       const { email, daydate } = req.body;

//       console.log('Email: ', email);
     
      
//       // Declare variables outside the loop
//       let allTodayDates;
//       let totalgivenNuteBreakfast = 0;
//       let totalgivenNuteLunch = 0;
//       let totalgivenNuteDinner = 0;
//       let totalgivenNutenack = 0;
//       let totalgivenNuteOVERALL=0;
//       //------------------------------------------
//       let TotalTotFat = 0;
//       let GoalTotFat = 0;
//       let LeftTotFat = 0;


//       let TotalProtein = 0;
//       let GoalProtein = 0;
//       let LeftProtein = 0;



//       let TotalCarbs = 0;
//       let GoalCarbs = 0;
//       let LeftCarbs = 0;




      
//       daydate.forEach(day => {
//           const todayDate = day.todaydate;
        
//           allTodayDates = todayDate;

//       });

    
//     //console.log('All Today Dates -- showfn :', allTodayDates);

//       const userFillChoices = await userChoices.findOne({ email: email });
//       const searchNutri = await userChoices.findOne({ email: email });
//       const TodayfillInfohistorical = await historicaldiary.findOne({
//         email: email,
//         'daydate.todaydate': allTodayDates
//       });

//       if (userFillChoices) {
         

//           if (!TodayfillInfohistorical) {
//               // If no existing diaryinfo email record, error 400
//               return res.status(400).json('User does not have any logged yet.');
//           }  else {

//       // Find the record for the specified todaydate
//       const logForDate = TodayfillInfohistorical.daydate.find(day => day.todaydate === allTodayDates);

//       if (!logForDate) {
//           // If no record found for the specified date, return empty arrays with 200 OK

//           //-------------------------------
//           GoalTotFat =   parseFloat(TodayfillInfohistorical.daydate[0].totFat);
               
//           if(GoalTotFat >= TotalTotFat ) {
//              LeftTotFat = GoalTotFat - TotalTotFat;
//           }
//           else {

//              LeftTotFat = 0;
//           }
//           //-------------------------------

//           //-------------------------------
//           GoalProtein =   parseFloat(TodayfillInfohistorical.daydate[0].protein);

//           if(GoalProtein >= TotalProtein ) {
//               LeftProtein = GoalProtein - TotalProtein;
//           }
//           else {
              
//               LeftProtein = 0;
//           }
//           //-------------------------------



//           GoalCarbs =   parseFloat(TodayfillInfohistorical.daydate[0].carbs);

//           if(GoalCarbs >= TotalCarbs ) {
//               LeftCarbs = GoalCarbs - TotalCarbs;
//           }
//           else {
              
//               LeftCarbs = 0;
//           }
//           //-------------------------------


     









//           const responseObj = {
//               allTodayDates : allTodayDates,
           
//            // Fill the variables with zeros inside the response object
//               TotalTotFat: 0,
//               GoalTotFat: GoalTotFat.toFixed(2),
//               LeftTotFat: LeftTotFat.toFixed(2),
//               totFatUNIT : 'g',

   
//               TotalProtein: 0,
//               GoalProtein: GoalProtein.toFixed(2),
//               LeftProtein: LeftProtein.toFixed(2),
//               proteinUNIT : 'g',

//               TotalCarbs: 0,
//               GoalCarbs: GoalCarbs.toFixed(2),
//               LeftCarbs: LeftCarbs.toFixed(2),
//               carbsUNIT : 'g',


//           };
//           return res.status(200).json(responseObj);
//       } else {
//           // If record found for the specified date, calculate total calories for each meal type
        
          
         
          
//           if(true){

//                totalgivenNuteBreakfast = 0;
//                totalgivenNuteLunch = 0;
//                totalgivenNuteDinner = 0;
//                totalgivenNutenack = 0;
              

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.totFat);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.totFat);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.totFat);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.totFat);
//               });

//               TotalTotFat = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;

                                         
//                GoalTotFat =   parseFloat(TodayfillInfohistorical.daydate[0].totFat);
               
//                if(GoalTotFat >= TotalTotFat ) {
//                   LeftTotFat = GoalTotFat - TotalTotFat;
//                }
//                else {

//                   LeftTotFat = 0;
//                }

              
//           }

       

//            if(true){

//               totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.protein);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.protein);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.protein);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.protein);
//               });

//               TotalProtein = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;


//               GoalProtein =   parseFloat(TodayfillInfohistorical.daydate[0].protein);

//               if(GoalProtein >= TotalProtein ) {
//                   LeftProtein = GoalProtein - TotalProtein;
//               }
//               else {
                  
//                   LeftProtein = 0;
//               }
                                               

              


//           }

          
//            if(true){

//                totalgivenNuteBreakfast = 0;
//               totalgivenNuteLunch = 0;
//               totalgivenNuteDinner = 0;
//               totalgivenNutenack = 0;

//               logForDate.mealsExe.breakfast.forEach(meal => {
//                   totalgivenNuteBreakfast +=  parseFloat(meal.carbs);
                  
//               });

//               logForDate.mealsExe.lunch.forEach(meal => {
//                   totalgivenNuteLunch +=  parseFloat(meal.carbs);
//               });

//               logForDate.mealsExe.dinner.forEach(meal => {
//                   totalgivenNuteDinner +=  parseFloat(meal.carbs);
//               });

//               logForDate.mealsExe.snack.forEach(meal => {
//                   totalgivenNutenack +=  parseFloat(meal.carbs);
//               });

//               TotalCarbs = totalgivenNuteBreakfast + totalgivenNuteLunch 
//                                           + totalgivenNuteDinner +  totalgivenNutenack;


//             GoalCarbs =   parseFloat(TodayfillInfohistorical.daydate[0].carbs);

//           if(GoalCarbs >= TotalCarbs ) {
//               LeftCarbs = GoalCarbs - TotalCarbs;
//           }
//           else {
              
//               LeftCarbs = 0;
//           }
                                                                          

//           }
         



//           // Construct the response object
//           const responseObj = {
//               allTodayDates : allTodayDates,
//               // Fill the variables with zeros inside the response object
//                  TotalTotFat: TotalTotFat.toFixed(2),
//                  GoalTotFat: GoalTotFat.toFixed(2),
//                  LeftTotFat: LeftTotFat.toFixed(2),
//                  totFatUNIT: 'g',

              

//                  TotalProtein: TotalProtein.toFixed(2),
//                  GoalProtein: GoalProtein.toFixed(2),
//                  LeftProtein: LeftProtein.toFixed(2),
//                   proteinUNIT: 'g',


                

//                  TotalCarbs: TotalCarbs.toFixed(2),
//                  GoalCarbs: GoalCarbs.toFixed(2),
//                  LeftCarbs: LeftCarbs.toFixed(2),
//                  carbsUNIT: 'g',

         

//           };

//           // Return the response object
//           return res.status(200).json(responseObj);
//       }

//           }
//       } else {
//           console.log('User does NOT exist');
//           return res.status(400).json('User does NOT exist');
//       }
//   } catch (e) {
//       console.error(e);
//       res.sendStatus(500);
//   }
// }



exports.WelcomeMacrosDiaryinfo = async (req, res) => {
  try {
    const { email, daydate } = req.body;
    console.log('Email: ', email);

    let allTodayDates;
    let totalgivenNuteBreakfast = 0;
    let totalgivenNuteLunch = 0;
    let totalgivenNuteDinner = 0;
    let totalgivenNutenack = 0;
    let totalgivenNuteOVERALL = 0;
    let TotalTotFat = 0;
    let GoalTotFat = 0;
    let LeftTotFat = 0;
    let TotalProtein = 0;
    let GoalProtein = 0;
    let LeftProtein = 0;
    let TotalCarbs = 0;
    let GoalCarbs = 0;
    let LeftCarbs = 0;

    daydate.forEach(day => {
      const todayDate = day.todaydate;
      allTodayDates = todayDate;
    });

    const userFillChoices = await userChoices.findOne({ email: email });
    const TodayfillInfohistorical = await historicaldiary.findOne({
      email: email,
      'daydate.todaydate': allTodayDates
    },
    { 'daydate.$': 1 } 
  );

    if (userFillChoices) {
      if (!TodayfillInfohistorical) {
        return res.status(400).json('User does not have any logs yet.');
      } else {
        const logForDate = TodayfillInfohistorical.daydate.find(day => day.todaydate === allTodayDates);

        if (!logForDate) {
          GoalTotFat = parseFloat(TodayfillInfohistorical.daydate[0].goaltotFat);
          GoalProtein = parseFloat(TodayfillInfohistorical.daydate[0].goalprotein);
          GoalCarbs = parseFloat(TodayfillInfohistorical.daydate[0].goalcarbs);

          LeftTotFat = GoalTotFat;
          LeftProtein = GoalProtein;
          LeftCarbs = GoalCarbs;

          const responseObj = {
            allTodayDates: allTodayDates,
            TotalTotFat: 0,
            GoalTotFat: GoalTotFat.toFixed(2),
            LeftTotFat: LeftTotFat.toFixed(2),
            totFatUNIT: 'g',
            TotalProtein: 0,
            GoalProtein: GoalProtein.toFixed(2),
            LeftProtein: LeftProtein.toFixed(2),
            proteinUNIT: 'g',
            TotalCarbs: 0,
            GoalCarbs: GoalCarbs.toFixed(2),
            LeftCarbs: LeftCarbs.toFixed(2),
            carbsUNIT: 'g',
          };
          return res.status(200).json(responseObj);
        } else {
          logForDate.mealsExe.breakfast.forEach(meal => {
            totalgivenNuteBreakfast += parseFloat(meal.totFat);
          });

          logForDate.mealsExe.lunch.forEach(meal => {
            totalgivenNuteLunch += parseFloat(meal.totFat);
          });

          logForDate.mealsExe.dinner.forEach(meal => {
            totalgivenNuteDinner += parseFloat(meal.totFat);
          });

          logForDate.mealsExe.snack.forEach(meal => {
            totalgivenNutenack += parseFloat(meal.totFat);
          });

          TotalTotFat = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalTotFat = parseFloat(TodayfillInfohistorical.daydate[0].goaltotFat);
          LeftTotFat = GoalTotFat >= TotalTotFat ? GoalTotFat - TotalTotFat : 0;

          totalgivenNuteBreakfast = 0;
          totalgivenNuteLunch = 0;
          totalgivenNuteDinner = 0;
          totalgivenNutenack = 0;

          logForDate.mealsExe.breakfast.forEach(meal => {
            totalgivenNuteBreakfast += parseFloat(meal.protein);
          });

          logForDate.mealsExe.lunch.forEach(meal => {
            totalgivenNuteLunch += parseFloat(meal.protein);
          });

          logForDate.mealsExe.dinner.forEach(meal => {
            totalgivenNuteDinner += parseFloat(meal.protein);
          });

          logForDate.mealsExe.snack.forEach(meal => {
            totalgivenNutenack += parseFloat(meal.protein);
          });

          TotalProtein = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalProtein = parseFloat(TodayfillInfohistorical.daydate[0].goalprotein);
          LeftProtein = GoalProtein >= TotalProtein ? GoalProtein - TotalProtein : 0;

          totalgivenNuteBreakfast = 0;
          totalgivenNuteLunch = 0;
          totalgivenNuteDinner = 0;
          totalgivenNutenack = 0;

          logForDate.mealsExe.breakfast.forEach(meal => {
            totalgivenNuteBreakfast += parseFloat(meal.carbs);
          });

          logForDate.mealsExe.lunch.forEach(meal => {
            totalgivenNuteLunch += parseFloat(meal.carbs);
          });

          logForDate.mealsExe.dinner.forEach(meal => {
            totalgivenNuteDinner += parseFloat(meal.carbs);
          });

          logForDate.mealsExe.snack.forEach(meal => {
            totalgivenNutenack += parseFloat(meal.carbs);
          });

          TotalCarbs = totalgivenNuteBreakfast + totalgivenNuteLunch + totalgivenNuteDinner + totalgivenNutenack;
          GoalCarbs = parseFloat(TodayfillInfohistorical.daydate[0].goalcarbs);
          LeftCarbs = GoalCarbs >= TotalCarbs ? GoalCarbs - TotalCarbs : 0;

          const responseObj = {
            allTodayDates: allTodayDates,
            TotalTotFat: TotalTotFat.toFixed(2),
            GoalTotFat: GoalTotFat.toFixed(2),
            LeftTotFat: LeftTotFat.toFixed(2),
            totFatUNIT: 'g',
            TotalProtein: TotalProtein.toFixed(2),
            GoalProtein: GoalProtein.toFixed(2),
            LeftProtein: LeftProtein.toFixed(2),
            proteinUNIT: 'g',
            TotalCarbs: TotalCarbs.toFixed(2),
            GoalCarbs: GoalCarbs.toFixed(2),
            LeftCarbs: LeftCarbs.toFixed(2),
            carbsUNIT: 'g',
          };

          return res.status(200).json(responseObj);
        }
      }
    } else {
      console.log('User does NOT exist');
      return res.status(400).json('User does NOT exist');
    }
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
}



exports.TraineesInfo = async (req, res) => {
  try {
      const { email , dateToday } = req.body;

      console.log('Email:', email);

      // Find user choices based on email
      const userFillChoices = await userChoices.findOne({ email: email });
      const TodayfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': dateToday
      },
      { 'daydate.$': 1 } 
    );

      if (!userFillChoices&&!TodayfillInfohistorical) {
          // If user does not exist in userChoices table, return error 400
          console.log('User does NOT exist in this table');
          return res.status(400).json('User does NOT exist in this table');
      }

      if(!TodayfillInfohistorical){

        const recentEntry = await historicaldiary.findOne(
          {
            email: email,
            'daydate.todaydate': { $lt: dateToday }
          },
          { 'daydate.$': 1 } // Project only the matched subdocument
        ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry

          // Construct the response object
            const responseObj = {
                email : userFillChoices.email,
                TDEE: recentEntry.daydate[0].afterTDEE,
                target:recentEntry.daydate[0].target,
                activity: recentEntry.daydate[0].activity,
                sex: recentEntry.daydate[0].sex,
                age: recentEntry.daydate[0].age,
                height: recentEntry.daydate[0].height,

                startweight: userFillChoices.weight,
                currentweight: recentEntry.daydate[0].currentweight, 
                goalWeight: recentEntry.daydate[0].goalWeight, 
                date: userFillChoices.date,

                carbs: recentEntry.daydate[0].goalcarbs, 
                minWork:  recentEntry.daydate[0].goalminWork, 
                workWeek:  recentEntry.daydate[0].goalworkWeek, 
                sugar: recentEntry.daydate[0].goalsugar, 
                fiber: recentEntry.daydate[0].goalfiber, 
                cholesterol: recentEntry.daydate[0].goalcholesterol, 
                potassium: recentEntry.daydate[0].goalpotassium, 
                sodium: recentEntry.daydate[0].goalsodium, 
                carbsPer: recentEntry.daydate[0].goalcarbsPer, 
                protienPer: recentEntry.daydate[0].goalprotienPer, 
                fatPer: recentEntry.daydate[0].goalfatPer, 
                totFat: recentEntry.daydate[0].goaltotFat, 
                satFat: recentEntry.daydate[0].goalsatFat, 
                protein: recentEntry.daydate[0].goalprotein, 
            };
            return res.status(200).json(responseObj);
      }
      else {
              // Construct the response object
          const responseObj = {
            email : userFillChoices.email,
            TDEE: TodayfillInfohistorical.daydate[0].afterTDEE,
            target:TodayfillInfohistorical.daydate[0].target,
            activity: TodayfillInfohistorical.daydate[0].activity,
            sex: TodayfillInfohistorical.daydate[0].sex,
            age: TodayfillInfohistorical.daydate[0].age,
            height: TodayfillInfohistorical.daydate[0].height,

            startweight: userFillChoices.weight,
            currentweight: TodayfillInfohistorical.daydate[0].currentweight, 
            goalWeight: TodayfillInfohistorical.daydate[0].goalWeight, 
            date: userFillChoices.date,

            carbs: TodayfillInfohistorical.daydate[0].goalcarbs, 
            minWork:  TodayfillInfohistorical.daydate[0].goalminWork, 
            workWeek:  TodayfillInfohistorical.daydate[0].goalworkWeek, 
            sugar: TodayfillInfohistorical.daydate[0].goalsugar, 
            fiber: TodayfillInfohistorical.daydate[0].goalfiber, 
            cholesterol: TodayfillInfohistorical.daydate[0].goalcholesterol, 
            potassium: TodayfillInfohistorical.daydate[0].goalpotassium, 
            sodium: TodayfillInfohistorical.daydate[0].goalsodium, 
            carbsPer: TodayfillInfohistorical.daydate[0].goalcarbsPer, 
            protienPer: TodayfillInfohistorical.daydate[0].goalprotienPer, 
            fatPer: TodayfillInfohistorical.daydate[0].goalfatPer, 
            totFat: TodayfillInfohistorical.daydate[0].goaltotFat, 
            satFat: TodayfillInfohistorical.daydate[0].goalsatFat, 
            protein: TodayfillInfohistorical.daydate[0].goalprotein, 

            

        };

        // Return the response object
        return res.status(200).json(responseObj);

      }
   
  } catch (e) {
      console.error(e);
      res.sendStatus(500);
  }
};


exports.TDEEInfoHistorical = async (req, res) => {
  try {
    const { email, date } = req.body;

    console.log('Email:', email);
    console.log('Date:', date);

    // Find user choices based on email
    const userFillChoices = await userChoices.findOne({ email: email });
    const TodayfillInfohistorical = await historicaldiary.findOne({
      email: email,
      'daydate.todaydate': date
    },
    { 'daydate.$': 1 } 
  );

    if (!userFillChoices) {
      // If user does not exist in userChoices table, return error 400
      console.log('User does NOT exist in this table');
      return res.status(400).json('User does NOT exist in this table');
    } else {
      if (!TodayfillInfohistorical) {

        // If the date is not found, get the most recent entry
        // const RecentfillInfohistorical = await historicaldiary.findOne(
        //   { email: email },
        //   { daydate: { $slice: -1 } } // This returns the last entry in the daydate array
        // );

        
        const RecentfillInfohistorical = await historicaldiary.findOne(
          {
            email: email,
            'daydate.todaydate': { $lt: date }
          },
          { 'daydate.$': 1 } // Project only the matched subdocument
        ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry


        if (!RecentfillInfohistorical) {
          console.log('No historical data found for this user');
          return res.status(400).json('No historical data found for this user');
        } else {
          const recentDaydate = RecentfillInfohistorical.daydate[0];
          console.log('Returning the most recent historical data:', recentDaydate.afterTDEE);

          const responseObj = {
            afterTDEE: recentDaydate.afterTDEE,
          };

          return res.status(200).json(responseObj);
        }
      } else {
        // If the specified date is found, return its data
        console.log(TodayfillInfohistorical.daydate[0].afterTDEE);
        const responseObj = {
          afterTDEE: TodayfillInfohistorical.daydate[0].afterTDEE,
        };

        return res.status(200).json(responseObj);
      }
    }
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
};


exports.LASTDAYBACKHistorical = async (req, res) => {
  try {
    const { email } = req.body;

    console.log('Email:', email);

    // Find user choices based on email
    const userFillChoices = await userChoices.findOne({ email: email });
  

    if (!userFillChoices) {
      // If user does not exist in userChoices table, return error 400
      console.log('User does NOT exist in this table');
      return res.status(400).json('User does NOT exist in this table');
    } else {

      // If the specified date is found, return its data
      console.log(userFillChoices.date);
      const responseObj = {
        maxBackDate: userFillChoices.date,
      };

      return res.status(200).json(responseObj);

    }
  } catch (e) {
    console.error(e);
    res.sendStatus(500);
  }
};




exports.FetchforPreset = async (req, res) => {
  const { email } = req.query;
  console.log(`email for preset msg = ${email}`);

  try {
    const diary = await historicaldiary.findOne({ email });
    
    if (!diary) {
      return res.status(404).send('Diary not found');
    }

    const today = new Date().toISOString().split('T')[0];
    const todayInfo = diary.daydate.find(day => day.todaydate === today);

    if (!todayInfo) {
      return res.status(404).send('No entries for today');
    }

    const userData = {
      goalWeight: todayInfo.goalWeight,
      goalweeklyPer: todayInfo.goalweeklyPer,
      currentWeight: todayInfo.currentweight,
      goalProtein: todayInfo.goalprotein,
      afterTDEE: todayInfo.afterTDEE,
    };

    res.json(userData);
  } catch (error) {
    res.status(500).send('Internal Server Error');
  }
};

// let fillInfohistorical = await historicaldiary.findOne(
//   {
//   email: traineeEmail,
//   'daydate.todaydate': allTodayDates
//   },
//   { 'daydate.$': 1 } 
// );