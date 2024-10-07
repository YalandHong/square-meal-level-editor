extends TextureButton
class_name ChooseLevelButton

var level_number: int
var displayed_text: String
var text_label: PixelFontLabel

func _init(lvl_no: int) -> void:
    level_number = lvl_no
    texture_normal = preload("res://sprites/menu/choose_level_button.png")
    displayed_text = str(level_number)

func _ready():
    mouse_entered.connect(self._on_mouse_entered)
    mouse_exited.connect(self._on_mouse_exited)
    pressed.connect(self._on_mouse_clicked)

    text_label = PixelFontLabel.new(displayed_text)
    text_label.position = texture_normal.get_size() / 2
    add_child(text_label)

# 鼠标进入事件
func _on_mouse_entered():
    text_label.active = true

# 鼠标离开事件
func _on_mouse_exited():
    text_label.active = false

func _on_mouse_clicked():
    var level_str = LocalFileHelper.get_official_level_file_xml_path(level_number)
    var scene_to_load = preload("res://scenes/main_game.tscn")
    CurrentLevelIndicatorSingleton.current_level_num = level_number
    CurrentLevelIndicatorSingleton.current_level_file = level_str
    get_tree().change_scene_to_packed(scene_to_load)
