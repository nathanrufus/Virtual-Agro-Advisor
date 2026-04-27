cl import from react { useState, useEffect, useRef }
sv import from ..main { GetMapData }

cl {
    def:pub FarmerMap(props: any) -> any {
        [mapData, setMapData] = useState(None);
        [showWeather, setShowWeather] = useState(True);
        [showDiseases, setShowDiseases] = useState(True);
        [showMarkets, setShowMarkets] = useState(True);
        [showCases, setShowCases] = useState(True);
        [showAlerts, setShowAlerts] = useState(True);
        [loading, setLoading] = useState(True);
        [error, setError] = useState("");

        mapRef = useRef(None);
        leafletMapRef = useRef(None);
        layerGroupsRef = useRef({
            "weather": None,
            "diseases": None,
            "markets": None,
            "cases": None,
            "alerts": None
        });

        crop = props.crop or "maize";

        async def load() -> None {
            setLoading(True);
            setError("");
            try {
                result = await root spawn GetMapData(
                    crop=crop,
                    disease_filter=""
                );
                if result and result.reports and result.reports.length > 0 {
                    setMapData(result.reports[result.reports.length - 1]);
                }
            } except exception as e {
                console.error("[FarmerMap] load error:", e);
                setError("Could not load map data.");
            }
            setLoading(False);
        }

        useEffect(lambda -> None { load(); }, []);

        useEffect(
            lambda -> None {
                if not mapRef.current {
                    return;
                }

                if leafletMapRef.current {
                    leafletMapRef.current.remove();
                    leafletMapRef.current = None;
                }

                L = window.L;
                if not L {
                    console.error("[FarmerMap] Leaflet (window.L) not found. Check that leaflet CSS+JS are loaded.");
                    return;
                }

                lmap = L.map(mapRef.current, {"center": [-0.0236, 37.9062], "zoom": 7});
                leafletMapRef.current = lmap;

                L.tileLayer(
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    {"attribution": "OpenStreetMap contributors", "maxZoom": 18}
                ).addTo(lmap);

                wGroup = L.layerGroup().addTo(lmap);
                dGroup = L.layerGroup().addTo(lmap);
                mGroup = L.layerGroup().addTo(lmap);
                cGroup = L.layerGroup().addTo(lmap);
                aGroup = L.layerGroup().addTo(lmap);

                layerGroupsRef.current = {
                    "weather": wGroup,
                    "diseases": dGroup,
                    "markets": mGroup,
                    "cases": cGroup,
                    "alerts": aGroup
                };

                if mapData {

                    if mapData.weather_points {
                        for i = 0 to i < mapData.weather_points.length by i += 1 {
                            pt = mapData.weather_points[i];
                            popupHtml = "<div style='font-size:13px;min-width:160px'>"
                                + "<b>" + pt.region_name + "</b><br>"
                                + "Temp: " + pt.temperature_c + "C<br>"
                                + "Humidity: " + pt.humidity_pct + "%<br>"
                                + "Risk: <b>" + pt.disease_risk_level + "</b><br>"
                                + "<span style='color:#6b7280;font-size:11px'>" + pt.summary + "</span>"
                                + "</div>";
                            L.circle(
                                [pt.lat, pt.lon],
                                {
                                    "radius": 22000,
                                    "color": pt.risk_color,
                                    "fillColor": pt.risk_color,
                                    "fillOpacity": 0.25,
                                    "weight": 2
                                }
                            ).bindPopup(popupHtml).addTo(wGroup);
                        }
                    }

                    if mapData.disease_points {
                        for i = 0 to i < mapData.disease_points.length by i += 1 {
                            pt = mapData.disease_points[i];
                            r = pt.radius or 15000;
                            popupHtml = "<div style='font-size:13px;min-width:160px'>"
                                + "<b style='color:#dc2626'>" + pt.disease_name + "</b><br>"
                                + "Region: " + pt.region_name + "<br>"
                                + "Cases: " + pt.cases_reported + "<br>"
                                + "Risk: " + pt.risk_level
                                + "</div>";
                            L.circle(
                                [pt.lat, pt.lon],
                                {
                                    "radius": r,
                                    "color": "#ef4444",
                                    "fillColor": "#ef4444",
                                    "fillOpacity": 0.18,
                                    "weight": 1
                                }
                            ).bindPopup(popupHtml).addTo(dGroup);
                        }
                    }

                    if mapData.market_points {
                        for i = 0 to i < mapData.market_points.length by i += 1 {
                            pt = mapData.market_points[i];
                            priceStr = pt.price + " " + pt.currency + "/" + pt.unit;
                            popupHtml = "<div style='font-size:13px;min-width:160px'>"
                                + "<b>" + pt.market_name + "</b><br>"
                                + "Crop: " + pt.crop + "<br>"
                                + "<b style='color:#16a34a'>" + priceStr + "</b><br>"
                                + pt.trend
                                + "</div>";
                            L.circleMarker(
                                [pt.lat, pt.lon],
                                {
                                    "radius": 10,
                                    "color": pt.price_color,
                                    "fillColor": pt.price_color,
                                    "fillOpacity": 0.9,
                                    "weight": 2
                                }
                            ).bindPopup(popupHtml).addTo(mGroup);
                        }
                    }

                    if mapData.case_points {
                        for i = 0 to i < mapData.case_points.length by i += 1 {
                            pt = mapData.case_points[i];
                            popupHtml = "<div style='font-size:13px;min-width:180px'>"
                                + "<b>" + pt.title + "</b><br>"
                                + "<span style='color:#dc2626'>" + pt.disease_name + "</span><br>"
                                + pt.region_name + "<br>"
                                + "<i style='color:#6b7280'>" + pt.outcome + "</i><br>"
                                + "<span style='background:#dcfce7;color:#166534;padding:2px 6px;border-radius:4px;font-size:11px'>Success Story</span>"
                                + "</div>";
                            L.marker([pt.lat, pt.lon]).bindPopup(popupHtml).addTo(cGroup);
                        }
                    }

                    if mapData.alert_points {
                        for i = 0 to i < mapData.alert_points.length by i += 1 {
                            pt = mapData.alert_points[i];
                            popupHtml = "<div style='font-size:13px;min-width:180px'>"
                                + "<b style='color:#dc2626'>Alert</b><br>"
                                + "<b>" + pt.region_name + "</b><br>"
                                + pt.alert_message + "<br>"
                                + "<span style='background:#fee2e2;color:#991b1b;padding:2px 6px;border-radius:4px;font-size:11px;text-transform:uppercase'>" + pt.severity + "</span>"
                                + "</div>";
                            L.circleMarker(
                                [pt.lat, pt.lon],
                                {
                                    "radius": 14,
                                    "color": "#dc2626",
                                    "fillColor": "#dc2626",
                                    "fillOpacity": 0.8,
                                    "weight": 3
                                }
                            ).bindPopup(popupHtml).addTo(aGroup);
                        }
                    }
                }

                return lambda -> None {
                    if leafletMapRef.current {
                        leafletMapRef.current.remove();
                        leafletMapRef.current = None;
                    }
                };
            },
            [mapData]
        );

        useEffect(
            lambda -> None {
                groups = layerGroupsRef.current;
                if not groups or not leafletMapRef.current {
                    return;
                }

                lmap = leafletMapRef.current;

                if showWeather and groups.weather {
                    lmap.addLayer(groups.weather);
                } elif groups.weather {
                    lmap.removeLayer(groups.weather);
                }

                if showDiseases and groups.diseases {
                    lmap.addLayer(groups.diseases);
                } elif groups.diseases {
                    lmap.removeLayer(groups.diseases);
                }

                if showMarkets and groups.markets {
                    lmap.addLayer(groups.markets);
                } elif groups.markets {
                    lmap.removeLayer(groups.markets);
                }

                if showCases and groups.cases {
                    lmap.addLayer(groups.cases);
                } elif groups.cases {
                    lmap.removeLayer(groups.cases);
                }

                if showAlerts and groups.alerts {
                    lmap.addLayer(groups.alerts);
                } elif groups.alerts {
                    lmap.removeLayer(groups.alerts);
                }
            },
            [showWeather, showDiseases, showMarkets, showCases, showAlerts]
        );

        if loading {
            return <div className="flex h-96 items-center justify-center rounded-xl bg-slate-50 border border-slate-200">
                <div className="text-center space-y-2">
                    <div className="mx-auto h-10 w-10 animate-spin rounded-full border-4 border-green-500 border-t-transparent" />
                    <p className="text-slate-500 text-sm">Loading map data...</p>
                </div>
            </div>;
        }

        if error {
            return <div className="rounded-xl border border-red-200 bg-red-50 p-4 text-red-700 text-sm">
                {error}
            </div>;
        }

        layerPanelStyle = {
            "position": "absolute",
            "top": "12px",
            "right": "12px",
            "zIndex": "1000",
            "background": "white",
            "borderRadius": "10px",
            "boxShadow": "0 2px 8px rgba(0,0,0,0.15)",
            "padding": "12px",
            "minWidth": "160px"
        };

        mapContainerStyle = {"height": "540px", "width": "100%"};

        return <div className="relative w-full rounded-xl border border-slate-200 overflow-hidden">

            <div style={layerPanelStyle}>
                <p className="text-xs font-semibold text-slate-700 mb-2">Map Layers</p>

                <label className="flex items-center gap-2 text-sm text-slate-600 cursor-pointer mb-1">
                    <input
                        type="checkbox"
                        checked={showWeather}
                        onChange={lambda e: any -> None { setShowWeather(e.target.checked); }}
                    />
                    <span className="inline-block h-3 w-3 rounded-full bg-blue-400" />
                    Weather Risk
                </label>

                <label className="flex items-center gap-2 text-sm text-slate-600 cursor-pointer mb-1">
                    <input
                        type="checkbox"
                        checked={showDiseases}
                        onChange={lambda e: any -> None { setShowDiseases(e.target.checked); }}
                    />
                    <span className="inline-block h-3 w-3 rounded-full bg-red-400" />
                    Disease Heatmap
                </label>

                <label className="flex items-center gap-2 text-sm text-slate-600 cursor-pointer mb-1">
                    <input
                        type="checkbox"
                        checked={showMarkets}
                        onChange={lambda e: any -> None { setShowMarkets(e.target.checked); }}
                    />
                    <span className="inline-block h-3 w-3 rounded-full bg-green-400" />
                    Market Prices
                </label>

                <label className="flex items-center gap-2 text-sm text-slate-600 cursor-pointer mb-1">
                    <input
                        type="checkbox"
                        checked={showCases}
                        onChange={lambda e: any -> None { setShowCases(e.target.checked); }}
                    />
                    <span className="inline-block h-3 w-3 rounded-full bg-purple-400" />
                    Case Studies
                </label>

                <label className="flex items-center gap-2 text-sm text-slate-600 cursor-pointer">
                    <input
                        type="checkbox"
                        checked={showAlerts}
                        onChange={lambda e: any -> None { setShowAlerts(e.target.checked); }}
                    />
                    <span className="inline-block h-3 w-3 rounded-full bg-orange-400" />
                    Alerts
                </label>
            </div>

            <div ref={mapRef} style={mapContainerStyle} />

        </div>;
    }
}
