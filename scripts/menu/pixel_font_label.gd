extends Node2D

class_name PixelFontLabel

var active: bool = false
var displayed_text: String

func _init(text: String) -> void:
    displayed_text = text

func _draw() -> void:
    if active:
        draw_active_pixel_text_centered(displayed_text)
    else:
        draw_inactive_pixel_text_centered(displayed_text)

func _process(_delta: float) -> void:
    queue_redraw()

# 在指定相对坐标绘制文本
func display_special_text(x: float, y: float, text: String, font_map: Dictionary):
    text = text.to_upper()
    var pos = Vector2(x, y)
    for ch in text:
        if ch == ' ':
            pos.x += 18 - 2
            continue
        draw_texture(font_map[ch], pos)
        pos.x += font_map[ch].get_width() - 2  # 移动到下一个字符的位置

# 居中显示文本
func draw_special_text_centered(text: String, font_map: Dictionary):
    text = text.to_upper()
    var total_width = 0
    for ch in text:
        if ch in font_map:
            total_width += font_map[ch].get_width() - 2  # 计算总宽度
    var start_x = -total_width / 2  # 计算起始位置
    var total_height = font_map[text[0]].get_height()
    var start_y = -total_height / 2
    display_special_text(start_x, start_y, text, font_map)

func draw_active_pixel_text_centered(text: String):
    draw_special_text_centered(text, PixelFont.font_map_active)

func draw_inactive_pixel_text_centered(text: String):
    draw_special_text_centered(text, PixelFont.font_map_inactive)
