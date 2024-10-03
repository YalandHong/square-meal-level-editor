extends FloorTile
class_name SpikeHole

# 周期性伸出和收回的spike

@onready var floor_sprite: AnimatedSprite2D = $AnimatedSprite2D

enum SpikeState { STABBING, STABBED, WITHDRAWING, WITHDRAWN }
var state: SpikeState = SpikeState.WITHDRAWN
var spike_timer: int
const START_SPIKE_TIMER: int = 60

func _init() -> void:
    spike_timer = START_SPIKE_TIMER

func _ready() -> void:
    super._ready()
    floor_sprite.centered = false
    floor_sprite.animation_finished.connect(_on_animated_finished)
    floor_sprite.speed_scale = 0.8
    floor_sprite.offset = FLOOR_TILE_SPRITE_OFFSET

func _process(_delta: float) -> void:
    check_hit_player()
    if spike_timer > 0:
        spike_timer -= 1
        if spike_timer == 0:
            if state == SpikeState.WITHDRAWN:
                start_stab()
            else: # stabbed
                start_withdraw()

func check_hit_player():
    if state != SpikeState.STABBED:
        return
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player != null:
        player.die()

func _on_animated_finished():
    if state == SpikeState.STABBING:
        finish_stab()
    else: # withdrawing
        finish_withdraw()

func start_stab():
    state = SpikeState.STABBING
    floor_sprite.speed_scale = 0.8
    floor_sprite.play("stab")

func finish_stab():
    state = SpikeState.STABBED
    spike_timer = START_SPIKE_TIMER

func start_withdraw():
    state = SpikeState.WITHDRAWING
    floor_sprite.speed_scale = 0.8
    floor_sprite.play("withdraw")

func finish_withdraw():
    state = SpikeState.WITHDRAWN
    spike_timer = START_SPIKE_TIMER

func get_floor_type() -> int:
    return GlobalVars.ID_SPIKE_HOLE_FLOOR
