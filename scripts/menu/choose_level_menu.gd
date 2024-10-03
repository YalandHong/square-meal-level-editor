extends Node2D

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
    camera.enabled = true
    camera.zoom = Vector2(
        float(GlobalVars.WINDOW_WIDTH) / GlobalVars.VIEW_WIDTH,
        float(GlobalVars.WINDOW_HEIGHT) / GlobalVars.VIEW_HEIGHT
    )
    create_buttons(30)
    BgmPlayerSingleton.play_menu_song()

func create_buttons(max_available_level_number: int) -> void:
    for i in range(max_available_level_number):
        var button = ChooseLevelButton.new(i + 1)
        var row = i / 10
        var col = i % 10
        button.position = Vector2(75 + col * 40, 135 + row * 40)
        add_child(button)
