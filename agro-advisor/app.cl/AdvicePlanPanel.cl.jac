cl {
    def AdvicePlanPanel(props: any) -> any {
        let sourceLabel = "";
        let sourceColor = "";

        if (props.meta && props.meta.source) {
            if (props.meta.source == "fresh") {
                sourceLabel = "Source: fresh";
                sourceColor = "bg-emerald-50 text-emerald-700";
            } else {
                sourceLabel = "Source: cache";
                sourceColor = "bg-slate-100 text-slate-700";
            }
        }

        return <div className="rounded-2xl border border-lime-100 bg-white p-5 shadow-sm">
            <div className="mb-3 flex items-center justify-between gap-2">
                <h2 className="text-base font-semibold text-slate-900">
                    Advice Plan
                </h2>
                {sourceLabel && (
                    <span
                        className={
                            "inline-flex items-center gap-1 rounded-full px-3 py-1 text-[11px] font-medium " +
                            sourceColor
                        }
                    >
                        <span className="h-1.5 w-1.5 rounded-full bg-current" />
                        {sourceLabel}
                    </span>
                )}
            </div>

            {props.error && (
                <p className="text-sm text-red-600">
                    {props.error}
                </p>
            )}

            {not props.error && props.loading && (
                <p className="text-sm text-slate-500">
                    Generating advice…
                </p>
            )}

            {not props.error && not props.loading && not props.advicePlan && (
                <p className="text-sm text-slate-500">
                    Fill in the form on the left and click{" "}
                    <span className="font-semibold">Get Advice</span> to see your plan here.
                </p>
            )}

            {not props.error && not props.loading && props.advicePlan && (
                <div className="space-y-3 text-sm text-slate-800">
                    <div>
                        <p className="mb-1 font-semibold">Overview</p>
                        <p className="leading-relaxed">
                            {props.advicePlan.overview}
                        </p>
                    </div>

                    {props.advicePlan.steps && props.advicePlan.steps.length > 0 && (
                        <div>
                            <p className="mb-1 font-semibold">Step-by-Step Guide</p>
                            <ol className="list-decimal space-y-1 pl-5">
                                {props.advicePlan.steps.map(lambda step: any -> any {
                                    return <li>{step}</li>;
                                })}
                            </ol>
                        </div>
                    )}

                    {props.advicePlan.cautions && props.advicePlan.cautions.length > 0 && (
                        <div className="rounded-xl bg-amber-50 p-3">
                            <p className="mb-1 text-sm font-semibold text-amber-800">
                                Cautions
                            </p>
                            <ul className="list-disc space-y-1 pl-5 text-xs text-amber-900">
                                {props.advicePlan.cautions.map(lambda c: any -> any {
                                    return <li>{c}</li>;
                                })}
                            </ul>
                        </div>
                    )}
                </div>
            )}
        </div>;
    }
}
