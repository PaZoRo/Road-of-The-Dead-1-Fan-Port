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
	check(root.get_texture().get_image().save_png(capture_dir.path_join("car14_"+name+".png"))==OK,"capture "+name)
func verify():
	AudioServer.set_bus_volume_db(0,-80)
	root.size=Vector2i(1280,720);root.content_scale_size=Vector2i(1280,720)
	game=Node2D.new();game.set_script(load("res://scripts/game.gd"));root.add_child(game)
	game.set_process(false);game.test_mode=true;game.preview_mode=false
	check(game.progress.ephemeral,"car preview uses isolated progress")
	game.snd.silent=true;game.snd.stop_action();game.snd.music.stop()
	capture_dir=ProjectSettings.globalize_path("res://../analysis") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().path_join("../analysis")
	game.progress.upgrades=[0,0,0,0,0,0,0,0];game.progress.checkpoint=0;game.mode="story"
	game.start_run();game.notice_time=0;game.subtitle_time=0;game.speed=0;game.entities.clear()
	var map_origin=game.art.cockpit_map(Vector2.ZERO)
	var x_unit=game.art.cockpit_map(Vector2(100,0))-map_origin
	var y_unit=game.art.cockpit_map(Vector2(0,100))-map_origin
	check(absf(x_unit.length()-y_unit.length())<0.001,"uniform car scale keeps circles round")
	check(game.bumper_frame()==10 and game.windshield_frame()==0,"unupgraded car selects intact stock hood and glass")
	check(game.speedometer_frame()==0,"stopped car uses original zero needle frame")
	for name in ["stock","left","right","shift","punch","shoot","damage","armored"]:
		game.steering=-1.0 if name=="left" else (1.0 if name=="right" else 0.0)
		game.gear_arm_frame=10 if name=="shift" else 0;game.gear_stick_frame=game.gear_arm_frame
		game.attack_time=0;game.car_hp=100;game.glass_hp=100;game.armor_level=0
		if name in ["punch","shoot"]:
			game.attack_kind=name;game.attack_time=1;game.attack_elapsed=0.6
		if name=="damage":game.car_hp=45;game.glass_hp=40
		if name=="armored":game.armor_level=3
		await shot(name)
	game.attack_time=0;game.car_hp=100;game.glass_hp=100;game.armor_level=0
	for speed in [0,55,110]:
		game.speed=speed;check(game.speedometer_frame()==roundi(speed/110.0*70),"original stock speedometer range "+str(speed))
		await shot("speed_"+str(speed))
	game.speed=0;game.steering=0
	var wheel_before=game.art.cockpit_map(Vector2(328.86,575.82))
	root.size=Vector2i(2047,806)
	await process_frame;await process_frame
	game.update_viewport_layout()
	check(game.RW>1800 and absf(game.get_viewport_rect().size.y-720)<1,"ultrawide view expands horizontally")
	var wheel_after=game.art.cockpit_map(Vector2(328.86,575.82))
	check(absf((wheel_after.x-wheel_before.x)-(game.RW-1280)*0.5)<0.01,"wide view centers car without stretching its parts")
	check(absf(wheel_after.y-wheel_before.y)<0.01,"wide view preserves vertical placement")
	await shot("ultrawide_stock")
	game.open_menu();await shot("ultrawide_menu")
	check(is_equal_approx(game.UI_OFFSET.x,(game.RW-1080)*0.5),"existing menu stays centered at its authored size")
	await game.frontend_click("options")
	check(game.state=="options","wide menu mouse targets align")
	await game.frontend_click("options_close")
	check(game.state=="menu","wide options close aligns")
	game.start_run();game.notice_time=0;game.subtitle_time=0;game.entities.clear();game.next_pattern=1e9;game.air_delay=999
	for i in range(300):game.simulate(1.0/60,1,false,false,0)
	check(game.speed>40 and game.gear>0,"car accelerates and shifts")
	await shot("ultrawide_driving")
	print("CAR_CHECK: ","PASS" if errors.is_empty() else "FAIL"," ",errors)
	quit(0 if errors.is_empty() else 1)
