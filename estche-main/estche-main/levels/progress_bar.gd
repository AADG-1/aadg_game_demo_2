extends ProgressBar

signal energy_depleted

@export_group("Размери и Визия")
## Дебелина (височина) на бара в пиксели
@export var bar_height: float = 40.0
## Цвят на празната част (фона) отзад
@export var background_color: Color = Color("2f3542")
## Нормален цвят на запълване
@export var normal_color: Color = Color("2ed573")
## Жълт цвят за предупреждение
@export var warning_color: Color = Color("eccc68")
## Процент, под който барът става жълт
@export var warning_threshold_percent: float = 30.0

@export_group("Настройки за изчерпване")
@export var drain_rate: float = 1.0
@export var start_value: float = 30.0
@export var auto_start: bool = true

var is_running: bool = false
var fill_stylebox: StyleBoxFlat
var bg_stylebox: StyleBoxFlat

func _ready() -> void:
	# 1. Махаме изписването на процентите
	show_percentage = true
	
	# 2. Задаваме дебелината (височината)
	custom_minimum_size.y = bar_height
	
	# 3. Настройка на стила за фона (задната част)
	bg_stylebox = StyleBoxFlat.new()
	bg_stylebox.bg_color = background_color
	bg_stylebox.set_corner_radius_all(6) # Леко заоблени ъгли
	add_theme_stylebox_override("background", bg_stylebox)
	
	# 4. Настройка на стила за предната част (запълването)
	fill_stylebox = StyleBoxFlat.new()
	fill_stylebox.set_corner_radius_all(6)
	add_theme_stylebox_override("fill", fill_stylebox)
	
	# Начални стойности
	min_value = 0
	value = clamp(start_value, min_value, max_value)
	_update_bar_color()
	
	if auto_start:
		start_drain()

func _process(delta: float) -> void:
	if not is_running or value <= 0:
		return
		
	value -= drain_rate * delta
	_update_bar_color()
	
	if value <= 0:
		value = 0
		is_running = false
		energy_depleted.emit()
		print("Енергията свърши!")
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		
		var next_level_path = "res://levels/level_" + str(next_level_number) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
		

func _update_bar_color() -> void:
	var current_percent = (value / max_value) * 100.0
	
	if current_percent <= warning_threshold_percent:
		fill_stylebox.bg_color = warning_color
	else:
		fill_stylebox.bg_color = normal_color

func start_drain() -> void:
	is_running = true

func stop_drain() -> void:
	is_running = false

func set_speed(new_rate: float) -> void:
	drain_rate = new_rate

func reset_to_level(start_amount: float) -> void:
	start_value = start_amount
	value = clamp(start_value, min_value, max_value)
	_update_bar_color()
	

## Извиква се от сигнали за добавяне (+20.0) или отнемане (-15.0) на енергия
func change_energy(amount: float) -> void:
	value = clamp(value + amount, min_value, max_value)
	_update_bar_color()
	
	# Проверка дали енергията е изчерпана от отрицателна промяна
	if value <= 0 and is_running:
		value = 0
		is_running = false
		energy_depleted.emit()

func _on_npc_test_energy_changed(amount: float) -> void:
	$".".change_energy(amount)
