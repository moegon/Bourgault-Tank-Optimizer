const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs');

const HISTORY_FILE = () => path.join(app.getPath('documents'), 'tank_optimizations.json');

function ensureHistoryFile() {
  const filePath = HISTORY_FILE();
  if (!fs.existsSync(filePath)) {
    fs.writeFileSync(filePath, JSON.stringify([], null, 2));
  }
  return filePath;
}

function readHistory() {
  const file = ensureHistoryFile();
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    return [];
  }
}

function writeHistory(items) {
  const file = ensureHistoryFile();
  fs.writeFileSync(file, JSON.stringify(items, null, 2));
}

function createWindow() {
  const win = new BrowserWindow({
    width: 1100,
    height: 780,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });
  win.loadFile('index.html');
}

app.whenReady().then(() => {
  createWindow();
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

/* IPC: Save, list, load, delete, export */
ipcMain.on('history:list', (event) => {
  event.reply('history:list:result', readHistory());
});

ipcMain.on('history:save', (event, payload) => {
  const history = readHistory();
  history.push(payload);
  writeHistory(history);
  event.reply('history:save:result', { ok: true, message: 'Optimization saved.' });
});

ipcMain.on('history:delete', (event, id) => {
  const history = readHistory();
  const filtered = history.filter(item => item.id !== id);
  writeHistory(filtered);
  event.reply('history:delete:result', { ok: true });
});

ipcMain.on('history:export', async (event, id) => {
  const history = readHistory();
  const item = history.find(h => h.id === id);
  if (!item) return event.reply('history:export:result', { ok: false, message: 'Not found' });

  const result = await dialog.showSaveDialog({
    title: 'Export Optimization',
    defaultPath: `optimization-${id}.json`,
    filters: [{ name: 'JSON', extensions: ['json'] }]
  });
  if (result.canceled || !result.filePath) {
    return event.reply('history:export:result', { ok: false, message: 'Canceled' });
  }
  fs.writeFileSync(result.filePath, JSON.stringify(item, null, 2));
  event.reply('history:export:result', { ok: true, message: 'Exported' });
});


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
