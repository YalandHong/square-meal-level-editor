extends Node2D

var game_manager: GameManager

# 封装矩形的绘制函数
func draw_single_rect(position: Vector2, size: Vector2, color: Color):
    draw_rect(Rect2(position, size), color)

func _ready() -> void:
     game_manager = get_node("../GameManager")

func draw_enemy_rect(level_map_movers: Array):
    var map_width: int = level_map_movers[0].size()
    var map_height: int = level_map_movers.size()
    for row in range(map_height):
        for col in range(map_width):
            if level_map_movers[row][col] == null:
                continue
            draw_single_rect(
                Vector2(
                    GameManager.get_tile_top_left_x(col),
                    GameManager.get_tile_top_left_y(row)
                ),
                Vector2(GameManager.TILE_WIDTH, GameManager.TILE_HEIGHT),
                Color(1, 0, 0)
            )

# 重写 _draw()，调用封装好的绘制函数
func _draw():
    draw_enemy_rect(game_manager.level_map_movers)

# 在需要时更新绘制
func _process(_delta):
    queue_redraw()  # 触发重绘
