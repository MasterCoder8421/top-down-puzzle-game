extends Resource
class_name MachineData

@export var max_items = 0
var voltage_type = 0
var name: String = "Empty"
var tileId: int = -1
var atlas_coords: Vector2i = Vector2i(0, 0)
var size: Vector2i = Vector2i(1, 1)
var can_rotate: bool = false
var unbreakable: bool = false

func get_naame():
	return name

func get_tile_id():
	return tileId

func get_atlas_coords():
	return atlas_coords

func get_step_texture_update(_object: GridObject, _step_count: int):
	return false

func get_size():
	return size

func get_can_rotate():
	return can_rotate

func get_unbreakable():
	return unbreakable


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

func get_port_type(object: GridObject, side_dir: Vector2i, target_pos: Vector2i) -> int:
	return voltage_type

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

func update(object):
	pass
