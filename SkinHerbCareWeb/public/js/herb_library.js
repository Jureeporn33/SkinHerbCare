document.addEventListener('DOMContentLoaded', () => {
  const RENDER_BASE_URL = 'https://skinherbcareweb1.onrender.com';
  const isLocalHost = /^(localhost|127\.0\.0\.1)$/i.test(window.location.hostname);
  const isRenderHost = window.location.hostname.includes('onrender.com');
  const API_BASE_URL = (isLocalHost || isRenderHost) ? window.location.origin : RENDER_BASE_URL;
  const API_BASES = [...new Set([API_BASE_URL, RENDER_BASE_URL])];
  const FETCH_TIMEOUT_MS = 12000;
  const RETRY_PER_BASE = 2;

  const grid = document.getElementById('herb-grid');
  const searchInput = document.getElementById('herb-search');
  let allHerbs = [];

  if (!grid) {
    console.error("herb_library.js: missing #herb-grid");
    return;
  }

  function resolveImageSrc(raw) {
    if (!raw) return '';
    const val = String(raw).trim();
    if (!val) return '';
    if (val.startsWith('http://') || val.startsWith('https://') || val.startsWith('data:')) return val;
    if (val.startsWith('/uploads/')) return `${API_BASE_URL}${val}`;
    const normalized = val.replace(/\\/g, '/');
    const idx = normalized.lastIndexOf('/uploads/');
    if (idx >= 0) return `${API_BASE_URL}${normalized.slice(idx)}`;
    if (/\.(png|jpe?g|gif|webp)$/i.test(val)) return `${API_BASE_URL}/uploads/${val}`;
    return val;
  }

  const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

  async function fetchJsonWithFallback(path) {
    let lastError = null;
    for (const base of API_BASES) {
      const url = `${base}${path}`;
      for (let attempt = 1; attempt <= RETRY_PER_BASE; attempt++) {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);
        try {
          const res = await fetch(url, { signal: controller.signal });
          if (!res.ok) throw new Error(`HTTP ${res.status}`);
          const contentType = res.headers.get('content-type') || '';
          if (!contentType.includes('application/json')) throw new Error('Unexpected non-JSON response');
          clearTimeout(timeoutId);
          return await res.json();
        } catch (error) {
          clearTimeout(timeoutId);
          lastError = error;
          if (attempt < RETRY_PER_BASE) {
            await delay(1000 * attempt);
          }
        }
      }
    }
    throw lastError || new Error('Request failed');
  }

  function renderHerbs(list) {
    if (!Array.isArray(list) || list.length === 0) {
      grid.innerHTML = '<div class="col-span-full text-center text-gray-500 bg-white/60 rounded-2xl py-10 border border-dashed border-green-200">No herb data found</div>';
      return;
    }

    const html = list.map((herb) => {
      const propertiesText = Array.isArray(herb.properties) ? herb.properties.join(', ') : (herb.properties || '');
      const shortDesc = propertiesText.length > 90
        ? `${propertiesText.substring(0, 90)}...`
        : (propertiesText || 'No properties');
      const imageSrc = resolveImageSrc(herb.image || '');
      const herbId = herb._id || herb.id || '';

      return `
        <div class="card-glass rounded-2xl overflow-hidden flex flex-col">
          <div class="h-44 bg-gray-100">
            ${imageSrc ? `<img src="${imageSrc}" class="w-full h-full object-cover" alt="${herb.name || 'Herb'}">` : `<div class="h-full flex items-center justify-center text-gray-400">No Image</div>`}
          </div>
          <div class="p-5 flex flex-col gap-3">
            <h3 class="text-lg font-bold text-slate-900">${herb.name || 'Unknown herb'}</h3>
            <p class="text-sm text-gray-600">${shortDesc}</p>
            <a href="/herb_detail_public.html?id=${herbId}" class="mt-auto inline-flex items-center justify-center gap-2 text-sm font-bold text-green-800 bg-green-100 hover:bg-green-200 rounded-xl px-4 py-2">
              Read more
            </a>
          </div>
        </div>
      `;
    }).join('');

    grid.innerHTML = html;
  }

  async function loadHerbs() {
    grid.innerHTML = '<div class="col-span-full text-center text-gray-500 bg-white/60 rounded-2xl py-10 border border-dashed border-green-200">Loading herbs... (if Render is sleeping, this may take 10-30 seconds)</div>';
    try {
      const json = await fetchJsonWithFallback('/api/herbs');
      const herbs = Array.isArray(json) ? json : (json.herbs || json.data || []);
      allHerbs = Array.isArray(herbs) ? herbs : [];
      renderHerbs(allHerbs);
    } catch (error) {
      console.error('herb_library.js: load failed', error);
      grid.innerHTML = `<div class="col-span-full text-center text-red-500 bg-white/60 rounded-2xl py-10 border border-dashed border-red-200">Load failed: ${error.message}</div>`;
    }
  }

  if (searchInput) {
    searchInput.addEventListener('input', () => {
      const q = searchInput.value.trim().toLowerCase();
      if (!q) {
        renderHerbs(allHerbs);
        return;
      }
      const filtered = allHerbs.filter((herb) => {
        const props = Array.isArray(herb.properties) ? herb.properties.join(' ') : (herb.properties || '');
        const hay = `${herb.name || ''} ${props}`.toLowerCase();
        return hay.includes(q);
      });
      renderHerbs(filtered);
    });
  }

  loadHerbs();
});
