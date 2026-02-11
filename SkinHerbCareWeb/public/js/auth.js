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

    const guestNav = document.getElementById('guest-nav');
    const adminNav = document.getElementById('admin-nav');
    const adminLink = document.querySelector('#admin-nav a[href="/admin-dashboard.html"]');

    const isLoggedIn = Boolean(token && userRaw);
    if (guestNav) guestNav.style.display = isLoggedIn ? 'none' : 'flex';
    if (adminNav) adminNav.style.display = isLoggedIn ? 'flex' : 'none';
    if (adminLink) adminLink.style.display = userRole === 'admin' ? 'inline-flex' : 'none';
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
