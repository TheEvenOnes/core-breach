extends Node

func add_arena(arena: Spatial) -> void:
  get_node('/root/World/Arena').add_child(arena)
