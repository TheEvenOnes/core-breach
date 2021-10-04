extends Node

func add_fx(fx: Spatial) -> void:
  get_node('/root/World/FX').add_child(fx)
