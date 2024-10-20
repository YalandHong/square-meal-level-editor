extends Window

signal on_confirm(rows: int, columns: int)

func _on_cancel_pressed() -> void:
    hide()


func _on_ok_pressed() -> void:
    on_confirm.emit()
    hide()
