extends Node

signal health_changed(value: int)
signal ammo_changed(current: int, max_ammo: int)
signal score_changed(value: int)
signal game_over(won: bool)

var player_health: int = 100
var max_health: int = 100
var ammo: int = 30
var max_ammo: int = 30
var score: int = 0

func reset() -> void:
	player_health = max_health
	ammo = max_ammo
	score = 0
	health_changed.emit(player_health)
	ammo_changed.emit(ammo, max_ammo)
	score_changed.emit(score)

func damage_player(amount: int) -> void:
	player_health = max(0, player_health - amount)
	health_changed.emit(player_health)
	if player_health <= 0:
		game_over.emit(false)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

func use_ammo() -> bool:
	if ammo > 0:
		ammo -= 1
		ammo_changed.emit(ammo, max_ammo)
		return true
	return false

func reload() -> void:
	ammo = max_ammo
	ammo_changed.emit(ammo, max_ammo)
