from pymongo import MongoClient

from pprint import pprint

client = MongoClient("mongodb://localhost")
db = client["test"]


def irish_cuisines():
    return db.restaurants.find({"cuisine": "Irish"})


def irish_or_russian_cuisines():
    return db.restaurants.find({"cuisine": {"$in": ["Irish", "Russian"]}})


def with_address():
    return db.restaurants.find({"address.building": "284",
                                "address.street": "Prospect Park West",
                                "address.zipcode": "11215"})


print("=" * 5 + " " + "IRISH CUISINES" + " " + "=" * 5)
pprint(list(irish_cuisines()))
print()
print("=" * 5 + " " + "IRISH OR RUSSIAN CUISINES" + " " + "=" * 5)
pprint(list(irish_or_russian_cuisines()))
print()
print("=" * 5 + " " + "Prospect Park West 284, 11215" + " " + "=" * 5)
pprint(list(with_address()))
