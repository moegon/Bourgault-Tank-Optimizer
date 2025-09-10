const LBS_TO_KG = 0.453592;
const AC_TO_HA = 0.404685642;

function computeBushelsNeeded(rate, area, unitSystem, lbPerBu) {
  const kgPerBu = lbPerBu * LBS_TO_KG;
  if (unitSystem === 'imperial') {
    return (rate * area) / lbPerBu;
  }
  return (rate * area) / kgPerBu;
}

function buildTankList(caps) {
  const labels = ['Tank 1', 'Tank 2', 'Tank 3', 'Tank 4', 'Saddle'];
  const tanks = caps.map((c, i) => ({ label: labels[i] || `Tank ${i+1}`, capacity: c, index: i }));
  tanks.sort((a, b) => b.capacity - a.capacity);
  return tanks;
}

function allocate(modelCaps, products, unitSystem) {
  // products: [{ name, rate, lbPerBu }]
  if (!modelCaps || !products || products.length === 0) return { errors: ['Invalid input'] };

  const productsBu = products.map(p => ({
    name: p.name,
    rate: p.rate,
    bu: computeBushelsNeeded(p.rate, p.area, unitSystem, p.lbPerBu)
  }));

  productsBu.sort((a, b) => b.bu - a.bu);

  const tanks = buildTankList(modelCaps);
  const plan = [];
  let tankPtr = 0;

  for (const prod of productsBu) {
    let remaining = prod.bu;
    while (remaining > 0 && tankPtr < tanks.length) {
      const t = tanks[tankPtr];
      const fill = Math.min(t.capacity, remaining);
      plan.push({ tankLabel: t.label, capacity: t.capacity, product: prod.name, fillBu: fill, fillPct: (fill / t.capacity) * 100 });
      remaining -= fill;
      tankPtr++;
    }
    if (remaining > 0) {
      plan.push({ tankLabel: 'UNALLOCATED', capacity: 0, product: prod.name, fillBu: remaining, fillPct: 0 });
    }
  }

  const totalCapacity = modelCaps.reduce((a, b) => a + b, 0);
  const totalBuNeeded = productsBu.reduce((a, b) => a + b.bu, 0);
  const utilizationPct = Math.min(100, (totalBuNeeded / totalCapacity) * 100);

  return { productsBu, plan, utilizationPct };
}

module.exports = { allocate, computeBushelsNeeded, buildTankList };
