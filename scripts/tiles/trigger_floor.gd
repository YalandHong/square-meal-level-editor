extends SpikeHole
class_name TriggerFloor

# 机关刺，玩家踩上去后才会触发

func _init() -> void:
    spike_timer = 0

func _process(_delta: float) -> void:
    check_hit_player()
    if spike_timer > 0:
        spike_timer -= 1
        if spike_timer == 0:
            assert(state == SpikeState.STABBED)
            start_withdraw()

func check_hit_player():
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player == null:
        return
    if state == SpikeState.STABBED:
        player.die()
    if state == SpikeState.WITHDRAWN:
        start_stab()

func start_withdraw():
    state = SpikeState.WITHDRAWING
    floor_sprite.speed_scale = 1.2
    floor_sprite.play_backwards("stab")

func finish_withdraw():
    state = SpikeState.WITHDRAWN

func get_floor_type() -> int:
    return GlobalVars.ID_TRIGGER_FLOOR
