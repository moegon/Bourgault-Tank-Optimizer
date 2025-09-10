const { expect } = require('chai');
const allocator = require('../lib/allocator');

describe('allocator.allocate', () => {
  it('allocates within capacity', () => {
    const model = [100, 100, 50];
    const products = [{ name: 'P1', rate: 100, area: 1, lbPerBu: 50 }];
    const res = allocator.allocate(model, products, 'imperial');
    expect(res).to.have.property('plan');
    const totalFilled = res.plan.reduce((s, p) => s + p.fillBu, 0);
    expect(totalFilled).to.be.closeTo(2, 0.0001); // 100 lb over 1 ac / 50 lb/bu = 2 bu
  });

  it('reports unallocated when not enough tanks', () => {
    const model = [1];
    const products = [{ name: 'P1', rate: 1000, area: 1, lbPerBu: 1 }];
    const res = allocator.allocate(model, products, 'imperial');
    expect(res.plan.some(p => p.tankLabel === 'UNALLOCATED')).to.be.true;
  });
});
