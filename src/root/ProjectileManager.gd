extends Node

func add_projectile(projectile: Spatial) -> void:
  get_node('/root/World/Projectile').add_child(projectile)
