extends Node2D


@export var new_town_center: PackedScene
@export var new_house: PackedScene
@export var new_farm: PackedScene
@export var new_barracks: PackedScene
@export var new_range_building: PackedScene
@export var new_tower: PackedScene

@onready var game_objects: Node2D = $"../../GameObjects"



func _on_button_build_tc_pressed() -> void:
	if Global.wood_count >= 50 and Global.gold_count >= 50:
		var new_building = new_town_center.instantiate()
		game_objects.add_child(new_building)
		
		Global.wood_count -= 50
		Global.gold_count -= 50
		
		

func _on_button_b_build_house_pressed() -> void:
	if Global.wood_count >= 50:
		var new_building = new_house.instantiate()
		game_objects.add_child(new_building)
		
		Global.wood_count -= 50
		


func _on_button_b_build_barracks_pressed() -> void:
	if Global.wood_count >= 50:
		var new_building = new_barracks.instantiate()
		game_objects.add_child(new_building)
		
		Global.wood_count -= 50


func _on_button_b_build_range_pressed() -> void:
	if Global.wood_count >= 50:
		var new_building = new_range_building.instantiate()
		game_objects.add_child(new_building)
		
		Global.wood_count -= 50


func _on_button_b_build_tower_pressed() -> void:
	if Global.wood_count >= 50:
		var new_building = new_tower.instantiate()
		game_objects.add_child(new_building)
		
		Global.wood_count -= 50


func _on_button_build_farm_pressed() -> void:
	if Global.wood_count >= 50:
		var new_building = new_farm.instantiate()
		game_objects.add_child(new_building)
		
		Global.wood_count -= 50
