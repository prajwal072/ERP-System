const mongoose = require('mongoose');

const ResultSchema = new mongoose.Schema({
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  exam: { type: mongoose.Schema.Types.ObjectId, ref: 'Exam', required: true },
  marks: { type: Number, required: true },
  grade: { type: String },
});

module.exports = mongoose.model('Result', ResultSchema); 