'use strict';

const fs = require('fs');
const path = require('path');

function isPlainObject(v) {
  return v !== null && typeof v === 'object' && !Array.isArray(v);
}

function deepMerge(base, patch) {
  if (!isPlainObject(base) || !isPlainObject(patch)) return patch;
  const out = Object.assign({}, base);
  for (const [k, v] of Object.entries(patch)) {
    out[k] = isPlainObject(v) && isPlainObject(out[k]) ? deepMerge(out[k], v) : v;
  }
  return out;
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch (err) {
    if (err.code === 'ENOENT') return null;
    throw new Error(`node-config-helpers: failed to parse ${file}: ${err.message}`);
  }
}

function coerce(raw) {
  if (raw === 'true') return true;
  if (raw === 'false') return false;
  if (raw === 'null') return null;
  if (/^-?\d+(\.\d+)?$/.test(raw)) return Number(raw);
  return raw;
}

function applyEnv(cfg, prefix) {
  const out = Object.assign({}, cfg);
  const re = new RegExp(`^${prefix}_`);
  for (const [key, raw] of Object.entries(process.env)) {
    if (!re.test(key) || raw === undefined) continue;
    const parts = key.slice(prefix.length + 1).toLowerCase().split('__');
    let cur = out;
    for (let i = 0; i < parts.length - 1; i++) {
      if (!isPlainObject(cur[parts[i]])) cur[parts[i]] = {};
      cur = cur[parts[i]];
    }
    cur[parts[parts.length - 1]] = coerce(raw);
  }
  return out;
}

function getPath(obj, dottedPath, fallback) {
  const parts = String(dottedPath).split('.');
  let cur = obj;
  for (const p of parts) {
    if (cur === null || cur === undefined || typeof cur !== 'object') return fallback;
    cur = cur[p];
  }
  return cur === undefined ? fallback : cur;
}

function loadConfig(opts) {
  const options = opts || {};
  let cfg = options.defaults ? deepMerge({}, options.defaults) : {};

  for (const file of options.files || []) {
    const abs = path.resolve(file);
    const parsed = readJson(abs);
    if (parsed) cfg = deepMerge(cfg, parsed);
  }

  if (options.envPrefix) cfg = applyEnv(cfg, options.envPrefix);

  return {
    raw: cfg,
    get(dottedPath, fallback) {
      return getPath(cfg, dottedPath, fallback);
    },
    require(dottedPath) {
      const v = getPath(cfg, dottedPath, undefined);
      if (v === undefined) {
        throw new Error(`node-config-helpers: required config key "${dottedPath}" is missing`);
      }
      return v;
    }
  };
}

module.exports = { loadConfig, get: getPath, deepMerge, applyEnv, require: loadConfig };
