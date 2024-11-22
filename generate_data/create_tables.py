from sqlalchemy import create_engine, text, inspect
from sqlalchemy.orm import sessionmaker
import os

# Database connection parameters
DB_NAME = "dbm-db"
DB_USER = "postgres"
DB_PASSWORD = "bse1234"
DB_HOST = "localhost"
DB_PORT = "5432"

# Create a SQLAlchemy engine
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(DATABASE_URL)

# Function to execute an SQL file
def execute_sql_file(file_path):
    with open(file_path, 'r') as file:
        sql_code = file.read()
        with engine.connect() as connection:
            try:
                connection.execute(text(sql_code))
                connection.commit()  # Commit the transaction
                print(f"Executed SQL file: {file_path}")
            except Exception as e:
                print(f"Error executing {file_path}: {e}")

def drop_all_tables():
    inspector = inspect(engine)
    with engine.connect() as connection:
        transaction = connection.begin()
        try:
            for table_name in inspector.get_table_names():
                connection.execute(text(f"DROP TABLE IF EXISTS {table_name} CASCADE"))
            transaction.commit()
            print("Dropped all existing tables.")
        except Exception as e:
            transaction.rollback()
            print(f"Error dropping tables: {e}")

# Main function to create tables
def create_tables():
    directory = 'tables'
    files_path = sorted([os.path.join(directory, file) for file in os.listdir(directory) if file.endswith('.sql')])

    for file_path in files_path:
        execute_sql_file(file_path)

if __name__ == "__main__":
    drop_all_tables()
    create_tables()
