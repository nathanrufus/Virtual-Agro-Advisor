#!/usr/bin/env python3
import sys
import json
from pathlib import Path
import os

# Cache the model globally so it loads only once
_MODEL = None
_COLLECTION = None

def get_model():
    """Load model once and cache it"""
    global _MODEL
    if _MODEL is None:
        from sentence_transformers import SentenceTransformer
        _MODEL = SentenceTransformer("paraphrase-multilingual-MiniLM-L12-v2")
    return _MODEL

def get_collection():
    """Load collection once and cache it"""
    global _COLLECTION
    if _COLLECTION is None:
        import chromadb
        db_path = Path("data/chroma_db")
        if not db_path.exists():
            return None
        client = chromadb.PersistentClient(path=str(db_path))
        try:
            _COLLECTION = client.get_collection("diseases")
        except Exception:
            return None
    return _COLLECTION

def search(problem: str, crop: str, region: str, top_k: int = 7) -> list:
    """Search ChromaDB using cached model"""
    db_path = Path("data/chroma_db")
    if not db_path.exists():
        return []

    model = get_model()
    collection = get_collection()
    
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
    except Exception:
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

def main():
    if len(sys.argv) < 4:
        print(json.dumps([]))
        sys.exit(0)

    problem = sys.argv[1]
    crop = sys.argv[2]
    region = sys.argv[3]

    matches = search(problem, crop, region)
    print(json.dumps(matches))

if __name__ == "__main__":
    main()