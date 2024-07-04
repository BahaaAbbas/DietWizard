const express = require('express');
const router = express.Router();
const path = require('path');

const Exercise = require('../models/exerciseSchema');
const Category_exercises = require('../models/Category_exercise');
// // Route to render exercises.ejs with pagination

exports.getExercisesWeb = async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1; // Get current page from query parameter
      const pageSize = 10; // Number of exercises per page
      const skip = (page - 1) * pageSize; // Calculate number of exercises to skip
  
      const exercises = await Exercise.find().skip(skip).limit(pageSize);
      const count = await Exercise.countDocuments();
  
      // Calculate total number of pages
      const totalPages = Math.ceil(count / pageSize);
  
      res.render('exercises', { exercises, currentPage: page, totalPages });
    } catch (error) {
      console.error('Error fetching exercises:', error);
      res.status(500).send('Server Error');
    }
  };




  exports.getExercisesCategory = async (req, res) => {
    const category = req.params.category;
  let exerciseIds = [];
  
  try {
      let categoryExercise = await Category_exercises.findOne({ type: req.params.category });
  
      if (categoryExercise) {
          exerciseIdss = categoryExercise.numbers;
      } else {
          // Return an error response if the category exercise is not found
          return res.status(404).json({ error: 'Category exercise not found' });
          // res.redirect('filter.ejs');
      }
  
      // Assign exercise IDs based on the selected category
      switch (category) {
          case 'Abs':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Arms':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Back':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Cardio':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Chest':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Legs':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Shoulders':
              exerciseIds = categoryExercise.numbers;
              break;
          // Add cases for other categories
          default:
              break;
      }
  
      // Fetch exercises from MongoDB based on IDs
      const exercises = await Exercise.find({ id: { $in: exerciseIds } });
      res.render('exerciseList', { exercises }); // Render the exerciseList.ejs template with exercises data
  } catch (error) {
      console.error('Error fetching exercises:', error);
      res.status(500).json({ error: 'Internal Server Error' });
  }
  
  };








  exports.postRemoveExercises = async (req, res) => {
    try {
      const { type, numberToRemove } = req.body;

      // Find the document in the database based on the type
      const categoryExercise = await Category_exercises.findOne({ type });

      // If document is found, remove the specified number from the array
      if (categoryExercise) {
          const number = parseInt(numberToRemove);
          
          // Filter out the number to be removed
          categoryExercise.numbers = categoryExercise.numbers.filter(num => num !== number);

          // Save the updated document
          await categoryExercise.save();

          // Redirect to a success page or any other page as needed
          res.render('addexercises.ejs');
        } else {
          // Document not found, handle accordingly (e.g., send error response)
          res.status(404).send('Category exercise not found.');
      }
  } catch (error) {
      // Handle error
      console.error(error);
      res.status(500).send('Internal Server Error');
  }
  
  };






  exports.getExercisesCategoryMobile = async (req, res) => {
    
  
  const category = req.params.category;
  let exerciseIds = [];
  
  try {
      let categoryExercise = await Category_exercises.findOne({ type: req.params.category });
  
      // if (!exerciseIds) {
      //   return res.status(404).json({ error: 'Category exercise not found' });
      // }
    

      if (categoryExercise) {
          exerciseIdss = categoryExercise.numbers;
      } else {
          // Return an error response if the category exercise is not found
          return res.status(404).json({ error: 'Category exercise not found' });
          // res.redirect('filter.ejs');
      }
  
      // Assign exercise IDs based on the selected category
      switch (category) {
          case 'Abs':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Arms':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Back':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Cardio':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Chest':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Legs':
              exerciseIds = categoryExercise.numbers;
              break;
          case 'Shoulders':
              exerciseIds = categoryExercise.numbers;
              break;
          // Add cases for other categories
          default:
              break;
      }
  
      // Fetch exercises from MongoDB based on IDs
      const exercises = await Exercise.find({ id: { $in: exerciseIds } });
      // res.render('exerciseList', { exercises }); // Render the exerciseList.ejs template with exercises data
      // console.log({ exercises });
      res.json({ exercises });
  } catch (error) {
      console.error('Error fetching exercises:', error);
      res.status(500).json({ error: 'Internal Server Error' });
  }

  // Here you would typically query your database based on the exercise IDs
  // For demonstration, I'm just sending back the exercise IDs
  // res.json({ exercises: exerciseIds });
  
  };





  // const ExerciseImageSchema = new mongoose.Schema({
//   name: String,
//   imageUrl: String,
// });

// const ExerciseImage = mongoose.model('ExerciseImage', ExerciseImageSchema);

// // Express route for /api/v2/exerciseimage/?limit=2
// app.get('exercises', async (req, res) => {
//   try {
//     const response = await axios.get('https://wger.de/api/v2/exerciseimage/');
//     const exerciseImages = response.data.results;
//     res.render('exercises', { exerciseImages }); // Rendering exercise.ejs
//   } catch (error) {
//     console.error(error);
//     res.status(500).send('Server Error');
//   }
// });


///////////////////////////////////////////////////////



// const exerciseSchema = new mongoose.Schema({
//   id: Number,
 
//   image: String,
 
// },{versionKey:false}
// );


///// this is for fetch and save exercise


// const Exercise = mongoose.model('Exercise', exerciseSchema);

// async function fetchAndSaveExercises(url) {
//   try {
//     const response = await axios.get(url);
//     const exercisesData = response.data.results;

//     // Save each exercise to MongoDB
//     for (const exerciseData of exercisesData) {
//       const exercise = new Exercise({
//         id: exerciseData.id,
 
//         image: exerciseData.image,
   
//       });
//       await exercise.save();
//     }

//     console.log('Exercises saved to MongoDB');

//     // Check if there's a next page
//     if (response.data.next) {
//       const nextOffset = new URL(response.data.next).searchParams.get('offset');
//       const nextUrl = `https://wger.de/api/v2/exerciseimage/?limit=20&offset=${nextOffset}`;
//       await fetchAndSaveExercises(nextUrl); // Recursively fetch next page
//     }
//   } catch (error) {
//     console.error('Error fetching or saving exercises:', error);
//   }
// }





// // Fetch and save exercises if not already present in MongoDB
// async function init() {
//   const count = await Exercise.countDocuments();
//   if (count === 0) {
//     // await fetchAndSaveExercises();

//           // Start fetching exercises from the initial URL
//      await fetchAndSaveExercises('https://wger.de/api/v2/exerciseimage/?limit=20');

//   }
// }

// init();
/////////////// here end the fetch and save exercise



//////////////////////////////////////////
// this is new version from fetch and save exercise 


  // here fetch the exercise data to fix new details 
//   async function fetchAndSaveExercises(url) {
//     try {
//       const response = await axios.get(url);
//       const exercisesData = response.data.results;
  
//       // Save each exercise to MongoDB
//       for (const exerciseData of exercisesData) {
//         const exercise = new Exercise({
//           id: exerciseData.id,
//           image: exerciseData.image,
//           name: "excercise",
//           description: "move",
//           time: "5min",
//           calories: "100kcal",
     
//         });
//         await exercise.save();
//       }
  
//       console.log('Exercises saved to MongoDB');
  
//       // Check if there's a next page
//       if (response.data.next) {
//         const nextOffset = new URL(response.data.next).searchParams.get('offset');
//         const nextUrl = `https://wger.de/api/v2/exerciseimage/?limit=20&offset=${nextOffset}`;
//         await fetchAndSaveExercises(nextUrl); // Recursively fetch next page
//       }
//     } catch (error) {
//       console.error('Error fetching or saving exercises:', error);
//     }
//   }
  
//   // Fetch and save exercises if not already present in MongoDB
//   async function init() {
//     const count = await Exercise.countDocuments();
//     if (count === 0) {
//       // await fetchAndSaveExercises();
  
//             // Start fetching exercises from the initial URL
//        await fetchAndSaveExercises('https://wger.de/api/v2/exerciseimage/?limit=20');
  
//     }
//   }
  
  // init();
  ///////////// here end the fetch and save exercise