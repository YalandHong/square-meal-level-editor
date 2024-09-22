extends Node2D

# 监听输入事件
func _process(_delta: float) -> void:
    # 只在按下的一瞬间触发场景重启
    if Input.is_action_just_pressed("ui_restart"):
        restart_scene()

# 重启当前场景
func restart_scene() -> void:
    var scene_tree = get_tree()
    scene_tree.reload_current_scene()
