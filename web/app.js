const modes = ['coin', 'number', 'wheel4', 'custom'];
const wheelColors = ['#F7D154', '#2D7FF9', '#E34D4D', '#28C76F'];
const wheelLabels = ['Amarillo', 'Azul', 'Rojo', 'Verde'];
const state = { mode: 'coin', playing: false, ...DecisorData.load(localStorage) };
let audioContext;
let coinRotation = 0;

const content = document.querySelector('#mode-content');
const playButton = document.querySelector('#play-button');
const playHelp = document.querySelector('#play-help');
const settingsDialog = document.querySelector('#settings-dialog');
const soundToggle = document.querySelector('#sound-toggle');
const hapticsToggle = document.querySelector('#haptics-toggle');
const optionDialog = document.querySelector('#option-dialog');
const confirmDialog = document.querySelector('#confirm-dialog');
const historyDialog = document.querySelector('#history-dialog');

function persist() {
  // El juego debe seguir funcionando aunque el navegador bloquee localStorage
  // (modo privado, cuota llena o preferencias de seguridad).
  try { DecisorData.save(localStorage, state); } catch (_) { /* persistencia opcional */ }
}
function randomIndex(length) {
  if (!Number.isInteger(length) || length <= 0) throw new RangeError('La ruleta no tiene opciones disponibles.');
  const limit = 2 ** 32 - ((2 ** 32) % length);
  const secureCrypto = globalThis.crypto?.getRandomValues ? globalThis.crypto : null;
  if (!secureCrypto) return Math.floor(Math.random() * length);
  let value;
  try {
    do { value = secureCrypto.getRandomValues(new Uint32Array(1))[0]; } while (value >= limit);
  } catch (_) { return Math.floor(Math.random() * length); }
  return value % length;
}
function feedback() {
  try { if (state.settings.hapticsOn && navigator.vibrate) navigator.vibrate(35); } catch (_) { /* feedback opcional */ }
  try {
    if (!state.settings.soundOn || !window.AudioContext) return;
    const audio = audioContext ||= new window.AudioContext(); const oscillator = audio.createOscillator(); const gain = audio.createGain();
    oscillator.frequency.value = 620; gain.gain.setValueAtTime(.04, audio.currentTime); gain.gain.exponentialRampToValueAtTime(.001, audio.currentTime + .08);
    oscillator.connect(gain).connect(audio.destination); oscillator.start(); oscillator.stop(audio.currentTime + .08);
  } catch (_) { /* el resultado no depende del audio */ }
}
function setResult(value, color = '') {
  const result = content.querySelector('.result-card');
  if (!result) return;
  result.textContent = value; result.style.background = color || ''; result.style.color = color && ['#F7D154', '#28C76F'].includes(color.toUpperCase()) ? '#111' : '';
  result.setAttribute('aria-label', `resultado: ${value}`); feedback();
  state.history = DecisorData.appendHistory(state.history, { mode: state.mode, value, timestamp: new Date().toISOString() }); persist();
}
function updatePlayState() {
  const disabled = state.playing || (state.mode === 'custom' && state.options.length === 0);
  playButton.disabled = disabled;
  playButton.textContent = state.playing ? 'JUGANDO…' : 'JUGAR';
  playHelp.textContent = state.mode === 'custom' && state.options.length === 0 ? 'Agrega al menos una opción para jugar.' : '';
}
function wheelMarkup(colors = wheelColors) {
  const step = 100 / colors.length;
  const gradient = colors.map((color, index) => `${color} ${index * step}% ${(index + 1) * step}%`).join(', ');
  const labels = state.mode === 'wheel4' ? wheelLabels : state.options.map((option) => option.label);
  return `<div class="wheel-wrap" aria-label="Ruleta"><div class="wheel" style="background:conic-gradient(${gradient})"></div><span class="wheel-pointer" aria-hidden="true"></span></div><ul class="wheel-legend">${labels.map((label, index) => `<li><span style="background:${colors[index]}" aria-hidden="true"></span>${label}</li>`).join('')}</ul>`;
}
function render() {
  document.querySelector('.app-shell').className = `app-shell mode-${state.mode}`;
  document.querySelectorAll('.mode-tab').forEach((tab) => tab.classList.toggle('is-active', tab.dataset.mode === state.mode));
  if (state.mode === 'coin') { coinRotation = 0; content.innerHTML = `<section class="panel coin-panel"><div class="coin-scene" aria-hidden="true"><div class="coin"><div class="coin-face coin-face--heads"><span>☺</span><small>CARA</small></div><div class="coin-face coin-face--tails"><span>S</span><small>SELLO</small></div></div></div><div class="result-card" role="status" aria-label="resultado">—</div></section>`; }
  if (state.mode === 'number') content.innerHTML = `<section class="panel"><form class="number-form" novalidate><label>Mínimo<input id="min-input" type="number" step="1" value="${state.settings.min}" /></label><label>Máximo<input id="max-input" type="number" step="1" value="${state.settings.max}" /></label></form><p class="error" aria-live="polite"></p><div class="result-card" role="status" aria-label="resultado">—</div></section>`;
  if (state.mode === 'wheel4') content.innerHTML = `<section class="panel">${wheelMarkup()}<div class="result-card" role="status" aria-label="resultado">—</div></section>`;
  if (state.mode === 'custom') renderCustom();
  updatePlayState();
}
function renderCustom() {
  const colors = state.options.map((option) => option.color);
  const wheel = state.options.length ? `<div class="panel">${wheelMarkup(colors)}<div class="result-card" role="status" aria-label="resultado">—</div></div>` : '<p class="play-help">Agrega opciones para crear tu ruleta.</p>';
  content.innerHTML = `<section class="custom-panel"><div class="custom-header"><h2>Ruleta personalizada</h2><strong>${state.options.length}/12</strong></div><form id="add-option-form" class="add-form"><input id="option-label" maxlength="60" required placeholder="Nueva opción" aria-label="Texto de la opción" /><input id="option-color" class="color-input" type="color" value="#1ABC9C" aria-label="Color de la opción" /><button class="small-button"><span aria-hidden="true">＋</span> Agregar opción</button></form>${wheel}<ul class="option-list" aria-label="Opciones de la ruleta"></ul></section>`;
  const list = content.querySelector('.option-list'); const template = document.querySelector('#option-template');
  state.options.forEach((option, index) => { const item = template.content.cloneNode(true); item.querySelector('.option-dot').style.background = option.color; item.querySelector('.option-label').textContent = option.label; item.querySelector('.edit-option').onclick = () => openOptionDialog(index); item.querySelector('.remove-option').onclick = () => openConfirmDialog(index); list.append(item); });
  content.querySelector('#add-option-form').onsubmit = (event) => { event.preventDefault(); if (state.options.length >= 12) return; const label = content.querySelector('#option-label').value.trim(); if (!label) return; state.options.push({ label, color: content.querySelector('#option-color').value }); persist(); render(); };
}
function openOptionDialog(index) {
  const option = state.options[index];
  document.querySelector('#option-title').textContent = 'Editar opción';
  document.querySelector('#dialog-option-label').value = option.label;
  document.querySelector('#dialog-option-color').value = option.color;
  optionDialog.showModal();
  optionDialog.addEventListener('close', function handler() { if (optionDialog.returnValue === 'default') { const label = document.querySelector('#dialog-option-label').value.trim(); if (label) { option.label = label; option.color = document.querySelector('#dialog-option-color').value; persist(); render(); } } optionDialog.removeEventListener('close', handler); }, { once: true });
}
function openConfirmDialog(index) {
  document.querySelector('#confirm-message').textContent = `¿Eliminar "${state.options[index].label}" de la ruleta?`;
  confirmDialog.showModal();
  confirmDialog.addEventListener('close', function handler() { if (confirmDialog.returnValue === 'default') { state.options.splice(index, 1); persist(); render(); } confirmDialog.removeEventListener('close', handler); }, { once: true });
}
function openHistory() {
  const list = document.querySelector('#history-list'); list.replaceChildren();
  state.history.forEach((item) => { const row = document.createElement('li'); row.className = 'option-row'; row.textContent = `${modeLabel(item.mode)} · ${item.value} · ${new Date(item.timestamp).toLocaleString()}`; list.append(row); });
  if (!state.history.length) list.innerHTML = '<li class="option-row">Aún no hay jugadas.</li>';
  historyDialog.showModal();
}
function modeLabel(mode) { return ({ coin: 'Cara o sello', number: 'Número', wheel4: '4 colores', custom: 'Personalizada' })[mode] || mode; }
async function play() {
  if (state.playing) return;
  if (state.mode === 'number') { const min = Number(content.querySelector('#min-input').value); const max = Number(content.querySelector('#max-input').value); const error = content.querySelector('.error'); if (!Number.isInteger(min) || !Number.isInteger(max) || min >= max || min < -1e9 || max > 1e9) { error.textContent = 'Usa enteros entre -1e9 y 1e9 y mínimo menor que máximo.'; return; } state.settings.min = min; state.settings.max = max; persist(); }
  state.playing = true; updatePlayState();
  const coin = content.querySelector('.coin'); const wheel = content.querySelector('.wheel');
  const playedMode = state.mode;
  try {
    let result, color;
    if (playedMode === 'coin') result = randomIndex(2) === 0 ? 'Cara' : 'Sello';
    if (playedMode === 'number') { const min = state.settings.min; result = String(min + randomIndex(state.settings.max - min + 1)); }
    if (playedMode === 'wheel4') { const index = randomIndex(4); result = wheelLabels[index]; color = wheelColors[index]; if (wheel) wheel.style.transform = `rotate(${1080 - index * 90}deg)`; }
    if (playedMode === 'custom') { const index = randomIndex(state.options.length); result = state.options[index].label; color = state.options[index].color; if (wheel) wheel.style.transform = `rotate(${1440 - index * (360 / state.options.length)}deg)`; }
    if (coin) {
      const minimumSpin = Math.ceil((coinRotation + 720) / 360) * 360;
      coinRotation = minimumSpin + (result === 'Sello' ? 180 : 0);
      coin.style.transform = `rotateY(${coinRotation}deg)`;
    }
    await new Promise((resolve) => setTimeout(resolve, playedMode === 'coin' ? 700 : 1100));
    setResult(result, color);
  } catch (error) {
    const errorMessage = content.querySelector('.error') || playHelp;
    errorMessage.textContent = 'No se pudo completar la jugada. Inténtalo de nuevo.';
    console.error('Error al jugar', error);
  } finally {
    state.playing = false;
    updatePlayState();
  }
}
document.querySelectorAll('.mode-tab').forEach((tab) => tab.addEventListener('click', () => { if (!state.playing) { state.mode = tab.dataset.mode; render(); } }));
playButton.addEventListener('click', play);
document.querySelector('#settings-button').addEventListener('click', () => { soundToggle.checked = state.settings.soundOn; hapticsToggle.checked = state.settings.hapticsOn; settingsDialog.showModal(); });
[soundToggle, hapticsToggle].forEach((toggle) => toggle.addEventListener('change', () => { state.settings.soundOn = soundToggle.checked; state.settings.hapticsOn = hapticsToggle.checked; persist(); }));
document.querySelector('#history-button').addEventListener('click', openHistory);
document.querySelector('#clear-history').addEventListener('click', (event) => { event.preventDefault(); state.history = []; persist(); historyDialog.close(); });
render();
