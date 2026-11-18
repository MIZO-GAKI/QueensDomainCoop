# Test report

What was tested, how, and what was not. "Live" means real copies of the game (vanilla English baseline) running on
one Windows 11 PC, driven by test bots through the mod's developer bridge, talking over the network layer on
loopback. Copies A, B and C run game version 1.01.03 (exe 6AE3DAC2); copy D runs 1.01.05 (exe 6AEBF261, the Steam
update of 2026-11-07), so every test that includes D, and the mixed-build runs below, are cross-version tests. Mock
tests use a simulated network or a simulated Steam and are labelled as such: they check the mod's own code, not the
game and not Steam. Copies E to H ran game version 1.01.06a (exe 6AF55DEF, the Steam update
of 2026-11-12) for the tests of 0.15.1 and 0.16.0, and run 1.01.07 (the same exe, the update of 2026-11-14) since
2026-11-15: 0.16.0 was run on that too, and 0.17.0 to 0.20.0 were tested on it alone.

The owner's real saves were hashed before testing; every live test checks that they are unchanged
(`owner saves untouched`). All copies ran from separate test folders; the real installation was never modified.

## 0.20.2: nothing else of a teammate's hit on your screen

What a read-only audit of the whole mod (three readers and a critic) found still showing a teammate's hit to the
others, and what an independent review of 0.20.x (three reviewers, every finding checked by a skeptic: 7 confirmed,
4 refuted) found wrong - all measured or confirmed, then changed:

- The party HUD shook a teammate's row and flashed their name when their health fell (partyhud.cpp): now only your
  own row does, for your own hits.
- An effect an enemy put on a teammate's body (measured with the native-call tracer: the body's fire made a
  `MagicFireStatusOverlay_C` with its widget on the host's screen and a burning loop; its poison played a flat
  "poisoned" sound) showed for a moment in that game: the overlay's widget is now taken off as it is put on, the
  loops are stopped as they start, the flat sound is played for no world.
- A reviver who was hit dropped out of the kneel for one state message (the revive's target was let go for a frame):
  the revive starts over as before, the target is kept.
- The host caught in a blow aimed at the teammate next to it got the whole hit effect before its health was given
  back: the blow is now known for a bystander's in the host's own TryApplyDamage (the enemy's target, within 160
  units) - shake, flash, sounds and the HUD's dip held, the health given back.
- The list of teammates' bodies kept the address of a body the engine destroyed with its level (a wipe's reload, the
  game's return to the title) - a later object there would have been taken for a body: each body is now checked by
  its weak reference at every lookup.
- A player's hit was recognised for 0.4 s or six of the loader's pumps - the loader pumps several times while the
  game stands still - so a stall right after a host's blow could still let it through as an enemy's: a mark now
  lasts exactly until the mod's next look at the bodies (a main-loop frame); what the hit put on the body is taken
  at the first look after it (where 0.20.0 dropped every effect for 0.6 s - an enemy's too).
- The bodies' own events run in a BodyScope only when they are the game's blueprint events, not the mod's own calls
  on a body (its move each frame).

| Test (copies E to H, game 1.01.07, the packaged build) | Result |
|---|---|
| `test_hit_effect` (new check) | PASS: fire and poison put on the joiner's body in the host's game - the overlay taken off as it came (1), the loops stopped (2), the flat sound held (1); the joiner's own game took both |
| `test_status` (new check) | PASS: the enemies' fire and poison still handed on, each once; the host's view of B's hits held each time |
| A lab: B draws a fighter, A stands next to B | the fighter's blows aimed at B caught A three times: A's camera shook 0 times, A lost no health, its HUD did not dip (3 held), the health given back by the enemy's own event each time; B took its 8 hits |
| `test_friendly`, `test_team`, `test_anim`, `test_travel`, `test_two_players`, `test_party` (three games) | PASS |

## 0.20.1: no knight flinch for a hit either

Asked for by the owner on 2026-11-18, after 0.20.0 ("Remove it too"): a teammate's knight flinched in the others'
games when its player was hit. A hit no longer sends anything (PLAYER_ACTION kind 2 is gone) and a body plays nothing
for one; the message protocol is 13, so 0.20.0 and 0.19.0 are refused (0.20.0 kept 12 and joined 0.19.0 games - the
README had said otherwise).

| Test (copies E to H, game 1.01.07, the packaged build) | Result |
|---|---|
| `test_anim` | PASS: "a hit on B shows nothing on B's knight in A's game: B sends nothing of it, A plays nothing" (B 90 -> 85, played 0, sent 0) and all its other checks |
| `test_hit_effect` | PASS: a fighter struck the joiner twice - nothing played on its knight in the host's game, nothing sent, the host's camera never shook |
| `test_knights` (four games), `test_weapons`, `test_versions` | PASS |

A read-only audit of the mod found what else still shows a teammate's hit to the others - the party HUD's row of the
hit teammate shakes and its name flashes, a status effect an enemy puts on a body shows its overlay and sound in that
game for a moment, a reviver who is hit drops out of the kneel for a moment - and an independent review found that
the list of teammates' bodies keeps the address of a body that went with its level. Those are for 0.20.2. The whole
run was not repeated for 0.20.1 (0.20.0's run, on the same code but for the flinch, is below).

## 0.20.0: no friendly fire; a hit shows only to the player who was hit

Asked for by the owner on 2026-11-17: "The host can damage the players with L2 attack. I don't want any sort of
friendly fire. If any player gets hit the hit effect play to all players. I want it only for the player who got hit."

**What was found** (two copies through the developer bridge, the game's own data, and the owner's own log, read only):

- **The L2 hits.** The owner's log as a joined player that day has three hits of 10.2, 12.4 and 9.5, each told as
  "most likely" an enemy's, in the first two minutes of the session - before they had touched an enemy. The enemies
  there hit for 10, 15, 20 or 21; a player's weapon for uneven amounts (the host's axe L2: 10 to 11). So the host's
  game had put a loss of the joiner's body down to the nearest enemy: the host's blow had not landed inside the
  swing's hitbox notify that the mod watched for the player's own blows (0.14.0), and a loss outside every watched
  moment, with an enemy near, was told to the body's player as that enemy's. In the tests the L2 and swings of ten
  weapons were tried (axe, spear, jar hammer, crushing lance, great spear, halberd, duck hammer, bird flail, the
  electric gun and the energy-ball hammer; tapped and held; at 2, 4.5 and 8 to 9 m): every blow of them that reached
  the body (eight of the ten weapons' did, at one distance or more) landed inside that notify, so the leak was
  reproduced not by an attack but by its result: the host's own character hitting the joiner's body outside any
  swing, an enemy near - told to the joiner as "10.0 from <that enemy> (most likely)", as in the owner's log.
- **The hit effect.** Screenshots of the host's screen showed the same red at the screen's edges, with the camera
  shaken, whether the host itself or the joiner's body was hit (the edges' redness against the middle: -8 at rest,
  +8 to +10 with either). The game's damage function of a player character (`FS_PlayerChar_C.TryApplyDamage`, 3.5 KB
  of script) names what it does (read from the game: the objects its code refers to): the engine's
  `PlayWorldCameraShake` with `DamageCamShake` (every camera of that game near the hit), `PlaySound2D` with
  `PlayerTakeDamage` (flat, at full volume), the rumble (the game's `Play Player Rumble`: a force feedback
  component on the local player's character), and the `HitFlash` timeline (the red). A teammate's body is one of the
  game's player characters, so in each game a hit on it shook that game's camera, reddened its screen and played
  the hurt sound there. The rumble was the exception: the game gives one only to the character it controls (with
  the test pad in use: the host's own hit made one, a hit on the joiner's body none).
- **How to see it.** The game's blueprints call one another without passing ProcessEvent, where the mod sees
  events: a swapped native pointer of the blueprint function `TryApplyDamage` saw only ProcessEvent's calls, never
  an enemy's blow. A blueprint's call of a NATIVE function always passes its pointer, with the calling blueprint's
  frames, and those name the hit character and its `TryApplyDamage` with what applied the hit (`natives.cpp`).

**What 0.20.0 does** is in the README; how, in `friendly.cpp` ("Hits on a teammate's body") and `natives.cpp`.

### `test_hit_effect` (new: two games)

| Step | Result on the final build |
|---|---|
| The joiner's body is hit in the host's game (the game's own damage, an enemy as the applier) | the host's camera: no shake (the game's shake for it held back: 1); its screen's edges -7.9 / -35.3 before, -7.5 / -32.2 after (no red; 31 steps of the body's flash not run); the flat hurt sound not played |
| The host itself is hit | its camera shakes, its edges +16.4 / -27.5 (red; its flash at 0.96), its hurt sound plays: nothing held back |
| A fighter (AI on) strikes the joiner twice | the joiner took both, its own camera shook twice and its flash ran; the host's camera never shook (2 held back) |

### `test_friendly` (changed: no switch; the L2; the owner's case)

| Step | Result on the final build |
|---|---|
| The host swings at the joiner three times; the joiner at the host three times | nobody loses anything or is told anything; each game put back the three blows on the body |
| The host's own character hits the joiner's body outside any swing, an enemy near, with the 0.19.0 rule switched back for that moment | told to the joiner: "10.0 from <the enemy> (most likely)", 88 -> 78 - the owner's case |
| ... with the 0.20.0 rule | nothing lost, nothing told; the hit seen as the host's ("FS_Full_PlayerChar_C (us)") and dropped |
| The host and the joiner ask for friendly fire | it stays off in both games and in the campaign |
| The host's L2 (the real left trigger, tapped and held) and a swing at the joiner; the joiner's L2 and a swing at the host | nobody loses anything or is told anything |
| Unchanged | an enemy's blow is told with its name; a hazard in both games is not taken twice; an enemy's shot is taken, "most likely"; poison on the body is handed on |

### Other measurements (labs)

- The ten weapons above, L2 at three distances, with the rule on and off: every blow that reached the body was seen
  as the host's ("FS_Full_PlayerChar_C (us)") and was not told; with the rule off the swing's hitbox put them back
  as before. The great spear's and the bird flail's L2 never reached the body.
- The Bird Flail's L2 seemed to hurt the joiner once (-35): with every enemy held, its L2 never reached the joiner;
  the hits had been a fighter's that was not held (told with its name, as they should be).
- The rumble: the hook that stops a rumble made by a body's code stays in place, though the game makes none for a
  body (above).

### The whole run on the final build

2026-11-17, game 1.01.07 (copies E to H), the build that is packaged (`QDCoop.dll`, SHA-256 beginning `31a9c553`):
**62 runs, 59 passed; 926 checks passed, 3 failed.** `test_perf`: host 0.49 ms of mod work per frame on average
(worst frame 2.1 ms), joined game 0.77 ms (worst 2.0 ms), at 60 frames per second - as 0.19.0.

The three that failed, each run again alone twice on the same build: all six runs passed.
- `test_combat`, one check of its own setting up ("the host stands back from the enemy, on the floor of its room":
  it stood 26 m off); it passed in the run before.
- `test_party` with three players, one check ("the player who rested is free to play once they have left the
  menu": the stick moved them 0 units). The resting player was being hit for 5 every half second, before and after
  the rest: in the host's game the bodies of both joined players stood in the level's hazard by the boss gate, and
  the one with an enemy near was told it as "most likely" that enemy's - the rule of 0.15.0 for what is lost outside
  every watched moment, which this change does not touch; the hits kept the character in its hit reaction. It
  passed in the run before.
- `test_dialogue`, the harness timed out waiting for all three players on a conversation's second line (the
  dialogue's hook looks only at the local player and its dialogue: nothing of this change reaches it).

A first run, on the build before the last fix, had found what that fix is for: 62 runs, 59 passed. `test_status`
failed because an enemy's fire put on a teammate's body ticks with the body itself as the applier, and that was
taken for a player's blow - the fire was not handed on to its player (now what a character does to itself is no
player's blow; `test_status` passed alone on the final build). `test_hit_effect` failed one check by its screenshot
coming late in the host's own flash (+7.7 against a threshold of 8; the check now reads the flash itself too, at 5).
`test_split_kills` failed two checks of a third player joining after the kills (one of the party's kills alive in
its game for a second; blocks not lifted when the host's enemy came back): it passed alone on the final build and
in the second run.

The installer test on the 0.20.0 package's files: all 19 checks passed. The unit suites: all OK.

### What was not tested

As before: real Steam between two accounts, a real controller (its vibration: the test pad has no motor), people
over the internet, large displays. For this change: the ultra (the bridge could not fill its charge: `UltraCharge`
set to 100 read back as 1, not ready), the wind dash, thrown weapons other than daggers, and a player's weapon that
burns or poisons (by the code: what a player's hit put on a body in the last 0.6 s is not handed on); the host's
weapon in the owner's session (not known); a hit whose answer plays neither the camera shake nor the flat sound
(none was met: then only the swing's hitbox and a dagger nearby tell a player's blow from an enemy's, as in 0.19.0).

## 0.19.0: a friend who joins later catches up with the host

Asked for by the owner on 2026-11-16: a friend who joined in the middle of the game had none of the host's
weapons or items, nor the host's level, weapon levels or coins - "if i get something and someone join me mid game
he get it too automatically. Also the same for character level and weapons level and coins".

**Where the game keeps them** (one copy, read through the developer bridge): the save in play
(`GameInstance.BaseActiveSave`, `FS_SaveSlot_C`) holds every item in `InventoryContents` - the coins too (the item
`Coin`, which the game files with its placeholders, category 8) and the weapon in hand (equipping the axe left it
there); the character's experience in `XPAmount` (the level follows from it: `CalculateLevel`); each weapon's
experience in `WeaponXP` and its level in `WeaponLevels`. Measured: the character's `AddXP` added exactly what was
asked (1000: level 2; 5000 more: level 8) and `GrantXPDirectlyToWeapon` too (500: weapon level 5).

**What 0.19.0 does** is in the README; how, in `catchup.cpp` and SYNC_AUDIT.

**Read by two reviewers** (read-only, one through the flows line by line, one looking for a session in which the
change makes things worse) after the first version had passed its own test. Put right from their reading before the
final build:

- a friend who joined from inside another co-op save would have had THAT campaign's character topped up and saved
  (now only the character of the campaign being joined, by the character book's slot);
- a returning friend's due was the host's net change: what the host found was hidden by what it spent, and what it
  bought or was handed in a trade was given free (now: the party's finds, counted as they are granted);
- an important find owed by the reward ledger was counted by the catch-up as well, so a used-up one came back (now
  what the ledger has just handed over is taken off);
- what the friend's game gained while the catch-up waited for a calm moment was swallowed by it (now reckoned the
  moment the word arrives);
- the record followed the host while a friend's link was dead (now a timed-out or reconnected friend is owed the
  last seconds' finds again), was written to disk every 15 seconds for nothing (now as things happen), and a friend
  starting the campaign anew with a new character was held to the old character's record (now told and let go);
- dozens of kinds of items were given in one frame (now six a frame), and the screen's line of words, the only
  place the new level is shown, was pushed off by the item tiles (now after them, with four tiles at most); the
  level is shown as the player counts it.

### `test_catchup` (new: two games, through the title screen and a join code as players do)

| Step | Result on the final build |
|---|---|
| The host, alone in a new campaign, gets an axe and a spear, three daggers, six herbs, 750 coins, 6000 experience (level 8) and weapon experience (axe 500, spear 300) | all there |
| A friend joins mid-game with a new character | within seconds: every item at least as many as the host, exactly 750 coins, experience 6000 and level 8, axe 500 and spear 300; the host's own inventory unchanged; "Caught up with ..." on the friend's screen |
| The friend spends 400 coins, uses four herbs and a dagger, and leaves; the host, alone, finds a hammer, 200 coins and three daggers, spends 150 coins, is handed a throwing axe the way a trade hands it, uses two herbs, gains 1500 experience and 200 for the axe | the host's record counts the finds and where the friend stood in them |
| The friend joins again (the same character, from its save) | the hammer once (by the reward ledger), exactly 200 coins (350 -> 550: not the 400 it spent, and the host's spending does not count), the three daggers once (2 -> 5), no throwing axe, no herbs; the host's experience and the axe's; nothing else - what the first catch-up gave was in its save |

### The whole run on the final build

2026-11-16, game 1.01.07 (copies E to H), the build that is packaged (`QDCoop.dll`, SHA-256 beginning `7f6f2847`):
**61 runs, 59 passed; 931 checks passed, 2 failed.** `test_perf`: host 0.47 ms of mod work per frame on average
(worst frame 2.1 ms), joined game 0.72 ms (worst 1.9 ms), at 60 frames per second. The run took 190 minutes, 83 of
them asleep: the PC went to sleep at 18:40 during `test_lobby4` and woke at 20:03 (Windows' own record); that test
then went on and passed all its checks.

The two that failed, each run again alone twice on the same build: all four runs passed.
- `test_friendly`, one check ("standing in something that hurts, in both games: the joiner loses its own game's 5,
  not the host's 5 on top" - the joiner lost 15): it has failed so before, in one run of 1.01.06a and one other
  earlier run, and passed in every other.
- `test_sight`, one check ("the mod's look agrees with the game's own": no look within range - the host stood far
  from the enemy): the same failure as in the runs of 0.18.0, where it was looked at and left open.

Before it, on this change's builds: `test_catchup` passed on every build after the coins were put in (five runs);
`test_campaigns` four runs, `test_trade` and `test_loot_rules` two each on the final build, all passed (the check of
`test_loot_rules` that said a player new to the campaign is given nothing found before it came was turned round to
the owner's new rule: such a player has what the host has, by the catch-up). One build of this change had the
re-owing after a forced close: `test_loot_rules` showed the finder of a Jar Hammer with two; that rule was taken out.

### What was not tested

As before: real Steam between two accounts, a real controller, people over the internet, large displays. For this
change: three or four players joining at different times (by the code each is caught up on their own); a friend who
joins from inside another co-op save (the guard is in the code: nothing is given; not provoked); a link that times
out or reconnects mid-session (the last 25 seconds of finds are owed again: by rule); a host deep in the game with
dozens of kinds of items (six a frame: not measured); a friend whose own bonus multiplies experience (the first
addition reckons with the multiplier the game reports: not met); weapons at their highest level, and evolved
weapons (an evolved weapon is an item of its own and is copied as one; installed upgrades are not copied).

## 0.18.0: kills of a split party

Asked for by the owner on 2026-11-15, after the report on 0.17.0 named it as a limit that was known and not
changed.

**The defect, measured on 0.17.0.** Enemies are shared where the host's game has them, and a death was told only
to games that had an actor of that enemy. The host killed an enemy (real damage, its own player) while the joined
player was 187 m away: when that player came within 70 m of the place, their own game made that enemy again, alive
and on its own, and it was still there, for that player only, when they walked up to it. The other way round, with
the new test on a build whose new messages were not yet delivered: the host's game made the enemy the joined
player had killed alone again 1.6 s after the host stood 70 m from the place, and the joined game had it alive
again with it. And a player who joined after both kills had both enemies alive beside the host.

**How the game itself records a kill** (three runs with one game, alone, read through the developer bridge; the
spawner class from a type dump):

- An enemy's death calls its spawner's `ManagedEnemyDied`: the kill count goes up, and from that moment - read
  right after the killing blow - the spawner's `IsNotBlockedByRespawnTime` is false and `GetNextSpawnTime` is the
  world's clock plus `GetRespawnTime`, 1200 seconds. The game does not make that enemy again while that stands (not
  at 70 m, not after 200 s, not when its `Try Spawning Enemy` is called, with either setting of ResetSpawn).
- A rest (every spawner gets `WorldStateChanged`) takes every block away and makes the enemies again.
- `StartRespawnTimer(T)` on a spawner whose enemy has no actor blocks it for T seconds, counts no kill, and a rest
  undoes it. `Force Respawn` lifts a block and makes the enemy at once.
- A death without rewards (the test tools' Kill) writes no block: that enemy is back within seconds.

**What 0.18.0 does.** The record goes round. The game in which an enemy dies as a kill - its own spawner says
"blocked" - tells for how long: the host to everyone, a joined game to the host, which blocks its own spawner (or,
if it has that enemy alive after all, kills it as it does for a joined player's kill of a shared enemy) and tells
the others at once. Every other game blocks its own spawner of that enemy for as long, with the spawner's own
`StartRespawnTimer`, once its level has settled, and looks again every five seconds while the record stands. A
player who comes into the host's level is given the list of what the host's spawners count (asked of every
spawner, sixty a frame). A game that has such an enemy alive on its own ends it: by the game's own death when the
kill has just happened, without a word when it was killed before that game came. A rest of a game clears its
record as the game clears its spawners; a new character - a level entered, or loaded again after a wipe - reads
everything anew. When the host has an enemy alive that a game still counts as killed, that game's spawner gives it
back (`Force Respawn`). Protocol 11.

### `test_split_kills` (new: three games, the third joins later)

| Case | Result on this build |
|---|---|
| The host kills X, the joined player B 160 m away with no actor of it | the host's spawner blocked for 1199 s, B's own for 1198 s within seconds; X not alive in B's game at 70 m from its place, not when B's spawner is asked for it outright, not next to it |
| B kills Y alone, the host 160 m away with no actor of it | B's spawner 1199 s, the host's 1198 s (B told the host once); Y not alive in the host's game at 70 m, not when asked, not at the checkpoint - nor in B's |
| C joins after both kills | told of two; its spawners blocked for the time that was left (X: 1012 s, as the host's); the two enemies its game had made at its start were taken away; neither alive beside the host nor made when asked |
| An enemy nobody killed | alive in all three games, the host's to drive |
| A party rest | X and Y alive again in all three games, no spawner counts them any more, no enemy twice in a joined game |
| X killed with everyone there, then the host's spawner made to give it back | it dies in every game and every spawner counts it; then B and C, who still counted it, have it again, the host's to drive (their own spawners gave it back) |

What the first runs of this test found, and what was done:

- The two new messages were sent and never read: the mod hands a message to a module by a list of message types,
  and the list had not been extended. (The test's first check failed on it: nothing heard.)
- The list for a newcomer reached the newcomer 3.4 s before its character existed; written into the spawners at
  once it did not hold - the game's own start of a level makes every enemy and reads its spawners from the save -
  and both enemies stood there. Now the record is kept through the load and written only into a level that has
  settled.
- Two spawners can carry one save GUID (a place in two versions of a part of the map, of which the game shows one):
  the mod's list of spawners now keeps the one whose part is shown.

**Read by two reviewers** (read-only; one through the flows line by line, one looking for a session in which the
change makes things worse) after the first version. Put right from their reading: the record was never cleared on a
level change or a wipe's reload (only when a session began or ended); the host's list after a level change came
from the level before; a player who left cleanly and came back was not given the list again; a far kill whose
spawner the host did not have at hand was not passed on; word of a kill that came in during a game's own rest took
away an enemy the rest had just brought back; an enemy a game had never had an actor of was given back as a copy,
not by its own spawner. The passes after that reading were not read by a reviewer again.

### The whole run on this build - NOT clean

2026-11-16, game 1.01.07 (copies E to H), the build in the package (`QDCoop.dll`, SHA-256 beginning `28830dcf`):
**60 runs, 58 passed; 918 checks passed, 2 failed**, 108 minutes. `test_perf`: host 0.53 ms of mod work per frame
on average (worst frame 2.4 ms), joined game 0.79 ms (worst 1.9 ms), at 60 frames per second.

The two that failed, and what is known:

- `test_enemy_count`, one check: "the dead one does not come back while the first lives (none made since)". The
  host made its fifteenth extra enemy after the test's kill step instead of before it (14, then 15). Run again
  alone twice: it failed the same way once and passed once (15 from the start). The number of extra enemies is the
  same in every run.
- `test_sight`, one check: the joined player stood 40 units off a line that allows 30. Run again alone twice: one
  run passed; the other failed another check, with the host standing 26 m from the enemy it was to watch.

Both tests passed in every run kept from before 0.18.0 (eleven of eleven). What the failures have in common: the
host's game seems to have its enemies at slightly other times and places than before. Suspected and NOT verified:
the mod's new questions to every spawner when a player comes into the level (`IsNotBlockedByRespawnTime`,
`GetNextSpawnTime`), or the look at the spawners that now also runs in the host's game every five seconds, disturb
the game's own making of enemies. **Until that is settled this build is a preview.** 0.17.0 is the last version
whose full run was clean (59 of 59). The owner asked for this package as it is.

The unit suites were not run again for this build.

### What was not tested

As before: real Steam between two accounts, a real controller, people over the internet, large displays, bosses
other than the Sword Shrine's guardian. For this change: more than one level (the list for a newcomer after the
party has changed level, by rule only); a wipe's reload with kills made since the last rest (by rule only); four
games at once with two joined players together far from the host (the death of an enemy both have is carried out
in the second game by the game's own death: by rule only); the twenty minutes running out (the lab stopped at 200
seconds); a player whom a party rest did not rest. Not covered by the change at all: a boss, a follower, an enemy a
script calls up, the extra enemies of a larger party.

## 0.17.0: the party rest that took the HUD and the controls away

The owner played 0.16.0 on 2026-11-15 (two players, the owner joined, two new campaigns, game 1.01.07) and wrote:
rest must always regroup all players and bring the enemies back for all, whoever rests, with no option; the same
for Save; and "when my friend rest i got something like freeze or stuck can't move or do anything and no hud".

**What their log showed** (read only; names never leave the reading script). Four party messages in the first
session, all started by the owner's own Rest, Save, Rest, Save at one checkpoint within 73 seconds, each accepted
by the host - so each time the HOST was the one brought and rested. No follower's sequence in the owner's own game
at all. Between the sessions the owner switched their own "regroup on rest" off.

**What did not reproduce it** (two copies, each watched for 40 s: controls, HUD, cutscene flags): a host's rest
with no party rest, the other player 3 m away; far away with 25 enemies killed first; sitting in the same
checkpoint's menu; a new campaign with both settings off; 26 of the level's triggers entered by the host with the
joined player elsewhere.

**What did.** The owner's sequence replayed in a new campaign with the party rest on: after the first rest the
follower's HUD widget was Collapsed, for good. Traced: in the game a rest is a step inside the checkpoint's menu.
`Checkpoint_C.Interact` opens `SaveMenu_C` (the character's `ShouldHideHUD` is set), the menu's Rest handler starts
the rest, `FS_PlayerHUD_C.RestAnimDone` ends it, the menu takes the focus again, and its Leave handler (or
`SaveMenu_C.Close`) gives the HUD and the play state back. A follower was rested by a direct call of
`Checkpoint_C.Rest`: no menu, so nothing ever left that state. Measured with a controller the game itself reads
(new in the test tools: `input.gamepad`, the first XInput controller of a test copy):

| After | HUD | Stick pushed for 1.2 s |
|---|---|---|
| nothing (baseline) | shown | 389 units |
| a rest the old way (direct call, as every follower's rest up to 0.16.0) | away (`ShouldHideHUD` true, widget Collapsed) | **0 units** |
| "Unstuck" after that (0.17.0) | shown | 389 units |
| a follower's rest the new way (through the menu) | shown | 389 units |

No test had looked at the HUD or at real input before: the test players move by forced input, which a game that
takes no input does not stop, and the checks read the controller's ignore flags and "Resting" - all clear in that
state. Every party-rest test passed for four versions while every follower lost their HUD.

**What 0.17.0 does** is in the README. In short: a follower rests through the checkpoint's own menu; Rest and Save
always bring everyone (no setting); a save brings and saves, nobody rests; a sequence under way is never thrown
away; eight seconds of watching after each; Unstuck and the watch use the character's own `ClosedSaveMenu` /
`UnhideHUD`. Two reviewers read the new code before the first full run; what they found was put right first - among
it that the new enemy rule would have had a joined game ask the host to kill its freshly returned enemies (the
corpse's "our hit killed it first" claim), which no run had shown because the test compared 0 with 0.

### Found by the first full run: a player set down among enemies their game had taken away

The first full run of 0.17.0 (2026-11-15, 101 minutes: 59 runs, 56 passed; 894 checks passed, 4 failed) had three
failed runs. Two were the tests' own. `test_versions` posed as "a mod that speaks only a newer protocol" with the
numbers 10 to 12 written into it, and 10 is this version's own now: the join was rightly let in (the test reads the
number from the source now). `test_daggers` had the host throw three axes from one place with something between it
and the enemy: all three stuck 376 units short (a thrower who missed now throws from another side).

The third, `test_join_far` - "no reading: not on B 41 times" for each of the three enemies around the host - was
followed up, and it is a defect every version has had:

- Traced, the joining game watched five times a second from the moment it is in the level: the game makes EVERY
  enemy of the level when the level starts (392 in the Ruins) and takes those far from the player away a moment
  after a new character's intro; it makes none closer than 50 m to its player. The mod moves a new player next to
  the host at about that moment. When the move came first, the player kept the enemies around the host. When the
  game's taking away came first, the player stood among none of them until the mod's copies came: 17.9 s and 17.9 s
  later in two runs of two, 17.2 s in a third (a copy is held back until the game has been in the level for 25 s
  and calm for 12 s - the rule of 0.16.0 against copies made into a game still coming in).
- The mod's own answer for a player who arrives by a warp - ask that player's spawners for the enemy ("Try
  Spawning Enemy", the sight check skipped) - had in fact never been made: it was queued only for enemies whose name
  the joined game had never seen, and a joined game has seen every name by its first look at the level. Requests
  counted: 0 in every run looked at.
- The test had not noticed: it counted the enemies the joined game knew BY NAME (all of them, always), and when the
  joined game had no actor of any it said "no reading": the summaries kept of eight earlier full runs show it failing
  in two.

**What 0.17.0 does about it.** A joined game that is told of a living enemy it has no actor of asks its own spawner
for it - also for a name it knows: after a second without an actor, the nearest first, three a frame and fifteen a
second, and only while its own game is calm (no move under way, no part of the map coming in, no cutscene, no
intro, no rest of its own, no party rest placing this player). What the spawner makes is that enemy's actor from
that moment: the host drives it from the next frame, and a death the host tells in between is carried out on it.
Left to the copies as before: a boss group's and a paired boss's spawner, a follower's, one a script activates,
the extra enemies of a larger party. A spawner that makes nothing is asked less and less (10, 20, 40, 60 s).
What kinds of spawners there are was looked at first: of the 415 in the shown parts of the first level 276 are
plain, and of the 58 within 60 m of the first checkpoint 36 are plain, 10 have a condition in the save (the
"regular" enemies that come with the story), 10 lie in wait (traps, sleepers) and 2 are potion lizards (a kill
count and a drop of their own) - all of these are asked; no copy has what their spawner gives them.

| | Before (0.16.0 and the first 0.17.0 build) | Now (the final build) |
|---|---|---|
| A new player moved next to the host, the game's taking away first | none of the 3 enemies around the host for 17.9 s, 17.9 s, 17.2 s (three runs), then copies | all there 0.1 s after the player stands - the player's own game's enemies, 0 copies |
| The same made on purpose: back to the level's start (187 m), the enemies around the host taken away, a warp back | not tested | 4 requests, 4 made, 0 copies; there 0.1 s after landing; none twice |
| A joined player 160 m away brought by a party SAVE; 33 enemies around the checkpoint taken away in their game | not tested (by the rule above: copies after 12 s of calm) | 33 requests, 33 made, 0 copies; all there 3.3 s after being set down; none twice, none the host does not have |
| An enemy the host's game killed while the joined player was away | - | not asked for, not made |
| `test_enemy_repair`: a joined game's copy of a fighting enemy destroyed | a copy from the host's word after 3 s | the game's own enemy, by its spawner, after 2.6 s |

**Read by four reviewers in two rounds** (two each time, one going through the flow line by line, one looking for
a session in which the change makes things worse; read-only). The first round found eight things in the first
version, the second round what the rework had left open; all of it was put right before the final build:

- An enemy the host killed between the request and the joined game's next look lived on in the joined game with
  its own AI (the look made a new record that knew nothing of the death). Now the request is checked against the
  host's word just before it is made, and the enemy made is that enemy's actor at once.
- Requests went to every spawner. Now not to a boss group's, a paired boss's, a follower's or a script's, and
  whether an enemy is a boss is asked at the first look at its actor, not when it is first driven.
- No pace and no waiting for a calm game: now both (and the pace counts requests made, not entries looked at).
- A request during the player's own rest, or while a party rest is setting the player down, could have met the
  game's own re-making of the enemies: none is made then.
- A trap made on request next to a player who was just set down could have told the host "it woke for my
  player": one that is awake from its first moments is sent back to sleep and no waking of it is told until it has
  slept once.
- An enemy the player's own hit had just killed could have been made again before the host's word of its death
  arrived: no request for five seconds after the player's own kill claim, and none in the first second without an
  actor.
- A spawner that never delivers was asked every five seconds, with a full look at the enemies each time: now less
  and less often, and the look only when something was made.
- The six-second limits in the tests could not be met by an enemy that is left to the copies: the status now says
  for each enemy whether its spawner may be asked, and the tests give the others their own limit (40 s).

Not provoked in a live test, closed by the code as the second pair read it: the host's kill in the very moment of
the request; a trap that comes out awake; a boss among the missing enemies (none of the tested places has one).

**Found on the way and NOT changed: kills of a split party.** A probe on the final build: the host killed an
enemy (real damage, its own player) while the joined player was 187 m away - that player's game had no actor of it
to die. When the joined player came within 70 m of the place, their own game made that enemy again, alive and on
its own, and it was still there for that player only when they walked up to it. Enemies are shared where the
host's game has them; what is killed while the party is split is not shared, in any version. It is in the README's
known limitations now. A rest puts every game right, and a rest or a save now brings everyone to one place.

### New and changed live tests

| Test | What it checks now |
|---|---|
| `lab.py` | `arm_pads`, `stick_moves` (the game's own controller input moves the character - or not), `hud_state`, `free_to_play` (HUD back, no checkpoint menu left, controls not held, not resting, AND the stick moves the character) |
| `test_party_rest` (rewritten, 38 checks) | the old `RegroupOnRest=0` / `RegroupOnSave=0` lines in both settings files do nothing; the host rests: the joined player, 39 m away and hurt, is brought, rests through its own checkpoint menu, is healed and free to play, enemies killed before are alive again, the same number in both games, none twice in the joined game and none alive there that the host does not have; the joined player SAVES: the host, 160 m away and hurt, is brought and its game saved at that checkpoint, not healed, not rested; the joined player rests with the host standing there: rested where it stands, through its menu; the HOST saves: the joined player, 160 m away, whose game had taken the 33 enemies around the checkpoint away, is brought and saved, is free to play, and has every one of them again within 6 s, each once; a follower sitting in the checkpoint's own menu is rested in it and keeps it, and leaving it by hand gives the HUD back; a follower in a fight with the co-op menu open is brought and rested all the same; a boss fight: refused for both, with words; a rest without the menu (made by hand) leaves no HUD and no input, and "Unstuck" gives both back |
| `test_party` (3 and 4 players) | one joined player rests through the menu: ALL the others, far away, are brought, rest through their own menus and are free to play (HUD, real stick input), and so is the one who rested |
| `test_join_far` (11 checks, was 6) | counts ACTORS in the joined game, not names: every enemy the host has around it is there within 6 s of the new player standing next to the host, each once, where the host has it; then the bad order on purpose - back to the level's start, the joined game takes those enemies away, a warp back: every one again within 6 s, made by the joined game's own spawners on request (0 copies); and one the host's game killed meanwhile is not made |
| `test_zones` | the party rest in a part of the map the follower's game does not show, the rest that does not let go (ended at 14 s, the HUD checked too), the rest in place: stage numbers and waits follow the new sequence |
| `test_menu_pages`, `test_coop_screen` | the settings page has nothing to switch for the party rest and says that it always brings the party; another setting is used for "switches at once and is kept" |
| `test_versions` | "a mod that speaks only a newer protocol" takes its numbers from the source (this version's protocol plus one to plus three), and the host's roster must stay at one |
| `test_daggers` | a thrower whose axe missed throws again from another side (and says from how far each time) |

### The whole run on the final build

2026-11-15, game 1.01.07 (copies E to H), the build that is packaged (`QDCoop.dll`, SHA-256 beginning `fee6437c`),
nothing rebuilt afterwards: **59 runs, 59 passed; 908 checks passed, none failed**, 103 minutes. `test_perf`: host
0.47 ms of mod work per frame on average (worst frame 1.7 ms), joined game 0.75 ms (worst 1.7 ms), at 60 frames per
second - the requests to the spawners and the question "is it a boss" at the first look included.

Before it, for the record:

- The first full run of this version (build `62925dde`, before the change told of above): 59 runs, 56 passed, 894
  checks passed, 4 failed - the three runs told of above (`test_versions`, `test_daggers`, `test_join_far`).
- On that build, with the two tests put right: `test_versions` once and `test_daggers` twice, all passed.
- On the first version of the change: `test_join_far` three times, `test_enemy_repair` and `test_party_rest` once
  each, all passed (requests then went to every spawner at once, unpaced: 37 around the first checkpoint in 0.6 s).
- On the second version (after the first review): `test_enemy_repair` passed; `test_join_far` failed twice on one
  check of its own making (the test "killed" an enemy with the tools' Kill, which is not a player's kill, and the
  host's game brought that enemy back within seconds: the check judges at the moment of arrival now, and a real
  kill by the host's player is what the probe of the split party used); `test_party_rest` failed its new six-second
  check: of 33 enemies around the checkpoint one, a potion lizard, was left to the copies by a rule taken over
  from the host's extra enemies and came after 14.1 s. The rule was wrong for this purpose (an extra potion lizard
  would be an extra potion; the ONE the host has is just that enemy) and was narrowed to what does more than "make
  my enemy".
- On the final build, before the whole run: `test_join_far` twice, `test_enemy_repair`, `test_party_rest` (38
  checks): all passed.

The build itself: the release build was started five times for the change; two of those were cut off halfway by the
tool that ran them (a partial file, no error of the compiler's) and were simply run again in the background.

### What was not tested

Everything above ran with test bots on one PC. **UNTESTED** as before: real Steam between two accounts, a real
controller and Steam Input (the test's controller is read by the game as its first XInput controller: the same
path, not the same hardware), people over the internet, 1440p / 4K / ultrawide displays, bosses other than the
Sword Shrine's guardian, game builds before 1.01.06a with this version. New and **UNTESTED in effect**: a checkpoint
whose part of the map is not loaded in a follower's game at all (in this game every part is loaded, shown or
hidden; the code waits 40 s for it and then leaves the player where they are); two players resting at two
checkpoints within seconds (the host refuses the second, by rule only); a party rest across a level load; the
requests to a joined game's spawners in a level other than the first, with three or four players at once (the
full run has them in every test, the timing was measured with two), and for a boss or a script's enemy (left to
the copies by rule, no such enemy was missing in a run).

## 0.16.0: what the owner's games with 0.15.1 showed

The owner played 0.15.1 on 2026-11-13 (three players, game 1.01.06a) and sent a list of what was still wrong. Their
game's log of that evening was read first (read only; names and account numbers never leave the reading script):

| In the log | What it was | What 0.16.0 does |
|---|---|---|
| One joined character, save slot 9, loaded for every host's campaign | A player who joined had ONE co-op character: a new campaign began with the old campaign's items, and what a campaign owed a player was counted against that one character | A campaign id per co-op save; a character per campaign on the joining PC (slots 20 and up, `characters.json`); rewards kept per campaign |
| 27 enemy copies made "after 11.1 s", "after 26.8 s" | A player the mod had moved (a warp to a teammate, a party rest, joining next to the host) stood in the right place while their game still showed another part of the map: none of the host's enemies there, until copies were made | The moved player's game is made to show what the teammate's shows first (the game's own level lists), then the player is set down |
| A rest in a Secret Zone, then the same player warping to a teammate six times in a minute | The rest brought the player to a checkpoint in a part of the map their game did not show: the game's rest never ended there, and the watch that should have freed them stopped when they opened the co-op menu | The levels are waited for; a checkpoint this game does not show is not rested at; the watch does not stop for the menu; "Unstuck" in the menu |
| A member listed in a session while their game was on the title screen | They had left by the game's own menu | Such a member leaves the session; a host who does it ends it |
| A vote to end the session that lapsed after 30 s | The vote's Yes and No were the menu's last entries but three | They are its first entries while a vote is open |

Not in the log, from the owner's list: fire and poison that never ended on a teammate (a teammate's body does not run
the game's effect logic: nothing ever ended it there); a blow aimed at one player that hurt two; the controller
bindings (View held for the menu, R3 the ping only); the party HUD's place; Delete Co-op Save; a friend's picture in
the invitations.

### New and changed live tests

All on four copies of game 1.01.06a (`QD_E` to `QD_H`, the owner's game build).

| Test | What it checks |
|---|---|
| `test_campaigns` (new, 27 checks) | Three campaigns of one host, one joining player: a character per campaign in a slot of its own; a new campaign starts with the starting items and nothing of another campaign's; going back gives exactly that campaign's inventory (herbs and daggers counted); an important item found while the player was away is given once on return, in that campaign only, never twice; a campaign whose record names the player from before 0.16.0 gets a COPY of the old character, the old save byte for byte unchanged; Delete Co-op Save is refused with a lobby open, deletes only the chosen save's game files, record and ledger, and leaves a copy of all of it in `Saves\Backups`; every other save file on the PC is byte for byte as before; with all eighty character slots of the joining PC taken, one more campaign puts away the character of the campaign not played for the longest time - its save files in `Saves\Backups` byte for byte, with a note - and no other character's files change |
| `test_zones` (new, 18 checks) | Each game knows what part of the map the others show; the host goes below ground the game's own way and the two games show different parts; a warp to the host makes the joined game show the host's part first, with the host's enemies there; a warp that can not land (no floor) puts the player back and the game shows what it showed; a party rest across parts brings the player, rests them with their own game (health refilled), controls back by the game's own doing; a rest that does not let go is ended by the watch after 12 s with the co-op menu open; "Unstuck" gives the controls back; a teammate already at the checkpoint rests where they stand |
| `test_status` (new, 11 checks) | Magic fire and poison put on a teammate's body in the host's game are taken off the body and handed to that player's own game, each once; the party HUD shows them in both games while they last; the fire burns down by the game's own doing and the poison is cured by the game's own cure, and nothing is left on any body or screen; a joined game cleans the bodies it shows and hands nothing on; two players in one spot by an enemy: no blow taken by both; the party HUD's rows are centred on half the screen's height at three window shapes |
| `test_menu_input` (rewritten, 25 checks) | 30 holds of View toggle the co-op menu 30 times; short presses open nothing and the game's own Status event is handed on when the button is let go; a hold hands the game nothing; R3 pings and never opens the menu; the menu holds the controls while open; the same on the joined game, after the pause menu, after a rest, after a team wipe and respawn, after reconnecting; no invisible menu while the HUD is not drawn |
| `test_invitations` (11 checks) | As before, and: a friend's picture, given as pixels the way Steam gives them, becomes one texture drawn in the row; entries without a picture show the name's initial |
| `test_ping`, `test_trade_menu`, `test_progress`, `test_lobby`, `test_menu`, `test_lan_code`, `test_versions`, `test_warp` | Follow 0.16.0: R3 is the ping, the joined character's slot is the campaign's own, a protocol newer than 9 |

Game-free suites (`build_tests.cmd`, `tests/run_tests.py`): the new `chars_tests` (12 tests: which character a
campaign gets, never another campaign's slot, never a save the book does not know, which one makes room in a full
book) with five mutation twins, the
reward ledger's "a new character is owed its campaign's finds again" with its twin; all suites pass and every twin is
caught.

### Found and fixed while testing 0.16.0

- **The game stood still every ten seconds - in every version up to 0.15.1.** The mod looked through every object of
  the game for its hooks every ten seconds, for as long as the game ran: 0.5 s on the host copy and 1.2 s on the
  joined copy each time, measured on the test PC (`test_menu_input` showed it: holds of View cut short on a
  ten-second beat). What it looks for is fixed once the game has started; it now stops after the pass that finds
  everything in place ("ProcessEvent hooks complete ... no further scans"). This was a real, regular hitch in every
  player's game.
- **Two crashes of a joined game, one cause - in every version up to 0.15.1.** The game's crash report names it:
  "Illegal call to StaticFindObjectFast() while serializing object data or garbage collecting". The mod's frame is
  started from the game thread's message pump. The main loop pumps once a frame; but the engine also peeks at its
  messages while the game thread WAITS for the renderer from somewhere inside engine code - also in the middle of a
  garbage collection - and since 0.10.2 the mod ran a frame from such a peek too when the last frame was more than
  50 ms ago. A frame that then looked up or made an object (an enemy copy, a teammate's body) ended the game. On a
  fast PC such waits are short and rare; on the test PC of 2026-11-14, throttled to a third of its speed (see
  *Performance*), they came five to eight times a second, and two test copies crashed within hours
  (`test_menu_input`, `test_party` with four players). The loader now tells the core which pump a frame comes from
  (host interface version 4), and in a pump made from inside the engine the mod does nothing at all; the session's
  links are kept alive by their own thread. A slow PC is exactly where a player would have met this.
- **Enemy copies came too early.** 0.16.0 first made an enemy copy after 3 s instead of 11 s: a joined game six
  seconds after a team wipe, its intro still running, got twenty copies in one frame. Copies are now made only in a
  game that has been in the level for 25 s with its levels in and no cutscene for 12 s, only where that game has
  ground at the enemy's place, and two a look, four a second at most. Meanwhile an enemy that is not there can not
  hurt (its hits are not taken, as before).
- **Copies of enemies lying in wait woke the host's.** A copy made from an enemy's class is not lying in wait; told
  to the host as "woke", it set the host's real enemies on players who had done nothing (`test_team`: the party dead
  by the level's start). A copy no longer reports a waking.
- **The rest watch stopped too early.** The game's rest takes hold of the player a moment after it begins, sometimes
  more than a second after: the watch saw "free" before that and stopped (`test_zones`). It now waits until the rest
  has held the player.
- **A team wipe with four players: one game never pressed Continue.** The game can hold more than one death screen
  object; the first found was kept though it never opened (`test_party` with four players). The open one is looked
  for; the game's own Kill is tried up to three times; with no death screen at all after 30 s the game's own Respawn
  is used.
- **A skip vote left a slow player out.** A player was waited for only for 8 s after their character was in the
  level; a game that needs longer than that to start its intro (a slow PC) was dropped from the count, the others
  skipped, and that player watched the intro alone - the owner's log has it ("all 2 voted" with three in the
  session), and `test_cutscene` showed it on the throttled test PC. 25 s now; a vote still waits 30 s in all at most.
- **A joining player could run out of character slots.** Eighty campaigns fill the book; the eighty-first was
  refused ("no save slot is left"). The character of the campaign not played for the longest time is now put away
  in `Saves\Backups` - copied, checked, then removed from its slot - and its slot given to the new campaign.
- A warp over nothing let the character fall 13.5 m before holding it (`test_warp`): 11 m at most again.
- On a slow PC the game places a new character once more some seconds after its intro - after the mod had moved the
  joining player next to the host: the player stood at the level's start again, 140 m away (`test_party` with four
  players). A jump of the character that was not the mod's, within a minute of that move, is answered with the move
  once more.
- A game on the title screen asked the level manager whether levels were coming in: there is none there, and the
  call faulted. Not asked without one.
- The engine's image import takes a 24-bit BMP's bits for a channel's depth and makes no texture: the picture is
  handed over as a PNG.
- A hold of View begun or ended while the game stood still for a moment (a level coming in) is timed from the middle
  of the gap, so that a long-enough hold is a hold.

### The run on the packaged build

Every same-build live test on four copies of game 1.01.06a (`REGRESS_REMAP="A=E,B=F,C=G,D=H"`), on the build that is in
the package - `QDCoop.dll` sha256 `e9cddd4ca27894c7...`, `xinput1_3.dll` `23f0a0c608f5e45b...` - on 2026-11-14/15:
**59 runs, 55 passed in the full run; the four others passed when run again by themselves on the same build, after
their tests were put right** (845 checks in all). Nothing was rebuilt between that run and the package. The four:

- `test_dialogue`: the PC went to sleep while this test was starting its copies (21:12 to 23:44; the run went on by
  itself afterwards). Nothing of the test had run. Run again: PASS, 23 checks.
- `test_party_rest`: its boss step set the host's player next to "the boss" it had picked minutes earlier; the rests
  in between had brought the level's enemies back, the picked one was another actor by then and stood held, and the
  host's player was taken down by its neighbours. The test now wakes the boss by its name as it is, and holds the
  others. PASS, 17 checks.
- `test_join_deep`: it asked that the character be seen moving at the moment of the join's move; since 0.16.0 the move
  itself holds the character still while the part of the map it goes to comes in, and the test's look fell into that
  hold. It now tells the two holds apart. PASS, 7 checks.
- `test_enemy_repair`: its second step needs the joined player within the enemy's reach; the first step's moves had
  left the player 270 to 515 units away in some runs, and the enemy never noticed them. The player is now put next
  to the enemy before the step. PASS, 8 checks (three hits told by the host, none of them taken while the enemy's
  copy is missing; with the copy back its hits land).

Three full runs on earlier builds of that day came before it; what they found is in *Found and fixed while testing
0.16.0* above. `test_perf` failed in those and passes in this one: see *Performance*.

**Not run for 0.16.0: the older game builds.** The mixed-build runs and the runs on game 1.01.03 and 1.01.05 (copies
A to D) were left out: 0.16.0 was tested on 1.01.06a only, the build the owner plays. **UNTESTED on 1.01.03 and
1.01.05** (the mod's start-up check of the game is unchanged, and 1.01.06a can not play with the older builds in any
case).

The installer test (`tests/installer_test.py`) on the 0.16.0 package's files (its two DLLs and its installer scripts; this report was completed afterwards): all 15 checks passed.

| Test | Result | Checks passed | Seconds | |
|---|---|---|---|---|
| `test_two_players` | PASS | 14 | 49 |  |
| `test_combat` | PASS | 14 | 55 |  |
| `test_loot_world` | PASS | 9 | 55 |  |
| `test_team` | PASS | 21 | 96 |  |
| `test_drops` | PASS | 13 | 65 |  |
| `test_progress` | PASS | 13 | 66 |  |
| `test_hud` | PASS | 17 | 69 |  |
| `test_anim` | PASS | 29 | 123 |  |
| `test_menu` | PASS | 15 | 54 |  |
| `test_menu_input` | PASS | 25 | 202 |  |
| `test_versions` | PASS | 9 | 91 |  |
| `test_warp` | PASS | 9 | 38 |  |
| `test_perf` | PASS | 3 | 66 |  |
| `test_fault_guard` | PASS | 8 | 45 |  |
| `test_boss_scaling` | PASS | 17 | 53 |  |
| `test_chaos` | PASS | 25 | 115 |  |
| `test_party --players A,B,C` | PASS | 0 | 100 |  |
| `test_party --players A,B,C,D` | PASS | 0 | 127 |  |
| `test_difficulty` | PASS | 15 | 59 |  |
| `test_party_rest` | PASS | 17 | 149 | first run: FAIL (1 failed); run again by itself on the same build |
| `test_lan_code` | PASS | 17 | 71 |  |
| `test_title_button` | PASS | 13 | 39 |  |
| `test_menu_pages` | PASS | 19 | 104 |  |
| `test_lobby` | PASS | 12 | 105 |  |
| `test_join_far` | PASS | 6 | 57 |  |
| `test_paste_join` | PASS | 5 | 41 |  |
| `test_trade` | PASS | 28 | 130 |  |
| `test_trade_menu` | PASS | 13 | 67 |  |
| `test_outline` | PASS | 8 | 95 |  |
| `test_coop_screen` | PASS | 42 | 152 |  |
| `test_knights` | PASS | 10 | 120 |  |
| `test_lobby4` | PASS | 11 | 97 |  |
| `test_ranged` | PASS | 10 | 60 |  |
| `test_deaths` | PASS | 7 | 57 |  |
| `test_sight` | PASS | 11 | 62 |  |
| `test_ambush` | PASS | 7 | 51 |  |
| `test_boss_fight` | PASS | 18 | 84 |  |
| `test_trade_window` | PASS | 17 | 74 |  |
| `test_daggers` | PASS | 11 | 63 |  |
| `test_weak` | PASS | 13 | 98 |  |
| `test_loot_rules` | PASS | 25 | 180 |  |
| `test_friendly` | PASS | 18 | 113 |  |
| `test_heal_give` | PASS | 9 | 77 |  |
| `test_session_end` | PASS | 27 | 255 |  |
| `test_travel` | PASS | 21 | 134 |  |
| `test_dialogue` | PASS | 23 | 132 | first run: FAIL (1 failed); run again by itself on the same build |
| `test_cutscene` | PASS | 20 | 83 |  |
| `test_enemy_count` | PASS | 22 | 121 |  |
| `test_teamsound` | PASS | 9 | 43 |  |
| `test_weapons` | PASS | 13 | 87 |  |
| `test_invitations` | PASS | 11 | 60 |  |
| `test_join_deep` | PASS | 7 | 46 | first run: FAIL (1 failed); run again by itself on the same build |
| `test_enemy_repair` | PASS | 8 | 79 | first run: FAIL (1 failed); run again by itself on the same build |
| `test_ping` | PASS | 11 | 96 |  |
| `test_latency` | PASS | 6 | 177 |  |
| `test_boss_talk` | PASS | 8 | 78 |  |
| `test_zones` | PASS | 18 | 281 |  |
| `test_campaigns` | PASS | 27 | 544 |  |
| `test_status` | PASS | 11 | 93 |  |

### Game 1.01.07 (Steam's update of 2026-11-14)

Found on 2026-11-15, when 0.16.0 was installed in the owner's game: Steam had updated that game the day before,
after the test copies had been made, so the run above was not on the game the owner now has. The update changes the
game's data only: the main pak (12 KB smaller) and the build number in the game's `version.txt` (13565 became
13571). The exe is the one of 1.01.06a, time stamp and all - which is why the installer, going by the exe, called
the game "1.01.06a: tested". Steam's notes for 1.01.07 name two things: a collision fault fixed, and a red rectangle
on the title screen removed.

What the mod reports when it starts on it: game version 1.01.07, the same game data signature
(`1e3ab73668704977`) and the same fourteen class signatures as on 1.01.06a, every feature on, the title screen's
Co-op button in its place.

**The whole run again, on 1.01.07.** Copies E to H were given the owner's pak (checked by hash); they keep Steam's
exe and stay without the owner's Arabic pak, as before (the owner's exe differs from Steam's by the 108 bytes of that
mod's text patch; their log of 2026-11-13 shows the same game data signature with it). The build is the packaged
one, nothing rebuilt. 2026-11-15, 100 minutes: **59 runs, 58 passed; 874 checks passed, one failed.** `test_perf`:
host 0.49 ms of mod work per frame on average (worst frame 2.7 ms), joined game 0.83 ms (worst 2.1 ms), at 60
frames per second.

The one that failed: `test_boss_fight`, one check of its 18 - "the boss fights the joiner in front of it, the host
standing off to the side". The boss stayed with the host for the 25 seconds watched. **It was the test, not the
update and not the mod**, and this is how that was settled:

- Run again unchanged, four times: 18 of 18 each time.
- The step moved the two players under a fighting boss, one after the other (each move takes a second): the
  joiner first, to 3.5 m in front of the boss, then the host, to 8 m off its side. Between the two moves the joiner
  was already gone and the host still stood next to the boss. Watched closely (the same setup with the pause between
  the moves made longer, twice): the boss turned to the host in that gap both times - its rule: the nearest player,
  with a preference for the one it already has - and came back to the joiner when the host had left. In the failed
  run it had instead walked after the host to the host's new place before it asked again whom to fight; there the
  host was the nearest, and stayed so.
- With the order turned round (the host first), four runs: the check passed four times, and in one of them the next
  check failed the same way, mirrored ("the host near and the joiner away": the boss had followed the joiner 14 m).
- The test now holds the boss still while the two take their places and lets it go then (it asks anew whom to
  fight): six runs, 18 of 18 each, the boss at the joiner within 0.5 to 10 s and at the host within 4 s.

So the race was seen in two of nine runs on 1.01.07 that day. Whether 1.01.07 makes it likelier than 1.01.06a did
was not measured (the test had not failed this way in the runs before); it needs a player who is moved several
metres in one instant, which in a real game is a warp to a teammate, and a boss that then follows the player it was
after is what the game does.

**1.01.06a and 1.01.07 together.** The two have the same data wherever co-op compares it, so the mod lets them
play together; no entry in `compat.ini` is needed for that. Tested both ways on 2026-11-15, with one copy put back on
1.01.06a (each copy's log names the other's game version): 1.01.07 hosting and 1.01.06a joining, then 1.01.06a
hosting and 1.01.07 joining - `test_two_players`, `test_progress`, `test_team`, `test_hud` and `test_boss_fight`
each way. **10 runs, 10 passed (166 checks).**

**The installer** now tells 1.01.07 from 1.01.06a by the game's `version.txt`, and says of a later update with the
same exe that the mod was not tested on it (`tests/installer_test.py`: four more checks, 19 in all).

**0.16.0 in the owner's game** (2026-11-15, with their yes, the game closed): installed with the package's own
installer over 0.15.1. Checked afterwards: the three installed files are the package's (the tested build); the
settings file, the player id and the co-op records are byte for byte as before; the game's exe and paks are
untouched; all eleven save files are byte for byte as before. The state before it (the 0.15.1 mod folder and the
saves) is kept in a backup folder outside the game.

### What was not tested, and how to test it

Everything above ran with test bots on one PC, the games talking over loopback. That shows what the mod's code does
in the real game; it does not show Steam, a real controller, real distance between players, or people playing.
**UNTESTED** below means exactly that: built, never seen working where it is meant to work.

| What | State | How to check it |
|---|---|---|
| Steam: invitations, joining, friends' pictures from Steam itself | **BLOCKED** here (needs two Steam accounts that own the game, in two games; the test copies run with the mod's use of Steam off, and App ID 480 is not used) | Host from the Co-op screen, invite a friend from the co-op menu. On the friend's PC: Co-op screen > Join: the host's row should show their Steam picture (their initial for the first seconds), "In the lobby 1/4 - invited you", ACCEPT joins. Also try "Join Game" in Steam's friends list with the game running and with it closed |
| The panel never shows an invitation that is not real | Checked in code and by test: rows come only from Steam's friends list (a friend in this game whose game says it hosts) or from an invitation accepted in Steam; test rows exist only through the developer bridge, which is off in the package | - |
| A real controller: View held 0.6 s for the menu, a short press for the game's Status screen, R3 for the ping | **UNTESTED** with hardware (the test presses the buttons on a virtual controller the mod reads like a real one; the hand-over of a short press to the game is tested with the game's own Status event). Steam Input was not tested at all | In a session: hold View about a second: the co-op menu opens; again: it closes. Tap View: the game's Status screen. Click the right stick: a ping where you look. With a Steam Input layout that remaps View, set it back to Back/Select or use F8 |
| Three and four people over the internet | **UNTESTED** (the four-player tests are four copies on one PC). Lag is tested at a simulated 150 ms round trip (`test_latency`) | Play; the roster in the co-op menu shows each player's ping |
| A new campaign next to an old one, with real saves | Tested with test characters (`test_campaigns`); **UNTESTED** with the owner's own saves (never touched by a test) | Host an existing co-op save: each friend gets a copy of their old joined character, once. Host "+ Create New Co-Op Save": everyone starts with the starting items. Go back to the old save: everyone has that save's items. Rest before leaving: nothing is saved when a session ends |
| Missing daggers / important items after rejoining | Tested (`test_campaigns`, `test_daggers`, the ledger's game-free suite) | A friend who was away when the party found daggers, a key or a quest reward gets them within seconds of joining that campaign again |
| Fire and poison in a real fight | Tested by putting the game's own effects on a body with the game's own functions (`test_status`), and seen once from a real enemy (a poisoner by the level's start, in `test_menu_input`'s log). **UNTESTED**: every enemy and hazard of the game that sets players on fire | Get set on fire next to a friend: their screen must not show your fire once it has burned out on yours; the party HUD shows BURNING on your row while it lasts |
| One swing, one victim | The rule is in and switched on (`[Combat] SingleTargetSwings`), but in the test no blow of the enemy used caught both bodies, so the rule itself did not have to act: **UNTESTED in effect** | Stand shoulder to shoulder with a friend in front of one enemy: a blow at one of you should hurt that one only |
| The party HUD at 1440p, 4K and ultrawide | Tested at three window shapes up to this PC's desktop (1596 x 997), a 21:9 window among them: the rows are centred on half the screen's height in each. **UNTESTED** on a real 1440p, 4K or ultrawide display | Look at it; `[PartyHUD] Position=TopLeft` is the old place |
| Bosses other than the Sword Shrine's guardian | The boss bar, the fight and the talk with the beaten boss are tested with that boss (`test_boss_fight`, `test_boss_talk`, `test_boss_scaling`). **UNTESTED** with the others | In a boss fight every player should see the boss's health bar; after the talk with a beaten boss everyone can move |
| The wipe's last resort (the game's own Respawn when no death screen comes) | **UNTESTED**: it has not been needed in any run since it was written | - |
| Two joined players far from the host, in a part of the map the host's game does not show | **NOT BUILT**: each of them runs the enemies around them in their own game (see the README's known limits) | - |
| Weapons in teammates' hands | Tested: every weapon of the game drawn in turn (`test_weapons`) | - |

### Performance

`test_perf` asks that the mod's own work stays under 1 ms per frame on average. In the final run, on the packaged
build, with the game at 60 frames per second: **host 0.46 ms on average (worst frame 1.9 ms), joined game 0.81 ms
(worst 2.6 ms): PASS.** (0.13.0, the last version written up here: 0.40 and 0.64 ms.)

For most of 2026-11-14 the same test failed - and so did 0.15.1 when it was put back on the same copies: the test PC
was throttled that day. Windows reported every processor core at about a third of its base clock (`% Processor
Performance` 31-44 on each core; by the evening it read 163 again), and two copies of the game reached 17 to 21
frames per second instead of 60. The two versions were measured against each other in that state: the same two
copies, the same quiet scene (both players at the level's start, the enemies around held), 40 s each, alternating:

| Build | Host: mod work per frame | Joined game: per frame | Game frames per second | Mod work per second, both games |
|---|---|---|---|---|
| 0.15.1 | 3.2 ms | 5.5 ms | 20.9 / 20.2 | 177 ms |
| 0.16.0 | 4.6 ms | 3.6 ms | 19.5 / 19.6 | 160 ms |
| 0.15.1 | 3.5 ms | 5.7 ms | 21.2 / 20.8 | 193 ms |
| 0.16.0 | 4.9 ms | 4.2 ms | 16.9 / 18.8 | 161 ms |

(0.15.1's frames include the ones it ran from inside the engine, which 0.16.0 no longer runs - 470 to 570 of them
were skipped on the host and 260 to 280 on the joined game in each 0.16.0 sample - so "per second" is the fair
column.) 0.16.0 does no more work than 0.15.1.

That slow day is also what brought out the crash and the stalls described above: the throttled PC behaved like a
much weaker one. Separately from the per-frame work, 0.16.0 removes a stall: up to 0.15.1 the mod looked through
every object of the game every ten seconds (0.3 to 1.2 s each time on the throttled PC; a fraction of that at full
speed, but on every PC, every ten seconds).

## 0.15.1: game version 1.01.06a

Installing 0.15.0 into the owner's game on 2026-11-12 showed that the game had been installed again that day, in
another Steam library, and that Steam had brought it up to **game version 1.01.06a** (exe `6AF55DEF`, built
2026-11-12) - a build the mod had not met. Four test copies of that build were made from the owner's installation
(read only, without the mod's files): `QD_E` to `QD_H`; `tests/live/regress.sh` takes `REGRESS_REMAP="A=E,B=F,C=G,D=H"`
to run every same-build test on them.

**What 0.15.0 did on 1.01.06a.** The mod's start-up check found everything it needs and switched every part on
(teammate bodies, shared world, loot and enemies, revive, checkpoint, party rest, boss gate, party HUD, title screen
hosting, trading, enemy shots); `test_two_players`, `test_combat`, `test_boss_fight`, `test_enemy_repair`,
`test_weapons` and `test_anim` passed on it. `test_team` did not: 1.01.06a added two keys of its own (compass, HUD)
and with them renumbered the game's events of the Interact key (`InpActEvt_Interact_K2Node_InputActionEvent_25/26`
became `_30/_31`). The mod looked these up by their numbers: on 1.01.06a a downed player could still use Interact,
and a talk with an NPC no longer waited for the party ("Waiting for Teammates"). Every other key event the mod uses
kept its name (read from the game: 33 events).

**What changed in 0.15.1.** The mod finds the game's key events by their action's name, whatever numbers the build
gave them (`gamefuncs.cpp` `InputEventNames`; used by the downed player's block and the talk's gate). The tests find
them the same way (`lab.input_events`). The installer knows 1.01.06a as a tested build. Nothing else changed.

**1.01.06a with the earlier builds.** 1.01.06a changed the game's player and enemy data (and its save functions and
title screen), so it can not play with 1.01.05 or 1.01.03: a session between them is refused, both ways round, with
the reason named (tested: `test_two_players` with the host on 1.01.06a and the joiner on 1.01.05, and the other way
round). Everyone who plays together needs the same game update.

**The run on 1.01.06a.** Every same-build live test on four copies of 1.01.06a, with the 0.15.1 build that is in the package (`QDCoop.dll` sha256 `edbc8f89e12f3652...`, `xinput1_3.dll` `6418948fb5601a82...`): **56 runs, 47 passed.** The failed ones and why - every one was run again, on the same build, after its test was put right:

| Test | First result | Why | Run again |
|---|---|---|---|
| `test_fault_guard` | FAIL (2 failed) | the test read the log of copy C, not of the copy C was mapped to - the test, fixed | PASS, 8 checks |
| `test_party --players A,B,C` | FAIL (1 failed) | the test looked for the names BotB and BotC; bots are named after the copy they run on (BotF, BotG) - the test, fixed | PASS, 15 checks |
| `test_party --players A,B,C,D` | FAIL (1 failed) | as above (that run started before the fix) | PASS, 15 checks |
| `test_trade_menu` | FAIL (2 failed) | names written into the test (BotA, BotB) - the test, fixed | PASS, 13 checks |
| `test_lobby4` | FAIL (1 failed) | names written into the test - the test, fixed | PASS, 11 checks |
| `test_daggers` | FAIL (3 failed) | the joiner's three axes missed the held enemy (its known way of failing; nothing of the mod in it); passed when run again | PASS, 11 checks |
| `test_loot_rules` | FAIL (3 failed) | 1.01.06a removes a pickup once it is taken (the earlier builds kept it, hidden): the test took the finder's own, gone pickup for a fault - the test now takes either | PASS, 25 checks |
| `test_cutscene` | FAIL (1 failed) | 1.01.06a's OpenPauseMenu has no QuickJournal parameter, which the test passed - the test, fixed (the mod sets it only where it is there) | twice: PASS, 20 checks; FAIL once (see below) |
| `test_ping` | FAIL (1 failed) | the test's enemy stands lower than the ledge the test puts the joiner on; a line to its middle meets the floor's edge first, and the mod rightly marks the floor - the test now looks at what can be seen of it | PASS, 11 checks |

`test_menu` and `test_chaos` started their copies by letter and so ran on the old copies in that run; run again on 1.01.06a: PASS, 15 checks and PASS, 25 checks. `test_cutscene` was run twice more on 1.01.06a after its fix: once all 20 checks passed; once the part where one game is held up 18 s after a team wipe stopped, because that game was not seen in the intro within two minutes (the other games had waited for it and gone on) - not explained.

| Test | Copies | Result | Checks passed | Seconds |
|---|---|---|---|---|
| `test_two_players` | game 1.01.06a | PASS | 14 | 43 |
| `test_combat` | game 1.01.06a | PASS | 14 | 54 |
| `test_loot_world` | game 1.01.06a | PASS | 9 | 55 |
| `test_team` | game 1.01.06a | PASS | 21 | 93 |
| `test_drops` | game 1.01.06a | PASS | 13 | 66 |
| `test_progress` | game 1.01.06a | PASS | 13 | 66 |
| `test_hud` | game 1.01.06a | PASS | 17 | 67 |
| `test_anim` | game 1.01.06a | PASS | 29 | 124 |
| `test_menu` | game 1.01.06a | PASS | 15 | 69 |
| `test_menu_input` | game 1.01.06a | PASS | 16 | 143 |
| `test_versions` | game 1.01.06a | PASS | 9 | 91 |
| `test_warp` | game 1.01.06a | PASS | 9 | 38 |
| `test_perf` | game 1.01.06a | PASS | 3 | 64 |
| `test_fault_guard` | game 1.01.06a | FAIL (2 failed checks) | 2 | 39 |
| `test_boss_scaling` | game 1.01.06a | PASS | 17 | 52 |
| `test_chaos` | game 1.01.06a | PASS | 25 | 112 |
| `test_party --players A,B,C` | game 1.01.06a | FAIL (1 failed checks) | 14 | 98 |
| `test_party --players A,B,C,D` | game 1.01.06a | FAIL (1 failed checks) | 14 | 126 |
| `test_difficulty` | game 1.01.06a | PASS | 15 | 60 |
| `test_party_rest` | game 1.01.06a | PASS | 17 | 156 |
| `test_lan_code` | game 1.01.06a | PASS | 17 | 69 |
| `test_title_button` | game 1.01.06a | PASS | 13 | 40 |
| `test_menu_pages` | game 1.01.06a | PASS | 19 | 101 |
| `test_lobby` | game 1.01.06a | PASS | 12 | 98 |
| `test_join_far` | game 1.01.06a | PASS | 6 | 56 |
| `test_paste_join` | game 1.01.06a | PASS | 5 | 37 |
| `test_trade` | game 1.01.06a | PASS | 28 | 129 |
| `test_trade_menu` | game 1.01.06a | FAIL (2 failed checks) | 2 | 56 |
| `test_outline` | game 1.01.06a | PASS | 8 | 93 |
| `test_coop_screen` | game 1.01.06a | PASS | 42 | 148 |
| `test_knights` | game 1.01.06a | PASS | 10 | 117 |
| `test_lobby4` | game 1.01.06a | FAIL (1 failed checks) | 10 | 92 |
| `test_ranged` | game 1.01.06a | PASS | 10 | 64 |
| `test_deaths` | game 1.01.06a | PASS | 7 | 56 |
| `test_sight` | game 1.01.06a | PASS | 11 | 62 |
| `test_ambush` | game 1.01.06a | PASS | 7 | 51 |
| `test_boss_fight` | game 1.01.06a | PASS | 18 | 96 |
| `test_trade_window` | game 1.01.06a | PASS | 17 | 73 |
| `test_daggers` | game 1.01.06a | FAIL (3 failed checks) | 8 | 83 |
| `test_weak` | game 1.01.06a | PASS | 13 | 100 |
| `test_loot_rules` | game 1.01.06a | FAIL (3 failed checks) | 22 | 167 |
| `test_friendly` | game 1.01.06a | PASS | 18 | 108 |
| `test_heal_give` | game 1.01.06a | PASS | 9 | 75 |
| `test_session_end` | game 1.01.06a | PASS | 27 | 251 |
| `test_travel` | game 1.01.06a | PASS | 21 | 130 |
| `test_dialogue` | game 1.01.06a | PASS | 23 | 131 |
| `test_cutscene` | game 1.01.06a | FAIL (1 failed checks) | 2 | 27 |
| `test_enemy_count` | game 1.01.06a | PASS | 22 | 119 |
| `test_teamsound` | game 1.01.06a | PASS | 9 | 43 |
| `test_weapons` | game 1.01.06a | PASS | 13 | 87 |
| `test_invitations` | game 1.01.06a | PASS | 10 | 57 |
| `test_join_deep` | game 1.01.06a | PASS | 7 | 45 |
| `test_enemy_repair` | game 1.01.06a | PASS | 8 | 95 |
| `test_ping` | game 1.01.06a | FAIL (1 failed checks) | 2 | 78 |
| `test_latency` | game 1.01.06a | PASS | 6 | 118 |
| `test_boss_talk` | game 1.01.06a | PASS | 8 | 75 |

**0.15.1 on the earlier builds.** The only change finds the same names there (25/26), so the full run of 0.15.0 on 1.01.03 and 1.01.05 (below) stands for them; on the 0.15.1 build these were run again: `test_team`  PASS (21 checks); `test_dialogue`  FAIL (9 checks); `test_menu_input`  PASS (16 checks); `test_two_players`  PASS (14 checks); `test_versions`  PASS (9 checks); `test_ping`  PASS (11 checks); `test_two_players` [B=D] PASS (14 checks). (`test_dialogue` stopped once while waiting for all three games on the second line; run again twice on the same build: 23 of 23 both times.)


## 0.15.0: what changed and how it was checked

0.15.0 is 0.14.0 kept as it was and repaired in place (nothing was rebuilt; every older live test is still run). It
answers the owner's "critical stability and synchronization overhaul" (P0, P1, P2) and its three additions (boss
health bars, the talk with a beaten boss, invisible weapons), written after three players had played 0.14.0 for two
hours. The evidence came first: the owner's own co-op log of that morning, read without changing it and with names,
ids and addresses masked (findings F1-F9 in `OVERHAUL_015_NOTES.md`). For each point: what was wrong and why, what
was changed, which test checks it on real copies of the game, and what stays open. "Checks" are the PASS lines of
that test in the final run on the packaged build (below); a test with one failed check counts as failed.

New live tests: `test_enemy_repair`, `test_latency`, `test_ping`, `test_boss_talk`; extended: `test_enemy_count`,
`test_loot_rules`, `test_cutscene`, `test_boss_fight`, `test_party_rest`, `test_session_end`, `test_versions`. A
simulated slow network for tests: `QDCOOP_TEST_LAG_MS` (every packet held that long on arrival, in both games: 75
gives a round trip of 150 ms) and `QDCOOP_TEST_LOSS_PCT`; test-only, never set in a player's game.

**The final run.** Every live test, on the build that is in the package (`QDCoop.dll` sha256 `f20aa6e665a47be3...`, `xinput1_3.dll` `01620ac8b7003ed5...`; nothing was built again afterwards): **69 runs in 101 minutes, 68 passed, 1 failed: test_boss_fight [A=D,B=A].** The game-free suites (`tests/run_tests.py`: code, compat, discovery, ledger, net, save, sync, trade, each with its twins) all pass on the same source.

Runs repeated after the full run (the reason is given; the build is the same):

| Test | Copies | Result | Checks | Why it was run again |
|---|---|---|---|---|
| `test_boss_fight` | A=D, B=A (mixed game builds) | PASS, 2 runs of 2 | 18 in each | In the full run the host's game (copy D, game 1.01.05) went silent about a minute after its level had loaded, while the harness waited for its character to stand after the intro was skipped - before any step of the boss test - and its process then ended, leaving no crash report and no Windows error event. Nothing was changed; the cause is not known. The same pairing passed in the first full run, and the other pairing (B=D) in both. |

| Test | Copies | Result | Checks passed | Seconds |
|---|---|---|---|---|
| `test_two_players` | same build | PASS | 14 | 48 |
| `test_combat` | same build | PASS | 14 | 54 |
| `test_loot_world` | same build | PASS | 9 | 54 |
| `test_team` | same build | PASS | 21 | 93 |
| `test_drops` | same build | PASS | 13 | 64 |
| `test_progress` | same build | PASS | 13 | 66 |
| `test_hud` | same build | PASS | 17 | 71 |
| `test_anim` | same build | PASS | 29 | 122 |
| `test_menu` | same build | PASS | 15 | 50 |
| `test_menu_input` | same build | PASS | 16 | 141 |
| `test_versions` | same build | PASS | 9 | 87 |
| `test_warp` | same build | PASS | 9 | 38 |
| `test_perf` | same build | PASS | 3 | 64 |
| `test_fault_guard` | same build | PASS | 8 | 44 |
| `test_boss_scaling` | same build | PASS | 17 | 53 |
| `test_chaos` | same build | PASS | 25 | 113 |
| `test_party --players A,B,C` | same build | PASS | 15 | 98 |
| `test_party --players A,B,C,D` | same build | PASS | 15 | 120 |
| `test_difficulty` | same build | PASS | 15 | 58 |
| `test_party_rest` | same build | PASS | 17 | 154 |
| `test_lan_code` | same build | PASS | 17 | 68 |
| `test_title_button` | same build | PASS | 13 | 40 |
| `test_menu_pages` | same build | PASS | 19 | 100 |
| `test_lobby` | same build | PASS | 12 | 95 |
| `test_join_far` | same build | PASS | 6 | 55 |
| `test_paste_join` | same build | PASS | 5 | 37 |
| `test_trade` | same build | PASS | 28 | 130 |
| `test_trade_menu` | same build | PASS | 13 | 66 |
| `test_outline` | same build | PASS | 8 | 94 |
| `test_coop_screen` | same build | PASS | 42 | 148 |
| `test_knights` | same build | PASS | 10 | 118 |
| `test_lobby4` | same build | PASS | 11 | 88 |
| `test_ranged` | same build | PASS | 10 | 59 |
| `test_deaths` | same build | PASS | 7 | 57 |
| `test_sight` | same build | PASS | 11 | 61 |
| `test_ambush` | same build | PASS | 7 | 50 |
| `test_boss_fight` | same build | PASS | 18 | 98 |
| `test_trade_window` | same build | PASS | 17 | 74 |
| `test_daggers` | same build | PASS | 11 | 61 |
| `test_weak` | same build | PASS | 13 | 97 |
| `test_loot_rules` | same build | PASS | 25 | 167 |
| `test_friendly` | same build | PASS | 18 | 110 |
| `test_heal_give` | same build | PASS | 9 | 75 |
| `test_session_end` | same build | PASS | 27 | 253 |
| `test_travel` | same build | PASS | 21 | 129 |
| `test_dialogue` | same build | PASS | 23 | 131 |
| `test_cutscene` | same build | PASS | 20 | 82 |
| `test_enemy_count` | same build | PASS | 22 | 119 |
| `test_teamsound` | same build | PASS | 9 | 43 |
| `test_weapons` | same build | PASS | 13 | 84 |
| `test_invitations` | same build | PASS | 10 | 55 |
| `test_join_deep` | same build | PASS | 7 | 45 |
| `test_enemy_repair` | same build | PASS | 8 | 85 |
| `test_ping` | same build | PASS | 11 | 92 |
| `test_latency` | same build | PASS | 6 | 107 |
| `test_boss_talk` | same build | PASS | 8 | 75 |
| `test_two_players` | B=D (mixed game builds) | PASS | 14 | 48 |
| `test_progress` | B=D (mixed game builds) | PASS | 13 | 65 |
| `test_team` | B=D (mixed game builds) | PASS | 21 | 94 |
| `test_hud` | B=D (mixed game builds) | PASS | 17 | 67 |
| `test_anim` | B=D (mixed game builds) | PASS | 29 | 122 |
| `test_trade` | B=D (mixed game builds) | PASS | 28 | 130 |
| `test_coop_screen` | B=D (mixed game builds) | PASS | 42 | 148 |
| `test_two_players` | A=D, B=A (mixed game builds) | PASS | 14 | 47 |
| `test_progress` | A=D, B=A (mixed game builds) | PASS | 13 | 66 |
| `test_team` | A=D, B=A (mixed game builds) | PASS | 21 | 93 |
| `test_hud` | A=D, B=A (mixed game builds) | PASS | 17 | 67 |
| `test_boss_fight` | B=D (mixed game builds) | PASS | 18 | 93 |
| `test_boss_fight` | A=D, B=A (mixed game builds) | FAIL (1 failed checks) | 1 | 154 |

**The first full run, and what it found.** A first full run on an earlier build (`QDCoop.dll` `aa35a7e3e8f0fd09...`)
ended 61 of 69. One failure was the mod's: `test_enemy_repair` - a copy made in a joined game from the host's word
started with a record that said "never heard from the host", and the clean-up of copies the host no longer tells of
could take it away before the host's next state arrived, without a word; the enemy stayed missing and was made again
six seconds later. Fixed (the copy is marked as just heard of, and such a removal is logged), and the final build
above is the one with the fix. Seven were the tests' own: `test_progress` looked for the save only in `SaveGames`,
while the game writes it into a folder of the Steam account when Steam is running on the PC at its start (it was,
that evening); `test_boss_fight` confirmed the talk with the beaten boss in the host's game only, and since 0.15.0
the joiner is in that talk too and must confirm as well (the talk is shared, as asked); `test_session_end` expected
the "host lost" words about 57 s after the host went - with the 20 s timeout it is about 65 s, and the words were
looked for after they had gone; `test_invitations` had the mod versions of its test entries written for 0.14.0 and
took Steam to be missing on the PC; `test_knights` and `test_friendly` stood their bots where an enemy could walk up
(two knights were struck down mid-check; an enemy within 15 m was taken for the doer of a hurt "with no enemy
near") - those enemies are now taken out of the game first; `test_join_far` got no reading at all and said nothing
about why - it now says (it passed in the final run).

### P0: critical

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| **Items lost.** (1) The finder of a shared important item (a weapon, a key item) had it only in its game's memory until its next rest, while the mod's record already said "given": a team wipe, a death or a crash before that rest loaded the save without it, the host's ledger counted it as the finder's, and the pickup stayed taken in the host's world - lost for good, for the one who found it. (2) The owner's log shows a second cause of "my items are gone": as a joined player they continued one co-op character (slot 9), as a host they began a new campaign (slot 8) with a new character - the items of one are not in the other. | (1) The finder's game is saved before its record says the item was given (`loot.cpp`), as the others' games already were. (2) Said plainly in `README.md` (*Your co-op character is one per role*). | `test_loot_rules` (25 checks): the joiner finds the Jar Hammer; its game is then closed by force (as by a crash) with no rest since; it starts again with its own save: the hammer is there, one, and its record says so. The twin run with the save left out (`--twin-nofindsave`, the 0.14.0 behaviour): the joiner came back with **no** Jar Hammer while its record said it had been given - the owner's "items lost", made again (`build/live-results/twin_loot_nofindsave.txt`). | Carrying one character between hosting and joining was not built. What the game's own Continue loads (its last rest, or its suspend save every two minutes) is the game's. |
| **Too many enemies, enemies that vanish and come back** (F1). Enemy count scaling (new in 0.14.0) made an extra enemy whenever the first enemy of a spawner was "a new actor" and its extra was gone - with real players spread over a level both happen all the time (the game takes enemies away and brings them back by its own player's distance). In the owner's game: 520 extras in 13 minutes, the same one up to twelve times, three team wipes in five minutes. | An extra is made once for each time the enemies come back by right (a level entered, a rest of the host's game) and never again in between; only near players who have stood about there for 8 s; 4 at a time, 12 in 10 s, 24 alive at most; an extra alone for 20 s is removed and not made again (`enemies.cpp`). | `test_enemy_count` (22 checks), among them: a joined player thrown to four places in 14 s draws no enemies along the way; no extra was made twice since the level was entered; a killed extra does not come back while its first enemy lives. | Long sessions of real players moving apart were not run; the rule is by generation, so the count can not grow with time. |
| **Invisible enemies that hit** (F2). 205 times in two hours the host's enemy acted and the owner's game (joined) had no copy of it: the game makes enemies by its own player's distance and sight, and extras were never made in a joined game whose spawner did not want to. The host decides hits, so the damage came from nothing to be seen. | A joined game that is told about an enemy it has no living copy of (within 60 m) asks the host what it is (`ENEMY_ASK` / `ENEMY_INFO`) and makes the copy with the game's own class, driven by the host like any copy - after giving its own spawner 11 s (5.5 s when it has none there). Until a copy is there, a hit from that enemy is not taken. (The first full run found that a fresh copy could be taken away again at once by the clean-up of copies the host no longer tells of; fixed - see above.) | `test_enemy_repair` (8 checks): the joiner's copy taken away: back in about 4 s from the host's word; hits from an enemy with no copy are not taken; with repair on they land. `test_ambush`, `test_combat`, `test_deaths`, `test_sight`, `test_join_far` unchanged. | A copy made from the host's word has no spawner of its own: an enemy lying in wait made that way does not wake for that player's look (the host's enemy wakes as the host's game decides). |
| **An enemy dead for one player and alive for another** (F3, 16 times in the log: "our copy died first"). When the host did not take a joined game's kill, the enemy stayed dead there and alive in the host's game - another invisible enemy. | The joined game makes the copy again when the host's state still names that enemy alive (the dead copy is set aside first). | `test_enemy_repair`: a kill the host refuses (as for a waiting boss): the copy is back in about 2 s; a kill the host takes: gone in both games, no copy made. | - |
| **Damage to the wrong player, or twice.** No case of a hit put on the wrong player was found in the log: each "hit taken" names an enemy near that player. What looked wrong were the hits from enemies that were not there (above) and hits after a dodge (P1 below). The hazard damage counted twice was fixed in 0.14.0. | Hits from an enemy with no living copy are not taken; a hit escaped on the player's own screen is not taken (P1). Counters of hurts from the own world and from the host (`team.status`) and of every dropped hit (`enemies.repair`) for the next report. | `test_friendly` (18), `test_team` (21), `test_enemy_repair`, `test_latency` | Not reproduced as described. |
| **A party wipe that does not bring everyone back** (F5). Three wipes in the owner's game, each followed by everyone's reload; the three wipes themselves came from the enemy flood (F1). | No change to the wipe itself. | `test_team` (wipe, two players), `test_party --players A,B,C` and `A,B,C,D` (15 checks each), `test_menu_input` (after a wipe and respawn) | A wipe with three and four players where someone does not come back was not reproduced. |
| **Players frozen after a rest / regroup** (F6). Not reproduced (two and three players, one and two rests, Rest then Save at one checkpoint, with "regroup on Save" on as the owner has it). Found on the way: a player busy in something else (a talk, a cutscene, the trade window, the co-op menu, their own rest) was moved and rested all the same; Rest then Save moved everyone twice. | A follower who is busy is not moved; the same checkpoint again within 60 s and 12 m moves nobody; a follower whose controls the game's rest still holds after 20 s gets them back (and it is logged); a placing that does not finish in 12 s is given up with the screen faded back in (`rest.cpp`). | `test_party_rest` (17 checks): controls free after every rest, the second rest at one checkpoint moves nobody, three rests told | The owner's freeze itself was not seen. |

### P1: high

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| **Daggers not shared** (F8). All 27 throwables in the game's item data were read (equippable, no consumable): the mod classes every one as shared and written to the reward ledger - none as an ordinary consumable. The owner's own log shows two dagger rewards reaching the owner's game (an NPC's gift of three Throwing Daggers, and one more): no failing case was found in the evidence. | None needed: the classification reads the game's item data (not names). A live check was added. | `daggers_class_lab` (27 of 27 shared); `test_loot_rules` part 6: B is handed a Throwing Dagger by the game, A and C are given one each, once, and the campaign's ledger has it. | A dagger lying in the world was not taken in a test: the only one in the first area is hidden until later in the story. |
| **"I dodge an attack but still receive damage."** The host's enemy strikes the joined player's body in the host's game, which is where that player was a moment ago (the network's delay, and the body's smoothing). A player who had stepped away on their own screen was hit all the same. | The host sends with each hit where the body and the enemy stood; the player's own game, which keeps a track of the last 1.5 s of its own places, looks where it really was when the host judged (now less half its live round trip) and does not take a hit it had clearly escaped: 1.5 m and more from where the host's body stood and 1.5 m farther from the enemy, with the host's body at most 0.5 s behind (`enemies.cpp`). Found by the test itself: a first version took the earliest moment the player had stood at the hit spot, so a dodge out of a stand never counted (the host's body seemed more than 0.5 s behind); it takes the latest. Also found: every ping time shown (Co-op screen, co-op menu) stayed at the link's starting guess of 100 ms - the roster was sent only when someone joined or left; it is now kept current (`net/session.cpp`). | `test_latency` (150 ms round trip, both games show it): both games show a ping of 160 ms. B standing next to the enemy: every hit taken, none called escaped (4 of 4). B dodging - each swing drawn as when standing, B stepping 2.6 m away 0-600 ms after the swing appeared on its own screen: in the final run 6 swings in 25 s; steps at 400 and 500 ms were hits on the host's lagging body and were not taken (2.6 m from where the host's body stood, which was 84 ms behind; round trip 165 ms); steps at 0-200 ms were seen by the host's game before the swing landed (no hit); the step at 300 ms was a hit taken. (In an earlier run, 12 swings: escapes at 400 ms, hits taken at 0, 200, 300, 500 and 600 ms - attacks differ in how long they wind up.) The test found the first version's mistake above. | Bounded on purpose: a near miss on the player's screen may still be a hit by the host's word. The game has no dodge with immunity this early (its Wind Dash is a later upgrade; with it the same rule applies). |
| **Steam invitations.** | No change in 0.15.0 (the 0.14.0 panel reads friends' Rich Presence, ACCEPT joins through the game's own App ID). | `test_invitations` (10, with entries a test puts in) | **Not verified with real Steam**: it needs two Steam accounts in two running games. Steam App ID 480 (Spacewar) was not used (see *Steam* below). |
| **A cutscene skipped by one player.** The vote itself held in the owner's log (four votes, each "skipped for everyone") - but with three players in the session the votes were "all 2", after each of three wipes: the vote counted only players already in the cutscene. After a wipe every game loads the level again and the intro plays in each as it finishes loading: the first game there was alone in the intro (its skip was the game's own, for that player alone), and a vote could be complete before a slower game was there at all. Every way the game has to skip a cutscene in a level was listed from its own code (all its functions named Skip): the pause menu's button and its SkipCutscene - both already votes - and the player's skip functions those call; the game has no key that skips a cutscene by itself. | A player who was in the level a moment ago and is loading it again, or who came into it in the last 8 s and is not in a cutscene yet, is waited for - at most 30 s after the first vote - and a player alone in a cutscene while others are on their way votes too (`cutscene.cpp`). | `test_cutscene` (20 checks): the three-player vote as in 0.14.0, and a team wipe with one game held up 9 s: A and B vote, nothing is skipped while C is on its way (2/3); C comes into the intro, the vote waits for its word; C votes and the three skip together. | Later cutscenes of the story were not reached by the tests (the intro only). |
| **End Session**: a unanimous vote, and no automatic save. 0.14.0 let the host end the session for everyone and saved every game. | Anyone may ask (asked twice); every player votes YES or NO in the co-op menu; it ends only when everyone has voted yes; one NO, or 30 s without every answer, and the session goes on; a player who leaves is no longer asked. **Nothing is saved by the mod on any end of a session** (the vote's end, leaving alone, a host gone); the vote reminds every player: "Make sure your progress is saved before leaving. The session will not automatically save." (`sessionend.cpp`, `menu.cpp`, `hud.cpp`). | `test_session_end` (27 checks): the vote's YES, NO and lapse; on every end - the vote's, leaving alone, the host gone - every save of every game is on disk as it was before | - |

### P2: medium

| What was wanted | What was made | Checked by | Open |
|---|---|---|---|
| **Teammate pings** | The middle mouse button (or `[Ping] Key`; on a controller R3 held for half a second - a tap still opens the co-op menu, every other button is the game's) marks what the player looks at: the enemy the look points at (the mark follows it and goes when it dies), else an item lying there, else the place. A small diamond in the player's colour with their name and the distance, an arrow at the edge of the screen when it is out of view; 8 s; one a second, two per player (`ping.cpp`, message `PING`). | `test_ping` (11 checks, three players) | No sound with a ping. |
| **Latency** | The session waits 20 s (was 12) before a stalled player counts as gone (the owner lost the host four times in two hours, over a shared virtual network; the host's own log of that day was not available). Ping times shown are current. The dodge rule above. Tests run under a simulated round trip of 150 ms. | `test_latency`, `test_chaos` (relay 50/100/150 ms) | The cause of the owner's four lost connections is not known (it needs the host's log of that day). |
| **Diagnostics** | `enemies.repair` (copies asked for, made, refused, hits not taken and why, hits judged and escaped), extras by generation, `team.status` (hurts from the own world and from the host), the rest's skipped and given-back counts, cutscene waits, pings; each with a log line. | the tests above read them | - |

### The boss, its health bar and the talk after it

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| **No boss health bar for joined players.** The boss's own fight logic switches the game's bar on, and that runs in the host's game only. | Every game shows the game's own boss bar (`BossHealthBar_C` in the player's HUD) while the host's boss fights within 45 m, kept to the boss's real health (the host's); off when the boss dies or leaves the fight. | `test_boss_fight` (18 checks): both bars on in the fight with the boss's health, both follow a hit, both go when it is beaten; also with one game 1.01.05 and the other 1.01.03, both ways round. | Other bosses than the guardian of the Sword Shrine were not reached by the tests. |
| **The talk with a beaten boss** (F7). The host's word about it arrived with no name for whom it was with ("talks to : not there for it"): the beaten boss talks through an NPC the game makes while it runs, which the other game could not find by its path - the others were not in the talk. The owner reported a freeze when talking to a beaten boss. | An NPC the game makes while it runs is known by its class and place (`dialogue.cpp`). The beaten boss's double is made by each game only when its own player interacts with the boss, so a game that has none yet joins by interacting with its own beaten boss: its double is made and the same talk starts there (`enemies::BeatenBossNear`). The lines step together as in any shared conversation. Found on the way: the host's word now names the NPC (it was empty in the owner's log). | `test_boss_talk` (8 checks): the joiner talks to the beaten boss; the host's game is in the same conversation (two members, the joiner leads); the lines step when both have confirmed (the reward the talk shows each puts away for themselves: there the two games were a line apart for a moment); the talk ends in both games; both players can walk and look about; the boss dies in both games with the same experience and story flag, and one reward each. `test_boss_fight`: the host's talk, the boss's death in both games, one reward each. | The freeze itself was not reproduced. |

### Weapons in a teammate's hand

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| **37 of the game's 106 weapons were invisible in a teammate's hand.** The mod showed the mesh of the weapon's component named "Mesh"; those weapons name theirs otherwise (Model, SkeletalMesh, their own names), or are built of several parts. | The weapon's largest mesh part is shown (effect parts and the engine's own shapes left out) (`knights.cpp`). | A lab over every weapon the game has (`weapons_lab2`): each drawn by the joiner, what the host's game puts in the joiner's body's hand - before the change 69 of 106, after it 106 of 106, the same mesh the joiner's game holds (one more item, `NullDagger_A`, is no weapon to draw). Pictures of six of the 37 in the host's game were looked at (kept with the test results, not in the package: they are pictures of the game). `test_weapons` (13). | How each looks in motion was judged from pictures, not by a person playing. |

### Steam App ID 480 (Spacewar)

Not used. Running the game under another application's id cuts it loose from its own Steam ownership, which the
request itself and the standing rules forbid; and the "Unreal project" steps (DefaultEngine.ini, Build.cs, session
nodes) have nothing to act on in a DLL mod of a shipped game. The Steam path stays the game's own App ID; joining by
code or address remains the way that was verified.

## 0.14.0: what changed and how it was checked

0.14.0 is 0.13.0 kept as it was and repaired and extended in place (nothing was rebuilt; every older live test is
still run). It answers a list of 25 points from the game's owner. For each: what was wrong and why, what was
changed, which test checks it on real copies of the game, and what stays open. "Checks" are the PASS lines of that
test in the final run on the packaged build (below); a test with one failed check counts as failed.

**The final run.** Every live test, on the build that is in the package (`QDCoop.dll` sha256 `895ea6f7c62bb50f...`, `xinput1_3.dll` `0e4b2f6ff2757901...`; nothing was built again afterwards): **65 runs in 89 minutes, 64 passed, 1 failed: test_daggers [same build].** The game-free suites (`tests/run_tests.py`: code, compat, discovery, ledger, net, save, sync, trade, each with its twins) all pass on the same source.

Runs repeated after the full run (the reason is given; the build is the same):

| Test | Copies | Result | Checks | Why it was run again |
|---|---|---|---|---|
| `test_daggers` | same build | PASS, 6 runs of 6 | 11 in each | In the full run the joiner's game saw the host's axe only once in flight (the check wants it seen twice, nearer the second time). The target enemy was held by switching its AI off; the joiner's axe had woken it, and it was striking the joiner while the host threw. The test now also stops the target's own time, again before every throw. Only the test was changed, not the mod. (Other changes to this test were tried first - the host nearer, both players set down again before every throw - and failed in 12 of 24 runs; they were dropped.) |

| Test | Copies | Result | Checks passed | Seconds |
|---|---|---|---|---|
| `test_two_players` | same build | PASS | 14 | 45 |
| `test_combat` | same build | PASS | 14 | 53 |
| `test_loot_world` | same build | PASS | 9 | 53 |
| `test_team` | same build | PASS | 21 | 92 |
| `test_drops` | same build | PASS | 13 | 62 |
| `test_progress` | same build | PASS | 13 | 64 |
| `test_hud` | same build | PASS | 17 | 66 |
| `test_anim` | same build | PASS | 29 | 120 |
| `test_menu` | same build | PASS | 15 | 52 |
| `test_menu_input` | same build | PASS | 16 | 141 |
| `test_versions` | same build | PASS | 9 | 83 |
| `test_warp` | same build | PASS | 9 | 38 |
| `test_perf` | same build | PASS | 3 | 62 |
| `test_fault_guard` | same build | PASS | 8 | 44 |
| `test_boss_scaling` | same build | PASS | 17 | 50 |
| `test_chaos` | same build | PASS | 25 | 128 |
| `test_party --players A,B,C` | same build | PASS | 15 | 95 |
| `test_party --players A,B,C,D` | same build | PASS | 15 | 118 |
| `test_difficulty` | same build | PASS | 15 | 57 |
| `test_party_rest` | same build | PASS | 15 | 139 |
| `test_lan_code` | same build | PASS | 17 | 65 |
| `test_title_button` | same build | PASS | 13 | 39 |
| `test_menu_pages` | same build | PASS | 19 | 98 |
| `test_lobby` | same build | PASS | 12 | 92 |
| `test_join_far` | same build | PASS | 6 | 54 |
| `test_paste_join` | same build | PASS | 5 | 37 |
| `test_trade` | same build | PASS | 28 | 125 |
| `test_trade_menu` | same build | PASS | 13 | 66 |
| `test_outline` | same build | PASS | 8 | 92 |
| `test_coop_screen` | same build | PASS | 42 | 144 |
| `test_knights` | same build | PASS | 10 | 112 |
| `test_lobby4` | same build | PASS | 11 | 87 |
| `test_ranged` | same build | PASS | 10 | 57 |
| `test_deaths` | same build | PASS | 7 | 56 |
| `test_sight` | same build | PASS | 11 | 59 |
| `test_ambush` | same build | PASS | 7 | 49 |
| `test_boss_fight` | same build | PASS | 15 | 91 |
| `test_trade_window` | same build | PASS | 17 | 72 |
| `test_daggers` | same build | FAIL (1 failed checks) | 10 | 72 |
| `test_weak` | same build | PASS | 13 | 95 |
| `test_loot_rules` | same build | PASS | 24 | 151 |
| `test_friendly` | same build | PASS | 18 | 108 |
| `test_heal_give` | same build | PASS | 9 | 73 |
| `test_session_end` | same build | PASS | 22 | 193 |
| `test_travel` | same build | PASS | 21 | 128 |
| `test_dialogue` | same build | PASS | 23 | 120 |
| `test_cutscene` | same build | PASS | 17 | 40 |
| `test_enemy_count` | same build | PASS | 20 | 90 |
| `test_teamsound` | same build | PASS | 9 | 41 |
| `test_weapons` | same build | PASS | 13 | 85 |
| `test_invitations` | same build | PASS | 10 | 54 |
| `test_join_deep` | same build | PASS | 7 | 44 |
| `test_two_players` | B=D (mixed game builds) | PASS | 14 | 46 |
| `test_progress` | B=D (mixed game builds) | PASS | 13 | 64 |
| `test_team` | B=D (mixed game builds) | PASS | 21 | 92 |
| `test_hud` | B=D (mixed game builds) | PASS | 17 | 66 |
| `test_anim` | B=D (mixed game builds) | PASS | 29 | 121 |
| `test_trade` | B=D (mixed game builds) | PASS | 28 | 127 |
| `test_coop_screen` | B=D (mixed game builds) | PASS | 42 | 144 |
| `test_two_players` | A=D, B=A (mixed game builds) | PASS | 14 | 46 |
| `test_progress` | A=D, B=A (mixed game builds) | PASS | 13 | 64 |
| `test_team` | A=D, B=A (mixed game builds) | PASS | 21 | 92 |
| `test_hud` | A=D, B=A (mixed game builds) | PASS | 17 | 66 |
| `test_boss_fight` | B=D (mixed game builds) | PASS | 15 | 88 |
| `test_boss_fight` | A=D, B=A (mixed game builds) | PASS | 15 | 91 |

### Stability (crashes)

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| The game crashed some minutes into a session, and when quitting. Cause: the mod kept plain pointers to game objects (classes, functions, actors) across frames; the engine frees what nothing uses about once a minute and between levels, and frees everything while closing - the pointer then led to freed memory, or to another object that had taken the place. Both crashes were found in the owner's own crash report and log, and the one on quitting was reproduced on 0.13.0. | Every kept reference is a weak one checked by slot and serial number (the engine's own way); caches keyed by an object are checked the same way; when the engine object is gone the mod does nothing more (`ue/ue.*`, `ue/uejson.*`, `core.cpp`, `gamefuncs.cpp`, `game.cpp`, `triggers.cpp`, `damageset.cpp`, `difficulty.cpp`) | `test_weak`: the Co-op screen opened again after four forced collections; an old address taken over by a new object is told apart; the game closes cleanly from the title screen and from a level | The crash in the middle of a session was not reproduced before the fix (its cause was read from the crash report); it has not happened in any run since. |

### Items, trading, health

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| **Joined players' pickups did nothing** (5). A pickup one player had taken was marked taken in the other games with the game's `SetState` alone, which leaves its model in the world: the others saw an item that could not be taken. And every pickup was first asked of the host, so a joined player's own pickup waited on a round trip that could be refused. | Shared pickups are put away with the game's own full refresh (model gone); ordinary consumables are not shared pickups at all any more (`world.cpp`, `loot.cpp`) | `test_loot_rules`, `test_loot_world`, `test_drops` | - |
| **Loot rules** (6): everything was shared, so three players got three herbs from one. | Items are sorted by the game's own data (`items.cpp`): an ordinary consumable is the finder's and stays in the world for the others; weapons, key items, upgrades and the like are given to everyone once. A ledger in the host's co-op save notes each such reward with who was entitled and who has it; each player's game keeps a record of what it has applied (with a "pending" step, so a crash in the middle neither loses nor doubles). A player who was away is given what they missed (`ledger_core.*`, `loot.cpp`, `GM_LOOT_GRANT`, `GM_LEDGER_*`) | `test_loot_rules` (three players; one leaves, a sword is found, they return and get it once; rejoining again gives nothing more; a late joiner gets nothing found before they came); game-free `ledger_tests` with a twin for each rule | The ledger is per co-op save of the host: a player who joins another host's campaign starts with that campaign's ledger. |
| **Trading "did nothing"** (9): both players offered the same items - ten herbs for ten herbs - and the trade was carried out, changing nothing. The window also did not say what would be given and received. | Two equal offers are refused in words; the window has YOU GIVE and YOU RECEIVE FROM, and a line "After this trade you have ..."; the result is told with the numbers; only ordinary consumables can be offered (`trade_core.*`, `trade.cpp`, `tradescreen.cpp`) | `test_trade` (10 herbs and 3 given: 7 and 3 more, in both saves), `test_trade_window`, `test_trade_menu`; game-free `trade_tests` with twins | Cutting a real connection at the very moment of a trade is covered by the simulated network only (unchanged from 0.13.0). |
| **Healing at full health** (10): the game refuses a healing item at full health on every path, so a healthy player could not heal a hurt teammate next to them. | The Use Item key at full health, with a hurt teammate in reach, spends the item for them; with nobody to help nothing is used (`team.cpp`) | `test_heal_give` (both directions; far away; nobody hurt) | Never revives (by design). |
| **Party HUD shows a wrong health** (11). Not reproduced: in every run - wounds, fights, heals, a changed maximum - the number a game held for a teammate was that teammate's own, and the bar showed it. | Two guards against the two ways it could happen: a state that arrives late no longer puts an older health back; the bar's material is looked at twice a second and put right (and logged) if it shows something else (`players.cpp`, `partyhud.cpp`, `umg.*`) | `test_hud` (the bar's own material value against the teammate's health; the local player's health changing leaves it alone) | The reported case itself was not seen, so it can not be called fixed - only guarded. If it shows again, `core.log` will have a "party HUD: ... put right" line. |
| **Pickup notices** (12) were plain lines on the left. | Tiles on the right with the item's picture, name and number, "found by <name>" or "found while you were away", merged when they come together (`hud.cpp`) | `test_hud` | - |
| **Friendly fire** (4) was always on. | Off unless the host turns it on (a rule kept with the co-op save); a player's own hits on a teammate's body are found by bracketing the weapon's hit window and dropped when off; enemy hits are named exactly, so a hazard of the level is not counted twice (`friendly.*`, `enemies.cpp`, `GM_FRIENDLY_HIT`, `GM_PLAYER_STATUS`) | `test_friendly` (off: nothing; on: both directions; poison handed on) | The level's own hazards were simulated (no pool of poison was reached). |
| **Downed players could crawl away** (7). | A downed player's walk speed is nothing and stays so (the character sets its speed every tick: it is put back before movement runs); falling still happens (`team.cpp`) | `test_team` | - |

### The party as one

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| **Only the host's rest regrouped** (8). | A joined player's rest asks the host, which checks (no boss fight, not down, its setting) and brings everyone, itself included (`rest.cpp`) | `test_party_rest` (the host's rest; a joiner's rest brings the host; refused in a boss fight for both, with words; a player in a fight stays) | - |
| **Ending a session left the others standing in the level** (19). | `End the session for everyone`: every game is told with a message sent until it arrives, saves, shows "The Co-op Session Has Ended" and goes to the main menu with the game's own exit; a joined player leaving goes the same way alone; a host gone without a word: told, 45 seconds of reconnecting, then the same end (`sessionend.*`, `GM_SESSION_END`) | `test_session_end` (three players; a downed player is put on their feet first; the same games play again afterwards; a joiner leaves; the host's process is killed) | - |
| **The shop took one player away** (15). The game is one map; "the shop" is an islet 460 m off, reached by a checkpoint's Shop button - a teleport in that player's game only. | Every game watches its own character's teleports; the host has the others follow with their own game's teleport (to the shop from the same checkpoint, back by the pad, to a checkpoint), with the mod's warp as a net (`travel.*`, `GM_PARTY_TRAVEL`) | `test_travel` (a joiner goes to the shop, another comes back, the host teleports to a checkpoint; health and inventory unchanged; setting off; boss fight) | Teleporter stations: not tried (none is open at the start); see the README. |
| **NPC talks were one player's** (16), and a gift went to everyone every time anyone had the talk. | The Interact key at an NPC waits for the party ("Waiting for Teammates: 2/3"); every game near runs the same conversation in step - a confirm is a vote ("Skip Votes: 2/3"), a choice is the leader's, the end is for all; a gift is known by its NPC and is the party's once (`dialogue.*`, `GM_DIALOGUE`, sources in `ledger_core`, `loot.cpp`) | `test_dialogue` (gate; three members; votes; five lines to the end; a gift handed out by all three games: one each, one ledger entry; a voter disconnects; the rule off); `ledger_tests` "an NPC's gift ..." with twin; `test_boss_fight` (a talk's reward reaches the player who was not in it) | A choice between options was not played through; saves that differ may show different lines (README). |
| **Cutscenes were skipped by each for themselves** (17). | The pause menu's Skip Cutscene is a vote while others are in the cutscene; all votes in, every game skips with the game's function; the count is drawn although the game's HUD is off there (`cutscene.*`, `GM_CUTSCENE`) | `test_cutscene` (the intro, three players) | The later cutscenes were not reached. |
| **A new player who joined a host standing on a ledge deep in the level fell out of the level** (found by the tests, see below; 0.13.0 has it too). The mod's warp watches a moved character until it stands; a character whose movement the game has switched off, as after the intro, was taken for standing. | The join move waits until the game has given the character back; the watch waits while a character is held still, wants 0.3 s of standing, and lets go of a character taken elsewhere (`players.cpp`) | `test_join_deep` (a new character joins a host on that ledge: held three times, then set down where the host stands), `test_warp` (movement off, warped over nothing, given back: held, put back; moved away while watched: let go) | A part of the level that does not load within 8 s still sends the player back where they were, with a notice (as before). |
| **Enemy count scaling** (21) did not exist. | The host has ordinary spawners make a second (third) enemy with the spawner's own function, where the party is and before a fight; the others mirror them under shared names; +50% for three, +100% for four, or the host's bonus (`enemies.cpp`, rules in `difficulty.*`, the menu) | `test_enemy_count` (three players: made only near the party, beside and not on the first, same names in all games, killed by a joiner, not coming back, rule off, bonus) | Bosses untouched by rule, not exercised; extras are not saved. Every other test runs with the game's own enemy count (see below). |

### How teammates look and sound

| What was wrong, and why | What was changed | Checked by | Open |
|---|---|---|---|
| **A plain torso under a detailed helmet** (2). Every part of a knight has one material, and all were set - but the Silver Knight's brightness (2.6) washed its body's plates out to a pale flat surface, while its helmet and shield, with other textures, kept their detail. | Brightness 1.5 with more reflection: seams and plate edges show (`knights.cpp`); looked at in pictures of every knight, front and back | pictures (`build/live-results/views_*.png`, `sweep_silver.png`), `test_knights` | Materials are the game's own, tuned by their parameters: no new textures or normal maps can be added by a code mod. |
| **Four more characters** (3). | Four more complete sets of the game's knight (Veteran Swordsman, Royal Guardian, Knight Commander, Ranger Knight) with a sword and a crossbow of the game's; the Co-op screen's selection in two pages (`knights.*`, `coopscreen.cpp`, `portraits.cpp`) | `test_knights` (four games, all eight looks, each fully built and swinging), `test_coop_screen` (pages, portraits) | **Not what was asked in full**: no new 3D models, no separate male and female bodies - that needs an artist and the game's asset tools. They are distinct, complete looks of the knight the game has. |
| **A placeholder weapon** (13): a knight held its look's weapon whatever its player used. | "Real weapon animations": each game tells which weapon model is in its player's hand; the knight carries it and uses the kit's style for its kind; "Legacy animations" is the old picture (`knights.*`, `players.cpp`, `GM_PLAYER_INFO` kind 3) | `test_weapons` (bare hands, axe, club, spear, legacy and back, both directions) | Four styles, not each weapon's own moveset (those exist only for first-person arms). Three weapons were looked at. |
| **Throwables not seen** (14). | Already there since 0.13.0 for all 24 thrown kinds (one root class); unchanged | `test_daggers`, `test_ranged` | The axe is the kind tested live. |
| **Teammates' steps too loud** (20): the knight's walk animations play the armoured enemy's footsteps and rustle at full volume, faster the faster the player runs. | Those sounds only, in a session only, at the player's "Teammate movement volume" (35%) (`teamsound.*`) | `test_teamsound` (the values the game plays them with; the setting; attack sounds untouched; restored) | How it sounds was not judged by ear; enemy knights' steps are quieter too during a session. |
| **No in-game way to accept a Steam invitation** (18). | The game lists the Steam friends who host now (from Rich Presence, with players, version and "invited you") with ACCEPT / DECLINE on the Co-op screen and in the co-op menu (`steamlink.*`, `menu.cpp`, `coopscreen.cpp`) | `test_invitations` - **with entries put in by the test**: Steam does not run in the test copies | **Not verified with Steam**: reading friends' Rich Presence and the join behind ACCEPT need two Steam accounts in two games. No avatars. |

### The earlier full run, and what the tests found before the final one

The first run of every live test on a finished build (64 runs) had 55 passes and 9 failures. Two of the failures
were faults of 0.14.0's own new parts, found by tests written long before them:

- `test_menu`: a player joined with a co-op character whose save stood at another checkpoint. The game sets a
  loaded character down with the same teleport a trip to the shop uses, the new "travel together" took it for a
  journey, and the host was teleported to the joiner's old checkpoint. Fixed: a teleport that begins within twelve
  seconds of a new character, while the level is loading, or in a cutscene is the game's placing, and nobody follows
  it (`travel.cpp`). `test_menu` now also checks that a join moves nobody.
- `test_boss_fight` (all three runs of it): the reward of a beaten boss's talk no longer reached the joined player.
  The new rule made what a talk hands over, if it is no important item, the talker's own. Fixed: the host gives the
  same, once, to the players who were not in that conversation (`loot.cpp`, `dialogue.cpp`).

The others were the tests' own: `test_party` with four players was wiped where it stood - with enemy count scaling
on (+100% for four) and test players that do not fight back. The tests now run with the game's own number of
enemies, by a test switch; `test_enemy_count` tests the scaling itself. `test_weak` still counted four knights;
`test_enemy_count` asked for more room than a wandering enemy keeps (extras are now set down 1.7 m and more from the
first, measured on the ground); `test_daggers` had its thrower 0.8 m from the target, too near to see the axe fly.

The build was made again, and the tests that had failed were run again before the next full run. That found a
third fault, an older one (0.13.0 has it too):

- `test_party` with four players: the first joiner was not next to the host - it stood 190 m away, at the map's
  origin. In that run the host had been sent to a checkpoint on a ledge 165 m under the start. Traced with two
  copies: the joiner's intro ended, the mod moved its character next to the host while the game still had the
  character's movement switched off (it does for almost two seconds after the intro); the watch that holds a
  moved character over a floor that is not there took "not falling" for "standing" and ended; when the game gave
  the character back there was no floor beside the host, and it fell 390 m until the game itself put it at the
  origin. Fixed in `players.cpp`: the join move waits until the character is the player's; the watch waits while
  the game holds a character still; "standing" is 0.3 s of standing - one frame that was not a falling frame had
  ended a watch over nothing in the new test; and the watch lets go of a character that something else (the
  game's own teleport, a party rest) has taken elsewhere, instead of pulling it back. `test_join_deep` (new) plays
  the case on that ledge, following the joiner five times a second; `test_warp` switches a character's movement
  off, warps it over nothing, gives it back, and moves it away while it is watched.

And more of the tests' own:

- `test_loot_rules` failed about every second run, from the first full run on: a herb both players had taken
  stayed in view in both games. Not the mod's loot rules, and not a thing a player can meet: the test went to the
  wrong herb. It looked its pickups up by name, and two herbs in the map are called `Herb_Item_BP_2` - one 15 m
  from the start, and one in a part of the map for a later time of the story, which lies loaded and not shown in
  the same place. The game hands its objects out in an order that changes from run to run. A pickup of a part
  that is not shown gives its item when the test calls its function, and can never be put away (its animation
  does not exist there). Found by following the pickup's own animation in a failing run, then by a picture of
  where the test stood. The test now names each pickup with the part of the level it is in. (On the way the test
  player's "put away" was made to wait until the game has the item shown, instead of a fixed 1.2 s: a "put away"
  before that leaves an item in view for good. That is true of the game, and it was not what made this test fail.)
- `test_weak` asked that none of the knights' assets stay loaded after the game collects, and two of them are
  weapons of the game which the game keeps loaded by itself (it now compares with what is loaded before the screen
  is first opened).
- `test_party_rest` once had its host taken down by an enemy at the far checkpoint where it waits with a third of
  its health (the host now waits at a checkpoint with no enemy within 35 m).
- `test_enemy_count` and `test_daggers` measured a little too strictly where enemies and landings move.

After these changes the build was made once more and every test was run again: that is the final run above. One
run of it failed, `test_daggers`, on a check of the test's own (how often the watching game saw an axe in flight
while its player was being struck by the target the test meant to hold); it is in the table of repeated runs.

### Found on the way

- The join handshake compared a protocol number that was not the one in the message definitions: 0.14.0 would have
  accepted a 0.13.0 player although several messages changed. The range now follows the definitions, and
  `test_versions` has the 0.13.0 case.
- `tests/net_tests` crashed about one run in three: a fault of the test (its simulated Steam was destroyed before
  the sessions that say goodbye through it), fixed there.
- A full audit of who decides what is in `SYNC_AUDIT.md`.

## 0.13.0: what changed and how it was checked

0.13.0 is 0.12.0 with two things the request asked for that were still open. Nothing else was touched:

| In 0.12.0 | In 0.13.0 | Checked by |
|---|---|---|
| A trade was a list in the co-op menu: names and numbers, one line an item | The trade window: two sides - YOUR OFFER, with every consumable the player carries, the game's own picture and name of it and how many are given of how many, and the teammate's offer - both confirmations, Confirm and Cancel; keys and controller; a list longer than six rows scrolls with the cursor | `test_trade_window` (its screenshots were looked at, at 1280x720 and 960x540); `test_trade` and `test_trade_menu` pass unchanged: the menu's list is still the model underneath, and what a request and its answer use |
| A teammate's knight swung its arm and nothing left its hand: a thrown dagger existed in the thrower's game only | Every game tells what its own player throws; the others show the same projectile flying from that knight - with nothing in it that could hurt - stuck where the thrower's stuck and gone when the thrower's is gone | `test_daggers` |

## 0.12.0: what changed and how it was checked

0.12.0 is 0.11.0 with its combat made whole for a party. No system was replaced: the changes are in how the host's
game treats its enemies when it has more than one player, and in what it tells the joined games. The work began by
letting a party of test bots meet a real boss of the game - the guardian of the Sword Shrine, the first boss a player
finds - and writing down everything that went wrong. Each line got an answer and a test:

| In 0.11.0 | In 0.12.0 | Checked by |
|---|---|---|
| A joined player who walked into a boss's arena ahead of the host found the boss asleep: the level's triggers answer to the game's own player only | In every game the party counts as one player for the level's triggers: a teammate's body walking in is told to the game as its own player, and while anyone of the party is inside, nobody has left | `test_boss_fight` |
| An enemy after a teammate judged its sight by the host's player: a teammate standing between it and the host hid the host, an enemy round the corner from the host saw nobody - and an enemy that sees nobody does not attack | The host answers "does this enemy see the one it is after" itself, the way the game does (its range and height, a trace on the same channel, the party's bodies let through), and makes the answer the enemy's own | `test_sight` (which also compares the mod's answer with the game's own for the host's player), `test_boss_fight` |
| The game turned every enemy towards the host's player; an enemy with its back to the teammate it was after never struck | The enemy's turning is handed the player it is after | `test_sight`, `test_boss_fight` |
| Enemies far from the host's camera ran at a few updates a second (the game saving work), also while a teammate fought them | An enemy within 45 m of a teammate runs at its full rate in the host's game | `test_sight` |
| What enemies shot existed in the host's game only: a joined player was hit by arrows nobody could see | The host tells every projectile of its enemies; the joined games show a harmless copy flying the same path, and the hit stays the host's | `test_ranged` |
| An enemy the host killed could live on in a joined game (its copy refused the blow: a shield turned to that player) | The death is carried out until the copy is dead, by the game's own Kill if need be | `test_deaths` |
| The flaming skull that rises from a dead skeleton took the skeleton's name in the mod's books: two games meant two different things by one name | It has a name of its own (its spawner and its class), the same in every game | `test_deaths` |
| A joined player's hit arrived at the host as a bare number: no stagger, no damage type | The hit goes with what it carried (the game's damage tags and values) and the host builds the game's own damage from it | `test_combat` |
| An enemy lying in wait (a fighter in the ground, a sleeping boss) woke in the host's game and was pushed about asleep in the joined ones; and it woke for the host's player only, though the game judges an ambush by one player's place and view | Its waking is mirrored; each game judges its own player, and a joined game tells the host when such an enemy woke for its player: it wakes in the host's game and goes for that player | `test_ambush`, `test_boss_fight` |
| A boss whose death the game suspends until a player has talked to it died for the player who talked; the others stood in a locked arena before a kneeling boss, without the experience | The end of the talk is told to the party and every game ends its own copy the same way: the experience, the story flags and the open gates for everyone; the reward is given once | `test_boss_fight` |

## 0.11.0: what it started from and what changed

0.11.0 is an upgrade of 0.10.2, not a rewrite. The loader, the mod's view of the engine, the session and network
code, the shared world, loot, enemies, down and revive, checkpoints, party rest, the boss gate, the difficulty, the
party HUD, the version handshake and the test harness are the same code, with the changes listed here. Before the
work began the existing mod was read through and its weak points were written down; each got an answer:

| In 0.10.2 | In 0.11.0 | Checked by |
|---|---|---|
| Every teammate was the same knight | Four knights built from the game's own knight armour (helmet, cloth, weapon; tinted by the game's own material values), chosen per player, kept in the settings, sent to the others | `test_knights`, `test_coop_screen`, `test_lobby4`; looked at in screenshots |
| A teammate's knight faced where the camera looked, ran one cycle at one speed, played a full enemy attack (a second of wind-up) for every swing - at the button's press, though the game swings at its release -, and tipped over sideways when down | The body follows its player: the run cycle at the real speed, backwards and sideways walking, swings timed to land with the player's, charging, heavy and ultra attacks, thrown dagger, dash, flinch, a real fall and getting up, kneeling at a checkpoint and when reviving | `test_anim` (29 checks, with a frame-by-frame trace of the feet); frame sheets looked at |
| Corner brackets around every teammate | No mark near by; from 20 m a thin outline of the knight's own shape fades in (full at 35 m, low strength; red for a downed teammate) | `test_outline`, `test_hud` |
| The title's Co-op entry opened a plain list | The Co-op screen: sections, lobby with everyone's knight, knight choice, co-op saves, difficulty, ways to join, one main button; D-pad, stick, keys and mouse | `test_coop_screen` (39 checks), `test_lobby4` (11 checks) |
| One co-op campaign | Three co-op saves, each in a slot and with a record of its own | `test_coop_screen` |
| No way to give a teammate an item | Trading of consumables: asked, accepted, offered, confirmed by both, decided by the host, journalled on both sides | `trade_tests` (15 tests, 6 twins), `test_trade` (28 checks), `test_trade_menu` (13 checks) |
| "New co-op campaign" kept the old save's character and items | The slot is cleared by the game's own delete after the old save was copied to Backups | `test_trade`, `test_menu_pages` |
| The custom difficulty had no coin value and no way to keep one's own values | "Coins found"; Reset, Load My Preset, Save As My Preset | `test_difficulty`, `test_coop_screen` |

"Checked by" names tests that run the real game (two to four copies of it on one PC). What was only looked at by eye
is said so; what could not be checked is under *Not tested / not verified*.

## Game-free suites (`build_tests.cmd`, then `py -3 -I tests/run_tests.py`)

Each suite also has mutation twins (the same code with one protection removed); the suite must fail every twin.

| Suite | Tests | Result | Twins caught |
|---|---|---|---|
| `net_tests` (link and session over a simulated lossy network) | 15: connect four, reliable delivery under 25% loss + 10% duplicates + 50 ms jitter and under 150 ms reordering, a 300 KB message at 15% loss, timeout and rejoin into the same slot, rejections (wrong build, full), unreliable without duplicates, unreliable size limit, host restart, 3 s blackout, early-ack regression, Steam transport session (mock Steam), UDP + Steam on one host (mock Steam), the host's admission verdict and its reason reaching a refused client | PASS | 5/5 |
| `sync_tests` (snapshot interpolation, world state) | 6, including 4-player convergence under chaos for 3 seeds | PASS | 3/3 |
| `save_tests` (co-op save file) | 4: round trip and rotating backups, crash in the middle of a write keeps the old version, recovery from a damaged file, newer schema refused | PASS | 1/1 |
| `code_tests` (join codes) | 7: addresses as typed or pasted (with or without the port, spaces and a line break around; 14 malformed ones refused) and pasted text cleaned; UDP, Steam host and old Steam lobby code round trips (2000 each), human input (case, spaces, no dashes, ip:port), every single-character typo rejected, six-symbol short codes (5000 round trips, any case and spacing, every single-symbol typo caught, wrong lengths refused), Steam's join string (`+qdcoop_host <SteamID>`: 2000 round trips; found inside a command line, after `=`, in quotes, after two spaces; nothing taken from no string, a lobby join, letters, a number with letters, a lobby's id, too many digits or an overflowing number) | PASS | - |
| `compat_tests` (version handshake rules) | 15: identity encode/decode, protocol range negotiation, same build accepted, different game data refused with the classes named, known-equivalent classes accepted (from either side's list), engine differences reported, required features, optional features switched off for the session, the equivalence file's format and bad lines | PASS | 3/3 |
| `discovery_tests` (short codes on the network, real UDP on 127.0.0.1) | 9: message formats and malformed packets, finding a host by its code, a code nobody uses and a session that ended (not found), a second host avoids a code in use, two sessions on one code reported (not guessed), host rate limit (a burst of 50 asks: at most 8 answers), a source guessing codes is muted for 2 minutes, client lookups spaced (at most 10 a minute), real broadcast targets | PASS | 3/3 |
| `trade_tests` (the trade rules and bookkeeping, both sides, over a simulated connection) | 15: a gift, an exchange, decline and cancel, a changed offer takes both confirmations back, only consumables, not more than owned, repeated messages, a replayed old message, a disconnect before the decision and after it, settling after a save was rolled back, the host settling from its ledger, one trade at a time, the rules (distance, fight, downed) and time-outs, and random play over 40 seeds (454 trades completed, 259 cancelled or aborted): after every one the two inventories add up to what they were | PASS | 6/6 |

## Live tests (`tests/live/*.py`)

`bash tests/live/regress.sh` runs all of them and the mixed-build pairs in one go (52 runs, about 67 minutes).

**0.13.0 (this package):** the full run on the final build (2026-11-11, 67 minutes): **all 52 runs passed**, none rerun. The two new runs are `test_trade_window` and `test_daggers`. The mod was not rebuilt after the run.

**0.12.0:** the full run on the final build (2026-11-10, 64 minutes): **49 of the 50 runs passed.** The one other, `test_chaos`, failed in one step for a reason in the test, brought out by this version's main change: the test stands its two bots among the fighters of the start dungeon while it shakes the network, and since 0.12.0 those fighters fight the joined player in earnest - at the moment bot B was to walk it had just been struck down a second time ("walked 0"). The test now holds the AI of the enemies around it, as the other tests do that are not about fighting, and then passed twice in a row on the same build (25 checks each time). The mod was not rebuilt after the full run. The six new runs are `test_ranged`, `test_deaths`, `test_sight`, `test_ambush`, `test_boss_fight`, and `test_boss_fight` in both mixed-build pairings.

**0.11.0:** the full run on the final build (2026-11-10, 66 minutes): **40 of the 43 runs passed.** The three others (`test_boss_scaling`, `test_party` with four players, `test_difficulty`) failed in one and the same step of the test harness - sending a player 60 m away from an enemy that turned out to stand in the dungeon under the level's start, so that the spots were inside the rock - and not in the mod. The step was corrected, and those three tests and the six others that use it were run again on the same build: all ten passed. What it was is under *Found and fixed while making 0.11.0*, with two earlier full runs of the same evening: one on the build before the lobby's difficulty display was corrected (41 of 43, the two failures in the tests), and one stopped after 12 runs when a controller that a remote-play tool had added to the PC turned out to reach every test copy. Nothing was built between the final run, the reruns and the package: the package's `QDCoop.dll` and `xinput1_3.dll` are byte for byte the ones these tests ran.

A "PASS" below is that run. Checks per test are counted by the tests themselves (every `PASS` line is one check that
looked at the running game).

| Test | What it shows | Result |
|---|---|---|
| `test_two_players` | B walks; A's body of B ends 0.0 units from B; the reverse direction too | PASS |
| `test_loot_world` | shared pickups and world state (collected items, opened things) on both; simultaneous pickup of one item: one copy | PASS |
| `test_combat` | host-driven enemy mirrored on B (AI off on B); the host verified standing 6-7 m back on the floor of the room; a real swing of B claimed and applied on the host; HP equal on both; the enemy targets B; B's hits kill it and the kill reaches B | PASS |
| `test_ranged` | an archer is brought to the players and shoots: every arrow the host tells is shown in the joiner's game and goes when the host's goes; the joiner loses exactly what the host's hits took and nothing by the copies | PASS (10 checks) |
| `test_daggers` | both carry the game's Throwing Axe; the joiner throws at a held enemy: the host's game shows the axe leave that knight and fly at the enemy; the enemy loses what the joiner's own axe took, once, by the joiner's claim, and the copy takes nothing and claims nothing; the copy sticks in the enemy where the thrower's stuck and goes when the thrower's goes; then the host throws and the joiner watches, the same; no copy is left over | PASS (11 checks) |
| `test_deaths` | a shielded skeleton killed in the host's game dies in the joiner's too, though its copy there refuses the blow; the skull that rises from it has one name in both games, is driven by the host, and dies in both when the joiner kills it | PASS (7 checks) |
| `test_sight` | the mod's answer to "does this enemy see the player" against the game's own, for the host's player (range and clear line); an enemy fights the joiner in front of it with the host behind in the same line; it turns to the joiner on its other side; it fights the joiner with the host 100 m away, at its full update rate | PASS (11 checks) |
| `test_ambush` | a fighter lying in wait, the host 30 m away: it sleeps on while the joiner stands in its reach and looks at it (as for one player); the joiner looks away and it wakes in the joiner's game, and in the host's on the joiner's word; it goes for the joiner | PASS (7 checks) |
| `test_boss_fight` | the guardian of the Sword Shrine and two players: the joiner walks in first and the boss wakes in the host's game; the gates lock in both; held "1/2", no damage while held; the host warps in; the boss hurts the joiner in front of it with the host off to the side, then the host; beaten in both games; the host talks to it: 450 experience, story flags, the reward once, and open gates in both games | PASS (15 checks) |
| `test_team` | lethal damage with a teammate around: down, not dead; crawl at 80; no further damage; revive interrupted by walking away; holding Interact revives in 3.0 s at 35%; herb heal shared 60% at 2 m, nothing at 20 m, never revives; wipe -> both continue and respawn; session intact | PASS |
| `test_boss_scaling` | gate holds a (forced) boss with "Waiting for teammates: 1/2", no damage while waiting; warp to group opens it; damage scale 1.65 boss / 1.45 enemy for host hits and client claims; client-first kill reaches the host | PASS |
| `test_drops` | an enemy's drop on both machines: B takes its bag -> one herb each, A's bag removed; both take their own bag at the same moment -> still one herb each (the later claim revoked) | PASS |
| `test_progress` | host plays slot 8, client slot 9; a rest on either side becomes both players' respawn checkpoint; after a wipe both respawn at it; World8/World9 saves on disk; the co-op save's record with schema, checkpoint, players and a backup | PASS |
| `test_hud` | names over teammates; close by no box and no outline around the teammate; status line, "Teammate collected: Dried Herbs", edge marker for a teammate out of view, "YOU ARE DOWN", "DOWNED", "Hold [E] to revive", revive progress, "BotA revived you.", "Waiting for teammates: 1/2" | PASS |
| `test_outline` (8 checks) | a teammate 3 m and 15 m away: no outline; at 27 m it is fading in (there, weaker than at full strength); it follows the body: a rounded shape of many points, not a box; at 40 m it is at full strength, and that is faint (about a third); a downed teammate 12 m away is outlined (a standing one at that distance is not) | PASS |
| `test_anim` (29 checks) | **what a teammate's knight shows of its player.** An attack plays one of that knight's swings, started 0.3-1.0 s into the animation (shortly before the strike) when the button is let go; the next one in a combo is the next swing; holding the attack draws the weapon back with nothing swung yet, and letting go plays the heavy blow from there; the game's own input events for the secondary attack, the ultra attack and a thrown dagger each play theirs; a dash to the right or left is a leap to that side, a dash ahead plays none; a hit plays the flinch; the weapon stays ready after fighting. Running ahead the cycle plays at 1.39x for 400 units/s and the feet on the ground move against the way (traced frame by frame); **walking backwards the knight faces where its player looks and the cycle runs backwards** (no moonwalk); walking sideways it turns 50 degrees into the walk; walking slowly the cycle is slower (0.69x at 200 units/s); standing, it faces where the player looks. A downed player's knight falls and stays down; the one who revives kneels by it; revived, it gets up the way it fell. At a checkpoint (the game's own menu open) the knight is on one knee, and stands when the menu closes. A montage the host's enemy plays is played on the other copy | PASS |
| `test_knights` (8 checks, four copies) | **four players, four knights**, the fourth copy on game 1.01.05: in every game every teammate is the knight they chose (12 views), built from the kit (body, helmet, cloth, weapon; the Silver Knight's shield too); each swings its own weapon's swing (mace, axe, spear and shield, axe); a player changes knight from the co-op menu in the game: everyone sees the new one fully built, the choice is kept in that player's settings, and back again; nobody lost a teammate over it | PASS |
| `test_menu` | menu on the title screen; a mistyped code refused; joining with a code; the client then loads its co-op slot; host menu lists its code and "Warp to BotB"; game input held while the menu is open; warp lands 100 units from the teammate; leave from the menu | PASS |
| `test_chaos` | through the hub's chaos relay at 50, 100 and 150 ms round trip, each with 2% loss, 2% reordering and 0.5% duplicates: movement, shared loot, enemy mirroring, damage claims, downed + revive; a 3 s outage of both directions survived and movement resynchronised | PASS |
| `test_party --players A,B,C` | 3 players: everyone sees everyone, movement on both others, loot exactly once to all three, scale 1.90, gate "1/3" and open, host HUD names both, 2 of 3 down: no wipe, last down: wipe, all respawn, session intact | PASS |
| `test_party --players A,B,C,D` | 4 players, D on game 1.01.05: the 3 joiners start next to the host; everyone sees everyone; movement; loot exactly once to all four; the game's own Shrine boss: boss scale 2.95; gate "1/4" then open; host HUD names all three; 3 of 4 down: no wipe, last down: wipe, all respawn, session intact | PASS |
| `test_perf` | the mod's own time per frame on the game thread, A host and B client in the dungeon, both moving; budget: under 1 ms on average. See "Performance" below | PASS |
| `test_warp` | the mod's warp stops the character: one falling at 392 units/s stands still at the new spot | PASS |
| `test_fault_guard` (8 checks) | three faults made on purpose while the mod first reads the engine are taken as "not ready": it tries again and comes up as usual; a deliberate access violation inside the mod's frame is caught and logged, co-op turns itself off, and the game keeps running in the level | PASS |
| `test_menu_input` | R3 and F8: 100 presses alternate the menu on the host with no miss or double, 20 on the client; View keeps the game's own screen; while the menu is open the game's Jump does nothing, and works again the moment it closes; still right after the pause menu, after resting, after a team wipe and after the client rejoins; with the game's HUD off the menu does not open, and an open menu closes when the HUD goes away | PASS |
| `test_versions` | the version handshake, one copy posing as another build: the same build accepted; a different exe with the same co-op data accepted with a note; a changed game class refused with the class named; a mod speaking only a newer protocol refused naming both versions; a feature only one side has switched off for that session; a build missing a required feature does not even try | PASS |
| `test_difficulty` | presets follow the party (Duo with two players, on both); the host's custom values reach the client and change the game's own data: maximum health +50%, healing 50%, stamina use 50%, stagger 200%, experience; **coins found 200%: three coins found are six, for the finder and for the teammate**; a 10-point hit takes 20 at 200% damage taken; enemy aggression and speed; attack rate 200% halves an enemy type's attack cooldowns; at 200% enemy health a 5-point client hit takes 2.5 on the host; a change during a boss fight waits and then applies for everyone; leaving puts the game's own values back | PASS |
| `test_party_rest` | (rewritten for 0.17.0: see that section) the party rest and the party save, for host and joined player; every follower free to play after it (HUD, real stick input); the enemies back in both games, each once; a player brought by a save has the checkpoint's enemies within seconds; boss fight refused; Unstuck | PASS |
| `test_lan_code` | joining by a six-letter code found on the network: a code nobody uses: not found; a typo: caught; the code typed in lower case with a space: joined; a new code: the old one no longer works; a second host on the same code by force takes another; a code expires and is replaced by itself | PASS |
| `test_title_button` | the title screen's own menu gets a Co-op button right after Play (the game's button widget; the other buttons keep their order); choosing it opens the co-op menu (shown as the Co-op screen; the test drives the list underneath it) without choosing anything, the title's buttons step aside and come back on Back; R3/F8 open the same there; hosting from it opens a lobby and Start loads the co-op slot | PASS |
| `test_coop_screen` (39 checks) | **the Co-op screen.** The Co-op entry opens it with all its parts; the title's buttons and big logo are out of the way; the four knights and the logo are pictured in 3D. The mouse over a control puts the cursor on it; Right walks along the knights; Enter chooses (kept in QDCoop.ini); a controller's D-pad and A do the same through the path a real controller takes; a click chooses; Down and Up go between the knights and the bar under them; moving the cursor and choosing play the game's own menu sounds. A difficulty card sets the preset; the switch lets it follow the party; Custom opens the chosen preset's values, Right raises one, Apply makes it the difficulty. RB/LB step through the sections; a setting changes at once and is kept. With no co-op save yet the first is a new campaign. Open Lobby hosts: the lobby code shows, the main button becomes Start Co-Op, and the difficulty chosen before is the session's; the copy button copies the code (into the test's own clipboard, never the PC's); Direct IP lists the ways in and copies the chosen one; Lobby Settings makes a new code; Back asks before closing the lobby. B opens its own screen: Join Co-Op, Join by Code takes a typed address and joins; both screens show the party of two with names, the host marked and who is ready; the host's difficulty shows on B's screen and can not be changed there; ready, the knights chosen and a difficulty change in the lobby reach the other. Start Co-Op loads both: the host into slot 8, the joiner into slot 9; in the game each is the knight chosen in the lobby; the save's record has its name, the host's knight and level. Back on the title, the save is listed with what is in it and continuing it is what hosting does; Create New Co-Op Save takes the next free one; choosing the first again continues it; the second save is played in slot 10 with a record of its own, and the first is as it was | PASS |
| `test_lobby4` (11 checks, four copies) | **a full lobby**, the fourth copy on game 1.01.05: three join by a typed address from their own screens, each chooses another knight and readies up; **every copy knows every other player's knight, also those chosen before it joined (12 of 12)**; all four screens show the party of four and, with *Match the party's size* on, the preset for four (Quartet), the host's names everyone and marks them ready, a joiner's names the host and the others; the lobby is full (four places taken, nobody to invite); Start Co-Op loads all four (slots 8, 9, 9, 9); in the game everyone is the knight they chose, in all four games (12 views), and the game runs Quartet in all four; four players on every copy | PASS |
| `test_menu_pages` | the party list with pings (host: Kick, client: none); the difficulty page: Right three times turns enemy health up 30 points, nothing changes until Apply, then both games run it; the settings page switches at once and is saved; Kick asks first and then removes the player; on the title screen, Continue shows what it continues, and starting a new campaign asks first, copies the old one to Saves\Backups and starts a new record | PASS |
| `test_lobby` | hosting from the title opens a lobby: the host stays on the title screen (no title Play into a solo save); a friend joins with the code and waits on the title screen; both menus show who is ready; starting before everyone is ready asks first; Ready, then Start: both load, the host slot 8, the friend slot 9; a third player joining after the start loads at once | PASS |
| `test_paste_join` | the host's menu lists its addresses by network adapter (Wi-Fi and a VPN here, no 127.x); a friend joins with "Join with the copied code or address" (an address copied with spaces and a line break around it), leaves, then pastes the address into the code field and joins again. The clipboard is the test's own | PASS |
| `test_join_far` | (extended for 0.17.0: see that section) the host at a checkpoint 187 m from the level's start with enemies around; a friend starting a new game is moved next to the host and stands there, no fall; the friend's game has an ACTOR of every enemy the host has around it within 6 s, driven by the host, none twice and none the host does not have, each where the host has it; the same after the friend's game had taken them away and the friend came back by a warp (made by its own spawners on request, 0 copies) | PASS |
| `test_trade` (28 checks, three copies) | **trading consumables.** A new co-op campaign starts from an empty inventory; by the game's own item data a healing herb may be traded and a weapon may not, and what A can offer lists the herb and no weapon; B, 2-4 m away, is a candidate in range; nothing moves before both confirmed; then A gave three herbs and B got three, **C got nothing (a trade is not shared loot)**, both were told, the game was saved on both sides and no journal entry is left; a weapon can not be offered, and a made-up offer of one is refused by the host; more than owned can not be offered, and a made-up offer of 999 herbs moves nothing; changing an offer takes back the other's confirmation; cancelling leaves both inventories as they were and both are told; the messages of a finished trade sent again change nothing; two clients trade through the host (2 herbs for 1) and the host keeps its own; too far apart: no trade; walking away ends an open trade; a downed player can not trade; a player leaving ends the trade and moves nothing; after leaving and rejoining, and after restarting the game and continuing its co-op save, B still has what it traded for | PASS |
| `test_trade_menu` (13 checks) | a trade done through the co-op menu as a player does it: the Trade page; a teammate too far away is listed with the distance and can not be chosen; the request, the notice "Trade Request Received" with who asks and how to answer; the asked player's menu opens on the request; Right and Left set how many (never more than owned); both see both offers and who confirmed; nothing moves until both confirmed; then the herbs move; the page says how the last trade ended; the game has its controls back | PASS |
| `test_trade_window` (15 checks) | **the trade window.** Once a trade is open the trade page is the window, in both games; every consumable has its row with the game's own picture and name and how many the player carries; Right and Left change the number, RB / LB by ten and never past what is carried; a controller's D-pad changes it too and A on a row gives one more; a list of nine kinds scrolls with the cursor; each side shows the teammate's offer with picture, name and number; one confirmation shows on both sides and nothing has changed hands; a changed offer takes the confirmations back; both confirm and exactly those items change hands and the window closes on "Trade Completed"; B goes back to the menu with the trade still open and Trade brings the window back; Cancel Trade ends it for both with nothing changed | PASS |

Some problems were in the tests themselves, each found because a run failed, and fixed on 2026-11-07. Every test
above passed on the final build after these fixes (`test_hud` and `test_boss_scaling` twice each):

- `test_chaos` teleported the players to fixed offsets from wherever the enemy happened to stand. Sometimes that
  spot was outside the level: a player fell out of it and went down, nobody could revive, and the team wiped. Its
  revive check also passed in that case (it only asked whether B was no longer down, and a wipe ends that too). It
  now places players only where they land and walk, refills both players' health, and counts a revive only when one
  arrived. A second cause showed up once placement was right: the enemy B had just hit attacked A, the reviver,
  every 2.9 s, and taking damage interrupts a 3.0 s revive (by design), so the revive could not finish. The test now
  holds that enemy's AI during the revive step, the way the boss gate holds a boss.
- `test_hud` placed B "in front of" A's camera and expected B on screen. In one run A's camera faced straight down
  (pitch -89, with nothing in the test turning it; earlier runs started level), so B was out of view and the four
  on-screen checks failed. It now turns A's view to B first (`bot.aim`).
- `test_boss_scaling` flagged the boss and moved A next to it before the host had seen B leave. The host checks the
  gate four times a second; seeing both players near the boss once opens the gate for good, so it never held. It
  now moves B away first and waits until the host sees B's body far from the boss.
- While looking at the chaos test: the mod's warps kept the speed a character had. They now stop it (`test_warp`). The game
  has no fall damage (a 2500-unit fall cost nothing), so this was about carried momentum, not health.

## Mixed game builds (`QD_REMAP`: copy D runs game 1.01.05, the others 1.01.03)

The same tests, with the host on one build and the client on the other (the handshake admits them through the
`compat.ini` entry for the player class, the one class that differs):

| Test | 1.01.03 host, 1.01.05 client | 1.01.05 host, 1.01.03 client |
|---|---|---|
| `test_two_players` (movement both ways) | PASS | PASS |
| `test_progress` (co-op slots, shared checkpoint from either side, wipe and respawn there, saves, the save's record) | PASS | PASS |
| `test_team` (down, crawl, revive, shared healing, wipe and respawn) | PASS | PASS |
| `test_hud` (names, no mark close by, notices, downed, revive progress, boss gate count) | PASS | PASS |
| `test_anim` (the knight's animations, see above) | PASS | not run |
| `test_trade` (trading, see above) | PASS | not run |
| `test_coop_screen` (the Co-op screen, lobby, start, saves) | PASS | not run |
| `test_boss_fight` (the Shrine boss from the walk in to the open gates, see above) | PASS | PASS |

`test_party --players A,B,C,D`, `test_knights` and `test_lobby4` above are four-player runs with D on 1.01.05.

## The request's test list, item by item

The request for 0.11.0 listed the tests it wanted. Where each stands: **live** means checked in the running game by
the named test in the final run; **game-free** means checked on the mod's own code over a simulated connection;
**by eye** means looked at in screenshots, with no test asserting it.

| Asked for | Where it stands | By |
|---|---|---|
| *Lobby* | | |
| Create a lobby | live | `test_coop_screen`, `test_lobby` |
| Invite through Steam | **not verified.** On one account (0.10.2; the Steam and network code is unchanged since): hosting announced to Steam, the friends list, a Steam-started join handled. Between two accounts: one try, no connection (see *Steam*) | `test_steam`, not part of the final run |
| Join using a code | live, the code found over one PC's loopback | `test_lan_code`, `test_menu`, `test_lobby` |
| Join using direct IP | live, over 127.0.0.1: typed, pasted, without its port | `test_paste_join`, `test_coop_screen`, `test_lobby4` |
| Connect two, three, four players | live | `test_two_players`; `test_party` with three and with four; `test_knights`, `test_lobby4` |
| Select different knights | live | `test_lobby4`, `test_knights` |
| Choose a save | live | `test_coop_screen` |
| Change difficulty | live | `test_coop_screen`, `test_difficulty`, `test_menu_pages` |
| Start together | live, two players and four | `test_lobby`, `test_coop_screen`, `test_lobby4` |
| *Characters* | | |
| Every knight appears correctly | live for what a test can read: every knight built from all its parts, in every copy's game. How they look: by eye | `test_knights` |
| Character selections synchronise | live | `test_knights`, `test_lobby4` |
| Animations work | live | `test_anim` |
| Weapons attach correctly | live: each knight has its weapon part (the Silver Knight its shield too). Where it sits in the hand: by eye | `test_knights` |
| No T-poses | live in so far as the feet are traced moving through the run cycle and every held pose reports where its animation stands; each pose and attack also by eye in frame sheets | `test_anim` |
| No foot sliding | live, measured: the foot on the ground moves against the way at the body's speed. A little sliding remains (the armour's run cycle is a stylised one) | `test_anim` |
| No floating models | live: a body ends 0.0 units from its player; a joiner moved next to the host stands on ground. Otherwise by eye | `test_two_players`, `test_join_far` |
| No frozen attacks | live: every attack starts its own animation shortly before the strike, and the knight is back in its cycle for the checks that follow. That no single frame hangs: by eye | `test_anim` |
| *Combat* | | |
| Several players attack the same enemy | live: host and joined player hit one enemy | `test_combat`, `test_boss_scaling` |
| Damage synchronises | live | `test_combat` |
| Enemy death synchronises | live, from either side | `test_combat`, `test_boss_scaling` |
| Boss targeting, boss phases | targeting live: the Shrine boss goes after the joined player in front of it and hurts it, then the host; it fights the one it is after wherever the host stands. Phases: **not verified** (this boss has one; no test reached a boss with several) | `test_boss_fight`, `test_sight` |
| Difficulty scaling works | live | `test_difficulty`, `test_boss_scaling` |
| Revive works | live | `test_team`, `test_anim` |
| Nearby healing works | live | `test_team` |
| *Trading* | | |
| The trade window: your offer and the teammate's, item pictures, names and numbers; add, remove, how many; confirm, cancel | live | `test_trade_window` |
| One healing item, several, both ways, a gift | live | `test_trade`, `test_trade_menu` |
| Cancel a trade | live | `test_trade` |
| Change an offer after confirmation | live | `test_trade` |
| Disconnect during a trade | live: a player leaving an open trade. At the moment the items change hands: game-free, every such moment | `test_trade`; `trade_tests` |
| Attempt to trade a weapon | live | `test_trade` |
| Attempt to trade a quest item | game-free (only consumables pass the rule); live only for a weapon | `trade_tests` |
| Attempt to trade more than owned | live | `test_trade` |
| Duplicate confirmation packets | live (a finished trade's messages sent again) and game-free (repeats, replays) | `test_trade`; `trade_tests` |
| Reconnect after a completed trade | live | `test_trade` |
| Save and reload after trading | live: the game restarted and the co-op save continued | `test_trade` |
| Nothing duplicated or lost | live in every step above (inventories counted on all three copies); game-free over 40 seeds of random play | `test_trade`; `trade_tests` |
| *Saves and progression* | | |
| Shared loot collection | live | `test_loot_world`, `test_drops`, `test_party` |
| Shared checkpoint activation | live | `test_progress` |
| Group rest | live | `test_party_rest` |
| Party wipe | live | `test_team`, `test_party`, `test_progress` |
| Boss defeat | live: beaten by the joined player, talked to by the host, dead in both games; experience, story flags, reward and open gates for both | `test_boss_fight` |
| Save and reload | live | `test_progress`, `test_coop_screen`, `test_trade` |
| Player reconnection | live: leaving and rejoining, a 3 s outage. A timed-out player returning to their place: game-free | `test_trade`, `test_menu_input`, `test_chaos`; `net_tests` |
| Progression consistency | live for what is shared: loot, world state, checkpoint | `test_loot_world`, `test_progress` |
| *Controller* | | |
| R3 opens and closes the menu | live through the path a controller's state takes (100 presses); a real gamepad in a person's hands was not part of these runs | `test_menu_input` |
| View keeps its own behaviour | live | `test_menu_input` |
| Trading menu navigation | live: the menu's list, and the trade window with its own keys and a test controller | `test_trade_menu`, `test_trade_window` |
| Lobby navigation, character selection | live: D-pad and A through the controller path, keys, a test mouse | `test_coop_screen` |
| Input focus restores | live | `test_menu_input`, `test_trade_menu` |
| *Outlines* | | |
| No rectangles | live | `test_outline`, `test_hud` |
| None on players near by | live | `test_outline` |
| A subtle silhouette at distance | live: about a third strength at 40 m, a shape of many points | `test_outline` |
| Smooth fade | live at one point of it (27 m: there, and weaker than at full strength); the fade as a whole by eye | `test_outline` |
| Identification colours | by eye (the test reads strength and shape, not colour) | |

## Steam (`tests/live/test_steam.py`, on the owner's Steam account, with the owner's permission)

Not part of `regress.sh`: it uses the Steam account signed in on this PC, so it runs only when the owner says so.
The test copies are started outside Steam (so without the Steam overlay), with the game's Steam app id.

**Steam refuses lobbies for Queen's Domain.** 0.10.0 created a Steam lobby when hosting, and its invites, *Join
game* and Steam codes all pointed at that lobby. The first live try (2026-11-08, owner's account) got `LobbyCreated`
with result 15, *access denied*, which Steam gives when a game is not set up for lobbies (or when the account may
not play the game, which is not the case: the same account runs it). So none of 0.10.0's Steam paths could have
worked. 0.10.1 uses no lobby: the host's Rich Presence `connect` string (`+qdcoop_host <SteamID>`) is what gives
Steam friends *Join Game* and what invites carry (sent from the co-op menu's friend list, which needs no overlay, or
through the overlay's dialog); joining connects to the host over Steam's peer-to-peer messages, and the host accepts
those from its Steam friends only.

One account (A and B both signed in as the owner): 19 checks, all passed (on the 0.10.1 build before the frame and
warp fixes of the same day; the Steam code was not touched by those fixes):

- Steam available in the game, hosting announced; Steam holds our `connect` string (read back from Steam), the app id
  is Queen's Domain's (1799840); neither the SteamID nor the Steam name is in the log;
- the host's menu shows a Steam code and *Invite Steam friends...*; that page lists exactly the online friends (one;
  the list took 0.5 ms to read; names are not printed and no entry was chosen, so no invite was sent) and offers the
  overlay's dialog only when the overlay is on (it was off);
- B started the way Steam starts the game for *Join Game* or an accepted invite (`+qdcoop_host` and A's SteamID on
  the command line): it waited for the title menu, then tried, and refused because the code is its own account's;
  it started no session; A's Steam code typed into B's menu: refused the same way;
- after A leaves the session, Steam no longer has the `connect` string.

Two accounts (not run yet: it needs the second account signed in on another PC with the game and this mod, and the
two accounts being Steam friends): `test_steam.py --invite NAME` hosts on copy A, sends one Steam invite to the
friend called NAME and waits for them to join, start and play in A's world; `test_steam.py --join STEAMCODE` joins
the friend's game the other way round with the Steam code their menu shows.

Found on the way and fixed: when hosting with Steam, the host's own SteamID was written to its log (in the line
naming the session's transports), and a player joining through Steam would have had the host's SteamID in theirs.
Neither is logged now; the test checks the host's and the second copy's logs for the SteamID and the Steam name.

**One try between two accounts did not connect (2026-11-08).** The owner's Steam friend had the mod (0.10.1)
installed and the game running; the host was a test copy on the owner's PC (started outside Steam, as all test
copies are). The invite sent from the host's friends list arrived in the friend's Steam without a way to join, and
the friend's game never reached the host (nothing from them in the host's log). What stopped it is not known: no log
from the friend's PC was to be had, and a test copy is not started by Steam, which may matter for how Steam treats
its invites. So the two-account path stays unverified; the next try should host from the real installation (started
from Steam) and keep both `core.log` files.

**For 0.11.0 the Steam test was not run again.** The Steam and network code is the 0.10.2 code (no line of
`steamlink.*` or `src/core/net` changed), and the Steam client was not running on the test PC during the final
runs. New in 0.11.0 on the Steam side are only the Co-op screen's *Invite via Steam* list and its *Steam's Own
Dialog* button, which call the same three functions as the co-op menu's friends page tested above; the list was
not opened in a test (it would show the owner's friends).

## Found and fixed while making 0.13.0 (2026-11-11)

- **The game takes any thrown projectile for its own player's.** An axe that nobody threw (spawned in front of a
  fighter for the purpose) took 0.01 health off it, and the game told the local player "your enemy was damaged" -
  which this mod would have sent to the host as that player's hit, and the fighter would have turned on a bystander.
  The copy of a teammate's dagger therefore has to hit nothing at all. A projectile looks for what it hits in its own
  tick: with the tick switched off it still flies and stops (its movement part does that), sounds and fades, and the
  fighter noticed nothing - no health lost, no word to its spawner or to the player. Copies have their tick off, and
  carry no numbers in their damage besides.
- **A copy that hits nothing flew on past the enemy.** The thrower's axe sticks in what it hit and stays for four
  and a half seconds (the game hangs it on that actor). The copy, finding nothing, flew past the enemy and lay about
  (seen in the first two-player run). The thrower's game now tells where its dagger stuck, and in which enemy; the
  copy is put there and hung on this game's copy of that enemy. Read off both games afterwards: the copy's blade 0
  units from the thrower's, at the same angles.
- **Two quick presses in the trade list could count as one.** How many of an item are given was counted on from the
  trade's own view, and that changes only when the host has answered: Right, Right within that time both asked for
  "one more than before". The trade window counts on from what was asked for last, and shows it at once.

In the tests:

- A throwable has to be ready before a bot can throw it: a newly equipped one fills in fifteen seconds. The dagger
  test fills it by hand (the charge count the game keeps), and throws by the game's own input event.
- Pictures of a thrown axe were of little use: thrown into sand it is buried (in the thrower's game as well), and
  stuck in a skeleton it is a thin handle among bones. What the test compares is where the copy is and what it is,
  not how it looks.

## Found and fixed while making 0.12.0 (2026-11-10)

All of these were found by letting two test bots meet enemies the way a party does - one ahead, one behind, on
different sides of an enemy, far apart - and reading the game's own values while it happened. In single-player they
can not happen: the game's enemies were written for one player, and "the player", "my target" and "the camera" are
the same thing there.

- **A joined player ahead of the host walked into a dead world.** The level's triggers (a boss's arena, an ambush)
  answer to the game's own player. In the host's game the joiner's body stood 4.5 m from the sleeping guardian of the
  Sword Shrine for eight seconds and nothing woke; it woke within two seconds of the host walking in. Now, in every
  game, the party counts as one player for these triggers. (The first version of this did nothing at all: the names
  of the triggers' events do not exist until the level's own classes are loaded, and the mod looked for them once,
  at the title screen. They are looked for until they are there.)
- **An enemy after a teammate did not see it.** The game's enemies do not attack what they do not see, and the part
  that answers "do I see the player" looks at the game's own player, whatever the enemy is after. The guardian,
  after the joiner 3.6 m in front of it with the host behind the joiner: "no line of sight", for 25 seconds - the
  teammate's body hid the host. One step of the host to the side and it saw again. Which of the game's collision
  channels the sight uses was found by making the joiner's body let one channel through at a time (it is
  Visibility), and that the answers can be written from outside once the part's own updating is switched off by
  switching it off and writing them. The host now answers the question itself for every enemy near the party. How
  the game measures was read off its own answers: with the mod computing the same for the host's player and
  comparing, the first rule (distance in space, height from the feet) disagreed in 0.9% of 160 000 looks; the range
  turned out to be flat and the height taken from the eyes. The line of sight agreed in 99.2% of 10 949 looks when
  drawn to the player's middle, in fewer when a second line to the head was added, so it is drawn to the middle.
- **An enemy after a teammate turned its back to it.** With the sight answered, the guardian struck the joiner once
  and then stood again: no attack could be chosen, because it faced away from its target - it faced the host,
  exactly, wherever the host went. The game hands its turning of an enemy the game's own player. That call passes
  through the mod's hook, and is now handed the player the enemy is after. (Until then an enemy fought a teammate
  only while the host happened to stand in the same direction: the earlier tests, with both bots side by side, never
  showed it.)
- **Enemies near a teammate far from the host hardly moved.** The game saves work on enemies far from its player's
  camera: a fighter next to the joiner, the host 113 m away, had 0.2 s between two updates of its own and did not
  strike in 20 s. An enemy within 45 m of a teammate now runs at its full rate in the host's game; it struck after
  1.6 s.
- **A beaten boss stayed beaten for one player only.** The guardian is not dead when its health is gone: the game
  suspends its death, it kneels, and a player talks to it - the reward comes in that dialogue, and the dialogue's end
  lets it die: 450 experience, the story flag, the arena's gates opening. (Followed step by step in a single-player
  run first.) Each game has its own copy of the beaten boss and one player talks: the other stood in a locked arena.
  And had the other talked too, the second dialogue would have taken the next reward of the row, the one meant for
  the next such boss. The end of the talk is now told to the party, and every game ends its own copy by the boss's
  own function. Several of the game's bosses are built this way (their classes carry the same pieces: the witch,
  the dragon and others); only the guardian was met in a test.
- **An enemy in the ground did not ambush a joined player.** A fighter lying in wait wakes when a player stands
  within its reach and looks away (tried with one player: it slept on for as long as it was looked at). That is
  judged for one player, in that player's game. In a party it woke for the host's player only; and when a joined
  player's own game woke its copy, the copy was put back to sleep to match the host's. Now each game judges its own
  player, and a joined game tells the host, which wakes its enemy and sets it on that player. (Without the last
  part the woken fighter stood up and looked about for the host, 30 m away.)
- **The boss gate woke a sleeping boss's AI.** Opening the gate switched the held boss's AI back on though the boss
  still lay in wait; the gate now leaves a sleeping boss alone until it wakes.
- **A joined game's copy of an enemy shot back on its own** when hit there (its copy of the game's "shot at whoever
  hit me"), and those shots hurt: the joiner lost 51 health to one arrow of the host's. Shots of a copy the host
  drives are removed.
- **An enemy with a shield could not be killed for the joiner**, and **the skull of a dead skeleton was taken for the
  skeleton**: see the table at the top (`test_deaths`).

In the tests:

- The test controller does not reach the game's own screens (the harness hides controllers from the game so that a
  real one on the PC can not steer the bots), so the boss test talks to the beaten boss by calling what the
  dialogue's buttons call, and puts the reward away the same way.
- A bot standing next to a woken boss is dead in fifteen seconds. The fight tests set the bots' health back to full
  while they watch, and count what was lost.

## Found and fixed while making 0.11.0 (2026-11-09)

In the mod:

- **"Start a new co-op campaign" did not start a new one.** The game's "new game" on a slot that has a save keeps
  that save: the new campaign came up with the old character and items. The slot is now cleared with the game's
  own delete after the old save was copied to `Saves\Backups`.
- **The game may keep its saves in a folder per Steam account** (`SaveGames\<id>\`), depending on Steam at the
  time it starts; the mod looked in `SaveGames` only and took an existing co-op save for missing. It now asks the
  game where its saves are.
- **A trade could be undone by closing the game.** The game writes a "suspend" save every two minutes and continues
  from it; a trade completed in between was not in it. A completed trade now makes the game write both saves.
- **The knight swung when the attack button went down; the game swings when it comes up** (holding it charges the
  blow). Seen by holding the button for three seconds and reading the game's own values: the swing, and the charge
  it was given, only appear at the release. The knight now draws its weapon back while the button is held and swings
  on the release.
- **The knight's body faced where its player's camera looked**, whatever way the player walked (the game is first
  person: that is all there is to send), and its legs ran one cycle at one speed. Walking backwards looked like
  running on the spot the wrong way. The body now turns into a sideways walk and steps backwards; the cycle's speed
  follows the player's, set from a frame-by-frame trace of the feet (the armour's run cycle keeps a foot on the
  ground for 0.27 s of each 0.4 s step and moves it 67 units in that time).
- **Every swing played a whole enemy attack**, a second of wind-up included, so a teammate's blow landed long after
  the player's. Each attack now starts shortly before its strike (the moments were read off the animations, frame
  by frame).
- **A downed teammate was the standing knight tipped over.** It now plays the armour's own fall and stays down.
  Getting up plays the fall backwards; the kneeling animation turned out to loop (played backwards it never ends),
  so leaving the knee is a short blend instead.
- **Text lost thin strokes in small sizes** (hyphens vanished: "CO OP"). The game's font is made at one size (50) and
  the canvas shrank its letters from there. Text is now made at the size it is drawn at.
- The game's own "resting" value on the player is never set; what tells that a player is at a checkpoint is its
  menu being open. The kneeling is tied to that.

Found by the full run on the first 0.11.0 build (2026-11-09; stopped after 22 runs, of which 16 had passed and 6 failed), fixed, and run again:

- **Co-op switched itself off at the start of the game, three times in about fifty starts.** The mod's first look
  for the engine's tables came while the game was still setting them up; reading a half-made table faulted, and the
  guard that keeps a fault from crashing the game switched co-op off for that run (`test_hud`, `test_versions` and
  `test_lan_code` each lost a copy to it). That first look now treats such a fault as "not ready yet" and tries
  again half a second later. It could not be made to happen again on demand (0 in 68 further starts, alone, in
  pairs and with every core busy), so the fix is tested by making the first three tries fault on purpose
  (`test_fault_guard`): the mod comes up as usual.
- **A player who joined later did not learn which knights the earlier joiners had chosen** (`test_lobby4`, the first
  time four sat in one lobby): each player told the others their knight when they chose it, and only the host told
  a newcomer again. The last to join knew the host's knight and saw the others as the knight their place in the
  party defaults to. The host now tells a newcomer what everyone already there chose.
- **A joining player's game ended with an engine error half a minute after joining, once** (`test_menu`; the game
  keeps no log, so its message is not known). The mod was building the host's knight - a dozen pieces to load - in
  the very moment it had moved the joiner next to the host, while the game was bringing that place in; an earlier
  version of the mod had crashed the same way when it loaded a teammate's body while a level was still coming in,
  and had a rule against that, which the move next to the host slipped past. A knight is now built only when no
  move is under way or just over and the level has finished bringing its parts in. The run did not fail again
  (`test_menu` passed twice since, alone and in the final run, and every other join next to a host in the final run went through); with one occurrence, that is likely the cause, not proven. A fault or an engine error that comes
  up through the mod's code now names the part of the mod that was running and its call chain in `core.log`.
- Loaded assets are remembered: looking an animation up by its path walked every object in the game (milliseconds)
  each time a teammate swung.

Seen in the screenshots of the full run on what was to be the final build (no check had asked), corrected, and the
full run repeated on the corrected build:

- **A lobby of four showed "Solo, 1 Player" as its difficulty, with *Match the party's size* on.** The session's
  preset follows the players who are in the level, and while a lobby waits on the title screen that is the host
  alone. The game did become Quartet once everyone had loaded in, but the lobby said otherwise. The lobby now shows
  the preset for the party sitting in it, on every player's screen; `test_lobby4` checks that, and that the game
  runs that preset once all four are in the level.
- The words "Lobby Code:" ran into the code itself in a small window; the label now ends before the code at any
  text size.

In the tests:

- The animation test's trace of the feet rounded a frame's length to hundredths of a second (a 60th became 0.02 s,
  a faster frame 0): speeds came out wrong by a sixth and one run divided by zero. Frame lengths are in
  milliseconds now.
- `test_progress` looked where the players were exactly 4 s after their new characters appeared following a wipe.
  The game itself puts a reloaded player at the level's start first and at their checkpoint a few seconds later
  (traced second by second: the host 3.8 s, the joined player 4.3 s after appearing); with the really new characters
  this version's tests start with, the joined player was found at the start, half a second early. The test now
  waits for both to be at the party's checkpoint and to stay there. (A first guess, that the party's checkpoint was
  missing from one of the game's save files, was wrong; the change made on that guess was taken out again.)
- Compiling the mod while the tests ran took the processor from the games (two of the start-up faults above came
  at such moments): nothing is built while a test run is on.

Found by that same full run (four things, all in two tests):

- `test_join_far` read each enemy's place on both games once, and one run read 794 units for one enemy. Traced at
  the bridge's full rate (750 readings per enemy in 40 s, three runs): the joining game shows the host's enemies
  about a tenth of a second late - 0 units for one that stands, 10 to 40 at the median for one that walks or runs,
  up to 250 for an instant while a spider runs at 800 units a second. And an enemy the joining game's own spawner
  has just made on the mod's request stands at its spawn point until the host's next message about it puts it
  where the host has it: 768 units off in one reading, 37 in the next, 50 ms later. The single reading had hit
  such a moment. The test now follows every enemy for six seconds and fails on a gap at the median or one that
  lasts.
- The same test counted the live enemies within 30 m of the host on both games, and one rerun failed with "2
  against 1": an enemy walking across that line is inside on one game and outside on the other for a moment. It
  now compares which enemies they are: none twice, and none the host does not have.
- The same test's search for a far checkpoint sent the host to 29 spots in a row, 2.5 s each, most of them in
  parts of the level not loaded yet. The mod's warp held the character in the air at each, as it is made to, so it
  hung there for over a minute before the first spot held. In 3 of 26 runs the host's character died during
  that search (a team wipe in the log about 30 s into it), and the test had nobody to join. What exactly ended it
  was not caught: six traced repeats all survived. A player's warp is held for 8 s at most, then put back. The
  search now starts with the likeliest spot and lets each try finish (landed, or put back); the test takes 54 s
  instead of 122 s and passed 4 of 4.
- `test_coop_screen` looked for the names "BotA" and "BotB" on the screens. With the fourth copy as the joiner
  (the mixed-build run of this test, new in this regression) the name is "BotD", and two checks failed on screens
  that showed the right names. The test asks the harness for the names now.

Found by the next full run, on the build with the lobby corrected (stopped after 12 runs: 10 passed, 2 failed):

- **A controller that was not the tests' reached every test copy at once.** A remote-play tool was running on the
  test PC that evening and had added a virtual controller for its guest (seen by Windows as controller 1; its
  packet counter stood at 528 changes). XInput gives a controller's state to every program that asks, so whatever
  was pressed on it went to all running copies of the game together. In `test_combat` the host ended 130 m from
  the fight, the enemy stood inert and none of the joined player's eight swings counted (its damage reached the
  host seconds later in the same run); in `test_menu_input` the menu never was as the test's presses had left it
  (100 mismatches in 100 presses). The earlier full run that evening had no such controller connected (its logs
  show none). Test copies now see no system controller at all: with `QDCOOP_TEST_NOPAD=1`, which the harness sets,
  neither the mod nor the game is told about one, and the tests' own virtual controller still works. With the
  foreign controller still connected both tests passed, and the full run was started again from the beginning.
  Players are not affected: without that switch the mod listens to every connected controller, as before.
- `test_combat` put the host near the enemy with a blind teleport and never looked whether it stood there. It now
  waits for the warp to end, checks that the host stands 3 to 10 m from the enemy on the floor of its room, and
  records for every swing how and where the joined player stood.

Found by the third full run, on the final build (the one in this package):

- **The harness's way of sending a player 60 m away assumed ground at the enemy's height.** Three tests
  (`test_boss_scaling`, `test_party` with four, `test_difficulty`) take the enemy nearest the host for their boss
  gate; with the dungeon under the start streamed in by then, that was a fighter 13 m underground, and the eight
  spots 60 m around it are inside the rock: the far player fell at each (traced: 50 m of fall with no floor,
  one angle landing 27 m down), the warp held it in the air for 8 s per spot and put it back, and the gate never
  saw a far player. The helper now goes to known ground first - the level's checkpoints beyond the gate's
  distance, nearest first - and only then to the ring of spots; those three tests, and the six others that use the helper (`test_party` with three, `test_party_rest`, `test_hud`, `test_trade`, `test_trade_menu`, and `test_hud` and `test_trade` with the joiner on the other game build), were run again on the same build: all ten passed (`test_boss_scaling` put its far player beside a checkpoint 115 m from the boss at the first try).
- Also in that helper: it used a plain teleport and gave the character 1.5 s to stand. It uses the mod's warp
  now (held until the spot is loaded in that game, put back after 8 s) and waits for it to end or the character
  to stand.

- A test that made a second co-op save left it chosen in that copy's settings, and the next tests' hosts played in
  slot 10 instead of 8 (`test_progress` failed on it). Every test now starts on the first co-op save.
- The animation test's "run ahead" went off a ledge into the sea in one layout (the start area is a small beach):
  it now first finds a direction with two seconds of ground and walks all its measurements along that.
- The placing helper took "the game put the player back where it was" (over water) for having arrived; it now
  requires the player to stand where it was put.
- The copy button would have written the PC's real clipboard during tests; with the tests' own clipboard set, it
  writes there.
- Loading the mod's core anew while the title screen was up (a developer's step) left the portraits' stage behind,
  lights included, so the next stage was lit twice; a stage now clears what stands where it goes, and the core
  clears its stage when it is unloaded.

## Found and fixed while testing 0.10.1 (2026-11-08)

- **Steam lobbies are refused for this game**, so 0.10.0's Steam play could not work; replaced (see *Steam* above).
- **The mod ran its frame about three times per game frame.** It gets its frame from the game's window-message pump.
  Besides the main loop's pump (once a frame), the engine also peeks at messages while the game thread waits for
  the renderer, several times a frame when the GPU is the bottleneck. Measured in a test copy in a level: 176 mod
  frames a second against 59 game frames (HUD draws). Two consequences:
  - the co-op menu sometimes refused to open: it counts the HUD as on screen if it was drawn within the last two of
    its calls, and with three or more calls per game frame that failed at random. Seen once in seven runs of
    `test_menu_input` (after a team wipe and respawn every R3 press was refused, still 20 s later). Players could
    have hit it whenever the game was GPU-bound;
  - the mod did its frame work up to three times per game frame, and the performance figures of 0.10.0 and earlier
    were per mod call, not per game frame (the "170-180 frames per second" there were mod calls; the game ran at 60).
  The loader now runs the mod once per game frame, on the main loop's pump (and, while the main loop is stuck in a
  blocking load, on another pump at most every 50 ms). Measured after the fix: 59 mod frames a second, 59 HUD draws.
  The menu also counts the HUD as drawn if it was drawn within the last 0.35 s, so a stray extra call can not
  refuse it again.
- **A warp could drop a player out of the level.** This game streams the level in as a player walks; a warp skips
  that, and where the floor was not loaded yet the character fell (to z -18 000, out of the level). The mod's warps
  (the join move, *Warp to teammate*, *Warp to the group at the boss*) now hold the character at the spot while it
  falls through where the floor should be, try where the teammate stands after 3 s, and go back where the player
  was after 8 s, with a notice. Seen live: a client warped to a spot its game had not loaded was held 13 times over
  8 s and then put back standing (that room never loaded; without the hold it fell out of the level).
- **The join move ran during a new character's intro**, which holds the player on the beach; it now waits for the
  intro to end (the game then places the player itself).
- **Enemies missing after a warp.** This game's spawners spawn an enemy only while the player is 50-100 m away and
  can not see the spot (their `MinSpawnDistance`, `MaxSpawnDistance` and a line-of-sight check). In one live state
  a client stood next to the host's enemy and its game had none (the spawner's `CurrentManagedEnemy` empty), so the
  host's enemy had no copy there. A client now asks its own spawner for such an enemy (`Try Spawning Enemy`, the
  visibility check skipped): in that state the copy appeared and was driven by the host 1.5 s later, at the host's
  position. `test_join_far` (a client joining 187 m from the host) passes, but its control run without the requests
  passed too (the client's game spawned those enemies itself there), so it shows the requests do no harm (no enemy
  twice), not that they are needed; the state above was not reproduced on demand.
- Test harness: the host copy's co-op campaign file kept the party checkpoint between tests, and the copies' save
  slot 0 (the tests' throwaway new game) came back from the game's own suspend saves, written while it runs: once a
  copy had fallen out of the level, every later "new game" of that copy started there. That broke `test_combat`,
  `test_drops` and `test_progress` in the first 0.10.1 regression run. Every session now starts with a new campaign
  and an empty slot 0 on its copies. `test_combat` now holds the enemy's AI while the players take their places (as
  `test_chaos` does), so it no longer walks to the host before the client's attack it checks.
- Test harness, from the 0.10.2 run (each found from the game logs the runner now keeps of a failed run):
  `test_menu_input` looked once for the HUD after a team wipe, but *Continue* reloads the level a few seconds after
  the new character appears, and the reload starts it in the resting pose with the HUD hidden: every R3 press was
  then rightly refused ("HUD not drawn, ShowHUD off"; seen in 4 of 12 runs, never when run alone). It now waits for
  the HUD to stay up for 4 s. `test_party_rest` sent the client 60 m from the boss without checking it got there: all
  eight spots were over ground the client's game had not loaded, so it stayed 28 m away, the boss gate saw both
  players and let the boss go, and the boss took the host down (a downed host can not party-rest, so the later steps
  had nothing to check). It now also tries the spots its checkpoints stand on, and the host waits at the checkpoint
  meanwhile. `test_progress` rested by a direct call in a new character's first 3 s in the world, which the mod takes
  as the game's own start checkpoint (a player can not walk to a checkpoint that fast); it now waits that out.

## Found and fixed while testing 0.10.0 (2026-11-08)

- **Players on the same game build were sometimes refused** ("differ in game data co-op relies on: DieUI_C"). The
  engine's names ignore case, and which spelling a name shows depends on which asset loaded first in that launch: the
  death screen's widget `BG` was `bg` in some launches, so the game-data signature changed from launch to launch.
  Signatures now use lower-case names. Six launches of each build then gave the same signature for all 14 classes
  (before: three different values in four launches of one build). The equivalence file was made again with the new
  values.
- **The co-op menu could not be seen on the title screen.** The mod only learned the names of the game events it
  hooks once a level was loaded, so the HUD (which draws the menu) never drew on the title screen; the old menu test
  only checked that the menu was open, not that it was drawn. Fixing that exposed a second bug: with no XInput
  controller active, the R3 fallback asked the engine for a key state while holding the input lock, the engine's
  event came back through the hook, which takes the same lock, and the fault guard switched co-op off for the run.
  The call now happens outside the lock. This would also have hit keyboard-only players in a level.
- **A rest in the first 15 seconds after a level load was not shared.** A time window meant to ignore the checkpoint
  a save file brings back on load also swallowed real rests in that window. This is why the mixed-build progress
  test failed in one direction (the 1.01.05 copy becomes walkable sooner, so the test rested within the window). The
  first reading after a load is now the baseline and every later change counts; the first reading after joining a
  session too (so a joining player's old checkpoint is never sent as a rest).
- **"Start a new co-op campaign" kept the old campaign record** (its id, play time and checkpoint) and made no backup.
  It now asks first, copies the old save and campaign file to `QDCoop\Saves\Backups` and starts a new record.
- Caught in review before the regression run: the first version of the title button looked for the title's widget
  with a walk over every engine object each frame, in levels too (several milliseconds per frame). It now looks only
  on the title screen, holds the widget once found and looks at most twice a second; the death screen lookup and the
  difficulty module's 3-second pass over enemy data no longer walk every object either.
- Hosting from the menu ignored the test copies' loopback-only setting (it could have shown a firewall prompt on the
  test PC); it now follows the setting, as the harness's hosting always did.
- Test harness: three tests ignored the copy mapping in mixed-build runs (names and file paths of the wrong copies);
  others did not wait for the title's intro or for a new code's 0.6 s check. Five tests sent a player "60 m away"
  with a blind teleport, which sometimes ended over nothing: the player fell out of the level (z -19 000) and never
  stood again, so a later step failed (the client's copy of an enemy never came). They now send the player to a spot
  where it is seen standing (`send_far`, `place_near` in `lab.py`). The same happened when a client was teleported
  straight into a room of the dungeon its own game had not streamed in yet (a player walking there loads it on the way):
  the boss test now picks enemies both players can stand next to. A campaign keeps its difficulty, so a test that
  changed it handed it on to the next; every session now starts from the default. The attack-rate check had sampled
  an enemy type with no cooldown (0 halved is 0) and could not fail; it now samples a type running at the changed
  rate, on a cooldown that is not zero.
- **The attack-rate setting had no effect**: the mod looked for an enemy's attack data under the blueprint's
  `EnemyData`, which these enemies leave empty; the data is in the native `NativeData`. Found when the sampled check
  above was made able to fail. Now verified: an enemy type's 2 s cooldown runs at 1 s with attack rate 200%.
- **A new campaign started from the lobby listed no players** (the record was replaced after friends had joined);
  it now lists everyone already in the session.

## Not tested / not verified

New in 0.15.0 (the 0.14.0 and 0.13.0 lists below are unchanged and still true, apart from what 0.15.0 now covers:
the talk with a beaten boss as a shared conversation, started by a joined player):

- **Steam invitations with real Steam** - still: it needs two Steam accounts in two running games. Steam App ID 480
  was not used (it would run the game under another application's identity).
- **The owner's own freezes** (after a party rest; after talking to a beaten boss) were not reproduced; what could be
  found on the way was fixed and is tested (see the 0.15.0 section).
- **The owner's four lost connections**: their cause is not known; it needs the host's log of that day. The session
  now waits 20 s instead of 12.
- **A party wipe where someone does not come back** was not reproduced (two, three and four players).
- **Damage put on the wrong player** was not found in the owner's log nor reproduced.
- **Dodging under lag** was tested with a step made by moving the player, at a simulated round trip of 150 ms, not
  with a person dodging over the internet; the rule is bounded (0.5 s of lag at most, 1.5 m clear).
- **Pings with a real mouse and controller**: the tests ask for a ping through the bridge (as the key does) and hold a test controller's
  R3; no person pinged.
- **Bosses other than the guardian of the Sword Shrine**, boss bars of bosses with phases, **later cutscenes**, and
  **enemy count scaling over a long session with players far apart**.
- **Carrying one character between hosting and joining**: not built (README, *Your co-op character is one per role*).

New in 0.14.0 (the rest of this list is unchanged from 0.13.0 and still true):

- **Steam invitations in the game with real Steam**: reading friends' Rich Presence and the join behind ACCEPT need
  two Steam accounts in two running games. The list, ACCEPT and DECLINE were tested with entries a test put in.
- **A choice between dialogue options** carried from the leader to the others; **conversations between players whose
  saves differ**; the **talk with a beaten boss** as a shared conversation.
- **Cutscene votes** beyond the intro; **teleporter stations** with the party; **bosses with enemy count scaling
  on** (left alone by rule); **enemy count scaling with four players** and its effect on speed in a long session.
- **How things look and sound to a person**: the eight knights and real weapons in motion, teammates' steps at 35%,
  the vote lines on a real screen. The tests check what the game is given; pictures were looked at for the knights,
  three weapons and the Co-op screen.
- **The crash in the middle of a session** (as opposed to the one on quitting) was not reproduced before its cause
  was removed.
- **The party HUD health mismatch** was not reproduced; see the 0.14.0 section.
- **Long sessions** (hours) with all of 0.14.0's parts on were not run; the longest runs are the tests themselves.

- **Steam between two accounts**: the peer-to-peer connection to a friend, an invite being accepted, *Join Game* from
  the friends list, the host turning away someone who is not a Steam friend. Everything Steam-side ran on one account;
  one try between two accounts did not connect (see *Steam* above). The Co-op screen's *Invite via Steam* list was
  not opened in a test (it would need Steam running for the test copy and would list the owner's friends).
- **A real person at the Co-op screen.** The tests put a test mouse where the pointer would be (the same
  hit-testing), press a test controller through the path a real controller's state takes, and send the game's own
  click event to the title's Co-op button. A real pointer moving and clicking, a real gamepad, and how the screen
  feels were not tried. The screen was looked at in screenshots at 1920x1080, 1600x900, 1280x720 and 960x540, and
  (0.12.0) in the shape of an ultrawide display (21:9, at 1720x720: the block stays 16:9 in the middle and the
  backdrop fills the sides) and at 16:10 (1152x720: the block is fitted to the width, with bands above and below).
  The pixel sizes of 1440p and 4K were not tried; their shape is that of 1080p.
- **How the animations look in motion.** The tests check what is played, when, how fast and that the feet move the
  right way; frame sheets of each pose and attack were looked at. Nobody watched a teammate play for an evening.
  The knight's run cycle is a stylised one whose foot never quite stands still; a little sliding remains, as on the
  game's own knights.
- **The knights' looks at the game's higher graphics settings**: the test copies run at the lowest.
- **A trade cut off at its critical moment in the real game.** What happens when a game closes or a connection
  drops between the two confirmations and the items changing hands (the journal, settling on the next meeting, a
  save rolled back) is tested in the game-free suite over a simulated connection, with every such moment tried. In
  the real game the tests cover a player leaving during an open trade, repeated messages, and restarting after a
  completed trade; they do not cut a real connection at that moment. Trading a key item or during a boss fight is
  refused by the rules (`trade_tests`, and the game's item data for a weapon in `test_trade`), not tried live.
- **Flight on the holy sword** (late in the game): a flying player is shown as the knight in the air; no test player
  got that far.
- **A thrown dagger in motion, and the other 23 throwables.** `test_daggers` throws the game's Throwing Axe and
  compares where the copy is, what it is and when it goes with the thrower's own (the blade of a stuck copy was 0
  units from the thrower's, at the same angles). Nobody watched one fly: a copy does not spin in the air (the game
  turns a thrown axe in the tick a copy has switched off). A grenade, a ring of fire, a stone block and the other
  stranger kinds are shown by the same rule and were not tried.
- **The trade window with a mouse**: it is not used there (keys and controller, as in the co-op menu in a level). A
  person at the window: the tests press the window's own keys by name and, for one step, a test controller.
- **Other bosses than the Sword Shrine's guardian, and bosses with several phases.** One boss fight was played
  through, by two test bots (`test_boss_fight`). The bots talk to the beaten boss by calling what the dialogue's
  buttons call (the test controller does not reach the game's own screens). Two players talking to a beaten boss at
  the same moment was not tried: each would take a reward in their own dialogue (see the README).
- **What an enemy sees of a joined player behind walls.** The mod's answer about sight was compared with the game's
  own for the host's player only (the game has no answer for anyone else): 10 949 looks from 217 places among the
  ruins' walls and in the open, 99.2% the same, and again in every run of `test_sight`. For a joined player the
  same code answers; nobody walked a joined player round a corner and watched.
- **A person playing a fight.** Bots stand still and are hit; a fight with players moving, blocking paths and
  running from a boss was not played.
- **Other languages**, game builds other than 1.01.03 and 1.01.05, other PCs, a real internet connection (the chaos
  relay simulates one).
- **Short join codes between two PCs**: the lookup was tested with copies on one PC over 127.0.0.1. The broadcast
  that finds a host on a real LAN is built and its target list checked, but no packet crossed a real network.
- **Not in this version**: Steam profile pictures; typed names for co-op saves; a picture of the place for a save
  (the list shows the knight it was played as); a separate stagger value for bosses (the game has one for all
  enemies); the player's own weapon in a teammate's knight's hand (a knight holds its own); item-use, interaction
  and weapon-change animations (the armour has none to play).

## Stability

A crash about 2-3 seconds after the level loads was seen in the test copies. It is inside the game's own code (no
mod code on the stack): engine code reads an object that has already been destroyed. Rates from a soak that starts
a new game and stays in the level for 20 s:

| Build | Loads | Crashes |
|---|---|---|
| ProcessEvent hook on all 1971 vtables (earlier builds) | 90 | 9 |
| ProcessEvent hooks off (diagnostic switch) | 80 | 9 (0 of the first 20 alone; 9 of 60 while another soak and tests ran) |
| Release build (hook on the 10 vtables the mod needs), while another soak ran | 40 | 3 |
| Release build, bots wait for the title screen to settle (3 s) before starting a game | 40 | 0 |
| The same, two soaks at once on copies C and D | 60 | 0 |

It happened with the mod's hooks switched off too, at the same rate, so the hook was not its cause. What changed the
rate was the test bots: they pressed the title screen's buttons as soon as it appeared, and doing that within about
3 seconds also raised an engine exception (0x4000) in another experiment. Once the bots waited 3 s first, no crash
happened in 100 loads, including 60 with two soaks running at once, the condition that crashed most before. At the
earlier rate (about 1 in 9) that would be very unlikely by chance, so the early start is very likely what set the
crash up: the title screen was still being set up when the level load began. The mod's own title actions (hosting or
joining from the co-op menu) wait for the same settled state. A person pressing New Game within 3 s of the title
screen appearing might still hit it, with or without the mod; that was not measured.

## Performance (`test_perf`)

The mod's own time per frame on the game thread (its frame work; the HUD drawing is listed separately), over the
last 600 frames, with the two copies sharing one PC (the frame rate is therefore not what a player sees):

| Copy | Average | Worst frame | HUD drawing | Biggest part |
|---|---|---|---|---|
| A, host (0.9.0) | 114 us | 869 us | 35 us | players 45 us, enemies 43 us per frame |
| B, client (0.9.0) | 261 us | 1076 us | 30 us | applying the host's 65 enemies 183 us per frame |
| A, host (0.10.0) | 160 us | 738 us | 28 us + party HUD 28 us | players 56 us, enemies 46 us per frame |
| B, client (0.10.0) | 334 us | 1200 us | 33 us + party HUD 28 us | applying the host's enemies 195 us per frame |
| A, host (0.10.2, per game frame) | 288 us | 1026 us | 86 us + party HUD 39 us | enemies 115 us, players 82 us |
| B, client (0.10.2, per game frame) | 598 us | 1487 us | 99 us + party HUD 41 us | applying the host's enemies 341 us |
| A, host (0.11.0, per game frame) | 336 us | 1136 us | 108 us + party HUD 46 us | enemies 143 us, players 101 us |
| B, client (0.11.0, per game frame) | 616 us | 1101 us | 113 us + party HUD 47 us | applying the host's enemies 399 us |
| A, host (0.12.0, per game frame) | 396 us | 1383 us | 100 us + party HUD 43 us | enemies 175 us (of it telling them and their sight 107 us), players 77 us |
| B, client (0.12.0, per game frame) | 623 us | 1810 us | 113 us + party HUD 46 us | applying the host's enemies 369 us |
| A, host (0.13.0, per game frame) | 396 us | 1333 us | 102 us + party HUD 44 us | enemies 173 us (of it telling them and their sight 106 us), players 98 us |
| B, client (0.13.0, per game frame) | 644 us | 2149 us | 117 us + party HUD 46 us | applying the host's enemies 386 us |

0.10.0 adds the party HUD (28 us), the short-code listener (5 us on the host) and the title screen's button (2 us,
nothing in a level).

**Correction (found while testing 0.10.1):** the 0.9.0 and 0.10.0 rows are per call of the mod's frame, and those
builds called it about three times per game frame (see *Found and fixed while testing 0.10.1*); the "170-180 frames
per second" measured then were those calls, with the game at about 60. Per game frame the mod's work was therefore
about three times their figures, the HUD drawing's included (they were all divided by the calls: 28 us then is the
86 us now). From 0.10.1 the mod runs once per
game frame: the 0.10.2 rows are per game frame (the game at 59 frames per second), and both copies stay under the
1 ms budget on average; single frames reach 1.0 ms on the host and 1.5 ms on the client.

Found and fixed on the way: the 2-second enemy scan walked all ~500 000 engine objects in one frame (spikes of about
10 ms); it now walks 15 000 per frame. Name lookups in the mod's reflection layer re-read the engine's newest name
block (up to 128 KB) whenever the game had added a name; they now read only new entries and only on a miss. The
client no longer moves enemies that stand still on the host (84% of moves skipped in this test) and writes their
state through handles resolved once.

0.11.0 adds per teammate in view: the knight's pose and cycle speed (in "players"), and, for a teammate further than
20 m, its outline (15 joints projected and a line drawn around them, in "hud"). Against 0.10.2 the host's average went from 288 to 336 us and the client's from 598 to 616 us (on the host: players 82 to 101 us, HUD drawing 86 to 108 us). Both stay under the 1 ms budget on average; single frames reach 1.1 ms on either copy. Looking an animation up by its path cost milliseconds per swing before loaded assets were remembered (see *Found and fixed*); that is in these numbers already.

0.12.0 adds on the host, ten times a second for every enemy near the party: what it sees of each player (a distance check, and a line trace for the players within its range), whom it turns to and whether it runs at its full rate - this is in "telling them and their sight", which went from 73 to 107 us per frame - and the telling of projectiles (29 us on the host, 28 us on the client). Against 0.11.0 the host's average went from 336 to 396 us and the client's from 616 to 623 us. Both stay under the 1 ms budget on average; single frames reach 1.4 ms on the host and 1.8 ms on the client. (What the game itself spends on enemies it now keeps at their full rate near a joined player is the game's own work and not in these figures.)

0.13.0 adds the watch for what the local player throws (the game's list of dagger actors is looked at once a frame; with nothing thrown it is empty): the "projectiles" part, which holds it, went from 29 to 40 us per frame on the host and from 28 to 39 us on the client. The trade window draws only while a trade is open. The host's average is 396 us as before, the client's 644 us (623 in 0.12.0's run; the difference is within what two runs of the same build give). Single frames reached 1.3 ms on the host and 2.1 ms on the client.

The Co-op screen runs on the title screen only: one copy on the title screen at 1280x720 with the screen open, 600 frames: drawing it (panels, text, the four knights' and the logo's pictures) takes 472 us per frame on average (worst frame 2.2 ms), reading mouse, keys and controller 32 us, the pictures' stage 65 us (and one frame of 10 ms when the four knights are built), the rest under 25 us: about 0.6 ms per frame, on the title screen only.

## Installer (`py -3 -I tests/installer_test.py dist/QueensDomainCoop-<version>`)

Runs the built package's `install.ps1` and `uninstall.ps1` against separate test folders (one holding a copy of the
game exe and a stand-in `xinput1_3.dll` of "another mod"), never against the real installation, with no game
running (the installer refuses while one runs). 15 checks, all passed on the 0.10.0 package:

- install: our loader in place, the other mod's file kept as `xinput1_3.dll.qdcoop-backup`, core, settings,
  compatibility data (`compat.ini`) and manifest written; the installer names the game version it found;
- install again (an update): the backup and the user's edited `QDCoop.ini` are kept;
- uninstall: the other mod's file is back, no backup left behind, the core removed, settings kept;
  `-RemoveSettings` removes the `QDCoop` folder too;
- the game exe is unchanged throughout (SHA-256);
- another game build (a copy of the exe with another time stamp) installs, with a note that it was not tested (the
  mod checks the game when it starts); the installer points out a package unpacked inside the game folder, and a
  `version.txt` that the 0.9.0 package overwrote, with how Steam restores it; that copy uninstalls cleanly.

The package's `QDCoop.dll` and `xinput1_3.dll` are byte for byte the ones the final live tests ran (SHA-256 checked).
0.10.2: all 15 checks passed on the 0.10.2 package itself (its installer scripts are byte for byte those of 0.10.0).
An earlier run of the installer test found a bug (an update rewrote the manifest without the earlier backup, so
uninstall did not put the other mod's file back); fixed then.
0.11.0: all 15 checks passed on the 0.11.0 package itself (its installer scripts are byte for byte those of 0.10.2), and its two DLLs have the SHA-256 of the ones the final live tests ran.

0.14.0: all 15 checks passed on the 0.14.0 package itself (the installer scripts are unchanged since 0.10.2), and its
two DLLs have the SHA-256 of the ones the final live run used (`QDCoop.dll` `895ea6f7c62bb50f...`, `xinput1_3.dll`
`0e4b2f6ff2757901...`; `SHA256SUMS.txt` in the package has them in full).
