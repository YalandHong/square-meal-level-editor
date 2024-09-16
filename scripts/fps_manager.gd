extends Node

const FRAME_RATE = 30

# Called when the node enters the scene tree for the first time.
func _init() -> void:
    Engine.max_fps = FRAME_RATE
