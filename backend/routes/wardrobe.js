const router = require('express').Router();
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const Clothing = require('../models/Clothing');

// ── POST /api/clothes ── Upload clothing
router.post('/', auth, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Image is required' });
    }

    const { category, color, occasions, seasons } = req.body;

    if (!category) {
      return res.status(400).json({ error: 'Category is required' });
    }

    // Build image URL (served from /uploads/)
    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

    const clothing = await Clothing.create({
      user: req.user._id,
      imageUrl,
      category,
      color: color || '#FFFFFF',
      occasions: occasions ? occasions.split(',') : ['casual'],
      seasons: seasons ? seasons.split(',') : ['all'],
    });

    res.status(201).json({ clothing });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── GET /api/clothes ── List all clothes
router.get('/', auth, async (req, res) => {
  try {
    const filter = { user: req.user._id };
    if (req.query.category) {
      filter.category = req.query.category;
    }

    const clothes = await Clothing.find(filter).sort({ createdAt: -1 });
    res.json({ clothes });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── GET /api/clothes/:id ── Get single item
router.get('/:id', auth, async (req, res) => {
  try {
    const clothing = await Clothing.findOne({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!clothing) {
      return res.status(404).json({ error: 'Clothing item not found' });
    }

    res.json({ clothing });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── DELETE /api/clothes/:id ── Delete item
router.delete('/:id', auth, async (req, res) => {
  try {
    const clothing = await Clothing.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!clothing) {
      return res.status(404).json({ error: 'Clothing item not found' });
    }

    res.json({ message: 'Clothing item deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
