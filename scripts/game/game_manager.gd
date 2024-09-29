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
var level_map_floor: Array
var level_map_tiles: Array # TODO 这个或许应该叫level_map_blocks
#var players_map: Dictionary

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
    return (level_map_tiles[row][col] == null
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
    var mouse_displayer_scene: PackedScene = load("res://scenes/mouse_tracker.tscn")
    var mouse_tracker = mouse_displayer_scene.instantiate()
    add_child(mouse_tracker)

    # 创建并设置 Camera2D
    camera = Camera2D.new()
    add_child(camera)
    camera.enabled = true

    scroll_game()

func _process(_delta: float) -> void:
    scroll_game()
    process_winning()

func get_loaded_level_map(file_path: String) -> Array:
    var array_2d = LocalFileHelper.read_level_map_tsv_file(file_path)
    return array_2d

static func calculate_depth(pos: Vector2) -> int:
    return int(pos.y / 2)

static func update_grid_pos_for_grid_element(map: Array, grid_element,
        old_row: int, old_col: int, new_row: int, new_col: int):
    assert(is_same(map[old_row][old_col], grid_element))
    map[old_row][old_col] = null

    assert(map[new_row][new_col] == null)
    map[new_row][new_col] = grid_element

func update_players(player: Player, old_row: int, old_col: int, new_row: int, new_col: int):
    update_grid_pos_for_grid_element(level_map_players, player, old_row, old_col, new_row, new_col)

func update_blocks(block: Block, old_row: int, old_col: int, new_row: int, new_col: int):
    update_grid_pos_for_grid_element(level_map_tiles, block, old_row, old_col, new_row, new_col)

func update_movers(enemy: Enemy, old_row: int, old_col: int, new_row: int, new_col: int):
    update_grid_pos_for_grid_element(level_map_movers, enemy, old_row, old_col, new_row, new_col)

# 绘制地图
func init_level_maps(level_map: Array):
    level_map_movers = []
    level_map_players = []
    level_map_tiles = []
    enemy_count = 0
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

            if BlockFactory.is_valid_block_type(tile_type):
                tile = BlockFactory.create_block(row, col, tile_type)
                add_child(tile)
            elif EnemyFactory.is_valid_enemy_type(tile_type):
                mover = EnemyFactory.create_enemy(row, col, tile_type)
                add_child(mover)
                enemy_count += 1
            elif tile_type == GlobalVars.ID_PLAYER:
                player = create_and_add_player(row, col)
            elif tile_type != GlobalVars.ID_EMPTY_TILE:
                print("unknown tile type: ", tile_type)

            # 将结果填充到对应的列表中
            level_map_movers[row].append(mover)
            level_map_players[row].append(player)
            level_map_tiles[row].append(tile)

func create_and_add_player(row: int, col: int) -> Player:
    var player_scene: PackedScene = load("res://scenes/player.tscn")
    var player: Player = player_scene.instantiate()
    player.set_init_pos(row, col)

    add_child(player)
    return player

func is_eatable_tile(row: int, col: int) -> bool:
    var block: Block = level_map_tiles[row][col]
    if block == null:
        return false
    return block.is_eatable() and not block.is_being_eaten()

func is_eatable_enemy(row: int, col: int) -> bool:
    var enemy: Enemy = level_map_movers[row][col]
    if enemy == null:
        return false
    return enemy.stunned and not enemy.being_eaten

func get_tile_instance(row: int, col: int) -> Block:
    return level_map_tiles[row][col]

func get_player_instance(row: int, col: int) -> Player:
    return level_map_players[row][col]

func get_enemy_instance(row: int, col: int) -> Enemy:
    return level_map_movers[row][col]

# 移除块，并且destroy
func remove_grid_element(map: Array, row: int, col: int) -> void:
    assert(map[row][col] != null)
    var elem = map[row][col]
    map[row][col] = null
    elem.queue_free()

func remove_block(row: int, col: int) -> void:
    assert(get_tile_instance(row, col) is Block)
    remove_grid_element(level_map_tiles, row, col)

func remove_player(row: int, col: int) -> void:
    assert(get_player_instance(row, col) is Player)
    remove_grid_element(level_map_players, row, col)

func remove_enemy(row: int, col: int) -> void:
    assert(get_enemy_instance(row, col) is Enemy)
    remove_grid_element(level_map_movers, row, col)
    enemy_count -= 1

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
