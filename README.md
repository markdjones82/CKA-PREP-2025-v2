# CKA Practice (Simple Edition)

Straightforward CKA practice labs derived from the CKA-PREP playlist. Every question lives in its own folder with three bash files:

- `LabSetUp.bash` � copy/paste into Killercoda (or any Kubernetes cluster) to prep the environment.
- `Questions.bash` � the scenario text plus the YouTube link for the walkthrough.
- `SolutionNotes.bash` � a step-by-step solution when you need a hint.

## How to Use
1. Launch the CKA Killercoda CKA playground or your own cluster.
2. Clone this repo inside the environment.
3. Pick a folder under `Question-*`.
4. Run `./scripts/run-question.sh Question-01` or cd ~/CKA-PREP-2025-v2
bash scripts/run-question.sh "Question-9 Network-Policy" to apply the setup and print the question text, or run `bash Question-01/LabSetUp.bash` manually.
5. Work through the task, then consult `SolutionNotes.bash` if you need help.

## Available Questions
| Question | Topic | Video |
|----------|-------|-------|
| Question-01 | Install Argo CD using Helm without CRDs | https://youtu.be/8GzJ-x9ffE0 |

More questions can be added by copying the template folder and dropping in the three bash files from the original collection.
