extends ConveyerData
class_name ConveyerCurvedLeftData

func _init():
	super()
	name = "Conveyer Left"
	tileId = 1
	atlas_coords = Vector2i(14, 2)
	size = Vector2i(1, 1)
	can_rotate = true

func get_output_direction(object):
	return Vector2i(Vector2(object.direction).rotated(deg_to_rad(90)))

func get_target_pos(object) -> Vector2i:
	return object.pos +Vector2i(Vector2(object.direction).rotated(deg_to_rad(90)))

func can_accept(object, _from_pos: Vector2i, _from_dir: Vector2i, _item: ItemData, _target_from: Vector2i) -> bool:
	return object.direction == -_from_dir
	
func along(object, val):
	var pos = Vector2(object.pos)
	var forward = Vector2(object.direction)
	var start = Vector2(0, 0)
	var end = Vector2(0, 0)
	if forward==Vector2(0, 1):
		start = pos+Vector2(0.5, 1)
		end = pos+Vector2(0, 0.5)
	if forward==Vector2(-1, 0):
		start = pos+Vector2(0, 0.5)
		end = pos+Vector2(0.5, 0)
	if forward==Vector2(0, -1):
		start = pos+Vector2(0.5, 0)
		end = pos+Vector2(1, 0.5)
	if forward==Vector2(1, 0):
		start = pos+Vector2(1, 0.5)
		end = pos+Vector2(0.5, 1)
	var middle = pos+Vector2(0.5, 0.5)
	var mid_seg = (start + end) / 2
	var midmid = lerp(middle, mid_seg, 0.5)
	if (val <=0.5):
		return lerp(start, midmid, val*2)
	else:
		return lerp(midmid, end, val*2-1)
