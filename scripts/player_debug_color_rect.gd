extends ColorRect

var square_size : Vector2 = Vector2(10, 10)
var square_color : Color = Color("LIGHT_GREEN")

func _init():
    size = square_size
    color = square_color

func _process(_delta: float) -> void:
    var player: Player = get_node_or_null("../GameManager/Player")
    if player == null:
        visible = false
    else:
        visible = true
        position.x = GameManager.get_tile_top_left_x(player.current_col)
        position.y = GameManager.get_tile_top_left_y(player.current_row)
