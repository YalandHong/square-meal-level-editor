extends Node

var level_map: Array
var map_height: int
var map_width: int

# Camera2D
@onready var camera: Camera2D = $Camera2D

func _ready():
    #request_map_size()  # 请求地图大小
    map_height = 30
    map_width = 30
    initialize_level_map()

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

# 初始化 level_map
func initialize_level_map():
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

# 处理相机移动的函数
func handle_camera_movement():
    var speed = 200  # 设置相机移动速度
    if Input.is_action_pressed("ui_up"):
        camera.position.y -= speed
    if Input.is_action_pressed("ui_down"):
        camera.position.y += speed
    if Input.is_action_pressed("ui_left"):
        camera.position.x -= speed
    if Input.is_action_pressed("ui_right"):
        camera.position.x += speed

    # 确保相机不超出地图边界
    camera.position.x = clamp(camera.position.x, 0,
        map_width * GlobalVars.TILE_WIDTH)
    camera.position.y = clamp(camera.position.y, 0,
        map_height * GlobalVars.TILE_HEIGHT)
