# CKA Practice (Simple Edition)

Straightforward CKA practice labs derived from the CKA-PREP playlist. Every question lives in its own folder with bash files:

- `LabSetUp.bash` — set up the environment for the question.
- `Questions.bash` — the scenario text plus the YouTube link for the walkthrough.
- `SolutionNotes.bash` — a step-by-step solution when you need a hint.
- `validate.bash` — automatic validation checks to confirm your solution is correct.
- `cleanup.bash` — clean up and remove resources created during the question.

---

## How to Use

1. Launch the [Killercoda CKA playground](https://killercoda.com/cka) or your own cluster.
2. Clone this repo inside the environment:
   ```bash
   git clone https://github.com/markdjones82/CKA-PREP-2025-v2.git ~/CKA-PREP-2025-v2
   cd ~/CKA-PREP-2025-v2
   ```
3. Run a question setup by number:
   ```bash
   scripts/run-question.sh 5
   ```
4. Work through the task, then consult `SolutionNotes.bash` if you need help.
5. Validate your solution:
   ```bash
   scripts/validate-question.sh 5
   ```
6. Clean up resources when done:
   ```bash
   scripts/cleanup-question.sh 5
   ```

---

## Validating Your Solutions

Each question has a `validate.bash` script that runs automated checks against your cluster to confirm the solution is correct.

### Validate a single question
```bash
# By question number
scripts/validate-question.sh 5

# By directory name
scripts/validate-question.sh Question-5-HPA
```

### Validate all questions
```bash
scripts/validate-question.sh all
```

The script outputs `PASS` or `FAIL` for each check, with a final score summary. Exit code is `0` if all checks pass, non-zero otherwise.

---

## Simulated Exam Desktop (VSCodium)

You can use **VSCodium** (an open-source VS Code build) inside the Killercoda simulated desktop to edit files in a familiar IDE environment, similar to what is available in the real CKA exam.

> **NOTE: A paid Killercoda subscription is required** for the simulated desktop environment.
> Without it, the desktop GUI is not available and VSCodium cannot be launched graphically.

### Install VSCodium
```bash
scripts/install-codium.sh
```

### Launch VSCodium
Once installed, open it from inside your repo:
```bash
cd ~/CKA-PREP-2025-v2
codium --no-sandbox --user-data-dir .
```

This opens VSCodium in the current directory, allowing you to browse and edit all question files directly.

---

## Available Questions

| # | Topic | Video |
|---|-------|-------|
| 1 | MariaDB — Persistent Volume | https://youtu.be/aXvvc1EB1zg |
| 2 | ArgoCD — Install via Helm (no CRDs) | https://youtu.be/e0YGRSjb8CU |
| 3 | Sidecar Container | https://youtu.be/3xraEGGQJDY |
| 4 | Resource Allocation | https://youtu.be/ZqGDdETii8c |
| 5 | HPA — HorizontalPodAutoscaler | https://youtu.be/YGkARVFKtmM |
| 6 | CRDs — cert-manager | https://youtu.be/SA1DzLQaDJs |
| 7 | PriorityClass | https://youtu.be/CZzxGyF6OHc |
| 8 | CNI & Network Policy | https://youtu.be/Uc04Ui4x3EM |
| 9 | cri-dockerd | https://youtu.be/ybzo1vXiqjU |
| 10 | Taints & Tolerations | https://youtu.be/oy6Mdqt1-jk |
| 11 | Gateway API | https://youtu.be/G9zispvOCHE |
| 12 | Ingress | https://youtu.be/sy9zABvDedQ |
| 13 | Network Policy | https://youtu.be/rA8mXYTU0W8 |
| 14 | Storage Class | https://youtu.be/di7X7OHn2fc |
| 15 | Etcd Fix | https://youtu.be/IL448T6r8H4 |
| 16 | NodePort Service | — |
| 17 | TLS Config | — |
| 18 | kubectl patch — Resource Limits | — |
