from pymongo import MongoClient

client = MongoClient("mongodb://localhost")
db = client["test"]


def update_restaurants():
    grade_to_add = {"date": "2023-04-04T00:00:00.000Z",
                    "grade": "A", "score": 11}
    num_updated = 0
    num_deleted = 0
    for r in db.restaurants.find({"address.street": "Prospect Park West"}):
        num_of_a = len([g for g in r["grades"] if g["grade"] == "A"])
        restaurant_id = {"_id": r["_id"]}
        if num_of_a > 1:
            assert db.restaurants.delete_one(restaurant_id).deleted_count == 1
            num_deleted += 1
        else:
            assert db.restaurants.update_one(restaurant_id,
                                             {"$push": {"grades": grade_to_add}}).modified_count > 0
            num_updated += 1
    print(f"Updated {num_updated} restaurants, deleted {num_deleted}")


update_restaurants()
