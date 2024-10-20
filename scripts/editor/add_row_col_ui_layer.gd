extends Node2D

@onready var level_editor: LevelEditor = $".."

const TILE_WIDTH: int = GlobalVars.TILE_WIDTH
const TILE_HEIGHT: int = GlobalVars.TILE_HEIGHT

func refresh_add_del_buttons():
    var BUTTON_SIZE = $AddRowTop.texture_normal.get_size().x + 5
    var LEVEL_WIDTH_PX = level_editor.map_width * TILE_WIDTH
    var LEVEL_HEIGHT_PX = level_editor.map_height * TILE_HEIGHT

    $AddRowTop.position = Vector2(LEVEL_WIDTH_PX/2 - BUTTON_SIZE, -60)
    $DelRowTop.position = Vector2(LEVEL_WIDTH_PX/2, -60)

    $AddRowBottom.position = Vector2(LEVEL_WIDTH_PX/2 - BUTTON_SIZE, LEVEL_HEIGHT_PX + 10)
    $DelRowBottom.position = Vector2(LEVEL_WIDTH_PX/2, LEVEL_HEIGHT_PX + 10)


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
