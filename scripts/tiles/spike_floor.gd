extends FloorTile
class_name SpikeFloor

var floor_sprite: Sprite2D

func is_dangerous() -> bool:
    return true

func _ready() -> void:
    super._ready()
    floor_sprite = Sprite2D.new()
    var loaded_texture = preload("res://sprites/floor_tiles/spike.png")
    floor_sprite.texture = loaded_texture

func _process(_delta: float) -> void:
    check_hit_player()

func check_hit_player():
    # TODO
    pass
