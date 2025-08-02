const mongoose = require('mongoose');

const ExamSchema = new mongoose.Schema({
  course: { type: String, required: true },
  subject: { type: String, required: true },
  date: { type: Date, required: true },
  type: { type: String, enum: ['midterm', 'final', 'backlog'], required: true },
});

module.exports = mongoose.model('Exam', ExamSchema); 