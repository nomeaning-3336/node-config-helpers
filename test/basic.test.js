'use strict';

const assert = require('assert');
const { loadConfig, deepMerge } = require('../index.js');

const cfg = loadConfig({
  defaults: { port: 3000, host: '127.0.0.1', db: { pool: 5 } },
  files: ['./config/does-not-exist.json'],
  envPrefix: 'APP'
});

assert.strictEqual(cfg.get('port'), 3000);
assert.strictEqual(cfg.get('host'), '127.0.0.1');
assert.strictEqual(cfg.get('db.pool'), 5);
assert.strictEqual(cfg.get('missing', 'fallback'), 'fallback');

assert.throws(() => cfg.require('nope'), /required config key/);

const merged = deepMerge({ a: 1, nested: { x: 1, y: 2 } }, { nested: { y: 9, z: 3 } });
assert.deepStrictEqual(merged, { a: 1, nested: { x: 1, y: 9, z: 3 } });

console.log('ok - all assertions passed');
