extends Button


func _on_Start_pressed():
  Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
  var arena = load('res://src/arena/Arena.tscn').instance()
  ArenaManager.set_arena(arena)
