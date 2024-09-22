extends Node2D

const TILE_WIDTH: int = GlobalVars.TILE_WIDTH
const TILE_HEIGHT: int = GlobalVars.TILE_HEIGHT

@onready var level_editor: LevelEditor = get_parent()

func _process(_delta):
    track_mouse()

func _draw() -> void:
    highlight_mouse_area()

# 跟踪鼠标位置
func track_mouse():
    var mouse_pos = get_global_mouse_position()
    if not is_mouse_within_bounds(mouse_pos):
        return
    var mouse_row = GridHelper.y_to_row(mouse_pos.y)
    var mouse_col = GridHelper.x_to_col(mouse_pos.x)

    if Input.is_action_just_pressed("mouse_left"):
        level_editor.put_grid_element(mouse_row, mouse_col)  # 放置方块
    elif Input.is_action_just_pressed("mouse_right"):
        level_editor.delete_grid_element(mouse_row, mouse_col)  # 删除方块

# 检查鼠标是否在 Camera2D 区域内
func is_mouse_within_bounds(mouse_pos: Vector2) -> bool:
    var camera = level_editor.camera
    var camera_rect = Rect2(camera.position.x, camera.position.y,
        camera.get_viewport().size.x, camera.get_viewport().size.y)
    return camera_rect.has_point(mouse_pos)

func highlight_mouse_area():
    var mouse_pos = get_global_mouse_position()
    if not is_mouse_within_bounds(mouse_pos):
        return
    var mouse_row = GridHelper.y_to_row(mouse_pos.y)
    var mouse_col = GridHelper.x_to_col(mouse_pos.x)
    var highlight_color: Color = Color(1, 1, 1)  # 半透明白色
    var tile_rect = Rect2(
        mouse_col * TILE_WIDTH, mouse_row * TILE_HEIGHT,
        TILE_WIDTH, TILE_HEIGHT
    )
    draw_rect(tile_rect, highlight_color)
