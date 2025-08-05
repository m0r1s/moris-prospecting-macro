# moris Prospecting Macro
This is a simple macro for the roblox game prospecting.

**Join the discord:** https://discord.gg/moris

---

## Features

- **Full Automated Farming**: Automatically performs dig-move-pan sequences
- **Auto-Sell System**: Configurable auto-selling after specified amount of cycles
- **Cycle Tracking**: Persistent cycle counter with GUI display (resets per reload)
- **Debug Mode**: Optional debug tooltips for debugging obviously
- **Settings Persistence**: Automatically saves and loads user settings
- **Window Move & Resize**: Auto-resizes and positions Roblox window
- **Terrain Detection**: Auto-detects current terrain for walking (water or land)
- **Adjustable Timing**: Adjustable Timing for walking and restarting the next dig

---

## Getting Started

### What You Need

- Windows PC
- [Autohotkey V2.0](https://www.autohotkey.com/)
- moris prospecting macro.ahk
- Roblox running

### Controls

| Key | What it does |
|-----|--------------|
| `F1` | Start the macro |
| `F2` | Reload the macro |

### Getting Started

1. Open Roblox and join Prospecting
2. Run the script
3. Hit `F1` to start
4. The script will resize your Roblox window and start doing its thing

---

## Configuration

Settings are automatically saved to `settings.ini` and include:

- Debug tooltip preferences
- Auto-sell enabled/disabled state
- Auto-sell cycle threshold
- Adjustable Walk Time = How long (ms) to hold the walk button after new terrain detection
- Adjustable Dig Wait = How long to wait to start the next dig

## If Something Goes Wrong

- Make sure Roblox is actually open and you can see the game window
- Check that AutoHotkey v2.0 installed correctly
- Make sure windows scaling setting is set to 100%
- Roblox should be in windowed mode, not fullscreen (the script will try to fix this automatically)
- Adjust Walk Time or Dig Wait to test if either are causing your problem
- Try turning on debug tooltips to see what the script is trying to do
