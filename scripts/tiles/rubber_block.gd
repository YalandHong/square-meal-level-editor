extends Block
class_name RubberBlock

@onready var rubber_block_sprite: AnimatedSprite2D = $AnimatedSprite2D

func is_eatable():
    return not sliding

func _ready() -> void:
    super._ready()
    rubber_block_sprite.centered = false
    rubber_block_sprite.offset.x = -2
    rubber_block_sprite.offset.y = BLOCK_SPRITE_OFFSET_Y - 2
    rubber_block_sprite.play("normal")

func finish_slide():
    slide_speed -= 2
    if slide_speed == 0:
        super.finish_slide()
        return
    # bounce
    dir = GridHelper.get_opposite_direction(dir)
    try_step_forward_moving_target(dir)
    do_wobble()

func get_block_type() -> int:
    return GlobalVars.ID_RUBBER_BLOCK

func do_wobble():
    SfxPlayerSingleton.play_sfx("rubble_bounce")
    rubber_block_sprite.play("wobble")
