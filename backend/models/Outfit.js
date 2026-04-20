const mongoose = require('mongoose');

const outfitSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  items: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Clothing',
  }],
  occasion: {
    type: String,
    enum: ['casual', 'formal', 'party', 'gym'],
  },
  weather: String,
  score: {
    type: Number,
    default: 0,
  },
  isFavorite: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

outfitSchema.index({ user: 1 });

module.exports = mongoose.model('Outfit', outfitSchema);
