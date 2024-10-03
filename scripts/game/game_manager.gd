class_name GameManager
extends Node

const TILE_WIDTH: int = GlobalVars.TILE_WIDTH
const TILE_HEIGHT: int = GlobalVars.TILE_HEIGHT

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
var level_map_floors: Array
var level_map_blocks: Array

# 滚动边界
var scroll_x_min: int
var scroll_x_max: int
var scroll_y_min: int
var scroll_y_max: int
var camera: Camera2D

# 通关相关
var enemy_count: int
var winner_timer: int
const MAX_WINNER_TIMER_BEFORE_CHEERING: int = 30
const MAX_WINNER_TIMER_BEFORE_WINNING: int = 90
var level_cleared: bool

# 计算滚动边界
func init_scroll_bounds() -> void:
    scroll_x_min = GlobalVars.VIEW_WIDTH / 2
    scroll_x_max = max(scroll_x_min, map_width * TILE_WIDTH - GlobalVars.VIEW_WIDTH / 2)
    scroll_y_min = GlobalVars.VIEW_HEIGHT / 2
    scroll_y_max = max(scroll_y_min, map_height * TILE_HEIGHT - GlobalVars.VIEW_HEIGHT / 2)

# 判断某一块是否为空
func is_empty(row: int, col: int) -> bool:
    return (level_map_blocks[row][col] == null
        and level_map_players[row][col] == null
        and level_map_movers[row][col] == null)
    # if level_map_movers[row][col] != "":
    #     return !map_holder[level_map_movers[row][col]].get_stunned()

func _init():
    # debug
    seed(0)

    var level_map = get_loaded_level_map(GlobalVarsSingleton.current_level_file)
    map_width = level_map[0].size()
    map_height = level_map.size()

    init_level_maps(level_map)
    init_scroll_bounds()
    level_cleared = false
    winner_timer = 0

func _ready() -> void:
    # 创建并设置 Camera2D
    camera = Camera2D.new()
    add_child(camera)
    camera.enabled = true
    camera.zoom = Vector2(
        float(GlobalVars.WINDOW_WIDTH) / GlobalVars.VIEW_WIDTH,
        float(GlobalVars.WINDOW_HEIGHT) / GlobalVars.VIEW_HEIGHT
    )
    scroll_game()

func _process(_delta: float) -> void:
    scroll_game()
    process_winning()

func get_loaded_level_map(file_path: String) -> Array:
    var array_2d
    if file_path.ends_with(".xml"):
        array_2d = LocalFileHelper.load_official_level_from_xml(file_path)
    else:
        array_2d = LocalFileHelper.read_level_map_tsv_file(file_path)
    assert(array_2d != null)
    return array_2d

static func calculate_depth(pos: Vector2) -> int:
    return int(pos.y / 4)

func update_players(player: Player, old_row: int, old_col: int, new_row: int, new_col: int):
    assert(is_same(level_map_players[old_row][old_col], player))
    level_map_players[old_row][old_col] = null
    assert(level_map_players[new_row][new_col] == null)
    level_map_players[new_row][new_col] = player

func update_blocks(block: Block, old_row: int, old_col: int, new_row: int, new_col: int):
    assert(is_same(level_map_blocks[old_row][old_col], block))
    level_map_blocks[old_row][old_col] = null
    assert(level_map_blocks[new_row][new_col] == null)
    level_map_blocks[new_row][new_col] = block

# TODO 某些敌人可能会叠在一起，比如leaping enemy
# 这时候mover map里的内容可能会相互覆盖，导致block/player等碰撞检测不准确
func update_movers(enemy: Enemy, old_row: int, old_col: int, new_row: int, new_col: int):
    level_map_movers[old_row][old_col] = null
    level_map_movers[new_row][new_col] = enemy

# 绘制地图
func init_level_maps(level_map: Array):
    level_map_movers = []
    level_map_players = []
    level_map_blocks = []
    level_map_floors = []
    enemy_count = 0
    for row in range(map_height):
        level_map_movers.append([])
        level_map_players.append([])
        level_map_blocks.append([])
        level_map_floors.append([])
        for col in range(map_width):
            var tile_type: int = level_map[row][col]

            # 初始化所有默认值为 null
            var mover = null
            var player = null
            var block = null
            var floor_tile = null

            if BlockFactory.is_valid_block_type(tile_type):
                block = BlockFactory.create_block(row, col, tile_type)
                add_child(block)
            elif EnemyFactory.is_valid_enemy_type(tile_type):
                mover = EnemyFactory.create_enemy(row, col, tile_type)
                add_child(mover)
                enemy_count += 1
            elif FloorFactory.is_valid_floor_type(tile_type):
                floor_tile = FloorFactory.create_floor(row, col, tile_type)
                add_child(floor_tile)
            elif tile_type == GlobalVars.ID_PLAYER:
                player = create_and_add_player(row, col)
            elif tile_type != GlobalVars.ID_EMPTY_TILE:
                print("unknown tile type: ", tile_type)

            # 将结果填充到对应的列表中
            level_map_movers[row].append(mover)
            level_map_players[row].append(player)
            level_map_blocks[row].append(block)
            level_map_floors[row].append(floor_tile)

func create_and_add_player(row: int, col: int) -> Player:
    var player_scene: PackedScene = preload("res://scenes/player.tscn")
    var player: Player = player_scene.instantiate()
    player.set_init_pos(row, col)

    add_child(player)
    return player

func is_eatable_tile(row: int, col: int) -> bool:
    var block: Block = level_map_blocks[row][col]
    if block == null:
        return false
    return block.is_eatable() and not block.is_being_eaten()

func is_eatable_enemy(row: int, col: int) -> bool:
    var enemy: Enemy = level_map_movers[row][col]
    if enemy == null:
        return false
    return enemy.stunned and not enemy.being_eaten

func get_tile_instance(row: int, col: int) -> Block:
    return level_map_blocks[row][col]

func get_player_instance(row: int, col: int) -> Player:
    return level_map_players[row][col]

func get_enemy_instance(row: int, col: int) -> Enemy:
    return level_map_movers[row][col]

# 从网格中移除块，但不会free
func remove_grid_element(map: Array, row: int, col: int) -> void:
    assert(map[row][col] != null)
    #var elem = map[row][col]
    map[row][col] = null
    #elem.queue_free()

func remove_block(row: int, col: int) -> void:
    assert(get_tile_instance(row, col) is Block)
    remove_grid_element(level_map_blocks, row, col)

func remove_player(row: int, col: int) -> void:
    assert(get_player_instance(row, col) is Player)
    remove_grid_element(level_map_players, row, col)

func remove_enemy(row: int, col: int) -> void:
    assert(get_enemy_instance(row, col) is Enemy)
    remove_grid_element(level_map_movers, row, col)
    enemy_count -= 1

func place_and_slide_new_block(block_type: int, row: int, col: int, start_dir: String) -> void:
    # 创建新的 Block 实例 (假设通过 block_type 加载不同的预制)
    var new_block: Block = BlockFactory.create_block(row, col, block_type)
    add_child(new_block)
    #level_map[row][col] = block_type
    level_map_blocks[row][col] = new_block

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
    new_block.start_slide(start_dir)

func scroll_game() -> void:
    # 目前只支持1个Player
    var player1: Player = get_node("Player")
    var scroll_center = player1.position

    #if player2 != null:
        ## 处理双玩家
        #var mid_x = (player1.position.x + player2.position.x) / 2
        #var mid_y = (player1.position.y + player2.position.y) / 2
        #scroll_x = -mid_x + viewport.size.x / 2
        #scroll_y = -mid_y + viewport.size.y / 2

    scroll_center.x = clamp(scroll_center.x, scroll_x_min, scroll_x_max)
    scroll_center.y = clamp(scroll_center.y, scroll_y_min, scroll_y_max)
    camera.position = scroll_center

func process_winning():
    if enemy_count == 0 and winner_timer < MAX_WINNER_TIMER_BEFORE_WINNING:
        winner_timer += 1
    if winner_timer >= MAX_WINNER_TIMER_BEFORE_CHEERING:
        level_cleared = true

func is_valid_row_col(row: int, col: int) -> bool:
    return row >= 0 and row < map_height and col >= 0 and col < map_width
