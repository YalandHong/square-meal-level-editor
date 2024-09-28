extends Button
class_name SelectButton

const BUTTON_SPRITE_FILE_FOLDER: String = "res://sprites/editor/button/"
const BUTTON_TYPE_ID_TO_SPRITE_FILE_MAP: Dictionary = {
    GlobalVars.ID_PLAYER: "player.png",

    GlobalVars.ID_DUMB_ENEMY: "dumb.png",

    GlobalVars.ID_WALL_BLOCK: "wall.png",
    GlobalVars.ID_STONE_BLOCK: "stone.png",
    GlobalVars.ID_DEFAULT_FOOD_BLOCK: "food.png",
}

var type: int
@onready var button_texture: StyleBoxFlat = get_theme_stylebox("normal")

var is_activated: bool
var texture_rect: TextureRect

func _init(type_id: int) -> void:
    type = type_id

func _ready():
    create_texture_rect()
    load_button_image()
    set_activation_state(false)

# 动态创建TextureRect，归一化button的精灵图像大小
func create_texture_rect():
    texture_rect = TextureRect.new()  # 创建新的TextureRect实例
    add_child(texture_rect)  # 将TextureRect添加为SelectButton的子节点
    texture_rect.size = Vector2(100, 50)  # 设置统一的大小
    texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED  # 设置缩放模式

func load_button_image():
    var image_texture = load(
        BUTTON_SPRITE_FILE_FOLDER + BUTTON_TYPE_ID_TO_SPRITE_FILE_MAP[type]
    )
    texture_rect.texture = image_texture

# 设置按钮激活状态，外部调用此方法
func set_activation_state(active: bool):
    is_activated = active
    button_texture.border_color = Color.WHITE if active else Color.BLACK

# 当按钮被点击时调用，通知SelectMenuManager
func _on_SelectButton_pressed():
    if is_activated:
        return  # 已激活则直接返回，不做任何处理
    var menu_manager = get_parent() as SelectMenuManager
    menu_manager._on_button_pressed(self)
