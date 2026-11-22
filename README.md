# 💍 Warden Ring Manager

### A safer, smarter ring swap — with a Might planner built in.

Manage Warden ring upgrades, plan augment setups, and compare your current and projected Might from one MacroQuest window.

> **Built for MacroQuest Lua** · Ring swaps · Saved aug loadouts · Might planning

## ✨ Features

| | Feature | What it does |
|---|---|---|
| 💍 | **Warden ring swaps** | Recognizes supported ring ranks and variants, handles Pietri hand-ins, and tracks swap progress. |
| 🧭 | **MQ2Nav travel** | Navigates to Pietri when you are too far away. Requires MQ2Nav to be loaded and Pietri to be present in the zone. |
| 🛡️ | **Augment safeguards** | Removes installed augments before hand-ins, handles confirmation dialogs, checks cursor state, and verifies augment insertion. Stops and reports a status if a step fails. |
| 🎒 | **Custom aug loadouts** | Choose a ring version, fill compatible slots from augments in your bags or on the managed ring, name the setup, and save it for later. |
| 🔎 | **Compact augment browser** | Groups augments by type, filters to the selected slot, and shows icons and key stats. Hover for more stats; right-click to link an item in game. |
| 📊 | **Might calculator** | Compare your current and projected Might, including party estimates and the selected ring's contribution. |
| 🏰 | **Instance planner** | Browse Solo/Duo, Group, and Raid progression suggestions, difficulty estimates, and suggested Might. |
| 🪟 | **Single-screen UI** | Ring controls, loadouts, and Might planning flow together in one ImGui window. |

## 🚀 Install

1. Copy `ring.lua` into your MacroQuest `lua` directory.
2. Make sure MacroQuest's Lua and ImGui support are available.
3. Load **MQ2Nav** if you want automatic travel to Pietri.
4. In game, run:

   ```text
   /lua run ring
   ```

## 🎮 Use

1. Select the target ring version.
2. Choose a saved loadout, or select augments slot by slot and save a new one.
3. Review the displayed target ring and augments, then click **Swap Ring**.
4. Watch the status line for navigation, hand-in, and installation progress.

Keep your cursor clear before starting. The script validates the selected augments and stops when it detects a failed or unexpected operation; review the status message before trying again.

Loadouts are stored locally in MacroQuest's config directory, separately for each server and character.

## 📈 Might estimates

Might values and instance suggestions are planning aids, not an authoritative eligibility check. Progression data may change, and party-composition reductions are not modeled. Confirm current requirements with your server's resources before relying on an estimate.

The calculator references [EQ Might progression](https://www.eqmight.com/progression) alongside the progression information represented in the script.

## 📦 Files

- `ring.lua` — the MacroQuest script
- `README.md` — features, setup, and usage
