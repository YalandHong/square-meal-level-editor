extends TextureRect


func _init() -> void:
    pivot_offset = texture.get_size() / 2


func _ready() -> void:
    get_tree().paused = true
    scale = Vector2(0.1, 0.1)  # 初始缩放为0.1
    var tween: Tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _on_back_pressed() -> void:
    if CurrentLevelIndicatorSingleton.current_level_num == CurrentLevelIndicatorSingleton.EDITOR_LEVEL_NUMBER:
        get_tree().change_scene_to_file("res://scenes/level_editor.tscn")
        return
    CurrentLevelIndicatorSingleton.current_level_num = -1
    CurrentLevelIndicatorSingleton.current_level_file = ""
    get_tree().change_scene_to_file("res://scenes/choose_level_menu.tscn")


func _on_continue_game_pressed() -> void:
    var tween: Tween = create_tween()
    tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    tween.finished.connect(_on_tween_out_finished)

func _on_tween_out_finished() -> void:
    get_tree().paused = false
    queue_free()
