extends ColorRect

var square_size : Vector2 = Vector2(GameManager.TILE_WIDTH, GameManager.TILE_HEIGHT)
var square_color : Color = Color(1, 1, 1)

var player: Player

func _init():
    size = square_size
    color = square_color

func _ready() -> void:
    player = get_node("../Player")

func _process(delta: float) -> void:
    position.x = player.current_row
    position.y = player.current_col
