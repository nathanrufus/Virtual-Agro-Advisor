# Graph-RAG Query Functions
# Functions for querying the agricultural knowledge graph

include utils;
include backend.graph_models;

sv import from backend.models {
    DiseaseDoc
}

# ============================================
# GRAPH QUERY FUNCTIONS
# ============================================

# Query 1: What diseases affect a specific crop?
def graph_query_diseases_for_crop(crop_name: str) -> list {
    """
    Returns all diseases that affect a given crop.
    
    Graph Pattern:
    Crop --[AFFECTED_BY]--> Disease
    """
    
    print(f"\n[GRAPH-RAG] Querying diseases for crop: {crop_name}");
    
    results = [];
    
    # Find the crop node
    all_crops = [root -->][?:Crop];
    crop_node = None;
    
    for c in all_crops {
        if c.crop_name.lower() == crop_name.lower() {
            crop_node = c;
            break;
        }
    }
    
    if not crop_node {
        print(f"[GRAPH-RAG] Crop '{crop_name}' not found in graph");
        return results;
    }
    
    # Traverse: Crop --[AFFECTED_BY]--> Disease
    for edge_obj in [crop_node -:AFFECTED_BY:->] {
        disease = edge_obj[1];  # Get the target node
        edge_data = edge_obj[0];  # Get the edge
        
        disease_info = DiseaseForCrop(
            disease_id=disease.disease_id,
            disease_name=disease.disease_name,
            severity=edge_data.severity,
            symptoms=disease.symptoms,
            treatments=[]
        );
        
        # Also get treatments for this disease
        for treat_edge in [disease -:TREATED_WITH:->] {
            treatment = treat_edge[1];
            disease_info.treatments = disease_info.treatments + [treatment.treatment_name];
        }
        
        results.append(disease_info);
        print(f"[GRAPH-RAG]   Found: {disease.disease_name} (severity: {edge_data.severity})");
    }
    
    print(f"[GRAPH-RAG] Total diseases found: {len(results)}");
    return results;
}

# Query 2: What diseases affect a crop in a specific region?
def graph_query_diseases_for_crop_in_region(crop_name: str, region_name: str) -> list {
    """
    Returns diseases affecting a crop in a specific region.
    
    Graph Pattern:
    Crop --[AFFECTED_BY]--> Disease --[OCCURS_IN]--> Region
    """
    
    print(f"\n[GRAPH-RAG] Querying diseases for {crop_name} in {region_name}");
    
    results = [];
    
    # Find crop node
    all_crops = [root -->][?:Crop];
    crop_node = None;
    for c in all_crops {
        if c.crop_name.lower() == crop_name.lower() {
            crop_node = c;
            break;
        }
    }
    
    if not crop_node {
        print(f"[GRAPH-RAG] Crop '{crop_name}' not found");
        return results;
    }
    
    # Find region node
    all_regions = [root -->][?:Region];
    region_node = None;
    region_lower = region_name.lower();
    
    for r in all_regions {
        if region_lower in r.region_name.lower() or region_lower in r.county.lower() {
            region_node = r;
            break;
        }
    }
    
    if not region_node {
        print(f"[GRAPH-RAG] Region '{region_name}' not found");
        # Fall back to all diseases for the crop
        return graph_query_diseases_for_crop(crop_name);
    }
    
    # Traverse: Crop --[AFFECTED_BY]--> Disease --[OCCURS_IN]--> Region
    for disease_edge in [crop_node -:AFFECTED_BY:->] {
        disease = disease_edge[1];
        
        # Check if this disease occurs in the target region
        for region_edge in [disease -:OCCURS_IN:->] {
            region = region_edge[1];
            
            if region.region_id == region_node.region_id {
                occurs_edge = region_edge[0];
                
                info = RegionalDiseaseInfo(
                    disease_name=disease.disease_name,
                    prevalence_pct=occurs_edge.prevalence_pct,
                    cases_reported=occurs_edge.cases_reported,
                    risk_level=occurs_edge.risk_level,
                    recommended_treatments=[]
                );
                
                # Get treatments
                for treat_edge in [disease -:TREATED_WITH:->] {
                    treatment = treat_edge[1];
                    info.recommended_treatments = info.recommended_treatments + [
                        treatment.treatment_name
                    ];
                }
                
                results.append(info);
                print(f"[GRAPH-RAG]   Found: {disease.disease_name}");
                print(f"[GRAPH-RAG]     Prevalence: {occurs_edge.prevalence_pct}%");
                print(f"[GRAPH-RAG]     Cases: {occurs_edge.cases_reported}");
            }
        }
    }
    
    print(f"[GRAPH-RAG] Total regional diseases found: {len(results)}");
    return results;
}

# Query 3: How to treat a specific disease?
def graph_query_treatments_for_disease(disease_name: str) -> list {
    """
    Returns all treatments for a given disease.
    
    Graph Pattern:
    Disease --[TREATED_WITH]--> Treatment
    """
    
    print(f"\n[GRAPH-RAG] Querying treatments for: {disease_name}");
    
    results = [];
    
    # Find disease node
    all_diseases = [root -->][?:Disease];
    disease_node = None;
    
    for d in all_diseases {
        if disease_name.lower() in d.disease_name.lower() {
            disease_node = d;
            break;
        }
    }
    
    if not disease_node {
        print(f"[GRAPH-RAG] Disease '{disease_name}' not found");
        return results;
    }
    
    # Traverse: Disease --[TREATED_WITH]--> Treatment
    for treat_edge in [disease_node -:TREATED_WITH:->] {
        treatment = treat_edge[1];
        edge_data = treat_edge[0];
        
        treatment_info = TreatmentForDisease(
            treatment_id=treatment.treatment_id,
            treatment_name=treatment.treatment_name,
            effectiveness_pct=edge_data.effectiveness_pct,
            cost_kes=edge_data.cost_kes,
            application=edge_data.application_timing
        );
        
        results.append(treatment_info);
        print(f"[GRAPH-RAG]   Found: {treatment.treatment_name}");
        print(f"[GRAPH-RAG]     Effectiveness: {edge_data.effectiveness_pct}%");
        print(f"[GRAPH-RAG]     Cost: {edge_data.cost_kes} KES");
    }
    
    print(f"[GRAPH-RAG] Total treatments found: {len(results)}");
    return results;
}

# Query 4: Success rate of treatments in a region
def graph_query_treatment_success_in_region(disease_name: str, region_name: str) -> dict {
    """
    Returns treatment success rates for a disease in a specific region.
    
    Graph Pattern:
    Disease --[CASE_STUDY_OF]--> CaseStudy --[OCCURS_IN]--> Region
    """
    
    print(f"\n[GRAPH-RAG] Querying treatment success for {disease_name} in {region_name}");
    
    result = {
        "disease": disease_name,
        "region": region_name,
        "total_cases": 0,
        "successful_cases": 0,
        "success_rate_pct": 0.0,
        "case_studies": []
    };
    
    # Find disease
    all_diseases = [root -->][?:Disease];
    disease_node = None;
    for d in all_diseases {
        if disease_name.lower() in d.disease_name.lower() {
            disease_node = d;
            break;
        }
    }
    
    if not disease_node {
        return result;
    }
    
    # Find region
    all_regions = [root -->][?:Region];
    region_node = None;
    region_lower = region_name.lower();
    for r in all_regions {
        if region_lower in r.region_name.lower() or region_lower in r.county.lower() {
            region_node = r;
            break;
        }
    }
    
    if not region_node {
        return result;
    }
    
    # Find case studies for this disease in this region
    for case_edge in [disease_node -:CASE_STUDY_OF:->] {
        case_study = case_edge[1];
        
        # Check if case is in target region
        for region_edge in [case_study -:OCCURS_IN:->] {
            region = region_edge[1];
            
            if region.region_id == region_node.region_id {
                result["total_cases"] = result["total_cases"] + 1;
                
                if case_study.success {
                    result["successful_cases"] = result["successful_cases"] + 1;
                }
                
                result["case_studies"].append({
                    "case_id": case_study.case_id,
                    "title": case_study.title,
                    "outcome": case_study.outcome,
                    "success": case_study.success,
                    "cost_kes": case_study.cost_kes,
                    "timeline_days": case_study.timeline_days
                });
            }
        }
    }
    
    # Calculate success rate
    if result["total_cases"] > 0 {
        result["success_rate_pct"] = (
            result["successful_cases"] * 100.0 / result["total_cases"]
        );
    }
    
    print(f"[GRAPH-RAG] Success rate: {result['success_rate_pct']}%");
    print(f"[GRAPH-RAG]   ({result['successful_cases']}/{result['total_cases']} cases)");
    
    return result;
}

# Query 5: Find similar diseases based on symptoms
def graph_query_similar_diseases(disease_name: str) -> list {
    """
    Returns diseases similar to the given disease.
    
    Graph Pattern:
    Disease --[SIMILAR_TO]--> Disease
    """
    
    print(f"\n[GRAPH-RAG] Finding diseases similar to: {disease_name}");
    
    results = [];
    
    # Find disease
    all_diseases = [root -->][?:Disease];
    disease_node = None;
    for d in all_diseases {
        if disease_name.lower() in d.disease_name.lower() {
            disease_node = d;
            break;
        }
    }
    
    if not disease_node {
        return results;
    }
    
    # Traverse: Disease --[SIMILAR_TO]--> Disease
    for similar_edge in [disease_node -:SIMILAR_TO:->] {
        similar_disease = similar_edge[1];
        edge_data = similar_edge[0];
        
        results.append({
            "disease_id": similar_disease.disease_id,
            "disease_name": similar_disease.disease_name,
            "similarity_score": edge_data.similarity_score,
            "shared_symptoms": edge_data.shared_symptoms,
            "symptoms": similar_disease.symptoms
        });
        
        print(f"[GRAPH-RAG]   Similar: {similar_disease.disease_name}");
        print(f"[GRAPH-RAG]     Similarity: {edge_data.similarity_score}");
    }
    
    return results;
}

# Query 6: Get comprehensive disease context for RAG
def graph_query_disease_context(crop: str, region: str, symptoms: list) -> str {
    """
    Main function to replace the old retrieve_relevant_diseases.
    Uses graph queries to build rich context.
    """
    
    print("\n[GRAPH-RAG] ========================================");
    print("[GRAPH-RAG] BUILDING COMPREHENSIVE DISEASE CONTEXT");
    print(f"[GRAPH-RAG] Crop: {crop}");
    print(f"[GRAPH-RAG] Region: {region}");
    print("[GRAPH-RAG] ========================================");
    
    context = "";
    
    # 1. Get diseases for this crop in this region
    regional_diseases = graph_query_diseases_for_crop_in_region(crop, region);
    
    if regional_diseases {
        context += "=== REGIONAL DISEASE INFORMATION ===\n\n";
        
        for disease_info in regional_diseases {
            context += f"Disease: {disease_info.disease_name}\n";
            context += f"Regional Prevalence: {disease_info.prevalence_pct}% ";
            context += f"({disease_info.cases_reported} cases reported)\n";
            context += f"Risk Level: {disease_info.risk_level}\n";
            
            if disease_info.recommended_treatments {
                context += "Recommended Treatments: ";
                context += ", ".join(disease_info.recommended_treatments);
                context += "\n";
            }
            
            # Get case studies for this disease in this region
            success_info = graph_query_treatment_success_in_region(
                disease_info.disease_name,
                region
            );
            
            if success_info["total_cases"] > 0 {
                context += f"Local Success Rate: {success_info['success_rate_pct']:.1f}% ";
                context += f"({success_info['successful_cases']}/{success_info['total_cases']} cases)\n";
                
                # Add best case study
                if success_info["case_studies"] {
                    best_case = success_info["case_studies"][0];
                    context += f"Example: {best_case['title']} - {best_case['outcome']}\n";
                }
            }
            
            context += "\n";
        }
    } else {
        # Fallback to all diseases for crop
        context += "=== DISEASE INFORMATION (NO REGIONAL DATA) ===\n\n";
        
        crop_diseases = graph_query_diseases_for_crop(crop);
        for disease_info in crop_diseases {
            context += f"Disease: {disease_info.disease_name}\n";
            context += f"Severity: {disease_info.severity}\n";
            context += f"Symptoms: {disease_info.symptoms}\n";
            
            if disease_info.treatments {
                context += "Treatments: ";
                context += ", ".join(disease_info.treatments);
                context += "\n";
            }
            
            context += "\n";
        }
    }
    
    print(f"[GRAPH-RAG] Context built: {len(context)} characters");
    print("[GRAPH-RAG] ========================================\n");
    
    return context;
}
