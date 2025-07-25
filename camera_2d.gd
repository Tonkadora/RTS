extends Camera2D

var cam_move_right = false
var cam_move_left = false
var cam_move_up = false
var cam_move_down = false

@onready var mini_map_screen = $"../UI/MiniMap/Screen"

func _process(delta: float) -> void:
	if get_local_mouse_position().x > 540:
		cam_move_right = true
		cam_move_left = false
	if get_local_mouse_position().x < -540:
		cam_move_right = false
		cam_move_left = true
	if get_local_mouse_position().x > -540 and get_local_mouse_position().x < 540:
		cam_move_right = false
		cam_move_left = false
	if get_local_mouse_position().y > 280:
		cam_move_down = true
		cam_move_up = false
	if get_local_mouse_position().y < -280:
		cam_move_down = false
		cam_move_up = true
	if get_local_mouse_position().y > -280 and get_local_mouse_position().y < 280:
		cam_move_down = false
		cam_move_up = false

	if cam_move_right == true and position.x <= 2040:
		position += Vector2(1,0) * 6
		mini_map_screen.position += Vector2(1,0) * 0.2
	if cam_move_left == true and position.x >= -870:
		position -= Vector2(1,0) * 6
		mini_map_screen.position -= Vector2(1,0) * 0.2
	if cam_move_down == true and position.y <= 1700:
		position += Vector2(0,1) * 6
		mini_map_screen.position += Vector2(0,1) * 0.2
	if cam_move_up == true and position.y >= -1060:
		position -= Vector2(0,1) * 6
		mini_map_screen.position -= Vector2(0,1) * 0.2
