extends Block
class_name FoodBlock

const FOOD_SCORE: int = 50
const FOOD_SPRITE_OFFSET_Y: int = -10

@onready var food_block_sprite = $AnimatedSprite2D

func is_eatable() -> bool:
    return true

func _ready() -> void:
    super._ready()
    food_block_sprite.centered = false
    food_block_sprite.offset.y = BLOCK_SPRITE_OFFSET_Y
    set_random_sprite()

# 随机设置精灵图像
func set_random_sprite():
    food_block_sprite.stop()
    var spr_count = food_block_sprite.sprite_frames.get_frame_count("default")
    food_block_sprite.frame = randi() % spr_count

func be_eaten_by_player(player: Player):
    player.add_score(FOOD_SCORE)
    game_manager.remove_block(current_row, current_col)
    queue_free()
