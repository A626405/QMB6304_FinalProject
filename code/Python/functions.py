import sqlite3

#Create A SQLite3 DB To Store Compressed RDA Datasets As Binary Entries. Indexed file_name. 
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
        
#Write Compressed RDA Datasets To Binary Entries In A SQLite3 Table Of DBs.
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

#Read A Dataset Stored As A Binary Entry In A Table Of Databases In A SQLite3 DB.
def read_db(path_to_db_char):
    try:
        if path_to_db_char is not None:
            conn = sqlite3.connect(path_to_db_char)
            cursor = conn.cursor()

            cursor.execute("SELECT data FROM databases WHERE file_name = ?", (path_to_db_char,))
            result = cursor.fetchone()

            conn.close()

            if result:
                binary_data = result[0]
                return binary_data
            else:
                print("No matching data found in the database.")
                return None
        else:
            print("Path, file name, or database path is missing.")
    except sqlite3.Error as e:
        print(f"An error occurred with SQLite: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
    
#Uses A DB To Match IPs & Fetch 'NA' Country Names.
def get_country(ip):
    reader = geoip2.database.Reader('data/external/GeoLite2-Country.mmdb')
    import geoip2
    import geoip2.database
    import pandas as pd
    
    try:
        response = reader.country(ip)
        return pd.DataFrame({'country':[response.country.name]})
    except:
        return pd.DataFrame({'country':[pd.NA]})
  
      
