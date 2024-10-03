extends GridElement
class_name FloorTile

# 所有地砖的基类，简称floor
# 原版叫danger block
# FloorTile不会移动，所以dir、moving target之类的属性不会用到

var game_manager: GameManager
var sfx_player: SfxPlayer

const FLOOR_TILE_SPRITE_OFFSET_Y: int = -20

func is_dangerous() -> bool:
    return false

func is_slippy() -> bool:
    return false

func _ready() -> void:
    game_manager = get_parent()
    sfx_player = game_manager.get_parent().get_node("SfxPlayer")

func get_floor_type() -> int:
    return GlobalVars.ID_INVALID
