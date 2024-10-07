extends Node2D
class_name BgDrawer

var map_width: int = 0
var map_height: int = 0

# 背景纹理
var background_texture: Texture2D

func _draw() -> void:
    var texture_size: Vector2 = background_texture.get_size()
    var draw_width = map_width * GridHelper.TILE_WIDTH
    var draw_height = map_height * GridHelper.TILE_HEIGHT

    # 计算需要横向和纵向绘制的次数
    var rows: int = ceil(draw_height / texture_size.y)
    var cols: int = ceil(draw_width / texture_size.x)

    # 循环绘制平铺背景
    for row in range(rows):
        for col in range(cols):
            var pos: Vector2 = Vector2(col * texture_size.x, row * texture_size.y)
            draw_texture(background_texture, pos)

func _ready() -> void:
    background_texture = preload("res://sprites/bg_level.png")
