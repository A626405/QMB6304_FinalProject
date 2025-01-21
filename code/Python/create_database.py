import sqlite3

def create_db(db_path):
  try:
      if db_path:
        
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()

        cursor.execute('''
        CREATE TABLE IF NOT EXISTS databases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            file_name TEXT,
            data BLOB
        );''')

        cursor.execute("CREATE INDEX file_name_idx1 ON working_data(file_name);")

        conn.commit()
        cursor.execute("VACUUM;")
        conn.commit()
        conn.close()
        print("Database Successfully Created. Indexed by file_name.")
      else:
          print("Path, file name, or database path is missing.")
          
  except sqlite3.Error as e:
        print(f"An error occurred with SQLite: '{e}'")
  except FileNotFoundError:
        print(f"The specified file '{db_path}' does not exist.")
  except Exception as e:
        print(f"An unexpected error occurred: '{e}'")
