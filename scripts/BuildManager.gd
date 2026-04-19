extends Node2D

@onready var main = get_parent()
@onready var tilemap = $"../TileMapLayer"
@onready var tilemapmask = $"../TileMapMaskLayer"
@onready var tilepreview = $"../TilePreview"
@onready var camera = $"../Camera2D"
@onready var button_container = $"../CanvasLayer/Control/HBoxContainer"

var current_tile_id = -1
var current_atlas_coords = Vector2i(0, 0)
var current_list_id = 0
var current_rotation = 0
var dragging = false
var startDragging = Vector2(0, 0)
var zoom_cooldown = 0.0

var material_group = ButtonGroup.new()
var selected_style = StyleBoxFlat.new()

var materials = [
	{"name": "Empty", "tile_id": -1, "atlas_coords": Vector2i(0, 0), "size_x":1, "size_y":1,"can_rotate":false, "class":null},
	{"name": "Conveyer", "tile_id": 1, "atlas_coords": Vector2i(1, 0), "size_x":1, "size_y":1,"can_rotate":true, "class":ConveyerStraightData},
	{"name": "Conveyer_Right", "tile_id": 1, "atlas_coords": Vector2i(11, 2), "size_x":1, "size_y":1,"can_rotate":true, "class":ConveyerCurvedRightData},
	{"name": "Conveyer_Left", "tile_id": 1, "atlas_coords": Vector2i(14, 2), "size_x":1, "size_y":1,"can_rotate":true, "class":ConveyerCurvedLeftData},
	{"name": "Furnace", "tile_id": 1, "atlas_coords": Vector2i(0, 1), "size_x":3, "size_y":3,"can_rotate":false, "class":FurnaceData},
	{"name": "Test", "tile_id": 1, "atlas_coords": Vector2i(3, 2), "size_x":2, "size_y":1,"can_rotate":false, "class":MachineData},
	{"name": "Low Voltage Wire","tile_id": 0, "atlas_coords": Vector2i(0, 0), "size_x": 1,"size_y": 1,"can_rotate": false,"class": LowVoltageMachineData},
	{"name": "High Voltage Wire","tile_id": 0, "atlas_coords": Vector2i(1, 0), "size_x": 1,"size_y": 1,"can_rotate": false,"class": HighVoltageMachineData},
	{"name": "Generator","tile_id": 1, "atlas_coords": Vector2i(8, 2), "size_x": 1,"size_y": 1,"can_rotate": false,"class": GeneratorData}
]

func _ready():
	var i = 0
	selected_style.bg_color = Color.GREEN 
	selected_style.set_corner_radius_all(4)
	for mat in materials:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(64, 64)
		btn.expand_icon = true
		btn.focus_mode = Control.FOCUS_NONE
		btn.toggle_mode = true          # Allows the button to stay pressed
		btn.button_group = material_group
		btn.add_theme_stylebox_override("pressed", selected_style)
		btn.add_theme_stylebox_override("hover_pressed", selected_style)
		mat["index"] = i
		if mat["tile_id"] != -1:
			var source = tilemap.tile_set.get_source(mat["tile_id"])
			var atlas_tex = AtlasTexture.new()
			atlas_tex.atlas = source.texture
			atlas_tex.region = source.get_tile_texture_region(mat["atlas_coords"])
			btn.icon = atlas_tex
		btn.pressed.connect(_on_material_selected.bind(mat))
		button_container.add_child(btn)
		i += 1

func _on_material_selected(mat_data):
	current_tile_id = mat_data["tile_id"]
	current_atlas_coords = mat_data["atlas_coords"]
	current_list_id = mat_data["index"]

func handle_panning():
	zoom_cooldown -= get_process_delta_time()
	if dragging:
		var curr = get_viewport().get_mouse_position()
		var move_vec = (startDragging - curr) / camera.zoom
		camera.position += move_vec
		startDragging = curr

func process_build_logic():
	tilepreview.clear()
	if is_input_blocked(): return
	
	var mouse_pos = tilemap.get_local_mouse_position()
	var pos = tilemap.local_to_map(mouse_pos)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		place(pos)
	queue_redraw()

func refresh_area(pos: Vector2i, size: Vector2i):
	for x in range(-1, size.x + 1):
		for y in range(-1, size.y + 1):
			update_wire_visual(pos + Vector2i(x, y))

func update_wire_visual(check_pos: Vector2i):
	var obj = SimulationData.grid_logic.get(check_pos)
	if not obj or (not obj.data is LowVoltageMachineData and not obj.data is HighVoltageMachineData): 
		return

	var mask = 0
	var dirs = {
		Vector2i.UP: 1,
		Vector2i.RIGHT: 2,
		Vector2i.DOWN: 4,
		Vector2i.LEFT: 8
	}

	for dir in dirs:
		var neighbor_pos = check_pos + dir
		var neighbor = SimulationData.grid_logic.get(neighbor_pos)
		if neighbor and obj.data.can_connect_to(obj, neighbor, dir):
			mask += dirs[dir]
	
	var atlas_x: int
	if obj.data.voltage_type==1:
		atlas_x=0
	else:
		atlas_x=1
	tilemap.set_cell(check_pos, 0, Vector2i(atlas_x, mask))

func delete(pos):
	if SimulationData.grid_logic.get(pos)==null: 
		return
	var obj = SimulationData.grid_logic.get(pos)
	var leader_pos = obj.leader
	var affected_nodes = []
	for p in SimulationData.grid_logic:
		if SimulationData.grid_logic[p].leader == leader_pos:
			affected_nodes.append(p)
			
	for p in affected_nodes:
		SimulationData.grid_logic.erase(p)
		tilemap.set_cell(p, -1)
		tilemapmask.set_cell(p, -1)
	
	refresh_area(leader_pos, Vector2i(1, 1))

func place(pos):
	if current_tile_id==-1:
		delete(pos)
		return
	var size_x = materials[current_list_id]["size_x"]
	var size_y = materials[current_list_id]["size_y"]
	if !can_place(pos, size_x, size_y): return
	if current_tile_id==1:
		tilemap.set_cell(pos, current_tile_id, current_atlas_coords, get_transforms())
		tilemapmask.set_cell(pos, current_tile_id+1, current_atlas_coords, get_transforms())
	else:
		tilemap.set_cell(pos, current_tile_id, current_atlas_coords, get_transforms())
	var dir = Vector2i(Vector2.DOWN.rotated(deg_to_rad(-current_rotation * 90)).round())
	var obj = GridObject.new(pos, dir, materials[current_list_id]["class"].new())
	obj.leader = pos
	for i in range(size_x):
		for j in range(size_y):
			SimulationData.grid_logic[pos+Vector2i(i, j)] = obj
			
	refresh_area(pos, Vector2i(size_x, size_y))

func can_place(pos, size_x, size_y):
	for i in range(size_x):
		for j in range(size_y):
			if SimulationData.grid_logic.get(pos+Vector2i(i, j))!=null:
				return false
	return true

func get_transforms():
	if !materials[current_list_id]["can_rotate"]:
		return 0
	var t = TileSetAtlasSource
	match current_rotation:
		1: return t.TRANSFORM_TRANSPOSE | t.TRANSFORM_FLIP_V
		2: return t.TRANSFORM_FLIP_V | t.TRANSFORM_FLIP_H
		3: return t.TRANSFORM_TRANSPOSE | t.TRANSFORM_FLIP_H
		_: return 0

func handle_camera(event):
	if event.is_action_pressed("rotate"):
		current_rotation = (current_rotation + 3) % 4
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			startDragging = get_viewport().get_mouse_position()
			dragging = event.pressed
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var dir = 1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1
			camera.zoom = (camera.zoom + Vector2(0.1, 0.1) * dir).clamp(Vector2(0.1, 0.1), Vector2(2, 2))
			zoom_cooldown = 0.1
	if event is InputEventMagnifyGesture:
		camera.zoom = (camera.zoom + Vector2(0.5, 0.5) * (event.factor-1)).clamp(Vector2(0.1, 0.1), Vector2(2, 2))
		zoom_cooldown = 0.1

func is_input_blocked():
	return get_viewport().gui_get_focus_owner() != null or get_viewport().gui_get_hovered_control() != null or zoom_cooldown >= 0
