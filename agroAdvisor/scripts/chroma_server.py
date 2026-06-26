#!/usr/bin/env python3
import json
from pathlib import Path
from fastapi import FastAPI
from sentence_transformers import SentenceTransformer
import chromadb

app = FastAPI()

# Load once at startup
model = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")
db_path = Path("data/chroma_db")
client = chromadb.PersistentClient(path=str(db_path))

try:
    collection = client.get_collection("diseases")
except:
    collection = None

@app.get("/search")
def search(problem: str, crop: str, region: str, top_k: int = 7):
    if not collection:
        return []
    
    query = f"{problem} {crop} kenya {region}"
    query_vec = model.encode(query).tolist()
    
    try:
        results = collection.query(
            query_embeddings=[query_vec],
            n_results=top_k,
            where={"crop": crop.lower()},
            include=["documents", "metadatas", "distances"]
        )
    except:
        results = collection.query(
            query_embeddings=[query_vec],
            n_results=top_k,
            include=["documents", "metadatas", "distances"]
        )
    
    if not results["ids"] or not results["ids"][0]:
        return []
    
    matches = []
    for i, disease_id in enumerate(results["ids"][0]):
        distance = results["distances"][0][i]
        similarity = round((1 - distance) * 100, 1)
        matches.append({
            "id": disease_id,
            "name": results["metadatas"][0][i].get("name", disease_id),
            "crop": results["metadatas"][0][i].get("crop", ""),
            "similarity": similarity
        })
    return matches

@app.get("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="localhost", port=8888)