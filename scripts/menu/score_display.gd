extends PixelFontLabel

func _init() -> void:
    super("")
    z_index = GlobalVars.DEPTH_UI_ELEMENTS
    active = true
    center = false

func _process(delta: float) -> void:
    var player: Player = $"../GameManager".get_first_player()
    if player == null:
        return
    displayed_text = "score " + str(player.score)
    super._process(delta)
