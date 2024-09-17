class_name GameManager
extends Node

# 假设tile的宽度和高度
const TILE_WIDTH = 50
const TILE_HEIGHT = 30

# direction常量
const UP = GlobalVars.UP
const DOWN = GlobalVars.DOWN
const LEFT = GlobalVars.LEFT
const RIGHT = GlobalVars.RIGHT
const NONE = GlobalVars.NONE

# 关卡地图（二维）
var map_width: int
var map_height: int
#var level_map: Array
var level_map_movers: Array
var level_map_players: Array
var level_map_floor: Array
var level_map_tiles: Array
#var players_map: Dictionary

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
func is_empty(row: int, col: int) -> bool:
    return (level_map_tiles[row][col] == null
        and level_map_players[row][col] == null)
    # if level_map_movers[row][col] != "":
    #     return !map_holder[level_map_movers[row][col]].get_stunned()

func _init():
    var level_map = get_loaded_level_map("res://levels/test_level.txt")
    map_width = level_map[0].size()
    map_height = level_map.size()

    draw_level(level_map)
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
func update_players(player: Player, old_row: int, old_col: int, new_row: int, new_col: int):
    assert(is_same(level_map_players[old_row][old_col], player))
    level_map_players[old_row][old_col] = null

    assert(level_map_players[new_row][new_col] == null)
    level_map_players[new_row][new_col] = player

# 更新block位置
# 第三次出现这段update代码，就要重构了
func update_blocks(block: Block, old_row: int, old_col: int, new_row: int, new_col: int):
    assert(is_same(level_map_tiles[old_row][old_col], block))
    level_map_tiles[old_row][old_col] = null

    assert(level_map_tiles[new_row][new_col] == null)
    level_map_tiles[new_row][new_col] = block

# 绘制地图
func draw_level(level_map: Array):
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
                tile = BlockFactory.create_block(row, col, GlobalVars.ID_STONE_BLOCK)
                add_child(tile)
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

#func get_tile_type(row: int, col: int) -> int:
    #return get_tile_instance(row, col).get_block_type()

func get_tile_instance(row: int, col: int) -> Block:
    return level_map_tiles[row][col]

# 移除块
func remove_block(row: int, col: int) -> void:
    assert(level_map_tiles[row][col] != null)
    var block: Block = level_map_tiles[row][col]
    level_map_tiles[row][col] = null
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

func place_and_slide_new_block(block_type: int, row: int, col: int, dir: String) -> void:
    # 创建新的 Block 实例 (假设通过 block_type 加载不同的预制)
    var new_block: Block = BlockFactory.create_block(row, col, block_type)
    add_child(new_block)
    #level_map[row][col] = block_type
    level_map_tiles[row][col] = new_block

    # 根据滑动方向初始化 Block 的位置
    # TODO 之后再细调，我还不知道这里差了1个2个是什么作用
    #match dir:
        ## TODO 大量magic公式
        #LEFT:
            #new_block.position.x = col * TILE_WIDTH + TILE_WIDTH / 2
            #new_block.position.y = row * TILE_HEIGHT
            #level_map[row][col + 1] = block_type
            #level_map_tiles[row][col + 1] = new_block
        #RIGHT:
            #new_block.position.x = col * TILE_WIDTH - TILE_WIDTH / 2
            #new_block.position.y = row * TILE_HEIGHT
            #level_map[row][col - 1] = block_type
            #level_map_tiles[row][col - 1] = new_block
        #UP:
            #new_block.position.x = col * TILE_WIDTH
            #new_block.position.y = row * TILE_HEIGHT + TILE_HEIGHT / 2
            #level_map[row + 1][col] = block_type
            #level_map_tiles[row + 1][col] = new_block
        #DOWN:
            #new_block.position.x = col * TILE_WIDTH
            #new_block.position.y = row * TILE_HEIGHT - TILE_HEIGHT / 2
            #level_map[row - 1][col] = block_type
            #level_map_tiles[row - 1][col] = new_block

    # 启动 Block 的滑动逻辑
    new_block.start_slide(dir)
