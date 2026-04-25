extends MachineData
class_name ConveyerData

func _init():
	max_items = 1

func is_invalid(object) -> bool:
	return object.held_items.size() > max_items

func get_display_item(object: GridObject) -> ItemData:
	if object.held_items.size() > 0:
		return object.held_items[0]
	print("empty")
	return null

func will_output(object: GridObject) -> bool:
	return object.held_items.size() > 0

func get_next_output_item(object: GridObject) -> ItemData:
	if object.held_items.size() > 0:
		return object.held_items[0]
	return null
