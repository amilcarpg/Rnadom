const assert = require('node:assert/strict');
const { load, appendHistory, maxHistory } = require('./data.js');

const corruptStorage = { getItem: () => '{invalid' };
assert.deepEqual(load(corruptStorage).history, []);

const entries = Array.from({ length: maxHistory + 5 }, (_, index) => ({ mode: 'coin', value: String(index), timestamp: new Date().toISOString() }));
assert.equal(entries.reduce((history, item) => appendHistory(history, item), []).length, maxHistory);
console.log('web data tests passed');
