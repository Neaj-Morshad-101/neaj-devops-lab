
N="${N:-100}"     # number of OpsRequests to run
NAMESPACE="${NAMESPACE:-demo}"
DB_NAME="${DB_NAME:-pg-cluster}" # Name of DB database CR
POD_PREFIX="${POD_PREFIX:-${DB_NAME}}"
OPS_KIND="${OPS_KIND:-PostgresOpsRequest}"
OPS_API_VERSION="${OPS_API_VERSION:-ops.kubedb.com/v1alpha1}"
OPS_TIMEOUT="${OPS_TIMEOUT:-600}" # max wait for OpsRequest success
WAIT_BETWEEN="${WAIT_BETWEEN:-0}" # seconds to sleep after each OpsRequest
SNAP_INTERVAL="${SNAP_INTERVAL:-2}"  # seconds between continuous pod snapshots


OUTDIR="./postgres-restart-uid-output"



# aggregate unique UIDs per pod
AGG="$OUTDIR/pod-uid-aggregate.txt"
: > "$AGG"
# read every snapshot csv and record unique uid per pod in awk
awk -F, '
{
  gsub(/"/,"",$0);
  pod=$1; uid=$2;
  key = pod "||" uid;
  if (!(key in seen)) {
    seen[key]=1;
    pods[pod]++;
  }
}
END {
  for (p in pods) {
    print p "," pods[p];
  }
}
' "$OUTDIR/snapshots/"*.csv | sort > "$AGG"

# print results: pod -> total creations (UID count)
echo "Pod creations (unique UIDs per pod):"
column -t -s, "$AGG" | while IFS=, read -r pod cnt; do
  echo "$pod: $cnt"
done

# expected creations = 1 (initial) + N (one per OpsRequest)
echo
echo "Expected creations per pod (if one recreation per OpsRequest): $((1 + N))"
echo
echo "Results saved to: $OUTDIR (snapshots and $AGG)"
echo "Done."
