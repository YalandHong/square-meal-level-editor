class_name ShadowManager
extends Node2D

var shadow_count: int

# 初始化
func _init() -> void:
	shadow_count = 0

# 添加玩家阴影
func add_player_shadow(id: int) -> void:
	# shadow_count += 1
	# var shadow_instance = preload("res://path_to_shadow_scene.tscn").instantiate()  # 加载玩家阴影场景
	# shadow_instance.name = "shadow_" + str(id)
	# shadow_instance.modulate.a = 0.4  # 设置透明度（40%）
	# add_child(shadow_instance)
	# TODO 暂不支持玩家阴影效果
	pass

# 添加敌人阴影
func add_enemy_shadow(id: int) -> void:
	# shadow_count += 1
	# var enemy_shadow_instance = preload("res://path_to_enemy_shadow_scene.tscn").instantiate()  # 加载敌人阴影场景
	# enemy_shadow_instance.name = "enemy_shadow_" + str(id)
	# enemy_shadow_instance.modulate.a = 0.4  # 设置透明度（40%）
	# add_child(enemy_shadow_instance)
	# TODO 暂不支持敌人阴影效果
	pass
