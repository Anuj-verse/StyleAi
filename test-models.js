const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
async function run() {
  const models = await genAI.getModels();
  // ... getModels does not exist maybe? Wait, let me just make a fetch call or use standard name.
}
