extends Area

const CoinPickupFX := preload('res://src/pickups/CoinPickupFX.tscn')

var elapsed := 0.0

func _physics_process(delta: float) -> void:
  elapsed += delta
  transform.origin.y = sin(elapsed)
  rotation.y = elapsed

  var bodies = get_overlapping_bodies()
  if bodies.size() > 0:
    for body in bodies:
      if body.is_in_group('player.ship'):
        body.add_coins(1)
        var fx = CoinPickupFX.instance()
        get_parent().add_child(fx)
        fx.global_transform.origin = global_transform.origin
        queue_free()
        break
