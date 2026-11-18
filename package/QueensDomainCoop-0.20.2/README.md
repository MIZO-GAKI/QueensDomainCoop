# Queen's Domain — online co-op for 1 to 4 players

A mod that lets up to four players play Queen's Domain together: one player hosts, friends join by Steam invite or
a join code, and everyone plays the host's world as a knight of their own choosing.

Made for the Steam version of Queen's Domain (Unreal Engine 4.27). Tested on game versions 1.01.03, 1.01.05
(the update of 2026-11-07), 1.01.06a (the update of 2026-11-12) and 1.01.07 (the update of 2026-11-14; this version
of the mod on the last two). Other builds install too: the mod checks the game every time it starts and switches off
any part that does not fit, with a note in its log (see *Game versions* below).

This is version 0.20.2. `TESTING.md` says what was tested, how, and what was not; `SYNC_AUDIT.md` says, event by
event, who decides what in a session.

**New in 0.20.2** (plays with 0.20.1; give it to everyone - each player's own screen is what changes):

The rest of what still showed a teammate's hit to the others, found by going through the whole mod:

- **The party HUD** no longer shakes a teammate's row, nor flashes their name, when they are hit. Their bar simply
  shows the health they have; your own row still reacts to your own hits.
- **Fire, poison and the other effects** an enemy puts on a teammate no longer show on your screen: the effect's
  full-screen overlay, its loop and its "poisoned" sound used to come up for a moment in the host's game (until the
  mod took the effect off the teammate's body there). The teammate still gets the effect in their own game.
- **A teammate reviving you** who is hit starts the revive over as before, but their knight stays kneeling: it used
  to drop out of the kneel for a moment and kneel again - the hit shown to you.
- **A blow aimed at the teammate standing right next to you** (within about 1.5 m) is theirs alone, as before - and
  now you do not get its shake, red flash, sound or a flicker of your health bar either (the host could, until now).
- Fixed: after a level was loaded anew (a team wipe, the game's own return to the title) the mod could take a new
  character or enemy for a teammate's body (it kept the old body's address); and a player's hit whose loss came in
  just after a long stall of the game could still be told to the teammate as an enemy's.

**New in 0.20.1** (everyone who plays together needs 0.20.1: it does not play with 0.20.0 or 0.19.0 and says so when
they meet):

- **Your knight does not flinch for your teammates when you are hit.** Nothing of a hit shows on anyone's screen but
  the hit player's own any more (0.20.0 still showed the flinch).
- 0.20.0 said it would not play with 0.19.0; it did - their messages were the same. 0.20.1 refuses both: a game of
  0.19.0 or 0.20.0 in the party would still pass the host's blows on, or flinch a knight.

**New in 0.20.0** (it played with 0.19.0 - it should not have: see 0.20.1):

- **No friendly fire, of any kind.** Players never hurt each other: not with a swing, the secondary attack (L2), the
  ultra, a thrown or shot weapon, nor with what a hit sets burning or poisons. Until now the host's secondary attack
  could hurt a teammate: where its blow did not land inside the swing the mod watched, the host's game took the
  teammate's loss for an enemy's hit "(most likely)" and passed it on. The *Friendly fire* switch on the difficulty
  page is gone (it was off unless the host turned it on).
- **A hit shows only on the screen of the player who was hit.** In your teammates' games your character is one of
  the game's own player characters, and their game answered a hit on it as on its own player: the damage camera
  shake, the red at the screen's edges and the "hurt" sound played for them when you were hit, and for you when they
  were. Now you see and hear your own hits only (and feel them: the controller's rumble was already yours alone);
  your teammates still saw your knight flinch (0.20.1 takes that away too).

**New in 0.19.0** (everyone who plays together needs 0.19.0: it does not play with 0.18.0 and says so when they
meet):

- **A friend who joins later catches up with the host.** Until now a friend who joined in the middle of the game
  began with nothing of what the host had - the weapons and items the host had found were gone from the world for
  everyone, and level, weapon levels and coins were each player's own. Now, a few seconds after a friend's game is
  in the level, it is brought up to the host's character, with the game's own functions, and saved:
  - **every item** the host has, up to the host's count - weapons (the one in hand too), gear, key items,
    upgrades, throwables, consumables, treasure - and **the host's coins**;
  - **the host's experience**, so the same **level** (the game levels the character up as it does for kills);
  - **each weapon's experience**, so the same **weapon levels**, for every weapon the friend has.
  The friend sees *Caught up with <host>: 4 items, 750 coins, level 1 -> 9, 2 weapons levelled*. Nothing is ever
  taken away: what the friend has more of stays theirs.
- **A friend who has played the campaign before** and comes back gets what the party **found** while they were
  away - every item and coin found, once - and is brought up to the host's level and weapon levels. Not what the
  host bought, sold or traded, and not what the friend spent or used up themselves: coins spent at the shop do not
  come back by leaving and joining again. (An ordinary consumable picked up from the world while they were away is
  not given either: it is still lying in their own world, as co-op's rule has it - each player takes their own.)
- The first time a friend who played a campaign with an earlier version joins it with 0.19.0, the host has no
  record of them yet: they are brought up to the host's items and coins like a new friend, once.
- Only into that campaign's own character: a friend who joins from inside another co-op save gets nothing and is
  told to join from the title screen.

**New in 0.18.0** (everyone who plays together needs 0.18.0: it does not play with 0.17.0 and says so when they
meet):

**This build is a preview.** Its own test passes (three games, below), but in the full run two other tests failed
for a reason that is not found yet: the host's game seems to have its enemies at slightly other times than before
(`TESTING.md`, "0.18.0", has what is known). 0.17.0 is the last version whose full run was clean.

- **Kills are the party's, also when the party is split up.** In the game an enemy that was killed stays away for
  twenty minutes, or until a rest; the game writes that on the enemy's spawner. Until 0.17.0 only the games that had
  that enemy at that moment were told of its death. What the host killed while a teammate was far away was alive
  again in that teammate's game when they came by - for that player only; what a joined player killed alone, far
  from the host, was alive again in the host's game; and a friend who joined later had every enemy the party had
  killed. Now the game in which an enemy is killed tells the others for how long it stays away, and every game
  keeps it away for as long; a player who joins, or comes into the level, later is told what is killed there; a
  rest brings everything back for everyone, as before. Measured with three games: the host's kill reached a
  teammate 160 m away within seconds (both games: twenty minutes, a second apart), a joined player's lone kill
  reached the host the same way, a player who joined afterwards had neither enemy - the two their game had made at
  its start were taken away - and after a party rest both were alive in all three games, each once.
- Not for a boss, a follower or an enemy a script calls up, nor for the extra enemies of a larger party: those are
  as before.

**New in 0.17.0** (everyone who plays together needs 0.17.0: it does not play with 0.16.0 and says so when they
meet). It answers what the owner's games with 0.16.0 showed on 2026-11-15:

- **A party rest no longer takes your HUD and your controls away.** In the game a rest is a step inside the
  checkpoint's menu: the menu opens (the game puts your HUD away for it), you choose Rest, and leaving the menu gives
  the HUD and the controls back. Until 0.16.0 the mod rested every teammate who was brought by calling the
  checkpoint's rest directly, with no menu: when that rest ended the game put the HUD away for a menu that was not
  there, and nothing ever brought it back - no HUD, and the game took no input, after every party rest ("when my
  friend rest i got something like freeze or stuck can't move or do anything and no hud"). Now a teammate rests the
  way a player does: their own game opens the checkpoint's menu, chooses Rest, waits for the rest to end and leaves
  the menu.
- **Rest always brings the whole party, whoever rests.** There is no setting for it any more. Every player is set
  down at that checkpoint and rests with their own game, so the enemies come back in every game - the host's, which
  are the party's, among them. A teammate in a fight is brought too (the rest ends the fight: its enemies come back
  as they were).
- **Save always brings the whole party too.** Everyone is set down at the checkpoint and their game is saved there.
  Nobody rests for a save: a save brings no enemy back in the game, and none here.
- Waited for, up to 75 seconds, because the game holds you by right: a conversation, a cutscene, one of the game's
  own screens, a rest of your own, a journey. Refused, with words, only during a boss fight. A teammate who is down
  is brought (and saved) and stays down. Two players who choose Rest at one checkpoint within seconds are one party
  rest; at two checkpoints, the first is the party's.
- **"Unstuck" gives the HUD back too** (the co-op menu, F8 or View held): it now undoes everything a rest or a
  checkpoint menu can leave behind, with the game's own functions.
- **Enemies the host has alive again are no longer unseen in a joined game.** When the host's game brought enemies
  back that a joined game still had as corpses, they fought on in the host's game and could neither be seen nor hit
  in the joined one. The joined game now replaces the corpse.
- **A player set down next to the others sees the enemies there at once.** The game makes every enemy of a level
  when the level starts, takes those far from a player away again, and makes none closer than 50 m to that player.
  A friend who was moved next to the host after joining - or brought by a party rest or save - could arrive just
  after their game had taken the enemies there away: none of them was to be seen in that player's game for 17
  seconds (nor could they hurt that player in that time), until the mod's copies came. That player's game now asks
  its own spawners at once, the nearest first: measured, the enemies around a far checkpoint were there 0.1 s after
  the player stood, and the 33 around the first checkpoint 3.3 s after a party save - the game's own enemies, not
  copies, each once. A boss, a follower and an enemy a script calls up stay with the copies, as before.
- The settings *Regroup party on checkpoint rest* and *Regroup on Save too* are gone. Their lines in an older
  `QDCoop.ini` are simply not read any more.

**New in 0.16.0** (everyone who plays together needs 0.16.0: it does not play with 0.15.x and says so when they
meet). It answers what went wrong in the owner's games with 0.15.1, read from their log:

- **Every co-op save is a campaign of its own, for every player.** Until now a player who joined had one co-op
  character for every host's save: a new campaign began with the old campaign's items. Now each campaign has an id,
  and a joining player has one character **per campaign** (its own save slot on their PC, slots 20 and up; the book
  is `QDCoop\Saves\characters.json`). A new campaign starts with the game's starting items; going back to an older
  campaign brings back exactly that campaign's character. The old joined character (slot 9) is never loaded or
  changed again: it is copied once into a campaign whose record says you played it before 0.16.0.
- **Rewards are per campaign.** What the party is owed (important weapons, daggers, keys, quest rewards) is kept per
  campaign; a player who was away gets it once when they come back - in that campaign only. A character that was
  never saved (no rest) and is begun again is owed the campaign's important items again.
- **Delete Co-op Save** on the Co-op screen's save panel (and in the title's co-op menu): asks twice, deletes only
  the chosen co-op save - its game files, its record and its reward ledger - after copying all of it to
  `QDCoop\Saves\Backups`. Never a solo save, never another campaign, never while a lobby or session is open.
- **The part of the map your game shows follows you when the mod moves you.** The game shows a part of its map
  according to where you walked. A player the mod moved - a warp to a teammate, a party rest, joining next to the
  host - stood in the right place while their game still showed another part: enemies alive for one player and
  dead or missing for another, enemies that hit you unseen, a party rest that left a player frozen in a place that
  was not there. The moved player's game now shows what the teammate's game shows first, and only then is the player
  set down; if the place can not be shown or has no floor, the player is put back where they were.
- **Nobody stays frozen after a rest.** A party rest waits for the levels, rests each player with the game's own
  rest, and a watch gives the controls back if the game has not done so after 12 seconds - also with the co-op menu
  open. A teammate already at the checkpoint rests where they stand. The co-op menu has **Unstuck: give my controls
  back** for anything else.
- **Fire and poison end.** A teammate's burning or poisoned body no longer keeps its fire, its screen overlay and
  its looping sound in your game for good: the effect lives on the character of the player it hit, in that player's
  own game, and ends there by the game's own rules. The party's health bars show who is burning or poisoned.
- **One swing, one victim.** An enemy's blow aimed at one player no longer also hurts the teammate standing in the
  same spot (`[Combat] SingleTargetSwings`). Wide attacks hit everyone they reach, as before.
- **Controller: hold View / Select for 0.6 s to open and close the co-op menu; R3 (the right stick's click) pings
  and does nothing else.** A short press of View stays the game's own (its Status screen). F8 still opens the menu.
- **The party HUD is at the centre-left** of the screen (`[PartyHUD] Position=CenterLeft`; `TopLeft` is the old
  place), with your own row first.
- **A regular hitch is gone.** Up to 0.15.1 the mod looked through every object of the game every ten seconds, for
  as long as the game ran, and the game stood still while it did (a fraction of a second; more than a second on a
  slow PC). It now does that once, when the game starts.
- **A crash on slow PCs is fixed.** The mod could start its work at a moment when the game thread was waiting
  inside the engine (in the middle of a garbage collection); making an enemy copy or a teammate's body right then
  ended the game ("Illegal call to StaticFindObjectFast() ..."). The mod now works only between the game's frames.
- **Steam invitations show your friend's Steam picture** (their initial until Steam has it on your PC).
- **A cutscene vote waits for a slow PC.** A player whose game needs a while between entering the level and starting
  its intro is waited for (25 seconds, was 8; a vote still never waits more than 30 in all): until now the others
  could skip "all 2 voted" with three in the session, and that player sat through the intro alone.
- A team wipe that did not take in one game is carried out there; a member who went to the title screen by the
  game's own menu leaves the session; while a vote is open its Yes and No are the co-op menu's first entries; a
  player who joins is moved next to the host again if the game puts their new character back at the level's start.

**New in 0.15.1** (0.15.0 with one fix; everyone who plays together needs 0.15.1): made for **game version 1.01.06a**,
the Steam update of 2026-11-12. That update added two keys of its own (compass, HUD) and with them renumbered the
game's Interact key events: on 1.01.06a, 0.15.0 no longer recognised Interact - a downed player could still interact,
and a talk did not wait for the party ("Waiting for Teammates"). The mod now finds the game's key events by their
action's name, whatever the build numbers them. Everything else of 0.15.0 is unchanged.
**Everyone needs the same game update**: 1.01.06a changed the game's player and enemy data, so it can not play
together with 1.01.05 or 1.01.03 - the mod says so when they meet. Steam updates the game by itself.

**New in 0.15.0** (everyone who plays together needs 0.15.0: it does not play with 0.14.x and says so when they meet).
It answers what went wrong in the owner's own games, read from their logs:

- **Enemy count scaling no longer floods the level.** For three players it made 520 extra enemies in 13 minutes,
  the same one up to twelve times; each enemy now gets its extra once until the enemies come back by right (a rest,
  a level entered), and only near players who stay where they are.
- **No more invisible enemies.** A joined game that has no copy of an enemy the host fights asks the host what it
  is and makes the copy (or lets its own spawner make it); until then that enemy's hits are not taken. An enemy that
  died first in a joined game while it lives on in the host's is made again there.
- **Dodging counts under lag.** A hit the host's enemy lands on your teammate-body in the host's game while you had
  already stepped clearly out of reach on your own screen is not taken (bounded: half a second of lag at most).
- **Boss health bars for everyone**, kept to the boss's real health in every game; the talk with a beaten boss is
  shared like any other conversation.
- **Ending the session is a party vote**: anyone may ask, it ends only when everyone votes yes, and **nothing is
  saved by the mod when a session ends** - save your progress first (everyone is reminded).
- **A party rest can no longer leave anyone stuck**, and Rest then Save at one checkpoint moves nobody twice.
- **The finder of a shared item keeps it** through a team wipe or a crash (it is saved before it counts as given).
- **Every weapon shows in a teammate's hand** (37 of the game's 106 weapons were invisible).
- **Pings**: the middle mouse button (or R3 held on a controller) marks a place, an enemy or an item for the party.
- **A cutscene vote waits for a teammate who is still loading** the level (after a team wipe every game loads it
  again and the intro plays in each as it finishes): at most 30 seconds. The owner's games had voted "all 2" with
  three players in the session.
- A connection that stalls is given 20 seconds (was 12) before a player counts as gone, and the ping times shown on
  the Co-op screen and in the co-op menu are current (they stayed at 100 ms).

**In 0.14.0** (0.14.0 and 0.15.0 do not play together):

- Two crashes fixed (a game that crashed some minutes into a session, and one on quitting).
- Items: joined players can pick things up; ordinary consumables are the finder's own, important items are given to
  everyone - also to a player who was away, when they come back.
- Trading shows what you give and get; friendly fire is off (the host can turn it on); a downed player stays put;
  a healing item used at full health heals a hurt teammate next to you.
- Any player's rest brings the party; the host's *End the session for everyone* takes every player back to the main
  menu, saved.
- A player who joins with a new character is set down with the host wherever the host stands (one could fall out
  of the level when the host stood on a ledge deep in it).
- The party travels together (the shop and back, checkpoints), talks to people together, and skips a cutscene only
  when everyone votes for it.
- More enemies for a party of three or four (the host can turn it off or set the bonus).
- Eight knights; teammates hold the weapon they really use; teammates' steps are much quieter.
- Steam invitations inside the game: friends who host appear in a list, with *Accept* and *Decline*.

## Install

1. Close the game.
2. Unzip the package anywhere **except the game folder** (for example your Downloads) and double-click
   `Install.cmd`. It finds the game in your Steam libraries. If it does not, open PowerShell in the package folder and
   run `.\install.ps1 -GameDir "D:\SteamLibrary\steamapps\common\QueensDomain"`.
3. Start the game from Steam as usual.

The installer adds two things next to the game exe (`QueensDomain\Binaries\Win64\`): `xinput1_3.dll` (a small
loader) and the `QDCoop` folder. It changes and deletes nothing of the game. If another mod already uses
`xinput1_3.dll`, that file is kept and put back on uninstall. To remove the mod, run `Uninstall.cmd`.

To switch the mod off without uninstalling, create an empty file named `disabled` in the `QDCoop` folder.

Everyone who plays together needs the same version of this mod.

## Play

### The Co-op screen

On the title screen choose **Co-op** (right under Play). The Co-op screen opens; the title's own buttons step aside
until you go back.

Move with the D-pad, the left stick, the arrow keys (or W A S D) or the mouse; choose with **A**, **Enter** or a
click; go back with **B** or **Esc**; **LB / RB** (Q / E) step through the sections on the left.

- **Host Co-Op** — everything for hosting on one screen:
  - *Select Co-Op Save*: up to three co-op saves, each with its name, where the party is, the play time, who played,
    your level and when it was last played. *Create New Co-Op Save* takes the next free one (if all three are in use
    it asks first, and the one it replaces is copied to `QDCoop\Saves\Backups`).
  - *Difficulty*: the presets **Solo, Duo, Trio, Quartet, Nightmare**; *Match the party's size* lets the preset follow
    the number of players (the lobby shows the preset for the party sitting in it; in the game it follows the
    players who have loaded into the level, so it steps up as your friends arrive). *Custom* opens every value as a
    slider, with *Reset*, *Load My Preset*, *Save As My Preset* and *Apply*.
  - *Choose Your Knight*: eight knights in two pages of four; the arrows turn the page (see *Knights* below).
  - **Open Lobby** (the big button) starts hosting. The *Party Lobby* then shows the **lobby code**, a copy button and
    *Invite via Steam*; each of the four places shows a player's knight, name and whether they are ready, or *Invite
    Player*. Choosing another player's place removes them (it asks first).
  - *Join Methods* at the bottom: *Steam Invite* (your online Steam friends: choose one to invite), *Join by Code*
    (copies the lobby code) and *Direct IP* (the lobby code, your Steam code and this PC's address on each of its
    networks: choose one to copy it). *Lobby Settings*: travel together, and *New Lobby Code*.
  - **Start Co-Op** (the same big button) loads the game for everyone. If someone is not ready, it asks first.
    Friends who join later load straight into your game.
- **Join Co-Op** — *Steam Invitations* (on the right: every Steam friend of yours who is hosting right now, with the
  state of their session - *In the lobby 2/4*, *Full*, *Another version of the mod* - and **ACCEPT** / **DECLINE**;
  no button of Steam's is needed, though accepting in Steam or *Join Game* on a friend still work), *Join by Code*
  (type the lobby code, a Steam code or an address; Ctrl+V pastes; Enter joins) or *Paste Code or Address* (joins
  with what you copied: no typing, also with a controller). In the host's lobby you see the party, pick your knight
  and press **Ready Up**; the game loads when the host starts it.
- **Continue Co-Op** — opens the lobby with the co-op save you played last.
- **Co-Op Settings** — travel together, the party HUD and its size, teammate names, the outline of
  distant teammates, markers for teammates out of view, notices, teammates' weapons and animations (*Real* or
  *Legacy*), teammate movement volume. Each change counts at once and is kept in `QDCoop\QDCoop.ini`.

### In the game

Hold **View / Select** for 0.6 s, or press **F8**: the co-op menu. The same again closes it. (A short press of View is
the game's own: its Status screen. R3, the right stick's click, is the ping.) Up/Down move,
A (Enter) chooses, Left/Right change a value, B (Esc) goes back. While it is open the game does not get your
controls; when it closes they are back at once. In it:

- **Trade...** — see *Trading* below.
- **Warp to** a teammate, or **to the group at the boss**.
- **Difficulty** (the host changes it; everyone sees it), with the session's rules: *Talk to people together*,
  *Enemy count scaling* and its bonus.
- **Steam invitations (n)...** when you are not in a session: the Steam friends who host now, *ACCEPT* / *DECLINE*.
- The party with pings; the host can remove a player (asks first).
- The host's join code, Steam invites, Steam code and addresses, for friends who join later.
- **Co-op settings**, with **Your knight** (Left/Right changes it; your teammates see the new one at once).
- **End the co-op session (party vote)** (anyone; asks first): every player sees *End the Co-op Session? Votes: 1/3*
  and votes YES or NO in their co-op menu. It ends only when everyone has voted yes; one NO, or 30 seconds without
  every answer, and the session goes on. When it passes every game goes back to the main menu with the words *The
  Co-op Session Has Ended*. **The session does not save**: save at a checkpoint first. A joined player can also
  **Leave the session (only you)**: back to the main menu, unsaved, the others play on. If the host's game is gone
  without a word, you are told, the session tries to reach it for 45 seconds, and then your game goes to the main
  menu too (unsaved by the mod; the game's own saving - its rests, its suspend save every two minutes - is as always).
- **Pings**: the **middle mouse button** (or **R3**, the right stick's click, on a controller) marks what you look at for the party: a place, an enemy (the mark follows it, and goes when it dies) or an
  item - a small diamond in your colour with your name and the distance, an arrow at the screen's edge when it is
  out of view. A mark stays 8 seconds; one a second, two at a time per player.

### Playing over the internet

1. **Steam** (Steam friends): the invite, *Join Game* or the Steam code. Nothing to set up. Through Steam only your
   Steam friends are let in.
2. **A VPN for games** such as Radmin VPN, ZeroTier or Hamachi: both join the same VPN network. The host copies the
   VPN's address under *Direct IP* and sends it; the friend copies it and chooses *Paste Code or Address*. No router
   settings. If it does not connect, Windows Firewall is the usual cause: VPN networks often count as public, so
   allow Queen's Domain on public networks too (Windows Security > Firewall > Allow an app through firewall).
3. **Port forwarding**: the host forwards UDP port 27777 on the router to this PC and sends their internet address
   (a "what is my IP" website shows it); the friend pastes it (the port can be left out). The mod never looks your
   internet address up or shows it.

The six-letter **lobby code** (like `K7M2Q9`) finds a host **on the same network** only. Every code has a check
letter: a typo is reported instead of connecting somewhere else. An invite accepted during a solo game is not
followed (solo saves stay apart): go back to the title screen and accept it again.

### Knights

Each player is one of eight knights, built from the game's own knight armour. Every one is a whole set of that
armour - body, helmet, cloth and weapon of one kind - not a helmet on another knight's body:

| Knight | Look | Its own weapon |
|---|---|---|
| Royal Knight | gilded plate, the crowned helm, a crimson cloth | mace |
| Black Knight | dark steel with red trim, the horned helm | axe |
| Silver Knight | bright polished plate, the tall helm | spear and shield |
| Wandering Knight | weathered green-bronze armour, a travelling cloak | axe |
| Veteran Swordsman | worn deserter steel, the tall helm, a weathered cloak | sword |
| Royal Guardian | the castle's dark plate, the crowned helm | spear and shield |
| Knight Commander | deserter steel, polished, the horned helm | mace |
| Ranger Knight | green-bronze, a red lantern helm, a cloak | crossbow |

The last four are new in 0.14.0. They are put together from armour, weapons and animations the game already has:
a mod made of code can not add new 3D models, so there are no new bodies - no separate male and female figures -
only complete, different sets of the knight the game has. (In 0.14.0 the Silver Knight's plates also got their
detail back: they were so bright that the body looked like a plain pale surface next to its helmet and shield.)

Choose yours on the Co-op screen or in the game's co-op menu; it is kept in `QDCoop\QDCoop.ini` and your teammates
see it in the lobby and in the world. Two players may choose the same knight.

Your teammates see your knight do what you do: it runs as fast as you move (and steps backwards when you back away
while facing an enemy), turns into a sideways walk, jumps and falls with you, swings when you attack (the swing lands
when yours does), draws its weapon back while you hold the attack and strikes the heavy blow when you let go, plays a
heavier blow for your secondary attack, a leap for your ultra attack, a quick swing for a thrown dagger and a sideways
leap for a dash to the side, and keeps its weapon ready for a moment after fighting (a hit shows nothing: 0.20.1). When
you go down it falls and lies there; the teammate who revives you kneels by you; revived, your knight gets up. While
you are at a checkpoint (its menu open) it is down on one knee.

**The weapon your teammates see.** The game is played in first person and has no body of the player to show, so the
knights are the game's own armoured knights. With **Real weapon animations** (on unless you change it: Co-Op
Settings, or *Teammates' weapons* in the co-op menu's settings) a teammate's knight holds the weapon that player
really has in hand - the game's own model of it - and stands and swings in the knight style that goes with such a
weapon (mace, axe and blades, spear, gun); with nothing in hand it carries nothing; when the player changes weapon,
so does the knight. **Legacy animations** shows every knight with its own weapon and swings, as before 0.14.0. The
setting is yours alone and changes only the picture: what a hit does is decided as always.

**Their steps.** A teammate's knight makes the game's knight sounds. Its footsteps and armour rustle are played at
your **Teammate movement volume** (35% unless you change it); they fade with distance as the game's sounds do.

**Finding each other.** A teammate's name, health and distance float over their knight in their colour (P1 cyan,
P2 green, P3 orange, P4 purple). Near you (up to 20 m) nothing else is drawn; from 20 m a thin outline of the
knight's shape fades in, and from 35 m it is there at a low, steady strength — also when the knight is behind a wall.
A downed teammate's outline is red. A teammate off screen is marked on the screen edge.

**Party HUD.** At the centre-left of the screen: one bar per player in the game's own health-bar style - yours
first - with the name, *HOST*, *DOWNED*, *RECONNECTING* or *LOADING*, the passing effects a player is under
(*BURNING*, *POISONED*, ...), and a shake when they are hit. `[PartyHUD] Position=TopLeft` puts it back under the
game's own health bar.

## How the rules change in co-op

- **The host's world.** The host's game runs the world: enemies, doors, chests, pickups, quests. Everyone sees the
  same enemies and the same opened doors.
- **Enemies fight the whole party.** An enemy goes for the nearest player or the one who hurt it, and fights that
  player wherever the others stand: it turns to that player, sees them or loses sight of them, and what it shoots
  is seen by everyone - as is what a teammate throws (a dagger, an axe: it flies from their knight and sticks
  where theirs stuck). Enemies near any player stay fully awake in the host's game, also when the host is far
  away. A place that reacts to a player walking in (an ambush, a boss's arena) reacts to any player.
- **Loot: yours, or everyone's.** An ordinary consumable you pick up (a herb, a potion) is yours alone, and it stays
  in the world for each of the others to take their own. An important item (a weapon, a key item, an upgrade) is
  given to every player once, whoever picks it up, and is then gone from the world for everyone. The host keeps a
  ledger of those in the co-op save: a player of the campaign who was not there gets what they missed when they
  come back - once. What you get is shown on the right of the screen with the item's picture, its name and how many
  (*found by <name>*, or *found while you were away*). Nothing is equipped for you. Coins are shared as before.
- **Your own character - never behind the host when you join.** You keep your own level, experience, weapons,
  weapon levels and upgrades, and every player gets the experience of every kill. When you join a campaign, your
  character is brought up to the host's: their items and coins (a friend new to the campaign), or what the party
  found while you were away (a friend who has been here before), their level and their weapons' levels (0.19.0).
- **No friendly fire.** Nothing a player does hurts a teammate - weapons, the secondary attack, the ultra, shots,
  what a hit sets burning - and there is no switch for it (0.20.0). A hit shows on the screen of the player who was
  hit, nobody else's: no shake, flash, sound, flinch, party-HUD shake or effect overlay for anyone else (0.20.2).
- **Down, not dead.** With a teammate in the level, running out of health puts you down: you stay where you fell
  (you can look around), cannot attack, and enemies leave you alone. A teammate holds **Interact** (E / gamepad X) next to you for 3 seconds to revive
  you at 35% health. Taking damage, letting go or walking away interrupts the revive.
- **Team wipe.** Only when everyone in the level is down does the team wipe: everyone returns to the checkpoint
  together.
- **Healing.** Herbs and potions also heal teammates within about 5.5 m by 60% of the amount. At full health you can
  still use one for a hurt teammate next to you (the game alone would refuse); with nobody to help, nothing is
  used up. Healing never revives a downed teammate.
- **Checkpoints.** When anyone rests at a checkpoint, it becomes everyone's respawn point.
- **Party rest and party save.** When any player chooses *Rest* at a checkpoint, the whole party is brought there:
  the screen fades, everyone is set down next to the checkpoint and rests with their own game, through the
  checkpoint's own menu (health, checkpoint, save - and every game's enemies come back). When any player chooses
  *Save* there, everyone is brought and their game is saved at that checkpoint; nobody rests. Always, whoever does
  it: there is no setting for it (0.17.0). A teammate in a fight is brought too; one in a conversation, a cutscene,
  a screen of the game's, a rest of their own or a journey is waited for (75 seconds at most, then the party has
  rested without them and they are told). There is no party rest during a boss fight (the one who asked is told),
  and a downed player is brought along but stays down. Whoever is set down sees the enemies the host has there
  within a few seconds (their own game is asked for them).
- **The party travels together.** The game's own teleports - the *Shop* button of a checkpoint (the merchant's
  islet), the pad there that leads back, a teleport to a checkpoint - take everyone: each player's own game does the
  same teleport, so the way back from the shop leads everyone to the same checkpoint. Not during a boss fight (the
  traveller goes alone and is told). The shop itself is each player's own: their coins, their purchases. *Travel
  together* (the host's setting, on by default) switches it.
- **Talking to people together.** A talk with one of the game's people waits until every teammate who can come is
  near (15 m): *Waiting for Teammates: 2/4*. Then the conversation is everyone's: each player's game shows it, a
  line goes on only when everyone has pressed confirm (*Skip Votes: 3/4*), a choice is made by the player who
  started the talk, and it ends for all. A gift from the talk is the party's once (the ledger again); an ordinary
  consumable or coin from it is each player's own from their own talk, and the players who were not in the talk
  are given the same once. The merchant is everyone's own business. A teammate who does not
  answer for 45 seconds, leaves or is disconnected no longer holds the others up. The host's rule *Talk to people
  together* (on by default) switches it.
- **Cutscenes are skipped by vote.** While more than one player is in a cutscene, *Skip Cutscene* in the pause menu
  is a vote: *Skip Votes: 2/3*. When everyone in it has voted, every game skips its own.
- **More enemies for a larger party.** With three players every second ordinary enemy has a second one beside it,
  with four every one (+50%, +100%); with two the game is as it is. They are the spawners' own kind, appear where
  the party is before a fight begins, and are the same in every player's game. Never doubled: bosses and their
  groups, traps and ambushes, enemies with a drop of their own or tied to the story. The host can turn *Enemy
  count scaling* off or set the bonus (0 to +200%) on the difficulty page.
- **Difficulty.** By default the preset follows the number of players (enemies 1.45× effective health with two,
  1.9× with three, 2.35× with four; bosses 1.65× / 2.3× / 2.95×). The host can fix a preset or set *Custom* values:
  enemy and boss health, damage, aggression, attack rate, speed and stagger resistance, player health and damage,
  damage taken, healing, stamina use, experience, coins found, revive time and health, and shared healing reach. They apply for
  everyone at once (after a boss fight, if one is on), are kept with the co-op save, and leaving a session puts the
  game's own values back.
- **Bosses wait for the party.** Whoever walks into a boss's arena first wakes it for everyone, and the boss does not
  start until every player is near it; players see *"Waiting for teammates: 2/4"*. Players far away can use *Warp to
  the group at the boss* in the menu.
- **A beaten boss is beaten for everyone.** Some bosses are not dead when their health is gone: they kneel, and a
  player talks to them for their reward (the guardian of the Sword Shrine is the first of them). One player talks.
  The reward goes to everyone, and when the talk ends the boss dies in every player's game: everyone gets the
  experience, and the arena's gates open for everyone.
- **Saves.** Co-op never uses your solo slots (the title screen shows slots 1–5). The host's three co-op saves are
  save slots 8, 10 and 11; a joining player has one character per campaign, in slots 20 and up on their own PC
  (slot 9, the one joined character of versions before 0.16.0, is kept and never changed). Should all eighty of
  those slots ever hold a character, the one of the campaign you have not played for the longest time is put away
  in `QDCoop\Saves\Backups` (its save files, with a note of which campaign it was) to make room. Each co-op save has a record of its own in
  `QDCoop\Saves` (`campaign.json`, `campaign-10.json`, `campaign-11.json`), written atomically with three backups.
  Starting a co-op save over first copies its save file and record to `QDCoop\Saves\Backups` (the newest ten are
  kept).

### Trading

Players can give each other **consumables** (healing items and the like) — nothing else: no weapons, equipment, key
items, quest items, upgrades or currency.

1. Stand within 5 m of your teammate, open the co-op menu (R3 / F8) and choose **Trade...**, then the teammate.
2. They see *Trade Request Received* and open their menu: it opens on the request, to *Accept* or *Decline*.
3. The trade window opens for both: **Your Offer** on the left - every consumable you carry, with the game's own
   picture and name and how many of it you give - and your teammate's offer on the right. Up and Down move along
   your items (a long list scrolls), **Left / Right** change how many (never more than you have), **LB / RB** or
   **Q / E** change it by ten, **A / Enter** on an item gives one more.
4. Each chooses **Confirm Trade**. If an offer changes, both confirmations are taken back. When both have
   confirmed, the items change hands: *Trade Completed*. **Cancel Trade** ends it; **B / Esc** goes back to the menu
   and leaves the trade open (choose *Trade* again to return to it).

A trade is not possible while either of you is down, in a boss fight, has an enemy on them, or was hit in the last
few seconds; walking more than 7.5 m apart cancels it. Either can cancel until it completes.

The host's game decides every trade and both games keep a small journal, so a trade is done completely or not at all:
if a game closes or the connection drops in the middle, nothing is lost or doubled, and what was interrupted is
settled the next time the two of you play with that host. Traded items are not shared loot: only the two of you are
involved, and the others get nothing from it.

## Settings

`QDCoop\QDCoop.ini` (comments inside): your name, your knight and co-op save, ports, revive time and health, heal
radius and share, difficulty factors, HUD parts and colours, save slots; since 0.14.0 also `[Coop] TravelTogether`
and `TeammateWeapons` (real / legacy), `[Audio] TeammateMovementVolume`, `[Dialogue] Radius` and `IndividualNPCs`,
`[Loot] SharedConsumables`; since 0.15.0 `[Ping] Enabled`, `Key` and `Seconds`; since 0.16.0 `[Ping] PadButton`,
`[Menu] PadHoldSeconds`, `[Combat] SingleTargetSwings` and `[PartyHUD] Position`. What the Co-op screen and the co-op menu
change is written there at once; what you change in the file by hand applies the next time the game starts.
`[Menu] Screen=0` gives the plain list menu on the title screen instead of the Co-op screen.

## Game versions

The mod finds what it needs in the game by name every time it starts (no fixed memory addresses), checks each part
(teammates, shared world, loot, enemies, revive, checkpoints, party rest, boss gate, party HUD, title screen,
trading), and switches off only the parts a game update broke, writing what it found to `QDCoop\Logs\core.log`.

Players can play together when their game versions have the same data where co-op touches it. When someone joins,
both mods compare: the co-op protocol they speak, the game data co-op relies on (game classes, compared by their
structure), the features each has, and the co-op save format. A combination that is not known to be safe is refused
with an explanation instead of risking a broken session. Versions that differ in harmless ways are listed in
`QDCoop\compat.ini` (each entry tested): 1.01.03 and 1.01.05 can play together. 1.01.06a can not play with either
(its player and enemy data changed; tested: refused, with the reason). 1.01.07 (the update of 2026-11-14) changed
nothing that co-op compares: it plays together with 1.01.06a (tested with either one hosting). Optional parts only one
side has are switched off for that session.

Mod versions: use the same one. 0.14.0 changed what several co-op messages carry, so it refuses 0.13.x (and is
refused by it) with a message that names both versions.

## Troubleshooting

- **"Game build ... is not one this mod was tested on"**, or **"Game build ...: an update of the game this mod was
  not tested on"** (installer) — the game updated after this mod was made. (An update that changes only the game's
  data keeps the game's exe; the installer tells such updates apart by the build number in the game's `version.txt`.)
  The mod installs anyway and checks the game when it starts: `QDCoop\Logs\core.log` lists what it found ("compat"
  lines) and anything it had to switch off.
- **"Could not join: Your game ... and the host's ... differ in game data co-op relies on"** — you and the host have
  different game versions that are not known to work together. Update both games through Steam so they match.
- **The game's `version.txt` says 0.9.0** — the 0.9.0 package was unpacked into the game folder and its version file
  replaced the game's. Steam restores it: Queen's Domain > Properties > Installed Files > Verify integrity of game
  files. (Later packages use a name that cannot clash.)
- **Holding View does nothing** — a controller (or a controller tool) may report View as held all the time; the mod
  then shows a note. F8 always works. Steam Input layouts that give View another job: the mod reads the controller
  itself (XInput), so set View back to "Back / Select" for this game, or use F8.
- **"No session with the code ... on this network"** — six-letter codes are found on the same network only (the
  host's PC answers on UDP port 27779). Over the internet use the Steam invite or the Steam code. A firewall that
  blocks the game on a private network also hides the code.
- **Friends cannot join with the lobby code or the direct IP** — those only work on your network, over a VPN that
  joins your networks (see *Playing over the internet*), or with UDP port 27777 forwarded to your PC. Over a VPN,
  check Windows Firewall first (the game allowed on public networks too).
- **No Steam friends to invite / "Steam is not running here"** — the game was not started through Steam, or
  `[Steam] Enabled=0` in the INI.
- **A friend's Steam join never connects** — through Steam the host lets in only their Steam friends: add each other
  as friends on Steam. Both need this mod and Steam running, and the host should have started the game from Steam
  (not a copy of the game folder). If it still does not connect, send both `QDCoop\Logs\core.log` files.
- **The knights' pictures on the Co-op screen stay empty ("...")** — the game's knight armour could not be pictured
  in this game build; `core.log` says so ("portraits"). The screen works without them.
- **The Co-op screen does not suit you** — `[Menu] Screen=0` in the INI gives the plain list menu on the title screen.
- **The co-op menu does not open** — check that `xinput1_3.dll` and `QDCoop\QDCoop.dll` are next to the game exe,
  and look at `QDCoop\Logs\loader.log` and `core.log`.
- **"FAULT ... Co-op disabled for this run"** in `core.log` — the mod hit an error and switched itself off for
  this session instead of crashing the game (tested with a deliberate fault: the game kept running). Please report
  it with the log.

## Known limitations

These are true for this version; see `TESTING.md` for what was tested and how.

- **What is left of "kills of a split party".** Since 0.18.0 a kill counts in every game. Not covered: a boss, a
  follower, an enemy a script calls up and the extra enemies of a larger party (as before); and a player whom a
  party rest did not rest (down, or waited for longer than 75 seconds) keeps counting the enemies as killed until
  the host's come near them - their game then gives them back.
- **Steam play between two Steam accounts is not verified.** Steam does not allow lobbies for Queen's Domain (it
  answered "access denied" when the mod tried to create one), so the mod announces hosting through Steam's Rich
  Presence (what gives friends *Join Game* and what invites carry) and connects friends over Steam's peer-to-peer
  messages. Tested live on one account: Steam stores the host's *Join Game* entry and clears it on leaving, the
  friends list and the Steam code are there, and a game started the way Steam starts it for *Join Game* acts on it
  once the title screen is up. One try between two accounts did not connect (the invite arrived without a way to
  join; the friend's game never reached the host), and its cause is not known yet. LAN and direct play are the fully
  tested paths.
- **Joining by address over a VPN or the internet was tested on one PC only** (two copies over 127.0.0.1: the typed
  address, the copied address, Ctrl+V, an address without its port): a real VPN or a forwarded router port was not
  tried yet.
- **Six-letter lobby codes work on the same network only**, and were tested with game copies on one PC (over
  127.0.0.1), not between two PCs: the broadcast that finds a host on a real network is built but not yet tried
  there.
- **The Co-op screen's mouse pointer and a real controller were not tried by a person yet.** The tests move a test
  mouse through the same hit-testing and press a test controller through the path a real controller's state takes;
  a real pointer, a real click and a real gamepad on the screen are left to you. The title's *Co-op* button was
  likewise tested through the game's own button event.
- **Knights are the game's armoured knights, not your character.** The game is first person and has no player body.
  With *Real weapon animations* a teammate's knight holds that player's weapon and swings in the knight style for
  its kind - one of four styles (mace, axe, spear, gun), not that weapon's own first-person moveset, which exists
  only for the arms the game draws for its player. A weapon is set in the knight's hand by its shape; a few of the
  game's sixty-odd weapons may sit oddly (three were looked at: axe, club, spear). There is no block or parry to
  show (the game has none for the player). Using an item and the ultra attack's own effect are not shown as such
  (a healing item's notice and the party HUD say what happened).
- **The four knights of 0.14.0 are sets of the game's own knight**, not new models: no new bodies, no separate male
  and female figures. That needs an artist and the game's asset tools, not a code mod.
- **Steam invitations in the game** list the friends who are hosting, as Steam's friends list knows them; an
  invitation that only sits in Steam's chat is not something a game is told about before it is accepted there. The
  list, *Accept* and *Decline* were tested with entries put in by a test (Steam does not run in the test copies);
  the join behind *Accept* is the same Steam join as before, which is still not verified between two accounts.
- **Talking together**: choosing between options was tested only as far as the rule goes (the leader chooses; the
  others are told) - the people near the start of the game have no choices to offer, so a real choice made by the
  leader and carried out in every game was not played through. Players whose saves differ (one has talked to
  someone before, the other not) may be shown different lines; the conversation then ends for all when the
  leader's ends.
- **Your co-op character belongs to a campaign.** Hosting plays the character of that co-op save; joining plays your
  character of that host's campaign (0.16.0). A character is saved by the game when you rest: what you picked up
  since your last rest is gone if you leave without resting (nothing is saved when a session ends - everyone is
  reminded). Important items are owed again to a character that was never saved.
- **Enemies are run by the host's game.** Where a player stands in a part of the map the host's game does not show
  (the party split far apart, one below ground and one above), that player's own game runs the enemies around them:
  two such players in the same far part do not see the same enemy state until the host is there. Staying in one
  part of the map - walking, warping to a teammate, resting together - keeps everyone on the host's enemies.
- **Pings on a controller** are R3. No sound is played for a ping.
- **Dodging under lag**: a hit is not taken only when you had clearly escaped it on your screen (1.5 m away from
  where the host saw you and 1.5 m farther from the enemy, with at most half a second of lag); a near miss on your
  screen may still be a hit by the host's word. The game itself has no dodge with immunity this early (its Wind
  Dash is an upgrade found later; with it the same rule applies).
- **An enemy a joined game makes from the host's word** (when its own spawner does not) has no spawner of its own:
  it is driven by the host like any copy, but an enemy lying in wait made that way does not wake for that player's
  look (the host's enemy wakes as the host's game decides).
- **The freeze after a party rest** that the owner saw was not reproduced (two and three players, one and two rests,
  Rest then Save); the rest can no longer leave anyone stuck, and if the game's own rest ever keeps the controls, the
  mod gives them back after 20 seconds (and logs it).
- **The freeze after talking to a beaten boss** was not reproduced either (the guardian of the Sword Shrine, the
  joined player talking). The talk is now shared: the others' games join it (each makes its own talking double of
  the boss, as the game does for its own player), its lines step when everyone has confirmed, and it ends for all
  when the one who started it is done. The reward the talk shows is each player's own to put away, so there the
  games may be a line apart for a moment.
- **Cutscene votes** were tested on the intro: three players starting together, and after a team wipe with one game
  much slower than the others. The game has no way to skip a cutscene in a level other than its pause menu (read
  from its code), and that is the vote. The later cutscenes (the ritual, the endings) use the same button and the
  same rule; no test reached them.
- **More enemies**: tested in the first area with three players. Bosses are left alone by their spawners' settings
  (no boss was reached with the rule on). Extra enemies are not kept in the save: after a load they are made anew.
- **Teammate movement volume** also quietens the steps of the game's own knight enemies during a co-op session
  (they walk with the same animations); their attacks are as loud as ever.
- **Travelling together** follows the shop, the way back and checkpoint teleports with the game's own teleport. A
  teleporter station's own teleport has no such call that works from outside: there the others are brought by the
  game's teleport to the nearest checkpoint and the mod's warp from it (not tried: no station is open at the start).
- **A knight's steps are the knight armour's own run cycle**, a stylised one: played to match your speed, its feet
  still slide a little (as the game's own knights' do).
- **Flight on the holy sword** (late in the game) is shown as the knight in the air, without an animation of its
  own; no test reached that part of the game.
- **Trading**: consumables only, by design. What happens when a game closes or a connection drops at the moment the
  items change hands was tested with the trade code on a simulated connection (every such moment), not by cutting a
  real connection at that moment; in the real game the tests cover a player leaving during an open trade, repeated
  messages, and restarting after a completed trade.
- **Three co-op saves per host.** A save is named *Co-op Save 1–3*; names can not be typed in. Co-op saves have no
  picture of the place: the list shows the knight you played it as.
- Steam profile pictures are not shown; players are shown by name (their Steam name, unless `PlayerName` is set in
  the INI), knight and colour.
- Enemies are run by the host only in the host's level. Players in a different level than the host play that level
  with their own local enemies.
- Enemy attack animations: montage-based ones are mirrored from the host. Some enemies animate attacks from state
  flags instead; those flags are copied too, but not every enemy's attack animation is guaranteed to show on clients.
- **One boss fight was played through by the tests**: the guardian of the Sword Shrine, by two players, from the
  walk into its arena to the open gates after it. The other bosses (the witch, the dragon, the whale king and more)
  were not reached by a test: the same rules are there for them, unverified. A boss's change of phase is not sent
  as such; joined players see the boss's place, health and attack animations from the host.
- **A beaten boss's talk** is a conversation like any other since 0.14.0: everyone near is in it, and its reward
  reaches everyone once - those in the talk from their own game, the others from the host. The tests play it with
  one player talking and the other not in the talk (the reward reaches both); two players in that talk together
  were not played.
- **The tests run with the game's own number of enemies** (a test switch), except the test of *Enemy count scaling*
  itself: test players do not fight back, and a party of four of them was wiped where it stood by twice as many
  enemies. How four real players fare against +100% was not played.
- **What an enemy shoots** (an arrow, a fireball) is shown to joined players as a copy of what flies in the host's
  game; it hurts by the host's word, not by the copy touching you, so a hit can look a little off.
- **What a teammate throws** is shown as a copy too: it flies and sticks where theirs did, but it does not spin in
  the air, and of the game's 24 throwables only the Throwing Axe was tried. The stranger ones (a grenade, a ring of
  fire, a stone block) are shown by the same rule, unverified; what they do to the world beside hitting an enemy
  happens in the thrower's game only.
- **The trade window is steered with the keys or a controller**; the mouse is not used in it.
- Joining from inside a solo game is not offered, to keep solo saves apart: join from the title screen.
- Warps (joining next to the host, *Warp to teammate*, *Warp to the group at the boss*) can arrive where your game
  has not loaded that part of the level yet. You are then held there until it loads, and after 8 s put back where
  you were ("That spot is not loaded in your game yet"): walk closer and try again.
- The outline of a distant teammate is drawn over the picture (the game has no outline effect to use): it follows the
  knight's shape and pose, and it shows through walls.
- In a small game window (around 960×540) the in-game HUD's text is small and thin marks such as hyphens can
  disappear there; codes accept spaces and dashes alike. (The Co-op screen draws its text at its exact size.)
- Tested with the game in English; other languages are untested.
- A crash shortly after a level loads was seen in test copies when the test bots started a game the moment the
  title screen appeared (inside the game's own code, also with the mod's hooks switched off). Once they waited 3 s
  it did not happen again in 100 loads; the mod's own menu waits the same way. See `TESTING.md`.
