extends Node2D

@onready var build_manager = $"../BuildManager"
@onready var tilemap = $"../TileMapLayer"
@onready var tilepreview = $"../TilePreview"
@onready var main = $".."

func _process(_delta):
	queue_redraw()

func _draw():
	if build_manager.is_input_blocked(): 
		return
	if main.current_state==main.State.SIMULATION:
		return
	
	var mouse_pos = tilemap.get_local_mouse_position()
	var pos = tilemap.local_to_map(mouse_pos)
	
	if build_manager.current_data.get_tile_id() == -1:
		tilepreview.clear()
		return

	var mat = build_manager.current_data.new()
	var size = mat.get_size()

	var color = Color(0.5, 1, 0.5, 1.0) if build_manager.can_place(pos, size.x, size.y) else Color(1, 0.5, 0.5, 1.0)
	
	tilepreview.clear()
	tilepreview.modulate = color
	tilepreview.set_cell(pos, build_manager.current_data.new().get_tile_id(), build_manager.current_data.new().get_atlas_coords(), build_manager.get_transforms())

	var tile_size = tilemap.tile_set.tile_size
	var rect_pos = tilemap.map_to_local(pos) - (Vector2(tile_size) / 2)
	var rect_size = Vector2(size.x * tile_size.x * 5, size.y * tile_size.y * 5)
	var rect = Rect2(rect_pos*5, rect_size)
	
	draw_rect(rect, color, false, 5.0)
