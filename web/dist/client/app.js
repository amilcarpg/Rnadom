const MODE = Object.freeze({ coin: 'coin', number: 'number', wheel4: 'wheel4', custom: 'custom' });
const MODES = Object.freeze(Object.values(MODE));
const MODE_LABELS = Object.freeze({ [MODE.coin]: 'Cara o sello', [MODE.number]: 'Número', [MODE.wheel4]: '4 colores', [MODE.custom]: 'Personalizada' });
const MODE_ICONS = Object.freeze({ [MODE.coin]: '☺', [MODE.number]: '#', [MODE.wheel4]: '◉', [MODE.custom]: '☷' });
const WHEEL_COLORS = Object.freeze(['#F7D154', '#2D7FF9', '#E34D4D', '#28C76F']);
const WHEEL_LABELS = Object.freeze(['Amarillo', 'Azul', 'Rojo', 'Verde']);
const PLAY_DELAY = Object.freeze({ [MODE.coin]: 700, default: 1100 });
const HEX_COLOR = /^#[0-9a-f]{6}$/i;

const state = { mode: MODE.coin, playing: false, ...DecisorData.load(localStorage) };
const dom = {
  shell: document.querySelector('.app-shell'), content: document.querySelector('#mode-content'),
  playButton: document.querySelector('#play-button'), playHelp: document.querySelector('#play-help'),
  modeSelector: document.querySelector('#mode-selector'), modeSelectorLabel: document.querySelector('#mode-selector-label'),
  modeSelectorIcon: document.querySelector('#mode-selector-icon'), modeDialog: document.querySelector('#mode-dialog'),
  customEditorDialog: document.querySelector('#custom-editor-dialog'), customEditorCount: document.querySelector('#custom-editor-count'),
  customOptionList: document.querySelector('#custom-option-list'), modeChoices: [...document.querySelectorAll('.mode-choice')],
  optionTemplate: document.querySelector('#option-template'),
  settingsDialog: document.querySelector('#settings-dialog'), soundToggle: document.querySelector('#sound-toggle'),
  hapticsToggle: document.querySelector('#haptics-toggle'), optionDialog: document.querySelector('#option-dialog'),
  confirmDialog: document.querySelector('#confirm-dialog'), historyDialog: document.querySelector('#history-dialog'),
};

let audioContext;
let coinRotation = 0;
let wheelRotation = 0;

function persist() {
  try { DecisorData.save(localStorage, state); } catch (_) { /* La persistencia no puede bloquear el juego. */ }
}

function escapeHtml(value) {
  return String(value).replace(/[&<>'"]/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[character]);
}

function safeColor(color, fallback = '#1ABC9C') {
  return HEX_COLOR.test(color || '') ? color : fallback;
}

function randomIndex(length) {
  if (!Number.isInteger(length) || length <= 0) throw new RangeError('No hay opciones disponibles para jugar.');
  const secureCrypto = globalThis.crypto?.getRandomValues ? globalThis.crypto : null;
  if (!secureCrypto) return Math.floor(Math.random() * length);
  const limit = 2 ** 32 - ((2 ** 32) % length);
  try {
    let value;
    do { value = secureCrypto.getRandomValues(new Uint32Array(1))[0]; } while (value >= limit);
    return value % length;
  } catch (_) { return Math.floor(Math.random() * length); }
}

function playFeedback() {
  try { if (state.settings.hapticsOn && navigator.vibrate) navigator.vibrate(35); } catch (_) { /* Opcional. */ }
  try {
    if (!state.settings.soundOn || !window.AudioContext) return;
    const audio = audioContext ||= new window.AudioContext();
    const oscillator = audio.createOscillator();
    const gain = audio.createGain();
    oscillator.frequency.value = 620;
    gain.gain.setValueAtTime(.04, audio.currentTime);
    gain.gain.exponentialRampToValueAtTime(.001, audio.currentTime + .08);
    oscillator.connect(gain).connect(audio.destination);
    oscillator.onended = () => { oscillator.disconnect(); gain.disconnect(); };
    oscillator.start(); oscillator.stop(audio.currentTime + .08);
  } catch (_) { /* El resultado no depende del audio. */ }
}

function getResultCard() { return dom.content.querySelector('.result-card'); }

function showResult(value, color = '') {
  const resultCard = getResultCard();
  if (!resultCard) return;
  const resultColor = safeColor(color, '');
  resultCard.textContent = value;
  resultCard.style.background = resultColor;
  resultCard.style.color = ['#F7D154', '#28C76F'].includes(resultColor.toUpperCase()) ? '#111' : '';
  resultCard.setAttribute('aria-label', `resultado: ${value}`);
  state.history = DecisorData.appendHistory(state.history, { mode: state.mode, value, timestamp: new Date().toISOString() });
  persist();
  playFeedback();
}

function updatePlayState() {
  const needsOptions = state.mode === MODE.custom && state.options.length === 0;
  dom.playButton.disabled = state.playing || needsOptions;
  dom.playButton.textContent = state.playing ? 'JUGANDO…' : 'JUGAR';
  dom.playHelp.textContent = needsOptions ? 'Agrega al menos una opción para jugar.' : '';
}

function wheelMarkup(colors, labels) {
  const validColors = colors.map((color) => safeColor(color));
  if (validColors.length === 1) {
    const legend = `<li><span style="background:${validColors[0]}" aria-hidden="true"></span>${escapeHtml(labels[0])}</li>`;
    return `<div class="wheel-wrap" role="img" aria-label="Ruleta con 1 opción"><div class="wheel"><svg viewBox="0 0 100 100" aria-hidden="true" focusable="false"><circle cx="50" cy="50" r="49" fill="${validColors[0]}" stroke="#eef4f5" stroke-width="1.1" vector-effect="non-scaling-stroke" /></svg></div><span class="wheel-pointer" aria-hidden="true"></span></div><ul class="wheel-legend">${legend}</ul>`;
  }
  const sector = 360 / validColors.length;
  const point = (angle) => {
    const radians = angle * Math.PI / 180;
    return `${(50 + 49 * Math.cos(radians)).toFixed(3)} ${(50 + 49 * Math.sin(radians)).toFixed(3)}`;
  };
  const sectors = validColors.map((color, index) => {
    const start = -90 - sector / 2 + sector * index;
    const end = start + sector;
    const largeArc = sector > 180 ? 1 : 0;
    return `<path d="M 50 50 L ${point(start)} A 49 49 0 ${largeArc} 1 ${point(end)} Z" fill="${color}" stroke="#eef4f5" stroke-width="1.1" vector-effect="non-scaling-stroke" />`;
  }).join('');
  const legend = labels.map((label, index) => `<li><span style="background:${validColors[index]}" aria-hidden="true"></span>${escapeHtml(label)}</li>`).join('');
  return `<div class="wheel-wrap" role="img" aria-label="Ruleta con ${labels.length} opciones"><div class="wheel"><svg viewBox="0 0 100 100" aria-hidden="true" focusable="false">${sectors}</svg></div><span class="wheel-pointer" aria-hidden="true"></span></div><ul class="wheel-legend">${legend}</ul>`;
}

function renderCoin() {
  coinRotation = 0;
  return `<section class="panel coin-panel"><div class="coin-scene" aria-hidden="true"><div class="coin"><div class="coin-face coin-face--heads"><span>☺</span><small>CARA</small></div><div class="coin-face coin-face--tails"><span>S</span><small>SELLO</small></div></div></div><div class="result-card" role="status" aria-label="resultado">—</div></section>`;
}

function renderNumber() {
  return `<section class="panel"><form class="number-form" novalidate><label>Mínimo<input id="min-input" type="number" step="1" value="${state.settings.min}" /></label><label>Máximo<input id="max-input" type="number" step="1" value="${state.settings.max}" /></label></form><p class="error" aria-live="polite"></p><div class="result-card" role="status" aria-label="resultado">—</div></section>`;
}

function renderWheel4() {
  wheelRotation = 0;
  return `<section class="panel">${wheelMarkup(WHEEL_COLORS, WHEEL_LABELS)}<div class="result-card" role="status" aria-label="resultado">—</div></section>`;
}

function renderCustom() {
  wheelRotation = 0;
  const hasOptions = state.options.length > 0;
  const colors = state.options.map((option) => option.color);
  const labels = state.options.map((option) => option.label);
  const wheel = hasOptions ? `${wheelMarkup(colors, labels)}<div class="result-card" role="status" aria-label="resultado">—</div>` : '<p class="empty-state">Agrega opciones para crear y girar tu propia ruleta.</p>';
  return `<section class="custom-panel"><div class="custom-header"><h2>Ruleta personalizada</h2><strong>${state.options.length}/12</strong></div>${wheel}<button id="edit-options-button" class="edit-options-button" type="button">Editar opciones</button></section>`;
}

function renderOptionList() {
  const fragment = document.createDocumentFragment();
  state.options.forEach((option, index) => {
    const item = dom.optionTemplate.content.cloneNode(true);
    item.querySelector('.option-row').dataset.optionIndex = String(index);
    item.querySelector('.option-dot').style.background = safeColor(option.color);
    item.querySelector('.option-label').textContent = option.label;
    fragment.append(item);
  });
  dom.customOptionList.replaceChildren(fragment);
  dom.customEditorCount.textContent = `${state.options.length}/12 opciones`;
}

function renderModeSelector() {
  dom.modeSelectorLabel.textContent = MODE_LABELS[state.mode];
  dom.modeSelectorIcon.textContent = MODE_ICONS[state.mode];
  dom.modeSelector.setAttribute('aria-label', `Seleccionar modo: ${MODE_LABELS[state.mode]}`);
  dom.modeChoices.forEach((choice) => choice.classList.toggle('is-active', choice.dataset.mode === state.mode));
}

function render() {
  const renderers = { [MODE.coin]: renderCoin, [MODE.number]: renderNumber, [MODE.wheel4]: renderWheel4, [MODE.custom]: renderCustom };
  dom.shell.className = `app-shell mode-${state.mode}`;
  renderModeSelector();
  dom.content.innerHTML = renderers[state.mode]();
  renderOptionList();
  updatePlayState();
}

function validNumberRange() {
  const min = Number(dom.content.querySelector('#min-input')?.value);
  const max = Number(dom.content.querySelector('#max-input')?.value);
  const isValid = Number.isInteger(min) && Number.isInteger(max) && min < max && min >= -1e9 && max <= 1e9;
  if (!isValid) {
    const error = dom.content.querySelector('.error');
    if (error) error.textContent = 'Usa enteros entre -1e9 y 1e9 y mínimo menor que máximo.';
    return null;
  }
  state.settings.min = min;
  state.settings.max = max;
  persist();
  return { min, max };
}

function rotateCoin(coin, result) {
  const minimumSpin = Math.ceil((coinRotation + 720) / 360) * 360;
  coinRotation = minimumSpin + (result === 'Sello' ? 180 : 0);
  coin.style.transform = `rotateY(${coinRotation}deg)`;
}

function rotateWheel(wheel, index, optionsCount) {
  const angle = 360 / optionsCount;
  const minimumSpin = Math.ceil((wheelRotation + 720) / 360) * 360;
  wheelRotation = minimumSpin - index * angle;
  wheel.style.transform = `rotate(${wheelRotation}deg)`;
}

function getOutcome(mode, range) {
  if (mode === MODE.coin) return { value: randomIndex(2) === 0 ? 'Cara' : 'Sello' };
  if (mode === MODE.number) return { value: String(range.min + randomIndex(range.max - range.min + 1)) };
  if (mode === MODE.wheel4) {
    const index = randomIndex(WHEEL_LABELS.length);
    return { value: WHEEL_LABELS[index], color: WHEEL_COLORS[index], index, optionsCount: WHEEL_LABELS.length };
  }
  const index = randomIndex(state.options.length);
  return { value: state.options[index].label, color: state.options[index].color, index, optionsCount: state.options.length };
}

function showPlayError(error) {
  const message = dom.content.querySelector('.error') || dom.playHelp;
  message.textContent = 'No se pudo completar la jugada. Inténtalo de nuevo.';
  console.error('Error al jugar', error);
}

function delay(milliseconds) { return new Promise((resolve) => setTimeout(resolve, milliseconds)); }

async function play() {
  if (state.playing) return;
  const mode = state.mode;
  const range = mode === MODE.number ? validNumberRange() : null;
  if (mode === MODE.number && !range) return;

  state.playing = true;
  updatePlayState();
  try {
    const outcome = getOutcome(mode, range);
    const coin = dom.content.querySelector('.coin');
    const wheel = dom.content.querySelector('.wheel');
    if (coin) rotateCoin(coin, outcome.value);
    if (wheel && Number.isInteger(outcome.index)) rotateWheel(wheel, outcome.index, outcome.optionsCount);
    await delay(PLAY_DELAY[mode] || PLAY_DELAY.default);
    showResult(outcome.value, outcome.color);
  } catch (error) {
    showPlayError(error);
  } finally {
    state.playing = false;
    updatePlayState();
  }
}

function setMode(mode) {
  if (!MODES.includes(mode) || state.playing || state.mode === mode) return;
  state.mode = mode;
  render();
}

function addOption(form) {
  if (state.options.length >= 12) return;
  const label = form.querySelector('#option-label').value.trim();
  if (!label) return;
  state.options.push({ label, color: safeColor(form.querySelector('#option-color').value) });
  persist();
  render();
}

function openOptionDialog(index) {
  const option = state.options[index];
  if (!option) return;
  document.querySelector('#option-title').textContent = 'Editar opción';
  document.querySelector('#dialog-option-label').value = option.label;
  document.querySelector('#dialog-option-color').value = option.color;
  dom.optionDialog.showModal();
  dom.optionDialog.addEventListener('close', function saveOption() {
    if (dom.optionDialog.returnValue === 'default') {
      const label = document.querySelector('#dialog-option-label').value.trim();
      if (label) { option.label = label; option.color = safeColor(document.querySelector('#dialog-option-color').value); persist(); render(); }
    }
  }, { once: true });
}

function openConfirmDialog(index) {
  const option = state.options[index];
  if (!option) return;
  document.querySelector('#confirm-message').textContent = `¿Eliminar "${option.label}" de la ruleta?`;
  dom.confirmDialog.showModal();
  dom.confirmDialog.addEventListener('close', function removeOption() {
    if (dom.confirmDialog.returnValue === 'default') { state.options.splice(index, 1); persist(); render(); }
  }, { once: true });
}

function openHistory() {
  const list = document.querySelector('#history-list');
  const fragment = document.createDocumentFragment();
  state.history.forEach((item) => {
    const row = document.createElement('li');
    row.className = 'option-row';
    row.textContent = `${MODE_LABELS[item.mode] || item.mode} · ${item.value} · ${new Date(item.timestamp).toLocaleString()}`;
    fragment.append(row);
  });
  if (!fragment.childNodes.length) {
    const empty = document.createElement('li'); empty.className = 'option-row'; empty.textContent = 'Aún no hay jugadas.'; fragment.append(empty);
  }
  list.replaceChildren(fragment);
  dom.historyDialog.showModal();
}

function bindEvents() {
  dom.modeSelector.addEventListener('click', () => dom.modeDialog.showModal());
  dom.modeChoices.forEach((choice) => choice.addEventListener('click', () => {
    setMode(choice.dataset.mode);
    dom.modeDialog.close();
  }));
  dom.playButton.addEventListener('click', play);
  document.querySelector('#add-option-form').addEventListener('submit', (event) => { event.preventDefault(); addOption(event.target); });
  document.addEventListener('click', (event) => {
    const closeButton = event.target.closest('[data-close-dialog]');
    if (closeButton) document.querySelector(`#${closeButton.dataset.closeDialog}`)?.close();
    if (event.target.closest('#edit-options-button')) dom.customEditorDialog.showModal();
    const action = event.target.closest('[data-option-action]');
    if (!action) return;
    const index = Number(action.closest('[data-option-index]')?.dataset.optionIndex);
    if (action.dataset.optionAction === 'edit') openOptionDialog(index);
    if (action.dataset.optionAction === 'remove') openConfirmDialog(index);
  });
  document.querySelector('#settings-button').addEventListener('click', () => {
    dom.soundToggle.checked = state.settings.soundOn; dom.hapticsToggle.checked = state.settings.hapticsOn; dom.settingsDialog.showModal();
  });
  [dom.soundToggle, dom.hapticsToggle].forEach((toggle) => toggle.addEventListener('change', () => {
    state.settings.soundOn = dom.soundToggle.checked; state.settings.hapticsOn = dom.hapticsToggle.checked; persist();
  }));
  document.querySelector('#history-button').addEventListener('click', openHistory);
  document.querySelector('#clear-history').addEventListener('click', (event) => { event.preventDefault(); state.history = []; persist(); dom.historyDialog.close(); });
}

bindEvents();
render();
