extends CharacterBody2D

@export var speed = 150
@export var laser: PackedScene

var target_radius = 10
var av = Vector2.ZERO
var avoid_weight = 0.1

var job_building = false
var job_cutting_wood = false
var job_mining_gold = false
var job_farming_farm = false
var job_attack = false
var job_attack_units = false
var using_worker_tools = false

var target_id = null
var new_id = null
var target_middle_of_enemy = null

var wood_gathered = 0
var gold_gathered = 0 
var food_gathered = 0

var able_to_shoot = true

var health = 10

var selected = false:
	set = set_selected

var target = null:
	set = set_target

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var body: Node2D = $Body
@onready var back_sprite: Sprite2D = $Body/BackSprite
@onready var hit_box: Area2D = $HitBox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_inactive: Timer = $TimerInactive
@onready var timer_shoot: Timer = $TimerShoot
@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	Global.player_units += 1
	Global.population_count += 1
	
	var characters = "abcdefghijklmnopqrstuvwxyz"
	new_id = generate_id(characters, 10)
	add_to_group("unit")
	

func _physics_process(delta: float) -> void:
	make_path()
	move_towards_target()
	
	if selected and Global.new_worker_target != null:
		turn_off_all_jobs()
		target = Global.new_worker_target
		
		if Global.new_worker_target_job == "build":
			turn_off_all_jobs()
			job_building = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "chop_wood":
			turn_off_all_jobs()
			job_cutting_wood = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "mine_gold":
			turn_off_all_jobs()
			job_mining_gold = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "farm":
			turn_off_all_jobs()
			job_farming_farm = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "attack_unit":
			turn_off_all_jobs()
			job_attack_units = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "attack":
			turn_off_all_jobs()
			job_attack = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "tile" and job_farming_farm == false:
			find_closest_side_of_tile()
		
		selected = false
	
	if using_worker_tools:
		speed = 0
		animation_player.play("UseTools")
		await animation_player.animation_finished
		if job_cutting_wood or job_farming_farm or job_mining_gold:
			find_closest_drop_off_spot()
			find_closest_side_of_tile()
			using_worker_tools = false
		speed = 150
		
	if (job_cutting_wood or job_farming_farm or job_mining_gold or job_building) and timer_inactive.time_left == 0 and velocity == Vector2(0,0) and target == null:
		using_worker_tools = false
		find_closest_target_for_job()
		reset_stand_still_timer()
		
		
	check_if_no_more_resoruces_for_job()
	
	
	if velocity != Vector2(0,0):
		body.look_at(nav_agent.get_next_path_position())
	
	if job_attack and target != null:
		var distance_to_enemy = (target - global_position).lenghth()
		if distance_to_enemy <= 70:
			body.look_at(target_middle_of_enemy)
			speed = 0
			if able_to_shoot:
				able_to_shoot = false
				timer_shoot.start()
				var new_laser = laser.instantiate()
				new_laser.is_player_laser = true
				add_sibling(new_laser)
				new_laser.position = body.global_position
				new_laser.look_at(target_middle_of_enemy)
				new_laser.owners_id = new_id
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			var found_targeted_enemy = false
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
					find_closest_side_of_tile()
					found_targeted_enemy = true
			if found_targeted_enemy == false:
				job_attack = false
				target = null
				target_id = null
				turn_off_all_jobs()
		else:
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			var found_targeted_enemy = false
			for enemy in all_enemies:
				if enemy.new_id == target_id: 
					target = enemy.position
					target_middle_of_enemy = target
					find_closest_side_of_tile()
					found_targeted_enemy = true
			if found_targeted_enemy == false:
				job_attack = false
				target = null
				target_id = null
				turn_off_all_jobs()
			speed = 150
	progress_bar.value = health
	
	if health <= 0:
		Global.player_units -= 1
		Global.population_count -= 1
		queue_free()


func set_selected(value):
	selected = value
	if selected:
		back_sprite.visible = true
		Global.workers_selected = true
	else:
		back_sprite.visible = false
		Global.workers_selected = false
		
	
func set_target(value):
	target = value


func avoid():
	var result = Vector2.ZERO
	var neighbors = hit_box.get_overlapping_bodies()
	if neighbors:
		for n in neighbors:
			result += n.position.direction_to(position)
		result /= neighbors.size()
	return result.normalized()
	
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
		velocity = safe_velocity
	
	
func make_path():
	if target != null:
		nav_agent.target_position = target
		

func move_towards_target():
	velocity = Vector2.ZERO
	if target != null:
		velocity = position.direction_to(target)
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		if position.distance_to(target) < target_radius:
			target = null
	av = avoid()
	velocity = (velocity + av * avoid_weight).normalized() * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(velocity)
		
	move_and_slide()
	var next_path_position = nav_agent.get_next_path_position()
	
	
func turn_off_all_jobs():
	target_id = null
	job_building = false
	job_cutting_wood = false
	job_mining_gold = false
	job_farming_farm = false
	job_attack = false
	job_attack_units = false
	using_worker_tools = false
	speed = 150
	
	
func find_closest_side_of_tile():
	if target != null and target.x < self.position.x and target.y < self.position.y:
		target.x = target.x + 40
		target.y = target.y + 40
	if target != null and target.x < self.position.x and target.y > self.position.y:
		target.x = target.x + 40
		target.y = target.y - 40
	if target != null and target.x > self.position.x and target.y < self.position.y:
		target.x = target.x - 40
		target.y = target.y + 40
	if target != null and target.x > self.position.x and target.y > self.position.y:
		target.x = target.x - 40
		target.y = target.y - 40


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("unbuilt_building") and job_building and area.new_id == target_id:
		using_worker_tools = true
		body.look_at(area.position)
	if area.is_in_group("built_building") and job_building:
		using_worker_tools = false
		find_closest_target_for_job()
		reset_stand_still_timer()
	if area.is_in_group("tree") and job_cutting_wood and area.new_id == target_id:
		using_worker_tools = true
		body.look_at(area.position)
	if area.is_in_group("mine") and job_mining_gold and area.new_id == target_id:
		using_worker_tools = true
		body.look_at(area.position)
	if area.is_in_group("farm") and job_farming_farm and area.new_id == target_id:
		using_worker_tools = true
		body.look_at(area.position)
	if area.is_in_group("town_center") and (job_cutting_wood or job_farming_farm or job_mining_gold):
		Global.wood_count += wood_gathered
		Global.gold_count += gold_gathered
		Global.food_count += food_gathered
		wood_gathered = 0
		gold_gathered = 0
		food_gathered = 0
		body.look_at(area.position)
		
		go_back_to_the_resources()
		
	if area.is_in_group("enemy_laser"):
		health -= 1
		if target_id != area.owner_id:
			turn_off_all_jobs()
			job_attack_units = true
			job_attack = true
			target_id = area.owners_id
			body.look_at(area.position)
			var all_enemies = get_tree().get_nodes_in_group("enemies")
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
		area.queue_free()
		
		
func reset_stand_still_timer():
	timer_inactive.start()


func find_closest_target_for_job():
	var lowest_distance = INF
	var closest_job
	var all_jobs
	
	if job_building:
		all_jobs = get_tree().get_nodes_in_group("unbuilt_building")
	if job_cutting_wood:
		all_jobs = get_tree().get_nodes_in_group("tree")
	if job_mining_gold:
		all_jobs = get_tree().get_nodes_in_group("mine")
	if job_farming_farm:
		all_jobs = get_tree().get_nodes_in_group("farm")
	for job in all_jobs:
		var distance = job.global_position.distance_to(position)
		if distance < lowest_distance:
			closest_job = job.position
			lowest_distance = distance
			target_id = job.new_id
			target = closest_job
			if job_farming_farm == false:
				find_closest_side_of_tile()
				
				
func find_closest_drop_off_spot():
	var lowest_distance = INF
	var closest_drop_offs
	var all_drops_offs = get_tree().get_nodes_in_group("town_center")
	for drop_off in all_drops_offs:
		var distance = drop_off.global_position.distance_to(position)
		if distance < lowest_distance:
			closest_drop_offs = drop_off
			lowest_distance = distance
			target = closest_drop_offs


func go_back_to_the_resources():
	var lowest_resource = INF
	var all_resources
	if job_building:
		all_resources = get_tree().get_nodes_in_group("unbuilt_building")
	if job_cutting_wood:
		all_resources = get_tree().get_nodes_in_group("tree")
	if job_mining_gold:
		all_resources = get_tree().get_nodes_in_group("mine")
	if job_farming_farm:
		all_resources = get_tree().get_nodes_in_group("farm")
	for resource in all_resources:
		var distance = resource.global_position.distance_to(position)
		if resource.new_id == target_id:
			target = resource.position
			if job_farming_farm == false:
				find_closest_side_of_tile()
				
				
func check_if_no_more_resoruces_for_job():
	var lowest_distance = INF
	var all_resources
	if job_building:
		all_resources = get_tree().get_nodes_in_group("unbuilt_building")
	if job_cutting_wood:
		all_resources = get_tree().get_nodes_in_group("tree")
	if job_mining_gold:
		all_resources = get_tree().get_nodes_in_group("mine")
	if job_farming_farm:
		all_resources = get_tree().get_nodes_in_group("farm")
	if job_attack:
		all_resources = get_tree().get_nodes_in_group("enemy")
	if all_resources == null:
		turn_off_all_jobs()
		
		
func generate_id(characters : String, lenght: int):
	var word: String
	var n_char = len(characters)
	for i in range(lenght):
		word += characters[randi()% n_char]
	return word

func _on_timer_shoot_timeout() -> void:
	able_to_shoot = true
