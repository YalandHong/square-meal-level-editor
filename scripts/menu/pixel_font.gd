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
