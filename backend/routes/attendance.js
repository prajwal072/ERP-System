const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');
const User = require('../models/User');

// Simple token-based auth middleware for demo
async function requireFaculty(req, res, next) {
  const token = req.headers['x-auth-token'];
  console.log('Debug: Token received:', token);
  if (!token) return res.status(401).json({ message: 'No token provided' });
  // For demo, token is userId
  const user = await User.findOne({ userId: token });
  console.log('Debug: User found:', user);
  if (!user || user.role !== 'faculty') {
    console.log('Debug: Access denied - user:', user?.role);
    return res.status(403).json({ message: 'Access denied' });
  }
  req.user = user;
  next();
}

// Mark attendance (faculty only)
router.post('/', requireFaculty, async (req, res) => {
  try {
    const Student = require('../models/Student');
    const { student, subject, date, status, marks } = req.body;
    
    // Find student by rollNumber
    const studentDoc = await Student.findOne({ rollNumber: student });
    if (!studentDoc) {
      return res.status(404).json({ message: 'Student not found' });
    }
    
    const attendance = new Attendance({
      student: studentDoc._id,
      subject,
      date,
      status,
      marks
    });
    await attendance.save();
    res.status(201).json(attendance);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Get attendance for a student
router.get('/student/:studentId', async (req, res) => {
  try {
    const records = await Attendance.find({ student: req.params.studentId });
    res.json(records);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get attendance report by subject
router.get('/report/:studentId/:subject', async (req, res) => {
  try {
    const records = await Attendance.find({ student: req.params.studentId, subject: req.params.subject });
    res.json(records);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router; 