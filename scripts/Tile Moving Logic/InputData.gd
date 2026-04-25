extends MachineData
class_name InputData
var first = true
var item_name = ""
var timer = 0
var TIME_SET = 5

func _init(_item_name, _time_set: int = 5):
	max_items = 1
	item_name = _item_name
	TIME_SET = maxi(1, _time_set)
	
func get_display_item(object) -> ItemData:
	return null

func get_target_pos(object) -> Vector2i:
	return object.pos + object.direction

func get_output_direction(object):
	return object.direction

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return false

func will_output(object) -> bool:
	if timer >= TIME_SET:
		timer = 0
		return true
	timer+=1
	return false

func get_next_output_item(object) -> ItemData:	
	var new_obj = ItemData.new(object.pos, item_name)
	object.push_item(new_obj)
	return new_obj
