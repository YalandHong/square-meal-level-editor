extends Node2D

const TILE_WIDTH: int = GridHelper.TILE_WIDTH
const TILE_HEIGHT: int = GridHelper.TILE_HEIGHT
@onready var game_manager: GameManager = $GameManager

# 滚动边界
var scroll_x_min: int
var scroll_x_max: int
var scroll_y_min: int
var scroll_y_max: int
@onready var camera: Camera2D = $Camera2D
@onready var ui_layer: Node2D = $UiElementsLayer

# 重启当前场景
func restart_scene() -> void:
    var scene_tree = get_tree()
    scene_tree.reload_current_scene()

func _ready() -> void:
    $GridDrawer.map_width = game_manager.map_width
    $GridDrawer.map_height = game_manager.map_height
    BgmPlayerSingleton.play_game_song()

    camera.zoom = Vector2(
        float(GlobalVars.WINDOW_WIDTH) / GlobalVars.VIEW_WIDTH,
        float(GlobalVars.WINDOW_HEIGHT) / GlobalVars.VIEW_HEIGHT
    )
    init_scroll_bounds()
    scroll_game()

func _process(_delta: float) -> void:
    # 只在按下的一瞬间触发场景重启
    #if Input.is_action_just_pressed("ui_restart"):
        #restart_scene()
    scroll_game()

# 计算滚动边界
func init_scroll_bounds() -> void:
    scroll_x_min = GlobalVars.VIEW_WIDTH / 2
    scroll_x_max = max(scroll_x_min, game_manager.map_width * TILE_WIDTH - GlobalVars.VIEW_WIDTH / 2)
    scroll_y_min = GlobalVars.VIEW_HEIGHT / 2
    scroll_y_max = max(scroll_y_min, game_manager.map_height * TILE_HEIGHT - GlobalVars.VIEW_HEIGHT / 2)

func scroll_game() -> void:
    # 目前只支持1个Player
    var player1: Player = game_manager.get_first_player()
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
    ui_layer.position = scroll_center - Vector2(GlobalVars.VIEW_WIDTH/2, GlobalVars.VIEW_HEIGHT/2)


func popup_game_over_menu():
    var menu = preload("res://scenes/menu/game_over_menu.tscn").instantiate()
    menu.z_index = GlobalVars.DEPTH_UI_ELEMENTS
    camera.add_child(menu)

func popup_level_complete_menu():
    var menu = preload("res://scenes/menu/level_complete_menu.tscn").instantiate()
    menu.z_index = GlobalVars.DEPTH_UI_ELEMENTS
    camera.add_child(menu)

func popup_pause_menu():
    var menu = preload("res://scenes/menu/pause_menu.tscn").instantiate()
    menu.z_index = GlobalVars.DEPTH_UI_ELEMENTS
    camera.add_child(menu)


func _on_pause_button_pressed() -> void:
    popup_pause_menu()
