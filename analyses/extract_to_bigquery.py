import pandas as pd
import random
from datetime import date, timedelta
from google.cloud import bigquery
from pathlib import Path

random.seed(99)

PROJECT_ID = "dbt-finance-project"
DATASET_ID = "dbt_finance"
TABLE_ID = "raw_transactions"

def generate_transactions(n=50):
    """Simulate extracting fresh transactions from a source system like ORMB."""
    tax_types = ['VAT', 'PAYE', 'CIT']
    ft_types = ['BILL', 'PAY', 'PEN']
    accounts = [f'ACCT{i:04d}' for i in range(1, 51)]
    periods = [f'PER{y}{m:02d}' for y in [2025] for m in range(1, 5)]

    rows = []
    for i in range(n):
        ft_type = random.choice(ft_types)
        amount = round(random.uniform(1000, 100000), 2)
        if ft_type == 'PAY':
            amount = -amount
        rows.append({
            'ft_id':        f'FT_NEW_{i+1:05d}',
            'account_id':   random.choice(accounts),
            'period_id':    random.choice(periods),
            'tax_type_cd':  random.choice(tax_types),
            'ft_type_cd':   ft_type,
            'amount':       amount,
            'currency_cd':  'KES',
            'ft_date':      str(date(2025, random.randint(1,4), random.randint(1,28))),
            'status':       'FROZEN',
            'source_system': 'ORMB_API',
            'extracted_at': str(date.today()),
        })
    return pd.DataFrame(rows)

def load_to_bigquery(df):
    """Load extracted data into BigQuery raw table."""
    client = bigquery.Client(project=PROJECT_ID)
    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{TABLE_ID}"

    job_config = bigquery.LoadJobConfig(
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
        autodetect=True,
    )

    job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()

    table = client.get_table(table_ref)
    print(f"Loaded {table.num_rows} rows to {table_ref}")
    return table.num_rows

def main():
    print("Step 1: Extracting transactions from source system...")
    df = generate_transactions(n=50)
    print(f"Extracted {len(df)} rows")
    print(df[['ft_id', 'account_id', 'tax_type_cd', 'ft_type_cd', 'amount']].head())

    print("\nStep 2: Loading to BigQuery...")
    rows_loaded = load_to_bigquery(df)
    print(f"Done. {rows_loaded} rows now in {PROJECT_ID}.{DATASET_ID}.{TABLE_ID}")
    print("\nNext step: run dbt to transform this raw data.")

if __name__ == "__main__":
    main()