extends ColorRect

var square_size : Vector2 = Vector2(GameManager.TILE_WIDTH, GameManager.TILE_HEIGHT)
var square_color : Color = Color(1, 1, 1)

func _init():
    # 创建 ColorRect
    # color_rect = ColorRect.new()
    size = square_size
    color = square_color
    # position = square_position
