extends Block
class_name WallBlock

func _ready() -> void:
    super._ready()
    var loaded_texture = load("res://sprites/block/wall/default.png")
    block_sprite.texture = loaded_texture

func be_exploded():
    pass
