const router = require('express').Router();
const auth = require('../middleware/auth');
const Outfit = require('../models/Outfit');
const Clothing = require('../models/Clothing');
const { generateOutfits } = require('../services/outfitEngine');
const { generateAIOutfits } = require('../services/aiOutfitEngine');

// ── POST /api/outfits/generate ── Rule-based outfit generation
router.post('/generate', auth, async (req, res) => {
  try {
    const { occasion, useWeather, lat, lng } = req.body;

    // Fetch user's clothes
    const clothes = await Clothing.find({ user: req.user._id });

    if (clothes.length === 0) {
      return res.status(400).json({
        error: 'No clothes in wardrobe. Upload some items first!',
      });
    }

    // Get weather data if needed
    let weatherCondition = null;
    if (useWeather && lat && lng) {
      try {
        const axios = require('axios');
        const weatherRes = await axios.get(
          `https://api.openweathermap.org/data/2.5/weather`,
          {
            params: {
              lat,
              lon: lng,
              appid: process.env.WEATHER_API_KEY,
              units: 'metric',
            },
          }
        );
        const temp = weatherRes.data.main.temp;
        if (temp > 30) weatherCondition = 'hot';
        else if (temp > 20) weatherCondition = 'warm';
        else if (temp > 10) weatherCondition = 'cool';
        else weatherCondition = 'cold';
      } catch (e) {
        console.log('⚠️ Weather API error, continuing without weather filter');
      }
    }

    // Generate outfits using rule engine
    const outfits = generateOutfits(clothes, {
      occasion,
      weather: weatherCondition,
      maxResults: 6,
    });

    res.json({ outfits, mode: 'rule-based' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── POST /api/outfits/ai-generate ── AI-powered outfit generation 🤖
router.post('/ai-generate', auth, async (req, res) => {
  try {
    const { occasion, useWeather, lat, lng, userPrompt } = req.body;

    // Fetch user's clothes
    const clothes = await Clothing.find({ user: req.user._id });

    if (clothes.length === 0) {
      return res.status(400).json({
        error: 'No clothes in wardrobe. Upload some items first!',
      });
    }

    // Get weather data if needed
    let weatherCondition = null;
    if (useWeather && lat && lng) {
      try {
        const axios = require('axios');
        const weatherRes = await axios.get(
          `https://api.openweathermap.org/data/2.5/weather`,
          {
            params: {
              lat,
              lon: lng,
              appid: process.env.WEATHER_API_KEY,
              units: 'metric',
            },
          }
        );
        const temp = weatherRes.data.main.temp;
        if (temp > 30) weatherCondition = 'hot';
        else if (temp > 20) weatherCondition = 'warm';
        else if (temp > 10) weatherCondition = 'cool';
        else weatherCondition = 'cold';
      } catch (e) {
        console.log('⚠️ Weather API error, continuing without weather filter');
      }
    }

    // Generate outfits using Gemini AI
    const result = await generateAIOutfits(clothes, {
      occasion,
      weather: weatherCondition,
      maxResults: 4,
      userPrompt,
    });

    res.json({
      outfits: result.outfits,
      aiTips: result.aiTips,
      missingPieces: result.missingPieces,
      imagesAnalyzed: result.imagesAnalyzed,
      mode: 'ai',
    });
  } catch (error) {
    console.error('❌ AI generation error:', error.message);
    res.status(500).json({ error: error.message });
  }
});

// ── POST /api/outfits/save ── Save an outfit
router.post('/save', auth, async (req, res) => {
  try {
    const { items, occasion, weather } = req.body;

    const outfit = await Outfit.create({
      user: req.user._id,
      items,
      occasion,
      weather,
      isFavorite: true,
    });

    const populated = await Outfit.findById(outfit._id).populate('items');
    res.status(201).json({ outfit: populated });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── GET /api/outfits ── Get saved outfits
router.get('/', auth, async (req, res) => {
  try {
    const outfits = await Outfit.find({ user: req.user._id })
      .populate('items')
      .sort({ createdAt: -1 });
    res.json({ outfits });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ── DELETE /api/outfits/:id ── Delete outfit
router.delete('/:id', auth, async (req, res) => {
  try {
    const outfit = await Outfit.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });

    if (!outfit) {
      return res.status(404).json({ error: 'Outfit not found' });
    }

    res.json({ message: 'Outfit deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
