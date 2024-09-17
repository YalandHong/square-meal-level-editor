extends Node2D

var tile_width: int = GameManager.TILE_WIDTH
var tile_height: int = GameManager.TILE_HEIGHT
var grid_color: Color = Color(1, 1, 1) # 白色
var line_width: float = 1.0

func _draw():
    var full_area_size = Vector2(GlobalVars.VIEW_WIDTH*2, GlobalVars.VIEW_HEIGHT*2)
    var num_cols = int(full_area_size.x / tile_width) + 1
    var num_rows = int(full_area_size.y / tile_height) + 1

    var half_line_width = line_width / 2

    # 绘制垂直线
    for i in range(num_cols):
        var x = i * tile_width
        draw_line(Vector2(x + half_line_width, 0), Vector2(x + half_line_width, full_area_size.y), grid_color, line_width)

    # 绘制水平线
    for j in range(num_rows):
        var y = j * tile_height
        draw_line(Vector2(0, y + half_line_width), Vector2(full_area_size.x, y + half_line_width), grid_color, line_width)
