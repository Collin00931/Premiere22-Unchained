# Claude Bridge for Premiere Pro

**Edit videos in Adobe Premiere Pro by talking to Claude.**

Claude Bridge connects the Claude desktop app to Premiere Pro, so you can describe an edit in plain language and Claude makes it in your timeline. For example:

> *"Look at my active sequence, cut out 0:12–0:15, put a cross dissolve between the first two clips, add a marker called 'Intro end' and show me the frame at 10 seconds."*

Claude can read your project, sequences, tracks and clips. It then makes the changes with real Premiere actions: cutting, trimming, moving, placing clips, adding effects and transitions, animating properties with keyframes, and exporting. It can also render a frame of your timeline and look at it, so it can check its own work before you do.

### Why use it?
- **Save time on repetitive work:** cutting out sections, adding the same transition everywhere, placing markers, setting up sequences and exports.
- **Edit by describing:** you don't need to know where every option is hidden in Premiere's menus.
- **Everything stays local:** the bridge only runs on your own computer (`127.0.0.1`), protected by a random token. Your footage never gets uploaded.
- **No Creative Cloud needed:** it's a plain CEP panel. It doesn't need Creative Cloud, an Adobe sign-in, the Exchange store or Media Encoder.
- **Lightweight:** there's nothing to compile and no npm packages. The Claude desktop app already includes everything it needs to run.

Built and tested on **Premiere Pro 2022 (v22)**. It should also work on 2019–2025 (CEP 9–12). Windows is fully supported, and macOS should work with a manual install.

### How it works
```
Claude Desktop ──(MCP)──> premiere-pro-bridge ──(HTTP 127.0.0.1:47823 + token)──> Claude Bridge panel ──> ExtendScript ──> Premiere
```
The **Claude Bridge panel** runs inside Premiere and carries out the commands using Premiere's own scripting engine (ExtendScript). The **MCP server** (`premiere-pro-bridge`) gives Claude 29 tools and passes each call on to the panel.

## Install (Windows)

1. Close Premiere Pro, then unzip this folder anywhere.
2. Double-click **install.bat** (no admin needed). It:
   - copies the panel to `%APPDATA%\Adobe\CEP\extensions\com.claude.premierebridge`
   - sets `PlayerDebugMode = 1` under `HKCU\Software\Adobe\CSXS.9–12` so Premiere loads the unsigned panel
3. Start Premiere Pro and open **Window → Extensions → Claude Bridge**. The panel should turn green and say
   "Listening on 127.0.0.1:47823". Dock it somewhere, because it has to stay open while Claude is editing.
4. Double-click **premiere-pro-bridge.mcpb**. Claude Desktop opens and offers to install it, so click Install.
   (Claude Desktop includes its own Node.js, so you don't need to install it.)

Then ask Claude something like: *"Look at my active sequence in Premiere Pro."*

### Manual MCP config (if the .mcpb won't install)
You need [Node.js](https://nodejs.org) for this. Add the following to `%APPDATA%\Claude\claude_desktop_config.json`, then restart Claude Desktop:
```json
{
  "mcpServers": {
    "premiere-pro-bridge": {
      "command": "node",
      "args": ["C:\\Users\\YOUR_NAME\\AppData\\Roaming\\ClaudePremiereBridge\\mcp-server.js"]
    }
  }
}
```

## What Claude can do (29 tools)
| Area | Tools |
|---|---|
| Inspect | `ping`, `get_project`, `list_project_items`, `get_sequence`, `get_clip_properties`, `list_effects`, `view_frame` (Claude sees the rendered frame) |
| Project | `import_files`, `create_bin`, `create_sequence_from_clips`, `open_sequence`, `save_project` |
| Timeline | `place_clip` (insert/overwrite, with source in/out), `razor`, `remove_clips` (ripple), `move_clip`, `trim_clip`, `set_speed`*, `set_clip_enabled`, `set_track_state` |
| Look & sound | `set_clip_property` (Motion/Opacity/Volume/effect params, with keyframes), `add_effect`*, `add_transition`* |
| Navigation | `add_marker`, `set_playhead`, `set_in_out` |
| Output | `list_export_presets`, `export_sequence` (renders inside Premiere, no Media Encoder) |
| Escape hatch | `run_extendscript`: arbitrary ExtendScript for anything else |

\* These use Premiere's undocumented "QE" API. They work in 2022 but may act differently in other versions.

## Tips & limits
- **Save first.** Scripted edits land in Premiere's undo history, but some (especially QE ones) can be hard to undo. Ctrl+S before a big edit.
- Clip indices are per track, from left to right. They shift after cuts and deletes, so Claude re-reads `get_sequence` after each edit.
- Times are in seconds. Position values are normalized (0–1), so `[0.5, 0.5]` is the center of the frame.
- Security: the panel only listens on `127.0.0.1`, it needs a random token stored in `%APPDATA%\ClaudePremiereBridge\token`, and it rejects browser requests.
  To use a different port, put the number in `%APPDATA%\ClaudePremiereBridge\port`.

## Troubleshooting
- **Panel missing from Window → Extensions:** run install.bat again, and fully quit Premiere (check Task Manager) before you reopen it.
- **"Cannot reach Premiere Pro":** the panel isn't open, or another program is using port 47823.
- **Panel is blank:** Premiere 2022 uses CSXS.11. Check that `HKCU\Software\Adobe\CSXS.11\PlayerDebugMode` is the string `1`.
- **Debugging:** create a `.debug` file in the extension folder to use Chrome DevTools, or look at the log in the panel itself.

## Uninstall
Delete `%APPDATA%\Adobe\CEP\extensions\com.claude.premierebridge` and `%APPDATA%\ClaudePremiereBridge`, and remove the extension in Claude Desktop → Settings → Extensions.
