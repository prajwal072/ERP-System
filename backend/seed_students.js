const mongoose = require('mongoose');
const Student = require('./models/Student');
const User = require('./models/User');
const Fee = require('./models/Fee');

mongoose.connect('mongodb://localhost:27017/college_erp', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function seed() {
  const studentsData = [
    {
      name: 'ashu.ashish',
      dob: new Date('2000-01-01'),
      gender: 'Male',
      contact: '1234567890',
      branch: 'CSE',
      semester: 1,
      rollNumber: '67890',
      caste: 'OBC',
      documents: []
    },
    {
      name: 'ashu.ashish',
      dob: new Date('2000-01-01'),
      gender: 'Male',
      contact: '1234567891',
      branch: 'CSE',
      semester: 1,
      rollNumber: '24680',
      caste: 'SC',
      documents: []
    }
  ];
  const userData = [
    { name: 'ashu.ashish', userId: '67890', role: 'student' },
    { name: 'ashu.ashish', userId: '24680', role: 'student' }
  ];
  const feeAmounts = { Open: 1000, OBC: 800, EWS: 700, ST: 600, SC: 500, NT: 400 };
  try {
    await Student.deleteMany({ rollNumber: { $in: ['67890', '24680'] } });
    await User.deleteMany({ userId: { $in: ['67890', '24680'] } });
    await Fee.deleteMany({ student: { $exists: true } });
    const students = await Student.insertMany(studentsData);
    await User.insertMany(userData);
    for (const student of students) {
      for (const caste of Object.keys(feeAmounts)) {
        await Fee.create({
          student: student._id,
          semester: 1,
          amount: feeAmounts[caste],
          status: 'unpaid',
          caste
        });
      }
    }
    console.log('Seeded students, users, and fees.');
  } catch (err) {
    console.error(err);
  } finally {
    mongoose.disconnect();
  }
}

seed(); 