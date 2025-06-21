# npc-sell

🛒 **NPC Sell Script for FiveM (QBCore)**  
Simple and efficient NPC selling script for FiveM servers using QBCore framework. Players can sell predefined items to nearby NPCs with progress bars and animations. The script prevents selling to the same NPC multiple times during cooldown and alerts police jobs on sales.

---

## 📹 Demo
https://streamable.com/ju84wa

---

## 📦 Features

- 🚶‍♂️ Sell predefined items to nearby NPCs within a configurable distance.
- ⏳ Progress bar during selling with animations (player and NPC).
- 🤚 NPC performs an emote after sale and then walks away.
- 🛑 Prevent selling to the same NPC repeatedly within a cooldown period.
- 🚓 Sends alert to police jobs on every sale.
- ☠️ Cannot sell to dead NPCs.
- ⚙️ Easy to configure item list, prices, distances, and cooldowns.

---

## 🔧 Requirements

- [`qb-core`](https://github.com/qbcore-framework/qb-core) — QBCore framework.
- Compatible with your inventory system (tested with QBCore's default inventory).
- Ensure you have configured police jobs correctly for alerts.

---

## 📁 Installation

1. Download or clone this repository:

```bash
git clone https://github.com/Takennncs/takenncs-npcsell.git
