#!/usr/bin/env python3
"""
RAG search - FIXED VERSION
Properly handles both embedding and keyword fallback

Run: python scripts/rag_search_simple.py
"""

import json
from pathlib import Path

class SimpleRAG:
    def __init__(self):
        # Load knowledge base from JSON
        kb_path = Path("data/rag_kb.json")
        
        if not kb_path.exists():
            print(f"❌ Knowledge base not found at {kb_path}")
            print("   Run: python scripts/quick_rag_setup.py first")
            self.kb = {"diseases": [], "pests": []}
        else:
            with open(kb_path) as f:
                self.kb = json.load(f)
            print(f"✅ Loaded knowledge base: {len(self.kb['diseases'])} diseases, {len(self.kb['pests'])} pests")
        
        # Try to load Chroma collections (optional)
        self.use_embeddings = False
        try:
            from sentence_transformers import SentenceTransformer
            import chromadb
            
            self.model = SentenceTransformer('paraphrase-multilingual-MiniLM-L12-v2')
            self.client = chromadb.PersistentClient(path="data/chroma_db")
            
            # Try to get existing collections (don't create new ones)
            try:
                self.diseases_col = self.client.get_collection("diseases")
                self.pests_col = self.client.get_collection("pests")
                self.use_embeddings = True
                print("✅ Loaded Chroma embeddings")
            except:
                print("⚠️  Chroma collections not found - using keyword search")
        except Exception as e:
            print(f"⚠️  Embeddings unavailable - using keyword search: {e}")
    
    def search(self, query: str, top_k=3):
        """Search using embeddings or keyword fallback"""
        
        if self.use_embeddings:
            return self._search_semantic(query, top_k)
        else:
            return self._search_keyword(query, top_k)
    
    def _search_semantic(self, query: str, top_k=3):
        """Semantic search using embeddings"""
        
        print(f"\n🔍 Semantic search: '{query}'")
        
        query_embedding = self.model.encode(query).tolist()
        
        # Search diseases
        disease_results = self.diseases_col.query(
            query_embeddings=[query_embedding],
            n_results=top_k
        )
        
        # Search pests
        pest_results = self.pests_col.query(
            query_embeddings=[query_embedding],
            n_results=top_k
        )
        
        # Get full disease info from KB
        diseases = []
        if disease_results['ids'] and disease_results['ids'][0]:
            for disease_id in disease_results['ids'][0]:
                for disease in self.kb['diseases']:
                    if disease['id'] == disease_id:
                        diseases.append(disease)
        
        # Get full pest info from KB
        pests = []
        if pest_results['ids'] and pest_results['ids'][0]:
            for pest_id in pest_results['ids'][0]:
                for pest in self.kb['pests']:
                    if pest['id'] == pest_id:
                        pests.append(pest)
        
        return {"diseases": diseases, "pests": pests}
    
    def _search_keyword(self, query: str, top_k=3):
        """Keyword search - FIX: Now properly searches JSON KB"""
        
        print(f"\n🔍 Keyword search: '{query}'")
        
        query_lower = query.lower()
        query_words = query_lower.split()
        
        # Search diseases in JSON KB
        disease_matches = []
        for disease in self.kb.get('diseases', []):
            score = 0
            
            # Check exact phrase in symptoms
            if query_lower in disease['symptoms'].lower():
                score += 5
            
            # Check individual words in symptoms
            for word in query_words:
                if len(word) > 2:  # Skip short words
                    if word in disease['symptoms'].lower():
                        score += 3
            
            # Check description
            for word in query_words:
                if len(word) > 3:
                    if word in disease['description'].lower():
                        score += 1
            
            # Check disease name
            if query_lower in disease['name'].lower():
                score += 5
            
            if score > 0:
                disease_matches.append((disease, score))
        
        # Search pests in JSON KB
        pest_matches = []
        for pest in self.kb.get('pests', []):
            score = 0
            
            # Check exact phrase in symptoms
            if query_lower in pest['symptoms'].lower():
                score += 5
            
            # Check individual words
            for word in query_words:
                if len(word) > 2:
                    if word in pest['symptoms'].lower():
                        score += 3
            
            # Check description
            for word in query_words:
                if len(word) > 3:
                    if word in pest['description'].lower():
                        score += 1
            
            # Check pest name
            if query_lower in pest['name'].lower():
                score += 5
            
            if score > 0:
                pest_matches.append((pest, score))
        
        # Sort by score (descending)
        disease_matches.sort(key=lambda x: x[1], reverse=True)
        pest_matches.sort(key=lambda x: x[1], reverse=True)
        
        # Get top K
        diseases = [d[0] for d in disease_matches[:top_k]]
        pests = [p[0] for p in pest_matches[:top_k]]
        
        return {"diseases": diseases, "pests": pests}
    
    def format_context(self, results):
        """Format results for LLM"""
        
        context = "KNOWLEDGE BASE INFORMATION:\n\n"
        
        if results['diseases']:
            context += "RELEVANT DISEASES:\n"
            for disease in results['diseases']:
                context += f"\n{disease['name']}:\n"
                context += f"  Symptoms: {disease['symptoms']}\n"
                context += f"  Treatment: {', '.join(disease['treatment'][:2])}\n"
        
        if results['pests']:
            context += "\n\nRELEVANT PESTS:\n"
            for pest in results['pests']:
                context += f"\n{pest['name']}:\n"
                context += f"  Symptoms: {pest['symptoms']}\n"
                context += f"  Control: {', '.join(pest['control'][:2])}\n"
        
        return context

def main():
    print("="*60)
    print("RAG SEARCH TEST")
    print("="*60)
    
    rag = SimpleRAG()
    
    # Test queries
    test_queries = [
        "yellowing maize leaves starting from bottom",
        "holes in maize leaves",
        "long brown lesions on leaves",
        "white streaks on maize leaves"
    ]
    
    for query in test_queries:
        print(f"\n{'='*60}")
        print(f"Query: {query}")
        print('='*60)
        
        results = rag.search(query, top_k=2)
        
        # Show results
        print(f"\nDiseases found: {len(results['diseases'])}")
        for disease in results['diseases']:
            print(f"  ✓ {disease['name']}")
        
        print(f"\nPests found: {len(results['pests'])}")
        for pest in results['pests']:
            print(f"  ✓ {pest['name']}")
        
        # Show context that will be sent to LLM
        context = rag.format_context(results)
        if context and len(context) > 50:
            print(f"\n📋 Context for LLM:")
            print(context[:300] + "...")

if __name__ == "__main__":
    main()