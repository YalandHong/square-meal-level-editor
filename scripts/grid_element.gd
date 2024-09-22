extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

#func try_step_forward_moving_target(target_dir: String) -> bool:
    #var target_row = GlobalVars.step_row_by_direction(current_row, target_dir)
    #var target_col = GlobalVars.step_col_by_direction(current_col, target_dir)
    #if check_target_movable(target_row, target_col):
        #do_change_moving_target(target_row, target_col, target_dir)
        #return true
    #return false
