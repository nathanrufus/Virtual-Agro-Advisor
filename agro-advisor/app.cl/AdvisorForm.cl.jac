cl {
    def AdvisorForm(props: any) -> any {
        def handleSubmit(e: any) -> None {
            e.preventDefault();
            props.onSubmit();
        }

        # Simple handler: create a local preview URL and send it up.
        let handleImageChange = lambda e: any -> None {
            let files = e.target.files;

            if not files or files.length == 0 {
                # Clear image
                if props.onImageChange {
                    props.onImageChange("");
                }
                return;
            }

            let file = files[0];

            # Use browser URL API – no `new` keyword.
            # This is only for FRONTEND preview; backend can ignore for now.
            let previewUrl = URL.createObjectURL(file);

            if props.onImageChange {
                props.onImageChange(previewUrl);
            }
        };

        return <form
            onSubmit={handleSubmit}
            className="flex h-full min-h-[520px] flex-col rounded-2xl border border-lime-100 bg-white p-6 shadow-sm"
        >
            # {/* Header */}
            <div className="space-y-1">
                <h1 className="text-2xl font-semibold text-slate-900">
                    Get Personalized Agricultural Advice
                </h1>
                <p className="text-sm text-slate-500">
                    Fill in the details below to receive a tailored plan for your crops.
                </p>
            </div>

            # {/* Main fields */}
            <div className="mt-4 flex-1 space-y-4 overflow-y-auto pr-1">
                <div className="space-y-1">
                    <label className="text-sm font-medium text-slate-800">
                        Give Crop
                    </label>
                    <input
                        type="text"
                        placeholder="e.g., Maize, Wheat, Soybeans"
                        value={props.crop}
                        onChange={lambda e: any -> None {
                            props.onCropChange(e.target.value);
                        }}
                        className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none placeholder:text-lime-500/70 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"
                    />
                </div>

                <div className="space-y-1">
                    <label className="text-sm font-medium text-slate-800">
                        Enter Location
                    </label>
                    <input
                        type="text"
                        placeholder="e.g., Kisumu, Kenya"
                        value={props.location}
                        onChange={lambda e: any -> None {
                            props.onLocationChange(e.target.value);
                        }}
                        className="w-full rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 text-sm outline-none placeholder:text-lime-500/70 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600"
                    />
                </div>

                # ===== IMAGE UPLOAD (RIGHT AFTER LOCATION) =====
                <div className="space-y-2">
                    <label className="text-sm font-medium text-slate-800">
                        Upload Image (optional)
                    </label>
                    <input
                        type="file"
                        accept="image/*"
                        onChange={handleImageChange}
                        className="block w-full text-sm text-slate-700 file:mr-4 file:rounded-full file:border-0 file:bg-green-50 file:px-4 file:py-2 file:text-sm file:font-semibold file:text-green-700 hover:file:bg-green-100"
                    />

                    # Preview / placeholder
                    { (
                        <div className="mt-2 overflow-hidden rounded-xl border border-slate-200 bg-slate-50">
                            <img
                                src={props.imagePreviewUrl}
                                alt="Problem preview"
                                className="h-40 w-full object-cover"
                            />
                        </div>
                    ) if props.imagePreviewUrl && props.imagePreviewUrl != "" else  (
                        <div className="mt-2 flex h-24 items-center justify-center rounded-xl border border-dashed border-slate-300 bg-slate-50 text-xs text-slate-400">
                            No image selected – you can upload a clear photo of the affected plant.
                        </div>
                    )}
                </div>
                # ===== END IMAGE UPLOAD =====

                <div className="space-y-1">
                    <label className="text-sm font-medium text-slate-800">
                        Describe Your Problem
                    </label>
                    <textarea
                        rows={4}
                        placeholder="Describe the issue you are facing in detail..."
                        value={props.problemText}
                        onChange={lambda e: any -> None {
                            props.onProblemTextChange(e.target.value);
                        }}
                        className="w-full min-h-[120px] rounded-xl border border-slate-200 bg-slate-50 px-3 py-2.5 outline-none placeholder:text-green-500 focus:border-emerald-600 focus:bg-white focus:ring-1 focus:ring-emerald-600 resize-y"
                    />
                </div>

                # {/* LANGUAGE SEGMENTED CONTROL */}
                <div className="space-y-2 pt-1">
                    <label className="text-sm font-medium text-slate-800">
                        Select Language
                    </label>

                    <div className="flex gap-2">
                        # {/* EN - English */}
                        <label className="flex-1">
                            <input
                                type="radio"
                                name="advisor-language"
                                value="en"
                                checked={props.language == "en"}
                                onChange={lambda e: any -> None {
                                    props.onLanguageChange("en");
                                }}
                                className="peer sr-only"
                            />
                            <div
                                className="w-full rounded-md border border-green-600 bg-white px-4 py-2 text-sm font-semibold text-green-700 transition peer-checked:bg-green-600 peer-checked:text-white">
                                EN - English
                            </div>
                        </label>

                        # {/* SW - Swahili */}
                        <label className="flex-1">
                            <input
                                type="radio"
                                name="advisor-language"
                                value="sw"
                                checked={props.language == "sw"}
                                onChange={lambda e: any -> None {
                                    props.onLanguageChange("sw");
                                }}
                                className="peer sr-only"
                            />
                            <div
                                className=" w-full rounded-md border border-green-600 bg-white px-4 py-2 text-sm font-semibold text-green-700 transition peer-checked:bg-green-600 peer-checked:text-white">
                                SW - Swahili
                            </div>
                        </label>
                    </div>
                </div>

                # {/* DIVIDER LIKE IN THE DESIGN */}
                <div className="border-t border-slate-200 pt-3" />

                # {/* TOGGLE SWITCHES */}
                <div className="space-y-3 text-sm text-slate-800">
                    # {/* Include Weather */}
                    <label className="flex items-center gap-3">
                        <span className="relative inline-flex h-6 w-11 items-center">
                            <input
                                type="checkbox"
                                checked={props.includeWeather}
                                onChange={lambda e: any -> None {
                                    props.onIncludeWeatherChange(e.target.checked);
                                }}
                                className="peer sr-only"
                            />
                            <span
                                className="absolute inset-0 rounded-full bg-slate-300 transition peer-checked:bg-green-600"/>
                            <span
                                className="absolute h-5 w-5 rounded-full bg-white shadow translate-x-1 transition peer-checked:translate-x-5"/>
                        </span>
                        <span>Include Weather</span>
                    </label>

                    # {/* Include Market */}
                    <label className="flex items-center gap-3">
                        <span className="relative inline-flex h-6 w-11 items-center">
                            <input
                                type="checkbox"
                                checked={props.includeMarket}
                                onChange={lambda e: any -> None {
                                    props.onIncludeMarketChange(e.target.checked);
                                }}
                                className="peer sr-only"
                            />
                            <span
                                className=" absolute inset-0 rounded-full bg-slate-300 transition peer-checked:bg-green-600"/>
                            <span
                                className=" absolute h-5 w-5 rounded-full bg-white shadow translate-x-1 transition peer-checked:translate-x-5"/>
                        </span>
                        <span>Include Market</span>
                    </label>
                </div>

            </div>

            # {/* CTA BUTTON */}
            <div className="mt-4">
                <button
                    type="submit"
                    className="inline-flex w-full items-center justify-center rounded-full bg-green-500 px-4 py-3 text-base font-semibold text-white shadow-md hover:bg-emerald-800 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-1"
                >
                    Get Advice
                </button>
            </div>
        </form>;
    }
}
