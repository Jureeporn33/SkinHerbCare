const AUTH_JS_VERSION = '20260211r11';

document.addEventListener('DOMContentLoaded', () => {
    document.documentElement.setAttribute('data-auth-js', AUTH_JS_VERSION);
    console.log('[auth.js] loaded', AUTH_JS_VERSION);
    applyAuthNavState();
});

window.addEventListener('pageshow', () => {
    applyAuthNavState();
});

window.addEventListener('storage', (event) => {
    if (event.key === 'token' || event.key === 'userToken' || event.key === 'user' || event.key === 'userRole') {
        applyAuthNavState();
    }
});

function applyAuthNavState() {
    const token = localStorage.getItem('token')
        || localStorage.getItem('userToken')
        || sessionStorage.getItem('token')
        || sessionStorage.getItem('userToken');
    const userRaw = localStorage.getItem('user') || sessionStorage.getItem('user');
    let user = null;
    try {
        user = userRaw ? JSON.parse(userRaw) : null;
    } catch (_) {
        user = null;
    }

    const guestNav = document.getElementById('guest-nav')
        || document.getElementById('guest-menu')
        || document.getElementById('guest-panel');
    const adminNav = document.getElementById('admin-nav')
        || document.getElementById('user-nav')
        || document.getElementById('user-menu')
        || document.getElementById('user-panel');
    const adminLink = document.querySelector('#admin-nav a[href="/admin-dashboard.html"]');

    const storedRole = String(
        localStorage.getItem('userRole')
        || sessionStorage.getItem('userRole')
        || ''
    ).toLowerCase();
    // Prefer role from user payload to avoid stale role cache in localStorage.
    const normalizedRole = String(
        user?.role
        || user?.userRole
        || storedRole
        || 'user'
    ).toLowerCase();
    const isAdmin = Boolean(token) && normalizedRole === 'admin';

    // Always align role to current user payload to prevent stale admin cache.
    if (userRaw) {
        localStorage.setItem('user', userRaw);
        localStorage.setItem('userRole', normalizedRole);
    }

    // Treat token/user as login signal to handle inconsistent legacy storage.
    const isLoggedIn = Boolean(token || userRaw);

    // Hide/show login/register links globally (covers pages with imperfect navbar markup)
    const loginLinks = Array.from(document.querySelectorAll('a[href$="/login.html"], a[href="login.html"]'));
    const registerLinks = Array.from(document.querySelectorAll('a[href$="/register.html"], a[href="register.html"]'));
    const allAuthLinks = [...loginLinks, ...registerLinks];
    allAuthLinks.forEach((el) => {
        el.style.setProperty('display', isLoggedIn ? 'none' : '', 'important');
    });
    if (guestNav) {
        guestNav.style.setProperty('display', isAdmin ? 'none' : 'flex', 'important');
        guestNav.classList.toggle('hidden', isAdmin);
    }
    if (adminNav) {
        adminNav.style.setProperty('display', isAdmin ? 'flex' : 'none', 'important');
        adminNav.classList.toggle('hidden', !isAdmin);
    }
    if (adminLink) adminLink.style.display = isAdmin ? 'inline-flex' : 'none';
    const allAdminLinks = Array.from(document.querySelectorAll('a[href="/admin-dashboard.html"], a[href="admin-dashboard.html"]'));
    allAdminLinks.forEach((el) => {
        el.style.setProperty('display', isAdmin ? 'inline-flex' : 'none', 'important');
    });

    // Fallback for pages with legacy navbar (no admin-nav/user-nav).
    if (!adminNav) {
        const target = guestNav?.parentElement || allAuthLinks[0]?.parentElement;
        if (!target) return;

        let userRow = target.querySelector('[data-auth-user-row="true"]');
        let logoutBtn = target.querySelector('[data-auth-logout="true"]');
        let userLabel = target.querySelector('[data-auth-user="true"]');

        if (isLoggedIn) {
            if (!userRow) {
                userRow = document.createElement('div');
                userRow.setAttribute('data-auth-user-row', 'true');
                userRow.style.display = 'flex';
                userRow.style.alignItems = 'center';
                userRow.style.gap = '8px';
                userRow.style.marginLeft = '8px';
                target.appendChild(userRow);
            }

            if (!userLabel) {
                userLabel = document.createElement('span');
                userLabel.setAttribute('data-auth-user', 'true');
                userLabel.style.fontWeight = '700';
                userLabel.style.color = '#1f2937';
                userRow.appendChild(userLabel);
            }
            userLabel.textContent = (user && (user.firstName || user.name || user.username)) || 'User';

            if (!logoutBtn) {
                logoutBtn = document.createElement('button');
                logoutBtn.type = 'button';
                logoutBtn.setAttribute('data-auth-logout', 'true');
                logoutBtn.textContent = 'Log Out';
                logoutBtn.style.marginLeft = '8px';
                logoutBtn.style.padding = '6px 10px';
                logoutBtn.style.borderRadius = '8px';
                logoutBtn.style.border = '1px solid #fecaca';
                logoutBtn.style.background = '#fef2f2';
                logoutBtn.style.color = '#dc2626';
                logoutBtn.style.cursor = 'pointer';
                logoutBtn.addEventListener('click', logout);
                userRow.appendChild(logoutBtn);
            }
            userRow.style.display = 'flex';
        } else {
            if (logoutBtn) logoutBtn.remove();
            if (userLabel) userLabel.remove();
            if (userRow) userRow.remove();
        }
    } else {
        // Cleanup injected fallback row when a dedicated user/admin nav exists.
        const fallbackRows = document.querySelectorAll('[data-auth-user-row="true"]');
        fallbackRows.forEach((row) => row.remove());
    }
}

// Re-apply state in case other scripts re-render navbar after load.
setInterval(() => {
    applyAuthNavState();
}, 1000);

if (document.body) {
    const observer = new MutationObserver(() => {
        applyAuthNavState();
    });
    observer.observe(document.body, { childList: true, subtree: true });
}

function logout() {
    const msg = 'ต้องการออกจากระบบหรือไม่?';
    if (!confirm(msg)) return;
    localStorage.removeItem('token');
    localStorage.removeItem('userToken');
    localStorage.removeItem('user');
    localStorage.removeItem('userRole');
    localStorage.removeItem('adminToken');
    sessionStorage.removeItem('token');
    sessionStorage.removeItem('userToken');
    sessionStorage.removeItem('user');
    sessionStorage.removeItem('userRole');
    window.location.href = '/index.html';
}

window.logout = logout;
window.forceLogout = logout;
