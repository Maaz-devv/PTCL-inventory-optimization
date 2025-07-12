#!/usr/bin/env python
# coding: utf-8

import os
import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime
from dateutil import parser
import logging

# ------------------------------
# LOGGING SETUP
# ------------------------------
os.makedirs("logs", exist_ok=True)
log_file = "logs/etl_log.txt"
logging.basicConfig(
    filename=log_file,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

try:
    logging.info("🚀 Starting ETL process")

    # ------------------------------
    # DATABASE CONFIG
    # ------------------------------
    db_user = "root"
    db_password = "ortonfan007!"
    db_host = "localhost"
    db_port = "3306"
    db_name = "ptcl_inventory"

    connection_string = f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    engine = create_engine(connection_string)

    # ------------------------------
    # LOAD CSV DATA
    # ------------------------------
    sheet1 = pd.read_csv('../data_raw/ptcl_sheet1.csv')
    sto1 = pd.read_csv('../data_raw/ptcl_sto1.csv')

    # ------------------------------
    # CLEAN COLUMN NAMES
    # ------------------------------
    def clean_column_names(df):
        return df.rename(columns=lambda col: col.strip().lower().replace(" ", "_").replace(".", "").replace("/", "_"))

    sheet1_clean = clean_column_names(sheet1)
    sto1_clean = clean_column_names(sto1)

    # ------------------------------
    # DROP DUPLICATES
    # ------------------------------
    sheet1_clean.drop_duplicates(subset=['plant', 'purchase_order', 'material', 'posting_date'], inplace=True)
    sto1_clean.drop_duplicates(subset=['plant', 'purchase_order', 'material', 'posting_date'], inplace=True)

    # ------------------------------
    # FLEXIBLE DATE PARSING
    # ------------------------------
    def parse_date_flexibly(val):
        try:
            if pd.isna(val) or str(val).strip() == "":
                return pd.NaT
            return parser.parse(str(val), dayfirst=True)
        except Exception:
            return pd.NaT

    sheet1_date_cols = ['posting_date', 'document_date', 'entry_date']
    sto1_date_cols = ['posting_date', 'document_date', 'entry_date', 'deliv_date', 'gr_posting_date']

    for col in sheet1_date_cols:
        sheet1_clean[col] = sheet1_clean[col].apply(parse_date_flexibly)

    for col in sto1_date_cols:
        if col in sto1_clean.columns:
            sto1_clean[col] = sto1_clean[col].apply(parse_date_flexibly)

    # ------------------------------
    # FIX COLUMN NAMES
    # ------------------------------
    sheet1_clean.rename(columns={'amtin_loccur': 'amt_in_loc_cur'}, inplace=True)
    sto1_clean.rename(columns={'amtin_loccur': 'amt_in_loc_cur'}, inplace=True)

    # ------------------------------
    # SCHEMA VALIDATION
    # ------------------------------
    def validate_columns(df, expected_columns, df_name="DataFrame"):
        actual = set(df.columns)
        expected = set(expected_columns)
        missing = expected - actual
        extra = actual - expected
        if missing:
            logging.error(f"❌ {df_name} is missing columns: {missing}")
        if extra:
            logging.warning(f"⚠️  {df_name} has extra columns: {extra}")
        if not missing and not extra:
            logging.info(f"✅ {df_name} columns are valid.")

    expected_sheet1_columns = [
        'plant', 'storage_location', 'purchase_order', 'material', 'material_description',
        'reference', 'quantity', 'unit_of_entry', 'posting_date', 'amt_in_loc_cur',
        'movement_type', 'user_name', 'document_date', 'entry_date'
    ]

    expected_sto1_columns = [
        'plant', 'storage_location', 'purchase_order', 'material', 'material_description',
        'reference', 'quantity', 'unit_of_entry', 'posting_date', 'amt_in_loc_cur',
        'movement_type', 'user_name', 'document_date', 'entry_date',
        'receiving_plant', 'deliv_date', 'gr_posting_date'
    ]

    validate_columns(sheet1_clean, expected_sheet1_columns, "sheet1_clean")
    validate_columns(sto1_clean, expected_sto1_columns, "sto1_clean")

    # ------------------------------
    # INGESTION DATE
    # ------------------------------
    today = datetime.today().strftime('%Y-%m-%d')
    sheet1_clean["ingestion_date"] = today
    sto1_clean["ingestion_date"] = today

    # ------------------------------
    # FILTER OUT EXISTING ROWS
    # ------------------------------
    existing_sheet1 = pd.read_sql("SELECT plant, purchase_order, material, posting_date FROM raw_sheet1", engine)
    sheet1_clean = pd.merge(sheet1_clean, existing_sheet1, on=['plant', 'purchase_order', 'material', 'posting_date'], how='left', indicator=True)
    sheet1_clean = sheet1_clean[sheet1_clean['_merge'] == 'left_only'].drop(columns=['_merge'])

    existing_sto1 = pd.read_sql("SELECT plant, purchase_order, material, posting_date FROM raw_sto1", engine)
    sto1_clean = pd.merge(sto1_clean, existing_sto1, on=['plant', 'purchase_order', 'material', 'posting_date'], how='left', indicator=True)
    sto1_clean = sto1_clean[sto1_clean['_merge'] == 'left_only'].drop(columns=['_merge'])

    # ------------------------------
    # LOAD INTO MYSQL
    # ------------------------------
    if not sheet1_clean.empty:
        sheet1_clean.to_sql('raw_sheet1', con=engine, if_exists='append', index=False)
        logging.info(f"✅ {len(sheet1_clean)} rows loaded into raw_sheet1")
    else:
        logging.info("🟡 No new rows to load into raw_sheet1")

    if not sto1_clean.empty:
        sto1_clean.to_sql('raw_sto1', con=engine, if_exists='append', index=False)
        logging.info(f"✅ {len(sto1_clean)} rows loaded into raw_sto1")
    else:
        logging.info("🟡 No new rows to load into raw_sto1")

    logging.info("🎉 ETL process completed successfully!")

except Exception as e:
    logging.error("❌ ETL process failed:")
    logging.error(str(e))
