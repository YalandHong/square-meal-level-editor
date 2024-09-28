extends Node2D
class_name SelectButtonActiveOverlay

func _draw():
    if not visible:
        return
    var button: SelectButton = get_parent()
    draw_rect(
        Rect2(Vector2(0, 0), button.texture_normal.get_size()),
        Color(0.5, 0.5, 0.5, 0.5)
    )

# 在需要时更新绘制
func _process(_delta):
    queue_redraw()  # 触发重绘
