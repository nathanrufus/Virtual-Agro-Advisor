#!/usr/bin/env python3
"""
KAMIS Targeted Search and Download

Downloads specific crop/market data from KAMIS

Run:
  python kamis_search_downloader.py --crop maize --market nairobi --days 30
  python kamis_search_downloader.py --crop beans --region kiambu
"""

import sys
import json
import argparse
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict

try:
    import requests
except ImportError:
    print("Install: pip install requests")
    sys.exit(1)

class KAMISSearcher:
    """Search and download KAMIS data"""
    
    def __init__(self):
        self.base_url = "https://www.kamis.kalro.org"
        self.api_url = "https://www.kamis.kalro.org/api"
        self.data_dir = Path("data")
        self.data_dir.mkdir(exist_ok=True)
        
        # KAMIS markets
        self.markets = {
            "nairobi": "nairobi_central",
            "kisumu": "kisumu",
            "mombasa": "mombasa",
            "nakuru": "nakuru",
            "eldoret": "eldoret",
            "kericho": "kericho",
            "thika": "thika",
            "muranga": "muranga",
            "kisii": "kisii",
            "nyeri": "nyeri",
            "kitale": "kitale",
        }
        
        # KAMIS crops
        self.crops = {
            "maize": "maize",
            "beans": "beans",
            "wheat": "wheat",
            "rice": "rice",
            "potatoes": "potatoes",
            "onions": "onions",
            "tomatoes": "tomatoes",
            "cabbage": "cabbage",
        }
    
    def test_api(self):
        """Test if KAMIS API is available"""
        
        print("🔍 Testing KAMIS API...")
        
        try:
            response = requests.get(f"{self.api_url}/markets", timeout=5)
            if response.status_code == 200:
                print("✅ KAMIS API is available")
                return True
        except:
            pass
        
        print("⚠️  KAMIS API not responding")
        return False
    
    def search_api(self, crop=None, market=None, days=30):
        """Search KAMIS API for specific data"""
        
        print(f"\n🔍 Searching KAMIS...")
        print(f"   Crop: {crop or 'All'}")
        print(f"   Market: {market or 'All'}")
        print(f"   Days: {days}")
        
        try:
            params = {
                "format": "json",
                "days": days
            }
            
            if crop:
                params["commodity"] = crop
            
            if market:
                params["market"] = market
            
            endpoints = [
                f"{self.api_url}/prices",
                f"{self.api_url}/data",
            ]
            
            for endpoint in endpoints:
                try:
                    response = requests.get(endpoint, params=params, timeout=10)
                    
                    if response.status_code == 200:
                        data = response.json()
                        print(f"✅ Got {len(data) if isinstance(data, list) else 1} results")
                        return data if isinstance(data, list) else [data]
                
                except:
                    continue
            
            print("⚠️  No API endpoint worked")
            return None
            
        except Exception as e:
            print(f"❌ API search failed: {e}")
            return None
    
    def create_mock_data(self, crop=None, market=None, days=30):
        """Create mock KAMIS data for demo/testing"""
        
        crop = (crop or "maize").lower()
        market = (market or "nairobi").lower()
        
        # Mock prices for demo
        prices = {
            "maize": 32.50,
            "beans": 85.00,
            "wheat": 48.00,
            "potatoes": 25.00,
            "tomatoes": 45.00
        }
        
        base_price = prices.get(crop, 30.0)
        
        data = []
        for i in range(days):
            date = (datetime.now() - timedelta(days=i)).strftime("%Y-%m-%d")
            price = base_price + (i % 5) - 2
            
            data.append({
                "date": date,
                "market": market,
                "crop": crop,
                "price": round(price, 2),
                "unit": "kg",
                "currency": "KES"
            })
        
        return data
    
    def search_and_download(self, crop=None, market=None, days=30):
        """Main search and download function"""
        
        print("\n" + "="*60)
        print("KAMIS TARGETED SEARCH & DOWNLOAD")
        print("="*60)
        
        # Try API first
        data = None
        if self.test_api():
            data = self.search_api(crop, market, days)
        
        # Fallback to mock data for demo
        if not data:
            print("\n⚠️  Using demo data (no live API)")
            data = self.create_mock_data(crop, market, days)
        
        # Save results
        if data:
            filename = self.data_dir / f"kamis_{crop or 'all'}_{market or 'all'}.json"
            
            with open(filename, 'w') as f:
                json.dump(data, f, indent=2)
            
            # Print as JSON for stdout
            print(json.dumps(data))
            
            return True
        
        return False

def main():
    parser = argparse.ArgumentParser(
        description="Search and download KAMIS market data"
    )
    
    parser.add_argument('--crop', help='Crop to search for')
    parser.add_argument('--market', help='Specific market')
    parser.add_argument('--region', help='Region/county')
    parser.add_argument('--days', type=int, default=30, help='Days of history')
    
    args = parser.parse_args()
    
    searcher = KAMISSearcher()
    
    # Map region to market
    if args.region and not args.market:
        region_markets = {
            "nairobi": "nairobi",
            "kiambu": "thika",
            "kisumu": "kisumu",
            "nakuru": "nakuru",
        }
        args.market = region_markets.get(args.region.lower())
    
    success = searcher.search_and_download(
        crop=args.crop,
        market=args.market,
        days=args.days
    )
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()