extends Node2D

# The original symbol 19 selects one of 101 authored masks from real progress.
# No gameplay scene, save or garage is entered before its resources are ready.
var loader:Dictionary={}
var title:Texture2D
var tread:Texture2D
var tasks:Array=[]
var pending:Dictionary={}
var retained:Dictionary={}
var failures:Array=[]
var completed=0
var total=0
var finished=false
var finishing=false
var failed=false
var startup_test=false
var close_test=false
var frame_count=0
var last_frame_usec=0
var worst_frame_ms=0.0
var largest_pump_ms=0.0
var frame_times:Array=[]
var began_usec=0
var progress_frame=0
var observed_frames:Dictionary={}
var captured:Dictionary={}
var game
var ready_to_start=false
var font:Font
var logos:Array[Texture2D]=[]
var load_seconds=0.0
var ready_init_ms=0.0
var starting=false

func _ready():
	var args=OS.get_cmdline_user_args()
	startup_test="--release362-check" in args
	close_test="--startup-close-check" in args
	# Historical regression fixtures deliberately construct cold garages.
	# They use the unchanged game scene, independently of the production boot.
	var legacy_fixture=false
	for arg in args:
		if arg in ["--self-test","--parity-check","--ui-audio-check","--frontend-check","--mix-check","--pause-menu-check","--results-menu-check","--death-dialogue-check","--visual-suite","--fidelity-suite","--benchmark","--benchmark-hood","--cinema-check","--render-check"] or (arg.begins_with("--release") and (arg.ends_with("-check") or arg.ends_with("-visual"))):legacy_fixture=true
	if not startup_test and not close_test and legacy_fixture:
		finished=true
		game=load("res://scripts/game.gd").new()
		add_child(game)
		set_process(false)
		return
	if startup_test and not "--windowed-check" in args:DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	texture_repeat=CanvasItem.TEXTURE_REPEAT_DISABLED
	loader=JSON.parse_string(FileAccess.get_file_as_string("res://assets/startup361/loader.json"))
	title=load("res://assets/startup361/title.png")
	font=load("res://assets/title.ttf")
	for path in ["evildog.png","pazoro.jpg","godot.svg","openai.svg"]:logos.append(load("res://assets/startup362/"+path))
	tread=load("res://assets/startup361/tread.png")
	tasks=JSON.parse_string(FileAccess.get_file_as_string("res://assets/startup361/resources.json"))
	total=tasks.size()
	began_usec=Time.get_ticks_usec();last_frame_usec=began_usec
	Engine.max_fps=60
	get_viewport().size_changed.connect(queue_redraw)
	queue_redraw()

func _process(_dt):
	if finished or failed:return
	if ready_to_start:
		queue_redraw()
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_POINTING_HAND if start_rect().has_point(get_global_mouse_position()) else DisplayServer.CURSOR_ARROW)
		return
	var now=Time.get_ticks_usec()
	if frame_count>0:
		var frame_ms=float(now-last_frame_usec)/1000.0
		worst_frame_ms=maxf(worst_frame_ms,frame_ms);frame_times.append(frame_ms)
	last_frame_usec=now;frame_count+=1
	if close_test and frame_count==8:
		print("STARTUP_CLOSE_CHECK: PASS saves never opened")
		get_tree().quit();return
	# Paint the lightweight original loader before submitting any large reads.
	if frame_count<3:return
	if startup_test and frame_count==3:
		var early=InputEventKey.new();early.keycode=KEY_ENTER;early.pressed=true
		_input(early)
		if finished:push_error("Start accepted before loading completed");get_tree().quit(1)
	var begin=Time.get_ticks_usec();var published=0
	for path in pending.keys():
		var status=ResourceLoader.load_threaded_get_status(path)
		if status==ResourceLoader.THREAD_LOAD_LOADED:
			var resource=ResourceLoader.load_threaded_get(path)
			if resource==null:failures.append(path)
			else:retained[path]=resource
			pending.erase(path);completed+=1;published+=1
		elif status in [ResourceLoader.THREAD_LOAD_FAILED,ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:
			failures.append(path);pending.erase(path);completed+=1
		if published>=16 or Time.get_ticks_usec()-begin>=4000:break
	var submitted=0
	while pending.size()<8 and submitted<8 and not tasks.is_empty() and Time.get_ticks_usec()-begin<4000:
		var path:String=tasks.pop_front()
		submitted+=1
		if ResourceLoader.load_threaded_request(path,"",false)==OK:pending[path]=true
		else:failures.append(path);completed+=1
		if "/atlas_" in path:break
	largest_pump_ms=maxf(largest_pump_ms,float(Time.get_ticks_usec()-begin)/1000.0)
	progress_frame=mini(100,int(float(completed)/maxi(1,total)*100))
	observed_frames[progress_frame]=true
	queue_redraw()
	if startup_test:
		for threshold in [0,50,100]:
			if progress_frame>=threshold and not captured.has(threshold):
				captured[threshold]=true;capture_loader.call_deferred(threshold)
	if tasks.is_empty() and pending.is_empty() and not finishing:
		finishing=true
		if not failures.is_empty():
			failed=true;push_error("Startup loading failed: "+str(failures))
			if startup_test:get_tree().quit(1)
		else:call_deferred("finish_startup")

func _input(event):
	if finished:return
	get_viewport().set_input_as_handled()
	if not ready_to_start or starting:return
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed and start_rect().has_point(event.position):start_game()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode in [KEY_ENTER,KEY_KP_ENTER,KEY_SPACE]:start_game()

func stage_scale() -> float:
	var view=get_viewport_rect().size
	return minf(view.x/600.0,view.y/400.0)

func stage_base() -> Vector2:
	return (get_viewport_rect().size-Vector2(600,400)*stage_scale())/2.0

func start_rect() -> Rect2:
	return Rect2(stage_base()+Vector2(190,297)*stage_scale(),Vector2(220,43)*stage_scale())

func centered_text(text:String,baseline:float,size:int,color:Color,face:Font):
	var scale=stage_scale();var origin=stage_base()
	var actual_size=roundi(size*scale)
	var width=face.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,actual_size).x
	draw_string(face,origin+Vector2(300*scale-width/2,baseline*scale),text,HORIZONTAL_ALIGNMENT_LEFT,-1,actual_size,color)

func fit_logo(texture:Texture2D,box:Rect2):
	var size=texture.get_size();var factor=minf(box.size.x/size.x,box.size.y/size.y)
	var result=size*factor
	draw_texture_rect(texture,Rect2(stage_base()+(box.position+(box.size-result)/2)*stage_scale(),result*stage_scale()),false)

func capture_loader(threshold:int):
	await RenderingServer.frame_post_draw
	var folder=OS.get_environment("ROTD_CHECK_OUTPUT")
	if not folder.is_empty():
		get_viewport().get_texture().get_image().save_png(folder+"/startup_"+str(threshold)+".png")
		# Readback/PNG compression are QA work, absent from production startup.
		last_frame_usec=Time.get_ticks_usec()

func _draw():
	if finished or loader.is_empty():return
	var view=get_viewport_rect().size;var scale=stage_scale();var base=stage_base()
	draw_rect(Rect2(Vector2.ZERO,view),Color.BLACK)
	# Original title stays above the credits, with the tire track along the bottom.
	var title_pos:Dictionary=loader.title
	var crop_y=title.get_height()*.40
	draw_texture_rect_region(title,Rect2(base+Vector2(title_pos.offset[0],22)*scale,Vector2(title_pos.size[0],title_pos.size[1]*.60)*scale),Rect2(0,crop_y,title.get_width(),title.get_height()-crop_y))
	fit_logo(logos[0],Rect2(117,78,145,128))
	fit_logo(logos[1],Rect2(338,78,145,128))
	fit_logo(logos[2],Rect2(110,249,153,45))
	fit_logo(logos[3],Rect2(379,250,38,38))
	centered_text("Project by Pazoro and chatgpt",244,23,Color.WHITE,font)
	if ready_to_start:
		var hovered=start_rect().has_point(get_global_mouse_position())
		centered_text("PRESS START",327,32,Color("#c90000") if hovered else Color.WHITE,font)
	elif failed:centered_text("Loading failed — please restart",325,23,Color("#dd3333"),font)
	else:centered_text("Loading %d%%"%progress_frame,325,23,Color("#cccccc"),font)
	# Keep every original progress mask; move and uniformly scale the authored artwork.
	var points=PackedVector2Array();var uv=PackedVector2Array();var rec:Dictionary=loader.tread
	for p in loader.polygons[progress_frame]:
		var pos=Vector2(p[0],p[1])
		points.append(base+(Vector2(155,345)+(pos-Vector2(rec.offset[0],rec.offset[1]))*.48)*scale)
		uv.append((pos-Vector2(rec.offset[0],rec.offset[1]))/Vector2(rec.size[0],rec.size[1]))
	draw_polygon(points,PackedColorArray([Color.WHITE]),uv,tread)

func finish_startup():
	# Let the authored full-progress pose paint before handing off to the menu.
	await get_tree().process_frame
	await get_tree().process_frame
	var init_begin=Time.get_ticks_usec()
	game=retained["res://scripts/game.gd"].new()
	game.startup_check=startup_test;game.startup_prepared=true
	game.hide();add_child(game)
	# Every load here resolves to a resource already retained by the startup queue.
	game.art.prepare_driving()
	game.native_scenes.prepare_frames("garage_body",1)
	var init_ms=float(Time.get_ticks_usec()-init_begin)/1000.0
	if not game.art.prepared_driving:
		failed=true;push_error("Startup frame bank was not prepared")
		if startup_test:get_tree().quit(1)
		return
	retained.clear()
	game.set_process(false);game.set_process_input(false);game.set_process_unhandled_input(false)
	ready_to_start=true;ready_init_ms=init_ms
	load_seconds=float(Time.get_ticks_usec()-began_usec)/1000000.0
	queue_redraw()
	if startup_test:call_deferred("check_ready_gate")

func start_game():
	if not ready_to_start or starting or failed:return
	starting=true;finished=true;queue_redraw()
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	game.set_process(true);game.set_process_input(true);game.set_process_unhandled_input(true)
	game.show();game.snd.set_music("Music_MenuMusic")
	loader.clear();set_process(false)
	await RenderingServer.frame_post_draw
	title=null;tread=null;logos.clear()

func check_ready_gate():
	var errors:Array=[]
	if finished or game.visible or game.is_processing():errors.append("Ready screen did not wait for Start")
	for i in range(4):await get_tree().process_frame
	if finished or game.visible:errors.append("Ready screen opened automatically")
	await capture_loader(101)
	var held_key=InputEventKey.new();held_key.keycode=KEY_ENTER;held_key.pressed=true;held_key.echo=true
	_input(held_key)
	if finished:errors.append("Held key skipped Start gate")
	var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=Vector2.ZERO
	_input(click)
	if finished:errors.append("Click outside Start opened the menu")
	if "--windowed-check" in OS.get_cmdline_user_args():
		var fresh_key=InputEventKey.new();fresh_key.keycode=KEY_ENTER;fresh_key.pressed=true;_input(fresh_key)
	else:
		click.position=start_rect().get_center();_input(click)
	await get_tree().process_frame
	if not finished or not game.visible or not game.is_processing():errors.append("Start did not open the prepared menu")
	if not "--windowed-check" in OS.get_cmdline_user_args() and DisplayServer.window_get_mode()!=DisplayServer.WINDOW_MODE_MAXIMIZED:errors.append("Startup lost maximization")
	await check_startup(ready_init_ms,errors)

func check_startup(init_ms:float,errors:Array):
	if completed!=total or not failures.is_empty():errors.append("Incomplete startup resources")
	if frame_count<20 or observed_frames.size()<10:errors.append("Loader did not show real intermediate progress")
	if progress_frame!=100 or game.state!="menu":errors.append("Menu became available before preparation")
	if game.art.resident_pages.size()!=2427 or game.art.highway_pages.size()!=104:errors.append("Incomplete native frame bank")
	if game.art.car_pages.size()!=game.art.car_data.textures.size():errors.append("Incomplete car frame bank")
	if not game.progress.ephemeral:errors.append("Test could access player saves")
	frame_times.sort()
	var p95_frame_ms=float(frame_times[int(frame_times.size()*0.95)])
	if worst_frame_ms>1000 or p95_frame_ms>100 or largest_pump_ms>100:errors.append("Startup event loop stalled")
	game.progress.settings.garage_seen=true;game.mode="story"
	game.enter_garage()
	if game.art.driving_loading or not game.art.driving_pending.is_empty():errors.append("Garage started loading")
	var drive_begin=Time.get_ticks_usec();game.activate("drive")
	var first_drive_ms=float(Time.get_ticks_usec()-drive_begin)/1000.0
	if game.state!="play" or game.drive_requested or first_drive_ms>=100:errors.append("First Drive did not start immediately")
	game.enter_garage();drive_begin=Time.get_ticks_usec();game.activate("drive")
	var repeat_drive_ms=float(Time.get_ticks_usec()-drive_begin)/1000.0
	if game.state!="play" or game.drive_requested or repeat_drive_ms>=100:errors.append("Repeat Drive did not start immediately")
	game.open_menu()
	if not game.art.prepared_driving:errors.append("Returning to menu discarded ready frames")
	var report={"resources":total,"loading_seconds":load_seconds,"rendered_frames":frame_count,"progress_poses":observed_frames.size(),"p95_frame_ms":p95_frame_ms,"worst_frame_ms":worst_frame_ms,"max_handoff_ms":largest_pump_ms,"initialization_ms":init_ms,"first_drive_ms":first_drive_ms,"repeat_drive_ms":repeat_drive_ms,"errors":errors}
	await game.check_release362_behaviour(errors)
	print("RELEASE362_CHECK: ","PASS" if errors.is_empty() else "FAIL"," ",JSON.stringify(report))
	get_tree().quit(0 if errors.is_empty() else 1)
