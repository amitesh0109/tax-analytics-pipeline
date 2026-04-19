## Tech Stack

- **Python** — extraction script, data simulation, BigQuery client
- **dbt Core** — data transformation, testing, documentation
- **Google BigQuery** — cloud data warehouse
- **PostgreSQL** — local data warehouse (Docker)
- **DuckDB** — local development database
- **Apache Airflow** — pipeline orchestration (DAG defined)
- **Docker** — containerised local environment
- **DBeaver** — database exploration and querying

## Branches

| Branch | Description |
|---|---|
| `main` | Original pipeline using DuckDB locally |
| `bigquery` | Full ELT pipeline running on Google BigQuery |

## Data Model

### Source tables
| Table | Rows | Description |
|---|---|---|
| `raw_transactions` | 50+ | Fresh transactions extracted by Python script |
| `ft_ledger` | 1,183 | Historical financial transactions (seed) |
| `taxpayer_account` | 50 | Taxpayer accounts across VAT, PAYE, CIT |
| `tax_period` | 36 | Monthly tax periods 2022–2024 |
| `payment` | 428 | Payment records linked to ledger entries |

### Staging models (Silver)
| Model | Description |
|---|---|
| `stg_ft_ledger` | Cleaned historical transaction ledger |
| `stg_raw_transactions` | Cleaned freshly extracted transactions |
| `stg_taxpayer_account` | Cleaned taxpayer account data |
| `stg_tax_period` | Tax period reference data |
| `stg_payment` | Cleaned payment records |

### Gold marts
| Mart | Description |
|---|---|
| `mart_tax_collections` | Tax collected by type and period with collection rate % |
| `mart_account_balance` | Outstanding balance per taxpayer with debt risk flag |
| `mart_paye_reconciliation` | Expected vs actual PAYE with compliance status |
| `mart_vat_summary` | VAT collected, outstanding, and refund candidates |

## Key Business Insights Produced

- VAT collection rate of 49% in Dec 2024 flagged for collections team
- KES 22 million outstanding across 128 accounts
- 23 VAT refund candidates totalling KES 286,928
- PAYE non-compliance tracked per account per period with late payment flag
- Top debtor accounts ranked by outstanding balance with risk classification

## Data Quality

15 automated dbt tests across staging layer:
- Uniqueness and not-null constraints on all primary keys
- Accepted values validation on `ft_type_cd` and `tax_type_cd`

```bash
dbt test
# PASS=15 WARN=0 ERROR=0
```

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/amitesh0109/tax-analytics-pipeline.git
cd tax-analytics-pipeline
git checkout bigquery

# 2. Create virtual environment
python3 -m venv venv
source venv/bin/activate

# 3. Install dependencies
pip install dbt-bigquery google-cloud-bigquery pandas

# 4. Authenticate with Google Cloud
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/cloud-platform

# 5. Configure profiles.yml
# Copy profiles.yml.example to ~/.dbt/profiles.yml
# Update project and dataset to match your GCP project

# 6. Extract and load fresh data
python3 analyses/extract_to_bigquery.py

# 7. Run dbt pipeline
dbt seed
dbt run
dbt test
```

## Background

This project is modelled on real financial transaction patterns from enterprise
billing and revenue management systems. The data structures mirror production
tax authority implementations — ft_type_cd, period-based billing cycles,
payment matching, and compliance tracking are all based on 3+ years of
experience implementing enterprise revenue management systems.

The pipeline has been tested against three databases — DuckDB (local development),
PostgreSQL (Docker), and Google BigQuery (cloud) — demonstrating database
portability using dbt's adapter pattern.