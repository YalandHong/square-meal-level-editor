extends Node
class_name EnemyFactory

const ENEMY_TYPE_TO_SCENE_MAP = {
    GlobalVars.ID_DUMB_ENEMY: "res://scenes/enemy/dumb_enemy.tscn",
}

static func is_valid_enemy_type(type: int) -> bool:
    return ENEMY_TYPE_TO_SCENE_MAP.has(type)

static func create_enemy(row: int, col: int, type: int) -> Enemy:
    var enemy_scene = load(ENEMY_TYPE_TO_SCENE_MAP[type])
    var enemy: Enemy = enemy_scene.instantiate()
    enemy.set_enemy_init_pos(row, col)
    return enemy
