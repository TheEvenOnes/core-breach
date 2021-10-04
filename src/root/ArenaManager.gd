extends Node

func set_arena(arena: Spatial) -> void:
  var root = get_node('/root/World/Arena')
  for c in root.get_children():
    c.queue_free()
  yield(get_tree().create_timer(0.2), 'timeout')
  root.add_child(arena)
