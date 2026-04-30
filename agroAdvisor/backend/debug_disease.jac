include backend.models;

walker:pub DebugDiseaseDocs {

    can run with Root entry {

        docs = [root -->][?:DiseaseDoc];

        if not docs {
            report "❌ No DiseaseDoc nodes found in graph";
            disengage;
        }

        results = [];

        for d in docs {

            results = results + [{
                "disease_id": d.disease_id,
                "disease_name": d.disease_name,
                "description": d.description,
                "symptoms": d.symptoms,
                "treatments": d.treatments
            }];
        }

        report results;
    }
}