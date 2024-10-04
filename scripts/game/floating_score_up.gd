extends CountingFontLabel
class_name FloatingScoreUp

var float_timer: int

func _init(text: String) -> void:
    super()
    displayed_text = text
    float_timer = 0
    z_index = GlobalVars.DEPTH_UI_ELEMENTS

func _process(_delta: float) -> void:
    queue_redraw()
    float_timer += 1
    if float_timer >= 20:
        queue_free()

# 在指定相对坐标绘制逐渐上升的文本
func display_special_text(x: float, y: float, text: String, font_map: Dictionary):
    text = text.to_upper()
    var pos = Vector2(x, y - float_timer)
    for ch in text:
        draw_texture(font_map[ch], pos)
        pos.x += font_map[ch].get_width() - 2
