
Available WAL Backends: 
Before Milvus 2.6: Pulsar was the default WAL / message storage in cluster mode.
In Milvus 2.6 and later: Woodpecker becomes the preferred / default WAL backend.
The system retains backward compatibility, so you still can use Kafka or Pulsar, but the design is moving toward Woodpecker as the normative choice.

So, we will use Kafka or Woodpacker 






Offline install: 
Default:
helm template my-release zilliztech/milvus > milvus_manifest.yaml
￼


helm template my-release zilliztech/milvus \
  --namespace milvus-cluster \
  --create-namespace \
  --set image.all.tag=v2.6.2 \
  --set pulsarv3.enabled=false \
  --set woodpecker.enabled=true \
  --set streaming.enabled=true \
  --set indexNode.enabled=false \
  > milvus-cluster-manifest.yaml



