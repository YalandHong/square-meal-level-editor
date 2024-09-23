extends ColorRect
class_name SelectMenuManager

var active_button: SelectButton = null

const MENU_WIDTH: int = 120
const MENU_HEIGHT: int = GlobalVars.VIEW_HEIGHT

@onready var level_editor: LevelEditor = get_parent()

func _init() -> void:
    create_select_buttons()

func _ready():
    size = Vector2(MENU_WIDTH, MENU_HEIGHT)
    color = Color(0.5, 0.5, 0.5)  # 灰色背景

func _process(_delta: float) -> void:
    update_select_menu_position()

func create_select_buttons():
    # TODO
    pass

# 当某个按钮被按下时，执行激活逻辑
func _on_button_pressed(button: SelectButton):
    if active_button == button:
        return  # 如果点击的按钮已经是激活状态，直接返回

    if active_button != null:
        active_button.set_activation_state(false)  # 将之前的激活按钮设为未激活

    button.set_activation_state(true)  # 激活当前按钮
    active_button = button  # 更新当前激活按钮的引用

# 更新SelectMenuManager的位置和大小
func update_select_menu_position():
    var camera = level_editor.camera
    position.x = camera.position.x + GlobalVars.VIEW_WIDTH / 2 - MENU_WIDTH
    position.y = camera.position.y - GlobalVars.VIEW_HEIGHT / 2
