"""
load_data.py
Loads all 9 Olist CSVs into the olist_ecommerce MySQL database.
Run this AFTER executing 01_schema.sql in MySQL Workbench.

Usage: python scripts/load_data.py
"""

import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus
import os
from dotenv import load_dotenv

# ------------------------------------------------------------
# 1. DB CONNECTION — reads from .env (never hardcode real credentials)
# ------------------------------------------------------------
load_dotenv()

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")

encoded_password = quote_plus(DB_PASSWORD)
engine = create_engine(
    f"mysql+mysqlconnector://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)

# ------------------------------------------------------------
# 2. FILE PATHS — adjust if your folder name differs
# ------------------------------------------------------------
DATA_DIR = "data/raw"

files_to_tables = [
    # (csv_filename, table_name) -- ORDER MATTERS (parents before children, due to FKs)
    ("olist_customers_dataset.csv", "customers"),
    ("olist_sellers_dataset.csv", "sellers"),
    ("product_category_name_translation.csv", "category_translation"),
    ("olist_products_dataset.csv", "products"),
    ("olist_orders_dataset.csv", "orders"),
    ("olist_order_items_dataset.csv", "order_items"),
    ("olist_order_payments_dataset.csv", "order_payments"),
    ("olist_order_reviews_dataset.csv", "order_reviews"),
    ("olist_geolocation_dataset.csv", "geolocation"),
]

# Columns that need to be converted to proper datetime before loading
DATE_COLUMNS = {
    "orders": [
        "order_purchase_timestamp",
        "order_approved_at",
        "order_delivered_carrier_date",
        "order_delivered_customer_date",
        "order_estimated_delivery_date",
    ],
    "order_items": ["shipping_limit_date"],
    "order_reviews": ["review_creation_date", "review_answer_timestamp"],
}


def patch_missing_categories(df):
    """
    The raw Olist data has a known gap: a handful of product_category_name
    values in the products file don't exist in the category_translation file
    (e.g. 'pc_gamer', 'portateis_cozinha_e_preparadores_de_alimentos').
    Since category_translation is a parent table (FK target), we insert any
    missing category names there first so the products load doesn't violate
    the foreign key.
    """
    categories_in_products = set(df["product_category_name"].dropna().unique())

    existing = pd.read_sql("SELECT product_category_name FROM category_translation", con=engine)
    existing_set = set(existing["product_category_name"])

    missing = categories_in_products - existing_set
    if missing:
        print(f"  Found {len(missing)} category name(s) missing from category_translation: {missing}")
        patch_df = pd.DataFrame({
            "product_category_name": list(missing),
            "product_category_name_english": list(missing),  # fallback: reuse original name
        })
        patch_df.to_sql("category_translation", con=engine, if_exists="append", index=False)
        print(f"  -> Patched {len(missing)} missing categories into category_translation.")
    else:
        print("  No missing categories found.")


def load_csv_to_table(csv_file, table_name):
    path = f"{DATA_DIR}/{csv_file}"
    print(f"Loading {csv_file} -> {table_name} ...")

    df = pd.read_csv(path)

    # Convert date columns if this table has any
    if table_name in DATE_COLUMNS:
        for col in DATE_COLUMNS[table_name]:
            if col in df.columns:
                df[col] = pd.to_datetime(df[col], errors="coerce")

    # De-duplicate geolocation (it has millions of duplicate zip/lat/lng rows in the raw file)
    if table_name == "geolocation":
        df = df.drop_duplicates(subset=["geolocation_zip_code_prefix"])

    # Fix known data gap: some product categories aren't in the translation table
    if table_name == "products":
        patch_missing_categories(df)

    df.to_sql(
        name=table_name,
        con=engine,
        if_exists="append",
        index=False,
        chunksize=5000,
    )
    print(f"  -> Done. {len(df)} rows loaded into {table_name}.")


if __name__ == "__main__":
    for csv_file, table_name in files_to_tables:
        load_csv_to_table(csv_file, table_name)

    print("\nAll tables loaded successfully.")