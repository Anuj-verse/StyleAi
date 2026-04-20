const router = require('express').Router();
const axios = require('axios');

// ── GET /api/weather ── Get weather data
router.get('/', async (req, res) => {
  try {
    const { lat, lng } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ error: 'lat and lng are required' });
    }

    const apiKey = process.env.WEATHER_API_KEY;

    if (!apiKey || apiKey === 'YOUR_OPENWEATHERMAP_API_KEY') {
      // Return mock weather data if no API key configured
      return res.json({
        weather: [{ main: 'Clear', description: 'clear sky', icon: '01d' }],
        main: {
          temp: 28,
          feels_like: 30,
          humidity: 60,
        },
        name: 'Your City',
      });
    }

    const response = await axios.get(
      'https://api.openweathermap.org/data/2.5/weather',
      {
        params: {
          lat,
          lon: lng,
          appid: apiKey,
          units: 'metric',
        },
      }
    );

    res.json(response.data);
  } catch (error) {
    // Return mock data on error
    res.json({
      weather: [{ main: 'Clear', description: 'clear sky', icon: '01d' }],
      main: {
        temp: 28,
        feels_like: 30,
        humidity: 60,
      },
      name: 'Unknown',
    });
  }
});

module.exports = router;
