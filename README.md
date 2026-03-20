[README.md](https://github.com/user-attachments/files/26131275/README.md)
# NiceDamage 4.0

A lightweight World of Warcraft addon (WotLK 3.3.0) that lets you pick custom fonts for your floating combat text — separately for **damage** and **heals/auras**.

No framework required. Standalone, zero dependencies.

---

## Features

- 🎨 **Dual font selector** — choose one font for enemy damage, another for heals, auras and self text
- 📜 **25+ bundled fonts** — from Default WoW to Diablo, Galaxy, Zombie, and more
- 🖱️ **Scrollable UI** — mousewheel support, no template dependency
- 💾 **Persistent settings** — choices are saved between sessions via SavedVariables
- ⚡ **Instant apply** — heal/aura font updates immediately; damage font applies on next login

---

## Installation

1. Download and extract the folder.
2. Rename the folder to `NiceDamage4.0` if it isn't already.
3. Place it inside your addons directory:
   ```
   World of Warcraft/Interface/AddOns/NiceDamage4.0/
   ```
4. Make sure your custom fonts (`.ttf` files) are inside a `fonts/` subfolder.
5. Enable the addon in the character selection screen and log in.

---

## Usage

| Command | Action |
|---|---|
| `/nd` | Open / close the font selector |
| `/nicedamage` | Same as above |
| `/nd reset` | Reset both fonts to defaults |

In the selector window, click **D** to assign a font to enemy damage, and **H** to assign it to heals, auras and self text.

> **Note:** The damage font (`D`) requires a full WoW restart to take effect. The heal font (`H`) applies instantly.

---

## Compatibility

- **WoW version:** WotLK 3.3.0 (Interface 30300)

---

## Author

**Nidhaus**
