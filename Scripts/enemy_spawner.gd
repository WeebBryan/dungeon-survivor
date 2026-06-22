extends Node

# ============================================================
# CENAS EXPORTADAS
# ============================================================

@export var enemy_scene: PackedScene
@export var runner_scene: PackedScene
@export var tank_scene: PackedScene
@export var shooter_scene: PackedScene
@export var boss_scene: PackedScene


# ============================================================
# REFERÊNCIAS
# ============================================================

var player

var wave_label
var wave_banner
var enemy_count_label


# ============================================================
# CONFIGURAÇÃO DAS WAVES
# ============================================================

var wave = 1

var enemies_spawned = 0
var enemies_per_wave = 10
var total_wave_enemies = 10

var boss_spawned = false
var boss_wave_active = false


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	get_references()

	total_wave_enemies = enemies_per_wave

	update_wave_label()
	update_enemy_count()

	create_spawn_timer()


func get_references():

	player = get_tree().get_first_node_in_group("player")

	wave_label = get_tree().get_first_node_in_group("wave_label")
	enemy_count_label = get_tree().get_first_node_in_group("enemy_count_label")
	wave_banner = get_tree().get_first_node_in_group("wave_banner")


func create_spawn_timer():

	var timer = Timer.new()

	timer.wait_time = 1.0
	timer.timeout.connect(spawn_enemy)
	timer.autostart = true

	add_child(timer)


# ============================================================
# LOOP
# ============================================================

func _process(_delta):

	update_enemy_count()

	check_wave_completion()


func check_wave_completion():

	var enemies_alive = get_tree().get_nodes_in_group("enemy").size()

	if boss_wave_active:

		if boss_spawned and enemies_alive == 0:

			next_wave()

		return

	if enemies_alive == 0 and enemies_spawned >= enemies_per_wave:

		next_wave()


# ============================================================
# SPAWN DE INIMIGOS NORMAIS
# ============================================================

func spawn_enemy():

	if player == null:
		return

	if boss_wave_active:
		return

	if enemies_spawned >= enemies_per_wave:
		return

	var enemy = choose_enemy_scene().instantiate()

	set_spawn_position_around_player(enemy)

	get_parent().add_child(enemy)

	enemies_spawned += 1


func choose_enemy_scene():

	var roll = randf()

	if roll < 0.45:
		return enemy_scene

	elif roll < 0.70:
		return runner_scene

	elif roll < 0.90:
		return shooter_scene

	else:
		return tank_scene


func set_spawn_position_around_player(enemy):

	var angle = randf() * TAU
	var distance = 700

	enemy.global_position = player.global_position + Vector2(
		cos(angle),
		sin(angle)
	) * distance


# ============================================================
# TROCA DE WAVE
# ============================================================

func next_wave():

	wave += 1

	if wave > 10:

		show_victory()

		return

	print("WAVE ", wave)

	reset_wave_state()

	if is_boss_wave():

		start_boss_wave()

		return

	start_normal_wave()


func reset_wave_state():

	enemies_spawned = 0

	enemies_per_wave += 5
	total_wave_enemies = enemies_per_wave

	boss_spawned = false
	boss_wave_active = false


func is_boss_wave():

	return wave == 5 or wave == 10


func start_normal_wave():

	update_wave_label()
	update_enemy_count()
	show_wave_banner()


func start_boss_wave():

	boss_wave_active = true

	total_wave_enemies = 1

	spawn_boss()

	update_wave_label()
	update_enemy_count()
	show_wave_banner()


# ============================================================
# SPAWN DE BOSS
# ============================================================

func spawn_boss():

	if player == null:
		return

	if boss_scene == null:
		return

	var boss = boss_scene.instantiate()

	setup_boss_stats(boss)

	get_parent().add_child(boss)

	boss.global_position = player.global_position + Vector2(500, 0)

	update_boss_health_bar(boss)

	boss_spawned = true


func setup_boss_stats(boss):

	# Boss final da wave 10.
	if wave == 10:

		boss.is_final_boss = true

		boss.health = 300
		boss.max_health = 300
		boss.damage = 40

		boss.scale = Vector2(1.5, 1.5)

		print("BOSS FINAL SPAWNADO")

	else:

		print("BOSS SPAWNADO")


func update_boss_health_bar(boss):

	if boss.boss_health_bar:

		boss.boss_health_bar.max_value = boss.max_health
		boss.boss_health_bar.value = boss.health


# ============================================================
# UI DAS WAVES
# ============================================================

func update_wave_label():

	if wave_label:

		wave_label.text = "Wave: " + str(wave)


func update_enemy_count():

	if enemy_count_label == null:
		return

	var enemies_alive = get_tree().get_nodes_in_group("enemy").size()

	if boss_wave_active:

		enemy_count_label.text = "Boss/Minions vivos: " + str(enemies_alive)

		return

	var enemies_killed = enemies_spawned - enemies_alive
	var enemies_remaining = total_wave_enemies - enemies_killed

	enemies_remaining = max(enemies_remaining, 0)

	enemy_count_label.text = "Restantes: " + str(enemies_remaining) + "/" + str(total_wave_enemies)


func show_wave_banner():

	if wave_banner == null:
		return

	wave_banner.text = "WAVE " + str(wave)
	wave_banner.visible = true

	await get_tree().create_timer(2.0).timeout

	wave_banner.visible = false


# ============================================================
# VITÓRIA
# ============================================================

func show_victory():

	var panel = get_tree().get_first_node_in_group("victory_panel")

	if panel:

		panel.show_victory()
