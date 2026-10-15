(function (root) {
  const MAX_HISTORY = 50;
  const MAX_OPTIONS = 12;
  const STORAGE_KEY = 'decisor-web-state';
  const VERSION = 1;
  const HEX_COLOR = /^#[0-9a-f]{6}$/i;

  function defaults() {
    return { version: VERSION, settings: { soundOn: true, hapticsOn: true, min: 1, max: 10 }, options: [], history: [] };
  }

  function sanitizeSettings(value) {
    const input = value || {};
    const min = Number.isInteger(input.min) ? input.min : 1;
    const max = Number.isInteger(input.max) ? input.max : 10;
    const validRange = min < max && min >= -1e9 && max <= 1e9;
    return { soundOn: input.soundOn !== false, hapticsOn: input.hapticsOn !== false, min: validRange ? min : 1, max: validRange ? max : 10 };
  }

  function normalizeOption(option) {
    const label = typeof option?.label === 'string' ? option.label.trim() : '';
    return label && HEX_COLOR.test(option?.color || '') ? { label, color: option.color } : null;
  }

  function validHistory(item) {
    return item && typeof item.mode === 'string' && typeof item.value === 'string' && !Number.isNaN(Date.parse(item.timestamp));
  }

  function sanitizeOptions(options) {
    return Array.isArray(options) ? options.map(normalizeOption).filter(Boolean).slice(0, MAX_OPTIONS) : [];
  }

  function sanitizeHistory(history) {
    return Array.isArray(history) ? history.filter(validHistory).slice(0, MAX_HISTORY) : [];
  }

  function load(storage) {
    try {
      const parsed = JSON.parse(storage.getItem(STORAGE_KEY) || 'null');
      if (!parsed || parsed.version !== VERSION) return defaults();
      return { version: VERSION, settings: sanitizeSettings(parsed.settings), options: sanitizeOptions(parsed.options), history: sanitizeHistory(parsed.history) };
    } catch (_) { return defaults(); }
  }

  function snapshot(state) {
    return { version: VERSION, settings: sanitizeSettings(state?.settings), options: sanitizeOptions(state?.options), history: sanitizeHistory(state?.history) };
  }

  function save(storage, state) { storage.setItem(STORAGE_KEY, JSON.stringify(snapshot(state))); }

  function appendHistory(history, entry) {
    return validHistory(entry) ? [entry, ...sanitizeHistory(history)].slice(0, MAX_HISTORY) : sanitizeHistory(history);
  }

  function parseRange(minText, maxText) {
    if (!String(minText ?? '').trim() || !String(maxText ?? '').trim()) return null;
    const min = Number(minText);
    const max = Number(maxText);
    return Number.isInteger(min) && Number.isInteger(max) && min < max && min >= -1e9 && max <= 1e9
      ? { min, max } : null;
  }

  function readableForeground(color) {
    const rgb = color.slice(1).match(/.{2}/g).map((part) => parseInt(part, 16) / 255)
      .map((value) => value <= .04045 ? value / 12.92 : ((value + .055) / 1.055) ** 2.4);
    const luminance = rgb[0] * .2126 + rgb[1] * .7152 + rgb[2] * .0722;
    return (luminance + .05) / .05 >= 1.05 / (luminance + .05) ? '#000000' : '#ffffff';
  }

  const api = { parseRange, readableForeground, load, save, appendHistory, sanitizeSettings, snapshot, maxHistory: MAX_HISTORY, maxOptions: MAX_OPTIONS, storageKey: STORAGE_KEY };
  root.DecisorData = api;
  if (typeof module !== 'undefined') module.exports = api;
})(typeof window !== 'undefined' ? window : globalThis);
