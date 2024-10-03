extends FloorTile
class_name SpikeFloor

var floor_sprite: Sprite2D

func _ready() -> void:
    super._ready()
    floor_sprite = Sprite2D.new()
    var loaded_texture = preload("res://sprites/floor_tiles/spike.png")
    floor_sprite.centered = false
    floor_sprite.texture = loaded_texture
    floor_sprite.offset = FLOOR_TILE_SPRITE_OFFSET
    add_child(floor_sprite)

func _process(_delta: float) -> void:
    check_hit_player()

func check_hit_player():
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player != null:
        player.die()

func get_floor_type() -> int:
    return GlobalVars.ID_SPIKE_FLOOR
