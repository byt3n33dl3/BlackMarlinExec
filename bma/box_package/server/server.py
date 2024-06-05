from pymongo import MongoClient
from fastapi import FastAPI
from fastapi import FastAPI
 
app = FastAPI()
 
@app.get("/")
def root ():
  return {"message": "Hello World!"}

@app.get("/my-first-api")
def hello():
  cluster = MongoClient("mongodb://root:example@127.0.0.1:27018/")
  db = cluster.get_database("test_db")
  col = db.get_collection("test_col")
  col.insert_one({"field1": "value 1"})
  return {"Hello world!"}
