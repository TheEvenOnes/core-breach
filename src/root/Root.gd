extends Spatial

const Arena := preload('res://src/arena/Arena.tscn')

func _ready() -> void:
  ArenaManager.set_arena(Arena.instance())
