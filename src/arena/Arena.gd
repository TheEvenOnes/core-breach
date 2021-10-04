extends Spatial

const CrateTile := preload('res://src/tiles/CrateTile.tscn')
const CoolantTile := preload('res://src/tiles/CoolantTile.tscn')


const TILE = [CrateTile, CrateTile, CrateTile, CoolantTile]
const SKY_COLOR = [Color.darkblue, Color.darkgreen, Color.darkgoldenrod, Color.darkslategray]
const HORIZON_COLOR = [Color.slategray, Color.aquamarine, Color.burlywood, Color.slategray]

export (float) var difficulty := 1.0

var rng = OpenSimplexNoise.new()


func _ready() -> void:
  rng.seed = randi()
  rng.octaves = 8
  rng.period = 1.0
  rng.persistence = 0.8
  setup()
  setup_sky()

func setup_sky() -> void:
  randomize()
  var sky: ProceduralSky = $WorldEnvironment.environment.background_sky
  var index = randi() % SKY_COLOR.size()
  sky.sky_horizon_color = HORIZON_COLOR[index]
  sky.sky_top_color = SKY_COLOR[index]
  sky.ground_horizon_color = HORIZON_COLOR[index]
  sky.ground_bottom_color = SKY_COLOR[index]

func setup() -> void:
  var slots = $Grid.get_children().duplicate()

  var num_slots = int(difficulty * slots.size())

  for i in range(num_slots):
    var d = 0.5 + 0.5 * rng.get_noise_1d(float(1024 + i))
    var index = int(slots.size() * d)
    var slot: Position3D = slots[index]
    slots.remove(index)
    var tile: Spatial = TILE[int((0.5 + 0.5 * rng.get_noise_1d(i * 100)) * 100) % TILE.size()].instance()
    tile.global_transform.origin = slot.global_transform.origin
    tile.global_transform.origin.y = (0.5 * rng.get_noise_1d(i * 25)) * 10.0
    slot.add_child(tile)
