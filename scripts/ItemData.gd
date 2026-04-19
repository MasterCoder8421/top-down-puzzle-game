extends RefCounted
class_name ItemData

var pos: Vector2i
var name: StringName
var color
var texture_id
var atlas_coords

var materials = {
	"Raw Iron": {"atlas_coord": Vector2i(0, 4)},
	"Iron": {"atlas_coord": Vector2i(1, 4)}
}

func _init(_pos: Vector2i, _name: String):
	pos = _pos
	name = _name
	color = Color(randf(), randf(), randf())
	atlas_coords = materials[name]["atlas_coord"]

func set_name(_name):
	name = _name
	atlas_coords = materials[name]["atlas_coord"]

func clone() -> ItemData:
	return ItemData.new(pos, name)
