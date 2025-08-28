# Apache Ignite Commands and References

## Basic Cluster Access
```bash
# Access Ignite pod
kc exec -it pods/ignite-cluster-0 -n ignite -- sh

# Navigate to Ignite bin directory
cd apache-ignite/bin
```

## SQLLine Connection Commands

### Basic Connection
```bash
# Connect without authentication
./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/

# Connect with authentication (default credentials)
./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/ -n ignite -p ignite
```

### TLS-Enabled Connection
```bash
./sqlline.sh -u "jdbc:ignite:thin://127.0.0.1:10800/?sslMode=require&sslClientCertificateKeyStoreUrl=/ignite/certs/client/keystore.jks&sslClientCertificateKeyStorePassword=yvKvHg3O_;UFcLLq&sslClientCertificateKeyStoreType=JKS&sslTrustCertificateKeyStoreUrl=/ignite/certs/client/truststore.jks&sslTrustCertificateKeyStorePassword=yvKvHg3O_;UFcLLq&sslTrustCertificateKeyStoreType=JKS" -n ignite -p ignite
```

## Authentication Management
```sql
-- Change default password
ALTER USER "ignite" WITH PASSWORD 'MySecurePassword123!';

-- Exit SQLLine
!quit

-- Connect with new password
./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/ -n ignite -p MySecurePassword123!
```

## SQL Examples

### Creating Tables
```sql
-- Create replicated table
CREATE TABLE City (id LONG PRIMARY KEY, name VARCHAR) WITH "template=replicated";

-- Create partitioned table
CREATE TABLE Person (id LONG, name VARCHAR, city_id LONG, PRIMARY KEY (id, city_id))
WITH "backups=1, affinityKey=city_id";
```

### Sample Data Operations
```sql
-- Insert sample cities
INSERT INTO City (id, name) VALUES (1, 'Forest Hill');
INSERT INTO City (id, name) VALUES (2, 'Denver');
INSERT INTO City (id, name) VALUES (3, 'St. Petersburg');

-- Insert sample persons
INSERT INTO Person (id, name, city_id) VALUES (1, 'John Doe', 3);
INSERT INTO Person (id, name, city_id) VALUES (2, 'Jane Roe', 2);
INSERT INTO Person (id, name, city_id) VALUES (3, 'Mary Major', 1);
INSERT INTO Person (id, name, city_id) VALUES (4, 'Richard Miles', 2);

-- Query data
SELECT * FROM City;
SELECT * FROM Person;
```

## Cluster Management

### Activation and Baseline
```bash
# Activate cluster
./control.sh --user ignite --password ignite --set-state ACTIVE --yes

# Check baseline topology
./control.sh --baseline

# Enable auto baseline adjustment (timeout in milliseconds)
./control.sh --baseline auto_adjust enable timeout 30000
```

### Monitoring and Logs
```bash
# Access pod logs
kubectl exec -it -n ignite pod/ignite-cluster-0 -- /bin/bash
cd /opt/ignite/apache-ignite/work/log
cat ignite-*.log

# Check system tables
SELECT * FROM SYS.CACHES;
SELECT * FROM SYS.NODES;
```

## SQLLine Utility Commands
```sql
!tables    -- List all tables
!dropall   -- Drop all tables
!history   -- Display command history
!quit      -- Exit SQLLine
```

## Important Notes

### System Information
- **Overview**: Apache Ignite is a distributed database for high-performance computing with in-memory speed
- **Default Credentials**: 
  - Username: ignite
  - Password: ignite
- **Docker Image**: 
  - Recommended: apacheignite/ignite:2.16.0-jdk11
  - Uses JDK 11 for optimal performance
- **Documentation**: 
  - Official docs: https://www.gridgain.com/docs/latest
  - GridGain operator guide available

### Architecture Components

#### Caching Strategies
1. **Replicated Caches**:
   - Best for: Read-heavy workloads
   - Advantages:
     - Faster reads (any node can answer)
     - Data available on all nodes
   - Disadvantages:
     - Slower writes (must write to every node)
     - Higher memory usage

2. **Partitioned Caches**:
   - Best for: Write-heavy workloads
   - Advantages:
     - Faster writes (writes to specific node)
     - Efficient memory usage
   - Disadvantages:
     - Slower reads (must find specific node)
     - Data distributed across nodes

#### Cluster Discovery
- **Discovery Protocol**: Uses DiscoverySpi
- **Default Implementation**: TcpDiscoverySpi (TCP/IP based)
- **IP Finders**:
  - Default: TcpDiscoveryMulticastIpFinder (Multicast-based)
  - Alternative: TcpDiscoveryVmIpFinder (Static IP addresses)
- **Scaling Recommendation**:
  - < 100 nodes: TCP/IP Discovery
  - > 100 nodes: ZooKeeper Discovery
- **Partitioning**:
  - Default partition count: 1024
  - Controlled by affinity functions
  - Affinity keys determine data location

#### Data Persistence

1. **Write-Ahead Log (WAL)**:
   - Purpose: Ensures data durability and recovery
   - Operation:
     - Logs all data modifications
     - Updates go to WAL before disk
     - Enables transaction recovery
   - Components:
     - WAL segments store operations
     - WAL archive for node recovery

2. **Checkpointing**:
   - Process: Copies dirty pages from RAM to disk
   - Dirty pages: RAM updates pending disk write
   - Ensures data persistence and recovery

### Operational Aspects

#### Common Issues and Solutions
1. **Pod-0 Related**:
   - Symptoms:
     - Restart errors
     - Security context mismatches
     - History writing issues
   - Solutions:
     - Verify cluster activation status
     - Check security context configuration
     - Ensure proper pod initialization

2. **Distributed Joins**:
   - Types:
     - Colocated: Joined on partition key
     - Non-colocated: Different partition keys
   - Performance impact varies by join type

#### Monitoring and Metrics
- **Tools Support**:
  - Prometheus integration
  - JMX Exporter capability
  - Custom metrics available
- **Dashboard**: 
  - URL: https://www.gridgain.com/resources/blog/setting-prometheus-apache-ignite-and-gridgain
  - Features:
    - Real-time monitoring
    - Performance metrics
    - Cluster health status

#### Security Framework
1. **Authentication Options**:
   - Default authentication
   - Custom security plugins
   - OAuth2 integration

2. **Available Plugins**:
   - GridGain OAuth2 authenticator
   - Custom security implementations
   - Example implementations:
     - gridgain-oauth2-authenticator
     - gridgain-oauth2-authenticator-example

3. **Best Practices**:
   - Change default credentials
   - Implement TLS for secure communication
   - Use appropriate security plugins

### Additional Resources

#### Documentation and Guides
- [Apache Ignite Documentation](https://www.gridgain.com/docs/latest)
- [Getting Started with SQL](https://ignite.apache.org/docs/latest/sql/sql-getting-started)
- [Baseline Topology Guide](https://ignite.apache.org/docs/latest/clustering/baseline-topology)

#### Integration Resources
- [Ignite Cluster and Kubernetes Integration](https://stackoverflow.com/questions/tagged/apache-ignite+kubernetes)
- [Custom Security Plugin Guide](https://stackoverflow.com/questions/tagged/apache-ignite+security)
- [Go Client (amsokol/ignite-go-client)](https://github.com/amsokol/ignite-go-client)

#### Monitoring Tools
- [Prometheus Integration](https://github.com/GridGain-Demos/ignite-prometheus)
- [JMX Exporter Setup](https://github.com/prometheus/jmx_exporter)
- [GridGain Monitoring Dashboard](https://www.gridgain.com/resources/blog/setting-prometheus-apache-ignite-and-gridgain)




# Apache Ignite on Kubernetes — Organized Notes

*Last updated: Aug 28, 2025*

---

## 1) Quick Overview

* **Product:** Apache Ignite (fault‑tolerant distributed SQL database + compute grid)
* **Image (JDK11):** `apacheignite/ignite:2.16.0-jdk11`
* **Default credentials:** `ignite / ignite` (change after bootstrap)
* **SQL CLI:** `sqlline.sh` (Thin JDBC)

Useful docs & threads:

* Ignite Docs — What is Apache Ignite?
  [https://ignite.apache.org/docs/latest/](https://ignite.apache.org/docs/latest/)
* StackOverflow (Ignite + Kubernetes integration):
  [https://stackoverflow.com/search?q=ignite+kubernetes](https://stackoverflow.com/search?q=ignite+kubernetes)
* Spark executors not able to access Ignite in K8s:
  [https://stackoverflow.com/questions/](https://stackoverflow.com/questions/) (search thread)
* Getting started with SQL via CLI:
  [https://ignite.apache.org/docs/latest/sql-reference/sql-tool](https://ignite.apache.org/docs/latest/sql-reference/sql-tool)
* Baseline Topology:
  [https://ignite.apache.org/docs/latest/clustering/baseline-topology](https://ignite.apache.org/docs/latest/clustering/baseline-topology)
* Lists/Community:
  [https://lists.apache.org/](https://lists.apache.org/)

---

## 2) Cluster on Kubernetes

### 2.1 Shell & Logs

```bash
# Exec into a pod
kubectl exec -it -n ignite pod/ignite-cluster-0 -- /bin/bash

# Common log dirs
cd /opt/ignite/apache-ignite/work/log
ls -lah
cat ignite-*.log
# (Sometimes logs under /ignite/work/log depending on image/config)
```

### 2.2 Cluster Activation & Baseline

```bash
# Activate cluster (required after fresh start)
./control.sh --user ignite --password ignite --set-state ACTIVE --yes

# Show current baseline & nodes
./control.sh --baseline

# Enable auto-adjust baseline (time in ms)
./control.sh --baseline auto_adjust enable timeout 30000
```

> **Tip:** Auto‑adjust helps when nodes scale up/down; ensure discovery (Kubernetes IP Finder) is stable before enabling.

### 2.3 Common K8s Gotchas

* **Pod-0 restarts**: Verify Ignite actually started *and* cluster is **ACTIVE**; dependent nodes may spam warnings otherwise.
* **securityContext mismatch**: Sometimes `pod-0` runs as root while others are non‑root. Align `securityContext` across the `StatefulSet`.
* **Networking**: Use Kubernetes IP Finder / headless Service; ensure ports `47100` (communication), `47500` (discovery), `10800` (thin client), `11211` (ODBC/legacy) are open within the cluster.

---

## 3) SQL: Getting Started

### 3.1 Connect via SQLLine (inside pod)

```bash
cd apache-ignite/bin
./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/
# or from remote: jdbc:ignite:thin://<svc-dns>:10800/
```

When prompted:

```
username: ignite
password: ignite
```

### 3.2 Sample Schema & Queries

```sql
CREATE TABLE City (
  id   LONG PRIMARY KEY,
  name VARCHAR
) WITH "template=replicated";

CREATE TABLE Person (
  id      LONG,
  name    VARCHAR,
  city_id LONG,
  PRIMARY KEY (id, city_id)
) WITH "backups=1, affinityKey=city_id";

SELECT * FROM City;
SELECT p.name, c.name
FROM Person p, City c
WHERE p.city_id = c.id;
```

### 3.3 Handy SQLLine Commands

```
!tables        -- list tables
!dropall       -- drop all tables
!history       -- show command history
!quit          -- exit
```

---

## 4) Data Distribution & Performance

### 4.1 Partitioning & Affinity

* **Partitions:** 0..1023 by default.
* **Affinity function** maps keys to partitions → nodes.

### 4.2 Caching Modes

* **Replicated cache**: Faster reads (any node can serve); slower writes (data on every node).
* **Partitioned cache**: Faster writes (to owning node); reads require locating partition/primary.

### 4.3 Joins

* **Colocated join**: Join on the **affinity key** → avoids data movement.
* **Non‑colocated join**: Requires network shuffle → slower.

---

## 5) Durability: WAL & Checkpointing

* **WAL (Write‑Ahead Log):** All updates appended; ensures recovery to last committed tx after crash.
* **WAL Archive:** Holds older WAL segments needed for recovery/rebalancing.
* **Checkpointing:** Flushes dirty pages from RAM to partition files; reduces WAL replay during recovery.

Locations vary by `workDir` (often under `/opt/ignite/apache-ignite/work` or `/ignite/work`).

---

## 6) Authentication & Users

Change defaults immediately:

```bash
./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/ -n ignite -p ignite
ALTER USER "ignite" WITH PASSWORD 'MySecurePassword123!';
!quit

./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/ -n ignite -p 'MySecurePassword123!'
```

> Consider external auth (see Security plugins below) for production.

---

## 7) Clients

### 7.1 Go Client

* Repo: [https://github.com/amsokol/ignite-go-client](https://github.com/amsokol/ignite-go-client) (community)
  *Note: check protocol compatibility with Ignite 2.16 Thin Client.*

### 7.2 JDBC Thin

* URL: `jdbc:ignite:thin://host:10800/`
* Works well for SQLLine, apps, BI tools.

---

## 8) Monitoring & Metrics

### 8.1 JMX → Prometheus

* JMX Exporter (Prometheus) bridge:
  [https://github.com/prometheus/jmx\_exporter](https://github.com/prometheus/jmx_exporter)
* Guide (GridGain/Ignite):
  [https://www.gridgain.com/resources/blog/setting-prometheus-apache-ignite-and-gridgain](https://www.gridgain.com/resources/blog/setting-prometheus-apache-ignite-and-gridgain)
* Example charts: [https://github.com/GridGain-Demos/ignite-prometheus](https://github.com/GridGain-Demos/ignite-prometheus)

**Steps (high‑level):**

1. Add JMX Exporter Java agent to Ignite container.
2. Mount/export config for desired MBeans.
3. Expose an HTTP endpoint for Prometheus to scrape.
4. Build Grafana dashboards for cache, WAL, checkpoint, rebalance, SQL.

### 8.2 Useful System Tables

```sql
SELECT * FROM SYS.CACHES;
SELECT * FROM SYS.NODES;
```

---

## 9) Security Plugins (Custom/AuthN/AuthZ)

* Custom Security Plugin thread:
  [https://stackoverflow.com/questions/](https://stackoverflow.com/questions/) (search: "Custom Security Plugin for Apache Ignite")
* Blog: How to secure an Ignite cluster
  (search: Amar Gajbhiye Ignite security)
* OAuth2 Authenticator examples (GridGain):

  * [https://github.com/GridGain-Demos/gridgain-oauth2-authenticator](https://github.com/GridGain-Demos/gridgain-oauth2-authenticator)
  * [https://github.com/GridGain-Demos/gridgain-oauth2-authenticator-example](https://github.com/GridGain-Demos/gridgain-oauth2-authenticator-example)

> If adopting GridGain examples, adapt to open‑source Ignite interfaces and verify license compatibility.

---

## 10) Troubleshooting Checklist

* [ ] **Cluster state** is `ACTIVE`.
* [ ] **Baseline** includes all expected nodes; rebalance finished.
* [ ] **Discovery** (K8s IP Finder) has correct service DNS & ports.
* [ ] **Time sync** across nodes (NTP/chrony) to avoid WAL/tx issues.
* [ ] **Persistence dirs** writable and consistent UID/GID (securityContext).
* [ ] **Pod-0** log shows successful start; no repeated restarts.
* [ ] **Thin client port 10800** reachable from clients.
* [ ] **Memory config** (pageSize, dataRegion, off-heap) aligns with pod resources.

Log paths to inspect:

```
/opt/ignite/apache-ignite/work/log/ignite-*.log
/ignite/work/log/ignite-*.log
```

---

## 11) Diagrams & Artifacts

* draw\.io: [https://app.diagrams.net/](https://app.diagrams.net/)
* GDrive file (ID): `1cnA6Bv3pLExoLfG7cfcCQxYJXXapOEiGFb2Q6_OixwY`
* (Consider adding a high‑level architecture diagram: Clients ↔ Thin JDBC → Headless SVC → StatefulSet pods; include partitioning, backups, baseline.)

---

## 12) Handy Command Snippets

```bash
# Inside container
cd /opt/ignite/apache-ignite/bin
./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/

# K8s exec
kubectl exec -it pod/ignite-cluster-66944bc76c-f2b6t -n ignite -- /bin/bash

# Show caches/nodes
./sqlline.sh -u jdbc:ignite:thin://127.0.0.1/ -n ignite -p <pwd> \
  -e "SELECT * FROM SYS.CACHES;" \
  -e "SELECT * FROM SYS.NODES;"
```

---

## 13) Backlog / To‑Do

* [ ] Parameterize `StatefulSet` with consistent `securityContext` for all pods.
* [ ] Add a ConfigMap for JMX Exporter and wire Prometheus ServiceMonitor.
* [ ] Automate cluster activation + baseline via init job/hook.
* [ ] Evaluate Go client compatibility & e2e tests.
* [ ] Document persistence directories, WAL, checkpoint tuning.
* [ ] Add sample Grafana dashboard JSONs.

---

## 14) References (Direct)

* jmx\_exporter: [https://github.com/prometheus/jmx\_exporter](https://github.com/prometheus/jmx_exporter)
* ignite-prometheus: [https://github.com/GridGain-Demos/ignite-prometheus](https://github.com/GridGain-Demos/ignite-prometheus)
* GridGain blog on Prometheus setup:
  [https://www.gridgain.com/resources/blog/setting-prometheus-apache-ignite-and-gridgain](https://www.gridgain.com/resources/blog/setting-prometheus-apache-ignite-and-gridgain)
