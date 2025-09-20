const express = require('express');
const router = express.Router();
const User = require('../models/User');

// POST /api/auth/login
router.post('/login', async (req, res) => {
  const { name, userId } = req.body;
  if (!name || !userId) {
    return res.status(400).json({ message: 'Name and ID are required' });
  }
  try {
    const user = await User.findOne({ name, userId });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    // Check if student has complete profile
    let profileComplete = true;
    if (user.role === 'student') {
      const Student = require('../models/Student');
      const student = await Student.findOne({ userId });
      profileComplete = student && student.profileComplete;
    }
    
    res.json({ 
      message: 'Login successful', 
      role: user.role,
      userId: user.userId,
      profileComplete: profileComplete
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// POST /api/auth/signup
router.post('/signup', async (req, res) => {
  const { name, userId, role } = req.body;
  if (!name || !userId || !role) {
    return res.status(400).json({ message: 'Name, ID, and role are required' });
  }
  if (!['student', 'faculty'].includes(role)) {
    return res.status(400).json({ message: 'Role must be student or faculty' });
  }
  try {
    const existing = await User.findOne({ userId });
    if (existing) {
      return res.status(409).json({ message: 'User ID already exists' });
    }
    const user = new User({ name, userId, role });
    await user.save();
    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router; 