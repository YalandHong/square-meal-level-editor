extends Node2D

@export var tile_width: int = 32
@export var tile_height: int = 32
@export var grid_color: Color = Color(1, 1, 1) # 白色
@export var line_width: float = 1.0

func _draw():
    var viewport_size = get_viewport_rect().size
    var num_cols = int(viewport_size.x / tile_width) + 1
    var num_rows = int(viewport_size.y / tile_height) + 1

    var half_line_width = line_width / 2

    # 绘制垂直线
    for i in range(num_cols):
        var x = i * tile_width
        draw_line(Vector2(x + half_line_width, 0), Vector2(x + half_line_width, viewport_size.y), grid_color, line_width)

    # 绘制水平线
    for j in range(num_rows):
        var y = j * tile_height
        draw_line(Vector2(0, y + half_line_width), Vector2(viewport_size.x, y + half_line_width), grid_color, line_width)
