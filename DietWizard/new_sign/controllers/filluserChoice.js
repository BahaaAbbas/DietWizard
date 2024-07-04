const express = require('express');
 
const router = express.Router();
const path = require('path');
 
const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices =  require('../models/userChoices');
const historicaldiary =  require('../models/historicalDiary');
const dailytrackprogress = require('../models/DailyTrackProgress');

exports.postfilluserchoices=async(req,res)=>{

    try {

        const{email,beforeTDEE,afterTDEE,target,activity,sex,age,height,weight,goalWeight,date,carbsPer,protienPer,fatPer,workWeek,minWork,
            totFat,satFat,protein,sodium,potassium,cholesterol,carbs,fiber,sugar,burn
        }=req.body;
        let {weeklyPer} = req.body;
        console.log(email,beforeTDEE,afterTDEE,target,activity,sex,age,height,weight,goalWeight,date,weeklyPer,burn);
   
        
           // weeklyPer
if (weeklyPer === '0.5kg Lose per week') {
    weeklyPer = '-0.5';
} else if (weeklyPer === '1kg Lose per week') {
    weeklyPer = '-1';
} else if (weeklyPer === '0.5kg Gain per week') {
    weeklyPer = '+0.5';
} else if (weeklyPer === '1kg Gain per week') {
    weeklyPer = '+1';
} else if (weeklyPer === 'Maintain Weight') {
    weeklyPer = '0';
}

console.log(weeklyPer);

        const user = await userModel.findOne({ $or: [{ email: email }] });
        console.log(`userInfo = ${user}`);

        if(user){ // find email , then find user

            const fillInfo = await userChoices.findOne({ $or: [{ email: email }] });
            const fillInfohistorical = await historicaldiary.findOne({ $or: [{ email: email }] });
            const dailytrackprogressToday = await dailytrackprogress.findOne({ $or: [{ email: email }] });
    
            if(!fillInfo && !fillInfohistorical && !dailytrackprogressToday ){ // not exist email in fillchoices collection..
                    let userChoicesSchema=new userChoices({
                        iduser:user.iduser,
                        email:email,
                        beforeTDEE:beforeTDEE,
                        afterTDEE:afterTDEE,
                        target: target,
                        activity: activity,
                        sex: sex,
                        age: age,
                        height: height,
                        weight: weight,
                        goalWeight: goalWeight,
                        date: date,
                        weeklyPer:weeklyPer,
                        carbsPer:carbsPer,
                        protienPer:protienPer,
                        fatPer:fatPer,
                        workWeek:workWeek,
                        minWork:minWork,
                        totFat:totFat,
                        satFat:satFat,
                        protein:protein,
                        sodium:sodium,
                        potassium:potassium,
                        cholesterol:cholesterol,
                        carbs:carbs,
                        fiber:fiber,
                        sugar:sugar,

                    });
                await userChoicesSchema.save();

                            // Save to historicaldiary model
                            let historicalDiarySchema = new historicaldiary({
                                iduser: user.iduser,
                                email: email,
                                daydate: [{
                                    todaydate: date,
                                    mealsExe: {
                                        breakfast: [],
                                        lunch: [],
                                        dinner: [],
                                        snack: []
                                    },
                                    exerc: [],
                                    noteCont: "",
                                    beforeTDEE:beforeTDEE,
                                    afterTDEE:afterTDEE,
                                    target: target,
                                    activity: activity,
                                    sex: sex,
                                    age: age,
                                    height: height,
                                    startweight: weight,
                                    currentweight: weight,
                                    goalWeight: goalWeight,
                                    goalweeklyPer: weeklyPer,
                                    goalcarbsPer: carbsPer,
                                    goalprotienPer: protienPer,
                                    goalfatPer: fatPer,
                                    goalworkWeek: workWeek,
                                    goalminWork: minWork,
                                    goaltotFat: totFat,
                                    goalsatFat: satFat,
                                    goalprotein: protein,
                                    goalsodium: sodium,
                                    goalpotassium: potassium,
                                    goalcholesterol: cholesterol,
                                    goalcarbs: carbs,
                                    goalfiber: fiber,
                                    goalsugar: sugar,
                                }]
                            });
                            await historicalDiarySchema.save();


                              // Save to dailytrackprogress model
                              
                    let befTDEECalc = parseFloat(beforeTDEE);
                    let aftTDEECalc = parseFloat(afterTDEE);

                        let remainingToCalc = aftTDEECalc - befTDEECalc;
                        let burnedCal =  (befTDEECalc - (aftTDEECalc - remainingToCalc)).toFixed(2);

                        let burnedCalString
                        let RemainingCalString;

                        if(remainingToCalc > 0) {
                          RemainingCalString = `+${remainingToCalc}`;
                       }
                       else if(remainingToCalc < 0) {
                          RemainingCalString = `${remainingToCalc}`;
                       }
                       else if(remainingToCalc == 0) {
                          RemainingCalString = `${remainingToCalc}`;
                       }

                        if(burnedCal > 0) {
                          burnedCalString = `+${burnedCal}`;
                       }
                       else if(burnedCal < 0) {
                          burnedCalString = `${burnedCal}`;
                       }
                       else if(burnedCal == 0) {
                          burnedCalString = `${burnedCal}`;
                       }


                      
          
                              let dailytrackprogressTodayshema = new dailytrackprogress({
                                userid: user.iduser,
                                email: email,
                                daydate: [{
                                    todaydate: date,

                                    beforeTDEE:beforeTDEE,
                                    afterTDEE:afterTDEE,
                                    remaining: RemainingCalString,
                                    burned: burnedCalString,
                                    currentweight: weight,
                                    goalWeight: goalWeight,
                                    goalweeklyPer: weeklyPer,

                                }]
                            });
                            await dailytrackprogressTodayshema.save();
            
                            res.sendStatus(200);




           
            }

            else {

            console.log('user info exist');
            return res.status(400).json(  'user info exist' )
            }
            
        }
        else {

            console.log('user NOT exist');
            return res.status(400).json(  'user NOT exist' );
        }


    }catch(e){
        console.error(e);
        res.sendStatus(500); 
    }
    

   

}


exports.getUserGoal=async(req,res)=>{

    try {

        const{email}=req.body;
        console.log(email);

        const targetDate = new Date().toISOString().slice(0, 10);

        console.log(targetDate);
        
        const user = await userModel.findOne({ $or: [{ email: email }] });
       // console.log(`userInfo = ${user}`);

        if(user){ // find email , then find user

            const fillInfo = await userChoices.findOne({ $or: [{ email: email }] });
            const fillInfohistorical = await historicaldiary.findOne({ email: email });
        //    const fillInfohistorical = await historicaldiary.findOne({
        //     email: email,
        //     'daydate.todaydate': targetDate
        //   });

            if(!fillInfo && !fillInfohistorical){ // not exist email in fillchoices collection..
    
                console.log('user info NOT exist');
                return res.status(400).json(  'user info NOT exist' );
               
            }

            else {

                console.log('User goal info found + there is infohistorical');

                const todayEntry = fillInfohistorical.daydate.find(entry => entry.todaydate === targetDate);

                if (!todayEntry) {
                    console.log(`No entry found for the date: ${targetDate}`);
                    return res.status(400).json(`No entry found for the date: ${targetDate}`);
                }


                console.log(`We are in getUserGoal.. DATE = ${todayEntry.todaydate}`);
                const userData = {
                    iduser: user.iduser,
                    email: user.email,
                    TDEE: todayEntry.afterTDEE, 
                    target: todayEntry.target, 
                    activity: todayEntry.activity, 
                    sex: fillInfo.sex,
                    age: fillInfo.age,
                    height: fillInfo.height,
                    startweight: fillInfo.weight,
                    currentweight: todayEntry.currentweight, 
                    goalWeight: todayEntry.goalWeight, 
                    date: fillInfo.date,
                    weeklyPer: todayEntry.goalweeklyPer, 
                    carbs: todayEntry.goalcarbsPer, 
                    protien:todayEntry.goalprotienPer, 
                    fat: todayEntry.goalfatPer, 
                    workWeek: todayEntry.goalworkWeek, 
                    minWork: todayEntry.goalminWork, 
                };
            console.log(`userInfo = ${userData}`);
                res.status(200).json(userData);

            }
            
        }
        else {

            console.log('user NOT exist');
            return res.status(400).json(  'user NOT exist' );
        }


    }catch(e){
        console.error(e);
        res.sendStatus(500); 
    }
    

   

}

exports.startcurrentgoal=async(req,res)=>{

    try {

        const{email}=req.body;
        console.log(email);
       
        
        const user = await userModel.findOne({ $or: [{ email: email }] });
       // console.log(`userInfo = ${user}`);

       const targetDate = new Date().toISOString().slice(0, 10);

       console.log(targetDate);

        const fillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': targetDate
        },
        { 'daydate.$': 1 } 
    );

        if(user){ // find email , then find user

            const fillInfo = await userChoices.findOne({ $or: [{ email: email }] });

            if(!fillInfo && !fillInfohistorical){ // not exist email in fillchoices collection..
    
                console.log('user info NOT exist');
                return res.status(400).json(  'user info NOT exist' );
               
            }

            else {

                console.log('User weights info found');

                const userData = {
                    weight: fillInfo.weight,
                    current: fillInfohistorical.daydate[0].currentweight, 
                    goalWeight: fillInfohistorical.daydate[0].goalWeight, 

                };
            console.log(`userInfo = ${userData}`);
                res.status(200).json(userData);

            }
            
        }
        else {

            console.log('user NOT exist');
            return res.status(400).json(  'user NOT exist' );
        }


    }catch(e){
        console.error(e);
        res.sendStatus(500); 
    }
    

   

}


exports.changestartweight = async (req, res) => {
    try {
      const { email, startweight } = req.body;
      console.log(email, startweight);
  
      const user = await userModel.findOne({ email: email });

      const targetDate = new Date().toISOString().slice(0, 10);

      console.log(targetDate);

       const fillInfohistorical = await historicaldiary.findOne({
       email: email,
       'daydate.todaydate': targetDate
       },
       { 'daydate.$': 1 } 
    );


      if (user) {
        // Find the user in userChoices collection
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !fillInfohistorical) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else {

          console.log('User info found, updating the startweight only');
  
          await historicaldiary.findOneAndUpdate(

            { email: email, 'daydate.todaydate': targetDate },
            { $set: { 'daydate.$.startweight': startweight } }, 
            { new: true }
          );

          await userChoices.findOneAndUpdate(

            { email: email},
            { $set: { 'weight': startweight } }, 
            { new: true }
          );
  
          return res.status(200).json('startweight updated successfully');
        }
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };

  exports.changegoalweight = async (req, res) => {
    try {
      const { email, goalweight } = req.body;
      console.log(email, goalweight);
  
      const user = await userModel.findOne({ email: email });

      const targetDate = new Date().toISOString().slice(0, 10);

      console.log(targetDate);

       const fillInfohistorical = await historicaldiary.findOne({
       email: email,
       'daydate.todaydate': targetDate
       },
       { 'daydate.$': 1 } 
    );


      if (user) {
        // Find the user in userChoices collection
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !fillInfohistorical) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else {

          console.log('User info found, updating the goalweight only');
  
          await historicaldiary.findOneAndUpdate(

            { email: email, 'daydate.todaydate': targetDate },
            { $set: { 'daydate.$.goalWeight': goalweight } }, 
            { new: true }
          );

          await userChoices.findOneAndUpdate(

            { email: email},
            { $set: { 'goalWeight': goalweight } }, 
            { new: true }
          );
  
          return res.status(200).json('goalweight updated successfully');
        }
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };




  exports.changecurrentweight = async (req, res) => {
    try {
      const { email, currentweight } = req.body;
      console.log(email, currentweight);
  
      const user = await userModel.findOne({ email: email });

      const targetDate = new Date().toISOString().slice(0, 10);

      console.log(targetDate);

       const fillInfohistorical = await historicaldiary.findOne({
       email: email,
       'daydate.todaydate': targetDate
       },
       { 'daydate.$': 1 } 
    );


      if (user) {
        // Find the user in userChoices collection
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !fillInfohistorical) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else {

          console.log('User info found, updating the currentweight only');
  
          await historicaldiary.findOneAndUpdate(

            { email: email, 'daydate.todaydate': targetDate },
            { $set: { 'daydate.$.currentweight': currentweight } }, 
            { new: true }
          );

 
  
          return res.status(200).json('currentweight updated successfully');
        }
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };


  


  exports.changeweeklytarget = async (req, res) => {
    try {
      const { email, weeklytarget } = req.body;
      console.log(email, weeklytarget);
  
      const user = await userModel.findOne({ email: email });

      const targetDate = new Date().toISOString().slice(0, 10);

      console.log(targetDate);

       const fillInfohistorical = await historicaldiary.findOne({
       email: email,
       'daydate.todaydate': targetDate
       },
       { 'daydate.$': 1 } 
    );


      if (user) {
        // Find the user in userChoices collection
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !fillInfohistorical) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else {

          console.log('User info found, updating the weeklytarget only');

          const { beforeTDEE  } = fillInfohistorical.daydate[0];

          let TDEEbeforeTO = beforeTDEE;
          let newTDEEafter = 0.0;

          if (weeklytarget === '-0.5') {
            newTDEEafter =  TDEEbeforeTO  - 550;
            //const goaweeklyPER = goalweeklyPer;

        } else if (weeklytarget === '-1') {
            newTDEEafter =  TDEEbeforeTO  - 1100;
        } else if (weeklytarget === '+0.5') {
            newTDEEafter =  TDEEbeforeTO  + 550;
        } else if (weeklytarget === '+1') {
            newTDEEafter =  TDEEbeforeTO + 1100;
        } else if (weeklytarget === '0') {
            newTDEEafter =  TDEEbeforeTO;

        }




  
          await historicaldiary.findOneAndUpdate(

            { email: email, 'daydate.todaydate': targetDate },
            { $set: { 
                'daydate.$.afterTDEE': newTDEEafter.toFixed(2),
                'daydate.$.goalweeklyPer': weeklytarget,

             } }, 
            { new: true }
          );

 
  
          return res.status(200).json('weeklytarget updated successfully');
        }
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };

  


exports.changeworkWeek = async (req, res) => {
    try {
      const { email, workWeek } = req.body;
      console.log(email, workWeek);
  
      const user = await userModel.findOne({ email: email });

      const targetDate = new Date().toISOString().slice(0, 10);

      console.log(targetDate);

       const fillInfohistorical = await historicaldiary.findOne({
       email: email,
       'daydate.todaydate': targetDate
       },
       { 'daydate.$': 1 } 
    );


      if (user) {
        // Find the user in userChoices collection
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !fillInfohistorical) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else {
          console.log('User info found, updating the workWeek only');
  
          // Update the workWeek field only
          await historicaldiary.findOneAndUpdate(
            // { email: email },
            // { workWeek: workWeek },
            // { new: true }
            { email: email, 'daydate.todaydate': targetDate },
            { $set: { 'daydate.$.goalworkWeek': workWeek } }, // Update the workWeek field
            { new: true }
          );
  
          return res.status(200).json('workWeek updated successfully');
        }
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };

  
  exports.changeminWork = async (req, res) => {
    try {
      const { email, minWork } = req.body;
      console.log(email, minWork);

      const user = await userModel.findOne({ email: email });

      const targetDate = new Date().toISOString().slice(0, 10);

      console.log(targetDate);

       const fillInfohistorical = await historicaldiary.findOne({
       email: email,
       'daydate.todaydate': targetDate
       },
       { 'daydate.$': 1 } 
    );

      if (user) {
        // Find the user in userChoices collection
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !fillInfohistorical ) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else {
          console.log('User info found, updating the minWork only');
  
               //// Update the minwork field
          await historicaldiary.findOneAndUpdate(

            { email: email, 'daydate.todaydate': targetDate },
            { $set: { 'daydate.$.goalminWork': minWork } }, // Update the minWork field
            { new: true }
          );
          return res.status(200).json('minWork updated successfully');
        }
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };

  

  exports.changefatprotiencarbsPer = async (req, res) => {
    try {
      const { email, fatper, carbper, proteinper } = req.body;
      console.log(email, fatper, carbper, proteinper);
  
      const user = await userModel.findOne({ email: email });
  
      const targetDate = new Date().toISOString().slice(0, 10);
  
      console.log(targetDate);
  
      const fillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': targetDate
      },
      { 'daydate.$': 1 } 
    );
  
      if (user) {
        const fillInfo = await userChoices.findOne({ email: email });
  
        if (!fillInfo && !fillInfohistorical) {
          console.log('user info NOT exist');
          return res.status(400).json('user info NOT exist');
        } else {
          console.log('User info found, updating the percentages');
  
          const afterTDEE = parseFloat(fillInfohistorical.daydate[0].afterTDEE);
  
          if (isNaN(afterTDEE)) {
            console.log('afterTDEE is not a valid number');
            return res.status(400).json('afterTDEE is not a valid number');
          }

          const calculateFat = (tdee, percentage) => {
            const fatCalories = tdee * (percentage / 100);
            return (fatCalories / 9).toFixed(2);
          };
  
          const calculateSaturatedFat = (tdee) => {
            const saturatedFatCalories = tdee * 0.1; // Assuming 10% of fat intake is saturated fat
            return (saturatedFatCalories / 9).toFixed(2);
          };
  
          const calculateProtein = (tdee, percentage) => {
            const proteinCalories = tdee * (percentage / 100);
            return (proteinCalories / 4).toFixed(2);
          };
  
          const calculateCarbohydrates = (tdee, percentage) => {
            const carbCalories = tdee * (percentage / 100);
            return (carbCalories / 4).toFixed(2);
          };
  
          const goalFat = calculateFat(beforeTDEE, fatper);
          const goalSatFat = calculateSaturatedFat(beforeTDEE);
          const goalProtein = calculateProtein(beforeTDEE, proteinper);
          const goalCarbs = calculateCarbohydrates(beforeTDEE, carbper);

          console.log(`Percentages:
          goalFat = ${goalFat}  
          goalSatFat = ${goalSatFat}  
          goalProtein = ${goalProtein}  
          goalCarbs = ${goalCarbs}  
          `)
  
          await historicaldiary.findOneAndUpdate(
            { email: email, 'daydate.todaydate': targetDate },
            {
              $set: {
                'daydate.$.goalfatPer': fatper,
                'daydate.$.goalcarbsPer': carbper,
                'daydate.$.goalprotienPer': proteinper,
                'daydate.$.goaltotFat': goalFat.toString(),
                'daydate.$.goalsatFat': goalSatFat.toString(),
                'daydate.$.goalprotein': goalProtein.toString(),
                'daydate.$.goalcarbs': goalCarbs.toString()
              }
            },
            { new: true }
          );
          return res.status(200).json('Percentages and goals updated successfully');
        }
      } else {
        console.log('user NOT exist');
        return res.status(400).json('user NOT exist');
      }
    } catch (e) {
      console.error(e);
      res.sendStatus(500);
    }
  };


  /*

  exports.changeTDEEREFARCHIVE = async (req, res) => {
    try {
        const { email, tdee } = req.body;
        console.log(email, tdee);

        const user = await userModel.findOne({ email: email });

        const targetDate = new Date().toISOString().slice(0, 10);

        console.log(targetDate);

        const fillInfohistorical = await historicaldiary.findOne({
            email: email,
            'daydate.todaydate': targetDate
        });

        if (user) {
            const fillInfo = await userChoices.findOne({ email: email });

            if (!fillInfo && !fillInfohistorical) {
                console.log('user info NOT exist');
                return res.status(400).json('user info NOT exist');
            } else {
                console.log('User info found, updating TDEE and related values');

                const updatedTDEE = parseFloat(tdee);

                if (isNaN(updatedTDEE) || updatedTDEE < 1000) {
                    console.log('Invalid TDEE value');
                    return res.status(400).json('TDEE value must be a valid number and at least 1000 kcal');
                }

                const { height, currentweight, age, activity, sex ,goalfatPer ,goalprotienPer ,goalcarbsPer , goalweeklyPer } = fillInfohistorical.daydate[0];
                const heightInCm = parseFloat(height);
                const weightInKg = parseFloat(currentweight);
                const ageInYears = parseInt(age);

                const fatPercentage = parseInt(goalfatPer);
                const proteinPercentage = parseInt(goalprotienPer);
                const carbsPercentage = parseInt(goalcarbsPer);
                const goaweeklyPER = goalweeklyPer;
                console.log(`${heightInCm} + ${weightInKg} + ${ageInYears} + ${fatPercentage} + ${proteinPercentage} + ${carbsPercentage}`);



                let bmr = 0.0;
                if (sex === "Male") {
                    bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageInYears) + 5;
                } else if (sex === "Female") {
                    bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageInYears) - 161;
                }

                let activityFactor = 1.2;
                switch (activity) {
                    case "Not Very Active":
                        activityFactor = 1.2;
                        break;
                    case "Lightly Active":
                        activityFactor = 1.375;
                        break;
                    case "Active":
                        activityFactor = 1.55;
                        break;
                    case "Very Active":
                        activityFactor = 1.9;
                        break;
                }


                
                const newTDEE = bmr * activityFactor;

                let newTDEEafter = 0.0;

                if (goaweeklyPER === '-0.5') {
                    newTDEEafter =  newTDEE  - 550;
                    //const goaweeklyPER = goalweeklyPer;

                } else if (goaweeklyPER === '-1') {
                    newTDEEafter =  newTDEE  - 1100;
                } else if (goaweeklyPER === '+0.5') {
                    newTDEEafter =  newTDEE  + 550;
                } else if (goaweeklyPER === '+1') {
                    newTDEEafter =  newTDEE + 1100;
                } else if (goaweeklyPER === '0') {
                    newTDEEafter =  newTDEE;

                }
 
                const calculateFat = (tdee, percentage) => {
                    const fatCalories = tdee * percentage;
                    return (fatCalories / 9).toFixed(2);
                };

                const calculateSaturatedFat = (tdee) => {
                    const saturatedFatCalories = tdee * 0.1;
                    return (saturatedFatCalories / 9).toFixed(2);
                };

                const calculateProtein = (tdee, percentage) => {
                    const proteinCalories = tdee * percentage;
                    return (proteinCalories / 4).toFixed(2);
                };

                const calculateCarbohydrates = (tdee, percentage) => {
                    const carbCalories = tdee * percentage;
                    return (carbCalories / 4).toFixed(2);
                };

                const goalFat = calculateFat(newTDEE, fatPercentage);
                const goalSatFat = calculateSaturatedFat(newTDEE);
                const goalProtein = calculateProtein(newTDEE, proteinPercentage);
                const goalCarbs = calculateCarbohydrates(newTDEE, carbsPercentage);

                console.log(`New TDEE and calculated values:
                    newTDEE = ${newTDEE}
                    newTDEEafter= ${newTDEEafter}
                    goalFat = ${goalFat}
                    goalSatFat = ${goalSatFat}
                    goalProtein = ${goalProtein}
                    goalCarbs = ${goalCarbs}`);

                await historicaldiary.findOneAndUpdate(
                    { email: email, 'daydate.todaydate': targetDate },
                    {
                        $set: {
                            'daydate.$.beforeTDEE': newTDEE.toFixed(2),
                            'daydate.$.afterTDEE': newTDEEafter.toFixed(2),
                            'daydate.$.goaltotFat': goalFat,
                            'daydate.$.goalsatFat': goalSatFat,
                            'daydate.$.goalprotein': goalProtein,
                            'daydate.$.goalcarbs': goalCarbs
                        }
                    },
                    { new: true }
                );
                return res.status(200).json('TDEE and related values updated successfully');
            }
        } else {
            console.log('user NOT exist');
            return res.status(400).json('user NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
};

*/

exports.changeTDEE = async (req, res) => {
    try {
        const { email, tdee } = req.body;
        console.log(email, tdee);

        const user = await userModel.findOne({ email: email });

        const targetDate = new Date().toISOString().slice(0, 10);

        console.log(targetDate);

        const fillInfohistorical = await historicaldiary.findOne(
            {
            email: email,
            'daydate.todaydate': targetDate
            },
            { 'daydate.$': 1 } 
    );

   // console.log("Fill Info Historical:", JSON.stringify(fillInfohistorical, null, 2));



        //const todayEntry = fillInfohistorical.daydate.find(entry => entry.todaydate === targetDate);

        if (user) {
            const fillInfo = await userChoices.findOne({ email: email });

            if (!fillInfo && !fillInfohistorical) {
                console.log('user info NOT exist');
                return res.status(400).json('user info NOT exist');
            } else {
                console.log('User info found, updating TDEE and related values');

                const updatedTDEE = parseFloat(tdee);

                if (isNaN(updatedTDEE) || updatedTDEE < 1000) {
                    console.log('Invalid TDEE value');
                    return res.status(400).json('TDEE value must be a valid number and at least 1000 kcal');
                }

                const { goalfatPer ,goalprotienPer ,goalcarbsPer , goalweeklyPer } = fillInfohistorical.daydate[0];

              
                const fatPercentage = parseInt(goalfatPer);
                const proteinPercentage = parseInt(goalprotienPer);
                const carbsPercentage = parseInt(goalcarbsPer);
                const goaweeklyPER = goalweeklyPer;
                console.log(`${fatPercentage} + ${proteinPercentage} + ${carbsPercentage} + ${fillInfohistorical.daydate[0].todaydate}`);




                let newTDEEbefore = 0.0;

                if (goaweeklyPER === '-0.5') {
                    newTDEEbefore =  updatedTDEE  + 550;
                    //const goaweeklyPER = goalweeklyPer;

                } else if (goaweeklyPER === '-1') {
                    newTDEEbefore =  updatedTDEE  + 1100;
                } else if (goaweeklyPER === '+0.5') {
                    newTDEEbefore =  updatedTDEE  - 550;
                } else if (goaweeklyPER === '+1') {
                    newTDEEbefore =  updatedTDEE - 1100;
                } else if (goaweeklyPER === '0') {
                    newTDEEbefore =  updatedTDEE;

                }
 
                const calculateFat = (tdee, percentage) => {
                    const fatCalories = tdee * (percentage / 100);
                    return (fatCalories / 9).toFixed(2);
                };

                const calculateSaturatedFat = (tdee) => {
                    const saturatedFatCalories = tdee * 0.1;
                    return (saturatedFatCalories / 9).toFixed(2);
                };

                const calculateProtein = (tdee, percentage) => {
                    // tdee * (percentage / 100);
                    const proteinCalories = tdee * (percentage / 100);
                    return (proteinCalories / 4).toFixed(2);
                };

                const calculateCarbohydrates = (tdee, percentage) => {
                    const carbCalories = tdee * (percentage / 100);
                    return (carbCalories / 4).toFixed(2);
                };

                const goalFat = calculateFat(updatedTDEE, fatPercentage);
                const goalSatFat = calculateSaturatedFat(updatedTDEE);
                const goalProtein = calculateProtein(updatedTDEE, proteinPercentage);
                const goalCarbs = calculateCarbohydrates(updatedTDEE, carbsPercentage);

                console.log(`New TDEE and calculated values:
                updatedTDEE = ${updatedTDEE}
                newTDEEbefore= ${newTDEEbefore}
                    goalFat = ${goalFat}
                    goalSatFat = ${goalSatFat}
                    goalProtein = ${goalProtein}
                    goalCarbs = ${goalCarbs}`);

                await historicaldiary.findOneAndUpdate(
                    { email: email, 'daydate.todaydate': targetDate },
                    {
                        $set: {
                            'daydate.$.afterTDEE': updatedTDEE.toFixed(2),
                            'daydate.$.beforeTDEE': newTDEEbefore.toFixed(2),
                            'daydate.$.goaltotFat': goalFat,
                            'daydate.$.goalsatFat': goalSatFat,
                            'daydate.$.goalprotein': goalProtein,
                            'daydate.$.goalcarbs': goalCarbs
                        }
                    },
                    { new: true }
                );
                return res.status(200).json('TDEE and related values updated successfully');
            }
        } else {
            console.log('user NOT exist');
            return res.status(400).json('user NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
};






































exports.changeTDEE2 = async (req, res) => {
    try {
        const { email, tdee } = req.body;
        console.log(email, tdee);

        const user = await userModel.findOne({ email: email });

        const targetDate = new Date().toISOString().slice(0, 10);

        console.log(targetDate);

        const fillInfohistorical = await historicaldiary.findOne(
            {
            email: email,
            'daydate.todaydate': targetDate
            },
            { 'daydate.$': 1 } 
    );

    console.log("Fill Info Historical:", JSON.stringify(fillInfohistorical, null, 2));
    console.log(`date = ${fillInfohistorical.daydate[0].height}`)
   // fillInfohistorical.daydate[0].todaydate



        //const todayEntry = fillInfohistorical.daydate.find(entry => entry.todaydate === targetDate);
/*
        if (user) {
            const fillInfo = await userChoices.findOne({ email: email });

            if (!fillInfo && !fillInfohistorical) {
                console.log('user info NOT exist');
                return res.status(400).json('user info NOT exist');
            } else {
                console.log('User info found, updating TDEE and related values');

                const updatedTDEE = parseFloat(tdee);

                if (isNaN(updatedTDEE) || updatedTDEE < 1000) {
                    console.log('Invalid TDEE value');
                    return res.status(400).json('TDEE value must be a valid number and at least 1000 kcal');
                }

                const { goalfatPer ,goalprotienPer ,goalcarbsPer , goalweeklyPer } = fillInfohistorical.daydate[0];


                const fatPercentage = parseInt(goalfatPer);
                const proteinPercentage = parseInt(goalprotienPer);
                const carbsPercentage = parseInt(goalcarbsPer);
                const goaweeklyPER = goalweeklyPer;
                console.log(`${fatPercentage} + ${proteinPercentage} + ${carbsPercentage} + ${fillInfohistorical.daydate[0].todaydate}`);




                let newTDEEbefore = 0.0;

                if (goaweeklyPER === '-0.5') {
                    newTDEEbefore =  updatedTDEE  + 550;
                    //const goaweeklyPER = goalweeklyPer;

                } else if (goaweeklyPER === '-1') {
                    newTDEEbefore =  updatedTDEE  + 1100;
                } else if (goaweeklyPER === '+0.5') {
                    newTDEEbefore =  updatedTDEE  - 550;
                } else if (goaweeklyPER === '+1') {
                    newTDEEbefore =  updatedTDEE - 1100;
                } else if (goaweeklyPER === '0') {
                    newTDEEbefore =  updatedTDEE;

                }
 
                const calculateFat = (tdee, percentage) => {
                    const fatCalories = tdee * (percentage / 100);
                    return (fatCalories / 9).toFixed(2);
                };

                const calculateSaturatedFat = (tdee) => {
                    const saturatedFatCalories = tdee * 0.1;
                    return (saturatedFatCalories / 9).toFixed(2);
                };

                const calculateProtein = (tdee, percentage) => {
                    // tdee * (percentage / 100);
                    const proteinCalories = tdee * (percentage / 100);
                    return (proteinCalories / 4).toFixed(2);
                };

                const calculateCarbohydrates = (tdee, percentage) => {
                    const carbCalories = tdee * (percentage / 100);
                    return (carbCalories / 4).toFixed(2);
                };

                const goalFat = calculateFat(updatedTDEE, fatPercentage);
                const goalSatFat = calculateSaturatedFat(updatedTDEE);
                const goalProtein = calculateProtein(updatedTDEE, proteinPercentage);
                const goalCarbs = calculateCarbohydrates(updatedTDEE, carbsPercentage);

                console.log(`New TDEE and calculated values:
                updatedTDEE = ${updatedTDEE}
                newTDEEbefore= ${newTDEEbefore}
                    goalFat = ${goalFat}
                    goalSatFat = ${goalSatFat}
                    goalProtein = ${goalProtein}
                    goalCarbs = ${goalCarbs}`);

                await historicaldiary.findOneAndUpdate(
                    { email: email, 'daydate.todaydate': targetDate },
                    {
                        $set: {
                            'daydate.$.afterTDEE': updatedTDEE.toFixed(2),
                            'daydate.$.beforeTDEE': newTDEEbefore.toFixed(2),
                            'daydate.$.goaltotFat': goalFat,
                            'daydate.$.goalsatFat': goalSatFat,
                            'daydate.$.goalprotein': goalProtein,
                            'daydate.$.goalcarbs': goalCarbs
                        }
                    },
                    { new: true }
                );
                return res.status(200).json('TDEE and related values updated successfully');
            }
        } else {
            console.log('user NOT exist');
            return res.status(400).json('user NOT exist');
        }
        */
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
};



exports.changeactivitylevel = async (req, res) => {
    try {
        const { email, actlevel } = req.body;
        console.log(email, actlevel);

        const user = await userModel.findOne({ email: email });

        const targetDate = new Date().toISOString().slice(0, 10);

        console.log(targetDate);

        const fillInfohistorical = await historicaldiary.findOne(
            {
            email: email,
            'daydate.todaydate': targetDate
            },
            { 'daydate.$': 1 } 
		);
	

        if (user) {
            const fillInfo = await userChoices.findOne({ email: email });

            if (!fillInfo && !fillInfohistorical) {
                console.log('user info NOT exist');
                return res.status(400).json('user info NOT exist');
            } else {
                console.log('User info found, updating TDEE and related values');

             
                const { height, currentweight, age, activity, sex ,goalfatPer ,goalprotienPer ,goalcarbsPer , goalweeklyPer } = fillInfohistorical.daydate[0];
               
                // const updatedTDEE = parseFloat(tdee);

                // if (isNaN(updatedTDEE) || updatedTDEE < 1000) {
                //     console.log('Invalid TDEE value');
                //     return res.status(400).json('TDEE value must be a valid number and at least 1000 kcal');
                // }

              
                const heightInCm = parseFloat(height);
                const weightInKg = parseFloat(currentweight);
                const ageInYears = parseInt(age);

                const fatPercentage = parseInt(goalfatPer);
                const proteinPercentage = parseInt(goalprotienPer);
                const carbsPercentage = parseInt(goalcarbsPer);
                const goaweeklyPER = goalweeklyPer;
                console.log(`${heightInCm} + ${weightInKg} + ${ageInYears} + ${fatPercentage} + ${proteinPercentage} + ${carbsPercentage}`);



                let bmr = 0.0;
                if (sex === "Male") {
                    bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageInYears) + 5;
                } else if (sex === "Female") {
                    bmr = (10 * weightInKg) + (6.25 * heightInCm) - (5 * ageInYears) - 161;
                }

                let activityFactor = 1.2;
                switch (actlevel) {
                    case "Not Very Active":
                        activityFactor = 1.2;
                        break;
                    case "Lightly Active":
                        activityFactor = 1.375;
                        break;
                    case "Active":
                        activityFactor = 1.55;
                        break;
                    case "Very Active":
                        activityFactor = 1.9;
                        break;
                }


                
                const newTDEE = bmr * activityFactor;

                let newTDEEafter = 0.0;

                if (goaweeklyPER === '-0.5') {
                    newTDEEafter =  newTDEE  - 550;
                    //const goaweeklyPER = goalweeklyPer;

                } else if (goaweeklyPER === '-1') {
                    newTDEEafter =  newTDEE  - 1100;
                } else if (goaweeklyPER === '+0.5') {
                    newTDEEafter =  newTDEE  + 550;
                } else if (goaweeklyPER === '+1') {
                    newTDEEafter =  newTDEE + 1100;
                } else if (goaweeklyPER === '0') {
                    newTDEEafter =  newTDEE;

                }
 
                const calculateFat = (tdee, percentage) => {
                    const fatCalories = tdee * (percentage / 100);
                    return (fatCalories / 9).toFixed(2);
                };

                const calculateSaturatedFat = (tdee) => {
                    const saturatedFatCalories = tdee * 0.1;
                    return (saturatedFatCalories / 9).toFixed(2);
                };

                const calculateProtein = (tdee, percentage) => {
                    const proteinCalories = tdee * (percentage / 100);
                    return (proteinCalories / 4).toFixed(2);
                };

                const calculateCarbohydrates = (tdee, percentage) => {
                    const carbCalories = tdee * (percentage / 100);
                    return (carbCalories / 4).toFixed(2);
                };

                const goalFat = calculateFat(newTDEE, fatPercentage);
                const goalSatFat = calculateSaturatedFat(newTDEE);
                const goalProtein = calculateProtein(newTDEE, proteinPercentage);
                const goalCarbs = calculateCarbohydrates(newTDEE, carbsPercentage);

                console.log(`New TDEE and calculated values:
                    newTDEE = ${newTDEE}
                    newTDEEafter= ${newTDEEafter}
                    goalFat = ${goalFat}
                    goalSatFat = ${goalSatFat}
                    goalProtein = ${goalProtein}
                    goalCarbs = ${goalCarbs}`);

                await historicaldiary.findOneAndUpdate(
                    { email: email, 'daydate.todaydate': targetDate },
                    {
                        $set: {
                            'daydate.$.beforeTDEE': newTDEE.toFixed(2),
                            'daydate.$.afterTDEE': newTDEEafter.toFixed(2),
                            'daydate.$.goaltotFat': goalFat,
                            'daydate.$.goalsatFat': goalSatFat,
                            'daydate.$.goalprotein': goalProtein,
                            'daydate.$.goalcarbs': goalCarbs,
                            'daydate.$.activity': actlevel,

                        }
                    },
                    { new: true }
                );
                return res.status(200).json('TDEE and related values updated successfully');
            }
        } else {
            console.log('user NOT exist');
            return res.status(400).json('user NOT exist');
        }
    } catch (e) {
        console.error(e);
        res.sendStatus(500);
    }
};
