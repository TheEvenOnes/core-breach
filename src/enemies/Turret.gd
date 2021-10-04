extends RigidBody

const TurretProjectile := preload('res://src/weapon/TurretProjectile.tscn')
const CrateExplodeFX := preload('res://src/objects/CrateExplodeFX.tscn')
const CoolantPickup := preload('res://src/pickups/CoolantPickup.tscn')


onready var scanner := $Scanner
onready var gun := $Gun
onready var shooty := $Gun/ShootyPoint

const COOLDOWN = 1.0
var charge = 1.0

var health = 20.0

func damage(amount: float) -> void:
  health = max(0.0, health - amount)
  if health <= 0.0:
    var fx = CrateExplodeFX.instance()
    FxManager.add_fx(fx)
    fx.global_transform = global_transform
    var pickup = CoolantPickup.instance()
    PickupManager.add_pickup(pickup)
    pickup.global_transform.origin = global_transform.origin
    queue_free()

func _physics_process(delta: float) -> void:
  if charge <= COOLDOWN:
    charge += delta

  var bodies_in_vicinity = scanner.get_overlapping_bodies()
  for body in bodies_in_vicinity:
    if body.is_in_group('player.ship'):
      var player = body
      gun.look_at_from_position(gun.global_transform.origin, body.global_transform.origin, Vector3.UP)
      if charge >= COOLDOWN:
        charge = 0.0
        var p = TurretProjectile.instance()
        var to_player = (player.global_transform.origin - shooty.global_transform.origin).normalized()
        p.energy_color = Color.green
        add_collision_exception_with(p)
        ProjectileManager.add_projectile(p)
        p.global_transform = shooty.global_transform
        p.apply_central_impulse(to_player * 60.0)
