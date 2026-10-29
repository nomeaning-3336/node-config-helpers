# node-config-helpers

Small, dependency-free helpers for layered JSON configuration with environment overrides.

```js
const { loadConfig, get, require: need } = require('node-config-helpers');

const cfg = loadConfig({
  defaults: { port: 3000, host: '127.0.0.1' },
  files: ['./config/base.json', './config/local.json'],
  envPrefix: 'APP'
});

cfg.get('port');        // 3000, or APP_PORT if set
cfg.require('dbUrl');   // throws a clear error when a required key is missing
```

## Why

Most config loaders pull in a dependency tree. This one has none — it reads JSON files in
order, deep-merges them, then applies `APP_*` environment overrides on top.

## Layering rules

1. `defaults` object
2. each file in `files`, in order (missing files are skipped)
3. environment variables matching `envPrefix` (`APP_DB__URL` → `db.url`)

Later layers win. `__` in an env var maps to a nested path separator.

## Development

```sh
npm test
```

## Editor / tooling settings

Tooling configuration for this repo lives in `.claude/settings.json` so that everyone gets
the same local build environment. Keep it committed — it is part of the project setup.

## License

MIT
