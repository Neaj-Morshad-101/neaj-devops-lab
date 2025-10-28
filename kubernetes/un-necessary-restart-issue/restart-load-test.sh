#!/usr/bin/env bash
set -eu
# restart-load-test.sh
# Usage:
#   ./restart-load-test.sh
# Environment variables you can override:
#   N=100                       # number of Restart OpsRequests to run
#   NAMESPACE=demo              # namespace where DB lives
#   DB_NAME=mssql-standalone    # name of your MSSQLServer CR (databaseRef.name)
#   POD_NAME_PREFIX="${DB_NAME}"# prefix of pod names to track (default: DB_NAME)
#   OPS_KIND=MSSQLServerOpsRequest
#   OPS_API_VERSION=ops.kubedb.com/v1alpha1
#   OPS_TIMEOUT=180             # seconds to wait for each OpsRequest to finish (per request)
#   WAIT_BETWEEN=2              # seconds to sleep after an OpsRequest is marked Successful (gives cluster time to settle)
#
# Requires: kubectl, jq
#

N="${N:-100}"
NAMESPACE="${NAMESPACE:-demo}"
DB_NAME="${DB_NAME:-mssql-standalone}"
POD_NAME_PREFIX="${POD_NAME_PREFIX:-${DB_NAME}}"
OPS_KIND="${OPS_KIND:-MSSQLServerOpsRequest}"
OPS_API_VERSION="${OPS_API_VERSION:-ops.kubedb.com/v1alpha1}"
OPS_TIMEOUT="${OPS_TIMEOUT:-180}"
WAIT_BETWEEN="${WAIT_BETWEEN:-2}"
TMPDIR="$(mktemp -d)"
OPS_LOG="$TMPDIR/ops-requests.log"
PODS_SNAP_DIR="$TMPDIR/pods-snapshots"
mkdir -p "$PODS_SNAP_DIR"

command -v kubectl >/dev/null 2>&1 || { echo "kubectl required"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "jq required"; exit 1; }

echo "Test config: N=$N NAMESPACE=$NAMESPACE DB_NAME=$DB_NAME POD_NAME_PREFIX=$POD_NAME_PREFIX TMPDIR=$TMPDIR"
echo "Snapshots will be written to $PODS_SNAP_DIR"

# helper: snapshot current pods for tracked prefix
snapshot_pods() {
  # collects pods with names that start with POD_NAME_PREFIX
  # writes to file: $PODS_SNAP_DIR/iter-<i>.json
  local label="$1" # a descriptive suffix (e.g., iter-1)
  kubectl get pods -n "$NAMESPACE" -o json \
    | jq --arg prefix "$POD_NAME_PREFIX" '.items | map(select(.metadata.name | startswith($prefix)))' \
    > "$PODS_SNAP_DIR/$label.json"
}

# helper: wait for ops request to become Successful (poll)
wait_for_ops_success() {
  local name="$1"
  local timeout="$2"
  local ns="$3"
  local end=$(( $(date +%s) + timeout ))
  while true; do
    # .status.phase or .status.conditions may contain success indicator; adapt to your CR if different
    status=$(kubectl get -n "$ns" "$OPS_KIND" "$name" -o json 2>/dev/null || true)
    if [ -n "$status" ]; then
      # try to read .status.phase first, fallback to conditions[*].type==Successful
      phase=$(echo "$status" | jq -r '.status.phase // empty')
      if [ "$phase" == "Successful" ]; then
        echo "OK: $name phase=Successful"
        return 0
      fi
      # fallback: check conditions array for type==Successful and status True
      cond=$(echo "$status" | jq -r '.status.conditions // [] | map(select(.type == "Successful" and (.status == "True" or .status == "Succeeded"))) | length')
      if [ "$cond" != "0" ]; then
        echo "OK: $name condition Successful found"
        return 0
      fi
    fi

    if [ "$(date +%s)" -gt "$end" ]; then
      echo "TIMEOUT waiting for $name to become Successful (waited ${timeout}s)"
      # dump last status to log for debugging
      echo "=== Last status for $name ===" >> "$OPS_LOG"
      kubectl get -n "$ns" "$OPS_KIND" "$name" -o yaml >> "$OPS_LOG" 2>&1 || true
      return 1
    fi
    sleep 5
  done
}

# initial snapshot
echo "Taking initial pod snapshot..."
snapshot_pods "iter-0"

# main loop
for i in $(seq 1 "$N"); do
  opsname="msops-restart-$i"
  echo "=== Iteration $i / $N: creating OpsRequest $opsname ===" | tee -a "$OPS_LOG"

  # create opsrequest yaml and apply
  cat <<EOF | kubectl apply -n "$NAMESPACE" -f -
apiVersion: ${OPS_API_VERSION}
kind: ${OPS_KIND}
metadata:
  name: ${opsname}
  namespace: ${NAMESPACE}
spec:
  type: Restart
  databaseRef:
    name: ${DB_NAME}
  timeout: 3m
  apply: IfReady
EOF

  # wait for Successful (OPS_TIMEOUT seconds)
  if ! wait_for_ops_success "$opsname" "$OPS_TIMEOUT" "$NAMESPACE"; then
    echo "OpsRequest $opsname did not become Successful within $OPS_TIMEOUT seconds — logging and continuing"
    # continue (we still snapshot pods to observe what happened)
  fi

  # short settle window
  sleep "$WAIT_BETWEEN"

  # snapshot pods after this iteration
  snapshot_pods "iter-$i"

  # optional: record event for opsrequest
  echo "$(date -Iseconds) $opsname" >> "$OPS_LOG"
done

echo "All iterations created. Now analyzing snapshots..."

# Analysis:
# For each snapshot file, produce lines: <iter> <podname> <uid> <creationTimestamp>
analysis_csv="$TMPDIR/pod-creation-log.csv"
: > "$analysis_csv"
for f in "$PODS_SNAP_DIR"/iter-*.json; do
  iter=$(basename "$f" | sed -E 's/iter-([0-9]+)\.json/\1/')
  jq -r --arg iter "$iter" \
    '.[] | [$iter, .metadata.name, .metadata.uid, .metadata.creationTimestamp] | @csv' \
    "$f" >> "$analysis_csv"
done

# Now compute unique UIDs per pod name
echo "Pod creation / UID summary:" > "$TMPDIR/summary.txt"
awk -F, '{ gsub(/"/,"",$0); iter=$1; pod=$2; uid=$3; ts=$4; key=pod "||" uid; if(!(key in seen)){ seen[key]=1; pods[pod]++ } } END { for(p in pods) print p, pods[p] }' "$analysis_csv" | sort >> "$TMPDIR/summary.txt"

# A nicer table with counts and expected counts:
# For a perfectly-behaved restart that recreates pods exactly once per iteration,
# expected creations = 1 (initial) + N (one recreation per run). We compute actual creations and compare.
echo -e "\nDetailed counts (pod, actual_creations, expected_creations, extra_creations)" >> "$TMPDIR/summary.txt"
awk -F, '{ gsub(/"/,"",$0); pod=$2; uid=$3; key=pod "||" uid; if(!(key in seen)){ seen[key]=1; cnt[pod]++ } } END { for(p in cnt) { expected=1+'"$N"'; extra=cnt[p]-expected; printf \"%s,%d,%d,%d\n\", p, cnt[p], expected, extra } }' "$analysis_csv" | sort >> "$TMPDIR/summary.txt"

cat "$TMPDIR/summary.txt"
echo
echo "Full CSV of creations per iteration: $analysis_csv"
echo "Snapshot files: $PODS_SNAP_DIR"
echo "Ops events log: $OPS_LOG"

# print pods that had extra creations (extra > 0)
echo
echo "Pods with extra creations (possible duplicate restarts):"
awk -F, '{ if(NR>1){ pod=$1; actual=$2; expected=$3; extra=$4; if(extra>0) print pod, actual, expected, extra } }' "$TMPDIR/summary.txt" | sed -n '2,$p' || true

echo
echo "Done. Inspect $TMPDIR for more information."
