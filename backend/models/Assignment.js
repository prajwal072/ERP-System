const mongoose = require('mongoose');

const SubmissionSchema = new mongoose.Schema({
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  fileUrl: { type: String, required: true },
  submittedAt: { type: Date, default: Date.now }
});

const AssignmentSchema = new mongoose.Schema({
  title: { type: String, required: true },
  description: { type: String },
  subject: { type: String, required: true },
  dueDate: { type: Date, required: true },
  faculty: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  submissions: [SubmissionSchema]
});

module.exports = mongoose.model('Assignment', AssignmentSchema); 