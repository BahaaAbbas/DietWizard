const express = require("express");
const router = express.Router();
const noti = require("../controllers/Notification");

router.post('/postnotification/:postId', noti.postNotification);
router.get('/getnotification/:nameuser', noti.getNotification);

router.delete('/notifications/:idnotification', noti.deleteNotification);



module.exports = router;