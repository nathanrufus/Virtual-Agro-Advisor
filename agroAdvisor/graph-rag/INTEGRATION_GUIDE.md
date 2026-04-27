# GRAPH-RAG INTEGRATION GUIDE
# This file shows EXACTLY where and how to modify your existing code to integrate Graph-RAG

## ============================================
## STEP 1: Update backend/helpers.jac
## ============================================

# AT THE TOP, ADD THESE IMPORTS:
# ---------------------------------
# Add after existing imports:

include backend.graph_rag;

sv import from backend.graph_rag {
    graph_query_disease_context,
    graph_query_diseases_for_crop,
    graph_query_diseases_for_crop_in_region,
    graph_query_treatments_for_disease,
    graph_query_treatment_success_in_region
}


# REPLACE THE FUNCTION retrieve_relevant_diseases:
# ---------------------------------
# OLD VERSION (lines 251-326):
# def retrieve_relevant_diseases(problem: str) -> list {
#     ... (old string matching code)
# }

# NEW VERSION - REPLACE WITH:

def retrieve_relevant_diseases(crop: str, problem: str, region: str) -> list {
    """
    NEW Graph-RAG version that uses graph queries instead of string matching.
    Now takes crop and region to enable graph-based retrieval.
    """
    
    print("\n[RAG] ========================================");
    print("[RAG] GRAPH-RAG QUERY INITIATED");
    print(f"[RAG] Crop: {crop}");
    print(f"[RAG] Region: {region}");
    
    preview = problem;
    if len(problem) > 100 {
        preview = problem[0:100];
    }
    print(f"[RAG] Problem: {preview}...");
    print("[RAG] ========================================");
    
    # Use graph-based retrieval
    results = [];
    
    # Try to get diseases from the graph
    if region and crop {
        # Query: Crop --[AFFECTED_BY]--> Disease --[OCCURS_IN]--> Region
        regional_diseases = graph_query_diseases_for_crop_in_region(crop, region);
        
        if regional_diseases {
            print(f"[RAG] Found {len(regional_diseases)} diseases via GRAPH QUERY");
            
            # Convert to DiseaseDoc format for compatibility
            for rd in regional_diseases {
                # Find the actual Disease node
                all_diseases = [root -->][?:Disease];
                for d_node in all_diseases {
                    if d_node.disease_name == rd.disease_name {
                        # Convert to DiseaseDoc for compatibility with existing code
                        disease_doc = DiseaseDoc(
                            disease_id=d_node.disease_id,
                            disease_name=d_node.disease_name,
                            description=d_node.description,
                            symptoms=d_node.symptoms,
                            treatments=", ".join(rd.recommended_treatments)
                        );
                        results.append(disease_doc);
                        break;
                    }
                }
            }
            
            print(f"[RAG] Converted {len(results)} graph results to DiseaseDoc format");
        }
    }
    
    # Fallback to old string matching if graph query returns nothing
    if len(results) == 0 {
        print("[RAG] No graph results, falling back to legacy string matching...");
        
        problem_lower = problem.lower();
        all_diseases_old = [root -->][?:DiseaseDoc];
        
        print(f"[RAG] Total DiseaseDoc nodes: {len(all_diseases_old)}");
        
        temp_results = [];
        
        for d in all_diseases_old {
            score = 0;
            
            if problem_lower in d.symptoms.lower() {
                score = score + 2;
            }
            if problem_lower in d.description.lower() {
                score = score + 1;
            }
            if problem_lower in d.disease_name.lower() {
                score = score + 3;
            }
            
            if score > 0 {
                temp_results.append({"d": d, "score": score});
            }
        }
        
        # Sort by score
        while len(temp_results) > 0 {
            best = temp_results[0];
            for r in temp_results {
                if r["score"] > best["score"] {
                    best = r;
                }
            }
            results.append(best["d"]);
            temp_results.remove(best);
        }
        
        print(f"[RAG] Legacy search found {len(results)} diseases");
    }
    
    print("\n[RAG] FINAL RESULTS: " + str(len(results)) + " DISEASES");
    
    i = 0;
    for d in results {
        if i < 5 {
            print("[RAG]   " + str(i + 1) + ". " + d.disease_name);
        }
        i = i + 1;
    }
    
    print("[RAG] ========================================\n");
    
    return results;
}


# UPDATE format_disease_context TO USE GRAPH DATA:
# ---------------------------------
# Keep the function mostly the same, but it now receives DiseaseDoc objects
# that may have been enriched with graph data.
# No changes needed here - it will work with both old and new data.


## ============================================
## STEP 2: Update backend/advisor.jac
## ============================================

# FIND THE SECTION WHERE retrieve_relevant_diseases IS CALLED
# ---------------------------------
# This is around line 330-360 in your current advisor.jac

# OLD CODE:
# relevant_diseases = retrieve_relevant_diseases(self.problem_text);

# NEW CODE - UPDATE THE FUNCTION CALL:
relevant_diseases = retrieve_relevant_diseases(
    crop=self.crop,
    problem=self.problem_text,
    region=self.location
);


## ============================================
## STEP 3: Update backend/models.jac
## ============================================

# ADD NEW IMPORTS AT THE TOP:
# ---------------------------------
# After the existing includes, add:

include backend.graph_models;
include backend.graph_rag;
include backend.graph_seed;

# Import the new node types
sv import from backend.graph_models {
    Crop,
    Disease,
    Pest,
    Treatment,
    Region,
    GraphCaseStudy,
    AFFECTED_BY,
    OCCURS_IN,
    TREATED_WITH,
    AVAILABLE_IN,
    CASE_STUDY_OF,
    GROWS_IN,
    SIMILAR_TO
}


## ============================================
## STEP 4: Update main.jac
## ============================================

# ADD GRAPH INITIALIZATION
# ---------------------------------
# Add after your existing imports:

include backend.graph_seed;

# In your initialization section (with entry block or startup), add:

with entry {
    load_dotenv();
    
    # Initialize Graph-RAG knowledge base
    # Uncomment the line below to seed the graph on startup:
    # SeedGraphRAG();
}


## ============================================
## STEP 5: Create a new walker for testing
## ============================================

# ADD TO A NEW FILE OR TO main.jac:

walker:pub TestGraphRAG {
    """
    Test walker to demonstrate Graph-RAG queries
    """
    
    can run with Root entry {
        print("\n=== TESTING GRAPH-RAG QUERIES ===\n");
        
        # Test 1: Diseases for maize
        print("TEST 1: What diseases affect maize?");
        maize_diseases = graph_query_diseases_for_crop("Maize");
        print(f"Found {len(maize_diseases)} diseases\n");
        
        # Test 2: Diseases for maize in Kiambu
        print("TEST 2: What diseases affect maize in Kiambu?");
        kiambu_diseases = graph_query_diseases_for_crop_in_region("Maize", "Kiambu");
        print(f"Found {len(kiambu_diseases)} regional diseases\n");
        
        # Test 3: Treatments for nitrogen deficiency
        print("TEST 3: How to treat Nitrogen Deficiency?");
        treatments = graph_query_treatments_for_disease("Nitrogen Deficiency");
        print(f"Found {len(treatments)} treatments\n");
        
        # Test 4: Success rate in Kiambu
        print("TEST 4: Success rate of N-Deficiency treatments in Kiambu");
        success = graph_query_treatment_success_in_region(
            "Nitrogen Deficiency",
            "Kiambu"
        );
        print(f"Success rate: {success['success_rate_pct']}%");
        print(f"Cases: {success['successful_cases']}/{success['total_cases']}\n");
        
        report {
            "status": "success",
            "message": "Graph-RAG tests completed"
        };
    }
}


## ============================================
## SUMMARY OF CHANGES
## ============================================

FILES TO MODIFY:
1. backend/models.jac
   - Add imports for graph models
   
2. backend/helpers.jac
   - Add import for graph_rag
   - REPLACE retrieve_relevant_diseases function (signature changed!)
   - Old: retrieve_relevant_diseases(problem: str)
   - New: retrieve_relevant_diseases(crop: str, problem: str, region: str)
   
3. backend/advisor.jac
   - Update the call to retrieve_relevant_diseases
   - Pass crop, problem, and region parameters
   
4. main.jac
   - Add graph initialization (optional auto-seed)

NEW FILES CREATED:
1. backend/graph_models.jac - Graph node and edge definitions
2. backend/graph_rag.jac - Graph query functions
3. backend/graph_seed.jac - Data seeding functions


## ============================================
## HOW TO INITIALIZE THE GRAPH
## ============================================

Option 1: Manual initialization via walker
```bash
jac run main.jac -w SeedGraphRAG
```

Option 2: Auto-initialize on startup
In main.jac, uncomment:
```jac
with entry {
    SeedGraphRAG();
}
```


## ============================================
## TESTING THE INTEGRATION
## ============================================

After making the changes, test with:

```bash
# 1. Seed the graph
jac run main.jac -w SeedGraphRAG

# 2. Test graph queries
jac run main.jac -w TestGraphRAG

# 3. Test full advisor with graph-RAG
jac run main.jac -w AgroAdvisor crop="maize" problem_text="yellowing leaves" location="Kiambu"
```

The advisor will now use Graph-RAG to retrieve diseases based on:
- Crop type
- Regional prevalence
- Treatment success rates in the area
- Local case studies

Instead of simple string matching!
