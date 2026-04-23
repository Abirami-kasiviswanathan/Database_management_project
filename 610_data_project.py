import random
from datetime import datetime, timedelta

# Set your listing IDs to match your database
listing_ids = [1, 2, 3, 4, 5]

print("--- COPY THE SQL BELOW ---")

for lid in listing_ids:
    base_price = random.uniform(10.0, 50.0)
    for i in range(20):
        price_change = base_price * random.uniform(-0.10, 0.10)
        final_price = round(base_price + price_change, 2)
        date_entry = (datetime.now() - timedelta(days=i*15)).strftime('%Y-%m-%d %H:%M:%S')
        
        # Print directly to the terminal
        print(f"INSERT INTO Price_History (listing_id, recorded_price, recorded_at) VALUES ({lid}, {final_price}, '{date_entry}');")

print("--- END OF SQL ---")