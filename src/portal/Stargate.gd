extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#  pass


func _on_Area_body_entered(body: Spatial):
  if body.is_in_group('player.ship'):
    yield(get_tree().create_timer(0.05), 'timeout')
    var arena := load('res://src/arena/Arena.tscn')
    $"/root/ArenaManager".set_arena(arena)
