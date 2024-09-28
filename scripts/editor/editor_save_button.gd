extends MainMenuButton
class_name EditorSaveButton

func _on_mouse_clicked():
    var level_editor: LevelEditor = get_parent().level_editor
    level_editor.save_level_map()
