extends Control

# ============================================================
# REFERÊNCIAS
# ============================================================

@onready var stats_label = $StatsLabel


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false


# ============================================================
# MOSTRAR TELA DE VITÓRIA
# ============================================================

func show_victory():

	visible = true

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	update_stats(player)

	get_tree().paused = true


func update_stats(player):

	if stats_label == null:
		return

	var total_seconds = int(player.survival_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var seconds_text = str(seconds)

	if seconds < 10:
		seconds_text = "0" + seconds_text

	stats_label.text = (
		"Nível Final: " + str(player.level) + "\n" +
		"Inimigos Mortos: " + str(player.enemies_killed) + "\n" +
		"Bosses Mortos: " + str(player.bosses_killed) + "\n" +
		"Tempo Sobrevivido: " + str(minutes) + "m " + seconds_text + "s"
	)


# ============================================================
# BOTÃO VOLTAR AO MENU
# ============================================================

func _on_menu_button_pressed():

	get_tree().paused = false

	get_tree().change_scene_to_file("res:/Cenas/main_menu.tscn")
