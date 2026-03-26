cl {
    def:pub MarketSummaryPanel(props: any) -> any {
        if not props.summary {
            return <div className="h-[200px] rounded-2xl border border-lime-100 bg-white p-4 text-slate-500">
                Market summary will appear here when you request it.
            </div>;
        }

        # localized title (fallback)
        heading = "Market Summary";
        if props.meta and props.meta.titles and props.meta.titles.market_summary {
            heading = props.meta.titles.market_summary;
        }

        return <div className="h-[200px] rounded-2xl border border-lime-100 bg-white p-4">
            <div className="mb-2 flex items-center justify-between">
                <h3 className="font-semibold text-slate-900">
                    {heading}
                </h3>
            </div>
            <div className="h-full overflow-y-auto">
                <p className="text-slate-700 leading-relaxed">
                    {props.summary.summary_text}
                </p>
            </div>
        </div>;
    }
}