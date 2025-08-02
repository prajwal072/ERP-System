const express = require('express');
const router = express.Router();
const Student = require('../models/Student');

// Middleware for faculty/admin authentication
async function requireFaculty(req, res, next) {
  const token = req.headers['x-auth-token'];
  if (!token) return res.status(401).json({ message: 'No token provided' });
  const User = require('../models/User');
  const user = await User.findOne({ userId: token });
  if (!user || (user.role !== 'faculty' && user.role !== 'admin')) {
    return res.status(403).json({ message: 'Access denied' });
  }
  req.user = user;
  next();
}

// Create new student (faculty/admin only)
router.post('/', requireFaculty, async (req, res) => {
  try {
    // Generate enrollment number if not provided
    if (!req.body.enrollmentNumber) {
      const year = new Date().getFullYear();
      const count = await Student.countDocuments({ academicYear: year.toString() });
      req.body.enrollmentNumber = `EN${year}${(count + 1).toString().padStart(4, '0')}`;
    }
    
    const student = new Student(req.body);
    await student.save();
    res.status(201).json(student);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Get all students with filtering and pagination
router.get('/', async (req, res) => {
  try {
    const { 
      page = 1, 
      limit = 10, 
      search, 
      department, 
      semester, 
      status,
      category 
    } = req.query;
    
    const filter = {};
    
    // Search functionality
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: 'i' } },
        { rollNumber: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
        { enrollmentNumber: { $regex: search, $options: 'i' } }
      ];
    }
    
    // Filter by department
    if (department) filter.department = department;
    
    // Filter by semester
    if (semester) filter.semester = parseInt(semester);
    
    // Filter by status
    if (status) filter.status = status;
    
    // Filter by category
    if (category) filter.category = category;
    
    const skip = (page - 1) * limit;
    
    const students = await Student.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));
    
    const total = await Student.countDocuments(filter);
    
    res.json({
      students,
      pagination: {
        currentPage: parseInt(page),
        totalPages: Math.ceil(total / limit),
        totalStudents: total,
        hasNext: page * limit < total,
        hasPrev: page > 1
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get student by ID
router.get('/:id', async (req, res) => {
  try {
    const student = await Student.findById(req.params.id);
    if (!student) return res.status(404).json({ message: 'Student not found' });
    res.json(student);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Update student (faculty/admin only)
router.put('/:id', requireFaculty, async (req, res) => {
  try {
    const student = await Student.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true, runValidators: true }
    );
    if (!student) return res.status(404).json({ message: 'Student not found' });
    res.json(student);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete student (admin only)
router.delete('/:id', requireFaculty, async (req, res) => {
  try {
    const student = await Student.findByIdAndDelete(req.params.id);
    if (!student) return res.status(404).json({ message: 'Student not found' });
    res.json({ message: 'Student deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Get student statistics
router.get('/stats/overview', async (req, res) => {
  try {
    const totalStudents = await Student.countDocuments();
    const activeStudents = await Student.countDocuments({ status: 'Active' });
    const graduatedStudents = await Student.countDocuments({ status: 'Graduated' });
    const inactiveStudents = await Student.countDocuments({ status: 'Inactive' });
    
    // Department-wise distribution
    const departmentStats = await Student.aggregate([
      { $group: { _id: '$department', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);
    
    // Semester-wise distribution
    const semesterStats = await Student.aggregate([
      { $group: { _id: '$semester', count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    
    res.json({
      totalStudents,
      activeStudents,
      graduatedStudents,
      inactiveStudents,
      departmentStats,
      semesterStats
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Search students by roll number or email
router.get('/search/:query', async (req, res) => {
  try {
    const { query } = req.params;
    const students = await Student.find({
      $or: [
        { rollNumber: { $regex: query, $options: 'i' } },
        { email: { $regex: query, $options: 'i' } },
        { enrollmentNumber: { $regex: query, $options: 'i' } }
      ]
    }).limit(10);
    
    res.json(students);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Bulk operations
router.post('/bulk/import', requireFaculty, async (req, res) => {
  try {
    const { students } = req.body;
    const results = [];
    
    for (const studentData of students) {
      try {
        const student = new Student(studentData);
        await student.save();
        results.push({ success: true, student });
      } catch (err) {
        results.push({ success: false, error: err.message, data: studentData });
      }
    }
    
    res.json({ results });
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update student status
router.patch('/:id/status', requireFaculty, async (req, res) => {
  try {
    const { status } = req.body;
    const student = await Student.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    if (!student) return res.status(404).json({ message: 'Student not found' });
    res.json(student);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

module.exports = router; 