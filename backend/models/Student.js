const mongoose = require('mongoose');

const StudentSchema = new mongoose.Schema({
  // Basic Information
  name: { type: String, required: true },
  rollNumber: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  dateOfBirth: { type: Date, required: true },
  gender: { type: String, enum: ['Male', 'Female', 'Other'], required: true },
  bloodGroup: { type: String, enum: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'] },
  
  // Academic Information
  department: { type: String, required: true },
  branch: { type: String }, // New field for branch selection
  course: { type: String, required: true },
  semester: { type: Number, required: true },
  academicYear: { type: String, required: true },
  admissionDate: { type: Date, default: Date.now },
  enrollmentNumber: { type: String, unique: true },
  
  // Academic Performance
  twelfthPercentage: { type: Number },
  tenthPercentage: { type: Number },
  
  // Documents
  aadharNumber: { type: String },
  panNumber: { type: String },
  
  // User ID for profile completion
  userId: { type: String, unique: true },
  profileComplete: { type: Boolean, default: false },
  
  // Personal Information
  address: {
    street: String,
    city: String,
    state: String,
    pincode: String,
    country: { type: String, default: 'India' }
  },
  
  // Emergency Contact
  emergencyContact: {
    name: String,
    relationship: String,
    phone: String,
    email: String
  },
  
  // Parent/Guardian Information
  parent: {
    fatherName: String,
    fatherPhone: String,
    fatherEmail: String,
    motherName: String,
    motherPhone: String,
    motherEmail: String,
    guardianName: String,
    guardianPhone: String,
    guardianEmail: String
  },
  
  // Academic Details
  previousEducation: {
    institution: String,
    yearOfCompletion: Number,
    percentage: Number,
    board: String
  },
  
  // Category and Reservation
  category: { type: String, enum: ['General', 'OBC', 'SC', 'ST', 'EWS', 'Other'], default: 'General' },
  caste: { type: String, enum: ['General', 'OBC', 'SC', 'ST', 'EWS', 'NT', 'SBC'], default: 'General' },
  
  // Status and Documents
  status: { type: String, enum: ['Active', 'Inactive', 'Graduated', 'Suspended'], default: 'Active' },
  documents: [
    {
      name: String,
      type: String,
      url: String,
      uploadedAt: { type: Date, default: Date.now },
      verified: { type: Boolean, default: false }
    }
  ],
  
  // Additional Information
  hobbies: [String],
  achievements: [String],
  notes: String,
  
  // Timestamps
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// Update the updatedAt field before saving
StudentSchema.pre('save', function(next) {
  this.updatedAt = Date.now();
  next();
});

module.exports = mongoose.model('Student', StudentSchema); 