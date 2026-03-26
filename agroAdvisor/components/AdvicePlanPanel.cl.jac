cl {
    def:pub AdvicePlanPanel(props: any) -> any {
        sourceLabel = "";
        sourceColor = "";

        # --- source chip text/color ---
        if props.meta and props.meta.source {
            if props.meta.source == "fresh" {
                sourceLabel = "Source: fresh";
                sourceColor = "bg-emerald-50 text-emerald-700";
            } else {
                sourceLabel = "Source: cache";
                sourceColor = "bg-slate-100 text-slate-700";
            }
        }

        overviewTitle = "Overview";
        stepsTitle = "Step-by-Step Guide";
        cautionsTitle = "Cautions";

        if props.meta and props.meta.titles {
            titles = props.meta.titles;

            if titles.advice_overview {
                overviewTitle = titles.advice_overview;
            }
            if titles.advice_steps {
                stepsTitle = titles.advice_steps;
            }
            if titles.advice_cautions {
                cautionsTitle = titles.advice_cautions;
            }
        }

        return <div
            className="flex h-[520px] flex-col rounded-2xl border border-lime-100 bg-white p-5 md:p-6 shadow-sm">
            <div className="mb-2 flex items-center justify-between gap-2">
                <h2 className="text-base font-semibold text-slate-900">
                    Advice Plan
                </h2>
                {sourceLabel && (
                    <span
                        className={
                            "inline-flex items-center gap-1 rounded-full px-3 py-1 font-medium " +
                            sourceColor
                        }
                    >
                        <span className="h-1.5 w-1.5 rounded-full bg-current" />
                        {sourceLabel}
                    </span>
                )}
            </div>

            <div className="mt-1 flex-1 overflow-y-auto rounded-xl bg-slate-50/70 px-3 py-2">
                {props.error && (
                    <p className="text-red-600">
                        {props.error}
                    </p>
                )}

                {not props.error && props.loading && (
                    <p className="text-slate-500">
                        Generating advice…
                    </p>
                )}

                {not props.error && not props.loading && not props.advicePlan && (
                    <p className="text-slate-500">
                        Fill in the form on the left and click{" "}
                        <span className="font-semibold">Get Advice</span> to see your plan here.
                    </p>
                )}

                {not props.error && not props.loading && props.advicePlan && (
                    <div className="space-y-3 text-slate-800">
                        <div>
                            <p className="mb-1 font-semibold">{overviewTitle}</p>
                            <p className="leading-relaxed">
                                {props.advicePlan.overview}
                            </p>
                        </div>

                        {props.advicePlan.steps && props.advicePlan.steps.length > 0 && (
                            <div>
                                <p className="mb-1 font-semibold">{stepsTitle}</p>
                                <ol className=" space-y-1 pl-5">
                                {props.advicePlan.steps.map(lambda step: any, idx: any -> any {
                                    return <li key={idx}>{step}</li>;
                                })}
                                </ol>

                            </div>
                        )}

                        {props.advicePlan.cautions && props.advicePlan.cautions.length > 0 && (
                            <div className="rounded-xl border border-amber-100 bg-amber-50 p-3">
                                <p className="mb-1 font-semibold text-amber-800">
                                    {cautionsTitle}
                                </p>
                                <ul className="list-disc space-y-1 pl-5 text-amber-900">
                                    {props.advicePlan.cautions.map(lambda c: any -> any {
                                        return <li>{c}</li>;
                                    })}
                                </ul>
                            </div>
                        )}
                    </div>
                )}
            </div>
        </div>;
    }
}