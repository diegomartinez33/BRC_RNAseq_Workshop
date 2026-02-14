###############################################################################
# Instructor materials
###############################################################################
cat > "$GAME_DIR/INSTRUCTOR_KEY.txt" <<'EOF'
INSTRUCTOR KEY (do not give to students)

Core intended flow (commands may vary):

1) cd terminal_trial_fun
2) cat START.txt
3) cd garden
4) ./talk_to_cow.sh
5) cd ..
6) mkdir backpack
7) cd cave
8) ./explore_cave.sh
9) Remove trolls with a wildcard (example):
     rm *_troll.txt
   (Do NOT remove map.txt or scroll.txt)
10) Put scroll into backpack (example from cave/):
     cp scroll.txt ../backpack/
   (or mv is also OK if you want it removed from cave)
11) cd ../tower
12) ./open_door.sh
    - type: hello world
13) cd chest
14) cat treasure.txt

Quick checks:
- terminal_trial_fun/backpack exists
- terminal_trial_fun/backpack/scroll.txt exists
- terminal_trial_fun/cave has map.txt and scroll.txt (optional)
- terminal_trial_fun/tower/chest/treasure.txt exists
EOF

cat > "$GAME_DIR/README_TEACHER.txt" <<'EOF'
Teacher notes

Time plan (~15 mins)

Dependencies:
cowsay is optional. The garden script will fall back to plain text if missing.

Suggested command set in notes:
pwd, ls, cd, cat, mkdir, cp, mv, rm, ./script.sh, wildcards


EOF

###############################################################################
