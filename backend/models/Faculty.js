const mongoose = require('mongoose');

const FacultySchema = new mongoose.Schema({
  name: { type: String, required: true },
  facultyId: { type: String, required: true, unique: true },
  department: { type: String, required: true },
  contact: { type: String, required: true },
  email: { type: String },
});

module.exports = mongoose.model('Faculty', FacultySchema); 