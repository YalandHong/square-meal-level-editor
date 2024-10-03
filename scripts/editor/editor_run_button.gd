extends MainMenuButton
class_name EditorRunButton

func _on_mouse_clicked():
    var level_editor: LevelEditor = get_parent().level_editor
    if level_editor.player_row == null:
        var float_notification = FloatingNotification.new("no player")
        level_editor.camera.add_child(float_notification)
        return
    level_editor.save_level_map("user://edit_level.tsv")
    level_str = "user://edit_level.tsv"
    super._on_mouse_clicked()
