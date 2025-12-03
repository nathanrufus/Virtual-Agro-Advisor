cl {
    def MarketSummaryPanel(props: any) -> any {
        if not props.summary {
            return <div className="rounded-2xl border border-slate-200 bg-white p-4 text-sm text-slate-500">
                Market summary will appear here when you request it.
            </div>;
        }

        return <div className="rounded-2xl border border-slate-200 bg-white p-4">
            <div className="mb-2 flex items-center justify-between">
                <h3 className="text-sm font-semibold text-slate-900">
                    Market Summary
                </h3>
            </div>
            <p className="text-sm text-slate-700">
                {props.summary.summary_text}
            </p>
        </div>;
    }
}
