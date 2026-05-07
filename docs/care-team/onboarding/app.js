/* ═══════════════════════════════════════════════════════
   Rehlah — Coordinator Onboarding Tool · app.js
   Backend stubs marked // TODO(api): — replace with real
   API calls when Firebase / Supabase / custom API is wired.
   localStorage used for demo persistence end-to-end.
   ═══════════════════════════════════════════════════════ */

// ─── Protocol definitions (clinical static data) ───
const protocols = {
  'AC-21': {
    meds: [
      {name:'Doxorubicin (Adriamycin)', dose:'60 mg/m²', freq:'Every cycle day 1', route:'IV push', checked:true},
      {name:'Cyclophosphamide', dose:'600 mg/m²', freq:'Every cycle day 1', route:'IV infusion', checked:true},
      {name:'Ondansetron', dose:'8mg (anti-emetic)', freq:'Twice daily', route:'Oral', checked:true},
      {name:'Dexamethasone', dose:'12mg (pre-med)', freq:'Days 1–3 of cycle', route:'Oral', checked:true}
    ],
    cycleLen: 21, nadir: '6–14'
  },
  'Taxol-W': {
    meds: [
      {name:'Paclitaxel (Taxol)', dose:'80 mg/m² weekly', freq:'Weekly', route:'IV infusion', checked:true},
      {name:'Dexamethasone', dose:'20mg (pre-med)', freq:'Weekly', route:'Oral', checked:true},
      {name:'Diphenhydramine', dose:'50mg (pre-med)', freq:'Weekly', route:'IV push', checked:true}
    ],
    cycleLen: 7, nadir: '5–9'
  },
  'Carbo-T': {
    meds: [
      {name:'Carboplatin', dose:'AUC 5', freq:'Every cycle day 1', route:'IV infusion', checked:true},
      {name:'Paclitaxel', dose:'175 mg/m²', freq:'Every cycle day 1', route:'IV infusion', checked:true},
      {name:'Ondansetron', dose:'8mg (anti-emetic)', freq:'Twice daily', route:'Oral', checked:true}
    ],
    cycleLen: 21, nadir: '7–14'
  },
  'CMF': {
    meds: [
      {name:'Cyclophosphamide', dose:'100 mg/m²', freq:'Once daily', route:'Oral', checked:true},
      {name:'Methotrexate', dose:'40 mg/m²', freq:'Every cycle day 1', route:'IV push', checked:true},
      {name:'5-Fluorouracil', dose:'600 mg/m²', freq:'Every cycle day 1', route:'IV push', checked:true}
    ],
    cycleLen: 28, nadir: '10–18'
  }
};

let selectedProtocol = null;
let currentMeds = [];
let formData = {};
const ONBOARDING_SCREENS = ['step1','step2','step3','step4'];

// ─── localStorage helpers ───

// TODO(api): replace savePatient with POST /api/patients → server returns canonical code,
// persists record, queues SMS to patient phone.
function savePatient(record) {
  const patients = getStoredPatients();
  patients.unshift(record);
  localStorage.setItem('rehlah_patients', JSON.stringify(patients));
}

function getStoredPatients() {
  try { return JSON.parse(localStorage.getItem('rehlah_patients') || '[]'); }
  catch { return []; }
}

// ─── Screen routing ───

function showScreen(id) {
  const tEl = document.getElementById('toast');
  if (tEl) tEl.classList.remove('show');
  clearTimeout(window.__toastT);

  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  const target = document.getElementById('screen-' + id);
  if (target) target.classList.add('active');

  const isOnboarding = ONBOARDING_SCREENS.includes(id);
  document.getElementById('sb-default').style.display = isOnboarding ? 'none' : '';
  document.getElementById('sb-onboarding').style.display = isOnboarding ? '' : 'none';

  if (isOnboarding) {
    const stepNum = parseInt(id.replace('step',''));
    document.querySelectorAll('.sb-step').forEach(s => {
      const n = parseInt(s.dataset.step);
      s.classList.remove('active','done');
      const numEl = s.querySelector('.sb-step-num');
      if (n < stepNum) {
        s.classList.add('done');
        numEl.innerHTML = '<svg viewBox="0 0 12 12" fill="none"><path d="M2 6l3 3 5-6" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>';
      } else if (n === stepNum) {
        s.classList.add('active');
        numEl.textContent = n;
      } else {
        numEl.textContent = n;
      }
    });
  } else {
    document.querySelectorAll('#sb-default .sb-nav').forEach(n => n.classList.remove('active'));
    if (id === 'dashboard') document.getElementById('sbn-dash')?.classList.add('active');
    if (id === 'patients') document.getElementById('sbn-pat')?.classList.add('active');

    // TODO(api): GET /api/patients?coordinatorId={me} — replace static rows with API response
    if (id === 'dashboard' || id === 'patients') renderDynamicPatients(id);
  }

  window.scrollTo(0,0);
}

// ─── Form reset / lifecycle ───

function resetForm() {
  ['patient-name','patient-dob','patient-phone','patient-email',
   'cancer-type','cancer-stage','cancer-subtype','onco-email',
   'coord-email'].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.value = '';
  });
  selectedProtocol = null;
  currentMeds = [];
  document.querySelectorAll('.proto').forEach(p => p.classList.remove('selected'));
  const cycCard = document.getElementById('cycle-card');
  const medCard = document.getElementById('meds-card');
  const cycDisp = document.getElementById('cycle-display');
  if (cycCard) cycCard.style.display = 'none';
  if (medCard) medCard.style.display = 'none';
  if (cycDisp) cycDisp.style.display = 'none';
  document.querySelectorAll('.field.error').forEach(f => f.classList.remove('error'));
  const pgErr = document.querySelector('.proto-grid-error');
  if (pgErr) pgErr.classList.remove('show');
  const pg = document.querySelector('.proto-grid');
  if (pg) pg.classList.remove('error');
  const cs = document.getElementById('cycle-start'); if (cs) cs.value = '';
  const ad = document.getElementById('appt-date');   if (ad) ad.value = '';
}

function startOnboarding() {
  resetForm();
  showScreen('step1');
  const today = new Date().toISOString().split('T')[0];
  const cs = document.getElementById('cycle-start');
  if (cs && !cs.value) cs.value = today;
  let appt = new Date(); appt.setDate(appt.getDate()+21);
  const ad = document.getElementById('appt-date');
  if (ad && !ad.value) ad.value = appt.toISOString().split('T')[0];
}

function cancelOnboarding() { showScreen('dashboard'); }

function goToStep(n) { updateReview(); showScreen('step'+n); }

// ─── Validation ───

const STEP_REQUIRED = {
  1: [
    {id:'patient-name', label:'Full name'},
    {id:'patient-dob', label:'Date of birth'},
    {id:'patient-phone', label:'Mobile number'},
    {id:'cancer-type', label:'Cancer type'}
  ],
  2: [
    {id:'__protocol__', label:'Treatment protocol'},
    {id:'cycle-start', label:'Cycle start date'},
    {id:'appt-date', label:'Next appointment'},
    {id:'onco-email', label:'Oncologist email'}
  ]
};

function clearError(el) {
  const f = el?.closest?.('.field');
  if (f) f.classList.remove('error','shake');
}

// Phone normalization (UAE only): strip +971/00971/leading 0, keep digits, cap 9, pretty-format.
function normalizePhone(input) {
  let digits = input.value.replace(/\D/g, '');
  if (digits.startsWith('00971')) digits = digits.slice(5);
  else if (digits.startsWith('971')) digits = digits.slice(3);
  if (digits.startsWith('0')) digits = digits.slice(1);
  digits = digits.slice(0, 9);
  let formatted = digits;
  if (digits.length > 5) formatted = `${digits.slice(0,2)} ${digits.slice(2,5)} ${digits.slice(5)}`;
  else if (digits.length > 2) formatted = `${digits.slice(0,2)} ${digits.slice(2)}`;
  if (input.value !== formatted) input.value = formatted;
}

function formatPhoneDisplay(raw) {
  const digits = (raw || '').replace(/\D/g, '');
  if (digits.length === 9) return `${digits.slice(0,2)} ${digits.slice(2,5)} ${digits.slice(5)}`;
  return raw;
}

function isValidUAEMobile(raw) {
  const digits = (raw || '').replace(/\D/g, '');
  return digits.length === 9 && digits.startsWith('5');
}

function validatePhoneFormat(input) {
  const v = input.value.trim();
  if (!v) return true;
  const wrap = input.closest('.field');
  if (!isValidUAEMobile(v)) {
    if (wrap) {
      wrap.classList.add('error');
      const errEl = wrap.querySelector('.field-error');
      if (errEl) {
        const svg = errEl.querySelector('svg')?.outerHTML || '';
        errEl.innerHTML = svg + 'Enter a UAE mobile starting with 5 (e.g. 50 123 4567)';
      }
    }
    return false;
  }
  return true;
}

function clearAllErrors() {
  document.querySelectorAll('.field.error').forEach(f => f.classList.remove('error','shake'));
  const pg = document.getElementById('protocol-grid');
  const pe = document.getElementById('proto-grid-error');
  if (pg) pg.classList.remove('error');
  if (pe) pe.classList.remove('show');
  document.querySelectorAll('.meds-error-banner').forEach(b => b.remove());
}

function validateStep(stepNum) {
  clearAllErrors();
  const required = STEP_REQUIRED[stepNum] || [];
  const errors = [];

  required.forEach(req => {
    if (req.id === '__protocol__') {
      if (!selectedProtocol) {
        const grid = document.getElementById('protocol-grid');
        const errEl = document.getElementById('proto-grid-error');
        if (grid) grid.classList.add('error');
        if (errEl) errEl.classList.add('show');
        errors.push({el: grid, label: req.label});
      }
      return;
    }
    const el = document.getElementById(req.id);
    if (!el) return;
    const val = (el.value || '').trim();
    if (!val) {
      const wrap = el.closest('.field') || el.closest('[data-field]');
      if (wrap) {
        const errEl = wrap.querySelector('.field-error');
        if (errEl) {
          const svg = errEl.querySelector('svg')?.outerHTML || '';
          errEl.innerHTML = svg + 'This field is required';
        }
        wrap.classList.add('error','shake');
        setTimeout(() => wrap.classList.remove('shake'), 320);
      }
      errors.push({el: wrap || el, label: req.label});
      return;
    }
    if (req.id === 'patient-phone' && !isValidUAEMobile(val)) {
      const wrap = el.closest('.field');
      if (wrap) {
        const errEl = wrap.querySelector('.field-error');
        if (errEl) {
          const svg = errEl.querySelector('svg')?.outerHTML || '';
          errEl.innerHTML = svg + 'Enter a UAE mobile starting with 5 (e.g. 50 123 4567)';
        }
        wrap.classList.add('error','shake');
        setTimeout(() => wrap.classList.remove('shake'), 320);
      }
      errors.push({el: wrap || el, label: 'Valid UAE mobile'});
    }
    if (req.id === 'onco-email' && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val)) {
      const wrap = el.closest('.field');
      if (wrap) {
        const errEl = wrap.querySelector('.field-error');
        if (errEl) {
          const svg = errEl.querySelector('svg')?.outerHTML || '';
          errEl.innerHTML = svg + 'Enter a valid email (e.g. oncologist@hospital.ae)';
        }
        wrap.classList.add('error','shake');
        setTimeout(() => wrap.classList.remove('shake'), 320);
      }
      errors.push({el: wrap || el, label: 'Valid oncologist email'});
    }
  });

  if (stepNum === 2 && selectedProtocol) {
    const checked = document.querySelectorAll('#meds-list .med-check.checked');
    if (checked.length === 0) {
      const card = document.getElementById('meds-card');
      let banner = card?.querySelector('.meds-error-banner');
      if (card && !banner) {
        banner = document.createElement('div');
        banner.className = 'meds-error-banner';
        banner.innerHTML = '<svg viewBox="0 0 11 11" fill="none"><circle cx="5.5" cy="5.5" r="4.5" stroke="currentColor" stroke-width="1.1"/><path d="M5.5 3.5v2.5" stroke="currentColor" stroke-width="1.1" stroke-linecap="round"/><circle cx="5.5" cy="7.7" r="0.55" fill="currentColor"/></svg>Confirm at least one medication before continuing';
        card.querySelector('.med-list')?.before(banner);
      }
      errors.push({el: card, label: 'At least one medication'});
    }
  }
  return errors;
}

function attemptStep(targetStep) {
  const sourceStep = targetStep - 1;
  const errors = validateStep(sourceStep);
  if (errors.length > 0) {
    const first = errors[0].el;
    if (first) {
      const rect = first.getBoundingClientRect();
      window.scrollTo({top: window.scrollY + rect.top - 100, behavior:'smooth'});
      setTimeout(() => {
        const focusable = first.querySelector?.('input, select, textarea');
        if (focusable) focusable.focus({preventScroll:true});
      }, 350);
    }
    showToast(errors.length === 1
      ? `${errors[0].label} is required`
      : `${errors.length} required fields are missing`, true);
    return;
  }
  goToStep(targetStep);
}

// ─── Med list management ───

const ROUTE_OPTIONS = ['Oral','IV push','IV infusion','Subcutaneous','Intramuscular','Topical'];
const FREQ_OPTIONS = ['Once daily','Twice daily','Three times daily','Weekly','Every cycle day 1','Days 1–3 of cycle','As needed'];

function escapeHtml(s) {
  return String(s||'').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
}

function renderMeds() {
  const list = document.getElementById('meds-list');
  if (!list) return;
  list.innerHTML = currentMeds.map((m,i) => {
    const checkedCls = m.checked ? 'checked' : '';
    const routeOpts = ROUTE_OPTIONS.map(r => `<option ${r===m.route?'selected':''}>${r}</option>`).join('');
    const freqOpts = FREQ_OPTIONS.map(f => `<option ${f===m.freq?'selected':''}>${f}</option>`).join('');
    return `
    <div class="med-item" data-idx="${i}">
      <div class="med-item-main">
        <div class="med-check ${checkedCls}" onclick="toggleMed(${i})" title="${m.checked?'Confirmed':'Not confirmed'}">
          <svg width="11" height="9" viewBox="0 0 11 9" fill="none"><path d="M1 4.5l3 3 6-6.5" stroke="#fff" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>
        </div>
        <span class="med-name">${escapeHtml(m.name)}</span>
        <div class="med-meta">
          <span class="med-pill dose">${escapeHtml(m.dose)}</span>
          ${m.freq ? `<span class="med-pill">${escapeHtml(m.freq)}</span>` : ''}
          ${m.route ? `<span class="med-pill route">${escapeHtml(m.route)}</span>` : ''}
        </div>
        <div class="med-actions">
          <button class="med-act-btn" onclick="toggleEditMed(${i})" title="Edit" aria-label="Edit medication">
            <svg viewBox="0 0 14 14" fill="none"><path d="M9.5 2.5l2 2-7 7H2.5v-2l7-7z" stroke="currentColor" stroke-width="1.3" stroke-linejoin="round"/></svg>
          </button>
          <button class="med-act-btn danger" onclick="deleteMed(${i})" title="Remove" aria-label="Remove medication">
            <svg viewBox="0 0 14 14" fill="none"><path d="M3 4.5h8M5.5 4.5V3a1 1 0 011-1h1a1 1 0 011 1v1.5M4.5 4.5l.5 7a1 1 0 001 .9h2a1 1 0 001-.9l.5-7" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/></svg>
          </button>
        </div>
      </div>
      <div class="med-edit">
        <div class="med-edit-row">
          <input type="text" data-edit="name" value="${escapeHtml(m.name)}" placeholder="Medication name">
          <input type="text" data-edit="dose" value="${escapeHtml(m.dose)}" placeholder="Dose (e.g. 60 mg/m²)">
        </div>
        <div class="med-edit-row triple">
          <select data-edit="freq">${freqOpts}</select>
          <select data-edit="route">${routeOpts}</select>
        </div>
        <div class="med-edit-actions">
          <button class="med-edit-btn" onclick="cancelEditMed(${i})">Cancel</button>
          <button class="med-edit-btn primary" onclick="saveEditMed(${i})">Save changes</button>
        </div>
      </div>
    </div>`;
  }).join('');
  updateMedCountBadge();
}

function updateMedCountBadge() {
  const badge = document.getElementById('med-count-badge');
  if (!badge) return;
  const total = currentMeds.length;
  const confirmed = currentMeds.filter(m => m.checked).length;
  badge.textContent = `${confirmed} of ${total} confirmed`;
  badge.classList.toggle('warn', total > 0 && confirmed === 0);
}

function toggleMed(idx) {
  if (!currentMeds[idx]) return;
  currentMeds[idx].checked = !currentMeds[idx].checked;
  renderMeds();
  if (currentMeds.some(m => m.checked)) {
    document.querySelectorAll('.meds-error-banner').forEach(b => b.remove());
  }
}

function toggleEditMed(idx) {
  const row = document.querySelector(`.med-item[data-idx="${idx}"]`);
  if (!row) return;
  document.querySelectorAll('.med-item.editing').forEach(r => { if (r !== row) r.classList.remove('editing'); });
  row.classList.toggle('editing');
}

function cancelEditMed(idx) {
  const row = document.querySelector(`.med-item[data-idx="${idx}"]`);
  if (row) row.classList.remove('editing');
}

function saveEditMed(idx) {
  const row = document.querySelector(`.med-item[data-idx="${idx}"]`);
  if (!row || !currentMeds[idx]) return;
  const get = sel => row.querySelector(`[data-edit="${sel}"]`)?.value.trim() || '';
  const name = get('name');
  if (!name) { showToast('Medication name is required', true); return; }
  currentMeds[idx] = { ...currentMeds[idx], name, dose: get('dose'), freq: get('freq'), route: get('route') };
  renderMeds();
  showToast('Medication updated');
}

function deleteMed(idx) {
  const m = currentMeds[idx];
  if (!m) return;
  currentMeds.splice(idx, 1);
  renderMeds();
  showToast(`${m.name} removed`);
}

function addCustomMed() { openMedModal(); }

function openMedModal() {
  const m = document.getElementById('med-modal');
  document.getElementById('med-modal-name').value = '';
  document.getElementById('med-modal-dose').value = '';
  document.getElementById('med-modal-route').value = 'Oral';
  document.getElementById('med-modal-freq').value = 'Once daily';
  m.classList.add('show');
  setTimeout(() => document.getElementById('med-modal-name').focus(), 50);
}

function closeMedModal() {
  document.getElementById('med-modal')?.classList.remove('show');
}

function saveMedFromModal() {
  const name = document.getElementById('med-modal-name').value.trim();
  const dose = document.getElementById('med-modal-dose').value.trim();
  const route = document.getElementById('med-modal-route').value;
  const freq = document.getElementById('med-modal-freq').value;
  if (!name) { showToast('Medication name is required', true); return; }
  if (!dose) { showToast('Dose is required', true); return; }
  currentMeds.push({ name, dose, route, freq, checked: true });
  renderMeds();
  closeMedModal();
  showToast(`${name} added`);
}

// ─── Protocol selection ───

function selectProtocol(el, key) {
  document.querySelectorAll('.proto').forEach(p => p.classList.remove('selected'));
  el.classList.add('selected');
  selectedProtocol = key;
  const grid = document.getElementById('protocol-grid');
  const errEl = document.getElementById('proto-grid-error');
  if (grid) grid.classList.remove('error');
  if (errEl) errEl.classList.remove('show');
  document.getElementById('cycle-card').style.display = 'block';
  document.getElementById('meds-card').style.display = 'block';
  currentMeds = protocols[key].meds.map(m => ({ ...m }));
  renderMeds();
  updateCycleDisplay();
  updateReview();
}

// ─── Cycle display ───

function updateCycleDisplay() {
  if (!selectedProtocol) return;
  const start = document.getElementById('cycle-start').value;
  if (!start) return;
  const cycleLen = protocols[selectedProtocol].cycleLen;
  const nadir = protocols[selectedProtocol].nadir;
  const startDate = new Date(start);
  const today = new Date();
  const diff = Math.floor((today - startDate) / 86400000);
  const cycleDay = Math.max(1, (diff % cycleLen) + 1);
  let phase = cycleDay <= 5 ? 'Post-infusion' : cycleDay <= 14 ? 'Nadir window' : 'Recovery';
  const isNadir = phase === 'Nadir window';
  const display = document.getElementById('cycle-display');
  display.style.display = 'grid';
  document.getElementById('cycle-day-display').innerHTML = `Day ${cycleDay}<span class="small">/ ${cycleLen}</span>`;
  const phaseEl = document.getElementById('cycle-phase-display');
  phaseEl.textContent = phase;
  phaseEl.className = 'cycle-val' + (isNadir ? ' warn' : '');
  document.getElementById('nadir-display').innerHTML = `Days ${nadir}<span class="small">of cycle</span>`;
  updateReview();
}

// ─── Review panel ───

function updateReview() {
  const name = document.getElementById('patient-name')?.value || '—';
  const dob = document.getElementById('patient-dob')?.value;
  const phoneRaw = document.getElementById('patient-phone')?.value || '';
  const phone = phoneRaw ? `+971 ${formatPhoneDisplay(phoneRaw)}` : '—';
  const email = document.getElementById('patient-email')?.value || '—';
  const cancer = document.getElementById('cancer-type')?.value || '—';
  const stage = document.getElementById('cancer-stage')?.value || '—';
  const subtype = document.getElementById('cancer-subtype')?.value || '—';
  const cycleNum = document.getElementById('cycle-num')?.value || '—';
  const cycleStart = document.getElementById('cycle-start')?.value || '';
  const appt = document.getElementById('appt-date')?.value || '';
  const onco = document.getElementById('onco-email')?.value || '—';
  const coord = document.getElementById('coord-email')?.value || '—';

  const set = (id, val) => {
    const el = document.getElementById(id); if(!el) return;
    el.textContent = val;
    if (val === '—') el.classList.add('muted'); else el.classList.remove('muted');
  };
  set('rv-name', name);
  set('rv-dob', dob ? new Date(dob).toLocaleDateString('en-GB',{day:'numeric',month:'long',year:'numeric'}) : '—');
  set('rv-phone', phone);
  set('rv-email', email);
  set('rv-cancer', cancer);
  set('rv-stage', stage);
  set('rv-subtype', subtype || '—');
  set('rv-protocol', selectedProtocol || '—');
  set('rv-cycle', cycleNum !== '—' ? `Cycle ${cycleNum}` : '—');
  set('rv-cyclestart', cycleStart ? new Date(cycleStart).toLocaleDateString('en-GB',{day:'numeric',month:'long',year:'numeric'}) : '—');
  set('rv-appt', appt ? new Date(appt).toLocaleDateString('en-GB',{day:'numeric',month:'long',year:'numeric'}) : '—');
  set('rv-onco', onco);
  set('rv-coord', coord);
  set('rv-proto-meds', selectedProtocol || 'selected protocol');

  if (selectedProtocol && cycleStart) {
    const cycleLen = protocols[selectedProtocol].cycleLen;
    const startDate = new Date(cycleStart);
    const today = new Date();
    const diff = Math.floor((today - startDate) / 86400000);
    const cycleDay = Math.max(1, (diff % cycleLen) + 1);
    let phase = cycleDay <= 5 ? 'Post-infusion' : cycleDay <= 14 ? 'Nadir' : 'Recovery';
    set('rv-cyclephase', `Day ${cycleDay} · ${phase} phase`);
  } else {
    set('rv-cyclephase','—');
  }
  formData = { name, phone, onco, appt };
}

// ─── Invite code generation ───

function generateInvite() {
  updateReview();
  const name = document.getElementById('patient-name')?.value || 'PAT';
  const rawInitials = name.trim().split(/\s+/).map(w => w[0]?.toUpperCase() || '').join('').replace(/[^A-Z]/g, '');
  const initials = (rawInitials.substring(0,3) + 'XXX').substring(0,3);
  const num = Math.floor(1000 + Math.random() * 9000);
  const code = `${initials}-${num}`;

  const phoneRaw = document.getElementById('patient-phone')?.value || '';
  const onco = document.getElementById('onco-email')?.value || '—';
  const appt = document.getElementById('appt-date')?.value;
  const cycleN = document.getElementById('cycle-num')?.value;

  document.getElementById('generated-code').textContent = code;
  document.getElementById('inv-name').textContent = name;
  document.getElementById('inv-proto').textContent = selectedProtocol ? `${selectedProtocol} · Cycle ${cycleN}` : '—';
  document.getElementById('inv-phone').textContent = phoneRaw ? `+971 ${formatPhoneDisplay(phoneRaw)}` : '—';
  document.getElementById('inv-onco').textContent = onco;
  document.getElementById('inv-appt').textContent = appt
    ? `Report scheduled ${new Date(new Date(appt).getTime() - 2*86400000).toLocaleDateString('en-GB',{day:'numeric',month:'long'})}`
    : 'Report generated 48h before appointment';

  const firstName = name.split(' ')[0];
  document.getElementById('sms-preview').innerHTML =
    `Hello ${escapeHtml(firstName)}, your care team at Cleveland Clinic Abu Dhabi has enrolled you in Rehlah. Download the app and enter code <strong>${code}</strong> to begin. Your journey is supported. 🌿`;

  // TODO(api): POST /api/patients → server returns canonical code, persists record, queues SMS.
  // For now: build record and save to localStorage for demo.
  const record = {
    id: crypto.randomUUID?.() || `local-${Date.now()}`,
    inviteCode: code,
    status: 'pending',
    identity: {
      name,
      dob: document.getElementById('patient-dob')?.value || '',
      phone: phoneRaw ? `+971${phoneRaw.replace(/\D/g,'')}` : '',
      email: document.getElementById('patient-email')?.value || '',
      cancerType: document.getElementById('cancer-type')?.value || '',
      cancerStage: document.getElementById('cancer-stage')?.value || '',
      cancerSubtype: document.getElementById('cancer-subtype')?.value || '',
    },
    protocol: {
      key: selectedProtocol,
      cycleNum: parseInt(document.getElementById('cycle-num')?.value || '1'),
      cycleStart: document.getElementById('cycle-start')?.value || '',
      apptDate: appt || '',
      meds: currentMeds.filter(m => m.checked),
      oncoEmail: onco,
      coordEmail: document.getElementById('coord-email')?.value || '',
    },
    createdAt: new Date().toISOString(),
    createdBy: 'coordinator',
  };
  savePatient(record);

  showScreen('step4');
}

// ─── Resend invite ───

// TODO(api): POST /api/patients/{id}/resend → re-trigger SMS with same code.
function resendInvite(name, phone) {
  const masked = phone.replace(/(\+\d+ \d+ )(\d+)( \d+)/, (_, a, b, c) => a + 'xxx' + c);
  showToast(`Invite code resent to ${masked}`);
}

// ─── Patient table (localStorage-backed) ───

const DEMO_PATIENTS = [
  {inviteCode:'NAD-7291', identity:{name:'Nadia R.'}, protocol:{key:'AC-21',cycleNum:4}, status:'active', _sub:'AC-T · Cycle 4 · Day 18'},
  {inviteCode:'FAT-4418', identity:{name:'Fatima A.'}, protocol:{key:'AC-21',cycleNum:2}, status:'active', _sub:'AC-T · Cycle 2 · Day 5'},
  {inviteCode:'MAR-9032', identity:{name:'Maryam H.'}, protocol:{key:'Taxol-W',cycleNum:3}, status:'pending', _sub:'Taxol weekly · Week 3'},
  {inviteCode:'LAY-2201', identity:{name:'Layla M.'}, protocol:{key:'CMF',cycleNum:1}, status:'active', _sub:'CMF · Cycle 1 · Day 3'},
];

function initials(name) {
  return (name || '').trim().split(/\s+/).map(w => w[0]?.toUpperCase() || '').join('').slice(0,2) || 'P';
}

function patientRow(p) {
  const statusCls = p.status === 'active' ? 'active' : 'pending';
  const statusDotColor = p.status === 'active' ? 'var(--ok)' : 'var(--warn)';
  const statusLabel = p.status === 'active' ? 'Active' : 'Pending';
  const actionHtml = p.status === 'pending'
    ? `<a class="tr-link" onclick="resendInvite('${escapeHtml(p.identity.name)}','${escapeHtml(p.identity.phone||'+971 50 000 0000')}')">Resend →</a>`
    : `<a class="tr-link">View →</a>`;
  const sub = p._sub || `${p.protocol.key} · Cycle ${p.protocol.cycleNum}`;
  return `
    <div class="tr">
      <div class="tr-pat"><div class="tr-avatar">${initials(p.identity.name)}</div><div><div class="tr-name">${escapeHtml(p.identity.name)}</div><div class="tr-sub">${escapeHtml(sub)}</div></div></div>
      <div><span class="tr-proto">${escapeHtml(p.protocol.key)}</span></div>
      <div class="tr-code">${escapeHtml(p.inviteCode)}</div>
      <div><span class="status ${statusCls}"><span class="status-dot" style="background:${statusDotColor}"></span>${statusLabel}</span></div>
      <div>${actionHtml}</div>
    </div>`;
}

function renderDynamicPatients(screenId) {
  const stored = getStoredPatients();
  const all = [...stored, ...DEMO_PATIENTS];

  const dashTable = document.getElementById('dash-table-body');
  const patTable = document.getElementById('patients-table-body');

  const dashRows = all.slice(0,4).map(patientRow).join('');
  const allRows = all.map(patientRow).join('');

  if (dashTable) dashTable.innerHTML = dashRows;
  if (patTable) patTable.innerHTML = allRows;

  // Update active count stat
  const activeCount = document.getElementById('stat-active-count');
  if (activeCount) {
    const active = all.filter(p => p.status === 'active').length;
    activeCount.textContent = active;
  }
}

// ─── Toast ───

function showToast(msg, isError) {
  const t = document.getElementById('toast');
  document.getElementById('toast-text').textContent = msg;
  t.classList.toggle('error', !!isError);
  t.classList.add('show');
  clearTimeout(window.__toastT);
  window.__toastT = setTimeout(() => t.classList.remove('show'), 2600);
}

// ─── Copy invite code ───

function copyCode() {
  const code = document.getElementById('generated-code').textContent;
  navigator.clipboard?.writeText(code);
  const btn = document.querySelector('.btn-copy');
  if (btn) {
    btn.classList.add('copied');
    const orig = btn.innerHTML;
    btn.innerHTML = `<svg viewBox="0 0 14 14" fill="none"><path d="M2 7l3 3 7-7" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg> Copied!`;
    clearTimeout(window.__copyT);
    window.__copyT = setTimeout(() => { btn.classList.remove('copied'); btn.innerHTML = orig; }, 2000);
  }
  showToast(`Code ${code} copied to clipboard`);
}

// ─── Init ───

window.addEventListener('DOMContentLoaded', () => {
  // Default cycle-start to today when page loads
  const today = new Date().toISOString().split('T')[0];
  const cs = document.getElementById('cycle-start');
  if (cs) cs.value = today;
  // Show dashboard and hydrate with localStorage patients
  showScreen('dashboard');
});
