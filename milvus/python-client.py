# Instruction to run this script:

# python3 -m venv venv
# source venv/bin/activate
# (venv) neaj@neaj-pc:~/g/s/g/N/y/milvus|main✓
# pip install pymilvus
# python python-client.py
# deactivate
# The next time you want to work on this project, just navigate to the directory and (source venv/bin/activate).

# python3 -m venv venv        Create the virtual environment (do this once).
# source venv/bin/activate    Enter the virtual environment (do this every time you start working).
# pip install <package>       Install packages into the active environment.
# deactivate                  Exit the virtual environment.


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












