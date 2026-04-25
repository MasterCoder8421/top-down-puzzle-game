extends MachineData
class_name LowVoltageMachineData

func _init():
	name = "Low Voltage Wirte"
	tileId = 0
	atlas_coords = Vector2i(0, 0)
	size = Vector2i(1, 1)
	can_rotate = false
	voltage_type = 1


func is_wire():
	return true
