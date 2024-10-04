extends Node2D
class_name Explosion

var explode_timer: int
#var explosive_source: GridElement
var current_row: int
var current_col: int
var game_manager: GameManager

func _init() -> void:
    explode_timer = 150
    position = Vector2(GridHelper.TILE_WIDTH / 2, -GridHelper.TILE_HEIGHT / 2)
    z_index = 1000

func _ready() -> void:
    $AnimatedSprite2D.visible = false
    $AnimatedSprite2D.stop()
    $AnimatedSprite2D.animation_finished.connect(_on_animated_finished)

func _process(_delta: float) -> void:
    assert(get_parent() != null)

    if explode_timer > 0:
        explode_timer -= 1
        var countdown = (explode_timer + 15) / 15
        $CountingFontLabel.displayed_text = str(countdown)
        return

    if explode_timer == 0:
        start_exploding()
        return

    if $AnimatedSprite2D.frame == 10:
        check_area()

# 计时结束，播放爆炸动画和音效
# 同时，将自己挂到game manager底下，因为自己的父节点会被炸掉
func start_exploding():
    explode_timer = -1
    var explosive_source: GridElement = get_parent()
    current_row = explosive_source.current_row
    current_col = explosive_source.current_col
    game_manager = explosive_source.game_manager
    explosive_source.remove_child(self)
    game_manager.add_child(self)
    position = Vector2(
        GridHelper.get_tile_top_left_x(current_col) + GridHelper.TILE_WIDTH / 2,
        GridHelper.get_tile_top_left_y(current_row)
    )

    $CountingFontLabel.visible = false
    $AnimatedSprite2D.visible = true
    $AnimatedSprite2D.play("explode")
    SfxPlayerSingleton.play_sfx("explode")

    if explosive_source is ExplosiveBlock:
        explosive_source.do_explode()

func check_area():
    for row in range(current_row - 1, current_row + 2):
        for col in range(current_col - 1, current_col + 2):
            var elem = game_manager.get_enemy_instance(row, col)
            if elem != null:
                elem.be_exploded()
            elem = game_manager.get_player_instance(row, col)
            if elem != null:
                elem.be_exploded()
            elem = game_manager.get_block_instance(row, col)
            if elem != null:
                elem.be_exploded()

func _on_animated_finished():
    queue_free()
