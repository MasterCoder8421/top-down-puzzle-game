extends Resource
class_name MachineData

@export var max_items = 0

func _init():
	max_items=0

func get_display_item(object) -> ItemData:
	return null

func is_invalid(object) -> bool:
	return object.held_items.size() > max_items

func get_output_direction(object):
	return Vector2(0, 0)

func get_target_pos(object) -> Vector2i:
	return object.pos

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return false

func will_output(object) -> bool:
	return false

func along(object, val):
	return object.pos

func get_port_type(object: GridObject, side_dir: Vector2i) -> int:
	# 0 = None, 1 = Low, 2 = High
	return 0

func reset():
	pass

func get_next_output_item(object: GridObject) -> ItemData:
	return null

func is_wire():
	return false

func get_possible_neighbour(my_obj: GridObject):
	var my_pos = my_obj.pos
	return [
		[my_pos + Vector2i(0, 1), Vector2i(0, 1)], 
		[my_pos + Vector2i(0, -1), Vector2i(0, -1)], 
		[my_pos + Vector2i(1, 0), Vector2i(1, 0)], 
		[my_pos + Vector2i(-1, 0), Vector2i(-1, 0)]
	]

func can_connect_to(my_obj: GridObject, neighbor_obj: GridObject, dir_to_neighbor: Vector2i) -> bool:
	var my_port = self.get_port_type(my_obj, dir_to_neighbor)
	var neighbor_port = neighbor_obj.data.get_port_type(neighbor_obj, -dir_to_neighbor)	
	return my_port != 0 and my_port == neighbor_port
