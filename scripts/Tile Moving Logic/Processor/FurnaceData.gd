extends MachineData
class_name FurnaceData
var TIMESET = 1
var timer = 0
var prev_val = 0

var SMELT_TABLE = {"Raw Iron": "Iron"}

func _init():
	max_items = 1


func get_display_item(object) -> ItemData:
	if object.held_items.size() > 0:
		return object.held_items[0]
	return null

func get_output_direction(object):
	return Vector2i(1, 0)

func get_target_pos(object) -> Vector2i:
	return object.pos + Vector2i(3, 1)

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return _from_dir == Vector2i(1, 0) && _target_from ==(object.pos+Vector2i(0, 1)) && _item.name in SMELT_TABLE

func will_output(object) -> bool:
	if object.held_items.size() > 0:
		timer+=1
		if timer >=TIMESET:
			timer = 0
			return true
		else:
			return false
	else:
		return false


func reset():
	timer = 0
	
func along(object, val):
	val = (timer+val)/TIMESET
	if (val>0.5 && prev_val <= 0.5):
		object.held_items[0] = smelt(object.held_items[0])
	prev_val=val
	return lerp(Vector2(object.pos)+Vector2(0, 1.5), Vector2(object.pos)+Vector2(3, 1.5), val)
	
func smelt(item: ItemData) -> ItemData:
	item.set_name(SMELT_TABLE[item.name])
	return item
	

func get_next_output_item(object) -> ItemData:
	if object.held_items.size() > 0:
		return object.held_items[0]
	return null
