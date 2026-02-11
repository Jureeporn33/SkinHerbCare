document.addEventListener('DOMContentLoaded', () => {
    applyAuthNavState();
});

window.addEventListener('storage', (event) => {
    if (event.key === 'token' || event.key === 'userToken' || event.key === 'user' || event.key === 'userRole') {
        applyAuthNavState();
    }
});

function applyAuthNavState() {
    const token = localStorage.getItem('token') || localStorage.getItem('userToken');
    const userRaw = localStorage.getItem('user');
    const userRole = localStorage.getItem('userRole');
    let user = null;
    try {
        user = userRaw ? JSON.parse(userRaw) : null;
    } catch (_) {
        user = null;
    }

    const guestNav = document.getElementById('guest-nav') || document.getElementById('guest-menu');
    const adminNav = document.getElementById('admin-nav') || document.getElementById('user-nav') || document.getElementById('user-menu');
    const adminLink = document.querySelector('#admin-nav a[href="/admin-dashboard.html"]');

    const isLoggedIn = Boolean(userRaw);
    if (guestNav) {
        guestNav.style.setProperty('display', isLoggedIn ? 'none' : 'flex', 'important');
        guestNav.classList.toggle('hidden', isLoggedIn);
    }
    if (adminNav) {
        adminNav.style.setProperty('display', isLoggedIn ? 'flex' : 'none', 'important');
        adminNav.classList.toggle('hidden', !isLoggedIn);
    }
    if (adminLink) adminLink.style.display = userRole === 'admin' ? 'inline-flex' : 'none';

    // Fallback for pages that still use old navbar markup without guest-nav/admin-nav.
    if (!guestNav && !adminNav) {
        const loginLinks = Array.from(document.querySelectorAll('a[href$="/login.html"], a[href="login.html"]'));
        const registerLinks = Array.from(document.querySelectorAll('a[href$="/register.html"], a[href="register.html"]'));
        const allAuthLinks = [...loginLinks, ...registerLinks];
        allAuthLinks.forEach((el) => {
            el.style.display = isLoggedIn ? 'none' : '';
        });

        // Use the nearest visible auth container to inject a logout button.
        const target = allAuthLinks.find((el) => el.offsetParent !== null)?.parentElement;
        if (!target) return;

        let logoutBtn = target.querySelector('[data-auth-logout="true"]');
        let userLabel = target.querySelector('[data-auth-user="true"]');

        if (isLoggedIn) {
            if (!userLabel) {
                userLabel = document.createElement('span');
                userLabel.setAttribute('data-auth-user', 'true');
                userLabel.style.fontWeight = '700';
                userLabel.style.color = '#1f2937';
                userLabel.style.marginLeft = '6px';
                target.appendChild(userLabel);
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
                target.appendChild(logoutBtn);
            }
        } else {
            if (logoutBtn) logoutBtn.remove();
            if (userLabel) userLabel.remove();
        }
    }
}

function logout() {
    const msg = 'ต้องการออกจากระบบหรือไม่?';
    if (!confirm(msg)) return;
    localStorage.removeItem('token');
    localStorage.removeItem('userToken');
    localStorage.removeItem('user');
    localStorage.removeItem('userRole');
    window.location.reload();
}

window.logout = logout;
