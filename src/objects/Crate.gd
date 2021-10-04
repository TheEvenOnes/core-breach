extends RigidBody

const HealthPickup := preload('res://src/pickups/HealthPickup.tscn')
const CoolantPickup := preload('res://src/pickups/CoolantPickup.tscn')
const CoinPickup := preload('res://src/pickups/CoinPickup.tscn')

const CrateExplodeFX := preload('res://src/objects/CrateExplodeFX.tscn')

const MAX_HEALTH := 3.0
var health := MAX_HEALTH

func _ready() -> void:
  contact_monitor = true
  contacts_reported = true

func update_gui() -> void:
  $Control/ColorRect.rect_scale.x = health / MAX_HEALTH

func damage(amount: float) -> void:
  health -= amount
  if health <= 0.0:
    var fx = CrateExplodeFX.instance()
    FxManager.add_fx(fx)
    fx.global_transform.origin = global_transform.origin

    var clazz = [HealthPickup, HealthPickup, CoolantPickup, CoolantPickup, CoinPickup, CoinPickup, CoinPickup, CoinPickup][randi() % 8]
    var pickup = clazz.instance()
    PickupManager.add_pickup(pickup)
    pickup.global_transform.origin = global_transform.origin

    queue_free()
