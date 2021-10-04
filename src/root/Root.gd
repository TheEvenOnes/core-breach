extends Spatial

const Arena := preload('res://src/arena/Arena.tscn')

func _ready() -> void:
  ArenaManager.add_arena(Arena.instance())
