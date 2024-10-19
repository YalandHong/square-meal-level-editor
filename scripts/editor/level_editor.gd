extends Node
class_name LevelEditor

const TILE_WIDTH: int = GlobalVars.TILE_WIDTH
const TILE_HEIGHT: int = GlobalVars.TILE_HEIGHT

var level_map: Array
var map_width: int
var map_height: int
const MAP_MIN_WIDTH: int = 3
const MAP_MIN_HEIGHT: int = 3

# 滚动边界
var scroll_x_min: int
var scroll_x_max: int
var scroll_y_min: int
var scroll_y_max: int
@onready var camera: Camera2D = $Camera2D

var player_row
var player_col


func _ready():
    #request_map_size()  # 请求地图大小
    if not try_load_existing_level_file("user://edit_level.tsv"):
        map_height = 20
        map_width = 30
        create_default_empty_level_map()
    set_scroll_bounds()

    camera.position = Vector2(GlobalVars.VIEW_WIDTH / 2, GlobalVars.VIEW_HEIGHT / 2)
    $GridDrawer.map_width = map_width
    $GridDrawer.map_height = map_height
    $BgDrawer.map_width = map_width
    $BgDrawer.map_height = map_height
    $ImportFileDialog.file_selected.connect(_on_import_file_dialog_confirmed)
    $ExportFileDialog.file_selected.connect(_on_export_file_dialog_confirmed)
    BgmPlayerSingleton.play_menu_song()
    $AddRowColUiLayer.refresh_add_del_buttons()

func try_load_existing_level_file(tsv_file_path: String) -> bool:
    var loaded_level_map = LocalFileHelper.read_level_map_tsv_file(tsv_file_path)
    if loaded_level_map == null:
        return false
    level_map = loaded_level_map
    map_width = level_map[0].size()
    map_height = level_map.size()
    filter_out_invalid_values()
    try_find_player_grid_pos()
    return true

func filter_out_invalid_values():
    var has_player: bool = false
    var valid_values = SelectButton.BUTTON_TYPE_ID_TO_SPRITE_FILE_MAP.keys()
    for row in range(map_height):
        for col in range(map_width):
            if level_map[row][col] == GlobalVars.ID_EMPTY_TILE:
                continue
            if level_map[row][col] == GlobalVars.ID_PLAYER:
                if has_player:
                    level_map[row][col] = GlobalVars.ID_EMPTY_TILE
                else:
                    has_player = true
            # TODO 这段代码不知道为什么有bug，if语句总是成立，所以暂且先不管
            #if level_map[row][col] not in valid_values:
                #print(level_map[row][col])
                #print(valid_values)
                #level_map[row][col] = GlobalVars.ID_EMPTY_TILE

func create_default_empty_level_map():
    level_map = []
    level_map.resize(map_height)
    for i in range(map_height):
        level_map[i] = []
        for j in range(map_width):
            if i == 0 or i == map_height - 1 or j == 0 or j == map_width - 1:
                level_map[i].append(GlobalVars.ID_WALL_BLOCK)
            else:
                level_map[i].append(GlobalVars.ID_EMPTY_TILE)

# 处理相机移动
func _process(_delta):
    handle_camera_movement()

# 计算滚动边界
func set_scroll_bounds() -> void:
    scroll_x_min = GlobalVars.WINDOW_WIDTH / 2
    scroll_x_max = max(scroll_x_min,
        map_width * TILE_WIDTH)
    scroll_y_min = GlobalVars.WINDOW_HEIGHT / 2 - 3*TILE_HEIGHT
    scroll_y_max = max(scroll_y_min,
        map_height * TILE_HEIGHT - GlobalVars.WINDOW_HEIGHT / 2 + 3*TILE_HEIGHT)

# 处理相机移动的函数
func handle_camera_movement():
    var CAMERA_MOVE_SPEED = 15
    if Input.is_action_pressed("ui_up"):
        camera.position.y -= CAMERA_MOVE_SPEED
    elif Input.is_action_pressed("ui_down"):
        camera.position.y += CAMERA_MOVE_SPEED
    elif Input.is_action_pressed("ui_left"):
        camera.position.x -= CAMERA_MOVE_SPEED
    elif Input.is_action_pressed("ui_right"):
        camera.position.x += CAMERA_MOVE_SPEED

    # 确保相机不超出地图边界
    camera.position.x = clamp(camera.position.x, scroll_x_min, scroll_x_max)
    camera.position.y = clamp(camera.position.y, scroll_y_min, scroll_y_max)

func put_grid_element(row: int, col: int, type: int):
    if row == 0 or row == map_height - 1 or col == 0 or col == map_width - 1:
        return
    if type == GlobalVars.ID_PLAYER:
        if player_row != null:
            level_map[player_row][player_col] = GlobalVars.ID_EMPTY_TILE
        player_row = row
        player_col = col
    level_map[row][col] = type

func delete_grid_element(row: int, col: int):
    if row == 0 or row == map_height - 1 or col == 0 or col == map_width - 1:
        return
    if level_map[row][col] == GlobalVars.ID_PLAYER:
        player_row = null
        player_col = null
    level_map[row][col] = GlobalVars.ID_EMPTY_TILE

func save_level_map(tsv_file_path: String):
    var ok = LocalFileHelper.save_level_map_to_tsv_file(level_map, tsv_file_path)
    if not ok:
        printerr("save failed")
        return
    popup_floating_notification("level saved")

func popup_floating_notification(text: String) -> void:
    var float_notification = FloatingNotification.new(text)
    camera.add_child(float_notification)

func popup_import_file_dialog():
    $ImportFileDialog.popup()

func _on_import_file_dialog_confirmed(file_path: String):
    if not try_load_existing_level_file(file_path):
        popup_floating_notification("load failed")

func popup_export_file_dialog():
    $ExportFileDialog.popup()

func _on_export_file_dialog_confirmed(file_path: String):
    save_level_map(file_path)

func try_find_player_grid_pos() -> bool:
    for row in range(map_height):
        for col in range(map_width):
            if level_map[row][col] == GlobalVars.ID_PLAYER:
                player_row = row
                player_col = col
                return true
    player_row = null
    player_col = null
    return false

func _on_run_button_pressed() -> void:
    if player_row == null:
        var float_notification = FloatingNotification.new("no player")
        camera.add_child(float_notification)
        return
    save_level_map("user://edit_level.tsv")
    var level_str = "user://edit_level.tsv"
    CurrentLevelIndicatorSingleton.current_level_num = CurrentLevelIndicatorSingleton.EDITOR_LEVEL_NUMBER
    CurrentLevelIndicatorSingleton.current_level_file = level_str
    get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_save_button_pressed() -> void:
    save_level_map("user://edit_level.tsv")

func _on_import_button_pressed() -> void:
    popup_import_file_dialog()

func _on_export_button_pressed() -> void:
    popup_export_file_dialog()

func _on_quit_button_pressed() -> void:
    save_level_map("user://edit_level.tsv")
    get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func is_valid_row_col(row: int, col: int) -> bool:
    return row >= 0 and row < map_height and col >= 0 and col < map_width


# 在第一行下方增加一行
func add_row_below_first() -> void:
    var new_row = []
    new_row.resize(map_width)
    new_row.fill(GlobalVars.ID_EMPTY_TILE)
    new_row[0] = GlobalVars.ID_WALL_BLOCK
    new_row[map_width - 1] = GlobalVars.ID_WALL_BLOCK
    level_map.insert(1, new_row)
    map_height += 1

# 在最后一行上方增加一行
func add_row_above_last() -> void:
    var new_row = []
    new_row.resize(map_width)
    new_row.fill(GlobalVars.ID_EMPTY_TILE)
    new_row[0] = GlobalVars.ID_WALL_BLOCK
    new_row[map_width - 1] = GlobalVars.ID_WALL_BLOCK
    level_map.insert(map_height - 1, new_row)
    map_height += 1

# 在第一列右侧增加一列
func add_column_right_of_first() -> void:
    for i in range(map_height):
        if i == 0:
            level_map[i].insert(1, GlobalVars.ID_WALL_BLOCK)  # 第一行
        elif i == map_height - 1:
            level_map[i].insert(1, GlobalVars.ID_WALL_BLOCK)  # 最后一行
        else:
            level_map[i].insert(1, GlobalVars.ID_EMPTY_TILE)  # 其他行
    map_width += 1

# 在最后一列左侧增加一列
func add_column_left_of_last() -> void:
    for i in range(map_height):
        if i == 0:
            level_map[i].insert(map_width - 1, GlobalVars.ID_WALL_BLOCK)  # 第一行
        elif i == map_height - 1:
            level_map[i].insert(map_width - 1, GlobalVars.ID_WALL_BLOCK)  # 最后一行
        else:
            level_map[i].insert(map_width - 1, GlobalVars.ID_EMPTY_TILE)  # 其他行
    map_width += 1

# 删除第二行
func remove_second_row() -> void:
    if map_height > MAP_MIN_HEIGHT:
        level_map.remove_at(1)
        map_height -= 1
        try_find_player_grid_pos()


# 删除倒数第二行
func remove_second_last_row() -> void:
    if map_height > MAP_MIN_HEIGHT:
        level_map.remove_at(map_height - 2)
        map_height -= 1
        try_find_player_grid_pos()


# 删除第二列
func remove_second_column() -> void:
    if map_width > MAP_MIN_WIDTH:
        for i in range(map_height):
            level_map[i].remove_at(1)
        map_width -= 1
        try_find_player_grid_pos()

# 删除倒数第二列
func remove_second_last_column() -> void:
    if map_width > MAP_MIN_WIDTH:
        for i in range(map_height):
            level_map[i].remove_at(map_width - 2)
        map_width -= 1
        try_find_player_grid_pos()
