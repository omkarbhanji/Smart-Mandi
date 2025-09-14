import pandas as pd
import psycopg2

# Load dataset
df = pd.read_csv("Agriculture_price_dataset.csv")

# Keep only unique markets
unique_markets = df[['STATE', 'District Name', 'Market Name']].drop_duplicates()

# Insert into DB
conn = psycopg2.connect(
    dbname="smartmandi",
    user="postgres",
    password="root",
    host="localhost",
    port="5432"
)
cur = conn.cursor()

for _, row in unique_markets.iterrows():
    cur.execute(
        """
        INSERT INTO markets (name, state, district, address)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT DO NOTHING;
        """,
        (row['Market Name'], row['STATE'], row['District Name'], None)
    )

conn.commit()
cur.close()
conn.close()
