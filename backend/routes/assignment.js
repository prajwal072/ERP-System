const express = require('express');
const router = express.Router();
const Assignment = require('../models/Assignment');
const User = require('../models/User');
const Student = require('../models/Student');

// Middleware for faculty authentication (reuse from attendance.js)
async function requireFaculty(req, res, next) {
  const token = req.headers['x-auth-token'];
  if (!token) return res.status(401).json({ message: 'No token provided' });
  const user = await User.findOne({ userId: token });
  if (!user || user.role !== 'faculty') {
    return res.status(403).json({ message: 'Access denied' });
  }
  req.user = user;
  next();
}

// Create assignment (faculty only)
router.post('/', requireFaculty, async (req, res) => {
  try {
    const assignment = new Assignment({ ...req.body, faculty: req.user._id });
    await assignment.save();
    res.status(201).json(assignment);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Get all assignments
router.get('/', async (req, res) => {
  try {
    const assignments = await Assignment.find().populate('faculty', 'name userId');
    res.json(assignments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Submit assignment (student)
router.post('/:id/submit', async (req, res) => {
  try {
    const { studentId, fileUrl } = req.body;
    const assignment = await Assignment.findById(req.params.id);
    if (!assignment) return res.status(404).json({ message: 'Assignment not found' });
    // Check if already submitted
    if (assignment.submissions.some(sub => sub.student.toString() === studentId)) {
      return res.status(400).json({ message: 'Already submitted' });
    }
    assignment.submissions.push({ student: studentId, fileUrl });
    await assignment.save();
    res.status(201).json({ message: 'Assignment submitted' });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Get submissions for an assignment (faculty only)
router.get('/:id/submissions', requireFaculty, async (req, res) => {
  try {
    const assignment = await Assignment.findById(req.params.id).populate('submissions.student', 'name rollNumber');
    if (!assignment) return res.status(404).json({ message: 'Assignment not found' });
    res.json(assignment.submissions);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router; 