# Todo App - Flask Version with .env Support

This is a Flask-based version of the Todo App that supports `.env` file configuration.

## Why Flask?

The original version used nginx to serve static files with `env.js` for configuration. However, browsers can't read `.env` files directly. Flask solves this by:

1. Loading environment variables from `.env` server-side
2. Dynamically generating `env.js` with the correct values
3. Serving HTML templates and static files

## Setup Instructions

### File Structure

You need to organize your files like this:

```
.
├── app.py                    # Flask application
├── requirements.txt          # Python dependencies
├── Dockerfile.flask          # Docker configuration
├── docker-compose.flask.yml  # Docker Compose configuration
├── .env                      # Environment variables
├── templates/
│   ├── index.html           # Login page
│   └── app.html             # Main app page
└── static/
    ├── styles.css           # Styles
    ├── auth.js              # Authentication logic
    └── app.js               # Todo management logic
```

### Step 1: Create the directories

```bash
mkdir -p templates static
```

### Step 2: Move your HTML files

```bash
mv index.html templates/
mv app.html templates/
```

### Step 3: Move your static files

```bash
mv styles.css static/
mv auth.js static/
mv app.js static/
```

### Step 4: Configure your environment

Edit `.env` file:

```bash
API_URL=http://3.82.236.145:8000
SERVER_NUMBER=1
```

### Step 5: Run with Docker Compose

```bash
docker-compose -f docker-compose.flask.yml up -d
```

Or build and run manually:

```bash
docker build -f Dockerfile.flask -t todo-web-flask .
docker run -d -p 5000:5000 --env-file .env --name todo-web-flask todo-web-flask
```

### Step 6: Access the app

Open `http://localhost:5000` in your browser.

## Development Mode (without Docker)

```bash
# Install dependencies
pip install -r requirements.txt

# Run the app
python app.py
```

The app will be available at `http://localhost:5000`.

## How It Works

1. Flask loads environment variables from `.env` file using `python-dotenv`
2. When the browser requests `/env.js`, Flask dynamically generates it with the correct values
3. Your JavaScript files (`auth.js` and `app.js`) work exactly as before
4. No changes needed to your existing JS/CSS/HTML logic!

## Environment Variables

- `API_URL`: The URL of your Todo API backend (default: `http://3.82.236.145:8000`)
- `SERVER_NUMBER`: Display number for the server badge (default: `1`)

## Stopping the Application

```bash
docker-compose -f docker-compose.flask.yml down
```

## Advantages Over nginx

✅ Server-side environment variable management  
✅ Proper separation of config and code  
✅ Easy to add more features (API proxy, server-side rendering, etc.)  
✅ Still very simple and lightweight  
✅ Works with standard `.env` files  

## Note

You don't need `env.js` as a file anymore - Flask generates it dynamically from your `.env` file!
