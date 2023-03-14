# create db
# psql -d template1
import psycopg2
from faker import Faker
from tqdm import tqdm

# https://stackabuse.com/working-with-postgresql-in-python/
con = psycopg2.connect(database="gino", user="test_user",
                       password="example", host="127.0.0.1", port="5000")

print("Database opened successfully")
cur = con.cursor()
cur.execute('''DROP TABLE IF EXISTS CUSTOMER;''')
cur.execute('''CREATE TABLE CUSTOMER
       (ID INT PRIMARY KEY     NOT NULL,
       Name           TEXT    NOT NULL,
       Address            TEXT     NOT NULL,
       review        TEXT);''')
print("Table created successfully")
fake = Faker()
for i in tqdm(range(10 ** 5)):
    cur.execute(
        "INSERT INTO CUSTOMER (ID,Name,Address,review) VALUES ('"
        + str(i) + "','" + fake.name() + "','" + fake.address() + "','" +
        fake.text() + "')")
    con.commit()
