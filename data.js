// Tank capacities [Tank1, Tank2, Tank3, Tank4, Saddle]
const models = {
  "91300": [635, 230, 140, 295, 44],
  "9950":  [465, 165, 100, 220, 44],
  "9650":  [195, 130, 130, 195, 44],
  "L9950": [220, 100, 165, 465, 44],
  "L9650": [195, 130, 130, 195, 44]
};

// Typical densities as mass per bushel (lb/bu).
// We compute kg/bu from lb/bu × 0.453592.
const products = {
  // Grains & pulses
  "Wheat": 60,
  "Durum": 60,
  "Barley": 48,
  "Oats": 32,
  "Canola": 50,
  "Flax": 56,
  "Peas": 60,
  "Lentils": 60,
  "Soybeans": 60,
  "Corn": 56,
  // Fertilizers (approximate, varies by blend and moisture)
  "Urea (46-0-0)": 48,
  "MAP (11-52-0)": 60,
  "DAP (18-46-0)": 62,
  "Ammonium Sulphate (21-0-0-24S)": 60,
  "Potash (0-0-60)": 70,
  "MESZ (12-40-0-10S-1Zn)": 61
};

module.exports = { models, products };
