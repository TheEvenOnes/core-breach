extends Area

const PickupFX := preload('res://src/pickups/PickupFX.tscn')

var elapsed := randf()

func _physics_process(delta: float) -> void:
  elapsed += delta
  rotation.y = elapsed

  var bodies = get_overlapping_bodies()
  if bodies.size() > 0:
    for body in bodies:
      if body.is_in_group('player.ship'):
        body.heal(20)
        var fx = PickupFX.instance()
        fx.fx_color = Color.red
        FxManager.add_fx(fx)
        fx.global_transform.origin = global_transform.origin
        queue_free()
        break
