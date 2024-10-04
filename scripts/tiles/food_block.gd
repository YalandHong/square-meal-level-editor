extends Block
class_name FoodBlock

const FOOD_SCORE: int = 50
const SPRITE_PATH: String = "res://sprites/block/food/"
const FOOD_SPRITE_OFFSET_Y: int = -10

func is_eatable() -> bool:
    return true

func _init() -> void:
    super()
    block_sprite.centered = true
    block_sprite.offset.y = FOOD_SPRITE_OFFSET_Y

func _ready() -> void:
    super._ready()
    set_random_sprite()

# food的精灵图像大小不一
# center和position不同于一般的单个网格的block
func set_init_pos(row: int, col: int) -> void:
    current_row = row
    current_col = col

    var spawn_x = GridHelper.get_tile_center_x(col)
    var spawn_y = GridHelper.get_tile_center_y(row)
    position = Vector2(spawn_x, spawn_y)

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
        block_sprite.texture = loaded_texture  # 给当前节点的 texture 属性赋值
    else:
        push_error("Failed to load texture: " + random_image)

func be_eaten_by_player(player: Player):
    player.score += 50
    game_manager.remove_block(current_row, current_col)
    queue_free()
