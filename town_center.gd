extends Area2D

@export var cleared_block: PackedScene
@export var new_worker: PackedScene

var health = 10
var dead = false

var x_value = 0
var y_value = 0

var removed_collision = false
var create = false
var new_id 

var workers_in_queue = 0

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var button_tc: Button = $ButtonTC
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var timer_worker: Timer = $TimerWorker
@onready var timer_ui_on: Timer = $TimerUIOn
@onready var q_1: Node2D = $CanvasLayer/Q1
@onready var q_2: Node2D = $CanvasLayer/Q2
@onready var q_3: Node2D = $CanvasLayer/Q3
@onready var q_4: Node2D = $CanvasLayer/Q4


func _ready() -> void:
	var new_pos = cleared_block.instantiate()
	add_child(new_pos)
	if position.x > 0:
		new_pos.position.x -= position.x
	if position.x < 0:
		new_pos.position.x += (position.x * -1)
	if position.y > 0:
		new_pos.position.y -= position.y
	if position.y < 0:
		new_pos.position.y += (position.y * -1)
		
	while new_pos.position.x < (0):
		if new_pos.position.x < (position.x):
			new_pos.position.x += 40
			x_value += 1
	while new_pos.position.x > 40:
		if new_pos.position.x > (position.x):
			new_pos.position.x -= 40
			x_value -= 1
	while new_pos.position.y < (-40):
		if new_pos.position.y < (position.y):
			new_pos.position.y += 40
			y_value += 1
	while new_pos.position.y > (0):
		if new_pos.position.y > (position.y):
			new_pos.position.y -= 40
			y_value -= 1

	y_value += 1
	new_pos.position.y += 20
	new_pos.position.x -= 20
	create = true
	add_to_group("building")
	add_to_group("town_center")
	
	var characters = "abcdefghijklmnopqrstuvwxyz"
	new_id = generate_id(characters, 10)
	add_to_group("unit")
	
	
	
func _physics_process(delta: float) -> void:
	if create:
		Global.add_to_no_nav_spot.append(Vector2i(x_value,y_value))
		Global.max_population_count += 10
		create = false
	
	if health <= 0:
		if removed_collision == false:
			Global.add_to_no_nav_spot.append(Vector2i(x_value,y_value))
			remove_from_group("building")
			remove_from_group("town_center")
			Global.max_population_count -= 10
			queue_free()
			removed_collision = true
	
	progress_bar.value = health
	
	if Global.workers_selected and health > 0 or Global.building_selected:
		button_tc.visible = false
		canvas_layer.visible = false
	
	if Global.workers_selected == false and health > 0:
		button_tc.visible = true
		
	if workers_in_queue > 0 and timer_worker.is_stopped() and Global.population_count < Global.max_population_count:
		timer_worker.start()
		
	if workers_in_queue == 0:
		q_1.visible = false
		q_2.visible = false
		q_3.visible = false
		q_4.visible = false
	elif workers_in_queue == 1:
		q_1.visible = true
		q_2.visible = false
		q_3.visible = false
		q_4.visible = false
	elif workers_in_queue == 2:
		q_1.visible = true
		q_2.visible = true
		q_3.visible = false
		q_4.visible = false
	elif workers_in_queue == 3:
		q_1.visible = true
		q_2.visible = true
		q_3.visible = true
		q_4.visible = false
	elif workers_in_queue == 4:
		q_1.visible = true
		q_2.visible = true
		q_3.visible = true
		q_4.visible = true
		

func generate_id(characters : String, lenght: int):
	var word: String
	var n_char = len(characters)
	for i in range(lenght):
		word += characters[randi()% n_char]
	return word
	

func _on_button_remove_pressed() -> void:
	health -= 10
	

func _on_button_add_worker_pressed() -> void:
	if workers_in_queue < 4 and Global.population_count < Global.max_population_count and Global.food_count >= 50:
		timer_worker.start()
		workers_in_queue += 1
		Global.food_count -= 50
		
		
func _on_button_tc_pressed() -> void:
	Global.building_selected = true
	timer_ui_on.start()
	

func _on_timer_worker_timeout() -> void:
	var new_worker_created = new_worker.instantiate()
	add_sibling(new_worker_created)
	new_worker_created.position = position + Vector2(0, 60)
	workers_in_queue -= 1
	if workers_in_queue > 0 and Global.population_count < Global.max_population_count:
		timer_worker.start()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_laser"):
		health -= 1
		area.queue_free()


func _on_timer_ui_on_timeout() -> void:
	Global.building_selected = false
	canvas_layer.visible = true
