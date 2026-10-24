extends Node

# FPS Fix
# The game keeps three tables with one entry for every character it has ever heard from (Network.ACTOR_DATA,
# ACTOR_ANIMATION_DATA and ACTOR_ACTIONS) and never removes an entry, not even when the character is gone or you leave
# the lobby. Every frame, every other character looks itself up in those tables with `keys().has(id)`, which builds a
# brand new list of every key each time. So the longer you play (birds, fish spots, rain clouds and props come and go
# all day), the bigger the tables and the more every frame costs. Frame rate slowly sinks until you restart the game.
# This mod removes the entries of characters that are gone, so the tables stay small. Entries of characters that
# haven't appeared yet are kept for a while, so nothing is lost while a character is still loading in.

const VERSION = "1.0.0"
const SWEEP_EVERY = 5.0      # seconds between clean-ups
const GRACE = 45.0           # an entry whose character is missing is kept this long (it may still be loading in)
const NOTE_ABOVE = 400       # only write to the log when a clean-up removed at least this many entries

const TABLES = ["ACTOR_DATA", "ACTOR_ANIMATION_DATA", "ACTOR_ACTIONS"]

var missing_since = {}   # actor id -> clock time it was first found missing
var clock = 0.0
var timer = 0.0
var last_lobby = null
var removed_total = 0    # entries removed this session
var biggest_seen = 0     # biggest table size seen before a clean-up


func _process(delta):
	clock += delta
	timer += delta
	if timer < SWEEP_EVERY:
		return
	timer = 0.0
	sweep()


func sweep():
	var net = get_node_or_null("/root/Network")
	if net == null:
		return
	# every character that is in the game right now
	var live = {}
	for actor in get_tree().get_nodes_in_group("actor"):
		var id = actor.get("actor_id")
		if id != null:
			live[id] = true
	# leaving or joining a lobby starts the world over, so nothing waits then
	var lobby = net.get("STEAM_LOBBY_ID")
	var grace = GRACE
	if last_lobby != null and lobby != last_lobby:
		grace = 0.0
	last_lobby = lobby
	var removed = 0
	var seen_ids = {}
	for table_name in TABLES:
		var table = net.get(table_name)
		if not table is Dictionary:
			continue
		biggest_seen = max(biggest_seen, table.size())
		for id in table.keys():
			if live.has(id):
				missing_since.erase(id)
				continue
			seen_ids[id] = true
			if not missing_since.has(id):
				missing_since[id] = clock
			if clock - missing_since[id] >= grace:
				table.erase(id)
				removed += 1
	# forget ids that are in no table any more
	for id in missing_since.keys():
		if not seen_ids.has(id) and not live.has(id):
			missing_since.erase(id)
	removed_total += removed
	if removed >= NOTE_ABOVE:
		print("[FPSFix] removed ", removed, " old entries from the actor tables (", removed_total, " this session)")
