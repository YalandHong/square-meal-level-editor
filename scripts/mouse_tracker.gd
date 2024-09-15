extends Node2D
class_name MouseTracker

'''
用于debug，显示鼠标位置
'''

# The label that will display the mouse position and tile coordinates
@onready var label: Label = $Label

func _process(delta: float) -> void:
    # Get the mouse position in the viewport
    var mouse_pos: Vector2 = get_viewport().get_mouse_position()

    # Calculate the row and col of the tile
    var col = int(mouse_pos.x / GameManager.TILE_WIDTH)
    var row = int(mouse_pos.y / GameManager.TILE_HEIGHT)

    # Update the label text with mouse position and tile coordinates
    label.text = "Mouse: " + str(mouse_pos) + "\nTile: (" + str(row) + ", " + str(col) + ")"
