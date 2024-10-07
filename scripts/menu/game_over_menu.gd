extends TextureRect

func _init() -> void:
    pivot_offset = texture.get_size() / 2

func _ready() -> void:
    scale = Vector2(0.1, 0.1)  # 初始缩放为0.1
    var tween: Tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
