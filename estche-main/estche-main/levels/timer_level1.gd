extends Timer
@onready var timer=$Timer
@onready var game_timer=$Level1/GameBasics/CharacterBody2D/game_timer/Label_time
@onready var progress_bar=$Level1/GameBasics/CharacterBody2D/progress_bar/ProgressBar

var day=1
var mount=1
var year=2026
func _ready():
	game_timer.text=(str(day)+"/"+str(mount)+"/"+str(year))
	timer.set_time(120)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
func _on_timer_timeout():
	progress_bar.value=60
