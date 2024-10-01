extends Enemy
class_name DumbEnemy

const SPRITE_OFFSET_NORMAL: Vector2 = Vector2(-53 / 2 + GameManager.TILE_WIDTH / 2, -GameManager.TILE_HEIGHT / 2 - 80)
const SPRITE_OFFSET_HIT: Vector2 = Vector2(-46 / 2 + GameManager.TILE_WIDTH / 2, -GameManager.TILE_HEIGHT / 2 - 78)

const ANIMATION_FPS_SCALE_WALK: float = 0.5
const ANIMATION_FPS_SCALE_HIT: float = 0.8

func set_enemy_sprite() -> void:
    anim_sprite = $DumbEnemySprite

func play_walk_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("walk_" + dir)

func play_jump_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_HIT
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_HIT
    anim_sprite.play("hit_" + dir)

func play_stunned_animation() -> void:
    anim_sprite.offset = SPRITE_OFFSET_NORMAL
    anim_sprite.speed_scale = ANIMATION_FPS_SCALE_WALK
    anim_sprite.play("stunned_" + dir)
