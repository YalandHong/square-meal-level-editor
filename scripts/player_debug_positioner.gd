extends ColorRect

var square_size : Vector2 = Vector2(GameManager.TILE_WIDTH, GameManager.TILE_HEIGHT)
var square_color : Color = Color(1, 1, 1)

func _init():
    size = square_size
    color = square_color

func _process(delta: float) -> void:
    var player: Player = get_node_or_null("../GameManager/Player")
    if player == null:
        visible = false
    else:
        visible = true
        position.x = GameManager.get_tile_top_left_x(player.current_col)
        position.y = GameManager.get_tile_top_left_y(player.current_row)
