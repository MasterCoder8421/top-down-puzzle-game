extends Node2D

enum State { BUILDING, SIMULATION }

var current_state = State.BUILDING
var broken = false
var last_time = 0.0
var step_duration = 1

@onready var tilemap = $TileMapLayer
@onready var tilemapmask = $TileMapMaskLayer
@onready var camera = $Camera2D
@onready var build_manager = $BuildManager
@onready var item_renderer = $ItemGridRenderer

func _ready():
	SimulationData.grid_logic[Vector2i(0, 0)] = GridObject.new(Vector2i(0, 0), Vector2i(0, 1), InputData.new("Raw Iron"))
	SimulationData.grid_logic[Vector2i(1, 0)] = GridObject.new(Vector2i(1, 0), Vector2i(0, 1), OutputData.new("Iron"))
	#SimulationData.grid_logic[Vector2i(-2, 0)] = GridObject.new(Vector2i(-2, 0), Vector2i(0, 1), InputData.new("Coal"))
	tilemap.set_cell(Vector2i(0, 0), 1, Vector2i(9, 7))
	tilemapmask.set_cell(Vector2i(0, 0), 2, Vector2i(9, 7))
	tilemap.set_cell(Vector2i(1, 0), 1, Vector2i(13, 7))
	tilemapmask.set_cell(Vector2i(1, 0), 2, Vector2i(13, 7))
	#tilemap.set_cell(Vector2i(-2, 0), 1, Vector2i(0, 7))
	#tilemapmask.set_cell(Vector2i(-2, 0), 1, Vector2i(0, 7))
	#for i in range(100):
		#for j in range(100):
			#SimulationData.grid_logic[Vector2i(i+10, j+10)] = GridObject.new(Vector2i(i+10, j+10), Vector2i(0, 1), ConveyerStraightData.new())
			#tilemap.set_cell(Vector2i(i+10, j+10), 1, Vector2i(1, 0))
			#tilemapmask.set_cell(Vector2i(i+10, j+10), 2, Vector2i(1, 0))

func _process(delta):
	build_manager.handle_panning()
	if current_state == State.SIMULATION and !broken:
		simulate_step(delta)
	
	if current_state == State.BUILDING:
		build_manager.process_build_logic()

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
				# print(pos, item.name)
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



func calculate_powered():
	print("Calculating...")
	var q = []
	for pos in SimulationData.grid_logic:
		if (SimulationData.grid_logic.get(pos) != null):
			var obj = SimulationData.grid_logic.get(pos)
			if obj.data is GeneratorData:
				q.push_back(pos)
	
	var visited = {}
	while (!q.is_empty()):
		var curr_pos = q.pop_front()
		if visited.get(curr_pos)==true:
			continue
		if SimulationData.grid_logic.get(curr_pos)==null:
			continue
		var obj = SimulationData.grid_logic.get(curr_pos)
		visited[curr_pos]=true
		print(curr_pos)
		for temp in obj.data.get_possible_neighbour(obj):
			var neighbours = temp[0]
			var dir = temp[1]
			if SimulationData.grid_logic.get(neighbours)==null: 
				continue
			if !obj.data.can_connect_to(obj, SimulationData.grid_logic.get(neighbours), dir):
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
	for pos in SimulationData.grid_logic:
		SimulationData.grid_logic[pos].reset()
		while SimulationData.grid_logic[pos].held_items.size() > 0:
			SimulationData.grid_logic[pos].held_items.remove_at(0)
	current_state = State.SIMULATION if current_state == State.BUILDING else State.BUILDING
	$CanvasLayer/Control/HBoxContainer.visible = (current_state == State.BUILDING)
	$CanvasLayer/Control/ChangeMode.release_focus()
