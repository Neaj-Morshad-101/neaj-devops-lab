# Set Up Vector Database

from pymilvus import MilvusClient

client = MilvusClient("milvus_demo.db")


# Create a Collection

if client.has_collection(collection_name="demo_collection"):
    client.drop_collection(collection_name="demo_collection")
client.create_collection(
    collection_name="demo_collection",
    dimension=768,  # The vectors we will use in this demo has 768 dimensions
)



# Represent text with vectors


from pymilvus import model


embedding_fn = model.DefaultEmbeddingFunction()

docs = [
    "Artificial intelligence was founded as an academic discipline in 1956.",
    "Alan Turing was the first person to conduct substantial research in AI.",
    "Born in Maida Vale, London, Turing was raised in southern England.",
]

vectors = embedding_fn.encode_documents(docs)
print("Dim:", embedding_fn.dim, vectors[0].shape)  # Dim: 768 (768,)
# Dim: 768 (768,)

data = [
    {"id": i, "vector": vectors[i], "text": docs[i], "subject": "history"}
    for i in range(len(vectors))
]

print("Data has", len(data), "entities, each with fields: ", data[0].keys())
print("Vector dim:", len(data[0]["vector"]))
# Data has 3 entities, each with fields:  dict_keys(['id', 'vector', 'text', 'subject'])
# Vector dim: 768


# Insert Data￼
res = client.insert(collection_name="demo_collection", data=data)

print(res)
# {'insert_count': 3, 'ids': [0, 1, 2]}





# Semantic Search
# Vector search




query_vectors = embedding_fn.encode_queries(["Who is Alan Turing?"])

res = client.search(
    collection_name="demo_collection",  # target collection
    data=query_vectors,  # query vectors
    limit=2,  # number of returned entities
    output_fields=["text", "subject"],  # specifies fields to be returned
)

print(res)


# data: [[{'id': 2, 'distance': 0.5859946012496948, 'entity': {'text': 'Born in Maida Vale, London, Turing was raised in southern England.', 'subject': 'history'}}, {'id': 1, 'distance': 0.5118255615234375, 'entity': {'text': 'Alan Turing was the first person to conduct substantial research in AI.', 'subject': 'history'}}]]


# Delete Entities
res = client.delete(
    collection_name="demo_collection",
    filter="subject == 'biology'",
)

print(res)
# {}


res = client.delete(collection_name="demo_collection", ids=[0, 2])

print(res)
# [0, 2]


# Drop collection
client.drop_collection(collection_name="demo_collection")