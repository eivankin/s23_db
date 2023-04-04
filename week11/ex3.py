from pymongo import MongoClient
from pymongo.results import DeleteResult

from pprint import pprint

client = MongoClient("mongodb://localhost")
db = client["test"]


def delete_one() -> DeleteResult:
    return db.restaurants.delete_one({"borough": "Manhattan"})


def delete_many() -> DeleteResult:
    return db.restaurants.delete_many({"cuisine": "Thai"})


print("=" * 5 + " " + "ONE MANHATTAN" + " " + "=" * 5)
pprint(delete_one().raw_result)
print()
print("=" * 5 + " " + "ALL THAI" + " " + "=" * 5)
pprint(delete_many().raw_result)
