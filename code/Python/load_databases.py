import sqlite3

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
