cl {
    def WeatherSummaryPanel(props: any) -> any {
        if not props.summary {
            return <div className="h-[150px] rounded-2xl border border-lime-100 bg-white p-4 text-sm text-slate-500">
                Weather summary will appear here when you request it.
            </div>;
        }

        let heading = "Weather Summary";
        if props.meta and props.meta.titles and props.meta.titles.weather_summary {
            heading = props.meta.titles.weather_summary;
        }

        return <div className="h-[150px] rounded-2xl border border-lime-100 bg-white p-4">
            <div className="mb-2 flex items-center justify-between">
                <h3 className="text-sm font-semibold text-slate-900">
                    {heading}
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
