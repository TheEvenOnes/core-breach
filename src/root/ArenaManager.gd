extends Node

func set_arena(arena: Spatial) -> void:
  var root = get_node('/root/World/Arena')
  for c in root.get_children():
    root.remove_child(c)
    c.queue_free()
  get_node('/root/World/Arena').add_child(arena)
