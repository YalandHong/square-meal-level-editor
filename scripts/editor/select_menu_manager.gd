extends ColorRect
class_name SelectMenuManager

var active_button: SelectButton

const MENU_WIDTH: int = GlobalVars.WINDOW_WIDTH - GlobalVars.VIEW_WIDTH
const MENU_HEIGHT: int = GlobalVars.WINDOW_HEIGHT

@onready var level_editor: LevelEditor = get_parent()

func _init() -> void:
    create_select_buttons()

func _ready():
    size = Vector2(MENU_WIDTH, MENU_HEIGHT)
    color = Color.IVORY
    # 从下往上布局按钮
    var editor_button_list = [
        [$ExportButton, $ImportButton],
        [$RunButton, $SaveButton],
    ]
    for row in range(editor_button_list.size()):
        for col in range(editor_button_list[row].size()):
            var button = editor_button_list[row][col]
            button.position = Vector2(
                MENU_WIDTH / 2 + (button.texture_normal.get_size().x + 5) * (col - 1),
                MENU_HEIGHT - 44 * (row+1)
            )
    $QuitButton.position = Vector2(MENU_WIDTH / 2, 5)

func _process(_delta: float) -> void:
    update_select_menu_position()

func create_select_buttons():
    var button_id_list = [
        [GlobalVars.ID_PLAYER],

        [GlobalVars.ID_DUMB_ENEMY, GlobalVars.ID_HELMET_ENEMY,
        GlobalVars.ID_CHARGING_ENEMY, GlobalVars.ID_LEAPING_ENEMY],

        [GlobalVars.ID_WALL_BLOCK, GlobalVars.ID_STONE_BLOCK,
        GlobalVars.ID_WOOD_BLOCK, GlobalVars.ID_METAL_BLOCK],

        [GlobalVars.ID_RUBBER_BLOCK, GlobalVars.ID_EXPLOSIVE_BLOCK,
        GlobalVars.ID_DEFAULT_FOOD_BLOCK],

        [GlobalVars.ID_SPIKE_FLOOR, GlobalVars.ID_SPIKE_HOLE_FLOOR,
        GlobalVars.ID_SLIPPY_FLOOR],
    ]
    for i in range(len(button_id_list)):
        var button_row = button_id_list[i]
        for j in range(len(button_row)):
            var button_id = button_row[j]
            var button = SelectButton.new(button_id)
            add_child(button)
            button.position.x = 10 + j * 54
            button.position.y = 10 + i * 60

# 当某个按钮被按下时，执行激活逻辑
func _on_button_pressed(button: SelectButton):
    if active_button == button:
        return  # 如果点击的按钮已经是激活状态，直接返回

    if active_button != null:
        active_button.set_activation_state(false)  # 将之前的激活按钮设为未激活

    button.set_activation_state(true)  # 激活当前按钮
    active_button = button  # 更新当前激活按钮的引用

# 更新SelectMenuManager的位置
func update_select_menu_position():
    var camera = level_editor.camera
    position.x = camera.position.x - GlobalVars.WINDOW_WIDTH / 2 + GlobalVars.VIEW_WIDTH
    position.y = camera.position.y - GlobalVars.WINDOW_HEIGHT / 2
