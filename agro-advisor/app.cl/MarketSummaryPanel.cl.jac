cl {
    def MarketSummaryPanel(props: any) -> any {
        if not props.summary {
            return <div className="h-[150px] rounded-2xl border border-lime-100 bg-white p-4 text-sm text-slate-500">
                Market summary will appear here when you request it.
            </div>;
        }

        return <div className="h-[150px] rounded-2xl border border-lime-100 bg-white p-4">
            <div className="mb-2 flex items-center justify-between">
                <h3 className="text-sm font-semibold text-slate-900">
                    Market Summary
                </h3>
            </div>
            <div className="h-full overflow-y-auto">
                <p className="text-sm text-slate-700 leading-relaxed">
                    {props.summary.summary_text}
                </p>
            </div>
        </div>;
    }
}
