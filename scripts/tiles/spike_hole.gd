extends FloorTile
class_name SpikeHole

# 周期性伸出和收回的spike

@onready var floor_sprite: AnimatedSprite2D = $AnimatedSprite2D

var stabbing: bool = false
var dangerous: bool = false
var spike_timer: int = 0
const START_SPIKE_TIMER: int = 60

func _ready() -> void:
    super._ready()
    floor_sprite.centered = false
    floor_sprite.animation_finished.connect(_on_animated_finished)
    floor_sprite.speed_scale = 0.8

func _process(_delta: float) -> void:
    if dangerous:
        check_hit_player()
    if spike_timer > 0:
        spike_timer -= 1
        if spike_timer == 0:
            if not stabbing:
                start_stab()
            else:
                start_withdraw()

func check_hit_player():
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player != null:
        player.die()

func _on_animated_finished():
    if stabbing:
        finish_stab()
    else:
        finish_withdraw()

func start_stab():
    stabbing = true
    floor_sprite.play("stab")

func finish_stab():
    spike_timer = START_SPIKE_TIMER
    dangerous = true

func start_withdraw():
    dangerous = false
    stabbing = false
    floor_sprite.play("withdraw")

func finish_withdraw():
    spike_timer = START_SPIKE_TIMER
