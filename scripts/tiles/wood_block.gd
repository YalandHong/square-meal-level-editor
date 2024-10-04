extends Block
class_name WoodBlock

@onready var wood_block_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _init() -> void:
    sliding = false

func is_eatable():
    return not sliding

func _ready() -> void:
    super._ready()
    wood_block_sprite.centered = false
    wood_block_sprite.offset.y = BLOCK_SPRITE_OFFSET_Y
    wood_block_sprite.play("normal")
    wood_block_sprite.animation_finished.connect(_on_break_animation_end)

func _on_break_animation_end():
    queue_free()

func finish_slide():
    do_break()

func do_hit_object():
    do_break()

func do_break():
    dir = NONE
    sliding = false
    SfxPlayerSingleton.play_sfx("wood_break")
    wood_block_sprite.offset.y = BLOCK_SPRITE_OFFSET_Y - 11
    wood_block_sprite.offset.x = -17
    wood_block_sprite.play("break")
    game_manager.remove_block(current_row, current_col)

func get_block_type() -> int:
    return GlobalVars.ID_WOOD_BLOCK
