extends MainMenuButton

func _on_mouse_clicked():
    var level_editor: LevelEditor = get_parent().level_editor
    level_editor.popup_file_dialog()
