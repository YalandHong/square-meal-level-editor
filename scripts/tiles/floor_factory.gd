extends Node
class_name FloorFactory

const TYPE_TO_FLOOR_TILE_MAP = {
    GlobalVars.ID_SPIKE_FLOOR: "res://scripts/tiles/spike_floor.gd",
}

static func is_valid_floor_type(type: int) -> bool:
    return TYPE_TO_FLOOR_TILE_MAP.has(type)

static func create_floor(row: int, col: int, type: int) -> FloorTile:
    var floor_tile_resource = load(TYPE_TO_FLOOR_TILE_MAP[type])
    var floor: FloorTile
    if floor_tile_resource is PackedScene:
        floor = floor_tile_resource.instantiate()
    else:
        floor = floor_tile_resource.new()
    floor.set_init_pos(row, col)
    return floor
