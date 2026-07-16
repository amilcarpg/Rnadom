const assert = require('node:assert/strict');
const { load, save, appendHistory, snapshot, maxHistory, maxOptions, storageKey } = require('./data.js');

const corruptStorage = { getItem: () => '{invalid' };
assert.deepEqual(load(corruptStorage).history, []);
assert.deepEqual(load({ getItem: () => { throw new Error('blocked'); } }).options, []);

const malformed = { version: 1, settings: { min: 10, max: 1 }, options: [{ label: '  Pizza  ', color: '#E34D4D' }, { label: '<script>', color: 'bad' }], history: [{ mode: 'coin', value: 'Cara', timestamp: new Date().toISOString() }, { mode: 1 }] };
const normalized = load({ getItem: () => JSON.stringify(malformed) });
assert.deepEqual(normalized.settings.min, 1);
assert.deepEqual(normalized.options, [{ label: 'Pizza', color: '#E34D4D' }]);
assert.equal(normalized.history.length, 1);

const entries = Array.from({ length: maxHistory + 5 }, (_, index) => ({ mode: 'coin', value: String(index), timestamp: new Date().toISOString() }));
assert.equal(entries.reduce((history, item) => appendHistory(history, item), []).length, maxHistory);
assert.equal(appendHistory([], { mode: 'coin', value: 'x' }).length, 0);
assert.equal(snapshot({ options: Array.from({ length: maxOptions + 1 }, (_, index) => ({ label: String(index), color: '#ffffff' })) }).options.length, maxOptions);

let saved;
save({ setItem: (key, value) => { saved = { key, value }; } }, normalized);
assert.equal(saved.key, storageKey);
assert.equal(JSON.parse(saved.value).options[0].label, 'Pizza');
console.log('web data tests passed');
