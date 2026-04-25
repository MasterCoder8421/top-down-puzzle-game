extends ConveyerData
class_name ConveyerStraightData

func _init():
	super()
	name = "Conveyer"
	tileId = 1
	atlas_coords = Vector2i(11, 1)
	size = Vector2i(1, 1)
	can_rotate = true


func get_output_direction(object):
	return object.direction

func get_target_pos(object: GridObject) -> Vector2i:
	return object.pos + object.direction

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return object.direction == _from_dir

func along(object, val):
	var pos = Vector2(object.pos)
	var forward = Vector2(object.direction)
	
	if forward==Vector2(0, 1):
		return lerp(pos+Vector2(0.5, 0), pos+Vector2(0.5, 1), val)
	if forward==Vector2(-1, 0):
		return lerp(pos+Vector2(1, 0.5), pos+Vector2(0, 0.5), val)
	if forward==Vector2(0, -1):
		return lerp(pos+Vector2(0.5, 1), pos+Vector2(0.5, 0), val)
	if forward==Vector2(1, 0):
		return lerp(pos+Vector2(0, 0.5), pos+Vector2(1, 0.5), val)
	
