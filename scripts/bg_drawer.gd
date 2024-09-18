extends Node2D
class_name BgDrawer

var draw_width: int
var draw_height: int

# 背景纹理
var background_texture: Texture2D

func _draw() -> void:
    if background_texture:
        var texture_size: Vector2 = background_texture.get_size()

        # 计算需要横向和纵向绘制的次数
        var rows: int = ceil(draw_width / texture_size.y)
        var cols: int = ceil(draw_height / texture_size.x)

        # 循环绘制平铺背景
        for row in range(rows):
            for col in range(cols):
                var pos: Vector2 = Vector2(col * texture_size.x, row * texture_size.y)
                draw_texture(background_texture, pos)

func _ready() -> void:
    var game_manager: GameManager = get_node("../GameManager")
    draw_width = game_manager.map_width * GameManager.TILE_WIDTH
    draw_height = game_manager.map_height * GameManager.TILE_HEIGHT
    background_texture = load("res://sprites/bg_level.png")
    queue_redraw() # 触发一次绘制
