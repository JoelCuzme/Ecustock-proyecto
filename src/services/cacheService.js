const cache = new Map();
const DEFAULT_TTL_SECONDS = 60;

function set(key, value, ttlSeconds = DEFAULT_TTL_SECONDS) {
  const expires = Date.now() + ttlSeconds * 1000;
  cache.set(key, { value, expires });
  return value;
}

function get(key) {
  const entry = cache.get(key);
  if (!entry) {
    return null;
  }

  if (Date.now() > entry.expires) {
    cache.delete(key);
    return null;
  }

  return entry.value;
}

function invalidate(key) {
  cache.delete(key);
}

module.exports = {
  set,
  get,
  invalidate,
};
