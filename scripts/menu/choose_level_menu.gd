extends Node2D

@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
    camera.enabled = true
    camera.zoom = Vector2(
        float(GlobalVars.WINDOW_WIDTH) / GlobalVars.VIEW_WIDTH,
        float(GlobalVars.WINDOW_HEIGHT) / GlobalVars.VIEW_HEIGHT
    )
    create_buttons(23)

func create_buttons(max_available_level_number: int) -> void:
    for i in range(1, max_available_level_number + 1):
        var button = ChooseLevelButton.new(i)
        var row = i / 10
        var col = i % 10
        button.rect_position = Vector2(75 + col * 40, 150 + row * 40)
        add_child(button)
