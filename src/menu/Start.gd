extends Button


func _on_Start_pressed():
  var arena = load('res://src/arena/Arena.tscn').instance()
  ArenaManager.set_arena(arena)
