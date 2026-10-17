extends SceneTree
var errors:Array=[]
var game
var capture_dir=""
func check(ok:bool,message:String):
	if not ok:errors.append(message);push_error(message)
func _initialize():call_deferred("verify")
func shot(name:String):
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(capture_dir.path_join("mechanics15_"+name+".png"))==OK,"capture "+name)
func reset():
	game.progress.upgrades=[0,0,0,0,0,0,0,0];game.progress.checkpoint=0;game.mode="story"
	game.start_run();game.notice_time=0;game.subtitle_time=0;game.entities.clear();game.next_pattern=1e9;game.air_delay=99999;game.speed=0
func enemy(kind:String,hp:float=50):
	game.hood={"kind":kind,"hp":hp,"grip":0.0,"anim":"Idle","anim_time":0.0,"wait":0.0}
	game.hood_time=2;game.dying_hood.clear()
func key(index:int,pressed:bool):
	var e=InputEventKey.new();e.physical_keycode=int(game.progress.settings.keys[index]);e.pressed=pressed;game._input(e)
func verify():
	AudioServer.set_bus_volume_db(0,-80)
	root.size=Vector2i(2047,806);root.content_scale_size=Vector2i(1280,720)
	game=Node2D.new();game.set_script(load("res://scripts/game.gd"));root.add_child(game)
	game.set_process(false);game.test_mode=true;game.preview_mode=true
	game.snd.silent=true;game.snd.stop_action();game.snd.music.stop()
	check(game.progress.ephemeral,"all mechanics checks use isolated progress")
	capture_dir=ProjectSettings.globalize_path("res://../analysis") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().path_join("../analysis")
	reset()
	await shot("wipers_parked")
	check(game.wiper_frame()==0 and game.art.anim_count("wipers")==28,"parked wipers remain an authored visible frame")
	game.blood=[{"slot":10,"frame":0,"life":1.0},{"slot":12,"frame":0,"life":1.0}]
	await shot("blood_fresh")
	key(6,true);game.update_wipers(0.2)
	check(game.blood[0].frame==1,"first sweep advances original blood-cleaning stage")
	await shot("wipers_up")
	game.update_wipers(0.2);await shot("wipers_top")
	key(6,false);game.update_wipers(0.3)
	check(game.blood[0].frame==2,"return sweep advances second blood stage")
	await shot("blood_wiped")
	game.update_wipers(0.3)
	check(game.wiper_frame()==0 and game.wipe_time==0,"released wipers park after full sweep")
	game.attack();game.update_action_animation(0.6)
	check(game.glass_hp<100,"punch still damages windshield")
	key(6,true)
	for i in range(240):game.update_wipers(1.0/60)
	key(6,false);game.update_wipers(1.0)
	check(game.blood.is_empty() and game.wiper_frame()==0,"held cleaning continues through punch then parks")
	game.damage_glass(100)
	key(6,true);game.update_wipers(0.3)
	check(game.wiper_frame()>0,"clean control remains responsive with broken glass")
	key(6,false);game.update_wipers(1.0)
	await shot("broken_wipers_parked")
	reset()
	# Exercise the real audio channel with the device output muted.
	game.snd.silent=false
	key(5,true);await process_frame
	check(game.snd.horn_player.playing,"holding horn starts its dedicated channel")
	for i in range(50):game.horn()
	check(game.snd.effects.all(func(p):return not p.playing),"horn spam cannot stack effect voices")
	key(5,false)
	check(not game.snd.horn_player.playing and game.horn_time==0,"horn release stops immediately")
	for i in range(10):key(5,true);key(5,false)
	check(not game.snd.horn_player.playing,"rapid horn taps end cleanly")
	key(5,true);game.set_pause()
	check(not game.snd.horn_player.playing,"pause cannot leave horn stuck")
	game.snd.silent=true
	for kind in ["male","female","hard","super","soldier"]:
		reset();enemy(kind,100)
		for i in range(1200):
			game.glass_hp=100;game.update_hood(1.0/60,false)
			var p=game.hood_pose()
			check(not p.is_empty() and not p.inside and game.hood.anim not in ["Shot","GetOff","Kill"],"live "+kind+" stays in arrival/idle/attack states")
		game.glass_hp=0;game.glass_break_time=2;game.hood_state("Idle")
		for i in range(90):game.update_hood(1.0/60,false)
		check(game.health==100 and not game.hood_pose().inside,"broken glass does not instantly run finishing clip: "+kind)
		await shot("broken_"+kind+"_idle")
		game.hood.hp=50;game.attack_time=0
		for i in range(5):key(7,true);game.update_action_animation(0.6)
		check(game.hood.hp==50 and game.hood.anim=="Idle" and game.attack_time==0 and game.dying_hood.is_empty(),"unarmed attack cannot damage or dislodge "+kind)
	reset();enemy("male");game.glass_hp=0;game.glass_break_time=2;game.hood_state("Kill")
	game.update_hood(0.1,false);key(7,true);game.update_action_animation(0.6)
	check(game.hood.hp==50 and game.hood.anim=="Kill" and game.attack_time==0,"unarmed attack cannot interrupt finishing lunge")
	# Exercise both real input routes with/without glass, firearm and ammunition.
	for mouse in [false,true]:
		for glass in [100,0]:
			for armed in [false,true]:
				for bullets in [0,3]:
					reset();enemy("male");game.glass_hp=glass;game.progress.upgrades[2]=int(armed);game.ammo=bullets
					if mouse:
						var e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=true;game._input(e)
					else:key(7,true)
					var can_fire=armed and bullets>0
					check((game.attack_time>0)==can_fire,"only loaded pistol starts an attack against clinger")
					game.update_action_animation(0.5)
					check(game.hood.hp==50 and game.ammo==bullets,"shot waits for authored muzzle event")
					game.update_action_animation(0.1)
					if can_fire:
						check(game.hood.is_empty() and game.ammo==bullets-1 and game.dying_hood.anim=="Shot","pistol works regardless of windshield through either input")
						check(game.glass_hp==maxi(0,glass-70),"shot applies original windshield damage")
					else:
						check(game.hood.hp==50 and game.hood.anim=="Idle" and game.glass_hp==glass and game.attack_time==0,"missing gun/ammo never falls back to punching")
		for armed in [false,true]:
			reset();game.progress.upgrades[2]=int(armed);game.ammo=3
			if mouse:
				var e=InputEventMouseButton.new();e.button_index=MOUSE_BUTTON_LEFT;e.pressed=true;game._input(e)
			else:key(7,true)
			check(game.attack_kind=="punch" and game.attack_time>0,"clear hood selects windshield punch")
			# An enemy arriving during the punch must not become a melee target.
			enemy("male");game.update_action_animation(0.6)
			check(game.glass_hp<100 and game.hood.hp==50 and game.hood.anim=="Idle","punch damages only windshield")
			game.hood.clear();game.glass_hp=0;game.attack_time=0;key(7,true)
			check(game.attack_time==0 and game.ammo==3,"empty hood and broken glass cause no attack")
	reset();enemy("male");game.glass_hp=0;game.glass_break_time=2;game.progress.upgrades[2]=1;game.ammo=3
	game.attack();game.update_action_animation(0.6)
	check(game.hood.is_empty() and game.dying_hood.anim=="Shot" and game.ammo==2,"only a fired pistol selects headshot animation")
	await shot("pistol_shot")
	var duration=game.hood_state_duration(game.dying_hood)
	for i in range(ceil(duration*60)+2):game.simulate(1.0/60,0,false,false,0)
	check(game.dying_hood.is_empty(),"pistol death ends once at authored boundary")
	for side in [-1,1]:
		reset();enemy("male",20);game.player_x=side*8.95;game.speed=85;game.lateral=side*4
		game.simulate(0.1,1,false,false,side)
		check(game.hood.is_empty() and game.dying_hood.anim=="GetOff","wall impact can dislodge enemy on side "+str(side))
		check(game.car_hp<100 and game.wall_contact==side,"wall contact damages car on correct side")
		await shot("wall_"+str(side))
		game.player_x=0;game.lateral=0;game.simulate(0.1,0,false,false,0)
		check(game.wall_contact==0,"sparks stop after leaving wall")
	reset();enemy("female",50);game.speed=90
	game.collide(game.spawn_entity("cars",0,game.position_z))
	check(game.hood.is_empty() and game.dying_hood.anim=="GetOff","car collision dislodges without headshot")
	reset();enemy("male");game.glass_hp=0;game.glass_break_time=2
	for i in range(360):
		if not game.hood.is_empty():game.update_hood(1.0/60,false)
	check(game.health<=0 and game.hood.is_empty(),"unopposed finishing attack runs once after warning delay")
	reset();await shot("final_parked")
	# The padded hood atlases must sustain animation on the user's RX 550.
	enemy("male");var frames=0;var began=Time.get_ticks_msec();var last=began
	while Time.get_ticks_msec()-began<3000:
		var now=Time.get_ticks_msec();game.update_hood(minf(0.05,(now-last)/1000.0),false);last=now
		game.queue_redraw();await process_frame;frames+=1
	print("HOOD15_RENDER_FPS: ",frames*1000.0/(Time.get_ticks_msec()-began))
	check(frames>=90,"hood animation sustains at least 30 FPS during playback")
	print("MECHANICS15_CHECK: ","PASS" if errors.is_empty() else "FAIL"," ",errors)
	quit(0 if errors.is_empty() else 1)
