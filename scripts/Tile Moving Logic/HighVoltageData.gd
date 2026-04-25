extends MachineData
class_name HighVoltageMachineData

func _init():
	name = "High Voltage Wirte"
	tileId = 0
	atlas_coords = Vector2i(1, 0)
	size = Vector2i(1, 1)
	can_rotate = false
	voltage_type = 2

func is_wire():
	return true
