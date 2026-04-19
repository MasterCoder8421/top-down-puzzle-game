extends MachineData
class_name OutputData
var first = true
var item_name : String

func _init(_item_name):
	max_items = 10
	item_name=_item_name
	
func get_display_item(object) -> ItemData:
	if object.held_items.size()>0:
		return object.held_items[0]
	return null

func get_target_pos(object) -> Vector2i:
	return object.pos

func get_output_direction(object):
	return object.direction

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return -_from_dir == object.direction && item_name == _item.name

func will_output(object) -> bool:
	return false

func along(object, val):
	if val >=0.5:
		while object.held_items.size()>0:
			object.held_items.pop_back()
	return lerp(Vector2(object.pos)+Vector2(0.5, 1), Vector2(object.pos)+Vector2(0.5, 0), val)

func get_next_output_item(object) -> ItemData:	
	return null
