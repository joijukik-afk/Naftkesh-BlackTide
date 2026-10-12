extends Node

# Signal for UI updates
signal mission_updated(mission_id: String, status: String)
signal player_stats_changed(current_hp: int, max_hp: int)
signal inventory_changed(weapon_id: String, ammo: int)

# Constants
const SAVE_PATH := "user://naftkesh_savegame.save"
const VERSION := "1.0.0"

# Player Stats
var max_health: int = 100
var current_health: int = 100
var is_alive: bool = true

# Mission State
var current_mission_id: String = "CHAPTER_1_DEAD_WATER"
var completed_missions: Array[String] = []
var active_objectives: Dictionary = {}

# Settings
var sensitivity_x: float = 0.5
var sensitivity_y: float = 0.5
var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 1.0

func _ready():
	load_game()

func save_game():
	var save_dict = {
		"version": VERSION,
		"current_health": current_health,
		"max_health": max_health,
		"current_mission_id": current_mission_id,
		"completed_missions": completed_missions,
		"active_objectives": active_objectives,
		"settings": {
			"sensitivity_x": sensitivity_x,
			"sensitivity_y": sensitivity_y,
			"master_volume": master_volume,
			"sfx_volume": sfx_volume,
			"music_volume": music_volume
		}
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_dict))
		file.close()
		print("Game Saved Successfully")
	else:
		push_error("Failed to open save file for writing.")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found. Starting new game.")
		reset_to_defaults()
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			# Validate version could be added here
			
			current_health = data.get("current_health", 100)
			max_health = data.get("max_health", 100)
			current_mission_id = data.get("current_mission_id", "CHAPTER_1_DEAD_WATER")
			completed_missions = data.get("completed_missions", [])
			active_objectives = data.get("active_objectives", {})
			
			var settings = data.get("settings", {})
			sensitivity_x = settings.get("sensitivity_x", 0.5)
			sensitivity_y = settings.get("sensitivity_y", 0.5)
			master_volume = settings.get("master_volume", 1.0)
			sfx_volume = settings.get("sfx_volume", 1.0)
			music_volume = settings.get("music_volume", 1.0)
			
			print("Game Loaded Successfully")
		else:
			push_error("Save file corrupted. Resetting.")
			reset_to_defaults()
	else:
		push_error("Could not read save file.")
		reset_to_defaults()

func reset_to_defaults():
	current_health = 100
	max_health = 100
	is_alive = true
	current_mission_id = "CHAPTER_1_DEAD_WATER"
	completed_missions = []
	active_objectives = {}
	save_game()

func take_damage(amount: int):
	if not is_alive:
		return
		
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		is_alive = false
		emit_signal("player_stats_changed", current_health, max_health)
		# Trigger death sequence in player controller
	else:
		emit_signal("player_stats_changed", current_health, max_health)

func heal(amount: int):
	if is_alive:
		current_health = min(current_health + amount, max_health)
		emit_signal("player_stats_changed", current_health, max_health)

func update_objective(objective_key: String, status: String):
	active_objectives[objective_key] = status
	emit_signal("mission_updated", current_mission_id, status)
	save_game()
