const mongoose = require('mongoose');

const clothingSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  imageUrl: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
    enum: ['top', 'bottom', 'shoes', 'accessories'],
  },
  color: {
    type: String,
    default: '#FFFFFF',
  },
  occasions: [{
    type: String,
    enum: ['casual', 'formal', 'party', 'gym'],
  }],
  seasons: [{
    type: String,
    enum: ['summer', 'winter', 'rainy', 'all'],
  }],
}, {
  timestamps: true,
});

// Index for faster queries
clothingSchema.index({ user: 1, category: 1 });

module.exports = mongoose.model('Clothing', clothingSchema);
