extends Node2D

class_name PixelFontLabel

var active: bool = false
var displayed_text: String

func _init(text: String) -> void:
    displayed_text = text

func _draw() -> void:
    if active:
        draw_active_pixel_text_centered(position.x, position.y, displayed_text)
    else:
        draw_inactive_pixel_text_centered(position.x, position.y, displayed_text)

func _process(_delta: float) -> void:
    queue_redraw()

# 在指定坐标绘制文本
func display_special_text(x: float, y: float, text: String, font_map: Dictionary):
    text = text.to_upper()
    var pos = Vector2(x, y)
    for char in text:
        if char in font_map:
            draw_texture(font_map[char], pos)
            pos.x += font_map[char].get_width()  # 移动到下一个字符的位置

# 居中显示文本，(x, y)为中点
func display_special_text_centered(x: float, y: float, text: String, font_map: Dictionary):
    text = text.to_upper()
    var total_width = 0
    for char in text:
        if char in font_map:
            total_width += font_map[char].get_width()  # 计算总宽度

    var start_x = x - total_width / 2  # 计算起始位置
    display_special_text(start_x, y, text, font_map)

func draw_active_pixel_text_centered(x: float, y: float, text: String):
    display_special_text_centered(x, y, text, PixelFont.font_map_active)

func draw_inactive_pixel_text_centered(x: float, y: float, text: String):
    display_special_text_centered(x, y, text, PixelFont.font_map_inactive)
