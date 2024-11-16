extends Node2D

@onready var level_editor: LevelEditor = $".."

const TILE_WIDTH: int = GlobalVars.TILE_WIDTH
const TILE_HEIGHT: int = GlobalVars.TILE_HEIGHT

func refresh_add_del_buttons():
    var BUTTON_WIDTH = $AddRowTop.texture_normal.get_size().x + 5
    var BUTTON_HEIGHT = $AddRowTop.texture_normal.get_size().y + 18
    var LEVEL_WIDTH_PX = level_editor.map_width * TILE_WIDTH
    var LEVEL_HEIGHT_PX = level_editor.map_height * TILE_HEIGHT

    $AddRowTop.position = Vector2(LEVEL_WIDTH_PX/2 - BUTTON_WIDTH, -BUTTON_HEIGHT)
    $DelRowTop.position = Vector2(LEVEL_WIDTH_PX/2, -BUTTON_HEIGHT)

    $AddRowBottom.position = Vector2(LEVEL_WIDTH_PX/2 - BUTTON_WIDTH, LEVEL_HEIGHT_PX + 10)
    $DelRowBottom.position = Vector2(LEVEL_WIDTH_PX/2, LEVEL_HEIGHT_PX + 10)

    $AddColLeft.position = Vector2(-BUTTON_WIDTH, LEVEL_HEIGHT_PX/2 - BUTTON_HEIGHT)
    $DelColLeft.position = Vector2(-BUTTON_WIDTH, LEVEL_HEIGHT_PX/2)

    $AddColRight.position = Vector2(LEVEL_WIDTH_PX + 10, LEVEL_HEIGHT_PX/2 - BUTTON_HEIGHT)
    $DelColRight.position = Vector2(LEVEL_WIDTH_PX + 10, LEVEL_HEIGHT_PX/2)


func _on_add_row_top_pressed() -> void:
    level_editor.add_row_below_first()
    refresh_add_del_buttons()


func _on_add_row_bottom_pressed() -> void:
    level_editor.add_row_above_last()
    refresh_add_del_buttons()


func _on_del_row_top_pressed() -> void:
    level_editor.remove_second_row()
    refresh_add_del_buttons()


func _on_del_row_bottom_pressed() -> void:
    level_editor.remove_second_last_row()
    refresh_add_del_buttons()


func _on_add_col_left_pressed() -> void:
    level_editor.add_column_right_of_first()
    refresh_add_del_buttons()


func _on_add_col_right_pressed() -> void:
    level_editor.add_column_left_of_last()
    refresh_add_del_buttons()


func _on_del_col_left_pressed() -> void:
    level_editor.remove_second_column()
    refresh_add_del_buttons()


func _on_del_col_right_pressed() -> void:
    level_editor.remove_second_last_column()
    refresh_add_del_buttons()
