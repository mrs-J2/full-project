// Display server number
document.getElementById('serverNumber').textContent = ENV.SERVER_NUMBER;

// Check if already logged in (from sessionStorage)
if (sessionStorage.getItem('authToken')) {
    window.location.href = 'app.html';
}

// Tab switching
function showLogin() {
    document.getElementById('loginForm').style.display = 'block';
    document.getElementById('registerForm').style.display = 'none';
    document.querySelectorAll('.tab')[0].classList.add('active');
    document.querySelectorAll('.tab')[1].classList.remove('active');
    hideError('loginError');
    hideError('registerError');
}

function showRegister() {
    document.getElementById('loginForm').style.display = 'none';
    document.getElementById('registerForm').style.display = 'block';
    document.querySelectorAll('.tab')[0].classList.remove('active');
    document.querySelectorAll('.tab')[1].classList.add('active');
    hideError('loginError');
    hideError('registerError');
}

function showError(elementId, message) {
    const errorElement = document.getElementById(elementId);
    errorElement.textContent = message;
    errorElement.classList.add('show');
}

function hideError(elementId) {
    const errorElement = document.getElementById(elementId);
    errorElement.classList.remove('show');
}

// Login form handler
document.getElementById('loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    hideError('loginError');
    
    const username = document.getElementById('loginUsername').value;
    const password = document.getElementById('loginPassword').value;
    
    try {
        const response = await fetch(`${ENV.API_URL}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            sessionStorage.setItem('authToken', data.token);
            sessionStorage.setItem('userData', JSON.stringify({ id: data.id, username: data.username }));
            window.location.href = 'app.html';
        } else {
            showError('loginError', data.error?.message || 'Login failed');
        }
    } catch (error) {
        showError('loginError', 'Network error. Please try again.');
    }
});

// Register form handler
document.getElementById('registerForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    hideError('registerError');
    
    const username = document.getElementById('registerUsername').value;
    const password = document.getElementById('registerPassword').value;
    
    try {
        const response = await fetch(`${ENV.API_URL}/auth/register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ username, password })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            sessionStorage.setItem('authToken', data.token);
            sessionStorage.setItem('userData', JSON.stringify({ id: data.id, username: data.username }));
            window.location.href = 'app.html';
        } else {
            showError('registerError', data.error?.message || 'Registration failed');
        }
    } catch (error) {
        showError('registerError', 'Network error. Please try again.');
    }
});
