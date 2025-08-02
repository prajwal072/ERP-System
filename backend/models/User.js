const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  userId: { type: String, required: true, unique: true }, // rollNumber or facultyId
  role: { type: String, enum: ['student', 'faculty'], required: true },
});

module.exports = mongoose.model('User', UserSchema); 