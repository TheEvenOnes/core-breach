extends Area

const HealthPickupFX := preload('res://src/pickups/CoolantPickupFX.tscn')

var elapsed := 0.0

func _physics_process(delta: float) -> void:
  elapsed += delta
  transform.origin.y = sin(elapsed)
  rotation.y = elapsed

  var bodies = get_overlapping_bodies()
  if bodies.size() > 0:
    for body in bodies:
      if body.is_in_group('player.ship'):
        body.add_core_time(5)
        var fx = HealthPickupFX.instance()
        get_parent().add_child(fx)
        fx.global_transform.origin = global_transform.origin
        queue_free()
        break
