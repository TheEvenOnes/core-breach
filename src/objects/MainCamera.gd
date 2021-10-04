extends Camera

export (NodePath) var target

export (float) var interpolation_speed := 0.9

func _physics_process(delta: float) -> void:
  if target != null:
    var tgt = get_node(target)
    global_transform.basis = global_transform.basis.slerp(tgt.global_transform.basis, interpolation_speed)
    global_transform.origin = global_transform.origin.linear_interpolate(tgt.global_transform.origin, interpolation_speed)
