class_name GameManager
extends Node2D

# GameManager 负责游戏全局的逻辑

# 假设tile的宽度和高度
const TILE_WIDTH = 50
const TILE_HEIGHT = 30

# 关卡地图（二维）
var map_width: int
var map_height: int
var level_map: Array
var players_map: Dictionary

# 滚动边界
var scroll_x_min: int
var scroll_x_max: int
var scroll_y_min: int
var scroll_y_max: int

# 计算滚动边界
func init_scroll_bounds() -> void:
    # TODO magic numbers 房间大小
    scroll_x_min = 550 - map_width * TILE_WIDTH
    scroll_x_max = 0
    scroll_y_min = 400 - map_height * TILE_HEIGHT
    scroll_y_max = 0

# 返回给定列的tile的中心X坐标
static func get_tile_center_x(col: int) -> float:
    return col * TILE_WIDTH + TILE_WIDTH / 2

# 返回给定行的tile的中心Y坐标
static func get_tile_center_y(row: int) -> float:
    # TODO magic number 10
    return row * TILE_HEIGHT + TILE_HEIGHT / 2 + 10

# 判断某一块是否为空
func get_empty(row: int, col: int) -> bool:
    # 假设有 level_map, level_map_players, level_map_movers
    if level_map[row][col] != 0:
        return false
    # TODO 暂未实现
    # if level_map_players[row][col] == "player" or level_map_players[row][col] == "player2":
    #     return false
    # if level_map_movers[row][col] != "":
    #     return !map_holder[level_map_movers[row][col]].get_stunned()
    return true

# 计算某一块的深度，作为z_index
static func calculate_depth(row: int, col: int) -> int:
    # TODO magic numbers
    return row * 1000 + col + 101

# 提供 getter 方法
func get_tile_width() -> int:
    return TILE_WIDTH

func get_tile_height() -> int:
    return TILE_HEIGHT

func _init():
    # 获取全局的 loaded_level_map 数据
    level_map = get_loaded_level_map() # 假设全局有一个函数能获取 loaded_level_map

    # 设定地图的宽高
    map_width = level_map[0].size()
    map_height = level_map.size()

    init_scroll_bounds()

    draw_level()

# 绘制地图
func draw_level() -> void:
    # TODO 添加绘制关卡的具体逻辑
    pass

# level map是二维数组，但现在Godot对于Array[Array]的类型提示支持有问题
func get_loaded_level_map() -> Array:
    var array_2d := []
    for i in range(10):
        array_2d.append([])
        for j in range(10):
            array_2d[i].append(0)
    return array_2d

# 用于获取行
static func get_row(y: float) -> int:
    return int(y / TILE_HEIGHT)

# 用于获取列
static func get_col(x: float) -> int:
    return int(x / TILE_WIDTH)

# 更新玩家位置
func update_players(player_name: String, old_row: int, old_col: int, new_row: int, new_col: int):
    # 将玩家从旧位置移除
    if players_map.has(Vector2(old_row, old_col)):
        players_map.erase(Vector2(old_row, old_col))

    # 在新位置更新玩家
    players_map[Vector2(new_row, new_col)] = player_name
