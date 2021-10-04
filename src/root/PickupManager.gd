extends Node

func add_pickup(pickup: Spatial) -> void:
  get_node('/root/World/Pickup').add_child(pickup)
