extends ColorRect

var square_size : Vector2 = Vector2(4, 4)
var square_color : Color = Color(1, 0, 0)

func _init():
    # 创建 ColorRect
    # color_rect = ColorRect.new()
    size = square_size
    color = square_color
    # position = square_position
