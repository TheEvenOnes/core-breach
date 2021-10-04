extends Area

const PickupFX := preload('res://src/pickups/PickupFX.tscn')

var elapsed := 0.0

func _physics_process(delta: float) -> void:
  elapsed += delta
  transform.origin.y = sin(elapsed)
  rotation.y = elapsed

  var bodies = get_overlapping_bodies()
  if bodies.size() > 0:
    for body in bodies:
      if body.is_in_group('player.ship'):
        body.heal(20)
        var fx = PickupFX.instance()
        FxManager.add_fx(fx)
        fx.fx_color = Color.red
        fx.global_transform.origin = global_transform.origin
        queue_free()
        break
