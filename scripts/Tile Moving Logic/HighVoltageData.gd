extends MachineData
class_name HighVoltageMachineData

var voltage_type: int

func _init():
	voltage_type = 2

func get_port_type(object: GridObject, side_dir: Vector2i) -> int:
	return voltage_type 

func is_wire():
	return true
