# Tax Authority Financial Analytics Pipeline

End-to-end ELT pipeline for tax authority using Python, dbt, PostgreSQL and Google BigQuery. Implements a medallion architecture (Bronze → Silver → Gold)
with automated data quality tests across VAT, PAYE, and Corporate Income Tax domains.

## Architecture

Raw CSV Seeds (Bronze)
↓
Staging Models — stg_ft_ledger, stg_taxpayer_account,
stg_tax_period, stg_payment (Silver)
↓
Mart Models — mart_tax_collections, mart_account_balance,
mart_paye_reconciliation, mart_vat_summary (Gold)

## Tech Stack

- **dbt Core** — data transformation and testing
- **DuckDB** — local analytical database
- **Python** — seed data generation and validation queries
- **SQL** — window functions, CTEs, aggregations

## Data Model

### Source tables (seeds)
| Table | Rows | Description |
|---|---|---|
| `ft_ledger` | 1,183 | Financial transactions — bills, payments, penalties, adjustments |
| `taxpayer_account` | 50 | Taxpayer accounts across VAT, PAYE, CIT |
| `tax_period` | 36 | Monthly tax periods 2022–2024 |
| `payment` | 428 | Payment records linked to ledger entries |

### Gold marts
| Mart | Description |
|---|---|
| `mart_tax_collections` | Tax collected by type and period with collection rate % |
| `mart_account_balance` | Outstanding balance per taxpayer with debt risk flag |
| `mart_paye_reconciliation` | Expected vs actual PAYE with compliance status |
| `mart_vat_summary` | VAT collected, outstanding, and refund candidates |

## Key Business Insights Produced

- VAT collection rate of 49% in Dec 2024 flagged for collections team
- 23 VAT refund candidates totalling KES 286,928 identified
- PAYE non-compliance tracked per account per period with late payment flag
- Top debtor accounts ranked by outstanding balance with risk classification

## Data Quality

15 automated dbt tests across staging layer covering:
- Uniqueness and not-null constraints on all primary keys
- Accepted values validation on `ft_type_cd` and `tax_type_cd`

```bash
dbt test --no-partial-parse
# PASS=15 WARN=0 ERROR=0
```

## How to Run

```bash
# 1. Clone the repo
git clone https://github.com/YOUR_USERNAME/tax-analytics-pipeline.git
cd tax-analytics-pipeline

# 2. Create virtual environment
python3 -m venv venv
source venv/bin/activate

# 3. Install dependencies
pip install dbt-duckdb

# 4. Configure profiles.yml
# Copy .dbt/profiles.yml.example to ~/.dbt/profiles.yml
# Update the path to point to your local finance.duckdb

# 5. Load seed data and run models
dbt seed
dbt run
dbt test

# 6. Validate outputs
python3 analyses/check_marts.py
```

## Background

This project is modelled on real financial transaction patterns from enterprise
billing and revenue management systems. The data structures mirror production
tax authority implementations — ft_type_cd, period-based billing cycles,
payment matching, and compliance tracking are all based on real-world patterns.
