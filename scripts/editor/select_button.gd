extends TextureButton
class_name SelectButton

const BUTTON_SPRITE_FILE_FOLDER: String = "res://sprites/editor/button/"
const BUTTON_TYPE_ID_TO_SPRITE_FILE_MAP: Dictionary = {
    GlobalVars.ID_PLAYER: "player.png",

    GlobalVars.ID_DUMB_ENEMY: "dumb.png",
    GlobalVars.ID_HELMET_ENEMY: "helmet.png",
    GlobalVars.ID_CHARGING_ENEMY: "charge.png",

    GlobalVars.ID_WALL_BLOCK: "wall.png",
    GlobalVars.ID_METAL_BLOCK: "metal.png",
    GlobalVars.ID_STONE_BLOCK: "stone.png",
    GlobalVars.ID_DEFAULT_FOOD_BLOCK: "food.png",
    GlobalVars.ID_WOOD_BLOCK: "wood.png",
    GlobalVars.ID_RUBBER_BLOCK: "rubber.png",
}

var type: int

var is_activated: bool
var active_overlay: SelectButtonActiveOverlay
#var texture_rect: TextureRect

func _init(type_id: int) -> void:
    type = type_id

func _ready():
    #create_texture_rect()
    load_button_image()
    active_overlay = SelectButtonActiveOverlay.new()
    add_child(active_overlay)
    set_activation_state(false)
    pressed.connect(self._on_mouse_clicked)

func load_button_image():
    texture_normal = load(
        BUTTON_SPRITE_FILE_FOLDER + BUTTON_TYPE_ID_TO_SPRITE_FILE_MAP[type]
    )

# 设置按钮激活状态，外部调用此方法
func set_activation_state(active: bool):
    is_activated = active
    active_overlay.visible = active

# 当按钮被点击时调用，通知SelectMenuManager
func _on_mouse_clicked():
    if is_activated:
        return  # 已激活则直接返回，不做任何处理
    var menu_manager = get_parent() as SelectMenuManager
    menu_manager._on_button_pressed(self)
