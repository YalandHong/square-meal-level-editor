extends Sprite2D
class_name Block

const BLOCK_SPRITE_OFFSET_Y: int = -20

# 定义 Block 基类的通用属性和方法
var eatable: bool = false

func _init() -> void:
    offset.y = BLOCK_SPRITE_OFFSET_Y
