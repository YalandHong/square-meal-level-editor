extends Sprite2D

var current_block: int = 0
var target_block: int = 0

var moving: bool = false

var turning: bool = false
var turn_count: int = 0

var anim_sprite: AnimatedSprite2D

var target_x: float
var target_y: float

var side_walk_speed: float = 100
var walk_speed: float = 100

var player_id: int = 1

var dir: String = "DOWN"
var current_row: int = 0
var current_col: int = 0

# 调用GameManager来获取按键和地图信息
@export var game_manager: GameManager
@export var shadow_holder: ShadowManager # 拖入shadow_holder节点

# 在 _ready() 中初始化玩家
func _ready():
    # 假设你要在 (100, 200) 位置初始化玩家
    init_player(100, 200)

func _process(_delta):
    process_normal_actions()

# 初始化玩家位置
func init_player(start_x: float, start_y: float) -> void:
    position.x = start_x
    position.y = start_y
    
    # 获取当前的行列位置
    current_row = game_manager.get_row(position.y)
    current_col = game_manager.get_col(position.x)

    # 设置玩家默认的静止动画
    set_animation("stop_" + dir)

    # 设置玩家ID
    if name == "player":
        player_id = 1
    else:
        player_id = 2

    # 添加阴影并更新位置
    shadow_holder.add_player_shadow(player_id)
    var shadow = shadow_holder.get_node("shadow_" + str(player_id))
    shadow.position.x = position.x
    shadow.position.y = position.y + 5

# 设置动画
func set_animation(animation_name: String) -> void:
    # 使用 AnimatedSprite2D 的 play 方法来播放动画
    $AnimatedSprite2D.play(animation_name)

# 主逻辑，检测按键
func process_normal_actions():
    if Input.is_action_pressed("ui_select"):
        process_eat_or_spit()
    else:
        process_movement()

# 处理吃东西或吐方块的逻辑
func process_eat_or_spit():
    if current_block == 0 and target_block == 0:
        start_eat_block()
        return
    
    if current_block != 0:
        start_spit_block()

# 处理移动的逻辑
func process_movement():
    var direction_pressed = get_direction_pressed()
    if direction_pressed == "":
        process_idle_animation()
        return
    
    if direction_pressed != dir:
        dir = direction_pressed
        play_stop_animation()
        turning = true
        turn_count = 0
        return

    # 执行移动动画和移动逻辑
    play_walk_animation()
    if get_target():
        moving = true
        do_move()

# 停止动画
func play_stop_animation():
    if current_block == 0:
        anim_sprite.play("stop_" + dir)
    else:
        anim_sprite.play("stop_" + dir + "_fat")

# 行走动画
func play_walk_animation():
    if current_block == 0:
        anim_sprite.play("walk_" + dir)
    else:
        anim_sprite.play("walk_" + dir + "_fat")

# 停止移动时的动画处理
func process_idle_animation():
    if current_block == 0:
        anim_sprite.play("stop_" + dir)
    else:
        anim_sprite.play("stop_" + dir + "_fat")

# 模拟获取方向键的按键状态
func get_direction_pressed() -> String:
    if Input.is_action_pressed("ui_right"):
        return "right"
    elif Input.is_action_pressed("ui_left"):
        return "left"
    elif Input.is_action_pressed("ui_down"):
        return "down"
    elif Input.is_action_pressed("ui_up"):
        return "up"
    return ""

# 吃东西逻辑
func start_eat_block():
    print("Eating block...")

# 吐出方块逻辑
func start_spit_block():
    print("Spitting block...")

# 获取玩家是否可以移动到目标格子
func get_target() -> bool:
    var direction = get_direction_pressed() # 使用已实现的方向检测逻辑
    var target_row = current_row
    var target_col = current_col
    
    match direction:
        "LEFT":
            target_col -= 1
        "RIGHT":
            target_col += 1
        "UP":
            target_row -= 1
        "DOWN":
            target_row += 1
        _:
            return false # 如果没有方向按键，直接返回 false
    
    # 获取目标位置的中心坐标
    target_x = game_manager.get_tile_center_x(target_col)
    target_y = game_manager.get_tile_center_y(target_row)
    
    # 检查目标位置是否为空
    var is_empty = game_manager.get_empty(target_row, target_col)
    
    if player_count == 1:
        return is_empty
    elif player_count == 2:
        var other_player_row, other_player_col
        
        if player_id == 1:
            other_player_row = game_manager.get_player_row(2)
            other_player_col = game_manager.get_player_col(2)
        else:
            other_player_row = game_manager.get_player_row(1)
            other_player_col = game_manager.get_player_col(1)
        
        var row_diff = abs(target_row - other_player_row)
        var col_diff = abs(target_col - other_player_col)
        
        # TODO magic number
        if row_diff > 13 or col_diff > 11:
            return false
        return is_empty
    
    return false


# 玩家移动
func do_move():
    if dir == "":
        return
    
    if dir == "LEFT":
        position.x -= side_walk_speed * delta
    elif dir == "RIGHT":
        position.x += side_walk_speed * delta
    elif dir == "UP":
        position.y -= walk_speed * delta
    elif dir == "DOWN":
        position.y += walk_speed * delta

    # 更新玩家阴影位置
    var shadow = game_manager.shadow_holder["shadow_" + str(player_id)]
    shadow.position.x = position.x
    shadow.position.y = position.y + 5

    # 更新玩家深度和其他信息
    var depth = game_manager.get_row(position.y) * 1000 + game_manager.get_col(position.x) + 101
    z_index = depth
    update_players_array()
