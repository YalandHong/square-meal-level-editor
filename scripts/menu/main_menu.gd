extends Node2D

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
    camera.enabled = true
    camera.zoom = Vector2(
        float(GlobalVars.WINDOW_WIDTH) / GlobalVars.VIEW_WIDTH,
        float(GlobalVars.WINDOW_HEIGHT) / GlobalVars.VIEW_HEIGHT
    )
    BgmPlayerSingleton.play_menu_song()
