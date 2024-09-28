extends Node2D

# 字体映射，保存字符与对应纹理的关系
var font_map_active: Dictionary = {}
var font_map_inactive: Dictionary = {}

# 初始化，加载所有字符的纹理
func _ready():
    load_fonts()
    create_texture_for_space()

# 加载字体纹理
func load_fonts():
    for ch in "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789":
        var texture_path = "res://sprites/font/active/" + ch + ".png"
        font_map_active[ch] = load(texture_path)
        texture_path = "res://sprites/font/inactive/" + ch + ".png"
        font_map_inactive[ch] = load(texture_path)

# 空格的texture就是一张透明图像
func create_texture_for_space():
    var size = Vector2(18, 18)
    var image = Image.new()
    image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)  # 填充透明色

    var space_texture = ImageTexture.new()
    space_texture.create_from_image(image)
    font_map_inactive[' '] = space_texture
    font_map_active[' '] = space_texture
