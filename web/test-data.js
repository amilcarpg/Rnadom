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

const { parseRange, readableForeground } = require('./data.js');
assert.equal(parseRange('', '10'), null);
assert.equal(parseRange('1', ' '), null);
assert.equal(parseRange('2.5', '10'), null);
assert.equal(parseRange('10', '1'), null);
assert.equal(parseRange('-1000000001', '10'), null);
assert.deepEqual(parseRange('0', '10'), { min: 0, max: 10 });
assert.deepEqual(parseRange('-1000000000', '1000000000'), { min: -1e9, max: 1e9 });
assert.equal(readableForeground('#12D6C1'), '#000000');
assert.equal(readableForeground('#2D7FF9'), '#000000');
assert.equal(readableForeground('#E34D4D'), '#000000');
assert.equal(readableForeground('#020d1b'), '#ffffff');
console.log('web range and contrast regressions passed');
