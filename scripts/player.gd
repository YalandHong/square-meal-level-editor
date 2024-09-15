class_name Player
extends Sprite2D

var current_block: int = 0
var target_block: int = 0

@onready var anim_sprite: AnimatedSprite2D = $PlayerSprite
@onready var debug_rect: ColorRect = $PlayerDebugColorRect

var game_manager: GameManager
var shadow_holder: ShadowManager

# enum DirectionState {UP, DOWN, LEFT, RIGHT, NONE}
const UP = "up"
const DOWN = "down"
const LEFT = "left"
const RIGHT = "right"
const NONE = ""

enum PlayerState {MOVING, TURNING, IDLE, SLIPPING, EATING, SPITTING}
var state: PlayerState

# var moving: bool = false

# var turning: bool = false
var turn_count: int = 0
const MAX_TURN_COUNT: int = 3

var target_x: float
var target_y: float

const SIDE_WALK_SPEED: float = 5
const WALK_SPEED: float = 5

var player_id: int = 1

var dir: String
var current_row: int = 0
var current_col: int = 0

# 在 _ready() 中初始化玩家
func _ready():
	# 假设你要在 (100, 200) 位置初始化玩家
	init_player(5, 5)

# 初始化玩家位置
func init_player(start_x: float, start_y: float) -> void:
	game_manager = get_node("../GameManager")
	shadow_holder = get_node("../ShadowManager")
	
	position.x = start_x
	position.y = start_y
	
	# 获取当前的行列位置
	current_row = GameManager.get_row(position.y)
	current_col = GameManager.get_col(position.x)

	state = PlayerState.IDLE
	dir = DOWN
	anim_sprite.play("stop_" + dir)

	# 设置玩家ID
	# TODO 暂不支持多人游戏
	# if name == "player":
	#     player_id = 1
	# else:
	#     player_id = 2

	# 添加阴影并更新位置
	# TODO 暂不支持
	# shadow_holder.add_player_shadow(player_id)
	# var shadow = shadow_holder.get_node("shadow_" + str(player_id))
	# shadow.position.x = position.x
	# shadow.position.y = position.y + 5

func _process(_delta):
	match state:
		PlayerState.IDLE:
			process_idle()
		PlayerState.MOVING, PlayerState.SLIPPING:
			process_moving_or_slipping()
		PlayerState.TURNING:
			process_turning()
	# debug target x/y
	debug_rect.position = Vector2(target_x, target_y)

func process_moving_or_slipping():
	do_move()

	# 如果玩家到达目标位置，停止移动
	if ((dir == LEFT and position.x <= target_x) or
		(dir == RIGHT and position.x >= target_x) or
	   (dir == UP and position.y <= target_y) or
	   (dir == DOWN and position.y >= target_y)):
		
		position.x = target_x
		position.y = target_y
		# TODO shadow
		# shadow_manager.update_shadow_position(player_id, position.x, position.y + 5)
		
		update_players_array()

		# slipping = false
		# moving = false
		game_manager.check_floor_tiles(current_row, current_col, name)
		state = PlayerState.IDLE
		return
	
	if state == PlayerState.SLIPPING:
		return

	# 检查按键转向
	var new_direction = get_direction_pressed()
	if new_direction == NONE or new_direction == dir:
		return
	
	# 如果按键方向相反且目标可以移动
	if is_opposite_direction(new_direction) and get_target(new_direction):
		dir = new_direction
		# moving = true
		do_move()
		if current_block == 0:
			anim_sprite.play("walk_" + dir)
		else:
			anim_sprite.play("walk_" + dir + "_fat")

# 判断是否为相反方向
func is_opposite_direction(new_dir: String) -> bool:
	return ((dir == LEFT and new_dir == RIGHT) or
		   (dir == RIGHT and new_dir == LEFT) or
		   (dir == UP and new_dir == DOWN) or
		   (dir == DOWN and new_dir == UP))


# 主逻辑，检测按键
func process_idle():
	if Input.is_action_pressed("ui_select"):
		start_eat_or_spit()
		return
	
	# 处理移动的逻辑
	var direction_pressed = get_direction_pressed()
	if direction_pressed == NONE:
		play_stop_animation()
		return
	
	change_dir(direction_pressed)

	if direction_pressed != dir:
		dir = direction_pressed
		play_stop_animation()
		# turning = true
		state = PlayerState.TURNING
		turn_count = 0
		return

	# 执行移动动画和移动逻辑
	play_walk_animation()
	if get_target(direction_pressed):
		# moving = true
		do_move()

# 处理吃东西或吐方块的逻辑
func start_eat_or_spit():
	if current_block == 0 and target_block == 0:
		start_eat_block()
		return
	
	if current_block != 0:
		start_spit_block()
	
func change_dir(direction_pressed: String):
	dir = direction_pressed
	#if direction_pressed == LEFT:
		#flip_h = true
	#else:
		#flip_h = false

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

# 模拟获取方向键的按键状态
func get_direction_pressed() -> String:
	if Input.is_action_pressed("ui_right"):
		return RIGHT
	if Input.is_action_pressed("ui_left"):
		return LEFT
	if Input.is_action_pressed("ui_down"):
		return DOWN
	if Input.is_action_pressed("ui_up"):
		return UP
	return NONE

# 吃东西逻辑
func start_eat_block():
	print("Eating block...")

# 吐出方块逻辑
func start_spit_block():
	print("Spitting block...")

# 获取玩家是否可以移动到目标格子
func get_target(dir_pressed: String) -> bool:
	var target_row = current_row
	var target_col = current_col
	
	match dir_pressed:
		LEFT:
			target_col -= 1
		RIGHT:
			target_col += 1
		UP:
			target_row -= 1
		DOWN:
			target_row += 1
		_:
			return false # 如果没有方向按键，直接返回 false
	
	# 获取目标位置的中心坐标
	target_x = GameManager.get_tile_center_x(target_col)
	target_y = GameManager.get_tile_center_y(target_row)
	
	# 检查目标位置是否为空
	var is_empty = game_manager.get_empty(target_row, target_col)
	return is_empty
	
	# TODO 暂不支持双人游戏
	# if player_count == 1:
	#     return is_empty
	# elif player_count == 2:
		# var other_player_row, other_player_col
		
		# if player_id == 1:
		#     other_player_row = game_manager.get_player_row(2)
		#     other_player_col = game_manager.get_player_col(2)
		# else:
		#     other_player_row = game_manager.get_player_row(1)
		#     other_player_col = game_manager.get_player_col(1)
		
		# var row_diff = abs(target_row - other_player_row)
		# var col_diff = abs(target_col - other_player_col)
		
		# # TODO magic number
		# if row_diff > 13 or col_diff > 11:
		#     return false
		# return is_empty
	
	# return false


# 玩家移动
func do_move():
	if dir == "":
		return
	
	if dir == LEFT:
		position.x -= SIDE_WALK_SPEED
	elif dir == RIGHT:
		position.x += SIDE_WALK_SPEED
	elif dir == UP:
		position.y -= WALK_SPEED
	elif dir == DOWN:
		position.y += WALK_SPEED

	# 更新玩家阴影位置
	# TODO 暂不支持
	# var shadow = shadow_holder["shadow_" + str(player_id)]
	# shadow.position.x = position.x
	# TODO magic number
	# shadow.position.y = position.y + 5

	# 更新玩家深度和其他信息
	# TODO magic number
	var depth = GameManager.get_row(position.y) * 1000 + GameManager.get_col(position.x) + 101
	z_index = depth
	update_players_array()

func update_players_array() -> void:
	var new_row = GameManager.get_row(position.y)
	var new_col = GameManager.get_col(position.x)
	
	# 调用 GameManager 的 update_players 方法，更新玩家的位置
	game_manager.update_players(name, current_row, current_col, new_row, new_col)
	
	# 更新 Player 类的 current_row 和 current_col
	current_row = new_row
	current_col = new_col

func process_turning() -> void:
	turn_count += 1
	if turn_count >= MAX_TURN_COUNT:
		state = PlayerState.IDLE
