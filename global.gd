extends Node

var add_nav_spot = PackedVector2Array()
var add_to_no_nav_spot = PackedVector2Array()
var workers_selected = false
var building_selected = false

var food_count = 1200
var gold_count = 1200
var wood_count = 1200
var population_count = 0
var max_population_count = 0

var new_worker_target = null
var new_worker_target_type = null
var new_worker_target_job = null
var new_worker_target_id = null

var enemy_units = 0
var player_units = 0

func reset_all_var() -> void:
	add_nav_spot = PackedVector2Array()
	add_to_no_nav_spot = PackedVector2Array()
	workers_selected = false
	building_selected = false

	food_count = 1200
	gold_count = 1200
	wood_count = 1200
	population_count = 0
	max_population_count = 0

	new_worker_target = null
	new_worker_target_type = null
	new_worker_target_job = null
	new_worker_target_id = null

	enemy_units = 0
	player_units = 0
