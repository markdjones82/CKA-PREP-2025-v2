#!/bin/bash
set -e

# Step 1: Create namespace
kubectl create namespace patch-ns || true

# Step 2: Create deployment with constrained resource limits
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-app
  namespace: patch-ns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: resource-app
  template:
    metadata:
      labels:
        app: resource-app
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF

# Step 3: Install a PROMPT_COMMAND hook to capture every command to a dedicated audit log.
# This is more reliable than reading ~/.bash_history (which is flushed lazily).
AUDIT_LOG="/tmp/cka-q18-audit.log"
truncate -s 0 "$AUDIT_LOG" 2>/dev/null || true

HOOK='export CKA_Q18_AUDIT=/tmp/cka-q18-audit.log; _cka_q18_audit() { history 1 | sed "s/^[[:space:]]*[0-9]*[[:space:]]*/" >> "$CKA_Q18_AUDIT"; }; PROMPT_COMMAND="_cka_q18_audit${PROMPT_COMMAND:+; $PROMPT_COMMAND}"'

# Write the hook to a sourced file so the user can activate it
cat > /tmp/cka-q18-hook.bash <<'HOOKEOF'
export CKA_Q18_AUDIT=/tmp/cka-q18-audit.log
_cka_q18_audit() {
  history 1 | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' >> "$CKA_Q18_AUDIT"
}
if [[ "$PROMPT_COMMAND" != *"_cka_q18_audit"* ]]; then
  PROMPT_COMMAND="_cka_q18_audit${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
fi
HOOKEOF

echo ""
echo "Lab setup complete."
echo "Deployment 'resource-app' created in namespace 'patch-ns'."
echo ""
echo "IMPORTANT: Run the following command to enable command audit logging:"
echo "  source /tmp/cka-q18-hook.bash"
echo ""
echo "Run Questions.bash to view the task."
