# AI-Delivery

![The AI-Delivery desk: each little model at its own door, with IN and OUT slots, and the postman in the middle handing off an envelope.](assets/ai-delivery-desk.jpg)

*The desk. Every model gets a door and two slots; the human is the postman. (Illustration generated with AI for this project.)*

A shared desk for AI assistants and the human who routes between them.

Several AI models help Steven Powell, but they cannot talk to each other and most cannot touch his filesystem. AI-Delivery gives each model a pair of folders on his machine and a small set of tools and conventions for moving files between them. The models never share a chat. They share a desk, and the human decides what gets slid across it.

This is the Council idea in miniature: models with different strengths, one human at the center, artifacts instead of summaries crossing between them.

**Built and proven live on November 11, 2026**, on a real home network, in one morning: a context seed, a published essay package, a network map, and a 15-page report all crossed between models through these boxes before this package was written down.

## The layout

```
<BASE>\                          e.g. C:\Users\<you>\AI-Delivery
  Inbox\<MODEL>\                 files the model created FOR Steven
  Outbox\<MODEL>\                files Steven wants that model to see
  Scripts\                       sync script, config, repo-url.txt
  Archive\
  ai-delivery-router.py          the web router (lives above the boxes)
  Run-AIDeliveryRouter.bat
```

Models on the original desk: `Muse`, `Grok-Bot`, `ChatGPT`, and `Caeled` (Steven's own box). Any folder pair works; the tools discover boxes automatically.

## Conventions

- Filenames: `YYYY-MM-DD_short-description.ext`, lowercase, hyphens, no spaces. Never rename a file in transit.
- **Copies, never moves.** The router and sync never delete and never silently overwrite. A different file with the same name is a conflict, reported, not replaced.
- Every transfer is logged in the destination box's `transfer-log.txt`, one line: `yyyy-MM-dd HH:mm:ss <filename> in|out`, router copies tagged `(web router)`.
- **Paste, never retype, addresses.** The staging repo address is stored byte-for-byte in `Scripts\repo-url.txt` and read at runtime. A retyped address once picked up an invisible extra character and every repo check failed for hours while pasted addresses worked. This rule is load-bearing.

## Components

| Piece | What it does |
| --- | --- |
| `Setup-AIDelivery.ps1` | Interactive install. Prompts for every variable (base path, staging repo address, branch, model list, staging model, sync interval), builds the folders, writes config, validates the repo, installs tools, optionally creates the scheduled sync task, runs the sync once. |
| `tools/ai-delivery-router.py` | The router web page. Localhost only (127.0.0.1:8765), Python standard library, no installs. Shows every box and file, tick files in one row, pick a destination, Copy. Hash-verifies every copy. Base folder defaults to wherever the script lives. Compile it to a single exe with: `pyinstaller --onefile --console --name AIDeliveryRouter ai-delivery-router.py` |
| `tools/Move-AIDelivery.ps1` | The same routing as a console menu, for keyboard people and for machines where the web page is not running. |
| `tools/Sync-AIDelivery.ps1` | The git bridge for ONE model's boxes (the model whose agent works through git). Reads `repo-url.txt` and `aidelivery-config.json` from its own folder; runs unattended from Task Scheduler. Inbound staging `ai-delivery/inbox/` to local Inbox; outbound local Outbox to staging `ai-delivery/outbox/` with commit and push. |
| `prompts/` | The prompt library: one setup prompt per model (Muse, Grok, ChatGPT) plus a template for any new model. |

## Quick start

1. Clone this repo anywhere on the machine.
2. Run `powershell -ExecutionPolicy Bypass -File Setup-AIDelivery.ps1` and answer the questions. Have the staging repo's git address ready to **paste**.
3. Open `prompts/` and hand each model its setup prompt.
4. Double-click `Run-AIDeliveryRouter.bat` in the base folder and open http://127.0.0.1:8765 whenever you want to route a file: tick it in its home box, choose the destination box, press Copy.

## Safety posture

- The router binds to 127.0.0.1 only. It is a page on the machine, not a service on the network.
- No tool in this package deletes files. Cleanup is a human decision made in Explorer.
- The sync holds no credentials; it uses the machine's existing git authentication.
- Nothing here phones home. The only network traffic is the git sync to Steven's own staging repo and the browser on the same machine.

## License

MIT. See `LICENSE`. Contributions welcome; see `CONTRIBUTING.md`.

## The idea, in one line

Give every model an inbox and an outbox, keep the human as the router, and let artifacts, not summaries, cross between them.
