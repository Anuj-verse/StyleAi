/**
 * 🤖 StyleAI — Gemini AI Outfit Engine
 *
 * Uses Google Gemini to analyze wardrobe images and generate
 * intelligent outfit recommendations with styling tips.
 */

const { GoogleGenerativeAI } = require('@google/generative-ai');
const fs = require('fs');
const path = require('path');

/**
 * Convert an image file to a Gemini-compatible part
 */
function imageToGenerativePart(imagePath) {
  try {
    // Extract the actual file path from URL
    let filePath = imagePath;
    if (imagePath.includes('/uploads/')) {
      const filename = imagePath.split('/uploads/').pop();
      filePath = path.join(__dirname, '..', 'uploads', filename);
    }

    if (!fs.existsSync(filePath)) {
      return null;
    }

    const imageData = fs.readFileSync(filePath);
    const ext = path.extname(filePath).toLowerCase();
    const mimeTypes = {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.gif': 'image/gif',
    };

    return {
      inlineData: {
        data: imageData.toString('base64'),
        mimeType: mimeTypes[ext] || 'image/jpeg',
      },
    };
  } catch (error) {
    console.log(`⚠️ Could not read image: ${imagePath}`, error.message);
    return null;
  }
}

/**
 * Build a text description of a clothing item (fallback when image unavailable)
 */
function describeItem(item) {
  const colorNames = {
    '#6C63FF': 'purple', '#FF5252': 'red', '#4A90D9': 'blue',
    '#00E676': 'green', '#333333': 'black', '#F5F5F5': 'white',
    '#FF6584': 'pink', '#FFAB40': 'orange', '#1A1A3E': 'navy',
    '#8D6E63': 'brown', '#FFEB3B': 'yellow', '#9E9E9E': 'grey',
  };

  const color = colorNames[item.color] || item.color || 'unknown color';
  const occasions = (item.occasions || []).join(', ') || 'general';
  const seasons = (item.seasons || []).join(', ') || 'all seasons';

  return `[ID: ${item._id}] ${color} ${item.category} — suitable for: ${occasions} | seasons: ${seasons}`;
}

/**
 * Generate AI-powered outfit recommendations using Gemini
 *
 * @param {Array} clothes - All user clothing items from DB
 * @param {Object} options - { occasion, weather, maxResults, userPrompt }
 * @returns {Object} - { outfits: [...], aiTips: "...", reasoning: "..." }
 */
async function generateAIOutfits(clothes, options = {}) {
  const { occasion, weather, maxResults = 4, userPrompt } = options;

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey || apiKey === 'YOUR_GEMINI_API_KEY') {
    throw new Error('Gemini API key not configured. Add GEMINI_API_KEY to your .env file.');
  }

  const genAI = new GoogleGenerativeAI(apiKey);

  // Categorize clothes
  const tops = clothes.filter(c => c.category === 'top');
  const bottoms = clothes.filter(c => c.category === 'bottom');
  const shoes = clothes.filter(c => c.category === 'shoes');
  const accessories = clothes.filter(c => c.category === 'accessories');

  if (tops.length === 0 || bottoms.length === 0) {
    throw new Error('Need at least 1 top and 1 bottom to generate outfits.');
  }

  // ── Build prompt parts ──
  const parts = [];

  // System prompt
  const systemPrompt = `You are StyleAI, an expert fashion stylist AI. You analyze clothing items and create perfectly coordinated outfit combinations.

WARDROBE INVENTORY:
===================
TOPS (${tops.length} items):
${tops.map((t, i) => `  ${i + 1}. ${describeItem(t)}`).join('\n')}

BOTTOMS (${bottoms.length} items):
${bottoms.map((b, i) => `  ${i + 1}. ${describeItem(b)}`).join('\n')}

SHOES (${shoes.length} items):
${shoes.map((s, i) => `  ${i + 1}. ${describeItem(s)}`).join('\n')}

ACCESSORIES (${accessories.length} items):
${accessories.map((a, i) => `  ${i + 1}. ${describeItem(a)}`).join('\n')}

FILTERS:
${occasion ? `- Occasion: ${occasion}` : '- No specific occasion'}
${weather ? `- Weather: ${weather}` : '- No weather filter'}
${userPrompt ? `- User request: "${userPrompt}"` : ''}

TASK:
Generate exactly ${maxResults} outfit combinations. Each outfit MUST have:
- 1 top (required)
- 1 bottom (required)
- 1 pair of shoes (if available)
- 1 accessory (optional, if available and fits)

For each outfit, explain WHY the pieces work together (color theory, style coherence, occasion fit).

RESPOND IN THIS EXACT JSON FORMAT (no markdown, no code blocks, just raw JSON):
{
  "outfits": [
    {
      "topId": "<exact _id of the top>",
      "bottomId": "<exact _id of the bottom>",
      "shoesId": "<exact _id of shoes or null>",
      "accessoryId": "<exact _id of accessory or null>",
      "score": <0.0-1.0 match score>,
      "reasoning": "<why this combo works — 1-2 sentences>",
      "stylingTip": "<practical styling tip for wearing this outfit>"
    }
  ],
  "overallTips": "<2-3 general wardrobe tips based on what you see>",
  "missingPieces": "<what items would improve their wardrobe — 1 sentence>"
}`;

  parts.push(systemPrompt);

  // ── Try to include clothing images for visual analysis ──
  const allItems = [...tops, ...bottoms, ...shoes, ...accessories];
  let imagesIncluded = 0;
  const maxImages = 10; // Limit to avoid token overflow

  for (const item of allItems) {
    if (imagesIncluded >= maxImages) break;
    if (item.imageUrl) {
      const imagePart = imageToGenerativePart(item.imageUrl);
      if (imagePart) {
        parts.push(`\n[Image of ${item.category} — ID: ${item._id}]:`);
        parts.push(imagePart);
        imagesIncluded++;
      }
    }
  }

  if (imagesIncluded > 0) {
    parts.push(`\n\n(${imagesIncluded} clothing images provided above for visual analysis. Use them to make better color and style matching decisions.)`);
  }

  // ── Call Gemini ──
  console.log(`🤖 Calling Gemini AI with ${clothes.length} items, ${imagesIncluded} images...`);

  const model = genAI.getGenerativeModel({ model: 'gemini-3-flash-preview' });

  const result = await model.generateContent(parts);
  const responseText = result.response.text();

  console.log('🤖 Gemini raw response:', responseText.substring(0, 200) + '...');

  // ── Parse response ──
  let aiResponse;
  try {
    // Clean up the response - remove markdown code blocks if present
    let cleanJson = responseText.trim();
    if (cleanJson.startsWith('```')) {
      cleanJson = cleanJson.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '');
    }
    aiResponse = JSON.parse(cleanJson);
  } catch (parseError) {
    console.error('❌ Failed to parse Gemini response:', parseError.message);
    console.error('Raw response:', responseText);
    throw new Error('AI returned an invalid response. Try again.');
  }

  // ── Build outfit objects ──
  const clothesMap = {};
  clothes.forEach(c => {
    clothesMap[c._id.toString()] = c;
  });

  const outfits = [];

  for (const aiOutfit of (aiResponse.outfits || [])) {
    const items = [];
    const top = clothesMap[aiOutfit.topId];
    const bottom = clothesMap[aiOutfit.bottomId];

    if (!top || !bottom) {
      console.log('⚠️ Skipping outfit — top or bottom not found in wardrobe');
      continue;
    }

    items.push(top);
    items.push(bottom);

    if (aiOutfit.shoesId && clothesMap[aiOutfit.shoesId]) {
      items.push(clothesMap[aiOutfit.shoesId]);
    }
    if (aiOutfit.accessoryId && clothesMap[aiOutfit.accessoryId]) {
      items.push(clothesMap[aiOutfit.accessoryId]);
    }

    outfits.push({
      _id: `ai-${top._id}-${bottom._id}-${Date.now()}`,
      items,
      occasion: occasion || null,
      weather: weather || null,
      score: Math.min(Math.max(aiOutfit.score || 0.7, 0), 1),
      isFavorite: false,
      reasoning: aiOutfit.reasoning || '',
      stylingTip: aiOutfit.stylingTip || '',
      createdAt: new Date().toISOString(),
    });
  }

  return {
    outfits,
    aiTips: aiResponse.overallTips || '',
    missingPieces: aiResponse.missingPieces || '',
    imagesAnalyzed: imagesIncluded,
  };
}

module.exports = { generateAIOutfits };
