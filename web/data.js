(function (root) {
  const maxHistory = 50;
  const defaults = { version: 1, settings: { soundOn: true, hapticsOn: true, min: 1, max: 10 }, options: [], history: [] };

  function load(storage) {
    try {
      const parsed = JSON.parse(storage.getItem('decisor-web-state') || 'null');
      if (!parsed || parsed.version !== 1) return structuredClone(defaults);
      return {
        version: 1,
        settings: sanitizeSettings(parsed.settings),
        options: Array.isArray(parsed.options) ? parsed.options.filter(validOption).slice(0, 12) : [],
        history: Array.isArray(parsed.history) ? parsed.history.filter(validHistory).slice(0, maxHistory) : [],
      };
    } catch (_) { return structuredClone(defaults); }
  }
  function save(storage, state) { storage.setItem('decisor-web-state', JSON.stringify({ version: 1, settings: sanitizeSettings(state.settings), options: state.options.filter(validOption).slice(0, 12), history: state.history.filter(validHistory).slice(0, maxHistory) })); }
  function appendHistory(history, entry) { return [entry, ...history.filter(validHistory)].slice(0, maxHistory); }
  function sanitizeSettings(value) { const input = value || {}; const min = Number.isInteger(input.min) ? input.min : 1; const max = Number.isInteger(input.max) ? input.max : 10; return { soundOn: input.soundOn !== false, hapticsOn: input.hapticsOn !== false, min: min < max && min >= -1e9 && max <= 1e9 ? min : 1, max: min < max && min >= -1e9 && max <= 1e9 ? max : 10 }; }
  function validOption(option) { return option && typeof option.label === 'string' && option.label.trim() && /^#[0-9a-f]{6}$/i.test(option.color || ''); }
  function validHistory(item) { return item && typeof item.mode === 'string' && typeof item.value === 'string' && !Number.isNaN(Date.parse(item.timestamp)); }
  const api = { load, save, appendHistory, maxHistory };
  root.DecisorData = api;
  if (typeof module !== 'undefined') module.exports = api;
})(typeof window !== 'undefined' ? window : globalThis);
