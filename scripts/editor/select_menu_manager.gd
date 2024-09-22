extends Node
class_name SelectMenuManager

var active_button: SelectButton = null

func _init() -> void:
    create_select_buttons()

func create_select_buttons():
    # TODO
    pass

# 当某个按钮被按下时，执行激活逻辑
func _on_button_pressed(button: SelectButton):
    if active_button == button:
        return  # 如果点击的按钮已经是激活状态，直接返回

    if active_button != null:
        active_button.set_activation_state(false)  # 将之前的激活按钮设为未激活

    button.set_activation_state(true)  # 激活当前按钮
    active_button = button  # 更新当前激活按钮的引用
