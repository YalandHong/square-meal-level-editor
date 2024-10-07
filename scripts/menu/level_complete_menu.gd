extends TextureRect

'''
混用Control和Node2D其实不是一个好习惯
Node2D一类的节点用是相对坐标，单位是像素值
而Control一类的节点通常是以anchor定位的，用的是占父节点的比例
所以这一个场景下我都用的Control类节点
唯独要注意的就是它和父节点（可能是Node2D）之间的定位
'''

func _init() -> void:
    pivot_offset = texture.get_size() / 2

func _ready() -> void:
    scale = Vector2(0.1, 0.1)  # 初始缩放为0.1
    var tween: Tween = create_tween()
    tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.4)
    tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)


func _on_next_level_pressed() -> void:
    var current_level = CurrentLevelIndicatorSingleton.current_level_num
    if current_level == CurrentLevelIndicatorSingleton.MAX_LEVELS_AVAILABLE:
        return
    current_level += 1
    CurrentLevelIndicatorSingleton.current_level_num = current_level
    var level_file = LocalFileHelper.get_official_level_file_xml_path(current_level)
    CurrentLevelIndicatorSingleton.current_level_file = level_file
    get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_back_pressed() -> void:
    CurrentLevelIndicatorSingleton.current_level_num = -1
    CurrentLevelIndicatorSingleton.current_level_file = ""
    get_tree().change_scene_to_file("res://scenes/choose_level_menu.tscn")
