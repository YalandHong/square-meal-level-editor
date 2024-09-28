extends Node
class_name LevelEditor

var level_map: Array
var map_height: int
var map_width: int

# 滚动边界
var scroll_x_min: int
var scroll_x_max: int
var scroll_y_min: int
var scroll_y_max: int
@onready var camera: Camera2D = $Camera2D

var player_row
var player_col

# 计算滚动边界
func init_scroll_bounds() -> void:
    scroll_x_min = GlobalVars.VIEW_WIDTH / 2
    scroll_x_max = max(scroll_x_min,
        map_width * GlobalVars.TILE_WIDTH - GlobalVars.VIEW_WIDTH / 2)
    scroll_y_min = GlobalVars.VIEW_HEIGHT / 2
    scroll_y_max = max(scroll_y_min,
        map_height * GlobalVars.TILE_HEIGHT - GlobalVars.VIEW_HEIGHT / 2)

func _ready():
    #request_map_size()  # 请求地图大小
    if not try_load_existing_level_file():
        map_height = 20
        map_width = 30
        create_default_level_map()
    init_scroll_bounds()
    camera.position = Vector2(GlobalVars.VIEW_WIDTH / 2, GlobalVars.VIEW_HEIGHT / 2)

func try_load_existing_level_file() -> bool:
    var loaded_level_map = LocalFileHelper.read_level_map_tsv_file(
        "user://edit_level.tsv"
    )
    if loaded_level_map == null:
        return false
    level_map = loaded_level_map
    map_height = level_map.size()
    map_width = level_map[0].size()
    return true

func create_default_level_map():
    level_map = []
    level_map.resize(map_height)
    for i in range(map_height):
        level_map[i] = []
        for j in range(map_width):
            if i == 0 or i == map_height - 1 or j == 0 or j == map_width - 1:
                level_map[i].append(GlobalVars.ID_WALL_BLOCK)
            else:
                level_map[i].append(GlobalVars.ID_EMPTY_TILE)

## 请求玩家输入地图大小
#func request_map_size():
    ## TODO 暂不支持
    #_on_input_confirmed()
#
## 输入验证函数
#func is_valid_input(input_text: String) -> bool:
    #return input_text.is_valid_int()
#
## 处理输入确认
#func _on_input_confirmed(row_input: LineEdit, col_input: LineEdit):
    #if not is_valid_input(row_input.text) or not is_valid_input(col_input.text):
        #get_tree().call_group("dialogs", "show_error", "请输入有效的数字！")
        #return
#
    #map_height = int(row_input.text)
    #map_width = int(col_input.text)
#
    #if map_height < 3 or map_width < 3:
        #get_tree().call_group("dialogs", "show_error", "行数和列数必须至少为3！")
        #return
#
    #initialize_level_map()

# 处理相机移动
func _process(_delta):
    handle_camera_movement()

# 处理相机移动的函数
func handle_camera_movement():
    if Input.is_action_just_pressed("ui_up"):
        camera.position.y -= GlobalVars.TILE_HEIGHT
    elif Input.is_action_just_pressed("ui_down"):
        camera.position.y += GlobalVars.TILE_HEIGHT
    elif Input.is_action_just_pressed("ui_left"):
        camera.position.x -= GlobalVars.TILE_WIDTH
    elif Input.is_action_just_pressed("ui_right"):
        camera.position.x += GlobalVars.TILE_WIDTH

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

func save_level_map():
    LocalFileHelper.save_level_map_to_tsv_file(level_map, "user://edit_level.tsv")
    var float_notification = FloatSavedNotification.new()
    camera.add_child(float_notification)
    float_notification.z_index = 1000
