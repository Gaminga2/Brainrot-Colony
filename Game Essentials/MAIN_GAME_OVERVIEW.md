# 🏰 PROJECT BRAINROT CASTLE (BRAINROT COLONY)
> **Living Master Game Reference Document**

---

## 📌 Project Meta
* **Project Name**: Brainrot Castle / Brainrot Colony
* **Platform**: Roblox (PC, Mobile, Console)
* **Current Working Version**: `v0.0.0.21`
* **Genre**: Real-Time Strategy (RTS) / Voxel Castle Builder / Tower Defense / PvP Siege
* **Monetization Philosophy**: **100% Fair Play / 0% P2W**. Strictly cosmetic drip (minion skins, wall themes, victory dances, audio packs) + Non-competitive Quality of Life (saved blueprints, inventory auto-stash, HUD themes).

---

## 📐 Voxel Grid & Architectural Scale
* **Base Grid Unit**: `GRID_SIZE = 2 studs` (`2 x 2 x 2` studs per 1x1 block).
* **Relative NPC Scale**:
  - Standard Roblox Avatar Height: `~5.0 - 5.5 studs`.
  - `1x1 Block` (2 studs height) = **~1/3 of an NPC height**.
  - `3 Stacked Blocks` (6 studs height) = **~1 full NPC height**.
* Allows precision castle architecture: arrow slits, battlements, stairs, pillars, half-walls, and micro-minion brick placement.

---

## 🎨 Cute Brainrot Visual Engine ("Soft Cubes & Derpy Decals")
* **Pillowy Soft Meshes**: Blocks use inset rounded bevel meshes (`SpecialMesh`) for a soft, cute, tactile toy brick feel instead of harsh sharp edges.
* **Pastel Color Palette**:
  - 🪵 **Ohio Wood**: Soft Caramel Honey (`#DCA064`)
  - 🪨 **Gyatt Granite**: Soft Mint / Periwinkle Stone (`#B4CDD7`)
  - 🧱 **Skibidi Clay**: Soft Strawberry Pink Brick (`#EB8282`)
  - 🏗️ **Sigma Concrete**: Soft Lavender Grey (`#C8C3D2`)
  - ⚡ **Rizzite Shield**: Soft Pastel Cyan Glow (`#78F0FF`)
* **Derpy Face Decals**: Placed blocks randomly spawn cute derpy blush faces (*OwO*, *UwU*, *Happy Smile*, *Derpy Blush*) on front surfaces for playful "cute brainrot" vibes!

---

## ⛏️ Resources & Materials System
| Resource Name | Node Source | Primary Uses | Material Aesthetic |
| :--- | :--- | :--- | :--- |
| **Ohio Wood** | Ohio Trees | Wood Blocks, Stairs, Archers | Warm natural wood |
| **Gyatt Granite** | Granite Boulders | Stone Walls, Beams, Fortresses | Heavy grey cobblestone |
| **Skibidi Clay** | Clay Deposits | Clay Bricks, Half-Walls | Red brick masonry |
| **Sigma Concrete** | Raw Lime & Gravel | Heavy Slabs, Pillars, Foundation | Smooth reinforced grey concrete |
| **Rizzite Alloy** | Rizzite Crystals | Shield Walls, Siege Weapons | Glowing neon cyan energy |

* 📜 **Master Recipe Reference File**: See [Crafting_Recipes.md](file:///c:/Users/gamin/Downloads/Roblox/Game%20Essentials/Crafting_Recipes.md) for full recipe table formatted as `ResourceName_x(Amount)`.
* 🛠️ **In-Game Hover Tooltips**: Hovering over any block/building card in the UI menu displays a popup tab showing exact crafting requirements (`resourcename_x(amount)`).

---

## 🧱 Basic Building Blocks Library (v0.0.0.21)

| Block Name | Shape Class | Dimensions (Studs) | Material | Primary Cost |
| :--- | :--- | :--- | :--- | :--- |
| **Wood 1x1 Cube** | `Part` | `2 x 2 x 2` | Wood | 2 Ohio Wood |
| **Wood 1x2 Beam** | `Part` | `2 x 4 x 2` | Wood | 4 Ohio Wood |
| **Wood Stairs** | `WedgePart` | `2 x 2 x 2` | Wood | 3 Ohio Wood |
| **Wood Half-Wall** | `Part` | `2 x 1 x 2` | Wood | 1 Ohio Wood |
| **Stone 1x1 Cube** | `Part` | `2 x 2 x 2` | Cobblestone | 3 Gyatt Granite |
| **Stone 1x2 Beam** | `Part` | `2 x 4 x 2` | Cobblestone | 5 Gyatt Granite |
| **Stone 2x2 Slab** | `Part` | `4 x 2 x 4` | Granite | 8 Gyatt Granite |
| **Stone Stairs** | `WedgePart` | `2 x 2 x 2` | Cobblestone | 4 Gyatt Granite |
| **Clay Brick 1x1** | `Part` | `2 x 2 x 2` | Brick | 3 Skibidi Clay |
| **Clay Wall 1x2** | `Part` | `2 x 4 x 2` | Brick | 5 Skibidi Clay |
| **Concrete Pillar** | `Part` | `2 x 4 x 2` | Concrete | 4 Sigma Concrete |
| **Concrete Slab** | `Part` | `4 x 2 x 4` | Concrete | 6 Sigma Concrete |
| **Rizzite Shield 1x1**| `Part` | `2 x 2 x 2` | Neon | 4 Granite + 2 Rizzite |

---

## 🤖 Minion Classes & Cosmetic Skins

### Minion Unit Classes
1. **Mewing Mason**: Silent, laser-focused builder & miner (25% faster block placement).
2. **Ohio Lumberjack**: Unhinged woodcutter (clears 3 trees at once).
3. **Gyatt Guard**: Heavy melee defender with shield knockback.
4. **Fanum Archer**: Ranged tower archer with snack barrage.
5. **Skibidi Bomber**: Explosive siege demolition unit.

### Cosmetic Skins (0% P2W)
* **Gigachad Classic** (Legendary)
* **Rizz God Kai** (Mythic)
* **Purple Grimace** (Epic)
* **Pure Gold Sigma** (Exotic)

---

## 🎮 Game Modes (Single-Player & Multiplayer)
* **Mode A: Survival ("Longest Run / Gyatt Defense")**: Defend core crystal against endless night waves.
* **Mode B: PvP Siege ("Siege of the Sigmas")**: 1v1 / 2v2 / FFA castle build phase followed by siege destruction.
