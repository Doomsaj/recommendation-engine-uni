from database import DatabaseConnection
from engine import ProductRecommendationEngine
import pickle
import os
from dotenv import load_dotenv

load_dotenv()

def get_database_connection():
    db = DatabaseConnection(
        host=os.getenv('DB_HOST', 'localhost'),
        database=os.getenv('DB_NAME', 'ecommerce_db'),
        user=os.getenv('DB_USER', 'root'),
        password=os.getenv('DB_PASSWORD', 'password')
    )
    db.connect()
    return db

connection = get_database_connection()
orders_df = connection.fetch_orders()
products_df = connection.fetch_products()

print("Initializing recommendation engine...")
engine = ProductRecommendationEngine()

print("Preparing data...")
engine.prepare_data(orders_df, products_df)

print("Training model...")
engine.train()

print("Saving model...")
with open('recommendation_model.pkl', 'wb') as f:
    pickle.dump(engine, f)

print("✅ Model trained and saved successfully!")