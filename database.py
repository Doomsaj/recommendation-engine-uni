import mysql.connector
from mysql.connector import Error
import pandas as pd
from contextlib import contextmanager

class DatabaseConnection:

    def __init__(self, host='localhost', database='ecommerce_db', user='root', password='your_password'):
        self.host = host
        self.database = database
        self.user = user
        self.password = password
        self.connection = None

    def connect(self):
        try:
            self.connection = mysql.connector.connect(
                host=self.host,
                database=self.database,
                user=self.user,
                password=self.password
            )
            if self.connection.is_connected():
                print(f"✅ Successfully connected to MySQL database: {self.database}")
                return self.connection
        except Error as e:
            print(f"❌ Error connecting to MySQL: {e}")
            return None

    def disconnect(self):
        if self.connection and self.connection.is_connected():
            self.connection.close()
            print("🔌 Database connection closed")

    @contextmanager
    def get_cursor(self):
        cursor = self.connection.cursor(dictionary=True)
        try:
            yield cursor
            self.connection.commit()
        except Error as e:
            self.connection.rollback()
            print(f"❌ Database error: {e}")
            raise
        finally:
            cursor.close()

    def execute_query(self, query, params=None):
        try:
            with self.get_cursor() as cursor:
                cursor.execute(query, params or ())
                return cursor.fetchall()
        except Error as e:
            print(f"❌ Query execution error: {e}")
            return None

    def execute_many(self, query, data):
        try:
            with self.get_cursor() as cursor:
                cursor.executemany(query, data)
                print(f"✅ Inserted {cursor.rowcount} rows")
        except Error as e:
            print(f"❌ Bulk insert error: {e}")

    def fetch_orders(self):
        query = """
            SELECT user_id, product_id, order_date, quantity
            FROM orders
            ORDER BY order_date DESC
        """
        result = self.execute_query(query)
        return pd.DataFrame(result) if result else pd.DataFrame()

    def fetch_products(self):
        query = """
            SELECT product_id, name, category, price, brand, tags, stock_quantity
            FROM products
            WHERE is_active = 1
        """
        result = self.execute_query(query)
        return pd.DataFrame(result) if result else pd.DataFrame()

    def fetch_user_orders(self, user_id):
        query = """
            SELECT o.order_id, o.product_id, p.name, p.category, p.price, 
                   o.quantity, o.order_date
            FROM orders o
            JOIN products p ON o.product_id = p.product_id
            WHERE o.user_id = %s
            ORDER BY o.order_date DESC
        """
        result = self.execute_query(query, (user_id,))
        return pd.DataFrame(result) if result else pd.DataFrame()

    def get_product_details(self, product_ids):
        if not product_ids:
            return pd.DataFrame()

        placeholders = ', '.join(['%s'] * len(product_ids))
        query = f"""
            SELECT product_id, name, category, price, brand, tags, 
                   description, stock_quantity
            FROM products
            WHERE product_id IN ({placeholders})
        """
        result = self.execute_query(query, tuple(product_ids))
        return pd.DataFrame(result) if result else pd.DataFrame()