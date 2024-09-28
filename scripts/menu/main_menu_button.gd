extends Area2D
class_name MainMenuButton

var button_sprite: Sprite2D
var collision_shape: CollisionShape2D
var text_label: PixelFontLabel

# 导出文本变量
@export var displayed_text: String = "sample"
@export var scene_to_load: PackedScene

func _ready():
    var button_texture = load("res://sprites/menu/main_menu_button.png")
    button_sprite = Sprite2D.new()
    button_sprite.texture = button_texture
    button_sprite.position = Vector2.ZERO  # 将精灵位置设置为(0, 0)
    add_child(button_sprite)

    # 设置碰撞形状以检测鼠标悬停
    collision_shape = CollisionShape2D.new()
    var button_shape = RectangleShape2D.new()
    button_shape.extents = button_texture.get_size() / 2  # 设置为纹理大小的一半
    collision_shape.shape = button_shape
    add_child(collision_shape)

    text_label = PixelFontLabel.new(displayed_text)
    add_child(text_label)

    connect("mouse_entered", _on_mouse_entered)
    connect("mouse_exited", _on_mouse_exited)

# 鼠标进入事件
func _on_mouse_entered():
    text_label.active = true

# 鼠标离开事件
func _on_mouse_exited():
    text_label.active = false

func _input_event(camera, event, shape_idx):
    if event is InputEventMouseButton and event.pressed and shape_idx != -1:
        # 当左键点击并在按钮上
        get_tree().change_scene_to(scene_to_load)  # 跳转到指定场景
