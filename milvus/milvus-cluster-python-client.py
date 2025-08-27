import random
import numpy as np
from pymilvus import (
    connections,
    utility,
    FieldSchema,
    CollectionSchema,
    DataType,
    Collection,
)

# --- 1. SETUP AND CONNECTION ---
HOST = "localhost"
PORT = "19530"
COLLECTION_NAME = "book_recommendations"
DIMENSION = 8  # For this example, we'll use 8-dimensional vectors

def connect_to_milvus():
    """Connect to Milvus and return the connection status."""
    try:
        connections.connect("default", host=HOST, port=PORT)
        print(f"✅ Successfully connected to Milvus at {HOST}:{PORT}")
        return True
    except Exception as e:
        print(f"❌ Failed to connect to Milvus: {e}")
        return False

def main():
    if not connect_to_milvus():
        return

    # --- 2. DEFINE AND CREATE A COLLECTION ---
    # A collection is like a SQL table. We must define its schema.
    
    # Drop the collection if it already exists, for a clean run
    if utility.has_collection(COLLECTION_NAME):
        utility.drop_collection(COLLECTION_NAME)
        print(f"🧹 Dropped existing collection: {COLLECTION_NAME}")

    # Define the fields (columns)
    fields = [
        FieldSchema(name="book_id", dtype=DataType.INT64, is_primary=True, auto_id=False),
        FieldSchema(name="book_title", dtype=DataType.VARCHAR, max_length=200),
        FieldSchema(name="publication_year", dtype=DataType.INT64),
        FieldSchema(name="book_embedding", dtype=DataType.FLOAT_VECTOR, dim=DIMENSION)
    ]
    schema = CollectionSchema(fields, description="A collection for book recommendations")
    
    print(f"Creating collection: {COLLECTION_NAME}...")
    collection = Collection(name=COLLECTION_NAME, schema=schema)
    print("✅ Collection created successfully.")


    # --- 3. PREPARE AND INSERT DATA ---
    # In a real app, an AI model (like SentenceTransformers) would create these embeddings.
    # Here, we'll generate random data for demonstration.
    print("\nPreparing and inserting data...")
    num_books = 1000
    data = [
        [i for i in range(num_books)],  # book_id
        [f"Book Title {i}" for i in range(num_books)], # book_title
        [random.randint(1980, 2024) for _ in range(num_books)], # publication_year
        np.random.rand(num_books, DIMENSION).tolist() # book_embedding (random vectors)
    ]
    
    insert_result = collection.insert(data)
    collection.flush() # Data is buffered; flush sends it to storage.
    print(f"✅ Inserted {insert_result.insert_count} books into the collection.")


    # --- 4. CREATE AN INDEX FOR THE VECTOR FIELD ---
    # An index is crucial for fast Approximate Nearest Neighbor (ANN) search.
    print("\nCreating index for the vector field...")
    index_params = {
        "metric_type": "L2",       # L2 is Euclidean distance
        "index_type": "IVF_FLAT",  # A common and effective index type
        "params": {"nlist": 128}   # Number of clusters to partition data into
    }
    collection.create_index(field_name="book_embedding", index_params=index_params)
    print("✅ Index created successfully.")
    

    # --- 5. LOAD COLLECTION AND PERFORM A SEARCH ---
    print("\nLoading collection into memory for searching...")
    collection.load()
    
    # Generate a random query vector to search for similar books
    query_vector = [np.random.rand(1, DIMENSION).tolist()[0]]
    
    search_params = {
        "metric_type": "L2",
        "params": {"nprobe": 10} # How many clusters to search in (higher is more accurate but slower)
    }

    print("Performing a vector similarity search...")
    results = collection.search(
        data=query_vector,
        anns_field="book_embedding",
        param=search_params,
        limit=5, # Get the top 5 most similar results
        output_fields=["book_title", "publication_year"] # Ask for metadata back
    )

    # --- 6. PARSE AND DISPLAY RESULTS ---
    print("\n🔍 Top 5 most similar books found:")
    for hit in results[0]:
        print(
            f"  - Book ID: {hit.id}, "
            f"Distance: {hit.distance:.4f}, "
            f"Title: '{hit.entity.get('book_title')}', "
            f"Year: {hit.entity.get('publication_year')}"
        )

    # --- 7. CLEANUP ---
    print("\nReleasing collection from memory...")
    collection.release()
    connections.disconnect("default")
    print("🔌 Disconnected from Milvus.")


if __name__ == "__main__":
    main()