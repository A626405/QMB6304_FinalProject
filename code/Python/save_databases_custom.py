import sqlite3

def write_db(rda_path,rda_name,db_path,tbl_name):
  try:
    if rda_path and rda_name and db_path and tbl_name:
    
      with open(rda_path, 'rb') as f:
        binary_data = f.read()

      conn = sqlite3.connect(db_path)
      cursor = conn.cursor()

      cursor.execute(f"INSERT INTO {tbl_name} (file_name, data) VALUES (?, ?)", (rda_name, binary_data))

      conn.commit()
      cursor.execute("VACUUM;")
      conn.commit()
      conn.close()
      print("Dataframe Successfully Uploaded Into The Database")
      
    else:
        print('Path or file name is missing.')
            
  except sqlite3.Error as e:
    print(f"An error occurred with SQLite: '{e}'")
  except FileNotFoundError:
    print(f"The specified file '{rda_path}' does not exist.")
  except FileNotFoundError:
    print(f"The specified file '{db_path}' does not exist.")
  except Exception as e:
    print(f"An unexpected error occurred: '{e}'")

