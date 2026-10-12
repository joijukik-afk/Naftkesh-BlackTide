class_name WeaponData
extends Resource

@export_group("Identity")
@export var weapon_name: String = "Standard Pistol"
@export var weapon_id: String = "wpn_pistol_01"
@export var model_path: String = "" # Path to .tscn or .glb

@export_group("Stats")
@export var damage: int = 15
@export var fire_rate: float = 0.2 # Seconds between shots
@export var magazine_size: int = 12
@export var reserve_ammo: int = 48
@export var reload_time: float = 1.5 # Seconds
@export var range: float = 50.0
@export var spread: float = 2.0 # Degrees

@export_group("Audio & FX")
@export var shoot_sound_path: String = ""
@export var reload_sound_path: String = ""
@export var muzzle_flash_scene: PackedScene = null

func get_current_ammo() -> int:
	# This would typically be managed by the player/inventory, 
	# but for resource definition, we just return max capacity
	return magazine_size
