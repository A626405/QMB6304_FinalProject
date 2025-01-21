import sqlite3

conn = sqlite3.connect('../../data/internal/datasets.db')
cursor = conn.cursor()

cursor.execute('''
CREATE TABLE IF NOT EXISTS databases (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_name TEXT,
    data BLOB
);
''')

with open('data/internal/working_data.RDA', 'rb') as f:
  binary_data = f.read()

cursor.execute('''
INSERT INTO databases (file_name, data) VALUES (?, ?)
''', ('working_data.RDA', binary_data))

conn.commit()
cursor.execute("VACUUM;")
conn.commit()
conn.close()
