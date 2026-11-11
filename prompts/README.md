# AI-Delivery — Prompt Library

These are the setup prompts that connect each AI model to the shared desk.
One prompt per model. Fill in the variables at the top of each prompt
(they come from the questions `Setup-AIDelivery.ps1` asked), then paste the
whole prompt into that model's chat or CLI.

| File | Hand it to | What it does |
| --- | --- | --- |
| `01-setup-claude-code.md` | Muse (local CLI) | Full bridge setup: folders, git staging sync, scheduled task, end-to-end test. The proven original from the first live deployment (Nov 11, 2026), generalized. |
| `02-setup-grok.md` | Grok / Grokbot (hands on the machine) | Sets Grok up as the machine operator: delivers artifacts to its inbox, reads its outbox, runs installs when asked. |
| `03-setup-chatgpt.md` | ChatGPT (no local hands) | Sets the convention for a chat-only model: Steven carries files via the router; ChatGPT names deliverables correctly and says exactly what it produced. |
| `04-setup-template-new-model.md` | Any new model | The blank template. Copy it, fill the variables, adjust the role paragraph. |

## The rules every prompt teaches

- **Inbox** = files the model created FOR Steven. **Outbox** = files Steven wants that model to see.
- Filenames: `YYYY-MM-DD_short-description.ext`, lowercase, hyphens, no spaces. Never rename a file in transit.
- **Copies, never moves.** Nothing is deleted unless Steven says so in that conversation.
- **Paste, never retype, addresses and identifiers.** A retyped repo address once carried an invisible extra character and failed for hours. Tools read addresses from `repo-url.txt` at runtime.
- **Verify, then report.** Every setup ends with a real end-to-end test whose result is reported in numbers (filename, size, first line), not adjectives.
- A model touches **only its own boxes** unless Steven, the human router, copies a file across. That copying is deliberate: the human decides what crosses between models.
