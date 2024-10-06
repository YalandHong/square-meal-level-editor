extends Node
class_name FloorFactory

const TYPE_TO_FLOOR_TILE_MAP = {
    GlobalVars.ID_SPIKE_FLOOR: preload("res://scripts/tiles/spike_floor.gd"),
    GlobalVars.ID_SPIKE_HOLE_FLOOR: preload("res://scenes/tile/spike_hole.tscn"),
    GlobalVars.ID_TRIGGER_FLOOR: preload("res://scenes/tile/trigger_floor.tscn"),
    GlobalVars.ID_SLIPPY_FLOOR: preload("res://scripts/tiles/slippy_floor.gd"),
}

static func is_valid_floor_type(type: int) -> bool:
    return TYPE_TO_FLOOR_TILE_MAP.has(type)

static func create_floor(row: int, col: int, type: int) -> FloorTile:
    var floor_tile_resource = TYPE_TO_FLOOR_TILE_MAP[type]
    var floor_obj: FloorTile
    if floor_tile_resource is PackedScene:
        floor_obj = floor_tile_resource.instantiate()
    else:
        floor_obj = floor_tile_resource.new()
    floor_obj.set_init_pos(row, col)
    return floor_obj
