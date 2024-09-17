extends Block
class_name WallBlock

func _ready() -> void:
    super._ready()
    var loaded_texture = load("res://sprites/block/wall/default.png")
    texture = loaded_texture
