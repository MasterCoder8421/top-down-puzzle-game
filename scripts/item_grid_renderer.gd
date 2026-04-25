extends Node2D

@onready var main = get_parent()
var atlas_tex = null
var scaling = 5

func _ready():
	atlas_tex = load("res://sprite_sheet.png")

func _process(_delta):
	if !main.broken:
		main.last_time-=_delta
	queue_redraw()

func _draw() -> void:
	if main.current_state != main.State.SIMULATION:
		return
	var t = 1.0 - (main.last_time / main.step_duration)
	for pos in SimulationData.grid_logic:
		var grid_obj = SimulationData.grid_logic[pos]
		if grid_obj.leader==pos:
			var item = grid_obj.get_display_item()
			if item!=null:
				var atlas_coords = item.atlas_coords
				var position = main.tilemap.to_global(grid_obj.along(t)*main.tilemap.tile_set.tile_size.x)
				draw_texture_rect_region(atlas_tex, Rect2(position-Vector2i(32*scaling, 32*scaling)*0.5, Vector2i(32*scaling, 32*scaling)), Rect2(atlas_coords*32, Vector2i(32, 32)))
