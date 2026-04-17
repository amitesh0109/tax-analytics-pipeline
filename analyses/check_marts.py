import duckdb
from pathlib import Path

print(Path(__file__).resolve().parents[2])

DB_PATH = Path(__file__).resolve().parents[2] / 'finance.duckdb'
conn = duckdb.connect(str(DB_PATH))

print('=== Tax Collections (top 5) ===')
rows = conn.execute('''
    SELECT tax_type_cd, period_year, period_month,
           total_billed, total_collected, collection_rate_pct
    FROM mart_tax_collections
    ORDER BY period_year desc, period_month desc
    LIMIT 5
''').fetchall()
for r in rows: print(r)

print()
print('=== Account Balances - Top Debtors ===')
rows = conn.execute('''
    SELECT taxpayer_name, tax_type_cd, current_balance, debt_risk_flag
    FROM mart_account_balance
    WHERE debt_risk_flag = 'HIGH'
    ORDER BY current_balance desc
    LIMIT 5
''').fetchall()
for r in rows: print(r)

print()
print('=== PAYE Reconciliation - Non Compliant ===')
rows = conn.execute('''
    SELECT taxpayer_name, period_year, period_month,
           expected_paye, actual_paye, variance,
           compliance_rate_pct, compliance_status, payment_timing
    FROM mart_paye_reconciliation
    WHERE compliance_status = 'NON_COMPLIANT'
    ORDER BY variance desc
    LIMIT 5
''').fetchall()
for r in rows: print(r)

print()
print('=== PAYE Compliance Summary by Period ===')
rows = conn.execute('''
    SELECT period_year, period_month,
           count(*) as total_accounts,
           sum(case when compliance_status = 'COMPLIANT' then 1 else 0 end) as compliant,
           sum(case when compliance_status = 'PARTIAL' then 1 else 0 end) as partial,
           sum(case when compliance_status = 'NON_COMPLIANT' then 1 else 0 end) as non_compliant
    FROM mart_paye_reconciliation
    GROUP BY 1,2
    ORDER BY 1 desc, 2 desc
    LIMIT 6
''').fetchall()
for r in rows: print(r)

print()
print('=== VAT Summary - Refund Candidates ===')
rows = conn.execute('''
    SELECT taxpayer_name, period_year, period_month,
           output_vat, vat_collected, net_vat_payable, vat_status
    FROM mart_vat_summary
    WHERE vat_status = 'REFUND_CANDIDATE'
    ORDER BY net_vat_payable
    LIMIT 5
''').fetchall()
for r in rows: print(r)

print()
print('=== VAT Status Summary ===')
rows = conn.execute('''
    SELECT vat_status, count(*) as accounts,
           round(sum(net_vat_payable), 2) as total_net_vat
    FROM mart_vat_summary
    GROUP BY vat_status
    ORDER BY total_net_vat desc
''').fetchall()
for r in rows: print(r)

conn.close()