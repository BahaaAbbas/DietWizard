const express = require('express');
const router = express.Router();
const path = require('path');

// const Exercise = require('../models/exerciseSchema');
// // Route to render exercises.ejs with pagination

exports.getFilter = async (req, res) => {
    try {
        res.render('filter');
    }catch (error) {
    console.error('Error fetching exercises:', error);
    }
};