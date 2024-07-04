const express = require('express');
 
const router = express.Router();
const path = require('path');
 
const bcrypt = require('bcrypt');
const userModel = require('../models/user');
const userChoices =  require('../models/userChoices');
const waterintake =  require('../models/Waterintake');
const progressphoto = require('../models/progressphotos');
const historicaldiary = require('../models/historicalDiary');
const dailytrackprogress = require('../models/DailyTrackProgress');
const fs = require('fs');

const multer = require('multer');


// Configure multer to use memory storage
const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

exports.setprogressphoto = [
  upload.single('image'), // Use multer middleware to handle the 'image' field
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).send('No file uploaded');
      }
     console.log(req.file);

      const { email, date, weight } = req.body;
      console.log(email, date, weight);

      const formatDate = (date) => {
        const d = new Date(date);
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
      };

      const formattedDate = formatDate(date);
      console.log(formattedDate); //YYYY-MM-DD
      
      const TodayTargetfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': formattedDate
      },
      { 'daydate.$': 1 } 
    );

    const dailytrackprogressToday = await dailytrackprogress.findOne({
      email: email,
      'daydate.todaydate': formattedDate
    },
    { 'daydate.$': 1 } 
  );




      //const imageBuffer = req.file.buffer; // Get the image buffer

      const userFillChoices = await userChoices.findOne({ email: email });

      if (userFillChoices) {
        const fillInfo = await progressphoto.findOne({ email: email });

        if (!fillInfo) {
          // If no existing progressphoto record, create a new one
          const progressphotoSchema = new progressphoto({
            iduser: userFillChoices.iduser,
            email: email,
            photo: [{
              date: date,
              weight: weight,
              image: {
                data:  req.file.buffer, // Read the uploaded file
                contentType: req.file.mimetype // Set the MIME type of the file
              }
            }]
          });
          await progressphotoSchema.save();

            //--------------------------------------
          if (TodayTargetfillInfohistorical) {

            const recentEntryDayData = TodayTargetfillInfohistorical.daydate[0];

            const updateFields = {
              'daydate.$.currentweight': weight,
            };
    
            await historicaldiary.updateOne(
              { email: email, 'daydate.todaydate': recentEntryDayData.todaydate },
              { $set: updateFields }
            );

          }
          else {

            const mostRecentEntryBeforeToday = await historicaldiary.findOne(
              {
                email: email,
                'daydate.todaydate': { $lt: formattedDate }
              },
              { 'daydate.$': 1 } // Project only the matched subdocument
            ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry

            const recentDaydate = mostRecentEntryBeforeToday.daydate[0];

            let allBreakfasts = [];
            let allLunches = [];
            let allDinners = [];
            let allSnacks = [];
            let allExercises = [];
        
                // Use the most recent entry to fill the new one
            await historicaldiary.findOneAndUpdate(
              { email: email },
              {
                $push: {
                  daydate: {
                    todaydate: formattedDate,
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
            
          }


          if(dailytrackprogressToday){

            const recentEntryDayData = dailytrackprogressToday.daydate[0];

            const updateFields = {
              'daydate.$.currentweight': weight,
            };

            await dailytrackprogress.updateOne(
              { email: email, 'daydate.todaydate': recentEntryDayData.todaydate },
              { $set: updateFields }
            );

          }
          else {

            const TodayHistForProgressDaily = await dailytrackprogress.findOne(
              {
                email: email,
                'daydate.todaydate': { $lt: formattedDate }
              },
              { 'daydate.$': 1 } // Project only the matched subdocument
            ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry

            
                const newEntry = {
                  todaydate: formatDate,
                  beforeTDEE: TodayHistForProgressDaily.daydate[0].beforeTDEE,
                  afterTDEE: TodayHistForProgressDaily.daydate[0].afterTDEE,
                  remaining: TodayHistForProgressDaily.daydate[0].remaining,
                  burned: TodayHistForProgressDaily.daydate[0].burned,
                  currentweight: TodayHistForProgressDaily.daydate[0].currentweight,
                  goalWeight: TodayHistForProgressDaily.daydate[0].goalWeight,
                  goalweeklyPer: TodayHistForProgressDaily.daydate[0].goalweeklyPer,
              };

              await dailytrackprogress.updateOne(
                  { email: email },
                  { $push: { daydate: newEntry } }
              );


          }


          //--------------------------------------



          return res.status(200).json('done add full record');
        } else {
          // If existing progressphoto record, update only the photo 
          await progressphoto.updateOne(
            { email: email },
            {
              $push: {
                photo: [{
                  date: date,
                  weight: weight,
                  image: [{
                    data:  req.file.buffer, // Read the uploaded file
                contentType: req.file.mimetype // Set the MIME type of the file
                  }]
                }]
              }
            }
          );


                      //--------------------------------------
                      if (TodayTargetfillInfohistorical) {

                        const recentEntryDayData = TodayTargetfillInfohistorical.daydate[0];
            
                        const updateFields = {
                          'daydate.$.currentweight': weight,
                        };
                
                        await historicaldiary.updateOne(
                          { email: email, 'daydate.todaydate': recentEntryDayData.todaydate },
                          { $set: updateFields }
                        );
            
                      }
                      else {
            
                        const mostRecentEntryBeforeToday = await historicaldiary.findOne(
                          {
                            email: email,
                            'daydate.todaydate': { $lt: formattedDate }
                          },
                          { 'daydate.$': 1 } // Project only the matched subdocument
                        ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry
            
                        const recentDaydate = mostRecentEntryBeforeToday.daydate[0];
            
                        let allBreakfasts = [];
                        let allLunches = [];
                        let allDinners = [];
                        let allSnacks = [];
                        let allExercises = [];
                    
                            // Use the most recent entry to fill the new one
                        await historicaldiary.findOneAndUpdate(
                          { email: email },
                          {
                            $push: {
                              daydate: {
                                todaydate: formattedDate,
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
                        
                      }
            
            
                      if(dailytrackprogressToday){
            
                        const recentEntryDayData = dailytrackprogressToday.daydate[0];
            
                        const updateFields = {
                          'daydate.$.currentweight': weight,
                        };
            
                        await dailytrackprogress.updateOne(
                          { email: email, 'daydate.todaydate': recentEntryDayData.todaydate },
                          { $set: updateFields }
                        );
            
                      }
                      else {
            
                        const TodayHistForProgressDaily = await dailytrackprogress.findOne(
                          {
                            email: email,
                            'daydate.todaydate': { $lt: formattedDate }
                          },
                          { 'daydate.$': 1 } // Project only the matched subdocument
                        ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry
            
                        
                            const newEntry = {
                              todaydate: formatDate,
                              beforeTDEE: TodayHistForProgressDaily.daydate[0].beforeTDEE,
                              afterTDEE: TodayHistForProgressDaily.daydate[0].afterTDEE,
                              remaining: TodayHistForProgressDaily.daydate[0].remaining,
                              burned: TodayHistForProgressDaily.daydate[0].burned,
                              currentweight: TodayHistForProgressDaily.daydate[0].currentweight,
                              goalWeight: TodayHistForProgressDaily.daydate[0].goalWeight,
                              goalweeklyPer: TodayHistForProgressDaily.daydate[0].goalweeklyPer,
                          };
            
                          await dailytrackprogress.updateOne(
                              { email: email },
                              { $push: { daydate: newEntry } }
                          );
            
            
                      }
                  
                  //----------------------------------
                  
          return res.status(200).json('done adding only photo');
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
];



exports.showprogressphotos = async (req, res) => {
  try {
      const { email } = req.body;

      const userfillChoces = await userChoices.findOne({ email: email });

      if (userfillChoces) {
          const fillInfo = await progressphoto.findOne({ email: email });

          if (!fillInfo) {
              return res.status(400).json('User does not have any logged photos yet.');
          } else {
              let logArray = fillInfo.photo;

              // Sort logArray by date in descending order
              logArray.sort((a, b) => new Date(b.date) - new Date(a.date));

              const formattedLogs = [];

              for (const loga of logArray) {
                  const logDate = loga.date;
                  const logWeight = loga.weight;
                  const logImages = loga.image;
                  const IDlog = loga._id;

                  // Iterate over each image in the array
                  const formattedImages = logImages.map(image => ({
                      data: image.data.toString('base64'), // Convert binary data to base64 string
                      contentType: image.contentType
                  }));

                  formattedLogs.push({
                      date: logDate,
                      weight: logWeight,
                      images: formattedImages,
                      photoID: IDlog
                  });
              }

              const responseObj = {
                  formattedLogs: formattedLogs,
              };
              res.json(responseObj);
          }
      } else {
          console.log('User does not exist');
          return res.status(400).json('User does not exist');
      }
  } catch (e) {
      console.error(e);
      res.sendStatus(500);
  }
}



// exports.showprogressphotos = async (req, res) => {
//     try {
//         const { email, } = req.body;

//         const userfillChoces = await userChoices.findOne({ email: email });

//         if (userfillChoces) {
//             const fillInfo = await progressphoto.findOne({ email: email });

//             if (!fillInfo) {
//                 return res.status(400).json('User does not have any logged photos yet.');
//             } else {
//               const logArray = fillInfo.photo;
//               const formattedLogs = [];

//               for (const loga of logArray) {
//                   const logDate = loga.date;
//                   const logWeight = loga.weight;
//                   const logImages = loga.image;
//                   const IDlog= loga._id;
//                 // Iterate over each image in the array
//               const formattedImages = logImages.map(image => ({
//                 data: image.data.toString('base64'), // Convert binary data to base64 string
//                 contentType: image.contentType
//             }));
//             //console.log(formattedImages);
//                 formattedLogs.push({
//                       date: logDate,
//                       weight: logWeight,
//                       images: formattedImages,
                     
//                       photoID:IDlog
//                   });
//               }
//          //   console.log(formattedLogs);
       
//               const responseObj = {
//                   formattedLogs: formattedLogs,
//               };
//               res.json(responseObj);
//           }
//         } else {
//             console.log('User does not exist');
//             return res.status(400).json('User does not exist');
//         }
//     } catch (e) {
//         console.error(e);
//         res.sendStatus(500);
//     }
// }




// Endpoint handler for updateprogressphotos
exports.updateprogressphotos = 

  async (req, res) => {
    try {
     
     console.log(req.body); // Log other fields

      const { email, date, weight , olddate , photoID } = req.body;
      // Replace "T" with a space in the date and olddate fields
      const formattedDate = date.replace('T', ' ');
      const formattedOldDate = olddate.replace('T', ' ');

      // Log the formatted fields
      console.log(email, formattedDate, weight, formattedOldDate);

      
      const formatDate = (date) => {
        const d = new Date(date);
        const year = d.getFullYear();
        const month = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
      };

      const formattedDateForHistorical = formatDate(date);
      console.log(formattedDateForHistorical); //YYYY-MM-DD
      
      const TodayTargetfillInfohistorical = await historicaldiary.findOne({
        email: email,
        'daydate.todaydate': formattedDateForHistorical
      },
      { 'daydate.$': 1 } 
    );

    const dailytrackprogressToday = await dailytrackprogress.findOne({
      email: email,
      'daydate.todaydate': formattedDateForHistorical
    },
    { 'daydate.$': 1 } 
  );




      const userFillChoices = await userChoices.findOne({ email: email });

      if (userFillChoices) {
        const fillInfo = await progressphoto.findOne({ email: email });

        if (!fillInfo) {

          return res.status(200).json('User Not found in progress records');
        } else {
          // If existing progressphoto record, update only the photo 
              const ReplaceArray = fillInfo.photo; 

              for (let index = 0; index < ReplaceArray.length; index++) {
                  const loga = ReplaceArray[index];
                  try {

                      const logDate = loga.date;
                      const logID = loga._id;
                    //  console.log(logID.toString());

                      if (logID.toString() === photoID) {
                          console.log(`Condition met. Breaking out of loop. at index=${index}`);
                          ReplaceArray[index].weight = weight; 
                          ReplaceArray[index].date = formattedDate; 
                          break; 
                      }
                  } catch (error) {
                      console.error(`Error parsing log at index ${index}: ${loga}`);
                      console.error(error);
                  }
              }
              
              await progressphoto.updateOne({ email: email }, { $set: { photo: ReplaceArray } });
              //console.log("Below check for edit photo");
             // console.log(ReplaceArray);

             

            //--------------------------------------
          if (TodayTargetfillInfohistorical) {

            const recentEntryDayData = TodayTargetfillInfohistorical.daydate[0];

            const updateFields = {
              'daydate.$.currentweight': weight,
            };
    
            await historicaldiary.updateOne(
              { email: email, 'daydate.todaydate': recentEntryDayData.todaydate },
              { $set: updateFields }
            );

          }
          else {

            const mostRecentEntryBeforeToday = await historicaldiary.findOne(
              {
                email: email,
                'daydate.todaydate': { $lt: formattedDateForHistorical }
              },
              { 'daydate.$': 1 } // Project only the matched subdocument
            ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry

            const recentDaydate = mostRecentEntryBeforeToday.daydate[0];

            let allBreakfasts = [];
            let allLunches = [];
            let allDinners = [];
            let allSnacks = [];
            let allExercises = [];
        
                // Use the most recent entry to fill the new one
            await historicaldiary.findOneAndUpdate(
              { email: email },
              {
                $push: {
                  daydate: {
                    todaydate: formattedDateForHistorical,
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
            
          }


          if(dailytrackprogressToday){

            const recentEntryDayData = dailytrackprogressToday.daydate[0];

            const updateFields = {
              'daydate.$.currentweight': weight,
            };

            await dailytrackprogress.updateOne(
              { email: email, 'daydate.todaydate': recentEntryDayData.todaydate },
              { $set: updateFields }
            );

          }
          else {

            const TodayHistForProgressDaily = await dailytrackprogress.findOne(
              {
                email: email,
                'daydate.todaydate': { $lt: formattedDateForHistorical }
              },
              { 'daydate.$': 1 } // Project only the matched subdocument
            ).sort({ 'daydate.todaydate': -1 }); // Sort in descending order to get the most recent entry

            
                const newEntry = {
                  todaydate: formatDate,
                  beforeTDEE: TodayHistForProgressDaily.daydate[0].beforeTDEE,
                  afterTDEE: TodayHistForProgressDaily.daydate[0].afterTDEE,
                  remaining: TodayHistForProgressDaily.daydate[0].remaining,
                  burned: TodayHistForProgressDaily.daydate[0].burned,
                  currentweight: TodayHistForProgressDaily.daydate[0].currentweight,
                  goalWeight: TodayHistForProgressDaily.daydate[0].goalWeight,
                  goalweeklyPer: TodayHistForProgressDaily.daydate[0].goalweeklyPer,
              };

              await dailytrackprogress.updateOne(
                  { email: email },
                  { $push: { daydate: newEntry } }
              );


          }
		  
		  //----------------------------------
		  

             
              return res.status(200).json('Done updating photo');
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

  
  // Endpoint handler for updateprogressphotos
exports.deleteprogressphotos= 

async (req, res) => {
  try {
   
    console.log(req.body); // Log other fields

      const { email, date, weight , olddate , photoID} = req.body;
      // Replace "T" with a space in the date and olddate fields
      const formattedDate = date.replace('T', ' ');
      const formattedOldDate = olddate.replace('T', ' ');

      // Log the formatted fields
      console.log(email, formattedDate, weight, formattedOldDate);

    const userFillChoices = await userChoices.findOne({ email: email });

    if (userFillChoices) {
      const fillInfo = await progressphoto.findOne({ email: email });

      if (!fillInfo) {

        return res.status(200).json('User Not found in progress records');
      } else {
        // If existing progressphoto record, update only the photo without image
        const ReplaceArray = fillInfo.photo; 

        for (let index = 0; index < ReplaceArray.length; index++) {
            const loga = ReplaceArray[index];
            try {

                const logDate = loga.date;
                const logID = loga._id;
                //  console.log(logID.toString());

                  if (logID.toString() === photoID) {
                    console.log(`Condition met. Breaking out of loop. at index=${index}`);
                    ReplaceArray.splice(index, 1); // Remove the log object at the current index
                    break; 
                }
            } catch (error) {
                console.error(`Error parsing log at index ${index}: ${loga}`);
                console.error(error);
            }
        }
        
        await progressphoto.updateOne({ email: email }, { $set: { photo: ReplaceArray } });
        //console.log("Below check for edit photo");
       // console.log(ReplaceArray);
        return res.status(200).json('Done Deleting photo');

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