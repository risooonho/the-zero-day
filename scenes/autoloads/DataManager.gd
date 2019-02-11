extends Node

# En la alpha v0.2.0 existira solo el usuario User por default
var current_user : String = "User"

var global_config # Es una referencia al diccionario de $GlobalConfig
var user_config # Es una referencia al diccionario de $UserConfig

# Instancias, para ser utilizadas. Instancias de RPGElements.
var players = []
var inventories = []
var stats = []

# Si este numero cambia la data se borra, normalmente el numero
# debe ir incrementando
var delete_data = 0

func _ready():
	configure_persistence_node()
	create_or_load_data_if_not_exist()

func configure_persistence_node():
	$DataGlobalConfig.folder_name = "Global"
	
	$DataUserConfig.folder_name = current_user
	$DataPlayers.folder_name = current_user
	$DataInventories.folder_name = current_user
	$DataStats.folder_name = current_user

func create_or_load_data_if_not_exist():
	global_config = $DataGlobalConfig.get_data()
	
	if global_config.empty():
		# Crea la data
		#

		create_global_config()
		create_players()
		create_user_config()
#		create_inventories()
#		create_stats()
	elif global_config["DeleteData"] != delete_data:
		remove_all_data()
		get_tree().quit()
	else:
		# Carga la data
		#
		
		# GlobalConfig ya se cargo anteriormente.
		
		load_players()
		load_user_config()
#		load_inventories()
#		load_stats()

func save_all_data():
	save_players()
	save_user_config()
#	save_inventories()
#	save_stats()

func create_global_config():
	global_config["DeleteData"] = delete_data
	$DataGlobalConfig.save_data()
	
func create_players():
	var temp_data
	temp_data = $DataPlayers.get_data("Players")

	players.append($RPGHelper.get_inst_character())

	# Esto solo funcionaria con un player
	temp_data[0] = inst2dict(players[0])

	$DataPlayers.save_data("Players")
	
func save_players():
	var temp_data = $DataPlayers.get_data("Players")
	temp_data.clear()
	
	for i in players.size():
		temp_data[i] = inst2dict(players[i])
	
	$DataPlayers.save_data("Players")
	
func load_players():
	var temp_data = $DataPlayers.get_data("Players")
	players = []

	for player in temp_data.values():
		players.append(dict2inst(player))

func create_user_config():
	user_config = $DataUserConfig.get_data("UserConfig")

#	shop_inventory = $HMRPGHelper.get_inst_weight_inventory()
#	ItemGenerator.create_item_pack_for_shop(shop_inventory)
	
#	Main.init_basic_user_config()
#	AchievementsManager.create_all_achievements()
	
	save_user_config()

func load_user_config():
	user_config = $UserConfig.get_data("UserConfig")
	
func save_user_config():
#	user_config["Gold"] = Main.current_gold
#	user_config["Emeralds"] = Main.current_emeralds
#	user_config["CurrentLevel"] = Main.current_level

	$DataUserConfig.save_data("UserConfig")

func create_inventories():
#	var w_inv = HMRPGHelper.get_inst_weight_inventory()
#	w_inv.max_weight = 10
#	w_inv.add_item(ItemGenerator.get_health_potion(Main.HMHealth.TYPE_10))
#	w_inv.add_item(ItemGenerator.get_health_potion(Main.HMHealth.TYPE_10))
#	w_inv.add_item(ItemGenerator.get_health_potion(Main.HMHealth.TYPE_10))
#
#	inventories.append(w_inv)
#
#	save_inventories()
	pass
	
func save_inventories():
#	var temp_data = $Inventories.get_data("Inventories")
#	temp_data.clear()
#
#	for i in inventories.size():
#		temp_data[i] = inventories[i].inv2dict()
#
#	$Inventories.save_data("Inventories")
	pass
	
func load_inventories():
#	var temp_data = $Inventories.get_data("Inventories")
#	var temp_inv = $HMRPGHelper.get_inst_weight_inventory()
#	inventories = []
#
#	for inventory in temp_data.values():
#		inventories.append(temp_inv.dict2inv(inventory))
		
	pass

func create_stats():
#	var temp_data
#	temp_data = $Stats.get_data("Stats")
#
#	var first_stats = $HMRPGHelper.get_inst_stats()
#	first_stats.add_stat("Strength", 0, 30)
#	first_stats.add_stat("Luck", 0, 20)
#	first_stats.add_stat("Vitality", 0, 30)
#
#	stats.append(first_stats)
#
#	temp_data[0] = inst2dict(stats[0])
#
#	$Stats.save_data("Stats")
	
	# Test
#	stats[0].add_points(100)
	pass
	
func load_stats():
#	var temp_data = $Stats.get_data("Stats")
#	stats = []
#
#	for stat in temp_data.values():
#		stats.append(dict2inst(stat))
	pass

func save_stats():
#	var temp_data = $Stats.get_data("Stats")
#	temp_data.clear()
#
#	for i in stats.size():
#		temp_data[i] = inst2dict(stats[i])
#
#	$Stats.save_data("Stats")
	pass
	
func remove_all_data():
	$DataGlobalConfig.remove_all_data()
	$DataPlayers.remove_all_data()
	$DataUserConfig.remove_all_data()
#	$Inventories.remove_all_data()
#	$Stats.remove_all_data()
	pass
