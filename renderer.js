const { ipcRenderer } = require('electron');
const data = require('./data');
const allocator = require('./lib/allocator');

const LBS_TO_KG = 0.453592;
const AC_TO_HA = 0.404685642;

const state = {
  unitSystem: 'imperial', // 'imperial' or 'metric'
  model: '91300',
  fieldSize: 160,
  products: [] // [{ name, rate }] rate in current unit system
};

function $(id) { return document.getElementById(id); }

function formatNumber(x, digits = 2) {
  return Number(x).toLocaleString(undefined, { maximumFractionDigits: digits });
}

function setupCatalog() {
  const catalog = $('productCatalog');
  catalog.innerHTML = '';
  Object.keys(data.products).forEach(p => {
    const opt = document.createElement('option');
    opt.value = p;
    opt.textContent = `${p} (${data.products[p]} lb/bu)`;
    catalog.appendChild(opt);
  });
}

function renderProducts() {
  const container = $('productRows');
  container.innerHTML = '';
  if (state.products.length === 0) {
    container.innerHTML = '<div class="muted">No products added yet.</div>';
    return;
  }
  state.products.forEach((p, idx) => {
    const row = document.createElement('div');
    row.className = 'product-row';
    const unitRate = state.unitSystem === 'imperial' ? 'lb/ac' : 'kg/ha';
    row.innerHTML = `
      <div><strong>${p.name}</strong> <span class="muted">(${data.products[p.name]} lb/bu)</span></div>
      <input type="number" step="0.01" min="0" value="${p.rate}" data-idx="${idx}" class="rate-input" />
      <div class="tag">${unitRate}</div>
      <button data-idx="${idx}" class="remove-btn danger">Remove</button>
    `;
    container.appendChild(row);
  });

  document.querySelectorAll('.rate-input').forEach(inp => {
    inp.addEventListener('input', (e) => {
      const i = parseInt(e.target.getAttribute('data-idx'), 10);
      state.products[i].rate = parseFloat(e.target.value || '0');
    });
  });
  document.querySelectorAll('.remove-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      const i = parseInt(e.target.getAttribute('data-idx'), 10);
      state.products.splice(i, 1);
      renderProducts();
    });
  });
}

function setUnitLabels() {
  $('areaUnit').textContent = state.unitSystem === 'imperial' ? 'ac' : 'ha';
}

function convertExistingRates(toSystem) {
  if (state.unitSystem === toSystem) return;
  // Convert product rates between lb/ac and kg/ha (1 lb/ac = 1.12085 kg/ha)
  const factor = 1.120849; // kg/ha per lb/ac
  state.products = state.products.map(p => ({
    ...p,
    rate: toSystem === 'metric' ? p.rate * factor : p.rate / factor
  }));
  // Convert field size between acres and hectares
  state.fieldSize = parseFloat($('fieldSize').value || '0');
  state.fieldSize = toSystem === 'metric' ? state.fieldSize * AC_TO_HA : state.fieldSize / AC_TO_HA;
  $('fieldSize').value = state.fieldSize.toFixed(2);
}

function computeBushelsNeeded(rate, area, name) {
  // rate and area units depend on unit system
  // densities: lb/bu known; derive kg/bu when needed
  const lbPerBu = data.products[name];
  const kgPerBu = lbPerBu * LBS_TO_KG;

  if (state.unitSystem === 'imperial') {
    // bu = (lb/ac * ac) / (lb/bu)
    return (rate * area) / lbPerBu;
  } else {
    // bu = (kg/ha * ha) / (kg/bu)
    return (rate * area) / kgPerBu;
  }
}

function buildTankList(modelKey) {
  const caps = data.models[modelKey]; // [T1, T2, T3, T4, Saddle]
  const labels = ['Tank 1', 'Tank 2', 'Tank 3', 'Tank 4', 'Saddle'];
  const tanks = caps.map((c, i) => ({ label: labels[i], capacity: c, index: i }));
  // Sort by capacity descending for greedy allocation
  tanks.sort((a, b) => b.capacity - a.capacity);
  return tanks;
}

function calculatePlan() {
  const model = $('model').value;
  const area = parseFloat($('fieldSize').value || '0');
  if (!model || area <= 0 || state.products.length === 0) {
    return { errors: ['Enter a valid field size and at least one product.'] };
  }

  // Build product objects for allocator
  const productsForAlloc = state.products.map(p => ({
    name: p.name,
    rate: p.rate,
    area,
    lbPerBu: data.products[p.name]
  }));

  const caps = data.models[model];
  const allocation = allocator.allocate(caps, productsForAlloc, state.unitSystem);
  if (allocation.errors) return { errors: allocation.errors };

  return {
    model,
    area,
    productsBu: allocation.productsBu,
    plan: allocation.plan,
    utilizationPct: allocation.utilizationPct
  };
}

function renderResults(result) {
  const container = $('results');
  if (result.errors) {
    container.innerHTML = `<div class="danger tag">${result.errors.join(' ')}</div>`;
    return;
  }

  let html = '';
  html += `<h3>Tank allocation</h3>`;
  html += `<div class="muted">Cart utilization: ${formatNumber(result.utilizationPct, 1)}% of total volume.</div>`;
  html += `<table><thead><tr><th>Tank</th><th>Capacity (bu)</th><th>Product</th><th>Fill (bu)</th><th>Fill (%)</th></tr></thead><tbody>`;
  result.plan.forEach(r => {
    const cap = r.capacity ? formatNumber(r.capacity, 0) : '-';
    const fill = formatNumber(r.fillBu, 1);
    const pct = r.capacity ? formatNumber(r.fillPct, 0) + '%' : '-';
    const rowClass = r.tankLabel === 'UNALLOCATED' ? ' style="background:#fee;"' : '';
    html += `<tr${rowClass}><td>${r.tankLabel}</td><td>${cap}</td><td>${r.product}</td><td>${fill}</td><td>${pct}</td></tr>`;
  });
  html += `</tbody></table>`;

  html += `<h4>Product totals</h4>`;
  html += `<table><thead><tr><th>Product</th><th>Rate (${state.unitSystem === 'imperial' ? 'lb/ac' : 'kg/ha'})</th><th>Bushels needed</th></tr></thead><tbody>`;
  result.productsBu.forEach(p => {
    html += `<tr><td>${p.name}</td><td>${formatNumber(p.rate, 2)}</td><td>${formatNumber(p.bu, 2)}</td></tr>`;
  });
  html += `</tbody></table>`;

  container.innerHTML = html;
}

function savePlanToHistory(result) {
  const id = Date.now().toString();
  const payload = {
    id,
    name: $('planName').value || `Plan ${new Date().toLocaleString()}`,
    timestamp: new Date().toISOString(),
    unitSystem: state.unitSystem,
    model: result.model,
    fieldSize: result.area,
    products: JSON.parse(JSON.stringify(state.products)),
    results: result
  };
  ipcRenderer.send('history:save', payload);
}

function loadHistory() {
  ipcRenderer.send('history:list');
}

function renderHistory(items) {
  const box = $('history-list');
  if (!items || items.length === 0) {
    box.innerHTML = '<div class="muted">No saved optimizations yet.</div>';
    return;
  }
  items.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp));
  box.innerHTML = items.map(item => {
    const date = new Date(item.timestamp).toLocaleString();
    return `
      <div style="border:1px solid #ddd; padding:8px; margin-bottom:8px; background:#fff;">
        <div><strong>${item.name}</strong></div>
        <div class="muted small">${date}</div>
        <div class="small">Model: ${item.model} • Units: ${item.unitSystem}</div>
        <div class="actions" style="margin-top:6px;">
          <button data-id="${item.id}" class="load-btn">Load</button>
          <button data-id="${item.id}" class="export-btn">Export</button>
          <button data-id="${item.id}" class="delete-btn danger">Delete</button>
        </div>
      </div>
    `;
  }).join('');

  box.querySelectorAll('.load-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const id = btn.getAttribute('data-id');
      ipcRenderer.send('history:list'); // refresh, then load specific
      ipcRenderer.once('history:list:result', (evt, list) => {
        const item = list.find(i => i.id === id);
        if (!item) return;
        // Load into form
        state.unitSystem = item.unitSystem;
        $('unitSystem').value = item.unitSystem;
        setUnitLabels();
        state.model = item.model;
        $('model').value = item.model;
        $('planName').value = item.name;
        $('fieldSize').value = item.fieldSize;
        state.products = item.products;
        renderProducts();
        const calc = calculatePlan();
        renderResults(calc);
      });
    });
  });

  box.querySelectorAll('.export-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const id = btn.getAttribute('data-id');
      ipcRenderer.send('history:export', id);
    });
  });

  box.querySelectorAll('.delete-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const id = btn.getAttribute('data-id');
      if (confirm('Delete this optimization?')) {
        ipcRenderer.send('history:delete', id);
      }
    });
  });
}

window.onload = () => {
  // Populate models
  const modelSel = $('model');
  Object.keys(data.models).forEach(m => {
    const opt = document.createElement('option');
    opt.value = m;
    opt.textContent = `${m} (${data.models[m].reduce((a, b) => a + b, 0)} bu total)`;
    modelSel.appendChild(opt);
  });
  modelSel.value = state.model;

  // Catalog
  setupCatalog();

  // Handlers
  $('unitSystem').addEventListener('change', (e) => {
    const toSystem = e.target.value;
    convertExistingRates(toSystem);
    state.unitSystem = toSystem;
    setUnitLabels();
    renderProducts();
  });

  $('model').addEventListener('change', (e) => {
    state.model = e.target.value;
  });

  $('fieldSize').addEventListener('input', (e) => {
    state.fieldSize = parseFloat(e.target.value || '0');
  });

  $('addProduct').addEventListener('click', () => {
    const name = $('productCatalog').value;
    const rate = parseFloat(($('productRate').value || '0').trim());
    if (!name || isNaN(rate) || rate <= 0) return;
    state.products.push({ name, rate });
    $('productRate').value = '';
    renderProducts();
  });

  $('calculate').addEventListener('click', () => {
    const result = calculatePlan();
    renderResults(result);
  });

  $('savePlan').addEventListener('click', () => {
    const result = calculatePlan();
    if (result.errors) {
      renderResults(result);
      return;
    }
    savePlanToHistory(result);
  });

  ipcRenderer.on('history:list:result', (evt, items) => renderHistory(items));
  ipcRenderer.on('history:save:result', (evt, res) => {
    alert(res.message || 'Saved');
    loadHistory();
  });
  ipcRenderer.on('history:delete:result', () => loadHistory());
  ipcRenderer.on('history:export:result', (evt, res) => {
    if (res.ok) alert('Exported');
  });

  // Initial UI
  $('fieldSize').value = state.fieldSize;
  setUnitLabels();
  renderProducts();
  loadHistory();
};
