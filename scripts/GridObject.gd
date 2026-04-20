extends RefCounted
class_name GridObject

var pos: Vector2i
var direction: Vector2i
var data: MachineData
var held_items: Array = [] 
var leader: Vector2i
var is_powered = false
var is_generating = false

func _init(_pos: Vector2i, _dir: Vector2i, _data: MachineData):
	pos = _pos
	direction = _dir
	data = _data
	leader = pos


func get_display_item() -> ItemData:
	return data.get_display_item(self)

func get_target_pos() -> Vector2i:
	return data.get_target_pos(self)

func can_accept(from_pos: Vector2i, from_dir: Vector2i, item: ItemData, target_pos: Vector2i) -> bool:
	return data.can_accept(self, from_pos, from_dir, item, target_pos)

func will_output() -> bool:
	return data.will_output(self)

func reset():
	is_powered=false
	return data.reset()

func get_next_output_item() -> ItemData:
	return data.get_next_output_item(self)

func get_output_direction() -> Vector2i:
	return data.get_output_direction(self)

func push_item(item: ItemData) -> void:
	held_items.append(item)

func pop_item(item: ItemData) -> void:
	held_items.erase(item)

func is_invalid() -> bool:
	return data.is_invalid(self)

func along(val: float):
	return data.along(self, val)

func clone() -> GridObject:
	var new_obj = GridObject.new(pos, direction, data)
	new_obj.held_items = held_items.duplicate()
	return new_obj
