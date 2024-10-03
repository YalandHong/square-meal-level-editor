extends MainMenuButton
class_name ChooseLevelButton

var level_number: int

func _init(lvl_no: int) -> void:
    level_number = lvl_no
    texture_normal = load("res://sprites/menu/choose_level_button.png")
    displayed_text = str(level_number)

func _on_mouse_clicked():
    var xml_file_name = str(level_number) + ".xml"
    if (level_number < 10):
        xml_file_name = "0" + xml_file_name
    level_str = "res://levels/official/" + xml_file_name
    scene_to_load = load("res://scenes/main_game.tscn")
    super._on_mouse_clicked()
