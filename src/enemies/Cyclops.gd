extends KinematicBody

const DEFAULT_MASS = 200.0
const DEFAULT_MAX_SPEED = 10.0
const DEFAULT_SLOWDOWN_RADIUS = 10.0
const DEFAULT_RADIUS = 40.0
const DEFAULT_MINIMUM_DISTANCE = 3.0
const DEFAULT_MINIMUM_SPEED = 0.2
const DEFAULT_DISTANCE_THRESHOLD = 1.0

export(NodePath) var Target = null

var velocity: Vector3 = Vector3.FORWARD

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.



func _physics_process(delta):
  var other: Spatial = get_node(Target)
  var pos_own: Vector3 = global_transform.origin
  var pos_other: Vector3 = other.global_transform.origin

  var new_velocity: Vector3 = follow(pos_own, velocity, pos_other)
  velocity = new_velocity

  var global_up_pos: Vector3 = to_global(Vector3.UP)
  var global_up: Vector3 = (global_up_pos - global_transform.origin).normalized()
  look_at_from_position(Vector3.ZERO, velocity, global_up)

  velocity = move_and_slide(velocity, Vector3.UP)

static func vec3_clamped(vec: Vector3, clmp: float) -> Vector3:
  var l := vec.length()
  if l > clmp:
    return vec.normalized() * clmp
  return vec

static func follow(
  src_position: Vector3,
  src_velocity: Vector3,
  target_position: Vector3,
  max_speed: float = DEFAULT_MAX_SPEED,
  mass: float = DEFAULT_MASS,
  slowdown_radius: float = DEFAULT_SLOWDOWN_RADIUS,
  min_distance: float = DEFAULT_MINIMUM_DISTANCE,
  min_speed: float = DEFAULT_MINIMUM_SPEED,
  distance_threshhold: float = DEFAULT_DISTANCE_THRESHOLD
) -> Vector3:

  var distance = (target_position.distance_to(src_position) - min_distance)
  if distance <= distance_threshhold:
    return vec3_clamped(src_velocity, max_speed)
  var desired_velocity := (target_position - src_position).normalized() * max_speed
  if distance < slowdown_radius:
    desired_velocity *= distance / slowdown_radius
  var steering := (desired_velocity - src_velocity) / mass
  var new_speed := vec3_clamped(src_velocity + steering, max_speed)

  if min_speed > 0.0 && new_speed.length() < min_speed:
    return new_speed.normalized() * min_speed
  else:
    return new_speed

static func avoid(
  src_position: Vector3,
  src_velocity: Vector3,
  target_position: Vector3,
  max_speed: float = DEFAULT_MAX_SPEED,
  mass: float = DEFAULT_MASS,
  radius: float = DEFAULT_RADIUS
) -> Vector3:
  var distance = src_position.distance_to(target_position)
  if distance >= radius:
    return src_velocity

  var desired_velocity := (src_position - target_position).normalized() * max_speed
  desired_velocity *= (1.0 - (distance + 1) / radius)
  var steering := (desired_velocity - src_velocity) / mass
  return vec3_clamped(src_velocity + steering, max_speed)
