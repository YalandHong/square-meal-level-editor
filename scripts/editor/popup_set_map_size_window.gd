extends Window

signal on_confirm(rows: int, columns: int)

func _on_cancel_pressed() -> void:
    get_tree().paused = false
    hide()

func _on_ok_pressed() -> void:
    get_tree().paused = false
    var rows = $VBoxContainer/SetRowSpinBox.value
    var cols = $VBoxContainer/SetColSpinBox.value
    on_confirm.emit(rows, cols)
    hide()
