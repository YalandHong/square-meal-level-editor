extends PixelFontLabel
class_name FloatSavedNotification

var float_timer: int

func _init() -> void:
    super("level saved")
    float_timer = 0

func _process(_delta: float) -> void:
    queue_redraw()
    float_timer += 1
    if float_timer >= 75:
        queue_free()

# 在指定相对坐标绘制逐渐消失的文本
func display_special_text(x: float, y: float, text: String, font_map: Dictionary):
    text = text.to_upper()
    var pos = Vector2(x, y - float_timer)
    for ch in text:
        if ch == ' ':
            pos.x += 18 - 2
            continue
        var alpha = 1 - float_timer / 100.0
        draw_texture(font_map[ch], pos, Color(1, 1, 1, alpha))
        pos.x += font_map[ch].get_width() - 2
