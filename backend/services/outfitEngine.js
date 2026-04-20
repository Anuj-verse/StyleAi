/**
 * 🧠 StyleAI Outfit Engine
 * 
 * Rule-based outfit generation with color matching and scoring.
 * Generates valid combinations from a user's wardrobe.
 */

// ── Color Harmony Rules ──
const colorHarmony = {
  '#6C63FF': ['#F5F5F5', '#333333', '#9E9E9E', '#FFEB3B'],   // Purple
  '#FF5252': ['#333333', '#F5F5F5', '#4A90D9', '#1A1A3E'],   // Red
  '#4A90D9': ['#F5F5F5', '#333333', '#FFAB40', '#8D6E63'],   // Blue
  '#00E676': ['#333333', '#F5F5F5', '#1A1A3E'],               // Green
  '#333333': ['#F5F5F5', '#FF5252', '#4A90D9', '#6C63FF', '#FFEB3B', '#FF6584'], // Black
  '#F5F5F5': ['#333333', '#4A90D9', '#6C63FF', '#FF5252', '#1A1A3E'],           // White
  '#FF6584': ['#333333', '#F5F5F5', '#1A1A3E', '#4A90D9'],   // Pink
  '#FFAB40': ['#333333', '#1A1A3E', '#4A90D9'],               // Orange
  '#1A1A3E': ['#F5F5F5', '#FFAB40', '#FF6584', '#00D9FF'],   // Navy
  '#8D6E63': ['#F5F5F5', '#4A90D9', '#333333'],               // Brown
  '#FFEB3B': ['#333333', '#1A1A3E', '#4A90D9'],               // Yellow
  '#9E9E9E': ['#333333', '#F5F5F5', '#6C63FF', '#4A90D9'],   // Grey
};

// ── Season → Weather mapping ──
const weatherSeasonMap = {
  hot: ['summer', 'all'],
  warm: ['summer', 'all'],
  cool: ['winter', 'all'],
  cold: ['winter', 'all'],
  rainy: ['rainy', 'all'],
};

/**
 * Calculate color harmony score between two hex colors
 */
function colorScore(color1, color2) {
  if (color1 === color2) return 0.5; // Same color — neutral
  const harmonious = colorHarmony[color1] || [];
  if (harmonious.includes(color2)) return 1.0; // Great match
  return 0.3; // Default
}

/**
 * Calculate occasion match score
 */
function occasionScore(item, targetOccasion) {
  if (!targetOccasion) return 0.5;
  if (item.occasions && item.occasions.includes(targetOccasion)) return 1.0;
  return 0.2;
}

/**
 * Generate outfit combinations
 * @param {Array} clothes - All user clothing items
 * @param {Object} options - { occasion, weather, maxResults }
 * @returns {Array} - Sorted outfit combinations
 */
function generateOutfits(clothes, options = {}) {
  const { occasion, weather, maxResults = 6 } = options;

  // Categorize items
  let tops = clothes.filter(c => c.category === 'top');
  let bottoms = clothes.filter(c => c.category === 'bottom');
  let shoes = clothes.filter(c => c.category === 'shoes');
  let accessories = clothes.filter(c => c.category === 'accessories');

  // ── Weather Filter ──
  if (weather) {
    const validSeasons = weatherSeasonMap[weather] || ['all'];
    const weatherFilter = (items) =>
      items.filter(item =>
        item.seasons && item.seasons.some(s => validSeasons.includes(s))
      );

    const filteredTops = weatherFilter(tops);
    const filteredBottoms = weatherFilter(bottoms);
    const filteredShoes = weatherFilter(shoes);

    // Only use filtered if they have items
    if (filteredTops.length > 0) tops = filteredTops;
    if (filteredBottoms.length > 0) bottoms = filteredBottoms;
    if (filteredShoes.length > 0) shoes = filteredShoes;
  }

  // ── Occasion Filter ──
  if (occasion) {
    const occasionFilter = (items) =>
      items.filter(item =>
        item.occasions && item.occasions.includes(occasion)
      );

    const filteredTops = occasionFilter(tops);
    const filteredBottoms = occasionFilter(bottoms);

    if (filteredTops.length > 0) tops = filteredTops;
    if (filteredBottoms.length > 0) bottoms = filteredBottoms;
  }

  // Edge case: need at least 1 top and 1 bottom
  if (tops.length === 0 || bottoms.length === 0) {
    return [];
  }

  // ── Generate Combinations ──
  const outfits = [];

  for (const top of tops) {
    for (const bottom of bottoms) {
      // Base score from color harmony
      let score = colorScore(top.color, bottom.color);

      // Add occasion score
      score += occasionScore(top, occasion) * 0.3;
      score += occasionScore(bottom, occasion) * 0.3;

      // Pick best matching shoe
      let bestShoe = null;
      let bestShoeScore = 0;

      for (const shoe of shoes) {
        const shoeColorScore =
          (colorScore(top.color, shoe.color) +
            colorScore(bottom.color, shoe.color)) /
          2;
        const shoeOccScore = occasionScore(shoe, occasion) * 0.2;
        const totalShoeScore = shoeColorScore + shoeOccScore;

        if (totalShoeScore > bestShoeScore) {
          bestShoeScore = totalShoeScore;
          bestShoe = shoe;
        }
      }

      if (bestShoe) {
        score += bestShoeScore * 0.2;
      }

      // Pick best accessory (optional)
      let bestAccessory = null;
      if (accessories.length > 0) {
        bestAccessory = accessories[Math.floor(Math.random() * accessories.length)];
        score += 0.05;
      }

      // Normalize score to 0-1
      const normalizedScore = Math.min(score / 2.5, 1.0);

      const items = [top, bottom];
      if (bestShoe) items.push(bestShoe);
      if (bestAccessory) items.push(bestAccessory);

      outfits.push({
        _id: `${top._id}-${bottom._id}-${Date.now()}`,
        items,
        occasion: occasion || null,
        weather: weather || null,
        score: normalizedScore,
        isFavorite: false,
        createdAt: new Date().toISOString(),
      });
    }
  }

  // Sort by score descending and return top N
  outfits.sort((a, b) => b.score - a.score);
  return outfits.slice(0, maxResults);
}

module.exports = { generateOutfits };
