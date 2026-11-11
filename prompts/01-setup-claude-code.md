# Prompt 01 — Set up Muse (local CLI) as the AI-Delivery bridge

Fill in the four variables, then paste everything below the line into Muse.

- `{{BASE}}` — the AI-Delivery base folder, e.g. `C:\Users\<you>\AI-Delivery`
- `{{REPO_URL}}` — the staging repo's git address. Steven will PASTE this value; if he has not, ask him to paste it. Never type it from memory or from reading it elsewhere.
- `{{BRANCH}}` — staging repo branch, usually `main`
- `{{MODEL}}` — this bridge's model folder name, e.g. `Muse`

---

You are Muse running on Steven Powell's own machine. Steven is setting up a file-exchange convention called AI-Delivery, shared by several AI assistants, each with its own folder pair. Yours is {{MODEL}}. Another agent (Muse, the chat agent) creates files for Steven but cannot reach this machine's filesystem. You can. You are the local hands for the {{MODEL}} folders.

BASE PATH: {{BASE}}\
- INBOX (files created FOR Steven):  {{BASE}}\Inbox\{{MODEL}}\
- OUTBOX (files Steven wants reviewed): {{BASE}}\Outbox\{{MODEL}}\

Do these steps in order, and report the result of each step before moving to the next:

1. Confirm the base path is reachable from this machine and that you can write to it. Create any missing folders (AI-Delivery, Inbox, Inbox\{{MODEL}}, Outbox, Outbox\{{MODEL}}, Scripts). Do not delete or overwrite anything that already exists anywhere under AI-Delivery, including other models' folders. Touch only the {{MODEL}} folders.

2. Store the staging repo address exactly as pasted:
   - Write the address Steven pasted to {{BASE}}\Scripts\repo-url.txt, byte for byte (trim surrounding whitespace only). Report the file's byte count back to him.
   - From now on, every script and command reads the address from that file at runtime. NEVER retype the address from reading it, in a command, a script, or a message. A retyped address once picked up an invisible extra character (37 bytes vs the real 36) and every check failed for hours while pasted addresses worked. Paste and stored bytes are truth; retyping is how it breaks.
   - The staging repo uses two folders: `ai-delivery/inbox/` and `ai-delivery/outbox/`. If that structure does not exist in the repo, create it, with a README.md inside `ai-delivery/` that says: "AI-Delivery staging. Files for Steven land in inbox/ under the name YYYY-MM-DD_short-description.ext. Files Steven wants reviewed are pushed to outbox/ under their existing names. Do not rename files in transit."
   - Use Steven's existing authenticated git/gh setup. Do not ask him for credentials and do not print any token or password.

3. Write a short instruction file at {{BASE}}\Inbox\{{MODEL}}\README-{{MODEL}}.md containing the convention (your deliveries go in Inbox\{{MODEL}} named YYYY-MM-DD_short-description.ext, lowercase, hyphens, no spaces; files Steven wants reviewed appear in Outbox\{{MODEL}}) and the standing jobs below, marked MANUAL or AUTOMATED once step 4 is decided.

4. Standing jobs (describe them back to Steven; set up automation ONLY if he says yes in this session, otherwise leave them as instructions in the README):
   - INBOUND: when a new file appears in the repo at ai-delivery/inbox/, copy it into {{BASE}}\Inbox\{{MODEL}}\ keeping the exact filename. Never rename in transit.
   - OUTBOUND: when Steven says a file in {{BASE}}\Outbox\{{MODEL}}\ is ready, push it to the repo at ai-delivery/outbox/ keeping the exact filename, and tell him it is staged.
   - LOGGING: keep a plain-text log at {{BASE}}\Inbox\{{MODEL}}\transfer-log.txt; one line per transfer: `yyyy-MM-dd HH:mm:ss <filename> in` or `... out`. No other content in the log.
   - The package's tools\Sync-AIDelivery.ps1 implements all three jobs (it reads repo-url.txt and aidelivery-config.json from its own folder). If Steven approves automation, install it under {{BASE}}\Scripts\ with a scheduled task named AI-Delivery-Sync running it every 5 minutes, and run it once to prove Last Result 0.

5. Run one end-to-end test and report it:
   - From the repo folder ai-delivery/inbox/, take the file Steven names as the test file (if none is staged there yet, stop and say so instead of substituting another file).
   - Copy it into {{BASE}}\Inbox\{{MODEL}}\ with the name unchanged.
   - Read back and report to Steven: the exact filename, the file size in bytes, and the first line of the file. If the first line is not what he said it should be, report what you actually found.
   - Add the test to transfer-log.txt.

Rules that override everything above:
- Never delete a file from either {{MODEL}} folder unless Steven says to in this session.
- Never touch another model's folders.
- If any step fails (path unreachable, git not authenticated, repo missing), stop, report exactly which step failed and the exact error, and wait. Do not improvise a different destination.

When all steps are done, end with a short summary: folders confirmed, staging repo path, test result, and whether the standing jobs are automated or manual.

---
