extends TileMapLayer


func _process(delta: float) -> void:
	if Global.add_nav_spot != null:
		for spot in Global.add_nav_spot:
			erase_cell(Vector2(spot.x, spot.y))
			erase_cell(Vector2(spot.x + 1, spot.y))
			erase_cell(Vector2(spot.x, spot.y + 1))
			erase_cell(Vector2(spot.x + 1, spot.y + 1))
			
			set_cell(Vector2(spot.x, spot.y), 0, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y), 0, Vector2i(0,0))
			set_cell(Vector2(spot.x, spot.y + 1), 0, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y + 1), 0, Vector2i(0,0))
		Global.add_nav_spot.clear()
		
	if Global.add_nav_spot != null:
		for spot in Global.add_to_no_nav_spot:
			erase_cell(Vector2(spot.x, spot.y))
			erase_cell(Vector2(spot.x + 1, spot.y))
			erase_cell(Vector2(spot.x, spot.y + 1))
			erase_cell(Vector2(spot.x + 1, spot.y + 1))
			
			set_cell(Vector2(spot.x, spot.y), 1, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y), 1, Vector2i(0,0))
			set_cell(Vector2(spot.x, spot.y + 1), 1, Vector2i(0,0))
			set_cell(Vector2(spot.x + 1, spot.y + 1), 1, Vector2i(0,0))
		Global.add_to_no_nav_spot.clear()
