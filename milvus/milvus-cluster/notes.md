
Available WAL Backends: 
Before Milvus 2.6: Pulsar was the default WAL / message storage in cluster mode.
In Milvus 2.6 and later: Woodpecker becomes the preferred / default WAL backend.
The system retains backward compatibility, so you still can use Kafka or Pulsar, but the design is moving toward Woodpecker as the normative choice.

So, we have to use Kafka or Woodpacker 
