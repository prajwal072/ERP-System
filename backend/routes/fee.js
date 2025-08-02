const express = require('express');
const router = express.Router();
const Fee = require('../models/Fee');

// Get fee status for a student
router.get('/student/:studentId', async (req, res) => {
  try {
    const caste = req.query.caste;
    let query = { student: req.params.studentId };
    if (caste) {
      query.caste = caste;
    }
    const fees = await Fee.find(query).sort({ amount: -1 });
    res.json(fees);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Pay fee (update status)
router.put('/:feeId/pay', async (req, res) => {
  try {
    const fee = await Fee.findByIdAndUpdate(req.params.feeId, { status: 'paid' }, { new: true });
    if (!fee) return res.status(404).json({ message: 'Fee not found' });
    res.json(fee);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Get invoice
router.get('/:feeId/invoice', async (req, res) => {
  try {
    const fee = await Fee.findById(req.params.feeId);
    if (!fee) return res.status(404).json({ message: 'Fee not found' });
    res.json({ invoiceUrl: fee.invoiceUrl });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Admin endpoint: Add fees for all castes for a student
router.post('/create-for-all-castes/:studentId', async (req, res) => {
  const { semester, amounts } = req.body; // amounts: { Open: 1000, OBC: 800, ... }
  const castes = ['Open', 'OBC', 'EWS', 'ST', 'SC', 'NT'];
  try {
    const fees = await Promise.all(castes.map(caste => {
      const fee = new Fee({
        student: req.params.studentId,
        semester,
        amount: amounts[caste] || 0,
        status: 'unpaid',
        caste
      });
      return fee.save();
    }));
    res.status(201).json(fees);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

module.exports = router; 