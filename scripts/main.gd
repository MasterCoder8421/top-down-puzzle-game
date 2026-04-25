extends Node2D

enum State { BUILDING, SIMULATION }

var current_state = State.BUILDING
var broken = false
var last_time = 0.0
var step_duration = 1
var visual_step_count = 0

@onready var tilemap = $TileMapLayer
@onready var tilemapmask = $TileMapMaskLayer
@onready var camera = $Camera2D
@onready var build_manager = $BuildManager
@onready var item_renderer = $ItemGridRenderer

func _ready():
	add_unbreakable_input(Vector2i(0, 0), Vector2i(0, 1), "Raw Iron", Vector2i(9, 7))
	add_unbreakable_output(Vector2i(1, 0), Vector2i(0, 1), "Iron", Vector2i(13, 7))
	add_unbreakable_input(Vector2i(-2, 0), Vector2i(0, 1), "Coal", Vector2i(0, 7), 1)
	##for i in range(100):
		#for j in range(100):
			#SimulationData.grid_logic[Vector2i(i+10, j+10)] = GridObject.new(Vector2i(i+10, j+10), Vector2i(0, 1), ConveyerStraightData.new())
			#tilemap.set_cell(Vector2i(i+10, j+10), 1, Vector2i(1, 0))
			#tilemapmask.set_cell(Vector2i(i+10, j+10), 2, Vector2i(1, 0))

func add_unbreakable_input(pos: Vector2i, direction: Vector2i, item_name: String, atlas_coords: Vector2i, mask_source_id: int = 2, spawn_interval: int = 5):
	var data = InputData.new(item_name, spawn_interval)
	_add_unbreakable_machine(pos, direction, data, 1, atlas_coords, mask_source_id)

func add_unbreakable_output(pos: Vector2i, direction: Vector2i, item_name: String, atlas_coords: Vector2i, mask_source_id: int = 2):
	var data = OutputData.new(item_name)
	_add_unbreakable_machine(pos, direction, data, 1, atlas_coords, mask_source_id)

func _add_unbreakable_machine(pos: Vector2i, direction: Vector2i, data: MachineData, tile_source_id: int, atlas_coords: Vector2i, mask_source_id: int):
	data.unbreakable = true
	var obj = GridObject.new(pos, direction, data)
	obj.leader = pos
	SimulationData.grid_logic[pos] = obj
	tilemap.set_cell(pos, tile_source_id, atlas_coords)
	tilemapmask.set_cell(pos, mask_source_id, atlas_coords)

func _process(delta):
	build_manager.handle_panning()
	if current_state == State.SIMULATION and !broken:
		simulate_step(delta)
	
	if current_state == State.BUILDING:
		build_manager.process_build_logic()

func refresh_tile_visuals():
	for pos in SimulationData.grid_logic:
		var obj = SimulationData.grid_logic[pos]
		if obj == null or obj.leader != pos or obj.data.is_wire():
			continue
		var texture_update = obj.data.get_step_texture_update(obj, visual_step_count)
		if texture_update is bool and texture_update == false:
			continue
		if not texture_update is Vector2i:
			continue
		var source_id = tilemap.get_cell_source_id(pos)
		if source_id == -1:
			continue
		var desired_coords: Vector2i = texture_update
		if desired_coords == tilemap.get_cell_atlas_coords(pos):
			continue
		var alternative = tilemap.get_cell_alternative_tile(pos)
		tilemap.set_cell(pos, source_id, desired_coords, alternative)

func simulate_step(delta):
	last_time -= delta
	if last_time <= 0:
		calculate_powered()
		print("simulate")
		var new_grid = {}
		for pos in SimulationData.grid_logic:
			new_grid[pos] = SimulationData.grid_logic[pos].clone()
		
		for pos in SimulationData.grid_logic:
			var current_obj = SimulationData.grid_logic[pos]
			if current_obj.will_output() &&  current_obj.leader==pos:

				var item = current_obj.get_next_output_item()
				var actual_target_pos = current_obj.get_target_pos()
				var target_pos = 0 
				if SimulationData.grid_logic.get(current_obj.get_target_pos())==null:
					target_pos = actual_target_pos
				else:
					target_pos = SimulationData.grid_logic[actual_target_pos].leader
				if validate_move(pos, target_pos, item, actual_target_pos):
					new_grid[target_pos].push_item(item)
					new_grid[pos].pop_item(item)
				else:
					broken = true
					return
					
		for pos in new_grid:
			if new_grid[pos].is_invalid():
				broken = true
				return
				
		SimulationData.grid_logic = new_grid
		last_time = step_duration
		for pos in SimulationData.grid_logic:
			if (SimulationData.grid_logic.get(pos) != null):
				var obj = SimulationData.grid_logic.get(pos)
				obj.data.update(obj)
		visual_step_count += 1
		refresh_tile_visuals()
	



func calculate_powered():
	print("Calculating...")
	var q = []
	for pos in SimulationData.grid_logic:
		if (SimulationData.grid_logic.get(pos) != null):
			var obj = SimulationData.grid_logic.get(pos)
			obj.is_powered = false
			if obj.is_generating:
				q.push_back(pos)
				obj.is_powered = true
	
	var visited = {}
	while (!q.is_empty()):
		var curr_pos = q.pop_front()
		if visited.get(curr_pos)==true:
			continue
		if SimulationData.grid_logic.get(curr_pos)==null:
			continue
		var obj = SimulationData.grid_logic.get(curr_pos)
		visited[curr_pos]=true
		obj.is_powered = true
		for i in range(20):
			for j in range(20):
				if SimulationData.grid_logic.get(curr_pos+Vector2i(i-10, j-10))==null:
					continue
				if visited.get(curr_pos+Vector2i(i-10, j-10))==true:
					continue
				if SimulationData.grid_logic.get(curr_pos+Vector2i(i-10, j-10)).leader == obj.leader:	
					q.push_back(curr_pos+Vector2i(i-10, j-10))
		for temp in obj.data.get_possible_neighbour(obj):
			var neighbours = temp[0]
			var dir = temp[1]
			# print(neighbours)
			if SimulationData.grid_logic.get(neighbours)==null: 
				continue
			var neighbor = SimulationData.grid_logic.get(SimulationData.grid_logic.get(neighbours).leader)
			if (not obj.data.get_port_type(obj, dir, curr_pos) == neighbor.data.get_port_type(neighbor, -dir, neighbours)) or obj.data.get_port_type(obj, dir, curr_pos)==0 :
				continue

			if visited.get(neighbours)!=null:
				continue
			q.push_back(neighbours)
	

func validate_move(from: Vector2i, to: Vector2i, item: ItemData, target_pos: Vector2i) -> bool:
	if not SimulationData.grid_logic.has(to): return false
	return SimulationData.grid_logic[to].can_accept(from, SimulationData.grid_logic[from].get_output_direction(), item, target_pos)

func _input(event):
	build_manager.handle_camera(event)

func _on_change_state(_toggled_on: bool) -> void:
	broken = false
	visual_step_count = 0
	for pos in SimulationData.grid_logic:
		SimulationData.grid_logic[pos].reset()
		while SimulationData.grid_logic[pos].held_items.size() > 0:
			SimulationData.grid_logic[pos].held_items.remove_at(0)
	current_state = State.SIMULATION if current_state == State.BUILDING else State.BUILDING
	refresh_tile_visuals()
	$CanvasLayer/Control/HBoxContainer.visible = (current_state == State.BUILDING)
	$CanvasLayer/Control/ChangeMode.release_focus()
