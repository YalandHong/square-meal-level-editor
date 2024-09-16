extends Node2D
class_name MouseTracker

'''
用于debug，显示鼠标位置
'''

# The label that will display the mouse position and tile coordinates
@onready var label: Label = $Label

func _process(delta: float) -> void:
    # Get the mouse position in the viewport
    var mouse_pos: Vector2 = get_global_mouse_position()

    # Calculate the row and col of the tile
    var col = GameManager.get_col(mouse_pos.x)
    var row = GameManager.get_row(mouse_pos.y)

    # Update the label text with mouse position and tile coordinates
    label.text = "Mouse: " + str(mouse_pos) + "\nTile: (" + str(row) + ", " + str(col) + ")"
