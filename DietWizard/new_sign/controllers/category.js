const express = require('express');
const router = express.Router();
const path = require('path');



exports.getCategory = async (req, res) => {
    // console.log("the login get is called");
    res.render('category', { errors: {} });
    };



    
exports.getControlPanel = async (req, res) => {
    // console.log("the login get is called");
    res.render('ControlPanel', { errors: {} });
    };
