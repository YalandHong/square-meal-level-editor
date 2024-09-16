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
var level_map_movers: Array
var level_map_players: Array
var level_map_floor: Array
var level_map_tiles: Array
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

# 返回给定列的tile的左上角X坐标
static func get_tile_top_left_x(col: int) -> float:
    return col * TILE_WIDTH

# 返回给定行的tile的左上角Y坐标
static func get_tile_top_left_y(row: int) -> float:
    return row * TILE_HEIGHT

# 返回给定列的tile的中心X坐标
static func get_tile_center_x(col: int) -> float:
    return get_tile_top_left_x(col) + TILE_WIDTH / 2.0

# 返回给定行的tile的中心Y坐标
static func get_tile_center_y(row: int) -> float:
    # TODO magic number 10
    return get_tile_top_left_y(row) + TILE_HEIGHT / 2.0 + 10

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

func _init():
    level_map = get_loaded_level_map("res://levels/test_level.txt")
    map_width = level_map[0].size()
    map_height = level_map.size()

    draw_level()
    init_scroll_bounds()

func _ready() -> void:
    var mouse_displayer_scene: PackedScene = load("res://scenes/mouse_tracker.tscn")
    var mouse_tracker = mouse_displayer_scene.instantiate()
    add_child(mouse_tracker)

# level map是二维数组，但现在Godot对于Array[Array]的类型提示支持有问题
func get_loaded_level_map(file_path: String) -> Array:
    #var array_2d := []
    #for i in range(10):
        #array_2d.append([])
        #for j in range(10):
            #array_2d[i].append(0)
    #array_2d[5][5] = GlobalVars.ID_STONE_BLOCK
    #array_2d[8][2] = GlobalVars.ID_STONE_BLOCK
    #array_2d[6][6] = GlobalVars.ID_PLAYER
    #array_2d[8][8] = GlobalVars.ID_FOOD_BLOCK[0]
    #array_2d[2][8] = GlobalVars.ID_FOOD_BLOCK[0]
    #array_2d[1][0] = GlobalVars.ID_FOOD_BLOCK[0]
    var array_2d = read_level_map_txt_file(file_path)
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

# 绘制地图
func draw_level():
    level_map_movers = []
    level_map_players = []
    level_map_tiles = []
    for row in range(map_height):
        level_map_movers.append([])
        level_map_players.append([])
        level_map_tiles.append([])
        for col in range(map_width):
            var tile_type: int = level_map[row][col]

            # 初始化所有默认值为 null
            var mover = null
            var player = null
            var tile = null

            if tile_type == GlobalVars.ID_STONE_BLOCK:
                tile = create_stone_block(row, col)
            elif tile_type == GlobalVars.ID_PLAYER:
                player = create_player(row, col)
                level_map[row][col] = GlobalVars.ID_EMPTY_TILE
            elif tile_type in GlobalVars.ID_FOOD_BLOCK:
                tile = create_food_block(row, col)
            elif tile_type != GlobalVars.ID_EMPTY_TILE:
                print("unknown tile type: ", tile_type)

            # 将结果填充到对应的列表中
            level_map_movers[row].append(mover)
            level_map_players[row].append(player)
            level_map_tiles[row].append(tile)

func create_stone_block(row: int, col: int) -> StoneBlock:
    # 动态加载 StoneBlock 预制场景
    var stone_block_scene: PackedScene = load("res://scenes/tiles/stone_block.tscn")
    var stone_block: StoneBlock = stone_block_scene.instantiate()
    stone_block.set_block_grid_pos(row, col)

    # 将 StoneBlock 加入到当前地图场景中
    add_child(stone_block)
    return stone_block

func create_player(row: int, col: int) -> Player:
    var player_scene: PackedScene = load("res://scenes/player.tscn")
    var player: Player = player_scene.instantiate()
    player.set_player_init_pos(row, col)

    add_child(player)
    return player

func create_food_block(row: int, col: int) -> Block:
    var block_scene: PackedScene = load("res://scenes/tiles/food_block.tscn")
    var block_obj: Block = block_scene.instantiate()
    block_obj.set_block_grid_pos(row, col)

    add_child(block_obj)
    return block_obj

func is_eatable_tile(row: int, col: int) -> bool:
    var block: Block = level_map_tiles[row][col]
    if block == null:
        return false
    return block.is_eatable() and not block.is_being_eaten()

func get_tile_type(row: int, col: int) -> int:
    return level_map[row][col]

func get_tile_instance(row: int, col: int) -> Block:
    return level_map_tiles[row][col]

# 移除块
func remove_block(row: int, col: int) -> void:
    assert(level_map[row][col] != GlobalVars.ID_EMPTY_TILE)
    var block: Block = level_map_tiles[row][col]
    level_map_tiles[row][col] = null
    level_map[row][col] = GlobalVars.ID_EMPTY_TILE
    block.queue_free()  # 移除方块

static func read_level_map_txt_file(file_path: String) -> Array:
    var file = FileAccess.open(file_path, FileAccess.READ)

    if not file:
        print("Error opening file!")
        return []

    var result_array: Array = []

    while not file.eof_reached():
        var line = file.get_line().strip_edges()  # 读取一行并移除首尾空格
        if line == "":
            continue  # 跳过空行

        var values = line.split("\t", false)
        var numeric_values = []

        # 将字符串转换为数字
        for value in values:
            numeric_values.append(value.to_float())

        result_array.append(numeric_values)  # 将每行的数字数组添加到二维数组中

    file.close()
    return result_array
