extends GeneratorData
class_name CoalGenData
var prev_val = 0
var is_generating = true;

var inputs = ["Coal"]

func _init():
	max_items = 1
	
func get_port_type(object: GridObject, side_dir: Vector2i) -> int:
	return 1
	
func _update():
	is_generating = true;

func get_display_item(object) -> ItemData:
	if object.held_items.size() > 0:
		return object.held_items[0]
	return null

func get_output_direction(object):
	return null

func get_target_pos(object) -> Vector2i:
	return Vector2i(2, 0)

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return _from_dir == Vector2i(1, 0) && _target_from ==(object.pos+Vector2i(-1, 0)) && _item.name in inputs

func will_output(object) -> bool:
	return false


func reset():
	is_generating = true

func along(object, val):
	if (val>0.5):
		object.held_items.pop_back()
		is_generating = true
	prev_val=val

func get_next_output_item(object) -> ItemData:
	return null
