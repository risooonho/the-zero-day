extends Node2D

func _ready():
	var player = PlayerManager.init_player(0)
	player.global_position = Vector2(140, 100)
	add_child(player)
	player.enable_player()
	
	$Camera.following = player
	$HUD.set_hud_actor(player)
	
	var item1 = Factory.ItemInWorldFactory.create_test_distance_weapon()
	item1.global_position = Vector2(200, 104)
	add_child(item1)
	
	var item2 = Factory.ItemInWorldFactory.create_test_distance_weapon()
	item2.global_position = Vector2(200, 103)
	add_child(item2)
	
	var item3 = Factory.ItemInWorldFactory.create_test_distance_weapon()
	item3.global_position = Vector2(200, 102)
	add_child(item3)
	
	var item4 = Factory.ItemInWorldFactory.create_test_ammo()
	item4.global_position = Vector2(200, 101)
	add_child(item4)
	
	var item5 = Factory.ItemInWorldFactory.create_test_ammo()
	item5.global_position = Vector2(201, 100)
	add_child(item5)