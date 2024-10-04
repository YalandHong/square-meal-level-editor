extends Block
class_name ExplosiveBlock

var triggered: bool = false
var exploding: bool = false

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
    var explosion = Explosion.new()
    triggered = true
    return true

# 被别的东西炸了，立刻触发自己爆炸
func be_exploded():
    if exploding:
        return
    # TODO 连环爆炸
    pass

# 爆炸的一瞬间，方块被移除
# 这里和原版Flash有区别，原版是在爆炸结束时移除的
func do_explode():
    exploding = true
    queue_free()
