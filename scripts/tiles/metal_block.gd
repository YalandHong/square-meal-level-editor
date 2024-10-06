extends Block
class_name MetalBlock

func is_eatable():
    return not sliding

func is_walkable():
    return false

func _init() -> void:
    super()
    start_slide_speed = 5

func _ready() -> void:
    super._ready()
    var loaded_texture = preload("res://sprites/block/metal.png")
    block_sprite.texture = loaded_texture

func get_block_type() -> int:
    return GlobalVars.ID_METAL_BLOCK

func slide() -> void:
    assert(dir != NONE)
    do_move()
    check_hit()
    if not reached_target():
        return
    position = Vector2(moving_target_x, moving_target_y)
    update_block_grid_pos()

    # metal block滑动时会减速
    if slide_speed == 1:
        finish_slide()
        return
    adjust_slide_speed()

    if try_step_forward_moving_target(dir):
        return
    if slide_speed > 1:  # Flash原版里没有这部分，是我自己随性加的
        if check_hit_rubber_block():
            return
        check_hit_wooden_block()
        check_hit_explosive_block()
    finish_slide()

func adjust_slide_speed():
    if slide_speed > 1:
        slide_speed -= 1
