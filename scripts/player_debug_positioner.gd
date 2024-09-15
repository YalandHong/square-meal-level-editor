extends ColorRect

@onready var player: Player = $Player

func _process(delta: float) -> void:
    position.x = player.current_row
    position.y = player.current_col
