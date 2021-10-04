extends Spatial

const Menu := preload('res://src/menu/Menu.tscn')

func _ready() -> void:
  ArenaManager.set_arena(Menu.instance())
