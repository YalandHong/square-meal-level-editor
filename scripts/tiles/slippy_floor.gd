extends FloorTile
class_name SlippyFloor

var floor_sprite: Sprite2D

const SPRITE_PATH: String = "res://sprites/floor_tiles/slippy/"

func _ready() -> void:
    super._ready()
    floor_sprite = Sprite2D.new()
    floor_sprite.centered = false
    floor_sprite.offset = FLOOR_TILE_SPRITE_OFFSET
    add_child(floor_sprite)
    set_random_sprite()

func _process(_delta: float) -> void:
    check_hit_player()

func check_hit_player():
    var player: Player = game_manager.get_player_instance(current_row, current_col)
    if player != null:
        player.try_start_slipping()

func get_floor_type() -> int:
    return GlobalVars.ID_SLIPPY_FLOOR

# 随机设置精灵图像
func set_random_sprite():
    # 获取指定目录中所有图片文件
    var fd = DirAccess.open(SPRITE_PATH)
    if fd == null:
        push_error("SPRITE_PATH open failed: " + str(DirAccess.get_open_error()))
        return

    var images = []
    fd.list_dir_begin()
    var file_name = fd.get_next()
    while file_name != "":
        if file_name.ends_with(".png"):  # 检查文件扩展名
            images.append(SPRITE_PATH + file_name)
        file_name = fd.get_next()
    fd.list_dir_end()

    assert(images.size() > 0, "No images found in directory: " + SPRITE_PATH)
    var random_image = images[randi() % images.size()]
    var loaded_texture = load(random_image)  # 使用不同的变量名
    if loaded_texture:
        floor_sprite.texture = loaded_texture  # 给当前节点的 texture 属性赋值
    else:
        push_error("Failed to load texture: " + random_image)
