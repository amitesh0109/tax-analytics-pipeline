import duckdb
from pathlib import Path

print(Path(__file__).resolve().parents[2])

DB_PATH = Path(__file__).resolve().parents[2] / 'finance.duckdb'
conn = duckdb.connect(str(DB_PATH))

print('=== Tax Collections (top 5) ===')
rows = conn.execute('''SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'main'
''').fetchall()
for r in rows: print(r)