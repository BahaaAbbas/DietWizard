const express = require("express");
const router = express.Router();
const Rem = require("../controllers/reminder");


router.post('/reminders/:email', Rem.PostReminder);
router.get('/reminders/:email', Rem.GetReminder);
router.put('/reminders/:id/:email', Rem.PutReminder);
router.delete('/reminders/:id/:email', Rem.DeleteReminder);

module.exports = router;