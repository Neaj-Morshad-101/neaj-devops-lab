from pymilvus import utility, connections

try:
    # Connect to Milvus
    connections.connect("default", host="localhost", port="19530")
    print("✅ Successfully connected to Milvus!")

    # Check if Milvus is healthy
    healthy = utility.get_server_version()
    print(f"✅ Milvus server version: {healthy}")

except Exception as e:
    print(f"❌ Failed to connect to Milvus: {e}")

finally:
    connections.disconnect("default")
    print("🔌 Disconnected from Milvus.")
