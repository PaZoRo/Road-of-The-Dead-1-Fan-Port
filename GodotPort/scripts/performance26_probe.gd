extends SceneTree

var game
var ready=false
var phase="gameplay"
var age=0.0
var frames:Array=[]
var report={}
var label="baseline"
var fixed_z=0.0
var zombie
var civilian
var initial_zombie_z=0.0
var initial_civilian_x=0.0
var phase_loads=0
var phase_crash_us=0

func _initialize():
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--probe-label="):label=a.trim_prefix("--probe-label=")
	game=load("res://main.tscn").instantiate()
	root.add_child.call_deferred(game)
	call_deferred("begin")

func begin():
	game.set_process(false);game.test_mode=true;game.preview_mode=true
	game.progress.ephemeral=true;game.progress.upgrades=[1,1,1,1,0,0,0,0]
	game.progress.settings.fullscreen=false;game.progress.settings.fps=60
	game.snd.silent=false;game.apply_settings();AudioServer.set_bus_volume_db(0,-80)
	game.rng.seed=242424;game.mode="story";game.progress.checkpoint=8;game.start_run()
	game.entities.clear();game.speed=100;game.next_pattern=game.position_z+60;game.post_checkpoint_pending=false
	game.air_delay=5;game.helicopter_delay=5;game.jet_delay=8
	game.hood={"kind":"hard","hp":500.0,"attack":0.0,"grip":0.0};game.hood_time=2
	phase_loads=game.art.perf_texture_misses
	ready=true

func _process(dt):
	if not ready:return false
	age+=dt
	game._process(dt)
	if phase=="gameplay":
		game.health=100;game.car_hp=100;game.fire_started=false;game.speed=100
		game.simulate(minf(dt,.05),1.0,false,false,sin(age*.8)*.7)
	if age>.1:frames.append(dt)
	if phase=="gameplay" and age>=20:
		finish_phase()
		game.entities.clear();game.hood.clear();game.effects.clear();game.impacts.clear()
		game.player_x=0;game.speed=90;game.notice_time=0;game.subtitle_time=0
		zombie=game.spawn_entity("male",-2.0,30.0+game.position_z);zombie.behavior="straight"
		civilian=game.spawn_entity("civilian",3.0,45.0+game.position_z)
		game.spawn_entity("cars",4.3,18+game.position_z)
		game.spawn_entity("feeders",-3.0,28+game.position_z)
		initial_zombie_z=zombie.z;initial_civilian_x=civilian.x;fixed_z=game.position_z
		game.car_hp=0
		var start=Time.get_ticks_usec()
		game.finish_run("The car was destroyed.",false,"Crash")
		report.finish_run_ms=float(Time.get_ticks_usec()-start)/1000.0
		phase="crash";age=0;frames.clear();phase_loads=game.art.perf_texture_misses;phase_crash_us=game.crash_sync_load_us
	elif phase=="crash" and age>=12:
		finish_phase()
		report.world_motion={"zombie_moved":zombie.z!=initial_zombie_z,"civilian_moved":civilian.x!=initial_civilian_x,"player_stopped":game.position_z==fixed_z,"death_time":game.death_screen_time}
		report.gpu=RenderingServer.get_video_adapter_name()
		report.texture_load_events=game.art.perf_load_events
		var path=ProjectSettings.globalize_path("res://../analysis/")
		if not OS.has_feature("editor"):path=OS.get_executable_path().get_base_dir()+"/../analysis/"
		var f=FileAccess.open(path+"performance24_"+label+".json",FileAccess.WRITE)
		f.store_string(JSON.stringify(report,"	"));f.close()
		print("PERFORMANCE24 ",label," ",JSON.stringify(report))
		quit()
	return false

func finish_phase():
	var total=0.0;var over33=0;var over50=0;var over100=0
	for t in frames:
		total+=t
		if t>.0334:over33+=1
		if t>.05:over50+=1
		if t>.1:over100+=1
	frames.sort()
	report[phase]={"average_fps":frames.size()/total,"p95_ms":frames[int(frames.size()*.95)]*1000,"p99_ms":frames[int(frames.size()*.99)]*1000,"max_ms":frames[-1]*1000,"frames":frames.size(),"over33_ms":over33,"over50_ms":over50,"over100_ms":over100,"texture_misses":game.art.perf_texture_misses-phase_loads,"sync_crash_load_ms":float(game.crash_sync_load_us-phase_crash_us)/1000.0}
	print("PERFORMANCE24 PHASE ",label," ",phase," ",JSON.stringify(report[phase]))
