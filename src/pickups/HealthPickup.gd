extends Area

var elapsed := 0.0

func _physics_process(delta: float) -> void:
  elapsed += delta
  transform.origin.y = sin(elapsed)
  rotation.y = elapsed
