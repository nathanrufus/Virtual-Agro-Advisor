#!/usr/bin/env python3
"""
Quick RAG setup - Create knowledge base and embeddings for agroAdvisor

Run: python scripts/quick_rag_setup.py
"""

import json
from pathlib import Path

# Simple knowledge base for RAG
KNOWLEDGE_BASE = {
    "diseases": [
        {
            "id": "N_DEF",
            "name": "Nitrogen Deficiency",
            "crop": "maize",
            "symptoms": "Yellowing of leaves starting from lower leaves moving upward",
            "description": """Nitrogen deficiency in maize causes progressive yellowing 
            of leaves. It starts from the lower leaves and moves upward. The entire 
            leaf may turn yellow without spots. Plant height is reduced. This is very 
            common in Kiambu region after continuous cropping without fertilizer.""",
            "treatment": [
                "Apply urea fertilizer (46% N) at 200-250 kg/ha",
                "Apply DAP (18-46-0) at 150-200 kg/ha", 
                "Apply farm yard manure 3-5 tons/acre",
                "Second application at V6-V8 growth stage"
            ],
            "effectiveness": 85,
            "region_common": ["kiambu", "nakuru", "nyeri", "muranga"],
            "cost": 500
        },
        {
            "id": "MSV",
            "name": "Maize Streak Virus",
            "crop": "maize",
            "symptoms": "Yellow/white streaks along leaf veins, stunted growth",
            "description": """Maize Streak Virus causes distinctive yellowing and white 
            streaks along the main leaf veins. Plants are severely stunted with very 
            reduced grain production. The disease is transmitted by leafhoppers. 
            Very common in Kiambu during March-April.""",
            "treatment": [
                "Use resistant varieties (H614, H516)",
                "Control leafhoppers with insecticides",
                "Remove infected plants",
                "Avoid planting near infected fields",
                "Crop rotation away from maize"
            ],
            "effectiveness": 70,
            "region_common": ["kiambu", "nakuru", "nairobi"],
            "cost": 0
        },
        {
            "id": "NCLB",
            "name": "Northern Corn Leaf Blight",
            "crop": "maize",
            "symptoms": "Long, narrow gray-brown lesions on leaves",
            "description": """Fungal disease causing long, narrow lesions on maize leaves. 
            The lesions are gray-brown and may merge together. Common in cool, wet highland 
            areas. Particularly problematic in Nyeri and Muranga where it reduces yields.""",
            "treatment": [
                "Use resistant varieties",
                "Spray with Mancozeb fungicide",
                "Avoid overhead irrigation",
                "Improve spacing for air circulation",
                "Remove infected leaves"
            ],
            "effectiveness": 80,
            "region_common": ["nyeri", "muranga", "kiambu"],
            "cost": 1500
        }
    ],
    "pests": [
        {
            "id": "FAW",
            "name": "Fall Armyworm",
            "crop": "maize",
            "symptoms": "Holes in leaves, stripped tissue between veins, cob damage",
            "description": """Fall Armyworm larvae feed on maize leaves creating holes 
            and stripping the tissue. They also damage the cob and grain. This invasive 
            pest is now widespread in Kenya with multiple generations per year. 
            Most damaging September-December.""",
            "control": [
                "Use Bt maize varieties",
                "Spray Lambda-cyhalothrin insecticide",
                "Scout fields regularly and spray early",
                "Encourage natural enemies",
                "Crop rotation"
            ],
            "effectiveness": 90,
            "region_common": ["nakuru", "eldoret", "kiambu"],
            "cost": 1200
        },
        {
            "id": "SB",
            "name": "Stalk Borer",
            "crop": "maize",
            "symptoms": "Holes in stalk, wilting of upper leaves, stalk breakage",
            "description": """Stalk borer larvae tunnel inside maize stalks causing damage. 
            This causes the stalk to break and leads to lodging and grain loss. 
            Peak damage is during dry season when damage is most severe.""",
            "control": [
                "Use resistant varieties",
                "Spray Chlorpyrifos or Lambda-cyhalothrin",
                "Remove crop residues properly",
                "Good spacing and fertilization",
                "Proper weeding"
            ],
            "effectiveness": 75,
            "region_common": ["kiambu", "nyeri", "muranga"],
            "cost": 1000
        }
    ]
}

def setup_rag():
    """Create RAG knowledge base and embeddings"""
    
    print("📚 Setting up RAG knowledge base...")
    
    # Save knowledge base
    kb_file = Path("data/rag_kb.json")
    kb_file.parent.mkdir(exist_ok=True)
    
    with open(kb_file, 'w') as f:
        json.dump(KNOWLEDGE_BASE, f, indent=2)
    print(f"✅ Saved knowledge base: {kb_file}")
    
    # Try to create embeddings with Chroma
    print("\n🔗 Creating embeddings...")
    
    try:
        from sentence_transformers import SentenceTransformer
        import chromadb
    except:
        print("⚠️  sentence-transformers or chromadb not installed")
        print("   Install with: pip install sentence-transformers chromadb")
        print("   Knowledge base JSON created but embeddings skipped")
        return True
    
    try:
        model = SentenceTransformer('all-MiniLM-L6-v2')
        client = chromadb.Client()
        
        # Create collections
        disease_collection = client.get_or_create_collection("diseases")
        pest_collection = client.get_or_create_collection("pests")
        
        # Embed diseases
        for disease in KNOWLEDGE_BASE['diseases']:
            text = f"{disease['name']} {disease['symptoms']} {disease['description']}"
            embedding = model.encode(text).tolist()
            
            disease_collection.add(
                ids=[disease['id']],
                embeddings=[embedding],
                documents=[text],
                metadatas=[{"name": disease['name']}]
            )
        
        print(f"✅ Embedded {len(KNOWLEDGE_BASE['diseases'])} diseases")
        
        # Embed pests
        for pest in KNOWLEDGE_BASE['pests']:
            text = f"{pest['name']} {pest['symptoms']} {pest['description']}"
            embedding = model.encode(text).tolist()
            
            pest_collection.add(
                ids=[pest['id']],
                embeddings=[embedding],
                documents=[text],
                metadatas=[{"name": pest['name']}]
            )
        
        print(f"✅ Embedded {len(KNOWLEDGE_BASE['pests'])} pests")
        
        # Test search
        print("\n🔍 Testing search...")
        
        test_query = "yellowing leaves starting from bottom"
        test_embedding = model.encode(test_query).tolist()
        
        results = disease_collection.query(
            query_embeddings=[test_embedding],
            n_results=2
        )
        
        if results['ids'] and results['ids'][0]:
            print(f"✅ Search test successful!")
            print(f"   Found: {results['ids'][0]}")
        
        return True
        
    except Exception as e:
        print(f"⚠️  Error creating embeddings: {e}")
        print("   Knowledge base JSON created. Embeddings skipped.")
        return True

if __name__ == "__main__":
    success = setup_rag()
    if success:
        print("\n✅ RAG setup complete!")
        print("   Next: python scripts/rag_search_simple.py")
    else:
        print("\n❌ RAG setup failed")