extends Control

# ============================================================
# CONSTANTES
# ============================================================

const CLASS_DUELIST = "duelist"
const CLASS_MAGE = "mage"

const MAIN_SCENE = "res://Cenas/main.tscn"


# ============================================================
# INICIALIZAÇÃO
# ============================================================

func _ready():

	# Garante que a seleção funcione mesmo se veio de uma cena pausada.
	get_tree().paused = false

	process_mode = Node.PROCESS_MODE_ALWAYS


# ============================================================
# SELEÇÃO DE CLASSE
# ============================================================

func select_player_class(selected_class):

	PlayerData.selected_class = selected_class

	get_tree().change_scene_to_file(MAIN_SCENE)


# ============================================================
# BOTÃO DUELISTA
# ============================================================

func _on_duelist_button_pressed():

	select_player_class(CLASS_DUELIST)


# ============================================================
# BOTÃO MAGO
# ============================================================

func _on_mage_button_pressed():

	select_player_class(CLASS_MAGE)
