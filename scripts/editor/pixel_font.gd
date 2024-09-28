extends Node2D

# 字体映射，保存字符与对应纹理的关系
var font_map_active: Dictionary = {}
var font_map_inactive: Dictionary = {}

# 初始化，加载所有字符的纹理
func _ready():
    load_fonts()

# 加载字体纹理
func load_fonts():
    for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789":
        var texture_path = "res://sprites/font/active/" + char + ".png"
        font_map_active[char] = load(texture_path)
        texture_path = "res://sprites/font/inactive/" + char + ".png"
        font_map_inactive[char] = load(texture_path)

# 在指定坐标绘制文本
func display_special_text(x: float, y: float, text: String, font_map: Dictionary):
    text = text.to_upper()
    var position = Vector2(x, y)
    for char in text:
        if char in font_map:
            draw_texture(font_map[char], position)
            position.x += font_map[char].get_width()  # 移动到下一个字符的位置

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
    display_special_text_centered(x, y, text, font_map_active)

func draw_inactive_pixel_text_centered(x: float, y: float, text: String):
    display_special_text_centered(x, y, text, font_map_inactive)
