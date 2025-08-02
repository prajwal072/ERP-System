const mongoose = require('mongoose');

const FeeSchema = new mongoose.Schema({
  student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student', required: true },
  semester: { type: Number, required: true },
  amount: { type: Number, required: true },
  status: { type: String, enum: ['paid', 'unpaid'], required: true },
  invoiceUrl: { type: String },
  caste: { type: String, enum: ['Open', 'OBC', 'EWS', 'ST', 'SC', 'NT'], required: false },
});

module.exports = mongoose.model('Fee', FeeSchema); 