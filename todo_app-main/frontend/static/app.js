// Get auth data from sessionStorage
let authToken = sessionStorage.getItem('authToken');
let userData = null;

try {
    const userDataStr = sessionStorage.getItem('userData');
    if (userDataStr) {
        userData = JSON.parse(userDataStr);
    }
} catch (e) {
    console.error('Error parsing user data');
}

// Display server number
document.getElementById('serverNumber').textContent = ENV.SERVER_NUMBER;

let currentFilter = 'all';
let todos = [];

// Check authentication
if (!authToken) {
    window.location.href = 'index.html';
}

// Display username
if (userData) {
    document.getElementById('username').textContent = userData.username;
}

// Logout function
function logout() {
    sessionStorage.removeItem('authToken');
    sessionStorage.removeItem('userData');
    window.location.href = 'index.html';
}

// Fetch all todos
async function fetchTodos() {
    try {
        let url = `${ENV.API_URL}/todos`;
        if (currentFilter !== 'all') {
            url += `?status=${currentFilter}`;
        }
        
        const response = await fetch(url, {
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok) {
            const data = await response.json();
            todos = data.todos || [];
            renderTodos();
        } else if (response.status === 401) {
            logout();
        }
    } catch (error) {
        console.error('Error fetching todos:', error);
    }
}

// Render todos
function renderTodos() {
    const todoList = document.getElementById('todoList');
    const emptyState = document.getElementById('emptyState');
    
    if (todos.length === 0) {
        todoList.innerHTML = '';
        emptyState.style.display = 'block';
        return;
    }
    
    emptyState.style.display = 'none';
    
    todoList.innerHTML = todos.map(todo => `
        <div class="todo-item ${todo.completed ? 'completed' : ''}">
            <div class="todo-header">
                <input type="checkbox" 
                       class="todo-checkbox" 
                       ${todo.completed ? 'checked' : ''} 
                       onchange="toggleTodo('${todo.id}', ${!todo.completed})">
                <div class="todo-title">${escapeHtml(todo.title)}</div>
                <div class="todo-actions">
                    <button class="btn-delete" onclick="deleteTodo('${todo.id}')">Delete</button>
                </div>
            </div>
            ${todo.description ? `<div class="todo-description">${escapeHtml(todo.description)}</div>` : ''}
            <div class="todo-date">Created: ${formatDate(todo.createdAt)}</div>
        </div>
    `).join('');
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
}

// Add todo
document.getElementById('addTodoForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const title = document.getElementById('todoTitle').value;
    const description = document.getElementById('todoDescription').value;
    
    try {
        const response = await fetch(`${ENV.API_URL}/todos`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ 
                title, 
                description: description || undefined 
            })
        });
        
        if (response.ok) {
            document.getElementById('todoTitle').value = '';
            document.getElementById('todoDescription').value = '';
            await fetchTodos();
        } else if (response.status === 401) {
            logout();
        }
    } catch (error) {
        console.error('Error adding todo:', error);
    }
});

// Toggle todo completion
async function toggleTodo(id, completed) {
    try {
        const response = await fetch(`${ENV.API_URL}/todos/${id}`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${authToken}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ completed })
        });
        
        if (response.ok) {
            await fetchTodos();
        } else if (response.status === 401) {
            logout();
        }
    } catch (error) {
        console.error('Error updating todo:', error);
    }
}

// Delete todo
async function deleteTodo(id) {
    if (!confirm('Are you sure you want to delete this todo?')) {
        return;
    }
    
    try {
        const response = await fetch(`${ENV.API_URL}/todos/${id}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${authToken}`
            }
        });
        
        if (response.ok || response.status === 204) {
            await fetchTodos();
        } else if (response.status === 401) {
            logout();
        }
    } catch (error) {
        console.error('Error deleting todo:', error);
    }
}

// Filter todos
function filterTodos(filter) {
    currentFilter = filter;
    
    // Update active button
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    event.target.classList.add('active');
    
    fetchTodos();
}

// Initial load
fetchTodos();
