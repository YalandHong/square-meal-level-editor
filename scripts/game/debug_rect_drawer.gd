extends Node2D

var game_manager: GameManager

# 封装矩形的绘制函数
func draw_single_rect(pos: Vector2, size: Vector2, color: Color):
    draw_rect(Rect2(pos, size), color)

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
                    GridHelper.get_tile_top_left_x(col),
                    GridHelper.get_tile_top_left_y(row)
                ),
                Vector2(GridHelper.TILE_WIDTH, GridHelper.TILE_HEIGHT),
                Color.RED
            )

func draw_sliding_block_rect(level_map_blocks: Array):
    var map_width: int = level_map_blocks[0].size()
    var map_height: int = level_map_blocks.size()
    for row in range(map_height):
        for col in range(map_width):
            var block: Block = level_map_blocks[row][col]
            if block == null or not block.sliding:
                continue
            draw_single_rect(
                Vector2(
                    GridHelper.get_tile_top_left_x(col),
                    GridHelper.get_tile_top_left_y(row)
                ),
                Vector2(GridHelper.TILE_WIDTH, GridHelper.TILE_HEIGHT),
                Color.DEEP_SKY_BLUE
            )

func draw_player_rect(player):
    if player == null:
        return
    draw_single_rect(
        Vector2(
            GridHelper.get_tile_top_left_x(player.current_col),
            GridHelper.get_tile_top_left_y(player.current_row)
        ),
        Vector2(GridHelper.TILE_WIDTH, GridHelper.TILE_HEIGHT),
        Color.LIGHT_GREEN
    )

# 重写 _draw()，调用封装好的绘制函数
func _draw():
    draw_enemy_rect(game_manager.level_map_movers)
    draw_sliding_block_rect(game_manager.level_map_blocks)
    draw_player_rect(game_manager.get_node("Player"))

# 在需要时更新绘制
func _process(_delta):
    queue_redraw()  # 触发重绘
