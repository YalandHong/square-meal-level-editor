extends Node2D

const TILE_WIDTH: int = GlobalVars.TILE_WIDTH
const TILE_HEIGHT: int = GlobalVars.TILE_HEIGHT

@onready var level_editor: LevelEditor = get_parent()

var loaded_element_textures: Dictionary = {}

func _process(_delta):
    track_mouse()
    queue_redraw()

func _draw() -> void:
    #highlight_map_edit_area()
    highlight_mouse_area()
    draw_full_map_area()

# 跟踪鼠标位置
func track_mouse():
    var mouse_pos = get_global_mouse_position()
    if not is_mouse_within_bounds(mouse_pos):
        return
    var mouse_row = GridHelper.y_to_row(mouse_pos.y)
    var mouse_col = GridHelper.x_to_col(mouse_pos.x)

    if Input.is_action_just_pressed("mouse_left"):
        level_editor.put_grid_element(mouse_row, mouse_col, GlobalVars.ID_STONE_BLOCK)
    elif Input.is_action_just_pressed("mouse_right"):
        level_editor.delete_grid_element(mouse_row, mouse_col)

func get_map_edit_area_rect() -> Rect2:
    var camera = level_editor.camera
    return Rect2(
        camera.position.x - GlobalVars.VIEW_WIDTH / 2,
        camera.position.y - GlobalVars.VIEW_HEIGHT / 2,
        GlobalVars.VIEW_WIDTH, GlobalVars.VIEW_HEIGHT
    )

# 检查鼠标是否在 Camera2D 区域内
func is_mouse_within_bounds(mouse_pos: Vector2) -> bool:
    return get_map_edit_area_rect().has_point(mouse_pos)

# use in debug
func highlight_map_edit_area():
    var highlight_color: Color = Color(1, 1, 1, 0.2)  # 半透明白色
    draw_rect(get_map_edit_area_rect(), highlight_color)

func highlight_mouse_area():
    var mouse_pos = get_global_mouse_position()
    if not is_mouse_within_bounds(mouse_pos):
        return
    var mouse_row = GridHelper.y_to_row(mouse_pos.y)
    var mouse_col = GridHelper.x_to_col(mouse_pos.x)
    var highlight_color: Color = Color(1, 1, 1, 0.4)  # 半透明白色
    var tile_rect = Rect2(
        mouse_col * TILE_WIDTH, mouse_row * TILE_HEIGHT,
        TILE_WIDTH, TILE_HEIGHT
    )
    draw_rect(tile_rect, highlight_color)

# TODO 或许，只需要draw camera里可见的部分即可，提高效率
func draw_full_map_area():
    for row in range(level_editor.map_height):
        for col in range(level_editor.map_width):
            var type: int = level_editor.level_map[row][col]
            if type == GlobalVars.ID_EMPTY_TILE:
                continue
            var loaded_texture = get_or_create_texture(type)
            assert(loaded_texture != null)
            var pos = Vector2(
                GridHelper.get_tile_top_left_x(col),
                GridHelper.get_tile_top_left_y(row) + Block.BLOCK_SPRITE_OFFSET_Y
            )
            draw_texture(loaded_texture, pos)

func get_or_create_texture(type: int) -> Texture2D:
    if loaded_element_textures.has(type):
        return loaded_element_textures[type]
    var file_path = (SelectButton.BUTTON_SPRITE_FILE_FOLDER +
                SelectButton.BUTTON_TYPE_ID_TO_SPRITE_FILE_MAP[type])
    var loaded_texture = load(file_path)
    loaded_element_textures[type] = loaded_texture
    return loaded_texture
