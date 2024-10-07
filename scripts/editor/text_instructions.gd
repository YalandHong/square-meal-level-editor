extends Node2D

@onready var camera: Camera2D = $"../Camera2D"

func _ready():
    create_text_labels()

func create_text_labels():
    var LEFT_OFFSET = 10
    var START_Y_OFFSET = 530
    var LINE_SPACE = 20
    var mouse_left_help = PixelFontLabel.new("hold mouse left to put blocks")
    mouse_left_help.position = Vector2(LEFT_OFFSET, START_Y_OFFSET)
    mouse_left_help.center = false
    mouse_left_help.z_index = GlobalVars.DEPTH_UI_ELEMENTS
    add_child(mouse_left_help)
    var mouse_right_help = PixelFontLabel.new("hold mouse right to delete blocks")
    mouse_right_help.position = Vector2(LEFT_OFFSET, START_Y_OFFSET + LINE_SPACE)
    mouse_right_help.center = false
    mouse_right_help.z_index = GlobalVars.DEPTH_UI_ELEMENTS
    add_child(mouse_right_help)
    var arrow_key_help = PixelFontLabel.new("arrow keys to move the view")
    arrow_key_help.position = Vector2(LEFT_OFFSET, START_Y_OFFSET + 2*LINE_SPACE)
    arrow_key_help.center = false
    arrow_key_help.z_index = GlobalVars.DEPTH_UI_ELEMENTS
    add_child(arrow_key_help)

func _process(_delta: float) -> void:
    scroll_with_camera()

# origin is the top-left of the camera
func scroll_with_camera():
    position = Vector2(camera.position.x - GlobalVars.WINDOW_WIDTH / 2,
        camera.position.y - GlobalVars.WINDOW_HEIGHT / 2)
