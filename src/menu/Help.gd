extends Button



func _on_Help_pressed():
  $'../HelpLabel'.visible = not $'../HelpLabel'.visible
