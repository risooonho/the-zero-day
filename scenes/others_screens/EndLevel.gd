extends Node2D

func _ready():
	get_tree().paused = false
	
	if Main.result == Main.Result.WIN:
		MusicManager.play(MusicManager.Music.VICTORY)
		win()
	elif Main.result == Main.Result.LOSE:
		MusicManager.play(MusicManager.Music.GAME_OVER)
		lose()
	else:
		print_debug("No se a ganado ni perdido")
	
	$MoneyDisplay.amount_to_show(Main.store_money)
	
func win():
	$Title.text = "YOU WIN!!"
	
	AdventureManager.current_level += 1
	
	if AdventureManager.current_level <= AdventureManager.ADVENTURE_LEVEL_MAX:
		if AdventureManager.current_level > AdventureManager.current_maximum_level:
			AdventureManager.current_maximum_level += 1
	else:
		print_debug("Se a llegado al nivel maximo")
	
func lose():
	$Title.text = "YOU LOSE.."
	
	Main.store_money = round(Main.store_money / 2)

func _on_Next_pressed():
	if AdventureManager.current_level <= AdventureManager.ADVENTURE_LEVEL_MAX:
		get_tree().change_scene(AdventureManager.get_level(AdventureManager.current_level))
	else:
		get_tree().change_scene("res://scenes/maps/adventure_mode/main_history/end/TheEnd.tscn")

func _on_Restart_pressed():
	if Main.result == Main.Result.WIN:
		AdventureManager.current_level -= 1
		get_tree().change_scene(AdventureManager.get_level(AdventureManager.current_level))
	elif Main.result == Main.Result.LOSE:
		get_tree().change_scene(AdventureManager.get_level(AdventureManager.current_level))

func _on_Back_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")
