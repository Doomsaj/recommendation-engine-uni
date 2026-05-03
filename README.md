# 📦 Product Recommendation API

This project is a Flask-based API that provides product recommendations using a trained machine learning model and a MySQL database.

---

# 🚀 Features

* Hybrid recommendation system
* Trending products endpoint
* MySQL-backed data source
* Offline model training (`train.py`)

---

# 📡 Available APIs

## 1. Get User Recommendations

```http
GET /recommendations/<user_id>?limit=10
```

### Example:

```http
GET /recommendations/1?limit=5
```

### Response:

```json
{
  "user_id": 1,
  "recommendations": [...]
}
```

---

## 2. Get Trending Products

```http
GET /trending?days=30&limit=10
```

### Example:

```http
GET /trending?days=7&limit=5
```

### Response:

```json
{
  "trending": [...]
}
```

---

# 🐳 Setup with Docker

## 1. Build and run containers

```bash
docker compose up --build
```

This will:

* Start MySQL database
* Seed database using `init.sql`
* Train the model using `train.py`
* Run the API (`api.py`)

---

## 2. Access API

```
http://localhost:5000
```

---

## 3. Stop services

```bash
docker compose down
```

---

# 🧪 Setup without Docker

Follow these steps manually:

---

## 1. Configure Database

Edit your database connection inside:

```
database.py
```

Set your:

* Host
* Username
* Password
* Database name

---

## 2. Seed Database

Run your SQL file:

```bash
mysql -u <user> -p <database_name> < init.sql
```

---

## 3. Train Model

```bash
python train.py
```

This will generate:

```
recommendation_model.pkl
```

---

## 4. Run API

```bash
python api.py
```

---

## 5. Access API

```
http://localhost:5000
```

---

# ⚙️ Notes

* Make sure MySQL is running before training or starting the API
* The model file (`recommendation_model.pkl`) must exist before running the API
* Default API port: `5000`

---