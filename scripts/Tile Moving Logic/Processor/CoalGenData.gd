extends MachineData
class_name CoalGenData
var timer = 0

var inputs = ["Coal"]
var TIMESET = 10

func _init():
	name = "Coal Generator"
	tileId = 3
	atlas_coords = Vector2i(0, 4)
	size = Vector2i(2, 1)
	can_rotate = false
	max_items = INF

func get_step_texture_update(_object: GridObject, _step_count: int):
	# Animate vertically in atlas column x=0 based on current generator timer.
	print("hello",maxi(0.0, timer)*1.0/TIMESET)
	return Vector2i(0, round(4-4.0*maxi(0, timer)*1.0/TIMESET))

func get_port_type(object: GridObject, side_dir: Vector2i, target_pos: Vector2i) -> int:
	if target_pos == (object.leader+Vector2i(1, 0)) and side_dir == Vector2i(1, 0):
		return 1
	return 0

func get_possible_neighbour(my_obj: GridObject):
	var my_pos = my_obj.leader
	return [
		[my_pos + Vector2i(2, 0), Vector2i(1, 0)], 
	]

func update(object):
	if timer <= 0:
		print("stop generating")
		object.is_generating = false
	else:
		timer -= 1
	if object.held_items.size() > 0:
		print(object.pos, "generating")
		object.is_generating = true
		timer = TIMESET

func get_display_item(object) -> ItemData:
	if object.held_items.size() > 0:
		return object.held_items[0]
	return null

func get_output_direction(object):
	return null

func get_target_pos(object) -> Vector2i:
	return Vector2i(2, 0)

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return _from_dir == Vector2i(1, 0) && _target_from ==(object.pos) && _item.name in inputs

func will_output(object) -> bool:
	return false


func reset():
	timer = 0

func along(object, val):
	if (val>0.5):
		object.held_items.pop_back()
	return lerp(Vector2(object.pos)+Vector2(0, 0.5), Vector2(object.pos)+Vector2(1, 0.5), val) 

func get_next_output_item(object) -> ItemData:
	return null
