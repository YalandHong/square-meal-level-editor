extends Sprite2D

const DISPLAYER_TEXTURE_MAP = {
    GlobalVars.ID_STONE_BLOCK: preload("res://sprites/menu/block_display/1030.png"),
    GlobalVars.ID_WOOD_BLOCK: preload("res://sprites/menu/block_display/1028.png"),
    GlobalVars.ID_METAL_BLOCK: preload("res://sprites/menu/block_display/1032.png"),
    GlobalVars.ID_RUBBER_BLOCK: preload("res://sprites/menu/block_display/1034.png"),
    GlobalVars.ID_EXPLOSIVE_BLOCK: preload("res://sprites/menu/block_display/1036.png"),
}

func _init() -> void:
    z_index = GlobalVars.DEPTH_UI_ELEMENTS

func _ready() -> void:
    scroll_with_camera()

func _process(_delta: float) -> void:
    scroll_with_camera()
    queue_redraw()

func scroll_with_camera():
    var camera: Camera2D = $"../Camera2D"
    var DISPLAYER_OFFSET = Vector2(10, 340)
    position = camera.position - Vector2(GlobalVars.VIEW_WIDTH/2, GlobalVars.VIEW_HEIGHT/2) + DISPLAYER_OFFSET

func _draw() -> void:
    var player: Player = $"../GameManager".get_first_player()
    if player == null:
        return
    var swallowed_block_type = player.swallowed_block_type
    if swallowed_block_type == GlobalVars.ID_EMPTY_TILE:
        return
    draw_texture(DISPLAYER_TEXTURE_MAP[swallowed_block_type], Vector2(2, 0))
