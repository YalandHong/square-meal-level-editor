extends Block
class_name ExplosiveBlock

# 开始倒计时
var triggered: bool = false
# 倒计时结束，进入爆炸状态
var exploding: bool = false

var explosion: Explosion

func is_eatable():
    return not sliding and not exploding

func _ready() -> void:
    super._ready()
    var loaded_texture = preload("res://sprites/block/explosive.png")
    block_sprite.texture = loaded_texture

func get_block_type() -> int:
    return GlobalVars.ID_EXPLOSIVE_BLOCK

func finish_slide():
    sliding = false
    SfxPlayerSingleton.play_sfx("block_stops")
    dir = NONE
    try_trigger_countdown()

func try_trigger_countdown() -> bool:
    if triggered:
        return false
    explosion = preload("res://scenes/tile/explosion.tscn").instantiate()
    explosion.explosive_source = self
    add_child(explosion)
    triggered = true
    return true

# 爆炸的一瞬间，方块被移除
# 这里和原版Flash有区别，原版是在爆炸结束时移除的
func do_explode():
    exploding = true
    game_manager.remove_block(current_row, current_col)
    queue_free()

# 被别的东西炸了，立刻触发自己爆炸
func be_exploded():
    if exploding:
        return
    if triggered:
        explosion.start_exploding()
        return
    triggered = true
    explosion = preload("res://scenes/tile/explosion.tscn").instantiate()
    explosion.explode_timer = 0
    explosion.explosive_source = self
    add_child(explosion)
