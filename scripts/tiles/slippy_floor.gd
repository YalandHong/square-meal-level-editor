extends FloorTile
class_name SlippyFloor

@onready var floor_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    super._ready()
    floor_sprite.centered = false
    floor_sprite.offset = FLOOR_TILE_SPRITE_OFFSET
    set_random_sprite()

func _process(_delta: float) -> void:
    check_hit_player()

func check_hit_player():
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player != null:
        player.try_start_slipping()

func get_floor_type() -> int:
    return GlobalVars.ID_SLIPPY_FLOOR

# 随机设置精灵图像
func set_random_sprite():
    floor_sprite.stop()
    var spr_count = floor_sprite.sprite_frames.get_frame_count("default")
    floor_sprite.frame = randi() % spr_count
