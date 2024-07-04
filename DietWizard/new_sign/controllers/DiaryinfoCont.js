const express = require('express');

const router = express.Router();
const path = require('path');

const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices = require('../models/userChoices');
const waterintake = require('../models/Waterintake');
const progressphoto = require('../models/progressphotos');
const customfoodexe = require('../models/CustomFoodExe');
const diaryinfo = require('../models/Diaryinfo');

const fs = require('fs');
const multer = require('multer');


exports.saveDiaryinfo = async (req, res) => {
    try {
        const { email, daydate } = req.body;

        // console.log('Email:', email);
        
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
        // console.log('All Breakfasts:', allBreakfasts);
        // console.log('All Lunches:', allLunches);
        // console.log('All Dinners:', allDinners);
        // console.log('All Snacks:', allSnacks);
        // console.log('All Exercises:', allExercises);
        // console.log('All Note Contents:', allNoteContents);
        

        const userFillChoices = await userChoices.findOne({ email: email });

        if (userFillChoices) {
            const fillInfo = await diaryinfo.findOne({ email: email });

            if (!fillInfo) {
                // If no existing diaryinfo record for the email, create a new one
                const diaryinfoSchema = new diaryinfo({
                    iduser: userFillChoices.iduser,
                    email: email,
                    daydate: [{
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
                await diaryinfoSchema.save();
                return res.status(200).json('Done adding full record');
            } else {
                // If existing diaryinfo for email record 
                const existingEntryIndex = fillInfo.daydate.findIndex(entry => entry.todaydate === allTodayDates);
                if (existingEntryIndex === -1) {
                    // If no record for todayDate, add a new entry
                    fillInfo.daydate.push({
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
                    await fillInfo.save();
                    return res.status(200).json('Done adding');
                } else {
                    // If record exists for todayDate, update the existing entry
                    fillInfo.daydate[existingEntryIndex] = {
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
                    await fillInfo.save();
                    return res.status(200).json('Done updating');
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



    exports.showDiaryinfo = async (req, res) => {
        try {
    
            const { email, daydate } = req.body;

            // console.log('Email:', email);
            
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
    
          
          console.log('All Today Dates -- showfn :', allTodayDates);

            const userFillChoices = await userChoices.findOne({ email: email });
    
            if (userFillChoices) {
                const fillInfo = await diaryinfo.findOne({ email: email });
    
                if (!fillInfo) {
                    // If no existing diaryinfo email record, error 400
                    return res.status(400).json('User does not have any logged yet.');
                }  else {
                    //if exist  diaryinfo email record then return the logged records
                    const logArray = fillInfo.daydate;
                    let logsExist = false;
    
                    for (const loga of logArray) {
                        if (loga.todaydate === allTodayDates) {
                            logsExist = true;
                            // Pushing all the required data into respective arrays
                            //before push you should parse totCalories to int and push to arrays!
                            
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
                            // Printing the response correctly using a loop
                    // console.log('Response:');
                    // Object.keys(responseObj).forEach(key => {
                    //     console.log(`${key}:`, responseObj[key]);
                    // });
                        res.json(responseObj);
                    } else {
                // If logs do not exist for today's date, return empty arrays with 200 OK
            const responseObj = {
                allBreakfasts: [],
                allLunches: [],
                allDinners: [],
                allSnacks: [],
                allExercises: [],
                allNoteContents: ""
            };
            res.status(200).json(responseObj);
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
    }
    

    

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

            if (userFillChoices) {
                const fillInfo = await diaryinfo.findOne({ email: email });
    
                if (!fillInfo) {
                    // If no existing diaryinfo email record, error 400
                    return res.status(400).json('User does not have any logged yet.');
                }  else {

            // Find the record for the specified todaydate
            const logForDate = fillInfo.daydate.find(day => day.todaydate === allTodayDates);

            if (!logForDate) {
                // If no record found for the specified date, return empty arrays with 200 OK
                totalCaloriesGOALS =   parseFloat(searchNutri.TDEE);

                const responseObj = {
                    allTodayDates : allTodayDates,
                    totalCaloriesBreakfast: 0,
                    totalCaloriesLunch: 0,
                    totalCaloriesDinner: 0,
                    totalCaloriesSnack: 0,
                    totalCaloriesOVERALL: 0,
                    totalCaloriesGOALS:totalCaloriesGOALS,
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

                totalCaloriesOVERALL = totalCaloriesBreakfast + totalCaloriesLunch 
                                            + totalCaloriesDinner +  totalCaloriesSnack;

                        totalCaloriesGOALS =   parseFloat(searchNutri.TDEE);

                // Construct the response object
                const responseObj = {
                    allTodayDates : allTodayDates,
                    totalCaloriesBreakfast: totalCaloriesBreakfast,
                    totalCaloriesLunch: totalCaloriesLunch,
                    totalCaloriesDinner: totalCaloriesDinner,
                    totalCaloriesSnack: totalCaloriesSnack,
                    totalCaloriesOVERALL:totalCaloriesOVERALL,
                    totalCaloriesGOALS:totalCaloriesGOALS,
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

    
    exports.CalTotGivenNutDiaryinfo = async (req, res) => {
        try {
    
            const { email, daydate , givenNute} = req.body;

            console.log('Email: ', email);
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
       
            let GoalTotFat = 0;
            let GoalSatFat = 0;
   
            let GoalProtein = 0;

            let GoalSodium = 0;
  
            let GoalPotassium = 0;

            let GoalCholesterol = 0;
 
            let GoalCarbs = 0;
     
            let GoalFiber = 0;
              let GoalSugar = 0;
      

            
            daydate.forEach(day => {
                const todayDate = day.todaydate;
              
                allTodayDates = todayDate;
      
            });
    
          
          //console.log('All Today Dates -- showfn :', allTodayDates);

            const userFillChoices = await userChoices.findOne({ email: email });
            const searchNutri = await userChoices.findOne({ email: email });

    
            if (userFillChoices) {
                const fillInfo = await diaryinfo.findOne({ email: email });
    
                if (!fillInfo) {
                    // If no existing diaryinfo email record, error 400
                    return res.status(400).json('User does not have any logged yet.');
                }  else {

            // Find the record for the specified todaydate
            const logForDate = fillInfo.daydate.find(day => day.todaydate === allTodayDates);

            if (!logForDate) {
                // If no record found for the specified date, return empty arrays with 200 OK

                if(givenNute === 'totFat'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.totFat);
                }
                else if(givenNute === 'satFat'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.satFat);
                }
                else if(givenNute === 'protein'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.protein);
                }
                else if(givenNute === 'sodium'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.sodium);
                }
                else if(givenNute === 'potassium'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.potassium);
                }
                else if(givenNute === 'cholesterol'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.cholesterol);
                }
                else if(givenNute === 'carbs'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.carbs);
                }
                else if(givenNute === 'fiber'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.fiber);
                }
                else if(givenNute === 'sugar'){ 
                    totalgivenNuteGOALS =   parseFloat(searchNutri.sugar);
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
            } else {
                // If record found for the specified date, calculate total calories for each meal type
              
                
               
                
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

                    totalgivenNuteGOALS =   parseFloat(searchNutri.totFat);

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

                        totalgivenNuteGOALS =   parseFloat(searchNutri.satFat);


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

                         totalgivenNuteGOALS =   parseFloat(searchNutri.protein);

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

                        totalgivenNuteGOALS =   parseFloat(searchNutri.sodium);

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

                                                totalgivenNuteGOALS =   parseFloat(searchNutri.potassium);                        

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

                                                totalgivenNuteGOALS =   parseFloat(searchNutri.cholesterol);    

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
                                                totalgivenNuteGOALS =   parseFloat(searchNutri.carbs);    

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
                                                totalgivenNuteGOALS =   parseFloat(searchNutri.fiber);   

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
                                                totalgivenNuteGOALS =   parseFloat(searchNutri.sugar);   

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
                console.log('User does NOT exist');
                return res.status(400).json('User does NOT exist');
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


    

    exports.CalTotGoalLeftNutDiaryinfo = async (req, res) => {
        try {
    
            const { email, daydate } = req.body;

            console.log('Email: ', email);
           
            
            // Declare variables outside the loop
            let allTodayDates;
            let totalgivenNuteBreakfast = 0;
            let totalgivenNuteLunch = 0;
            let totalgivenNuteDinner = 0;
            let totalgivenNutenack = 0;
            let totalgivenNuteOVERALL=0;
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


            
            daydate.forEach(day => {
                const todayDate = day.todaydate;
              
                allTodayDates = todayDate;
      
            });
    
          
          //console.log('All Today Dates -- showfn :', allTodayDates);

            const userFillChoices = await userChoices.findOne({ email: email });
            const searchNutri = await userChoices.findOne({ email: email });

    
            if (userFillChoices) {
                const fillInfo = await diaryinfo.findOne({ email: email });
    
                if (!fillInfo) {
                    // If no existing diaryinfo email record, error 400
                    return res.status(400).json('User does not have any logged yet.');
                }  else {

            // Find the record for the specified todaydate
            const logForDate = fillInfo.daydate.find(day => day.todaydate === allTodayDates);

            if (!logForDate) {
                // If no record found for the specified date, return empty arrays with 200 OK

                //-------------------------------
                GoalTotFat =   parseFloat(searchNutri.totFat);
                     
                if(GoalTotFat >= TotalTotFat ) {
                   LeftTotFat = GoalTotFat - TotalTotFat;
                }
                else {

                   LeftTotFat = 0;
                }
                //-------------------------------
                GoalSatFat =   parseFloat(searchNutri.satFat);

                if(GoalSatFat >= TotalSatFat ) {
                    LeftSatFat = GoalSatFat - TotalSatFat;
                }
                else {
                    
                    LeftSatFat = 0;
                }
                //-------------------------------
                GoalProtein =   parseFloat(searchNutri.protein);

                if(GoalProtein >= TotalProtein ) {
                    LeftProtein = GoalProtein - TotalProtein;
                }
                else {
                    
                    LeftProtein = 0;
                }
                //-------------------------------
                GoalSodium =   parseFloat(searchNutri.sodium);

                if(GoalSodium >= TotalSodium ) {
                    LeftSodium = GoalSodium - TotalSodium;
                }
                else {
                    
                    LeftSodium = 0;
                }
                //-------------------------------
                GoalPotassium =   parseFloat(searchNutri.potassium);

                if(GoalPotassium >= TotalPotassium ) {
                    LeftPotassium = GoalPotassium - TotalPotassium;
                }
                else {
                    
                    LeftPotassium = 0;
                }
                     
                //-------------------------------
                GoalCholesterol =   parseFloat(searchNutri.cholesterol);

                if(GoalCholesterol >= TotalCholesterol ) {
                    LeftCholesterol = GoalCholesterol - TotalCholesterol;
                }
                else {
                    
                    LeftCholesterol = 0;
                }
                  
                //-------------------------------

                GoalCarbs =   parseFloat(searchNutri.carbs);

                if(GoalCarbs >= TotalCarbs ) {
                    LeftCarbs = GoalCarbs - TotalCarbs;
                }
                else {
                    
                    LeftCarbs = 0;
                }
                //-------------------------------
                GoalFiber =   parseFloat(searchNutri.fiber);

                if(GoalFiber >= TotalFiber ) {
                  LeftFiber = GoalFiber - TotalFiber;
                }
                else {
                    
                  LeftFiber = 0;
                }
                //-------------------------------
                GoalSugar =   parseFloat(searchNutri.sugar);

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
            } else {
                // If record found for the specified date, calculate total calories for each meal type
              
                
               
                
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

                                               
                     GoalTotFat =   parseFloat(searchNutri.totFat);
                     
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


                    GoalSatFat =   parseFloat(searchNutri.satFat);

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


                    GoalProtein =   parseFloat(searchNutri.protein);

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


                    GoalSodium =   parseFloat(searchNutri.sodium);

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

                                                                                                
                         GoalPotassium =   parseFloat(searchNutri.potassium);

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


                    GoalCholesterol =   parseFloat(searchNutri.cholesterol);

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


                  GoalCarbs =   parseFloat(searchNutri.carbs);

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

                       
                    GoalFiber =   parseFloat(searchNutri.fiber);

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

                                              
                       GoalSugar =   parseFloat(searchNutri.sugar);

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
                console.log('User does NOT exist');
                return res.status(400).json('User does NOT exist');
            }
        } catch (e) {
            console.error(e);
            res.sendStatus(500);
        }
    }

    
     

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

            if (userFillChoices) {
                const fillInfo = await diaryinfo.findOne({ email: email });
    
                if (!fillInfo) {
                    // If no existing diaryinfo email record, error 400
                    return res.status(400).json('User does not have any logged yet.');
                }  else {

            // Find the record for the specified todaydate
            const logForDate = fillInfo.daydate.find(day => day.todaydate === allTodayDates);

            if (!logForDate) {
                // If no record found for the specified date, return empty arrays with 200 OK
                totalCaloriesGOALS =   parseFloat(searchNutri.TDEE);

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

                        totalCaloriesGOALS =   parseFloat(searchNutri.TDEE);

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

    


    exports.WelcomeMacrosDiaryinfo = async (req, res) => {
        try {
    
            const { email, daydate } = req.body;

            console.log('Email: ', email);
           
            
            // Declare variables outside the loop
            let allTodayDates;
            let totalgivenNuteBreakfast = 0;
            let totalgivenNuteLunch = 0;
            let totalgivenNuteDinner = 0;
            let totalgivenNutenack = 0;
            let totalgivenNuteOVERALL=0;
            //------------------------------------------
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
    
          
          //console.log('All Today Dates -- showfn :', allTodayDates);

            const userFillChoices = await userChoices.findOne({ email: email });
            const searchNutri = await userChoices.findOne({ email: email });

    
            if (userFillChoices) {
                const fillInfo = await diaryinfo.findOne({ email: email });
    
                if (!fillInfo) {
                    // If no existing diaryinfo email record, error 400
                    return res.status(400).json('User does not have any logged yet.');
                }  else {

            // Find the record for the specified todaydate
            const logForDate = fillInfo.daydate.find(day => day.todaydate === allTodayDates);

            if (!logForDate) {
                // If no record found for the specified date, return empty arrays with 200 OK

                //-------------------------------
                GoalTotFat =   parseFloat(searchNutri.totFat);
                     
                if(GoalTotFat >= TotalTotFat ) {
                   LeftTotFat = GoalTotFat - TotalTotFat;
                }
                else {

                   LeftTotFat = 0;
                }
                //-------------------------------
   
                //-------------------------------
                GoalProtein =   parseFloat(searchNutri.protein);

                if(GoalProtein >= TotalProtein ) {
                    LeftProtein = GoalProtein - TotalProtein;
                }
                else {
                    
                    LeftProtein = 0;
                }
                //-------------------------------
    
     

                GoalCarbs =   parseFloat(searchNutri.carbs);

                if(GoalCarbs >= TotalCarbs ) {
                    LeftCarbs = GoalCarbs - TotalCarbs;
                }
                else {
                    
                    LeftCarbs = 0;
                }
                //-------------------------------
   

           









                const responseObj = {
                    allTodayDates : allTodayDates,
                 
                 // Fill the variables with zeros inside the response object
                    TotalTotFat: 0,
                    GoalTotFat: GoalTotFat.toFixed(2),
                    LeftTotFat: LeftTotFat.toFixed(2),
                    totFatUNIT : 'g',

         
                    TotalProtein: 0,
                    GoalProtein: GoalProtein.toFixed(2),
                    LeftProtein: LeftProtein.toFixed(2),
                    proteinUNIT : 'g',

                    TotalCarbs: 0,
                    GoalCarbs: GoalCarbs.toFixed(2),
                    LeftCarbs: LeftCarbs.toFixed(2),
                    carbsUNIT : 'g',


                };
                return res.status(200).json(responseObj);
            } else {
                // If record found for the specified date, calculate total calories for each meal type
              
                
               
                
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

                                               
                     GoalTotFat =   parseFloat(searchNutri.totFat);
                     
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


                    GoalProtein =   parseFloat(searchNutri.protein);

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


                  GoalCarbs =   parseFloat(searchNutri.carbs);

                if(GoalCarbs >= TotalCarbs ) {
                    LeftCarbs = GoalCarbs - TotalCarbs;
                }
                else {
                    
                    LeftCarbs = 0;
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

                    

                       TotalProtein: TotalProtein.toFixed(2),
                       GoalProtein: GoalProtein.toFixed(2),
                       LeftProtein: LeftProtein.toFixed(2),
                        proteinUNIT: 'g',


                      

                       TotalCarbs: TotalCarbs.toFixed(2),
                       GoalCarbs: GoalCarbs.toFixed(2),
                       LeftCarbs: LeftCarbs.toFixed(2),
                       carbsUNIT: 'g',

               

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


    exports.TraineesInfo = async (req, res) => {
        try {
            const { email } = req.body;
    
            console.log('Email:', email);
    
            // Find user choices based on email
            const userFillChoices = await userChoices.findOne({ email: email });
    
            if (!userFillChoices) {
                // If user does not exist in userChoices table, return error 400
                console.log('User does NOT exist');
                return res.status(400).json('User does NOT exist');
            }
    
            // Construct the response object
            const responseObj = {
                email : userFillChoices.email,
                TDEE: userFillChoices.TDEE,
                target: userFillChoices.target,
                activity: userFillChoices.activity,
                sex: userFillChoices.sex,
                age: userFillChoices.age,
                height: userFillChoices.height,
                weight: userFillChoices.weight,
                goalWeight: userFillChoices.goalWeight,
                date: userFillChoices.date,
                carbs: userFillChoices.carbs,
                minWork: userFillChoices.minWork,
                workWeek: userFillChoices.workWeek,
                sugar: userFillChoices.sugar,
                fiber: userFillChoices.fiber,
                cholesterol: userFillChoices.cholesterol,
                potassium: userFillChoices.potassium,
                sodium: userFillChoices.sodium,
                carbsPer: userFillChoices.carbsPer,
                protienPer: userFillChoices.protienPer,
                fatPer: userFillChoices.fatPer,
                totFat: userFillChoices.totFat,
                satFat: userFillChoices.satFat,
                protein: userFillChoices.protein
            };
    
            // Return the response object
            return res.status(200).json(responseObj);
        } catch (e) {
            console.error(e);
            res.sendStatus(500);
        }
    };