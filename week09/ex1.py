from time import sleep

import psycopg2
from geopy.geocoders import Nominatim

conn = psycopg2.connect(
    host="127.0.0.1",
    database="dvdrental",
    user="test_user",
    password="example", port="5000", connect_timeout=3)
cur = conn.cursor()


def get_parts(address_contains, city_id_from, city_id_to):
    cur.callproc('get_parts', (address_contains, city_id_from, city_id_to))

    return cur.fetchall()


addresses = get_parts("11", 400, 600)
print(addresses)

cur.execute("""
alter table address add column latitude decimal(10,7);
alter table address add column longitude decimal(10,7);
""")

for address in addresses:
    geolocator = Nominatim(user_agent="sussmany", timeout=5)
    location = geolocator.geocode(address)
    if location is not None:
        cur.execute(
            "UPDATE address SET latitude=(%s), longitude=(%s) WHERE address = (%s)",
            (location.latitude, location.longitude, address,))
    else:
        cur.execute(
            "UPDATE address SET latitude=(%s), longitude=(%s) WHERE address = (%s)",
            (0, 0, address,))

conn.commit()

cur.close()
conn.close()
