#!/usr/bin/env bash
set -euo pipefail

# Terminal Trial v2 (fun edition): directories + runnable scripts + .txt clues
# Setup:
#   bash Treasure_of_BASH.sh
#
# Notes:
# - Uses cowsay if available (optional). If not installed, falls back to plain text.
# - Students should run *.sh scripts and read *.txt files.

GAME_DIR="terminal_trial_fun"

if [[ -e "$GAME_DIR" ]]; then
  echo "Error: '$GAME_DIR' already exists in: $(pwd)"
  echo "Move or delete it first, or change GAME_DIR in the script."
  exit 1
fi

mkdir -p "$GAME_DIR"/{garden,cave,tower}

###############################################################################
# START instructions (.txt)
###############################################################################
cat > "$GAME_DIR/START.txt" <<'EOF'
Welcome to the Terminal Trials.

You are a rugged explorer who is on a quest of great importance.

You want to be the one to find the long forgotten treasure of BASH.

The elders from your village would often tell stories of the great obstacles that would face those brave enough to seek the treasure of BASH.

Before you left your home in search of this treasure, you asked one of the elders for their help.

They said:

- Scripts end in .sh and need to be run.
- Clues end in .txt and need to be read.
- Your journey must start in the garden.


EOF

###############################################################################
# GARDEN: talk_to_cow.sh (cowsay message)
###############################################################################
cat > "$GAME_DIR/garden/talk_to_cow.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

msg=$'Moo! Do you wish to find the treasure of BASH? You will need a backpack for your journey. \n\nReturn to where you started and craft yourself a backpack directory. Then venture into the mysterious cave.'

if command -v cowsay >/dev/null 2>&1; then
  cowsay -f default "$msg"
else
  echo "----------------------------------------"
  echo "$msg"
  echo "----------------------------------------"

fi
EOF
chmod +x "$GAME_DIR/garden/talk_to_cow.sh"

cat > "$GAME_DIR/garden/sign.txt" <<'EOF'
This is the garden of the magical bovine.

A lone cow stands in silver mist,
Is there something magical I feel in her midst?
Quiet for now... yet in her gaze
Lingers a spell from older days.


EOF

###############################################################################
# CAVE: explore_cave.sh creates trolls + scroll + map
###############################################################################
cat > "$GAME_DIR/cave/explore_cave.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Create trolls only if they don't already exist
trolls=(
  ugly_troll.txt
  hairy_troll.txt
  green_troll.txt
  short_troll.txt
  grumpy_troll.txt
  sleepy_troll.txt
  smelly_troll.txt
  warty_troll.txt
  slimy_troll.txt
  noisy_troll.txt
)

for t in "${trolls[@]}"; do
  if [[ ! -e "$t" ]]; then
    cat > "$t" <<EOF2
A troll blocks your way: $t

To defeat the trolls, remove ONLY the troll files.
Do NOT remove scroll.txt or map.txt.
EOF2
  fi
done

# map + scroll
cat > map.txt <<'EOF2'
You found a MAP.

It is crumpled and stained, but you see something circled:


     |>>>
     |
 _  _|_  _
|;|_|;|_|;|
\\.    .  /
 \\:  .  /
  ||:   |
  ||:.  |
  ||:  .|
  ||:   |       \,/
  ||: , |            /`\
  ||:   |
  ||: . |
 _||_   |


EOF2

cat > scroll.txt <<'EOF2'
ANCIENT SCROLL

An ancient scroll covered in dust
Unfurls before you from an arcane gust

Tattered edges open at a slow pace
Dissapointed, all you see is a blank face

But you hear a whisper as it uncurls
"The secret phrase is: hello world"

You should place the scroll in your backpack
And let the map guide you to your next track

EOF2

echo
echo "As you begin to look around, ten trolls pop up out from behind the rocks. They look menacing and unfriendly, but... whats that? You notice they have a map and scroll! They must reveal the location of the secret treasure of BASH."
echo
echo "You think, I must:"
echo "Remove the 10 trolls! "
echo "Investigate the map and scroll. "
echo "Move the scroll into my backpack. "
echo
EOF
chmod +x "$GAME_DIR/cave/explore_cave.sh"

cat > "$GAME_DIR/cave/clue.txt" <<'EOF'

It is dark and damp, but you are a brave explorer.

EOF

###############################################################################
# TOWER: open_door.sh checks for scroll in backpack + passphrase, then creates chest/
###############################################################################
cat > "$GAME_DIR/tower/open_door.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Expect the student to have created backpack/ in the game root (starting area)
# and to have placed scroll.txt inside it.
GAME_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BACKPACK="$GAME_ROOT/backpack"
SCROLL="$BACKPACK/scroll.txt"
CHEST_DIR="$(cd "$(dirname "$0")" && pwd)/chest"
TREASURE_TXT="$CHEST_DIR/treasure.txt"

echo
echo "You stand before the tower door."
echo

if [[ ! -d "$BACKPACK" ]]; then
  echo "The door rumbles, but does not open."
  echo "Do you have a directory called backpack in the start location?"
  exit 1
fi

if [[ ! -f "$SCROLL" ]]; then
  echo "The door rumbles, but does not open."
  echo "You need to place scroll.txt into your backpack directory:"
  echo "  $BACKPACK"
  exit 1
fi

read -r -p "The door speaks: 'Say the secret phrase to enter: ' " phrase
if [[ "$phrase" != "hello world" ]]; then
  echo
  echo "The door snaps shut: 'Wrong phrase.'"
  exit 1
fi

mkdir -p "$CHEST_DIR"

# Create treasure.txt (ASCII art) each time to keep it consistent
cat > "$TREASURE_TXT" <<'EOF2'
                          _.--.
                      _.-'_:-'|| 
                  _.-'_.-::::'|| 
             _.-:'_.-::::::'  || 
           .'`-.-:::::::'     || 
          /.'`;|:::::::'      ||_
         ||   ||::::::'     _.;._'-._
         ||   ||:::::'  _.-!oo @.!-._'-.
         \'.  ||:::::.-!()oo @!()@.-'_.|
          '.'-;|:.-'.&$@.& ()$%-'o.'\U||
            `>'-.!@%()@'@_%-'_.-o _.|'||
             ||-._'-.@.-'_.-' _.-o  |'||
             ||=[ '-._.-\U/.-'    o |'||
             || '-.]=|| |'|      o  |'||
             ||      || |'|        _| '|
             ||      || |'|    _.-'_.-'
             |'-._   || |'|_.-'_.-'
              '-._'-.|| |' `_.-'
                  '-.||_/.-'

You have found the treasure of BASH. You return home a hero. Townsfolks will sing about your adventure for years to come.
EOF2

echo
echo "The door opens with a creak."
echo "You see in the middle of the room, a chest."
echo
EOF
chmod +x "$GAME_DIR/tower/open_door.sh"
