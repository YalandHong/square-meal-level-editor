extends TextureButton
class_name EditorMenuButton

var text_label: PixelFontLabel

# 导出文本变量
@export var displayed_text: String = "sample"

func _ready():
    mouse_entered.connect(self._on_mouse_entered)
    mouse_exited.connect(self._on_mouse_exited)

    text_label = PixelFontLabel.new(displayed_text)
    text_label.position = texture_normal.get_size() / 2
    add_child(text_label)

# 鼠标进入事件
func _on_mouse_entered():
    text_label.active = true

# 鼠标离开事件
func _on_mouse_exited():
    text_label.active = false
