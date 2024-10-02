extends Enemy
class_name ChargingEnemy

# 绕路相关
var detouring: bool = false
var expected_dir: String

# 改变方向，有追踪玩家的趋势
func try_change_direction() -> bool:
    var player_grid_pos = get_closest_player_grid_pos()
    var dis_to_player = {}
    # 计算距离
    for possible_dir in [UP, DOWN, LEFT, RIGHT]:
        var row = GridHelper.get_next_row_in_direction(current_row, possible_dir)
        var col = GridHelper.get_next_col_in_direction(current_col, possible_dir)
        dis_to_player[possible_dir] = get_manhattan_dis(player_grid_pos, Vector2(row, col))
    # 按距离排序方向
    var sorted_directions = [UP, DOWN, LEFT, RIGHT]
    sorted_directions.sort_custom(
        func(a, b): return dis_to_player[a] < dis_to_player[b]
    )
    # 尝试改变方向
    for possible_dir in sorted_directions:
        if try_step_forward_moving_target(possible_dir):
            play_walk_animation()
            return true
    return false

func get_closest_player_grid_pos() -> Vector2i:
    var player: Player = game_manager.get_node("Player")
    return Vector2i(player.current_row, player.current_col)

func get_manhattan_dis(pos1: Vector2i, pos2: Vector2i) -> int:
    return abs(pos1.x - pos2.x) + abs(pos1.y - pos2.y)

# 检测是否能看到玩家
func can_see_player() -> bool:
    assert(dir != NONE)
    var check_row = current_row
    var check_col = current_col
    for i in range(1, 31):
        check_row = GridHelper.get_next_row_in_direction(check_row, dir)
        check_col = GridHelper.get_next_col_in_direction(check_col, dir)
        if not game_manager.is_valid_row_col(check_row, check_col):
            break
        if not check_target_movable(check_row, check_col):
            break
        if game_manager.get_player_instance(check_row, check_col) != null:
            return true
    return false
