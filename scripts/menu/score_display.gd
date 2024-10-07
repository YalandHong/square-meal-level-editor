extends PixelFontLabel

func _init() -> void:
    super("")
    z_index = GlobalVars.DEPTH_UI_ELEMENTS
    active = true
    center = false

func _ready() -> void:
    scroll_with_camera()

func _process(delta: float) -> void:
    var player: Player = $"../GameManager".get_first_player()
    if player == null:
        return
    displayed_text = "score " + str(player.score)
    scroll_with_camera()
    super._process(delta)

func scroll_with_camera():
    var camera: Camera2D = $"../Camera2D"
    var DISPLAYER_OFFSET = Vector2(10, 5)
    position = camera.position - Vector2(GlobalVars.VIEW_WIDTH/2, GlobalVars.VIEW_HEIGHT/2) + DISPLAYER_OFFSET
