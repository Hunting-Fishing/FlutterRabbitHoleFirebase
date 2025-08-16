# Conspiracy Mobile Game Blueprint

## Overview
This project is a mobile game with a conspiracy theme. The core gameplay loop involves collecting **Conspiracy Fragments** to unlock and learn about various conspiracies.  
The initial release will feature **two distinct game modes**:  

1. **Trading Card Game (TCG)** — A lane-based conspiracy-themed card battler.  
2. **Simulation Game** — Inspired by Plague Inc., where you spread or combat conspiracies.  

The application will have a **dashboard home page** to navigate between these games and showcase planned future game modes.

---

## Current State

- **Dashboard Home Page**: Displays available and upcoming game modes.
- **TCG Dashboard**: Central hub for the Trading Card Game with navigation to:
  - Inventory
  - Battle
  - Unlock More
- **Campaign Mode (Skill Tree)**: A mode where users unlock conspiracies by progressing through a selectable skill tree.

- **Basic Card Game Screen**: A screen for playing the card game, though currently with several errors and incomplete functionality.
- **Card Widget**: A basic widget to display card information, with some issues in loading network images.
- **Deck Builder Screen**: Basic UI and logic for building decks, but with several implementation issues.
- **Game Logic Classes**: Initial classes for managing game state (`CardGameStateManager`) and decks (`DeckManager`), which still have errors.

## Planned Features (Expanded)

### **Conspiracy Card Game (TCG)**

A fast, lane-based card battler themed around misinformation, secret factions, and shadow operations.  
Players collect **Conspiracy Fragments** to unlock cards, build decks, and climb a progression path via the Campaign.

---

### Core Loop
1. **Earn Fragments** → open packs, craft cards, or unlock nodes in Campaign.  
2. **Build Decks** → synergize by faction/keywords (*Gov, Media, MegaCorp, Cult, Underground*).  
3. **Battle** → play cards, attack in lanes, trigger abilities, and manage resources.  
4. **Progress** → gain XP/fragments, unlock Campaign nodes, and cosmetic rewards.

---

### Rules & Systems

**Turn Structure** (already in code):
- **Start**: Untap creatures, remove summoning sickness, draw a card.
- **Main 1**: Play creatures/spells, spend resources, activate abilities.
- **Combat**:  
  - Declare Attackers  
  - (Future) Declare Blockers  
  - Resolve Combat
- **Main 2**: Continue playing cards.
- **End**: Cleanup phase (future: end-step triggers).

**Zones**:
- **Hand**: Cards you can play.
- **Play Area**: `List<CreatureInPlay>` (lane-based).
- **Graveyard**: Defeated creatures and used spells.
- **Deck**: Per-player deck.

**Resources**:
- Start at **20**, spend to play cards, gain +1 at Start phase.

**Win Condition**:
- Opponent’s `score <= 0` (score = health).

**Card Types**:
- **creature**: Persistent board units with `attack`, `defense`, `hasSummoningSickness`, `isTapped`.
- **spell**: One-shot effects; go to graveyard after resolution.

**Keywords & Status Effects**:
- **Summoning Sickness**
- **Tap/Untap**
- **Cloaked** *(future)*
- **Expose** *(future)*
- **Disinform** *(future)*
- **Shield** *(future)*
- **Overreach** *(future)*

**Ability Set (current enum)**:
- `attackBoost`
- `defenseBoost`
- `drawCards`
- `discardOpponentCard`
- `removeTargetCreatureFromPlay`
- `gainResources`
- `heal`

*Future abilities*: `dealDamageX`, `shieldX`, `silence`, `revive`, `clone`, `globalBuff`, `stealResource`.

---

### Combat Model
- Lane-based by index; attacker at lane *i* fights defender at lane *i*, else hits player directly.
- Simultaneous damage; creatures with `defense <= 0` go to graveyard.
- Attacking taps creatures; summoning sickness prevents attacking on the first turn a creature is played.

---

### Deckbuilding (Basic UI, State Management, Add/Remove, and Validation Implemented)
- Deck size: 20–30 cards.
- Max 3 copies of non-unique cards; 1 copy of unique cards.
- Factions for synergy:  
- Basic UI for deck selection and management is implemented using a dedicated screen (`DeckBuilderScreen`).
- State management for the deck and inventory is handled using the `provider` package and a `DeckManager`.
- Core logic for adding and removing cards, including validation for deck size (20-30) and card copy limits (3 non-unique, 1 unique), is implemented.
- The `CardWidget` is integrated to display card artwork and details in the deckbuilder UI.
- Sample cards have been added to the inventory for initial testing.
- **Future:** Implement saving and loading of decks, and further refine the UI/UX.
  - **Gov**: Control & removal.  
  - **Media**: Draw/discard.  
  - **MegaCorp**: Resource ramp.  
  - **Cult**: Healing & swarm.  
  - **Underground**: Cloaking & evasion.

---

### Data & Content

**CardDefinition Suggested Fields**:
```ts
{
  id: string,
  name: string,
  typeId: 'creature' | 'spell',
  cost: number,
  attack?: number,
  defense?: number,
  description: string,
  abilities: CardAbilityType[],
  artworkUrl?: string,
  rarity?: 'common' | 'rare' | 'epic' | 'legendary',
  faction?: 'gov' | 'media' | 'megacorp' | 'cult' | 'underground',
  tags?: string[]
}
