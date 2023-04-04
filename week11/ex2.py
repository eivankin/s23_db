from pymongo import MongoClient

from pprint import pprint

client = MongoClient("mongodb://localhost")
db = client["test"]


def insert():
    address = {"building": "126",
               "coord": [-73.9557413, 40.7720266],
               "street": "Sportivnaya",
               "zipcode": "420500"}
    grades = [{"date": "2023-04-04T00:00:00.000Z",
               "grade": "A", "score": 11}]
    return db.restaurants.insert_one({
        "address": address,
        "borough": "Innopolis",
        "cuisine": "Serbian",
        "name": "The Best Restaurant",
        "restaurant_id": 41712354,
        "grades": grades
    })


insert()
pprint(db.restaurants.find_one({"restaurant_id": 41712354}))
