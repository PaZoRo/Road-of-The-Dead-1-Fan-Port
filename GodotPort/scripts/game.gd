extends Node2D

var achievement_system=preload("res://scripts/achievements.gd").new()
var achievement_fonts:Dictionary={}
var achievement_scroll=0.0
var achievement_scroll_direction=0
var achievement_pointer=Vector2.INF
var achievement_messages:Array=[]
var achievement_message:Dictionary={}
var achievement_message_time=0.0

const Assets = preload("res://scripts/assets.gd")
const Audio = preload("res://scripts/audio.gd")
const Progress = preload("res://scripts/progress.gd")
const W = 1080.0
const H = 720.0
const YELLOW_LINE_SPACING = 20.0
const YELLOW_LINE_VIEW_DISTANCE = 80.0
const FOCAL_X = 590.0
const FOCAL_Y = 590.0
var RW = 1280.0
var UI_OFFSET = Vector2(100,0)
const NativeScenes = preload("res://scripts/native_scene.gd")
const CHAPTERS = ["Evans City","Monroeville","Red Ridge","Burgony Street","Central City","Down Town","Chinatown","Brighton Square","North Side Park","West Ridge","Tunnel Drive"]
const ROAD_SIGN_SIDE_X = 10.0 # RDRoad.SideRoadPosX; posts sit behind the side walls.
const LENGTHS = [2000,300,2500,400,3000,500,3500,600,4000,700,4500,800,5000,900,6000,1000,5000,800,4000,600,3500,400]
const UPGRADE_NAMES = ["Perception","Body Armor","Firearm","Windshield","Engine","Bumper","Tires","Horn"]
const COSTS = [[350,700,1400],[300,600,1200],[300,600,1200],[250,500,1000],[250,500,1000],[300,600,1200],[250,500,1000],[100,250,500]]
const DESCRIPTIONS = ["Reveal approaching threats on the windshield.","Reduce injuries and recover health faster.","Carry 3 / 6 / 9 shots for enemies on the hood.","Stronger glass protects you from attacks.","Better acceleration and a higher top speed.","Take less damage and lose less speed on impact.","Sharper steering; improved grip on oil and spikes.","Warn civilians earlier. Noise also attracts zombies."]
const INK = Color("#161719")
const PAPER = Color("#e3ded4")
const RED = Color("#ad332f")
const AMBER = Color("#d0b576")

var startup_check=false
var startup_prepared=false
var art
var snd
var progress
var rng = RandomNumberGenerator.new()
var state = "menu"
var previous_state = "menu"
var mode = "story"
var buttons: Array = []
var patterns: Array = []
var entities: Array = []
var scenery: Array = []
var road_signs: Array = []
var next_road_sign = 50.0
var effects: Array = []
var blood: Array = []
var impacts: Array = []
var elapsed = 0.0
var total_time = 0.0
var position_z = 0.0
var start_z = 0.0
var player_x = 0.0
var lateral = 0.0
var speed = 0.0
var steering = 0.0
var wall_contact=0.0
var wall_sound_time=0.0
var health = 100.0
var car_hp = 100.0
var glass_hp = 100.0
var tires = 0
var tire_damage = 0.0
var tire_bias_timer = 0.0
var tire_bias_duration = 0.0
var tire_bias_strength = 0.0
var tire_bias_target = 0.0
var oil_time = 0.0
var oil_duration = 0.0
var oil_factor = 0.0
var fire_time = 0.0
var fire_started = false
var coolant_time = 0.0
var chapter_index = 0
var segment = 0
var segment_start = 0.0
var next_pattern = 80.0
var ammo = 0
var shots = 0
var kills = 0
var soldier_kills = 0
var civilians_hit = 0
var player_voice_bags:Dictionary={}
var hood_reacted=false
var soldier_voice2:Dictionary={}
var hood_kills = 0
var air_dodges = 0
var precision_hits = 0
var run_rp = 0
var result_reason = ""
var awarded = false
var attack_time = 0.0
var attack_kind = ""
var horn_time = 0.0
var wipe_time = 0.0
var shake = 0.0
var red_flash = 0.0
var hit_cooldown = 0.0
var body_recovery = 0.0
var hood: Dictionary = {}
var hood_time = 0.0
var notice = ""
var notice_time = 0.0
var subtitle = ""
var subtitle_time = 0.0
var air: Dictionary = {} # diagnostic injection only; gameplay uses separate source air entities
var air_delay = 32.0 # compatibility override used by older test paths
var helicopter: Dictionary = {}
var jet: Dictionary = {}
var helicopter_delay = 32.0
var jet_delay = 40.0
var helicopter_warning_index = 0
var entity_serial = 0
var time_left = 30.0
var nuke_time = 120.0
var last_nuke_call = -1
var perception = true
var brake_held = false
var test_mode = false
var preview_mode = false
var preview_frames = 0
var screenshot_pending = false
var fps_samples: Array = []
var test_errors: Array = []
var visual_suite = false
var benchmark_mode = false
var benchmark_start = 0
var ui_message = ""
var ui_message_time = 0.0
var selected_upgrade = -1
var panel_anim = 0.0
var garage_chatter_timer = 0.0
var garage_chatter_delay = 8.0
var garage_blink_timer = 0.0
var garage_blink_delay = 3.0
var garage_head_anim = "idle"
var garage_head_time = 0.0
var garage_upgrade_anim = -1
var garage_upgrade_time = 0.0
var armor_level = 0
var armor_break_level = 0
var armor_break_time = 0.0
var cooled = false
var glass_break_time = 0.0
var attack_elapsed = 0.0
var attack_resolved = false
var car35=preload("res://scripts/car35.gd").new()
var drive_requested=false
var desired_lateral=0.0
var side_damage=[0.0,0.0]
var side_window_time=[0.0,0.0]
var side_mirror_time=[0.0,0.0]
var car_smoking=false
var collision_bump_strength=0.0
var collision_bump_speed=0.0
var gear = 0
var shift_time = 0.0
var shift_start = 0
var shift_end = 0
var shift_target_gear = 0
var gear_arm_frame = 0
var gear_stick_frame = 0
var menu_time = 0.0
var rebind_index = -1
var delete_confirm = false
var cinema: AudioStreamPlayer
var native_scenes
var cinema_time=0.0
var garage_body_time=0.0
var handbrake_time=0.0
var shot_count=0
var parity_check=false
var cinema_screen:Control
var cinema_canvas
var vehicle_catalog:Dictionary={}
var cinema_next = "garage"
var cinema_name = ""
var dying_hood: Dictionary = {}
var ui_audio_check = false
var check_mouse=Vector2.ZERO
var fidelity_suite = false
var cinema_check = false
var frontend_check = false
var mix_check = false
var pause_menu_check = false
var results_menu_check = false
var death_dialogue_check = false
var death_screen_data:Dictionary={}
var crash_data:Dictionary={}
var crash_texture:Texture2D
var crash_page=-1
var crash_sync_load_us=0
var crash_textures:Dictionary={}
var death_explosion=false
var death_screen_clip=""
var death_screen_time=0.0
var death_points_sound=false
var death_point_rows:Array=[]
var hood_shot_kills=0
var hood_shaken_kills=0
# The original garage chooses a recorded reaction from the last fatal damage type.
const DEATH_DIALOGUES = {"Crash":4,"Zombie":4,"Military":4,"Helicopter":2,"Jet":2,"Nuke":2}
var fatal_cause = ""
var pending_death_cause = ""
var death_dialogue_bags: Dictionary = {}
var pending_mode = ""
var cinema_overlay: Node2D
const COCKPIT_OFFSET = Vector2(0,58)
const HOOD_SYMBOLS = {"male":"clingerzombienormalmale","female":"clingerzombienormalfemale","hard":"clingerzombiehard","super":"clingerzombieveryhard","soldier":"clingersoldier"}
const HOOD_FRAMES = {"male":[2,34,154,217,285,338],"female":[2,34,154,217,283,333],"hard":[2,32,152,222,293,345],"super":[2,35,155,196,251,301],"soldier":[2,25,140,193,220,270]}

var source_rules:Dictionary={}
var pattern_bags:Dictionary={}
var spawn_segment=0
var next_hard_pattern=0.0
var last_super_spawn=-5.0
var last_pattern:Dictionary={}
var pre_checkpoint_pending=true
var post_checkpoint_pending=true
var checkpoint_message:Dictionary={}
var checkpoint_queue:Array=[]
var checkpoint_time=0.0
var checkpoint_fonts:Dictionary={}

func source_story_dialog_active() -> bool:
	return post_checkpoint_pending or String(snd.radio_key).begins_with("CheckPoint") and String(snd.radio_key).ends_with("Post")

func source_pick_pattern(bag_key:String,choices:Array) -> String:
	if not pattern_bags.has(bag_key) or pattern_bags[bag_key].is_empty():pattern_bags[bag_key]=choices.duplicate()
	var bag:Array=pattern_bags[bag_key]
	var index=rng.randi_range(0,bag.size()-1)
	var value=String(bag[index]);bag.remove_at(index)
	return value

func source_item_allowed(item:Dictionary,optional:bool=false) -> bool:
	var type=String(item.type)
	var military_level=-1
	if type=="SoldierStationary":military_level=1
	elif type=="SoldierAlign":military_level=4
	elif type=="SoldierSpikes":military_level=6
	elif type=="SoldierBomb":military_level=10
	elif optional and (float(item.red)!=0 or float(item.blue)!=0):military_level=8
	if military_level>=0:return segment<18 and (segment>military_level or segment==military_level and not source_story_dialog_active())
	if type.begins_with("ZombieHard"):return segment>=6
	if type=="ZombieVeryHard":return elapsed-last_super_spawn>5 and (segment>12 or segment==12 and not source_story_dialog_active())
	if type=="Feeders":return segment>=2
	if type=="Spikes":return source_spike_level()>= (2 if mode=="police" else 4)
	return true

func source_spawn_item(item:Dictionary,anchor:float,stretch:float,flipped:bool,difficulty:float) -> float:
	if not source_item_allowed(item):return 0.0
	var type=String(item.type)
	var kind="cars"
	if type=="ZombieVeryHard":kind="super";last_super_spawn=elapsed
	elif type.begins_with("ZombieHard"):kind="hard"
	elif type.begins_with("ZombieNormal"):kind="male" if rng.randf()<0.5 else "female"
	elif type.begins_with("Soldier"):kind="soldier"
	else:kind={"Civilian":"civilian","Feeders":"feeders","WaterJug":"water","TrafficCone":"cone","Spikes":"spikes","Oil":"oil","TrafficBarrel":"barrel","Box":"box","ConstructionSign":"construction_sign","ElectronicSign":"electronic_sign","Fence":"fence","ShoppingCart":"shopping_cart"}.get(type,"cars")
	if kind=="oil" and rng.randf()>=0.1+difficulty*0.3:return 0.0
	var local_z=float(item.z)*stretch
	var e=spawn_entity(kind,float(item.x)*(-1.0 if flipped else 1.0),anchor+local_z)
	e.moving="Patrol" in type or kind=="civilian"
	e.behavior={"SoldierStationary":"stationary","SoldierAlign":"align","SoldierSpikes":"spikes","SoldierBomb":"bomb"}.get(type,"straight" if "Straight" in type else "patrol")
	e["source_type"]=type
	if kind=="cars":
		var pool=type
		if vehicle_catalog.types.has(type+"Intact") and rng.randf()>=0.1+difficulty*0.7:pool=type+"Intact"
		var choices:Array=vehicle_catalog.spawn_choices362.get(pool,vehicle_catalog.spawn_choices362.AllCar)
		var choice:Dictionary=choices[rng.randi_range(0,choices.size()-1)]
		e.anim="vehicle";e.frame=int(choice.frame)
		var pose=art.world_frame("vehicle",int(e.frame))
		e.height=2.0;e.radius=float(pose.rect[2])/maxf(1.0,float(pose.get("density",1.0)))*0.0075
		e["ambient_sound"]=String(choice.sound)
		space_vehicle365(e)
		local_z=float(e.z)-anchor
		e["ambient_channel"]="car_"+str(int(e.serial))
		if (float(item.red)!=0 or float(item.blue)!=0) and segment<18 and (segment>8 or segment==8 and not source_story_dialog_active()):
			var hidden_flip=float(item.blue)!=0 if flipped else float(item.red)!=0
			var hidden=spawn_entity("soldier",e.x+(-e.radius-0.5 if hidden_flip else e.radius+0.5),e.z+0.1)
			hidden.behavior="hidden";hidden["flip"]=hidden_flip;hidden["cover_x"]=hidden.x
	if kind=="soldier" and e.behavior=="spikes":
		attach_soldier_strip(e)
	return local_z

func load_source_pattern(name:String,anchor:float,difficulty:float) -> float:
	var pattern:Dictionary=source_rules.patterns[name]
	var dynamic=name.begins_with("general") or name.begins_with("military")
	var stretch=1.0+rng.randf()*(0.25+(1.0-difficulty)*0.25)
	if dynamic and not helicopter.is_empty():stretch+=0.5
	var flipped=rng.randf()<0.5
	var optional:Array=[];var space=0.0;var fixed_spawned=0;var optional_spawned=0
	for item in pattern.items:
		if dynamic and float(item.alpha)<1:
			if source_item_allowed(item,true):optional.append(item)
		else:
			var before=entity_serial
			space=maxf(space,source_spawn_item(item,anchor,stretch,flipped,difficulty))
			if entity_serial>before:fixed_spawned+=1
	var hazards:Array=source_rules.hardcore_hazards if mode=="hardcore" else source_rules.hazards
	for i in range(mini(int(hazards[segment]),optional.size())):
		var index=rng.randi_range(0,optional.size()-1)
		space=maxf(space,source_spawn_item(optional[index],anchor,stretch,flipped,difficulty));optional.remove_at(index);optional_spawned+=1
	last_pattern={"name":name,"anchor":anchor,"space":space,"stretch":stretch,"flipped":flipped,"fixed":fixed_spawned,"optional":optional_spawned,"hazard_limit":int(hazards[segment]),"spawn_segment":spawn_segment}
	return space

func spawn_source_pattern():
	while spawn_segment<21 and position_z+200>=segment_position(spawn_segment+1):spawn_segment+=1
	if spawn_segment==21:next_pattern+=99999;return
	var hard:Array=source_rules.hard_patterns[spawn_segment]
	var name=""
	var view_position=position_z-5.0+200.0
	if not hard.is_empty() and (helicopter.is_empty() or bool(helicopter.get("broken",false))) and view_position>=next_hard_pattern:
		name=source_pick_pattern("hard"+str(spawn_segment),hard);next_hard_pattern+=300+rng.randf()*100
	elif spawn_segment==17:name="56hardcheckpoint"
	elif spawn_segment==19:name="35mediumcheckpoint"
	else:
		var military=spawn_segment%2==1
		name=source_pick_pattern("military" if military else "general",source_rules.military if military else source_rules.general)
	var difficulty=clampf(position_z/segment_position(21),0,1)
	var space=load_source_pattern(name,next_pattern,difficulty)
	var gap=20+rng.randf()*20
	if fire_started and rng.randf()<0.05:spawn_entity("water",rng.randf_range(-7.5,7.5),next_pattern+gap/2)
	next_pattern+=space+gap
	last_pattern["gap"]=gap

func show_checkpoint_message(title:String,message:String):
	checkpoint_queue.append({"title":title,"message":message})
	if checkpoint_message.is_empty():checkpoint_message=checkpoint_queue.pop_front();checkpoint_time=0.0

func update_checkpoint_message(dt:float):
	if not achievement_message.is_empty():return
	if checkpoint_message.is_empty():return
	var previous=checkpoint_time;checkpoint_time+=dt
	if previous<0.5 and checkpoint_time>=0.5:snd.play("UpgradePerception",-8)
	if checkpoint_time>=4.3:
		checkpoint_message.clear()
		if not checkpoint_queue.is_empty():checkpoint_message=checkpoint_queue.pop_front();checkpoint_time=0

func checkpoint_pose() -> Vector2:
	var slide=clampf((checkpoint_time-0.5)/0.3,0,1)
	var fade=clampf(checkpoint_time-3.3,0,1)
	return Vector2(-500.0*pow(1.0-slide,4)*1.8,1.0-pow(fade,4))

func draw_checkpoint_message():
	if not achievement_message.is_empty():return
	if checkpoint_message.is_empty() or checkpoint_time<0.5:return
	var pose=checkpoint_pose()
	for cid in ["1777","1778"]:
		var text=String(checkpoint_message.title if cid=="1777" else checkpoint_message.message)
		if text.is_empty():continue
		var field:Dictionary=source_rules.message_fields[cid]
		var font:Font=checkpoint_fonts[cid]
		var size=int(float(field.height)*1.8)
		var center=Vector2(297.575 if cid=="1777" else 298.025,85.55 if cid=="1777" else 102.7)*1.8
		var width=(float(field.bounds[1])-float(field.bounds[0])-4.0)*1.8
		var baseline=center+Vector2(pose.x-width/2,font.get_ascent(size))
		draw_multiline_string_outline(font,baseline+Vector2(2,3),text,HORIZONTAL_ALIGNMENT_CENTER,width,size,-1,3,Color(0,0,0,pose.y*0.8))
		draw_multiline_string(font,baseline,text,HORIZONTAL_ALIGNMENT_CENTER,width,size,-1,Color(1,1,1,pose.y))

func _ready():
	texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	rng.randomize()
	var release365_check="--release365-check" in OS.get_cmdline_user_args()
	var release364_check="--release364-check" in OS.get_cmdline_user_args()
	var release363_check="--release363-check" in OS.get_cmdline_user_args()
	var release36_check="--release36-check" in OS.get_cmdline_user_args()
	var release35_check="--release35-check" in OS.get_cmdline_user_args()
	var release34_check="--release34-check" in OS.get_cmdline_user_args()
	var release33_check="--release33-check" in OS.get_cmdline_user_args()
	var release32_check="--release32-check" in OS.get_cmdline_user_args()
	var release31_check="--release31-check" in OS.get_cmdline_user_args()
	var release30_check="--release30-check" in OS.get_cmdline_user_args()
	var release29_check="--release29-check" in OS.get_cmdline_user_args()
	var release28_check="--release28-check" in OS.get_cmdline_user_args()
	var release27_check="--release27-check" in OS.get_cmdline_user_args()
	var release26_check="--release26-check" in OS.get_cmdline_user_args()
	var release25_check="--release25-check" in OS.get_cmdline_user_args()
	var release24_check="--release24-check" in OS.get_cmdline_user_args()
	var release23_check="--release23-check" in OS.get_cmdline_user_args()
	var release23_visual="--release23-visual" in OS.get_cmdline_user_args()
	var release22_check="--release22-check" in OS.get_cmdline_user_args()
	var release22_visual="--release22-visual" in OS.get_cmdline_user_args()
	var release21_check="--release21-check" in OS.get_cmdline_user_args()
	var release21_visual="--release21-visual" in OS.get_cmdline_user_args()
	var release20_check="--release20-check" in OS.get_cmdline_user_args()
	var release20_visual="--release20-visual" in OS.get_cmdline_user_args()
	parity_check="--parity-check" in OS.get_cmdline_user_args()
	ui_audio_check = "--ui-audio-check" in OS.get_cmdline_user_args()
	frontend_check = "--frontend-check" in OS.get_cmdline_user_args()
	mix_check = "--mix-check" in OS.get_cmdline_user_args()
	pause_menu_check = "--pause-menu-check" in OS.get_cmdline_user_args()
	results_menu_check = "--results-menu-check" in OS.get_cmdline_user_args()
	death_dialogue_check = "--death-dialogue-check" in OS.get_cmdline_user_args()
	test_mode = startup_check or release365_check or release364_check or release363_check or release36_check or release35_check or release34_check or release33_check or release32_check or release31_check or release30_check or release29_check or release28_check or release27_check or release26_check or release25_check or release24_check or release23_check or release23_visual or release22_check or release22_visual or release21_check or release21_visual or release20_visual or release20_check or death_dialogue_check or results_menu_check or pause_menu_check or mix_check or frontend_check or "--self-test" in OS.get_cmdline_user_args() or parity_check or ui_audio_check
	visual_suite = "--visual-suite" in OS.get_cmdline_user_args()
	fidelity_suite = "--fidelity-suite" in OS.get_cmdline_user_args()
	benchmark_mode = "--benchmark" in OS.get_cmdline_user_args() or "--benchmark-hood" in OS.get_cmdline_user_args()
	cinema_check = "--cinema-check" in OS.get_cmdline_user_args()
	preview_mode = release23_visual or release22_visual or release21_visual or release20_visual or "--render-check" in OS.get_cmdline_user_args() or visual_suite or benchmark_mode or fidelity_suite or cinema_check
	art=Assets.new()
	prepare_original_tutorial()
	crash_data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/crash24/crash.json"))
	prepare_crash_textures()
	death_screen_data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/death21/screens.json"))
	progress=Progress.new()
	progress.ephemeral=test_mode or preview_mode
	if not progress.ephemeral: progress.read_save()
	prepare_achievements364()
	snd=Audio.new()
	snd.silent=test_mode or preview_mode
	add_child(snd)
	snd.voice_started.connect(_voice_caption_started)
	snd.voice_finished.connect(_voice_caption_finished)
	source_rules=JSON.parse_string(FileAccess.get_file_as_string("res://assets/source26/rules.json"))
	for cid in ["1777","1778"]:checkpoint_fonts[cid]=load("res://assets/source26/"+source_rules.message_fields[cid].file)
	patterns=JSON.parse_string(FileAccess.get_file_as_string("res://assets/patterns.json"))
	native_scenes=NativeScenes.new()
	vehicle_catalog=JSON.parse_string(FileAccess.get_file_as_string("res://assets/world03/vehicles.json"))
	cinema_screen=Control.new();cinema_screen.position=UI_OFFSET;cinema_screen.size=Vector2(W,H);cinema_screen.clip_contents=true;cinema_screen.mouse_filter=Control.MOUSE_FILTER_IGNORE
	cinema_canvas=Node2D.new();cinema_canvas.set_script(preload("res://scripts/cinema_canvas.gd"));cinema_canvas.renderer=native_scenes
	cinema_screen.add_child(cinema_canvas);add_child(cinema_screen);cinema_screen.hide()
	cinema_overlay=Node2D.new();cinema_overlay.position=UI_OFFSET;cinema_overlay.z_index=10
	cinema_overlay.draw.connect(draw_cinema_overlay);add_child(cinema_overlay);cinema_overlay.hide()
	cinema=AudioStreamPlayer.new()
	add_child(cinema)
	get_viewport().size_changed.connect(update_viewport_layout)
	update_viewport_layout()
	apply_settings()
	if not startup_prepared:snd.set_music("Music_MenuMusic")
	if startup_check:
		pass
	elif release365_check:
		call_deferred("run_release365_checks")
	elif release364_check:
		call_deferred("run_release364_checks")
	elif release363_check:
		call_deferred("run_release363_checks")
	elif release36_check:
		call_deferred("run_release36_checks")
	elif release35_check:
		call_deferred("run_release35_checks")
	elif release34_check:
		call_deferred("run_release34_checks")
	elif release33_check:
		call_deferred("run_release33_checks")
	elif release32_check:
		call_deferred("run_release32_checks")
	elif release31_check:
		call_deferred("run_release31_checks")
	elif release30_check:
		call_deferred("run_release30_checks")
	elif release29_check:
		call_deferred("run_release29_checks")
	elif release28_check:
		call_deferred("run_release28_checks")
	elif release27_check:
		call_deferred("run_release27_checks")
	elif release26_check:
		call_deferred("run_release26_checks")
	elif release25_check:
		call_deferred("run_release25_checks")
	elif release24_check:
		call_deferred("run_release24_checks")
	elif release23_check:
		call_deferred("run_release23_checks")
	elif release23_visual:
		call_deferred("capture_release23")
	elif release22_check:
		call_deferred("run_release22_checks")
	elif release22_visual:
		call_deferred("capture_release22")
	elif release21_check:
		call_deferred("run_release21_checks")
	elif release21_visual:
		call_deferred("capture_release21")
	elif release20_check:
		call_deferred("run_release20_checks")
	elif release20_visual:
		call_deferred("capture_release20")
	elif death_dialogue_check:
		call_deferred("run_death_dialogue_checks")
	elif results_menu_check:
		call_deferred("run_results_menu_checks")
	elif pause_menu_check:
		call_deferred("run_pause_menu_checks")
	elif mix_check:
		call_deferred("run_mix_checks")
	elif frontend_check:
		call_deferred("run_frontend_checks")
	elif ui_audio_check:
		call_deferred("run_ui_audio_checks")
	elif parity_check:
		call_deferred("run_parity_checks")
	elif test_mode:
		call_deferred("run_tests")
	elif cinema_check:
		call_deferred("validate_cinematics")
	elif preview_mode:
		progress.upgrades=[1,1,1,1,0,0,0,0]
		start_run()
		speed=70
		entities.clear()
		spawn_entity("male",-1,30)
		spawn_entity("cars",4.3,22)
		spawn_entity("female",2.6,65)
		spawn_entity("cars",-4.5,95)
		next_pattern=500
		if benchmark_mode:
			next_pattern=60;segment=8;segment_start=0
			air_delay=5;helicopter_delay=5;jet_delay=8;speed=100
			benchmark_start=Time.get_ticks_msec()
			if "--benchmark-hood" in OS.get_cmdline_user_args():hood={"kind":"hard","hp":500.0,"attack":0.0,"grip":0.0};hood_time=2
	queue_redraw()

func apply_settings():
	Engine.max_fps=int(progress.settings.fps)
	snd.enabled=bool(progress.settings.sound)
	if not snd.enabled:
		snd.clear_voice()
		snd.update_menu_ambience(0,false)
		snd.ui_effect.stop()
		for player in snd.effects:player.stop()
		for player in snd.action_loops.values():player.stop()
		snd.stop_world_audio()
	snd.music_enabled=bool(progress.settings.music)
	AudioServer.set_bus_volume_db(0,linear_to_db(float(progress.settings.volume)))
	if not test_mode and not preview_mode:
		apply_window_mode()
	if not snd.music_enabled:snd.music.stop()
	elif snd.music.stream and snd.music_looped and not snd.music.playing:snd.music.play()

func apply_window_mode():
	# Audio and other options must preserve a maximized window.
	var current=DisplayServer.window_get_mode()
	var is_fullscreen=current in [DisplayServer.WINDOW_MODE_FULLSCREEN,DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	if bool(progress.settings.fullscreen) and not is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif not bool(progress.settings.fullscreen) and is_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _notification(what):
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and snd!=null:
		stop_horn();wiper_pressed=false;achievement_scroll_direction=0
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and state=="play" and not preview_mode:
		set_pause()

func _process(dt):
	art.pump_textures()
	art.pump_driving_prepare()
	if drive_requested:
		if state!="garage":drive_requested=false
		elif art.prepared_driving:drive_requested=false;start_run()
		elif not art.driving_loading:
			drive_requested=false;ui_message="Could not load highway assets.";ui_message_time=5;snd.play("ErrorSound")
	var delta=minf(dt,0.05)
	total_time+=delta
	if state=="play":
		update_original_tutorial(delta);update_original_abort(delta)
	if state=="play" or death_menu_active():update_checkpoint_message(delta)
	if death_menu_active():
		update_death_menu(dt)
		update_death_world(delta)
	if state=="menu":menu_time+=delta
	if state=="achievements":update_achievements_menu364(delta)
	update_achievement_messages364(delta)
	snd.update_menu_ambience(delta,state in ["menu","achievements"] or (state in ["options","controls"] and previous_state=="menu"))
	if state=="cinematic":
		cinema.volume_db=(-8+linear_to_db(clampf(cinema_time/0.04,0.001,1))) if progress.settings.sound and not preview_mode else -80
		cinema_overlay.queue_redraw()
		cinema_time+=dt
		if cinema.playing and not preview_mode:cinema_time=maxf(0,cinema.get_playback_position()+AudioServer.get_time_since_last_mix()-AudioServer.get_output_latency())
		cinema_canvas.frame=mini(int(cinema_time*30),native_scenes.count(cinema_name)-1);cinema_canvas.queue_redraw()
		if cinema_time>=float(native_scenes.count(cinema_name))/30.0:finish_cinematic()
	if fidelity_suite and not screenshot_pending:
		screenshot_pending=true
		call_deferred("capture_fidelity")
	ui_message_time=maxf(0,ui_message_time-delta)
	if state=="options" or state=="controls": panel_anim=minf(0.4,panel_anim+delta)
	if state=="garage":
		garage_body_time+=dt
		if not drive_requested and not snd.dialogue_busy(): garage_chatter_timer+=delta
		if not drive_requested and garage_chatter_timer>garage_chatter_delay:
			snd.speak("GarageChatter%02d"%rng.randi_range(1,20),false,"",-18)
			garage_chatter_timer=0;garage_chatter_delay=rng.randf_range(8,16)
		garage_upgrade_time=maxf(0,garage_upgrade_time-delta)
		if garage_upgrade_time<=0: garage_upgrade_anim=-1
		if snd.voice.playing and snd.voice_key.begins_with("Player"):
			if garage_head_anim!="talk": garage_head_anim="talk";garage_head_time=0
			garage_head_time+=delta
		else:
			if garage_head_anim=="talk": garage_head_anim="idle";garage_head_time=0;garage_blink_timer=0
			if garage_head_anim=="blink":
				garage_head_time+=delta
				if garage_head_time>=7.0/30.0:
					garage_head_anim="idle";garage_head_time=0;garage_blink_timer=0;garage_blink_delay=1.0+rng.randf()*5.0
			else:
				garage_blink_timer+=delta
				if garage_blink_timer>=garage_blink_delay:
					garage_head_anim="blink";garage_head_time=0
		# Ambient radio waits until all foreground dialogue has finished.
	if state=="play" and not test_mode and not screenshot_pending:
		var a=1.0 if preview_mode or held(2) or Input.is_physical_key_pressed(KEY_UP) else 0.0
		var b=held(3) or Input.is_physical_key_pressed(KEY_DOWN)
		var hand=held(4)
		var steer=float(held(1) or Input.is_physical_key_pressed(KEY_RIGHT))-float(held(0) or Input.is_physical_key_pressed(KEY_LEFT))
		if benchmark_mode:
			steer=sin(total_time*0.8)*0.7;car_hp=100;health=100;speed=100;fire_started=false
		simulate(delta,a,b,hand,steer)
		if preview_mode:
			preview_frames+=1
			if preview_frames==90 and not visual_suite and not benchmark_mode:
				screenshot_pending=true
				call_deferred("capture_preview")
	if visual_suite and not screenshot_pending:
		if state!="play":preview_frames+=1
		if preview_frames in [60,120,180,240,300,360]:
			screenshot_pending=true
			call_deferred("capture_suite")
	if benchmark_mode:
		var seconds=float(Time.get_ticks_msec()-benchmark_start)/1000
		if seconds>3:fps_samples.append(dt)
		if seconds>20:finish_benchmark()
	update_car_audio()
	queue_redraw()

func capture_preview():
	await RenderingServer.frame_post_draw
	var im=get_viewport().get_texture().get_image()
	var path=ProjectSettings.globalize_path("res://../analysis/native_gameplay.png")
	im.save_png(path)
	print("RENDER_CHECK: ",path," renderer=",RenderingServer.get_video_adapter_name()," fps=",Engine.get_frames_per_second())
	get_tree().quit()

func capture_suite():
	await RenderingServer.frame_post_draw
	var names={60:"gameplay",120:"garage",180:"menu",240:"controls",300:"hood_combat",360:"pause"}
	var path=ProjectSettings.globalize_path("res://../analysis/check_"+names[preview_frames]+".png")
	get_viewport().get_texture().get_image().save_png(path)
	print("VISUAL_CHECK: ",names[preview_frames]," FPS=",Engine.get_frames_per_second())
	match preview_frames:
		60:state="garage"
		120:state="menu"
		180:previous_state="menu";state="controls"
		240:
			start_run();speed=42;glass_hp=46
			hood={"kind":"male","hp":50.0,"attack":0.0,"grip":0.0}
			hood_time=2.0
		300:set_pause()
		360:get_tree().quit()
	preview_frames+=1
	screenshot_pending=false

func finish_benchmark():
	benchmark_mode=false
	var sum=0.0
	for dt in fps_samples:sum+=dt
	fps_samples.sort()
	var report={"average_fps":float(fps_samples.size())/sum,"p95_frame_ms":fps_samples[int(fps_samples.size()*0.95)]*1000,"p99_frame_ms":fps_samples[int(fps_samples.size()*0.99)]*1000,"frames":fps_samples.size(),"warmup_seconds":3,"total_seconds":20,"gpu":RenderingServer.get_video_adapter_name(),"entities":entities.size(),"renderer":"GL Compatibility","window":"1280x720","limit":Engine.max_fps}
	print("BENCHMARK: ",JSON.stringify(report))
	var file=FileAccess.open("user://last_benchmark.json",FileAccess.WRITE)
	if file:file.store_string(JSON.stringify(report,"\t"))
	get_tree().quit()

var horn_pressed=false
var wiper_pressed=false

func _input(event):
	if state=="achievements" and event is InputEventMouse:
		achievement_pointer=event.position-UI_OFFSET
		if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and not event.pressed:achievement_scroll_direction=0
	if event is InputEventKey and not event.pressed:
		if event.physical_keycode==int(progress.settings.keys[5]):stop_horn()
		if event.physical_keycode==int(progress.settings.keys[6]):wiper_pressed=false
	if event is InputEventKey and event.pressed and not event.echo:
		var key=event.physical_keycode
		if abort_confirm:
			if key==KEY_ESCAPE:abort_choice(false)
			return
		# The source tutorial overlays driving; it consumes only its Space dismiss key.
		# Movement, horn and wipers must remain usable while a tutorial is visible.
		if state=="play" and original_tutorial_active() and key==KEY_SPACE:
			dismiss_original_tutorial();return
		if state=="results" and key in [KEY_ENTER,KEY_SPACE]:
			if results_ready():enter_garage()
			return
		if not pending_mode.is_empty():
			if key==KEY_ESCAPE:pending_mode="";queue_redraw()
			elif key==KEY_ENTER:confirm_mode("resume" if campaign_checkpoint(pending_mode)>0 else "new") if pending_mode in ["story","hardcore"] else confirm_mode("yes")
			return
		if delete_confirm and key!=KEY_F11:
			if key==KEY_ESCAPE:delete_confirm=false;queue_redraw()
			return
		if rebind_index>=0:
			if key!=KEY_ESCAPE and key!=KEY_F11:
				var previous=int(progress.settings.keys[rebind_index])
				var conflict=progress.settings.keys.find(key)
				if conflict>=0:progress.settings.keys[conflict]=previous
				progress.settings.keys[rebind_index]=key;progress.save()
			rebind_index=-1;return
		if state=="cinematic" and key in [KEY_ESCAPE,KEY_ENTER,KEY_SPACE]:
			finish_cinematic();return
		if key==KEY_F11:
			progress.settings.fullscreen=not progress.settings.fullscreen
			apply_settings();progress.save()
		elif key==KEY_ESCAPE:
			if state=="play":set_pause()
			elif state=="paused":resume_run()
			elif state=="achievements":activate("achievements_close")
			elif state=="options" or state=="controls":state=previous_state
			elif state=="garage" or state=="results":open_menu()
		elif state=="play":
			if key==int(progress.settings.keys[5]):horn()
			elif key==int(progress.settings.keys[6]):wiper_pressed=true;wipe()
			elif key==int(progress.settings.keys[7]):attack()
			elif key==int(progress.settings.keys[8]):
				progress.settings.quality=(int(progress.settings.quality)+1)%3;progress.save();say("QUALITY: "+["LOW","MEDIUM","HIGH"][int(progress.settings.quality)])
			elif key==int(progress.settings.keys[9]):perception=not perception
		elif key==KEY_ENTER:
			if state=="menu":activate("story")
			elif state=="garage":request_drive()
			elif state=="results":enter_garage()
			elif state=="paused":resume_run()
	if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
		if abort_confirm:
			for b in buttons:
				if b.rect.has_point(event.position-UI_OFFSET):activate(b.id);return
			return
		if state=="play":
			if abort_button_rect().has_point(event.position-UI_OFFSET):
				set_pause();abort_confirm=true;queue_redraw()
			elif not original_tutorial_active():attack()
			return
		var p=event.position-UI_OFFSET
		for b in buttons:
			if b.rect.has_point(p):
				activate(b.id)
				get_viewport().set_input_as_handled()
				return

func held(index: int) -> bool:
	if original_tutorial_active() and int(progress.settings.keys[index])==KEY_SPACE:return false
	return Input.is_physical_key_pressed(int(progress.settings.keys[index]))

func activate(id):
	if state=="achievements" and id not in ["achievements_close","achievements_up","achievements_down","fullscreen"]:return
	if abort_confirm:
		if id=="abort_yes":abort_choice(true)
		elif id=="abort_no":abort_choice(false)
		return
	if death_menu_active() and not results_ready() and id in ["retry","menu"]:return
	if id=="cinema_skip":
		finish_cinematic();return
	if id.begins_with("confirm_"):
		confirm_mode(id.trim_prefix("confirm_"));return
	if not pending_mode.is_empty():return
	if drive_requested and id!="menu":return
	if delete_confirm and id not in ["delete_yes","delete_cancel"]:return
	if id=="delete_yes" and not delete_confirm:return
	if id.begins_with("rebind_") or id in ["music","music_on","music_off","sound_on","quality_low","quality_medium","quality_high","buildings_on","buildings_off","delete_save","delete_cancel"]:
		snd.play("UpgradePerception",-8)
	if id.begins_with("rebind_"):
		rebind_index=int(id.trim_prefix("rebind_"));return
	if id.begins_with("buy_"):
		buy_upgrade(int(id.trim_prefix("buy_")));return
	match id:
		"achievements":
			if state!="menu":return
			state="achievements";panel_anim=0;achievement_scroll=0;achievement_scroll_direction=0;achievement_pointer=get_global_mouse_position()-UI_OFFSET;snd.play("UpgradePerception",-8)
		"achievements_close":
			if state=="achievements":state="menu";achievement_scroll_direction=0;snd.play("UpgradePerception",-8)
		"achievements_up":achievement_scroll_direction=-1
		"achievements_down":achievement_scroll_direction=1
		"story","time","police","hardcore":
			if id=="hardcore" and not progress.finished:
				ui_message="Escape the city to unlock Hardcore.";ui_message_time=3;snd.play("ErrorSound");return
			pending_mode=id
			snd.play("UpgradePerception",-8)
			queue_redraw()
		"drive": request_drive()
		"retry": enter_garage()
		"menu": open_menu()
		"resume": resume_run()
		"retire": finish_run("You ended this run.")
		"quit": progress.save();get_tree().quit()
		"options","controls": previous_state=state;state="options";panel_anim=0;snd.play("UpgradePerception",-8)
		"back","options_close": state=previous_state;panel_anim=0;rebind_index=-1;delete_confirm=false;snd.play("UpgradePerception",-8)
		"music","music_on","music_off": progress.settings.music=(id!="music_off") if id!="music" else not progress.settings.music;apply_settings();progress.save()
		"sound","sound_on","sound_off": progress.settings.sound=(id!="sound_off") if id!="sound" else not progress.settings.sound;apply_settings();progress.save()
		"quality_low": progress.settings.quality=0;progress.save()
		"quality_medium": progress.settings.quality=1;progress.save()
		"quality_high": progress.settings.quality=2;progress.save()
		"buildings_on": progress.settings.buildings=true;progress.save()
		"buildings_off": progress.settings.buildings=false;progress.save()
		"delete_save":rebind_index=-1;delete_confirm=true
		"delete_cancel":delete_confirm=false
		"delete_yes":
			progress.rp=0;progress.checkpoint=0;progress.hardcore_checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0];progress.best=0;progress.finished=false;progress.settings.intro_seen=false;progress.settings.tutorial_index=0;progress.settings.tutorial_seen=[];progress.settings.tutorial_encounters=[];progress.reset_achievements();achievement_system.pending.clear();achievement_messages.clear();achievement_message.clear();progress.save();delete_confirm=false;ui_message="SAVE DATA DELETED";ui_message_time=2
		"replay_intro":start_cinematic("intro","menu")
		"fullscreen":progress.settings.fullscreen=not progress.settings.fullscreen;apply_settings();progress.save()
		"shake":progress.settings.shake=not progress.settings.shake;progress.save()
		"fps":
			var limits=[30,60,120]
			progress.settings.fps=limits[(limits.find(int(progress.settings.fps))+1)%3]
			apply_settings();progress.save()
		"vol_down": progress.settings.volume=maxf(0,progress.settings.volume-0.1);apply_settings();progress.save()
		"vol_up": progress.settings.volume=minf(1,progress.settings.volume+0.1);apply_settings();progress.save()

func buy_upgrade(i: int) -> bool:
	selected_upgrade=i
	var level=int(progress.upgrades[i])
	if level>=3:
		snd.play("ErrorSound");return false
	var cost=int(COSTS[i][level])
	if progress.rp<cost:
		snd.play("ErrorSound");return false
	progress.rp-=cost;progress.upgrades[i]=level+1
	achievement_system.check_upgrades(progress);flush_achievements364()
	progress.save()
	var voices=["Perception","BodyArmor","Firearm","Windshield","Engine","Bumper","Tires","Horn"]
	var buy_sfx=[
		"UpgradePerception",
		"UpgradeBodyArmor",
		"UpgradeFirearm" if level==0 else "UpgradeFirearmBullet",
		"UpgradeWindshield",
		"UpgradeEngine"+str(level+1),
		"UpgradeBumper"+str(level+1),
		"UpgradeTire",
		"UpgradeHorn"+str(level+1)
	]
	snd.play(buy_sfx[i],-2)
	snd.upgrade_voice("PlayerUpgrade"+voices[i]+str(level+1))
	garage_upgrade_anim=i;garage_upgrade_time=8.0/30.0 if i==3 else 0.8
	return true

func open_menu():
	stop_horn();wiper_pressed=false
	pending_death_cause="";fatal_cause="";death_screen_clip="";death_point_rows.clear();death_explosion=false;crash_texture=null;crash_page=-1
	clear_original_tutorial();abort_confirm=false
	state="menu";pending_mode="";menu_time=0;snd.stop_action();snd.pause_all(false);snd.set_music("Music_MenuMusic")

func set_pause():
	stop_horn();wiper_pressed=false
	state="paused";snd.pause_all(true)

func resume_run():
	state="play";snd.pause_all(false)

func segment_position(i: int) -> float:
	var z=0.0
	for n in range(i):z+=LENGTHS[n]
	return z

func request_drive():
	if state!="garage" or drive_requested:return
	snd.stop_action();stop_horn();subtitle_time=0;garage_head_anim="idle"
	garage_chatter_timer=0;drive_requested=true
	art.begin_driving_prepare()
	if art.prepared_driving:drive_requested=false;start_run()
	queue_redraw()

func start_run():
	bullet_flesh365=0;bullet_hit_bag365.clear();last_bullet_sound365=""
	snd.stop_action()
	achievement_system.reset_run()
	art.prepare_driving()
	drive_requested=false;car35.reset(int(progress.upgrades[4]));desired_lateral=0;collision_bump_strength=0;collision_bump_speed=0;side_damage=[0.0,0.0];side_window_time=[0.0,0.0];side_mirror_time=[0.0,0.0];car_smoking=false
	clear_original_tutorial();abort_confirm=false;abort_y=-90.0;abort_target_y=-90.0;abort_from_y=-90.0;abort_clock=0.4
	fatal_cause="";pending_death_cause="";death_screen_clip="";death_screen_time=0;death_point_rows.clear();death_explosion=false;crash_texture=null;crash_page=-1
	hood_shot_kills=0;hood_shaken_kills=0
	state="play";elapsed=0;speed=0;player_x=0;lateral=0;steering=0;wall_contact=0;wall_sound_time=0
	car_hp=100;health=100;glass_hp=100;tires=0;tire_damage=0.0;tire_bias_timer=0.0;tire_bias_duration=0.0;tire_bias_strength=0.0;tire_bias_target=0.0;oil_time=0;oil_duration=0;oil_factor=0;fire_time=0;fire_started=false;coolant_time=0;handbrake_time=0;shot_count=0
	armor_level=int(progress.upgrades[5]);armor_break_level=0;armor_break_time=0;cooled=false;glass_break_time=0;attack_elapsed=0;attack_resolved=false
	gear=0;shift_time=0;gear_arm_frame=0;gear_stick_frame=0;dying_hood.clear()
	kills=0;soldier_kills=0;civilians_hit=0;hood_kills=0;precision_hits=0;air_dodges=0;run_rp=0;shots=0
	ammo=int(progress.upgrades[2])*3
	segment=campaign_checkpoint(mode)
	chapter_index=segment/2
	segment_start=segment_position(segment)
	position_z=segment_start;start_z=position_z;next_pattern=position_z+100
	spawn_segment=segment;next_hard_pattern=position_z+500+rng.randf()*100;last_super_spawn=-5;pattern_bags.clear();last_pattern.clear()
	pre_checkpoint_pending=segment<20;post_checkpoint_pending=true
	checkpoint_message.clear();checkpoint_queue.clear();checkpoint_time=0
	entities.clear();scenery.clear();road_signs.clear();effects.clear();blood.clear();impacts.clear();hood.clear();air.clear();helicopter.clear();jet.clear()
	next_road_sign=position_z+50.0
	entity_serial=0
	hood_reacted=false;hood_time=0;attack_time=0;horn_time=0;wipe_time=0;horn_pressed=false;wiper_pressed=false;shake=0;red_flash=0;hit_cooldown=0;body_recovery=0
	time_left=30;nuke_time=120;last_nuke_call=-1;air_delay=30;awarded=false
	reset_air_delays()
	snd.pause_all(false);snd.stop_action();snd.begin_gameplay_dialogue();snd.set_music("Music_GameMusic")
	for i in range(16):
		scenery.append({"x":(-12.1 if i%2==0 else 12.1),"z":position_z+16+i*17.0,"frame":rng.randi_range(0,art.count("buildings")-1),"height":rng.randf_range(15,22)})
	notice_time=0;subtitle_time=0
	if mode in ["story","hardcore"]:
		helicopter_delay=40+rng.randf()*10
		show_checkpoint_message("",CHAPTERS[chapter_index])
		for i in range(5):spawn_entity(["shopping_cart","cone","barrel","box","construction_sign","water"][rng.randi_range(0,5)],rng.randf_range(-7,7),position_z+float(i+1)*100.0/6.0)
	else:say("W / S  DRIVE & BRAKE     A / D  STEER",5)
	if mode=="time":say("DEAD ON TIME  —  Hits add time. Keep moving!",5)
	if mode=="police":say("POLICE STATE  —  Survive the military blockade.",5)
	if not test_mode and not preview_mode:setup_original_tutorials()

func simulate(dt: float, throttle: float, brake: bool, handbrake: bool, axis: float):
	if state!="play":return
	elapsed+=dt
	if armor_break_level>0:
		armor_break_time+=dt
		if armor_break_time*30>=art.anim_count("armor_break_"+str(armor_break_level)):armor_break_level=0
	update_action_animation(dt)
	if glass_hp<=0:glass_break_time+=dt
	if not dying_hood.is_empty():
		dying_hood.time+=dt
		if dying_hood.time>=hood_state_duration(dying_hood):dying_hood.clear()
	notice_time=maxf(0,notice_time-dt);subtitle_time=maxf(0,subtitle_time-dt)
	horn_time=1.0 if horn_pressed else 0.0
	update_wipers(dt)
	red_flash=maxf(0,red_flash-dt);shake=move_toward(shake,0,dt*13)
	if oil_time>0:
		oil_time=maxf(0,oil_time-dt)
		oil_factor=1.0-pow(1.0-oil_time/maxf(0.001,oil_duration),2.0)
	else:oil_factor=0.0
	hit_cooldown=maxf(0,hit_cooldown-dt);body_recovery=maxf(0,body_recovery-dt);coolant_time=maxf(0,coolant_time-dt)
	brake_held=brake or handbrake
	var eng=int(progress.upgrades[4]);var tire_level=int(progress.upgrades[6])
	var max_speed=float(car35.MAX_SPEEDS[eng])
	if car35.level!=eng:car35.reset(eng)
	if not is_equal_approx(speed,car35.speed):car35.seek_speed(speed)
	car35.update(dt,throttle,brake,handbrake,gear>0 or speed>0)
	speed=car35.speed
	handbrake_time=handbrake_time+dt if handbrake else 0.0
	if attack_time>0:axis=0 # Source left hand leaves the wheel during a punch/shot.
	var side_max=float([8,10.66,13.33,16][tire_level] if handbrake else [4,5.33,6.66,8][tire_level])
	var turn_accel=float([30,43.33,56.66,70][tire_level] if handbrake else [15,26.66,38.33,50][tire_level])
	var ratio=1.0-pow(1.0-minf(speed/(max_speed*0.75),1.0),3)
	var blown_control=1.0 if tires<=0 else float([0.9,0.8,0.7,0.6][clampi(tires-1,0,3)])
	var oil_control=1.0
	if oil_factor>0:
		var source_oil_control=float([0.25,0.30,0.35,0.40][tire_level])
		oil_control=oil_factor*source_oil_control+(1.0-oil_factor)
	desired_lateral=move_toward(desired_lateral,axis*side_max*ratio,dt*turn_accel)
	turn_accel*=blown_control*oil_control
	lateral=move_toward(lateral,axis*side_max*ratio,dt*turn_accel) if speed>0 else 0.0
	if tires>0:
		tire_bias_timer+=dt
		if tire_bias_timer>=tire_bias_duration:
			tire_bias_timer=0.0
			var bi=clampi(tires-1,0,3)
			tire_bias_duration=float([1.0,0.8,0.6,0.4][bi])+rng.randf()*float([4.0,3.5,3.0,2.5][bi])
			var mag=float([1.0,1.5,2.0,2.5][bi])+rng.randf()*float([1.0,2.0,3.0,4.0][bi])
			tire_bias_target=mag*(-1.0 if tire_bias_target>0 else 1.0)
		tire_bias_strength=lerpf(tire_bias_strength,tire_bias_target,1.0-exp(-dt))
	else:
		tire_bias_strength=lerpf(tire_bias_strength,0.0,1.0-exp(-dt))
	var effective_lateral=lateral+(tire_bias_strength if speed>0 else 0.0)
	effective_lateral=collision_bump_strength*collision_bump_speed+(1.0-collision_bump_strength)*effective_lateral
	collision_bump_strength=maxf(0.0,collision_bump_strength-4.0*dt)
	player_x+=effective_lateral*dt
	steering=desired_lateral/float([8,10.66,13.33,16][tire_level])
	if tires>0 and speed>0:
		var scrape_ratio=clampf(speed/maxf(1.0,max_speed),0.0,1.0)
		var max_vol=0.7+float(tires-1)*0.1
		snd.set_action_loop("tire_scrape","TireBlownScraping",true,linear_to_db(maxf(0.001,scrape_ratio*max_vol)))
		shake=maxf(shake,scrape_ratio*(0.35+float(tires-1)*0.15))
	else:snd.set_action_loop("tire_scrape","TireBlownScraping",false)
	var was_contact=wall_contact
	player_x=clampf(player_x,-9.4,9.1)
	wall_contact=-1 if player_x<=-9.4 and effective_lateral<0 and speed>0 else (1 if player_x>=9.1 and effective_lateral>0 and speed>0 else 0)
	if wall_contact!=0:
		if was_contact!=wall_contact:
			var hit_ratio=absf(effective_lateral)/float([8,10.66,13.33,16][tire_level])
			var bag="RDPlayer.m_HardCollisionSounds" if hit_ratio>=1 else ("RDPlayer.m_MediumCollisionSounds" if hit_ratio>.5 else "RDPlayer.m_LightCollisionSounds")
			source_sound_bag(bag,-10)
			if hit_ratio>.8:hood_collision(20,wall_contact>0,true)
			snd.set_action_loop("side_scrape","SideScraping",true,-16)
		var index=0 if wall_contact<0 else 1
		damage_car_side(index,20.0*dt)
		shake=maxf(shake,.35)
	else:snd.set_action_loop("side_scrape","SideScraping",false)
	for i in range(2):
		if side_damage[i]>=100:side_window_time[i]+=dt
		if side_damage[i]>90:side_mirror_time[i]+=dt
	position_z+=speed/3.6*dt
	if health>0:health=minf(100,health+dt*float([1.0,1.5,2.0,2.5][int(progress.upgrades[1])]))
	# Original Flash behavior: an unarmored, critically damaged bumper/engine burns.
	# Braking does not extinguish it; a water jug does.
	if armor_level==0 and car_hp<20 and not fire_started and not cooled:
		fire_started=true
		record_tutorial_encounter("Water Jugs")
		source_player_voice("RDPlayer.m_CarOnFireVoices",1.0,2,-7)
	update_gears(dt,throttle)
	update_car_audio()
	if mode in ["story","hardcore"]:
		while next_pattern<=position_z-camera_back_offset()+200:spawn_source_pattern()
	elif next_pattern<position_z+240:spawn_pattern()
	for b in scenery:
		if b.z<position_z-6:
			b.z+=272;b.frame=rng.randi_range(0,art.count("buildings")-1)
	snd.begin_world_frame(player_x,position_z)
	update_road_signs(dt)
	update_entities(dt)
	update_hood(dt,handbrake)
	update_air(dt)
	snd.flush_world_frame(dt)
	if health>0 and car_hp>0:
		achievement_system.update_distance(progress,mode,position_z,car35.state==car35.MAX_SPEED,tires==4,time_left);flush_achievements364()
	update_progression()
	update_world_effects(dt)
	blood=blood.filter(func(b):return b.life>0)
	
	if mode=="time":
		time_left-=dt
		if time_left<=0:finish_run("Time ran out.");return
	if segment>=20 and (mode=="story" or mode=="hardcore") and not original_tutorial_active():
		nuke_time-=dt
		if nuke_time<=0:finish_run("The nuclear strike reached the city.",false,"Nuke");return
		update_nuke_dialogue()
	if health<=0:finish_run("John did not survive.",false,fatal_cause);return
	if car_hp<=0:finish_run("The car was destroyed.",false,fatal_cause);return

func spawn_entity(kind: String,x: float,z: float) -> Dictionary:
	entity_serial+=1
	var height=1.8;var radius=0.36
	if kind=="cars":height=1.4;radius=1.15
	elif kind=="super":height=2.35;radius=0.58
	elif kind=="hard":height=2.1;radius=0.44
	elif kind=="water":height=0.9;radius=0.6
	elif kind=="cone":height=0.65;radius=0.35
	elif kind=="barrel":height=0.9;radius=0.45
	elif kind=="oil":height=0.10;radius=1.1
	elif kind=="spikes":height=0.15;radius=1.4
	elif kind=="box":height=1.3;radius=0.7
	elif kind=="construction_sign":height=1.5;radius=0.7
	elif kind=="electronic_sign":height=2.8;radius=1.3
	elif kind=="fence":height=1.6;radius=1.4
	elif kind=="shopping_cart":height=1.2;radius=0.55
	elif kind=="feeders":height=2.0;radius=1.0
	# Original world-space X bounds, independent of artwork or visual scale.
	radius=float({"fence":2.0,"spikes":2.5,"oil":1.5,"feeders":1.0}.get(kind,0.5)) if kind!="cars" else radius
	var frame=rng.randi_range(0,20 if kind=="cars" else maxi(0,art.count(kind)-1))
	if kind in ["male","female","hard","super","civilian","soldier","feeders","water","cone","barrel","box","construction_sign","electronic_sign","fence","shopping_cart","oil","spikes"]:frame=0
	var e={"kind":kind,"x":x,"z":z,"height":height,"radius":radius,"frame":frame,"phase":rng.randf()*4,"dead":false,"hit":false,"age":0.0,"aim":0.0,"aim_x":0.0,"fired":false,"moving":true,"patrol":rng.randf_range(-0.6,0.6),"serial":entity_serial}
	e["direction"]=1 if rng.randf()>0.5 else -1
	e["direction_time"]=rng.randf_range(2,4)
	e["flee"]=false;e["origin_x"]=x;e["patrol_wait"]=0.0;e["behavior"]="patrol";e["anim"]="";e["anim_time"]=0.0
	e["variant"]=["Male1","Male2","Male3","Male5","Female1","Female3","Female4"][rng.randi_range(0,6)]
	e["fire_timer"]=0.0;e["shots"]=0;e["last_z"]=z-position_z
	if kind=="feeders":e.anim="feeders_idle26"
	if kind=="super":record_tutorial_encounter("Mutated Zombies")
	art.prefetch_actor(kind,String(e.variant),frame)
	entities.append(e)
	return e

func spawn_pattern():
	if mode in ["story","hardcore"]:spawn_source_pattern();return
	var use_military=segment%2==1 or mode=="police"
	var candidates=[]
	for p in patterns:
		if use_military:
			if "checkpoint" in p.name:candidates.append(p)
		elif not "checkpoint" in p.name and (segment>=4 or "easy" in p.name):candidates.append(p)
	if candidates.is_empty():candidates=patterns
	var p=candidates[rng.randi_range(0,candidates.size()-1)]
	var flip=-1 if rng.randf()<0.5 else 1
	var stretch=1.0+rng.randf()*(0.25+(1.0-clampf(segment/20.0,0.0,1.0))*0.25)
	var pattern_end=next_pattern+float(p.length)*stretch
	for item in p.items:
		var type=String(item.type)
		if type=="Spikes" and source_spike_level()<(2 if mode=="police" else 4):continue
		if type=="SoldierSpikes" and (source_spike_level()<(4 if mode=="police" else 6) or mode=="time" and source_spike_level()>=18):continue
		var kind="cars"
		if "ZombieVeryHard" in type:kind="super" if segment>=12 else "male"
		elif "ZombieHard" in type:kind="hard" if segment>=6 else "female"
		elif "Zombie" in type:kind="male" if rng.randf()<0.5 else "female"
		elif "Soldier" in type:
			if segment<1 and mode!="police":continue
			kind="soldier"
		elif "Civilian" in type:kind="civilian"
		elif "WaterJug" in type:kind="water"
		elif "TrafficCone" in type:kind="cone"
		elif type=="Spikes":kind="spikes"
		elif "Oil" in type:kind="oil"
		elif type=="TrafficBarrel":kind="barrel"
		elif type=="Box":kind="box"
		elif type=="ConstructionSign":kind="construction_sign"
		elif type=="ElectronicSign":kind="electronic_sign"
		elif type=="Fence":kind="fence"
		elif type=="ShoppingCart":kind="shopping_cart"
		elif "Feeders" in type:kind="feeders"

		var x=clampf(float(item.x)*flip,-9,9)
		var e=spawn_entity(kind,x,next_pattern+float(item.z)*stretch)
		e["source_type"]=type
		e.moving="Patrol" in type or kind=="civilian"
		e.behavior="spikes" if "SoldierSpikes" in type else ("bomb" if "SoldierBomb" in type else ("align" if "Align" in type else ("hidden" if "PopOut" in type or "Hidden" in type else ("stationary" if "Stationary" in type else ("straight" if "Straight" in type else "patrol")))))
		if kind=="cars":
			var vehicle_choices:Array=vehicle_catalog.spawn_choices362.get(type,vehicle_catalog.spawn_choices362.AllCar)
			if not vehicle_choices.is_empty():
				var choice:Dictionary=vehicle_choices[rng.randi_range(0,vehicle_choices.size()-1)]
				e.anim="vehicle";e.frame=int(choice.frame);e["ambient_sound"]=String(choice.sound)
			# RDObstacleCar uses one source scale (6) for every vehicle model.
			# Collision width is source MC width * GlobalMCWidthToWorldWidthFactor (0.015).
			var pose=art.world_frame("vehicle",int(e.frame))
			e.height=2.0
			var vehicle_density=maxf(1.0,float(pose.get("density",1.0)))
			e.radius=float(pose.rect[2])/vehicle_density*0.0075
			e["ambient_channel"]="car_"+str(int(e.serial))
			space_vehicle365(e);pattern_end=maxf(pattern_end,float(e.z))
		if kind=="soldier" and e.behavior=="spikes":
			attach_soldier_strip(e)
		if kind=="soldier" and e.behavior=="hidden":e["cover_x"]=e.x
	next_pattern=pattern_end+rng.randf_range(20.0,40.0)


# Keep the original vehicle widths. Only separate rows that leave no route
# for the player's two-metre collision box beside a bus/truck.
func free_lanes365(blockers:Array,margin:float,left:float=-9.4,right:float=9.1) -> Array:
	var lanes:Array=[Vector2(left,right)]
	for b in blockers:
		var lo=float(b.x)-float(b.radius)-margin
		var hi=float(b.x)+float(b.radius)+margin
		var next:Array=[]
		for lane in lanes:
			if hi<=lane.x or lo>=lane.y:next.append(lane);continue
			if lo>lane.x:next.append(Vector2(lane.x,minf(lo,lane.y)))
			if hi<lane.y:next.append(Vector2(maxf(hi,lane.x),lane.y))
		lanes=next
	return lanes

func space_vehicle365(e:Dictionary):
	for attempt in range(entities.size()+1):
		var nearby:Array=[e];var has_long=float(e.radius)>=3.5;var last=float(e.z)
		for other in entities:
			if other.serial==e.serial or other.dead or other.kind!="cars":continue
			if absf(float(other.z)-float(e.z))<12.0:
				nearby.append(other);last=maxf(last,float(other.z));has_long=has_long or float(other.radius)>=3.5
		if not has_long:return
		var lanes=free_lanes365(nearby,1.1)
		if lanes.any(func(lane):return lane.y-lane.x>=0.4):return
		e.z=last+12.1;e.last_z=float(e.z)-position_z

func civilian_blockers365(e:Dictionary,z:float) -> Array:
	var blockers:Array=[]
	for other in entities:
		if other.kind=="cars" and not other.dead and absf(float(other.z)-z)<2.45:blockers.append(other)
	if speed<1.0 and absf(position_z-z)<1.3:blockers.append({"x":player_x,"radius":1.0})
	return blockers

func civilian_clear365(x:float,blockers:Array) -> bool:
	if x< -9.4 or x>9.1:return false
	for b in blockers:
		if absf(float(b.x)-x)<float(b.radius)+0.5:return false
	return true

func move_civilian365(e:Dictionary,dt:float):
	# Sweep both axes, with a persistent side until the obstruction is passed.
	# A pedestrian may wait if boxed in, but never walks into a parked car.
	var steps=maxi(1,ceili(dt/0.025));var step=dt/steps
	for n in range(steps):
		var next_z=float(e.z)-4.1667*step
		var blockers=civilian_blockers365(e,next_z)
		var forward_clear=civilian_clear365(float(e.x),blockers)
		if not forward_clear:
			var lanes=free_lanes365(blockers,0.55)
			var goal=float(e.get("avoid_x365",e.x));var best=INF;var found=false
			if e.has("avoid_x365") and civilian_clear365(goal,blockers):found=true
			else:
				for lane in lanes:
					if lane.y-lane.x<0.1:continue
					var candidate=clampf(float(e.x),lane.x+0.04,lane.y-0.04)
					var distance=absf(candidate-float(e.x))
					if distance<best:goal=candidate;best=distance;found=true
			if found:
				e.avoid_x365=goal;e.direction=1 if goal>float(e.x) else -1
				var nx=move_toward(float(e.x),goal,3.3333*step)
				if civilian_clear365(nx,civilian_blockers365(e,float(e.z))):e.x=nx
				# Resolve a spawn that was already inside a solid collision box.
				elif not civilian_clear365(float(e.x),civilian_blockers365(e,float(e.z))):e.x=goal
		else:
			if e.has("avoid_x365"):
				# Keep this side while alongside the obstacle, rather than flipping
				# back into it as soon as the centre clears its edge.
				if blockers.is_empty():e.erase("avoid_x365");e.direction_time=rng.randf_range(2,4)
			else:
				e.direction_time-=step
				if float(e.direction_time)<=0:e.direction=-int(e.direction);e.direction_time=rng.randf_range(2,4)
				var nx=float(e.x)+float(e.direction)*3.3333*step
				if nx< -9.4 or nx>9.1:e.direction=-int(e.direction)
				elif civilian_clear365(nx,blockers):e.x=nx
		if civilian_clear365(float(e.x),blockers):e.z=next_z
	e.anim="civilian_"+String(e.variant);e["flip"]=int(e.direction)<0

var bullet_flesh365=0
var bullet_hit_bag365:Array=[]
var last_bullet_sound365=""
func take_bullet365(glass_damage:float,body_damage:float,cause:String):
	if awarded:return
	if glass_hp>0:
		if bullet_hit_bag365.is_empty():
			for n in range(1,8):bullet_hit_bag365.append("BulletHit%02d" % n)
		var index=rng.randi_range(0,bullet_hit_bag365.size()-1)
		last_bullet_sound365=bullet_hit_bag365.pop_at(index)
		snd.play(last_bullet_sound365,-9);damage_glass(glass_damage)
	else:
		last_bullet_sound365="BulletHitFlesh%02d" % (bullet_flesh365+1)
		bullet_flesh365=(bullet_flesh365+1)%3
		snd.play(last_bullet_sound365,-9);damage_player(body_damage,cause)

func update_entities(dt):
	for e in entities:
		e.age+=dt;e.anim_time+=dt
		var z=float(e.z)-position_z
		var kind=String(e.kind)
		if e.dead:continue
		if kind=="cars" and e.has("ambient_sound") and not String(e.ambient_sound).is_empty():
			var car_sound=String(e.ambient_sound)
			var car_category="alarm" if car_sound.begins_with("CarAlarm") else "car"
			var audible=state=="play" and not awarded and z<100
			if car_category=="alarm":audible=audible and absf(z)<30.0
			snd.world_loop(String(e.ambient_channel),car_sound,audible,float(e.x),float(e.z),-18,"car",4.0,car_category)
		if kind=="spikes" and e.has("pull_target"):e.x=lerpf(float(e.x),float(e.pull_target),minf(1.0,dt*5.0))
		if kind in ["male","female","hard","super"]:
			if z>0 and z<80 and not bool(e.get("moan_played",false)):
				e.moan_played=true
				var moan_bag="RDZombie.m_MoanNormalFemaleSounds" if kind=="female" else ("RDZombie.m_MoanVeryHardSounds" if kind=="super" else "RDZombie.m_MoanNormalMaleSounds")
				source_world_sound_bag(moan_bag,e,-13)
			if kind!="super":
				update_normal_zombie363(e,z,dt)
			else:
				var detect=20.0 if horn_time<=0 else float([60,70,80,90][int(progress.upgrades[7])])
				var following=z>1 and z<detect
				if kind=="super" and z<80 and z>10:following=true
				if awarded and following:e.behavior="straight";following=false
				var vx=0.0
				if following:
					vx=signf(player_x-e.x)*(2.6 if kind=="super" else 0.8333)
					e.x=move_toward(e.x,player_x,absf(vx)*dt);e.z-=dt*(2.0 if kind=="super" else 1.3889)
				elif e.behavior=="straight":e.z-=1.3889*dt
				elif e.moving:
					if e.patrol_wait>0:e.patrol_wait=maxf(0,e.patrol_wait-dt)
					else:
						vx=float(e.direction)*0.8333;e.x+=vx*dt
						if absf(e.x-e.origin_x)>2 or absf(e.x)>9:
							e.direction=-int(e.direction);e.patrol_wait=2.0
				var moving_z=following or e.behavior=="straight"
				var desired=kind+("_WalkSide" if absf(vx)>0.05 and not following else ("_WalkFront" if moving_z else "_FrontPose"))
				if e.anim!=desired:e.anim=desired;e.anim_time=0
				e["flip"]=vx<0 and not following
		elif kind=="civilian":
			if z>0 and z<80 and not bool(e.get("plea_played",false)):
				e.plea_played=true
				var plea_gender="Female" if String(e.variant).begins_with("Female") else "Male"
				source_world_sound_bag("RDCivilian.m_"+plea_gender+"PleaSounds",e,-12,"voice")
			if horn_time>0 and z<float([20,30,40,50][int(progress.upgrades[7])]) and z>0 and not e.flee:
				e.flee=true;e.direction=1 if e.x>=player_x else -1;e.direction_time=rng.randf_range(2,4)
			move_civilian365(e,dt)
		elif kind=="feeders":
			e.anim="feeders_idle26"
			snd.world_loop("feeders_"+str(int(e.serial)),"FeedersEat",z>0 and z<100,e.x,e.z,-14,"default",4.0)
		elif kind=="soldier":
			update_soldier(e,z,dt)
			snd.world_loop("soldier_"+str(int(e.serial)),"SoldierMachineGunFire",bool(e.get("fired",false)),e.x,e.z,-11,"military",4.0)

		z=float(e.z)-position_z
		# The rendered car is one unit ahead of the normal camera. Test the
		# whole forward crossing, so a fast frame cannot skip an obstacle.
		if z<=1.0 and float(e.last_z)>1.0 and not e.hit and collision_overlap(e) and (kind!="civilian" or speed>=1.0):
			e.hit=true;collide(e)
		if camera_depth(z)< -8 and kind=="super" and not e.hit and not awarded:
			achievement_system.super_dodged(progress);flush_achievements364()
		if camera_depth(z)< -8 and not (kind=="soldier" and e.behavior=="bomb" and e.get("triggered",false) and int(e.get("bomb_index",0))<7):e.dead=true
		e.last_z=z
	entities=entities.filter(func(e):return not e.dead)


func update_normal_zombie363(e:Dictionary,z:float,dt:float):
	# RDZombie.UpdateNormalZombie retains MoveToPlayer/AlignWithPlayer after
	# the horn stops. Recomputing detection each frame restarts the walk on taps.
	var movement=String(e.get("zombie_alert",e.behavior))
	if z<0:
		movement="straight"
	elif movement=="chase":
		if awarded or not hood.is_empty():movement="straight"
	else:
		if z<10:
			movement="chase"
		elif (movement=="straight" or movement=="patrol" and float(e.patrol_wait)>0) and z<20:
			movement="chase"
		elif horn_time>0 and movement!="align":
			var level=int(progress.upgrades[7])
			if z<float([20,25,30,35][level]):movement="chase"
			elif z<float([60,70,80,90][level]):movement="align"
	if movement in ["align","chase"] or z<0 or e.has("zombie_alert"):
		e["zombie_alert"]=movement
	var vx=0.0;var vz=0.0;var aligning=false
	if movement in ["align","chase"]:
		var toward=Vector2(player_x-float(e.x),-z).normalized()
		vz=toward.y*(5.0*1000/60/60)
		if movement=="align":
			aligning=absf(player_x-float(e.x))>0.4
			var next_x=move_toward(float(e.x),player_x,(3.0*1000/60/60)*dt)
			vx=(next_x-float(e.x))/dt if dt>0 else 0.0
			e.x=next_x
		else:
			vx=toward.x*(3.0*1000/60/60);e.x+=vx*dt
		e.z+=vz*dt
	elif movement=="straight":
		vz=-(5.0*1000/60/60);e.z+=vz*dt
	elif movement=="patrol" and e.moving:
		if e.patrol_wait>0:e.patrol_wait=maxf(0,e.patrol_wait-dt)
		else:
			vx=float(e.direction)*(3.0*1000/60/60);e.x+=vx*dt
			if absf(e.x-e.origin_x)>2 or absf(e.x)>9:
				e.direction=-int(e.direction);e.patrol_wait=2.0
	var sideways=absf(vx)>0.00001 and (is_zero_approx(vz) or movement=="align" and aligning)
	var desired=String(e.kind)+("_WalkSide" if sideways else ("_WalkFront" if not is_zero_approx(vz) else "_FrontPose"))
	if e.anim!=desired:e.anim=desired;e.anim_time=0.0
	e["flip"]=vx<0 and (movement=="align" or movement=="patrol")

func soldier_anim(e:Dictionary,key:String):
	var next="soldier_"+key
	if e.anim!=next:e.anim=next;e.anim_time=0.0

func update_soldier(e:Dictionary,z:float,dt:float):
	e.fired=false
	var hidden=e.behavior=="hidden"
	if not e.has("soldier_state"):
		e["soldier_state"]="Hidden" if hidden else ("PullSpikeStripIdle" if e.behavior in ["spikes","bomb"] else "Idle")
		soldier_anim(e,String(e.soldier_state))
	if not e.has("cue_checked") and not awarded:
		e.cue_checked=true
		if rng.randf()<0.25:
			var voice2=bool(soldier_voice2.get(e.behavior,false))
			soldier_voice2[e.behavior]=not voice2;e["soldier_voice2"]=voice2
			var cue={"align":"AlignAndShoot","hidden":"Hidden","spikes":"Spikes","bomb":"Explosives"}.get(e.behavior,"Stationary")
			source_radio_bag("RDSoldier.m_Male"+("2" if voice2 else "1")+cue+"CueSounds")
	var max_speed=float([110,115,120,125][clampi(int(progress.upgrades[4]),0,3)])
	var ratio=clampf(speed/max_speed,0,1)
	if e.behavior in ["spikes","bomb"]:
		e["flip"]=e.x<0
		if e.behavior=="bomb" and not e.has("bomb_positions"):
			var positions:Array=[]
			var first=-7.4 if e.x>0 else 7.1
			for i in range(7):positions.append(first+i*(2 if e.x>0 else -2))
			if rng.randf()<0.5:positions.reverse()
			e.bomb_positions=positions;e.bomb_index=0
		if e.soldier_state=="PullSpikeStripIdle" and not awarded and absf(z)<(60 if e.behavior=="spikes" else 70)*ratio:
			var pull=true
			if e.behavior=="spikes" and e.has("strip"):
				var player_lane=int(floor((player_x+9.4)/5.0))
				var strip_lane=2 if float(e.strip.x)>0 else 0
				pull=rng.randf()<(0.25 if player_lane==strip_lane else 0.75)
			if pull:e.soldier_state="PullSpikeStrip";e.trigger_started=true;e.trigger_time=0.0;soldier_anim(e,"PullSpikeStrip")
		elif e.soldier_state=="PullSpikeStrip":
			e.trigger_time+=dt
			if e.trigger_time>=13.0/30.0 and not e.get("triggered",false):
				e.triggered=true
				if e.behavior=="spikes" and e.has("strip"):
					e.strip["pull_target"]=0.0
					snd.play_world("SpikeSlide",e.strip.x,e.strip.z,-10,"default",4.0)
				else:e.bomb_time=0.0
			if e.behavior=="bomb" and e.get("triggered",false):
				e.bomb_time+=dt
				while int(e.bomb_index)<7 and e.bomb_time>=float(e.bomb_index)*0.3:
					var bx=float(e.bomb_positions[int(e.bomb_index)]);e.bomb_index+=1
					effects.append({"text":"","color":AMBER,"time":0.9,"y":0.0,"blast_x":bx,"blast_z":e.z})
					snd.play_world("Explosion",e.x,e.z,-18,"loud",4.0)
					if not awarded and absf(z)<10 and absf(bx-player_x)<5:damage_car(10,0.0,true,"Military");damage_player(5,"Military");shake=maxf(shake,4)
		return
	if awarded or z<0:
		e.soldier_state="SlideOutIdle" if hidden and bool(e.get("revealed",false)) else ("Hidden" if hidden else "Idle")
		soldier_anim(e,"SlideOut" if e.soldier_state=="SlideOutIdle" else String(e.soldier_state))
		if e.soldier_state=="SlideOutIdle":e.anim_time=11.0/30.0
		return
	match String(e.soldier_state):
		"Hidden":
			if absf(z)<40*ratio:e.revealed=true;e.soldier_state="SlideOut";soldier_anim(e,"SlideOut")
		"SlideOut":
			if e.anim_time>=11.0/30.0:e.soldier_state="SlideFire";soldier_anim(e,"SlideFire")
		"Idle":
			if e.behavior=="align":
				if not e.has("adjust_target") and z<80:e.adjust_target=clampf(player_x+rng.randf()*2,-7.5,7.5)
				if e.has("adjust_target"):
					if is_equal_approx(float(e.x),float(e.adjust_target)):
						e.soldier_state="IdleToFire";soldier_anim(e,"IdleToFire")
					else:
						var target=move_toward(float(e.x),float(e.adjust_target),5.55556*dt)
						var blocked=false
						for other in entities:
							if other.kind=="cars" and not other.dead and absf(other.z-e.z)<2.4 and absf(other.x-target)<other.radius+0.36:blocked=true;break
						if not blocked:e["flip"]=target<e.x;e.x=target
						soldier_anim(e,"Run")
			elif z<40:e.soldier_state="IdleToFire";soldier_anim(e,"IdleToFire")
		"IdleToFire":
			if e.anim_time>=8.0/30.0:e.soldier_state="Fire";soldier_anim(e,"Fire")
		"Fire","SlideFire":
			e.fired=true;e.fire_timer+=dt
			if e.fire_timer>=0.1:
				e.fire_timer=0.0;e.shots+=1;shot_count+=1
				var accurate=absf(player_x-e.x)<2 or bool(e.get("corrected_aim",false)) and not hidden
				if accurate:
					take_bullet365(4.0 if hidden else 2.0,6.0 if hidden else 3.0,"Military")
				else:snd.play_world("BulletMiss%02d" % rng.randi_range(1,8),e.x,e.z,-20)
			if not hidden:
				if e.get("corrected_aim",false):
					if speed>40:e.corrected_aim=false
				elif speed<=20:
					e["aim_correction"]=float(e.get("aim_correction",0))+dt
					if e.aim_correction>=1.0:e.corrected_aim=true

func source_sound_bag(name:String,gain:float=-8.0,voice:bool=false):
	if voice:
		var priority=2 if name in ["RDPlayer.m_BlownTiresVoices","RDPlayer.m_HelicopterReactionVoices","RDPlayer.m_JetReactionVoices"] else (0 if "CollisionGruntVoices" in name else 1)
		source_player_voice(name,1.0,priority,gain);return
	var bag:Array=art.world_data.get("sounds16",{}).get(name,[])
	if bag.is_empty():return
	var key=String(bag[rng.randi_range(0,bag.size()-1)])
	if voice:snd.speak(key,false,"",gain)
	else:snd.play(key,gain)

func source_hit_anim(kind:String,variant:String,relative_x:float) -> Dictionary:
	# RDHumanoid: below 60 km/h is SlowRollOver; 100+ dead-center is Gib.
	var hit_type="RollOverHit"
	var precision=false
	if speed>=60:
		var ax=absf(relative_x)
		if ax<0.1 and speed>=100:
			hit_type="GibHit";precision=true
		elif ax<0.3:
			hit_type="FrontHit" if rng.randf()<0.5 else "RollOverHit"
		elif ax<0.6:
			if rng.randf()<0.4:hit_type="FrontHit" if rng.randf()<0.5 else "RollOverHit"
			else:hit_type="SideHit"
		else:hit_type="SideHit"
	var key=""
	if kind=="civilian":
		key="civilian_GibHit" if hit_type=="GibHit" else "civilian_"+hit_type+variant
	else:
		key=("soldier" if kind=="soldier" else kind)+"_"+hit_type
	return {"key":key,"precision":precision,"type":hit_type,"slow":speed<60.0}

func play_car_collision_audio():
	if speed>=100:
		source_sound_bag("RDPlayer.m_HugeCollisionSounds",-5)
		source_sound_bag("RDPlayer.m_HugeCollisionGruntVoices",-6,true)
	elif speed>=60:
		source_sound_bag("RDPlayer.m_HardCollisionSounds",-6)
		source_sound_bag("RDPlayer.m_HardCollisionGruntVoices",-7,true)
	elif speed>=30:
		source_sound_bag("RDPlayer.m_MediumCollisionSounds",-7)
		source_sound_bag("RDPlayer.m_MediumCollisionGruntVoices",-8,true)
	else:
		source_sound_bag("RDPlayer.m_LightCollisionSounds",-8)

func add_prop_impact(e:Dictionary):
	var frames:Array=art.world_data.get("groups",{}).get(String(e.kind),[])
	if frames.size()>1:
		# RDObstacle.TouchedBy: attach at player Z + .1, clear velocity, play frame 2.
		# Normal camera is one unit behind the player. Artwork owns the flying motion.
		var flipped=bool(e.get("flip",false)) if e.kind=="electronic_sign" else player_x>float(e.x)
		impacts.append({"kind":String(e.kind),"time":0.0,"x":e.x,"height":e.height,"flip":flipped,"start":1,"attached":true,"depth":1.1,"attach_offset_x":float(e.x)-player_x})

func apply_source_speed_loss(loss:float):
	# RDPlayer.HandleSpeedLoss + BumperSpeedLossFactors [1,.85,.7,.55].
	var factor=float([1.0,0.85,0.70,0.55][clampi(int(progress.upgrades[5]),0,3)])
	if not is_equal_approx(speed,car35.speed):car35.seek_speed(speed)
	car35.hit_speed_loss(loss,factor);speed=car35.speed

func collide(e: Dictionary):
	if awarded or e.kind=="civilian" and speed<1.0:return
	var kind=String(e.kind)
	if kind=="oil":
		var tire_level=clampi(int(progress.upgrades[6]),0,3)
		oil_duration=float([4.0,3.5,3.0,2.5][tire_level]);oil_time=oil_duration;oil_factor=1.0
		snd.play("OilSlick",-8);shake=maxf(shake,0.5)
		say("OIL — steer gently");e.dead=true;return
	if kind=="spikes":
		var tire_level=clampi(int(progress.upgrades[6]),0,3)
		shake=maxf(shake,0.5)
		if tires>=4:
			snd.play("TireAlreadyBlown",-9)
		else:
			snd.play("TireBlow",-8)
			tire_damage=minf(4.0,tire_damage+float([4.0,2.0,1.0,0.5][tire_level]))
			tires=int(floor(tire_damage))
			if tires>0:
				var bi=clampi(tires-1,0,3)
				tire_bias_timer=0.0
				tire_bias_duration=float([1.0,0.8,0.6,0.4][bi])+rng.randf()*float([4.0,3.5,3.0,2.5][bi])
				var mag=float([1.0,1.5,2.0,2.5][bi])+rng.randf()*float([1.0,2.0,3.0,4.0][bi])
				tire_bias_target=mag*(1.0 if rng.randf()>0.5 else -1.0)
				if tires==4:source_sound_bag("RDPlayer.m_BlownTiresVoices",-6,true)
		say("TIRES DAMAGED");e.dead=true;return
	if kind=="water":
		var was_burning=fire_started
		var max_speed=float([110,115,120,125][int(progress.upgrades[4])])
		# RDObstacleWaterJug: hit damage 2, then extinguish fire and wash windshield blood.
		damage_car(2.0*clampf(speed/max_speed,0.0,1.0),1.0)
		fire_started=false;fire_time=0;coolant_time=0;cooled=true;blood.clear()
		if was_burning:car_hp=maxf(car_hp,35.0);snd.play("SmokingEngine",-16)
		snd.play("WaterJugCollision");add_prop_impact(e)
		if was_burning:
			achievement_system.unlock(progress,7);flush_achievements364()
			source_player_voice("RDPlayer.m_ExtinguishFireVoices",0.5,1,-7)
		say("WATER — FIRE EXTINGUISHED / WINDSHIELD WASHED" if was_burning else "WINDSHIELD WASHED")
		e.dead=true;return
	if kind in ["box","construction_sign","electronic_sign","fence","shopping_cart"]:
		var cost=float({"box":0.0,"construction_sign":0.5,"electronic_sign":4.0,"fence":1.0,"shopping_cart":0.5}[kind])
		var hit_sound={"box":"TrafficConeHit","construction_sign":"TrafficBarrelHit","electronic_sign":"ElectronicSignHit","fence":"FenceHit","shopping_cart":"ShoppingCartHit"}[kind]
		var max_speed=float([110,115,120,125][int(progress.upgrades[4])])
		damage_car(cost*clampf(speed/max_speed,0.0,1.0),1.0)
		# Source speed loss: only ElectronicSign (.2) and Fence (.1) specify it.
		if kind=="electronic_sign":apply_source_speed_loss(0.20)
		elif kind=="fence":apply_source_speed_loss(0.10)
		snd.play(hit_sound,-15);add_prop_impact(e);e.dead=true
		shake=maxf(shake,0.10 if cost<=0 else (0.45 if cost<=0.5 else 1.4));return
	if kind in ["cone","barrel"]:
		# Original cone/barrel: run-through, no damage and no speed-loss value.
		snd.play("TrafficConeHit" if kind=="cone" else "TrafficBarrelHit",-15);add_prop_impact(e);e.dead=true
		shake=maxf(shake,0.08);return
	if kind=="feeders":
		var max_speed=float([110,115,120,125][int(progress.upgrades[4])])
		damage_car(3.0*clampf(speed/max_speed,0.0,1.0),1.0)
		apply_source_speed_loss(0.75)
		snd.play("FeedersHit",-10);add_prop_impact(e);e.dead=true
		if mode=="time":time_left+=3
		shake=maxf(shake,2.0);return
	if kind=="cars":
		if not bool(e.get("achievement_car_hit",false)):
			e["achievement_car_hit"]=true;achievement_system.car_hit(progress,total_time);flush_achievements364()
		if hit_cooldown>0:return
		var max_speed=float(car35.MAX_SPEEDS[int(progress.upgrades[4])])
		var hit_ratio=clampf(speed/max_speed,0.0,1.0)
		var alignment=clampf((player_x-float(e.x))/maxf(.1,float(e.get("radius",1.15))),-1.0,1.0)
		play_car_collision_audio()
		hood_collision(120.0*hit_ratio,e.x>player_x)
		if glass_hp>0:damage_glass((1.0-alignment)*hit_ratio*7.0)
		damage_car_side(0 if alignment>0 else 1,absf(alignment)*hit_ratio*20.0)
		collision_bump_strength=1.0;collision_bump_speed=-60.0 if e.x>player_x else 60.0
		apply_source_speed_loss(0.30)
		damage_car(20.0*clampf(speed/max_speed,0.0,1.0))
		shake=9;red_flash=0.25;hit_cooldown=0.65
		return
	if kind=="civilian":
		achievement_system.road_hit(progress,"civilian","",total_time);flush_achievements364()
		if mode=="time":time_left=maxf(0,time_left-10)
		civilians_hit+=1;add_blood(e.x-player_x);say("CIVILIAN HIT — RP penalty")
		var variant=String(e.get("variant","Male1"))
		var gender="Female" if variant.begins_with("Female") else "Male"
		var hit=source_hit_anim(kind,variant,float(e.x)-player_x)
		if bool(hit.slow):snd.play("RollOverSound",-12);shake=maxf(shake,0.2)
		source_sound_bag("RDCivilian.m_HitSounds",-9)
		if String(hit.type)!="GibHit":source_sound_bag("RDCivilian.m_"+gender+"GruntSounds",-6)
		source_player_voice("RDPlayer.m_HitCivilianVoices",0.25,1,-7)
		impacts.append({"kind":hit.key,"time":0.0,"x":e.x,"height":e.height,"flip":player_x>float(e.x),"attached":true})
		apply_source_speed_loss(0.25)
		e.dead=true;return
	if kind in ["male","female","hard","super","soldier"]:
		if hood.is_empty() and dying_hood.is_empty() and speed<100 and (speed<48 or kind=="super" or rng.randf()<0.20):
			hood={"kind":kind,"hp":50.0 if kind in ["male","female"] else 100.0,"attack":0.0,"grip":0.0}
			record_tutorial_encounter("Enemies On Hood")
			hood_time=0;hood.anim="Start";hood.anim_time=0.0;hood.wait=0.0;e.dead=true
			say("ON THE HOOD — F to attack. Brake and swerve to throw it off!",5)
			var hood_bag="RDZombie.m_GetOnHoodVeryHardSounds" if kind=="super" else "RDZombie.m_GetOnHoodNormalMaleSounds"
			source_sound_bag(hood_bag,-6)
			hood_reacted=rng.randf()<0.5
			if hood_reacted:hood_reacted=source_player_voice("RDPlayer.m_ReactToHoodEnemyVoices",1.0,1,-7)
			return
		if speed<8:return
		e.dead=true
		var cost=2.0*clampf(speed/float([110,115,120,125][int(progress.upgrades[4])]),0.0,1.0)
		var hit=source_hit_anim(kind,"",float(e.x)-player_x)
		achievement_system.road_hit(progress,kind,"SlowRollOverHit" if bool(hit.slow) else String(hit.type),total_time);flush_achievements364()
		if bool(hit.precision) and kind!="soldier":source_player_voice("RDPlayer.m_PrecisionHitVoices",0.5,1,-7)
		if bool(hit.slow):snd.play("RollOverSound",-12);shake=maxf(shake,0.2)
		impacts.append({"kind":hit.key,"time":0.0,"x":e.x,"height":e.height,"flip":player_x>float(e.x),"attached":true})
		damage_car(cost,20.0);apply_source_speed_loss(0.25);shake=maxf(shake,2.4)
		if kind=="soldier":
			soldier_kills+=1
			source_sound_bag("RDSoldier.m_HitSounds",-9)
			if String(hit.type)!="GibHit":source_sound_bag("RDSoldier.m_Male2GruntSounds" if bool(e.get("soldier_voice2",false)) else "RDSoldier.m_Male1GruntSounds",-7)
		else:
			kills+=1
			source_sound_bag("RDZombie.m_HitSounds",-7)
			if String(hit.type)!="GibHit":
				var grunt="RDZombie.m_GruntNormalFemaleSounds" if kind=="female" else ("RDZombie.m_GruntVeryHardSounds" if kind=="super" else "RDZombie.m_GruntNormalMaleSounds")
				source_sound_bag(grunt,-7)
		if bool(hit.precision):
			precision_hits+=1
		popup("+5 RP",PAPER)
		source_player_voice("RDPlayer.m_HitEnemyVoices",0.25,1,-7)
		add_blood(e.x-player_x)
		if mode=="time" and kind!="soldier":time_left+=3 if achievement_system.zombie_combo>0 else 2

func hood_range(enemy:Dictionary) -> Array:
	var key=String(HOOD_SYMBOLS[enemy.kind])
	return art.anim_data.hood15[key].states.get(enemy.get("anim","Idle"),[1,1])

func hood_state_duration(enemy:Dictionary) -> float:
	if enemy.get("anim","")=="Inside":return 8.0/30.0
	var span=hood_range(enemy)
	return float(int(span[1])-int(span[0])+1)/30.0

func hood_pose() -> Dictionary:
	var enemy=hood if not hood.is_empty() else dying_hood
	if enemy.is_empty():return {}
	var key=String(HOOD_SYMBOLS[enemy.kind])
	var inside=enemy.get("anim","Idle")=="Inside"
	var frame:int
	if inside:
		key+="inside";frame=clampi(1+int(float(enemy.get("anim_time",0))*30),1,8)
	else:
		var span=hood_range(enemy)
		var clock=float(enemy.get("anim_time",0)) if not hood.is_empty() else float(enemy.time)
		frame=clampi(int(span[0])-1+int(clock*30),int(span[0])-1,int(span[1])-1)
	return {"key":key,"frame":frame,"inside":inside}

func hood_state(name:String):
	if hood.is_empty():return
	hood.anim=name;hood.anim_time=0.0
	if name=="Idle":hood.wait=0.0

func hood_collision(damage:float,right:bool,from_wall:bool=true):
	if hood.is_empty():return
	hood.hp=maxf(0,float(hood.hp)-damage)
	if hood.hp<=0:kill_hood(false,true,from_wall)
	else:hood_state("CollideRight" if right else "CollideLeft")

func update_hood(dt,handbrake):
	if hood.is_empty():return
	hood_time+=dt
	if not hood.has("anim"):hood.anim="Idle";hood.anim_time=0.0;hood.wait=0.0
	if handbrake and absf(lateral)>2 and speed>12:hood.grip+=dt*(1+absf(lateral)*0.2)
	else:hood.grip=maxf(0,hood.grip-dt*0.4)
	if hood.grip>2.2:
		kill_hood(false,true);say("THROWN OFF");return
	var kind=String(hood.kind)
	var before=float(hood.anim_time)
	hood.anim_time+=dt
	var action=String(hood.anim)
	if action=="Idle":
		hood.wait=float(hood.get("wait",0))+dt
		if hood.wait>=(2.0 if kind=="soldier" else (2.5 if kind=="super" else 5.0)):
			hood_state("Kill" if glass_hp<=0 and kind!="soldier" else "Attack")
		elif hood.anim_time>=hood_state_duration(hood):hood.anim_time=0.0
		return
	if action=="Attack":
		var key=String(HOOD_SYMBOLS[kind])
		var first=int(hood_range(hood)[0])
		var events:Dictionary=art.anim_data.hood15[key].events
		for source_frame in events:
			var event=String(events[source_frame])
			if event not in ["ClingAnimDoAttack","ClingAnimDoThirdAttack","ClingAnimDrawGun"]:continue
			var event_time=float(int(source_frame)-first)/30.0
			if before<=event_time and float(hood.anim_time)>event_time:
				if event=="ClingAnimDrawGun":hood["gun_out"]=true;continue
				shake=maxf(shake,4)
				if kind=="soldier":
					hood["gun_out"]=false
					snd.play("SoldierPistolFire",-8)
					take_bullet365(25.0,35.0,"Military")
				elif glass_hp>0:
					var attack_bag="RDZombie.m_AttackNormalFemaleSounds" if kind=="female" else ("RDZombie.m_AttackVeryHardSounds" if kind=="super" else "RDZombie.m_AttackNormalMaleSounds")
					source_sound_bag(attack_bag,-8)
					var damage=float(10 if kind in ["male","female"] else (30 if kind=="super" else 15))*(1-progress.upgrades[3]*0.15)
					if kind!="super" and event!="ClingAnimDoThirdAttack":damage=minf(damage,maxf(0,glass_hp-1))
					damage_glass(damage);snd.play("PunchWindshield",-8)
	if hood.anim_time>=hood_state_duration(hood):
		if action=="Kill":hood_state("Inside")
		elif action=="Inside":
			damage_player(1000,"Zombie");hood.clear()
		else:hood_state("Idle")

func horn():
	horn_pressed=true;horn_time=1.0
	snd.set_horn("Horn"+str(int(progress.upgrades[7])+1),true)

func stop_horn():
	horn_pressed=false;horn_time=0.0
	snd.set_horn("",false)

func wipe():
	if wipe_time>0:return
	wipe_time=27.0/30.0

func wiper_frame() -> int:
	return clampi(1+int((27.0/30.0-wipe_time)*30.0),1,27) if wipe_time>0 else 0

func update_wipers(dt:float):
	if wipe_time<=0:
		if wiper_pressed:wipe()
		else:return
	var before=27.0/30.0-wipe_time
	wipe_time=maxf(0, wipe_time-dt)
	var after=27.0/30.0-wipe_time
	# Source frame 5 and 19 clear one authored blood stage each.
	for event in [3.0/30.0,17.0/30.0]:
		if before<event and after>=event:
			for b in blood:
				b.frame+=1
				if b.frame>=art.anim_count("windblood15_blood"+str(b.slot))-1:b.life=0
	for event in [6.0/30.0,20.0/30.0]:
		if before<event and after>=event:snd.play("Wiper01",-12)
	blood=blood.filter(func(b):return b.life>0)
	if wipe_time<=0 and wiper_pressed:wipe()

func hood_can_be_shot() -> bool:
	# RDHumanoid.CanBeShotDown: the finishing clip is already too late.
	return not hood.is_empty() and str(hood.get("anim","Idle")) not in ["GetOff","Shot","Kill","Inside"]

func attack():
	if attack_time>0:return
	# RDPlayer.Attack: a clinger takes priority; there is no melee fallback.
	var use_gun=not hood.is_empty()
	if use_gun:
		if int(progress.upgrades[2])==0 or ammo<=0:
			source_player_voice("RDPlayer.m_NoGunVoices" if int(progress.upgrades[2])==0 else "RDPlayer.m_NoAmmoVoices",1.0,1,-7)
			return
		if not hood_can_be_shot():return
	elif glass_hp<=0:return
	attack_kind="shoot" if use_gun else "punch"
	attack_elapsed=0;attack_resolved=false
	attack_time=41.0/30.0 if use_gun else 42.0/30.0

func update_action_animation(dt: float):
	if attack_time<=0:return
	attack_elapsed+=dt
	attack_time=maxf(0,attack_time-dt)
	var event_time=17.0/30.0 if attack_kind=="shoot" else 16.0/30.0
	if not attack_resolved and attack_elapsed>=event_time:
		attack_resolved=true
		if attack_kind=="shoot":
			ammo=maxi(0,ammo-1);shots+=1;shake=maxf(shake,1.6);snd.play("PistolShot",-4)
			if glass_hp>0:damage_glass(70)
			if hood_can_be_shot():
				hood.hp-=100
				if hood.hp<=0:kill_hood(true)
			if not hood_reacted:source_player_voice("RDPlayer.m_ShootEnemyOnHoodVoices",1.0,1,-7)
			if ammo==0:source_player_voice("RDPlayer.m_OutOfAmmoVoices",1.0,2,-7)
		else:
			if glass_hp>0:
				snd.play("PunchWindshield",-8)
				damage_glass(10+(1-glass_hp/100)*30)

func damage_glass(amount: float):
	if awarded:return
	var was_intact=glass_hp>0
	glass_hp=maxf(0,glass_hp-amount*(2.0 if mode=="hardcore" else 1.0))
	if was_intact and glass_hp<=0:
		glass_break_time=0;blood.clear();snd.play("WindshieldBreak",-4)

func windshield_frame() -> int:
	if glass_hp>=100:return 0
	if glass_hp>80:return 1
	if glass_hp>55:return 2
	if glass_hp>27:return 3
	if glass_hp>0:return 4
	return mini(30,5+int(glass_break_time*30))

func damage_car(amount: float,minimum_hp: float=0.0,absorb: bool=true,cause: String="Crash"):
	if awarded:return
	amount*=2.0 if mode=="hardcore" else 1.0
	if absorb:
		if amount<=float([0,2,5,8][armor_level]):return
		amount*=1.0-float([0.0,0.2,0.4,0.6][armor_level])
	amount=minf(amount,maxf(0,car_hp-minimum_hp))
	if amount<=0:return
	cooled=false;car_hp=maxf(0,car_hp-amount)
	if car_hp<=0 and armor_level>0:
		armor_break_level=armor_level;armor_break_time=0
		armor_level=0;car_hp=100;fire_started=false
		say("BUMPER ARMOR LOST",3);snd.play("HardCollision01",-5)
	elif car_hp<=0 and fatal_cause.is_empty():fatal_cause=cause

func bumper_frame() -> int:
	if armor_level>0:
		return 1+(armor_level-1)*3+(0 if car_hp>=66 else (1 if car_hp>=33 else 2))
	var damage_stage=0
	for threshold in [84,68,52,36,20]:
		if car_hp<float(threshold):damage_stage+=1
	return 10+damage_stage

func update_gears(dt:float,throttle:float=0.0):
	if shift_time>0:
		shift_time=maxf(0,shift_time-dt)
		gear_arm_frame=mini(shift_end,shift_start+int((float(shift_end-shift_start+1)/30.0-shift_time)*30))
		gear_stick_frame=gear_arm_frame
		if shift_time<=0:
			gear=shift_target_gear
			if gear==0:gear_arm_frame=0;gear_stick_frame=0
		return
	if gear==0 and throttle<=0:return
	var target=car35.source_gear+1
	if target==gear:return
	if target>gear:
		shift_start=[1,17,26,36][target-1];shift_end=[13,20,31,39][target-1]
	else:
		shift_start=[78,67,56,45][target];shift_end=[93,70,61,48][target]
	shift_target_gear=target
	shift_time=float(shift_end-shift_start+1)/30.0
	gear_arm_frame=shift_start;gear_stick_frame=shift_start

func update_car_audio():
	if snd.action_paused:return
	var active=state=="play"
	snd.update_engine(speed,active,brake_held,car35.level,car35.state,car35.clock,float(car35.SCALES[car35.level]),car35.revision)
	var tire_brake=active and speed>0 and (car35.state in [car35.BRAKE,car35.HAND_BRAKE] or oil_time>0)
	snd.set_action_loop("tire_brake","TireBrake",tire_brake,-18)
	snd.set_action_loop("heavy_wind","HeavyWind",active and glass_hp<=0 and speed>0,-15+linear_to_db(maxf(.001,speed/float(car35.MAX_SPEEDS[car35.level]))))
	snd.set_action_loop("burning_engine","BurningEngine",active and fire_started,-22)
	var smoking=active and armor_level==0 and car_hp<36
	if smoking and not car_smoking:snd.play("SmokingEngine",-18)
	car_smoking=smoking

func damage_car_side(index:int,amount:float):
	var old=float(side_damage[index])
	side_damage[index]=minf(100.0,old+amount*(2.0 if mode=="hardcore" else 1.0))
	if old<100 and side_damage[index]>=100:snd.play("SideWindowBreak",-10);side_window_time[index]=0
	if old<=90 and side_damage[index]>90:side_mirror_time[index]=0

func side_window_frame(index:int) -> int:
	var value=float(side_damage[index])
	if value>=100:return 4+int(float(side_window_time[index])*30)
	return 3 if value>75 else (2 if value>50 else (1 if value>15 else 0))

func side_mirror_frame(index:int) -> int:
	var value=float(side_damage[index])
	if value>90:return 4+int(float(side_mirror_time[index])*30)
	return 3 if value>60 else (2 if value>30 else (1 if value>0 else 0))

func kill_hood(by_gun: bool,tossed: bool=false,from_wall:bool=false):
	if hood.is_empty() or awarded:return
	achievement_system.hood_removed(progress,String(hood.kind),by_gun,from_wall,bool(hood.get("gun_out",false)));flush_achievements364()
	if hood.kind=="soldier":soldier_kills+=1
	else:kills+=1
	hood_kills+=1
	if by_gun:hood_shot_kills+=1
	else:hood_shaken_kills+=1
	run_rp+=40 if by_gun else 15
	dying_hood={"kind":hood.kind,"time":0.0,"gun":by_gun,"tossed":tossed,"anim":"Shot" if by_gun else "GetOff"}
	hood.clear()
	snd.play("HitZombie01",-8)
	if by_gun:add_blood()
	popup("+%d RP" % (40 if by_gun else 15),AMBER)
	if mode=="time" and hood.get("kind",dying_hood.kind)!="soldier":time_left+=8 if by_gun else 6

func damage_player(amount,cause: String="Military"):
	if awarded:return
	body_recovery=8
	health=maxf(0.0,health-amount*(1-float(progress.upgrades[1])*0.12)*(2.0 if mode=="hardcore" else 1.0))
	if health<=0 and fatal_cause.is_empty():fatal_cause=cause
	red_flash=0.32;shake=maxf(shake,3.5)
	if health>0 and cause!="Zombie":source_player_voice("RDPlayer.m_BulletHitVoices",1.0,0,-9)

func add_blood(relative_x:float=0):
	if glass_hp<=0:return
	var slots:Array
	if absf(relative_x)<0.3:slots=[8,9,10,11,12,13,14,15]
	elif relative_x<0:slots=[1,2,3,4,5,6,7,8]
	else:slots=[13,14,15,16,17,18]
	var slot=int(slots[rng.randi_range(0,slots.size()-1)])
	for b in blood:
		if int(b.slot)==slot:b.frame=0;b.life=1.0;return
	blood.append({"slot":slot,"frame":0,"life":1.0})

func popup(text: String,color: Color):
	if text.begins_with("+") and text.ends_with(" RP"):
		effects.append({"text":text,"color":color,"time":1.7,"y":330.0})

func say(text: String,duration: float=3):
	notice=text;notice_time=duration

func speak(key: String, text: String, _duration: float=4):
	snd.speak(key,false,text)

func _voice_caption_started(_key: String, text: String, duration: float):
	subtitle=text
	subtitle_time=duration+0.5 if not text.is_empty() else 0.0

func _voice_caption_finished(_key: String):
	subtitle=""
	subtitle_time=0.0

func update_progression():
	if mode not in ["story","hardcore"]:
		segment=mini(19,int((position_z-start_z)/1400)*2)
		chapter_index=mini(10,segment/2)
		return
	while segment<LENGTHS.size() and position_z-segment_start>=float(LENGTHS[segment]):
		segment_start+=LENGTHS[segment];segment+=1
		if segment>=LENGTHS.size():
			progress.finished=true;progress.save();finish_run("You escaped Evans City.",true);return
		chapter_index=mini(10,segment/2)
		if segment%2==0:
			pre_checkpoint_pending=segment<20;post_checkpoint_pending=true
			if not awarded:
				if mode=="story":progress.checkpoint=segment
				else:progress.hardcore_checkpoint=segment
				if progress.save():show_checkpoint_message("Progress Saved...",CHAPTERS[chapter_index])
				else:show_checkpoint_message("Could not save!","Check available disk space.")
		if segment==20:
			nuke_time=120;last_nuke_call=-1
	if pre_checkpoint_pending and position_z>=segment_start+float(LENGTHS[segment])-float(source_rules.pre_margins[chapter_index]):
		pre_checkpoint_pending=false;snd.play_radio("CheckPoint%dPre" % mini(10,chapter_index+1),2)
	if post_checkpoint_pending and position_z>=segment_start+float(source_rules.post_margins[chapter_index]):
		post_checkpoint_pending=false;snd.play_radio("CheckPoint%dPost" % chapter_index,2)

func reset_air_delays():
	var idx=clampi(int(chapter_index),0,10)
	var mins=[30.0,28.0,26.0,24.0,80.0,70.0,60.0,50.0,40.0,30.0,20.0]
	helicopter_delay=float(mins[idx])+rng.randf_range(0.0,10.0)
	jet_delay=float(mins[idx])+rng.randf_range(0.0,20.0)

func air_limits() -> Dictionary:
	if mode in ["story","hardcore"]:
		return {"heli":8,"missile":16,"jet":14,"end":20}
	return {"heli":4,"missile":8,"jet":7,"end":999}

func spawn_source_helicopter():
	record_tutorial_encounter("Helicopters")
	var limits=air_limits()
	var diff=clampi(int(floor(float(segment-int(limits.heli))/2.0))+1,1,6)
	var i=diff-1
	var not_fire=[5.0,4.5,4.0,3.5,3.0,2.5]
	var no_missile=[20.0,18.0,16.0,14.0,15.0,10.0]
	helicopter={
		"x":0.0,"z":position_z-400.0,"y":5.0,"t":0.0,"difficulty":diff,"hp":3,
		"broken":false,"retreating":false,"warned_player":false,"warning_timer":7.5,
		"kind":"air_helicopter","anim":"Idle","anim_time":0.0,"vz":0.0,"rotation":0.0,
		"firing":false,"fire_phase_timer":0.0,"fire_phase_duration":float(not_fire[i])+rng.randf_range(0.0,0.5),
		"bullet_timer":0.0,"can_missiles":segment>=int(limits.missile) and (segment>int(limits.missile) or not source_story_dialog_active()),"missile_mode":false,
		"missile_cycle_timer":0.0,"missile_cycle_duration":float(no_missile[i]),
		"missile_timer":0.0,"missile_delay":float([3.0,3.0,3.0,3.0,3.0,2.0][i])+rng.randf_range(0.0,0.5),
		"missile_right":rng.randf()>0.5,"missiles":[],"switch_timer":0.0
	}

	snd.speak("HelicopterDispatch%02d" % rng.randi_range(1,2),false,"",-6)

func launch_source_missile():
	if helicopter.is_empty():return
	var side=1.0 if bool(helicopter.missile_right) else -1.0
	helicopter.missile_right=not bool(helicopter.missile_right)
	var start_x=float(helicopter.x)+side
	var start_z=float(helicopter.z)-0.1
	var initial_dist=start_z-(position_z+10.0)
	if absf(initial_dist)<1.0:initial_dist=1.0
	var missiles:Array=helicopter.missiles
	missiles.append({
		"x":start_x,"start_x":start_x,"target_x":player_x,"z":start_z,"y":4.9,"start_y":4.9,
		"vz":speed/3.6,"initial_dist":initial_dist,"exploded":false,"age":0.0
	})
	snd.play_world("RocketLaunch",helicopter.x,helicopter.z,-7,"loud",1.0)

func source_explosion(x:float,z:float,cause:String) -> bool:
	effects.append({"text":"","color":AMBER,"time":0.9,"y":0.0,"blast_x":x,"blast_z":z})
	snd.play_world("Explosion",x,z,-6,"loud",1.0)
	if awarded:return false
	shake=maxf(shake,8.0)
	if absf(x-player_x)>5.0 or absf(z-position_z)>30.0:return false
	damage_car(60.0,0.0,true,cause)
	if glass_hp>0:damage_glass(30.0)
	else:
		body_recovery=8
		var body_damage=65.0*(1.0-float(progress.upgrades[1])*0.12)
		health=maxf(10.0,health-body_damage)
		red_flash=maxf(red_flash,0.32)
	return true

func update_source_missiles(dt:float):
	if helicopter.is_empty():return
	var missiles:Array=helicopter.get("missiles",[])
	for m in missiles:
		if bool(m.get("exploded",false)):continue
		m.age=float(m.get("age",0.0))+dt
		var dist=float(m.z)-(position_z+10.0)
		var initial=float(m.initial_dist)
		var ratio=clampf(1.0-dist/initial,0.0,1.25)
		m.x=lerpf(float(m.start_x),float(m.target_x),ratio)
		m.y=maxf(0.0,dist/initial*float(m.start_y))
		m.vz=float(m.vz)-15.0*dt
		m.z=float(m.z)+float(m.vz)*dt
		if float(m.y)<=0.05 or dist<=0:
			m.exploded=true
			source_explosion(float(m.x),float(m.z),"Helicopter")
	missiles=missiles.filter(func(m):return not bool(m.get("exploded",false)))
	helicopter.missiles=missiles

func update_source_helicopter(dt:float):
	if helicopter.is_empty():return
	helicopter.t=float(helicopter.t)+dt
	advance_helicopter_animation(dt)
	var limits=air_limits()
	if segment>=int(limits.end):
		helicopter.retreating=true;helicopter.broken=true;helicopter.firing=false
	var old_z=float(helicopter.z)
	var rel=old_z-position_z
	var player_ms=speed/3.6
	var target_speed=clampf(player_ms*2.0,50.0/3.6,200.0/3.6)
	var dist_ratio=clampf(absf(rel-20.0)/60.0,0.0,1.0)
	if bool(helicopter.broken):
		var decel=(6.0 if bool(helicopter.retreating) else 3.0)/3.6
		helicopter.vz=float(helicopter.vz)-decel*dt
		helicopter.y=float(helicopter.y)+0.5*dt
	else:helicopter.vz=lerpf(player_ms,target_speed,dist_ratio)
	var target_x=0.0 if bool(helicopter.broken) else player_x
	helicopter.rotation=(target_x-float(helicopter.x))*2.0
	helicopter.x=lerpf(float(helicopter.x),target_x,1.0-exp(-dt*(0.1 if bool(helicopter.broken) else 0.6)))
	helicopter.z=minf(old_z+float(helicopter.vz)*dt,position_z+20.0)
	helicopter_sign_collision(old_z)
	rel=float(helicopter.z)-position_z
	snd.world_loop("helicopter_fly","HelicopterLoop",true,helicopter.x,helicopter.z,-13,"loud",1.0)
	snd.world_loop("helicopter_alert","HelicopterBrokenAlert",bool(helicopter.broken) and not bool(helicopter.retreating),helicopter.x,helicopter.z,-14,"default",1.0)
	if bool(helicopter.broken):
		helicopter.firing=false
		update_source_missiles(dt)
		if rel < -100:
			helicopter.clear();reset_air_delays()
		return
	if awarded:
		helicopter.firing=false;helicopter.missile_mode=false
		snd.world_loop("helicopter_fire","HelicopterFireLoop",false,helicopter.x,helicopter.z)
		update_source_missiles(dt);return
	if rel>0 and not bool(helicopter.warned_player):
		helicopter.warned_player=true
		source_sound_bag("RDPlayer.m_HelicopterReactionVoices",-6,true)
	if rel>10:
		helicopter.warning_timer=float(helicopter.warning_timer)+dt
		if float(helicopter.warning_timer)>=15.0:
			helicopter.warning_timer=0.0
			helicopter_warning_index=(helicopter_warning_index%9)+1
			snd.play_world("HelicopterWarning%02d" % helicopter_warning_index,helicopter.x,helicopter.z,-9,"loud",1.0,helicopter)
	var i=clampi(int(helicopter.difficulty)-1,0,5)
	var fire_min=[1.0,1.5,2.0,2.5,3.0,3.5]
	var rest_min=[5.0,4.5,4.0,3.5,3.0,2.5]
	var missile_duration=[10.0,10.0,10.0,10.0,10.0,15.0]
	var no_missile=[20.0,18.0,16.0,14.0,15.0,10.0]
	if bool(helicopter.can_missiles):
		helicopter.missile_cycle_timer=float(helicopter.missile_cycle_timer)+dt
		if float(helicopter.missile_cycle_timer)>=float(helicopter.missile_cycle_duration):
			helicopter.missile_cycle_timer=0.0
			helicopter.missile_mode=not bool(helicopter.missile_mode)
			helicopter.firing=false;helicopter.bullet_timer=0.0
			if bool(helicopter.missile_mode):
				helicopter.switch_timer=1.25
				helicopter.missile_cycle_duration=float(missile_duration[i])
				snd.speak("HelicopterMissileRequest%02d" % rng.randi_range(1,2),false,"",-6)
			else:
				helicopter.missile_cycle_duration=float(no_missile[i])
				helicopter.fire_phase_timer=0.0;helicopter.fire_phase_duration=float(rest_min[i])+rng.randf_range(0.0,0.5)
	if bool(helicopter.missile_mode):
		snd.world_loop("helicopter_fire","HelicopterFireLoop",false,helicopter.x,helicopter.z)
		helicopter.switch_timer=maxf(0.0,float(helicopter.switch_timer)-dt)
		if float(helicopter.switch_timer)<=0 and rel>10:
			helicopter.missile_timer=float(helicopter.missile_timer)+dt
			if float(helicopter.missile_timer)>=float(helicopter.missile_delay):
				helicopter.missile_timer=0.0
				helicopter.missile_delay=float([3.0,3.0,3.0,3.0,3.0,2.0][i])+rng.randf_range(0.0,0.5)
				launch_source_missile()
	else:
		helicopter.fire_phase_timer=float(helicopter.fire_phase_timer)+dt
		if float(helicopter.fire_phase_timer)>=float(helicopter.fire_phase_duration):
			helicopter.fire_phase_timer=0.0
			helicopter.firing=not bool(helicopter.firing)
			helicopter.fire_phase_duration=float(fire_min[i] if bool(helicopter.firing) else rest_min[i])+rng.randf_range(0.0,0.5)
			if not bool(helicopter.firing):helicopter.bullet_timer=0.0
		var firing=bool(helicopter.firing) and rel>10
		snd.world_loop("helicopter_fire","HelicopterFireLoop",firing,helicopter.x,helicopter.z,-8,"loud",1.0)
		if firing:
			helicopter.bullet_timer=float(helicopter.bullet_timer)+dt
			while float(helicopter.bullet_timer)>=0.1:
				helicopter.bullet_timer=float(helicopter.bullet_timer)-0.1
				if absf(float(helicopter.x)-player_x)<3.0:
					take_bullet365(3.0,6.0,"Helicopter")
				else:snd.play_world("BulletMiss%02d" % rng.randi_range(1,8),helicopter.x,helicopter.z,-18,"default",1.0)
	update_source_missiles(dt)

func spawn_source_jet():
	var limits=air_limits()
	var total=clampi(int(floor(float(segment-int(limits.jet))/2.0))+1,1,6)
	jet={
		"x":float([-5,0,5][rng.randi_range(0,2)]),"z":position_z-400.0,"y":9.0,
		"phase":"pass","return_timer":0.0,"pass_sound":true,"return_sound":false,"warned":false,
		"drops":0,"total_drops":total,"bombs":[],"bombs_dropped":false,"result_timer":0.0,
		"player_hit":false,"wait_timer":0.0,"t":0.0
	}
	snd.speak("JetDispatch%02d" % rng.randi_range(1,2),false,"",-6)

func update_jet_bombs(dt:float):
	if jet.is_empty():return
	var bombs:Array=jet.get("bombs",[])
	for b in bombs:
		if bool(b.get("detonated",false)):continue
		b.delay=float(b.delay)-dt
		if float(b.delay)<=0:
			b.detonated=true
			if source_explosion(float(b.x),float(b.z),"Jet"):jet.player_hit=true
	jet.bombs=bombs

func update_source_jet(dt:float):
	if jet.is_empty():return
	jet.t=float(jet.t)+dt
	var rel=float(jet.z)-position_z
	var player_ms=speed/3.6
	var phase=String(jet.phase)
	if phase=="pass":
		jet.z=float(jet.z)+(300.0/3.6+player_ms)*dt
		rel=float(jet.z)-position_z
		if bool(jet.pass_sound) and rel>-150:
			jet.pass_sound=false;snd.play_world("JetPassBy",jet.x,jet.z,-5,"superloud",1.0,jet);shake=maxf(shake,2.0)
		if rel>0 and not bool(jet.warned):
			jet.warned=true;source_sound_bag("RDPlayer.m_JetReactionVoices",-6,true)
		if rel>0:
			jet.return_timer=float(jet.return_timer)+dt
			if float(jet.return_timer)>=5.0:
				jet.phase="return";jet.return_sound=true;jet.bombs_dropped=false
				jet.x=float([-5,0,5][rng.randi_range(0,2)])
	elif phase=="return":
		jet.z=float(jet.z)+(-300.0/3.6+player_ms)*dt
		rel=float(jet.z)-position_z
		if bool(jet.return_sound) and rel<150:
			jet.return_sound=false;snd.play_world("JetPassBy",jet.x,jet.z,-5,"superloud",1.0,jet);shake=maxf(shake,2.0)
		if not bool(jet.bombs_dropped) and rel<100:
			jet.bombs_dropped=true;jet.player_hit=false;jet.result_timer=0.0
			jet.drops=int(jet.drops)+1
			var bombs:Array=[]
			for i in range(8):bombs.append({"x":float(jet.x),"z":float(jet.z)-float(i)*8.0,"delay":float(i)*0.25,"detonated":false})
			jet.bombs=bombs
		if bool(jet.bombs_dropped):
			update_jet_bombs(dt)
			jet.result_timer=float(jet.result_timer)+dt
			if float(jet.result_timer)>=4.0:
				if bool(jet.player_hit):
					snd.speak("JetHit%02d" % rng.randi_range(1,2),false,"",-6)
					jet.phase="done"
				elif int(jet.drops)>=int(jet.total_drops):
					if not awarded:achievement_system.bombing_dodged(progress);flush_achievements364();air_dodges+=1;snd.speak("JetMissAndLeave%02d" % rng.randi_range(1,2),false,"",-6)
					jet.phase="done"
				else:
					if not awarded:achievement_system.bombing_dodged(progress);flush_achievements364();air_dodges+=1;snd.speak("JetMissAndRepeat%02d" % rng.randi_range(1,3),false,"",-6)
					jet.phase="wait";jet.wait_timer=0.0
				jet.bombs.clear()
	elif phase=="wait":
		jet.z=float(jet.z)+(-300.0/3.6+player_ms)*dt
		jet.wait_timer=float(jet.wait_timer)+dt
		if float(jet.wait_timer)>=8.0:
			jet.z=position_z-400.0;jet.phase="pass";jet.return_timer=0.0
			jet.pass_sound=true;jet.return_sound=false;jet.warned=false;jet.bombs_dropped=false;jet.result_timer=0.0
	elif phase=="done":
		jet.z=float(jet.z)+(-300.0/3.6+player_ms)*dt
		if float(jet.z)-position_z < -1100:
			jet.clear();jet_delay=source_air_delay("jet")

func source_air_delay(kind:String) -> float:
	var idx=clampi(int(chapter_index),0,10)
	var mins=[30.0,28.0,26.0,24.0,80.0,70.0,60.0,50.0,40.0,30.0,20.0]
	return float(mins[idx])+rng.randf_range(0.0,10.0 if kind=="helicopter" else 20.0)

func update_air(dt):
	if not air.is_empty():
		var injected=String(air.get("kind",""))
		if injected=="helicopter":
			if health<=1 and glass_hp<=0:damage_player(6.0,"Helicopter")
			elif car_hp<=1:damage_car(60.0,0.0,true,"Helicopter")
			elif helicopter.is_empty():spawn_source_helicopter()
			elif air.get("hit",false):
				source_helicopter_hit()
			elif air.get("force_missile",false):
				helicopter.can_missiles=true;helicopter.missile_mode=true;helicopter.switch_timer=0.0
		elif injected=="jet":
			if health<=1 or car_hp<=1:source_explosion(player_x,position_z,"Jet")
			elif jet.is_empty():spawn_source_jet()
		air.clear()
	var limits=air_limits()
	var air_allowed=segment<int(limits.end)
	if air_allowed and segment>=int(limits.heli) and helicopter.is_empty() and (segment>int(limits.heli) or not source_story_dialog_active()):
		helicopter_delay-=dt
		if air_delay<1000:helicopter_delay=minf(helicopter_delay,air_delay)
		if helicopter_delay<=0:spawn_source_helicopter();air_delay=99999
	if air_allowed and segment>=int(limits.jet) and jet.is_empty() and (segment>int(limits.jet) or not source_story_dialog_active()):
		jet_delay-=dt
		if air_delay<1000:jet_delay=minf(jet_delay,air_delay+3.0)
		if jet_delay<=0:spawn_source_jet();air_delay=99999
	update_source_helicopter(dt)
	update_source_jet(dt)

func finish_run(reason: String,won: bool=false,death_cause: String=""):
	if awarded:return
	clear_original_tutorial();abort_confirm=false
	if death_cause=="Zombie" and glass_hp<=0:record_tutorial_encounter("No Windshield")
	if won:achievement_system.escaped(progress,mode,nuke_time);flush_achievements364()
	awarded=true
	pending_death_cause=death_cause if not won and DEATH_DIALOGUES.has(death_cause) else ""
	result_reason=reason
	var hood_points=run_rp
	var base=int((position_z-start_z)*0.05)+kills*5+soldier_kills*5+run_rp+air_dodges*20
	base=int(base*(1+precision_hits*0.01)*maxf(0.1,1-civilians_hit*0.05))
	run_rp=maxi(0,base)
	progress.rp+=run_rp;progress.best=maxf(progress.best,position_z-start_z)
	progress.save()
	state="results";stop_horn();wiper_pressed=false;snd.stop_action();snd.stop_world_audio();snd.pause_all(false)
	death_screen_clip="";death_screen_time=0;death_points_sound=false;death_point_rows.clear();death_explosion=false
	if not pending_death_cause.is_empty():
		snd.begin_gameplay_dialogue();snd.gameplay_failed=true
		death_explosion=pending_death_cause=="Crash" or (car_hp<=0 and pending_death_cause not in ["Zombie","Nuke"])
		death_screen_clip="FlashToRed" if pending_death_cause=="Zombie" else ("WhiteScreen" if pending_death_cause=="Nuke" else ("FadeToRed" if death_explosion else "FadeToBlack"))
		var raw=int((position_z-start_z)*0.05)+kills*5+soldier_kills*5+hood_points+air_dodges*20
		var precise=int(raw*(1+precision_hits*.01))
		death_point_rows=[
			["%.2f KM Reached:"%(maxf(0,position_z-start_z)/1000),str(int((position_z-start_z)*.05))+" RP"],
			[str(kills)+" Zombies Hit:",str(kills*5)+" RP"],
			[str(soldier_kills)+" Soldiers Hit:",str(soldier_kills*5)+" RP"],
			[str(hood_shaken_kills)+" Clinging Enemies Shook Off:",str(hood_shaken_kills*15)+" RP"],
			[str(hood_shot_kills)+" Clinging Enemies Shot Down:",str(hood_shot_kills*40)+" RP"],
			[str(air_dodges)+" Air Attacks Evaded:",str(air_dodges*20)+" RP"],
			["Other Road Points:",str(maxi(0,hood_points-hood_shaken_kills*15-hood_shot_kills*40))+" RP"],
			[str(precision_hits)+" Splatter Hits:",str(precise-raw)+" RP Bonus"],
			[str(civilians_hit)+" Civilians Hit:","-"+str(precise-run_rp)+" RP Penalty"],
			["Total Road Points:",str(run_rp)+" RP"]
		]
		snd.set_music("FailStringer_1_V4",false)
		if pending_death_cause=="Zombie":source_player_voice("RDPlayer.m_DeathScreamVoices",1.0,3,-10)
		elif pending_death_cause in ["Military","Helicopter"] and not death_explosion:source_player_voice("RDPlayer.m_FatalBulletHitVoices",1.0,3,-10)
		elif death_explosion:
			speed=0;lateral=0;steering=0;wall_contact=0;attack_time=0;red_flash=0;shake=.2
			hood.clear();dying_hood.clear()
			snd.play("Explosion",-16)
			snd.set_action_loop("death_burning","BurningEngine",true,-24)
	else:snd.set_music("Music_GarageMusic")
	if won and not test_mode:start_cinematic("ending","results")

# RDCamera explosion failure: initial offset 4, retreat 0.7 units/second,
# camera at player Z - 1 - offset and height 1.6. FOV remains 60 degrees.
func crash_camera_active() -> bool:
	return death_menu_active() and death_explosion

func camera_back_offset() -> float:
	return 5.0+0.7*death_screen_time if crash_camera_active() else 0.0

func camera_depth(z:float) -> float:
	return z+camera_back_offset()

func camera_height() -> float:
	return 1.6 if crash_camera_active() else 1.5

func camera_horizon() -> float:
	return 360.0 if crash_camera_active() else 255.0

func camera_focal() -> Vector2:
	if crash_camera_active():
		var source_focal=float(art.anim_data.cockpit14.original_camera_scale)/0.0034959*1.8
		return Vector2(source_focal,source_focal)
	return Vector2(FOCAL_X,FOCAL_Y)

func project_point(x: float,z: float,y: float=0) -> Vector2:
	z=maxf(0.6,camera_depth(z))
	var ramp=pow(z/300.0,2)*11.66667
	return Vector2(RW*0.5+(x-player_x)*camera_focal().x/z,camera_horizon()+(camera_height()-y-ramp)*camera_focal().y/z)

func _draw():
	if art==null:return
	buttons.clear()
	draw_set_transform(Vector2.ZERO)
	if release34_isolated:
		draw_rect(Rect2(0,0,RW,H),Color("#e7aa78"))
		if not release34_pose.is_empty():
			var r=release34_pose
			if r.bank=="anim":art.draw_anim(self,r.key,int(r.frame))
			else:draw_world_sprite(r.key,int(r.frame),float(r.x),float(r.z),float(r.height),false)
		return
	if release33_isolated:
		draw_rect(Rect2(0,0,RW,H),Color("#e7aa78"))
		if not release33_pose.is_empty():draw_air_world_sprite(release33_pose.key,int(release33_pose.frame),float(release33_pose.x),float(release33_pose.z),0.0,1.0)
		return
	if release31_isolated:
		draw_rect(Rect2(0,0,RW,H),Color("#e7aa78"))
		for impact in impacts:draw_world_impact(impact)
		return
	draw_rect(Rect2(0,0,RW,H),INK)
	if state=="cinematic":
		var r=art.menu_data.buttons.cinema_skip.rect
		buttons.append({"id":"cinema_skip","rect":Rect2(r[0],r[1],r[2],r[3])})
		return
	if state in ["play","paused"] or death_menu_active() or state=="options" and previous_state=="paused" or state=="controls" and previous_state=="paused":
		draw_world()
	else:
		draw_set_transform(UI_OFFSET)
		draw_frontend_background()
	draw_set_transform(UI_OFFSET)
	match state:
		"menu":draw_menu()
		"achievements":draw_achievements364()
		"garage":draw_garage()
		"play":draw_hud()
		"paused":
			if abort_confirm:draw_hud()
			else:draw_pause()
		"options":draw_options()
		"controls":draw_controls()
		"results":draw_results()
		"cinematic":pass
	if ui_message_time>0 and state not in ["play","garage"] and pending_mode.is_empty():
		draw_source_sign(Rect2(175,604,730,82))
		draw_wrapped_text(ui_message,Rect2(201,624,678,43),25,Color.WHITE,art.menu_font,true)
	draw_achievement_message364()
	if state=="menu" and not pending_mode.is_empty():draw_start_confirmation()
	if abort_confirm:draw_abort_confirmation()

func draw_frontend_background():
	var menu_back=state in ["menu","achievements"] or ((state=="options" or state=="controls") and previous_state=="menu")
	if menu_back and not art.menu_data.is_empty():
		draw_flash_menu_scene()
	elif menu_back and art.native_texture("menu_native") != null:
		art.draw_native(self,"menu_native",Rect2(0,0,W,H))
	elif state=="garage" and art.native_texture("garage_bg") != null:
		art.draw_native(self,"garage_bg",Rect2(0,0,W,H))
	elif state=="garage" and art.native_texture("garage_native") != null:
		art.draw_native(self,"garage_native",Rect2(0,0,W,H))
	else:
		art.fit(self,"garage",0,Rect2(0,0,W,H))
		draw_rect(Rect2(0,0,W,H),Color(0.02,0.025,0.035,0.78))

func label(text: String,pos: Vector2,size: int=22,color: Color=PAPER,font: Font=null):
	var use_font=art.ui_font if font==null else font
	draw_string(use_font,pos+Vector2(1,2),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color(0,0,0,0.65))
	draw_string(use_font,pos,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func centered(text: String,y: float,size: int=22,color: Color=PAPER,font: Font=null):
	var use_font=art.ui_font if font==null else font
	var width=use_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	label(text,Vector2((W-width)/2,y),size,color,use_font)

func draw_flash_menu_scene():
	if art.menu_data.is_empty():
		if art.native_texture("menu_native")!=null: art.draw_native(self,"menu_native",Rect2(0,0,W,H))
		return
	for entry in art.menu_data.get("background",[]):
		var fps=float(entry.get("fps",0))
		if entry.has("key"):
			var key=String(entry.key)
			var n=0 if fps<=0 else int(total_time*fps)
			art.draw_menu(self,key,n)
		elif entry.has("track"):
			var track:Array=entry.track
			if track.is_empty(): continue
			var row: Array=track[posmod(int(total_time*maxf(fps,1.0)),track.size())]
			for item in row:
				art.draw_menu_affine(self,String(item.key),item.matrix,0)
	art.draw_menu(self,"menu_foreground",0)
	art.draw_menu(self,"menu_title",mini(int(menu_time*30),art.menu_count("menu_title")-1))

func flash_button(source:String,id:String,enabled:bool=true,extra:Vector2=Vector2.ZERO,alpha:float=1.0) -> bool:
	var info:Dictionary=art.menu_data.get("buttons",{}).get(source,{})
	if info.is_empty(): return false
	var raw:Array=info.get("rect",[0,0,0,0])
	var rect=Rect2(Vector2(float(raw[0]),float(raw[1]))+extra,Vector2(float(raw[2]),float(raw[3])))
	var hover=enabled and rect.has_point(check_mouse if ui_audio_check else get_global_mouse_position()-UI_OFFSET)
	var state_name=("down" if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else "over") if hover else "up"
	# Flash garage upgrade buttons are invisible hit targets; exported red shapes are authoring masks.
	if source.begins_with("garage_") and source.ends_with("Button") and source not in ["garage_GoBackButton","garage_ReadyButton"]:
		if hover:draw_rect(rect,Color(1,1,1,0.1))
	else:
		art.draw_menu(self,String(info.get(state_name,source+"_up")),0,extra,Color(1,1,1,alpha if enabled else minf(alpha,0.45)))
	if enabled and id!="": buttons.append({"id":id,"rect":rect})
	return hover

func draw_menu():
	if art.menu_data.is_empty():
		return
	var hovered="default"
	for pair in [["MilitaryMode","police"],["TimeMode","time"],["StoryHardcoreMode","hardcore"],["StoryMode","story"],["Options","options"],["Achievements","achievements"]]:
		if flash_button(pair[0],pair[1]): hovered=pair[0]
	for passive in ["HighScores","Newgrounds","EvilDog","SickDeathFiend"]:
		if flash_button(passive,"",true): hovered=passive
	if flash_button("MusicButton","music",true): hovered="MusicButton"
	var variants:Array=art.menu_data.texts.get(hovered,art.menu_data.texts.default)
	var tip=String(variants[1] if hovered=="StoryHardcoreMode" and not progress.finished and variants.size()>1 else variants[0])
	draw_wrapped_text(tip,Rect2(60.48,506.52,339.12,193.32),27,Color.WHITE,art.menu_font,true)

func draw_wrapped_text(text: String, rect: Rect2, font_size: int, color: Color, font: Font, centered_text: bool=false):
	var paragraph=TextParagraph.new()
	paragraph.width=rect.size.x
	paragraph.alignment=HORIZONTAL_ALIGNMENT_CENTER if centered_text else HORIZONTAL_ALIGNMENT_LEFT
	paragraph.break_flags=TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	paragraph.add_string(text,font,font_size)
	# Preserve the source text box and prevent long localized/tool-tip lines escaping it.
	while paragraph.get_size().y>rect.size.y and font_size>18:
		font_size-=1
		paragraph.clear()
		paragraph.add_string(text,font,font_size)
	paragraph.draw(get_canvas_item(),rect.position,color)

func draw_flash_options():
	if art.menu_data.is_empty():return
	var t=clampf(panel_anim/0.4,0.0,1.0)
	t=1.0-pow(1.0-t,3.0)
	var controls_extra=Vector2(lerpf(-540.0,0.0,t),0)
	var options_extra=Vector2(lerpf(540.0,0.0,t),0)
	var back_extra=Vector2(0,lerpf(180.0,0.0,t))
	art.draw_menu(self,"options_Controls_base",0,controls_extra)
	art.draw_menu(self,"options_Options_base",0,options_extra)
	art.draw_menu(self,"options_BackPanel",0,back_extra)
	var keys=[]
	for k in progress.settings.keys:keys.append(OS.get_keycode_string(int(k)))
	var dynamic:Array=art.menu_data.get("panels",{}).get("options",{}).get("dynamic",[])
	var use_font=art.menu_font if art.menu_font!=null else art.ui_font

	var control_buttons=["options_SetKey1","options_SetKey2","options_SetKey3","options_SetKey4","options_SetKey5","options_SetKey6","options_SetKey7","options_SetKey8","options_SetKey9","options_SetKey10"]
	for i in range(control_buttons.size()):flash_button(control_buttons[i],"rebind_"+str(i),true,controls_extra)
	for i in range(10):
		var rr=art.menu_data.buttons["options_SetKey"+str(i+1)].rect
		var key_text="Press a key..." if i==rebind_index else String(keys[i])
		var key_size=23
		while key_size>16 and use_font.get_string_size(key_text,HORIZONTAL_ALIGNMENT_LEFT,-1,key_size).x>float(rr[2])-12:key_size-=1
		var tw=use_font.get_string_size(key_text,HORIZONTAL_ALIGNMENT_LEFT,-1,key_size).x
		var pos=Vector2(float(rr[0])+(float(rr[2])-tw)/2,float(rr[1])+float(rr[3])/2+8)+controls_extra
		draw_string(use_font,pos,key_text,HORIZONTAL_ALIGNMENT_LEFT,-1,key_size,Color.WHITE)

	flash_button("options_SoundsOn","sound_on",true,options_extra,1.0 if progress.settings.sound else 0.65)
	flash_button("options_SoundsOff","sound_off",true,options_extra,1.0 if not progress.settings.sound else 0.65)
	flash_button("options_MusicOn","music_on",true,options_extra,1.0 if progress.settings.music else 0.65)
	flash_button("options_MusicOff","music_off",true,options_extra,1.0 if not progress.settings.music else 0.65)
	flash_button("options_QualityLow","quality_low",true,options_extra,1.0 if int(progress.settings.quality)==0 else 0.65)
	flash_button("options_QualityMedium","quality_medium",true,options_extra,1.0 if int(progress.settings.quality)==1 else 0.65)
	flash_button("options_QualityHigh","quality_high",true,options_extra,1.0 if int(progress.settings.quality)==2 else 0.65)
	flash_button("options_BuildingsOn","buildings_on",true,options_extra,1.0 if progress.settings.buildings else 0.65)
	flash_button("options_BuildingsOff","buildings_off",true,options_extra,1.0 if not progress.settings.buildings else 0.65)
	flash_button("options_DeleteSaveGame","delete_save",true,options_extra)
	flash_button("options_Close","options_close",true,back_extra)
	if delete_confirm:
		draw_source_confirmation("Delete your save data?\nYou will lose all your progress")
		flash_button("confirm_YesButton","delete_yes")
		flash_button("confirm_NoButton","delete_cancel")

func draw_options():
	draw_flash_options()

func draw_controls():
	draw_flash_options()


func draw_garage():
	# Original Flash garage rebuilt as independent MovieClip layers.
	# Static full figures stay underneath; exact upgrade pieces and talking head replace them.
	if art.native_texture("garage_car")!=null:
		art.draw_native(self,"garage_car",Rect2(0,0,W,H))

	art.draw_anim(self,"garage_carbase",clampi(int((8.0/30.0-garage_upgrade_time)*30.0),0,7) if garage_upgrade_anim==3 else 0)
	art.draw_anim(self,"garage_bumper",clampi(int(progress.upgrades[5]),0,3))
	art.draw_anim(self,"garage_wheel",clampi(int(progress.upgrades[6]),0,3))
	var head_frame=garage_head_frame()

	native_scenes.draw_clip(self,"garage_body",int(garage_body_time*30),Transform2D(Vector2(1.8,0),Vector2(0,1.8),UI_OFFSET+Vector2(96.3,387.05)*1.8),{"Head":head_frame,"Chest":int(progress.upgrades[1]),"Belt":int(progress.upgrades[2]),"Hand":int(progress.upgrades[2])})
	draw_set_transform(UI_OFFSET)

	selected_upgrade=-1
	var names=["Perception","BodyArmor","Firearm","Windshield","Engine","Bumper","Tires","Horn"]
	for i in range(8):
		var hover=flash_button("garage_"+names[i]+"Button","buy_"+str(i))
		if hover:selected_upgrade=i
		var level=int(progress.upgrades[i])
		for j in range(3):
			art.draw_menu(self,"garage_bar",2 if j<level else (1 if hover and j==level else 0),Vector2(j*18.45,i*46.98))
	var rp_text="%d RP" % progress.rp
	garage_text(rp_text,Vector2(652.59,702.18),70,true)
	if selected_upgrade>=0:
		var i=selected_upgrade
		var level=int(progress.upgrades[i])
		# The original hides the information panel once a category is fully upgraded.
		if level<3:
			art.draw_menu_in_rect(self,"garage_info_background",0,Rect2(306,8,502,278))
			art.draw_menu(self,"garage_cost_label",0,Vector2(0,8))
			art.draw_menu_in_rect(self,"garage_description",i*3+level,garage_description_rect(i*3+level))
			garage_text(UPGRADE_NAMES[i],Vector2(322,64),garage_title_size(i))
			var price="%d RP" % COSTS[i][level]
			var price_width=art.garage_font.get_string_size(price,HORIZONTAL_ALIGNMENT_LEFT,-1,43).x
			garage_text(price,Vector2(724-price_width/2,77),43)
	var destination=CHAPTERS[campaign_checkpoint(mode)/2] if mode in ["story","hardcore"] else ("Dead On Time" if mode=="time" else "Police State")
	garage_text(destination,Vector2(1029.56,707.24),39,true,Color("#cccccc"))

	# Navigation is a foreground layer, as in the Flash display list.
	flash_button("garage_GoBackButton","menu")
	var drive_hover=flash_button("garage_ReadyButton","drive")
	art.draw_menu(self,"garage_drive",1 if drive_hover else 0)

func garage_title_size(i: int) -> int:
	var size=70
	while size>18 and art.garage_font.get_string_size(UPGRADE_NAMES[i],HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>300:
		size-=1
	return size

func garage_description_rect(frame: int) -> Rect2:
	var record=art.menu_record("garage_description",frame)
	var size=Vector2(record.rect[2],record.rect[3])
	var scale=minf(1.0,minf(470.0/size.x,178.0/size.y))
	return Rect2(Vector2(322,93),size*scale)

func garage_head_frame() -> int:
	if snd.voice.playing and snd.voice_key.begins_with("Player"):
		if snd.voice_level()<0.08:return 0
		return 10+posmod(int(snd.voice.get_playback_position()*30),19)
	if garage_head_anim=="blink":return clampi(1+int(garage_head_time*30),1,7)
	return 0

func garage_text(text: String, position: Vector2, font_size: int, right_aligned: bool=false, color: Color=Color.WHITE):
	var font=art.garage_font
	if right_aligned:position.x-=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	draw_string_outline(font,position,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,3,Color(0,0,0,0.85))
	draw_string(font,position,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,color)

func draw_pause():
	draw_rect(Rect2(-UI_OFFSET.x,0,RW,H),Color(0,0,0,0.56))
	# Reuse the original confirmation road sign; keep its authored border/corners.
	draw_source_sign(Rect2(246,46,588,628))
	centered("PAUSED",147,76,Color("#e4e9e7"),art.garage_font)
	var destination=CHAPTERS[clampi(chapter_index,0,10)] if mode in ["story","hardcore"] else ("Dead On Time" if mode=="time" else "Police State")
	centered(destination,181,25,Color("#bdcecb"),art.menu_font)
	var rows=[
		["resume","RESUME","Return to the road."],
		["options","OPTIONS","Sound, music and graphics."],
		["controls","CONTROLS","View and change your driving controls."],
		["retire","END RUN / GARAGE","Finish this run and collect your RP."],
		["quit","EXIT TO DESKTOP","Close Road of the Dead."]
	]
	var hint="Esc to resume"
	for i in range(rows.size()):
		var rect=Rect2(294,211+i*73,492,59)
		if pause_source_button(rows[i][0],rows[i][1],rect):hint=rows[i][2]
	draw_wrapped_text(hint,Rect2(293,608,494,42),23,Color("#bdcecb"),art.menu_font,true)

func pause_source_button(id: String, text: String, rect: Rect2) -> bool:
	var hover=rect.has_point(check_mouse if ui_audio_check else get_global_mouse_position()-UI_OFFSET)
	var size=51 if hover else 48
	while size>24 and art.garage_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>rect.size.x-20:size-=1
	var width=art.garage_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
	var baseline=rect.position+Vector2((rect.size.x-width)/2,(rect.size.y-art.garage_font.get_height(size))/2+art.garage_font.get_ascent(size))
	if hover and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):baseline.y+=2
	draw_string_outline(art.garage_font,baseline,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,3,Color(0,0,0,0.7))
	draw_string(art.garage_font,baseline,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color("#f06a5a") if hover else Color("#e0e5e3"))
	buttons.append({"id":id,"rect":rect})
	return hover

func draw_source_sign(destination: Rect2):
	var source=art.menu_record("confirm_background",0)
	var r=source.rect
	var texture=art.menu_pages[int(source.page)]
	var edge=48.0
	var target_edge=minf(edge,minf(destination.size.x,destination.size.y)*0.5)
	var sx=[float(r[0]),r[0]+edge,r[0]+r[2]-edge,float(r[0]+r[2])]
	var sy=[float(r[1]),r[1]+edge,r[1]+r[3]-edge,float(r[1]+r[3])]
	var dx=[destination.position.x,destination.position.x+target_edge,destination.end.x-target_edge,destination.end.x]
	var dy=[destination.position.y,destination.position.y+target_edge,destination.end.y-target_edge,destination.end.y]
	for y in range(3):
		for x in range(3):
			draw_texture_rect_region(texture,Rect2(dx[x],dy[y],dx[x+1]-dx[x],dy[y+1]-dy[y]),Rect2(sx[x],sy[y],sx[x+1]-sx[x],sy[y+1]-sy[y]))

func run_pause_menu_checks():
	ui_audio_check=true;preview_mode=true
	AudioServer.set_bus_volume_db(0,-80)
	mode="story";progress.checkpoint=4;start_run();speed=62
	set_pause()
	var distance=position_z
	var elapsed_before=elapsed
	await get_tree().create_timer(0.2).timeout
	expect(position_z==distance and elapsed==elapsed_before and snd.action_paused,"menu keeps driving and audio paused")
	check_mouse=Vector2(50,50)
	await frontend_capture("pause10_default")
	expect(buttons.size()==5,"all five pause actions available")
	for i in range(buttons.size()):
		expect(Rect2(246,46,588,628).encloses(buttons[i].rect),"pause action inside original sign")
		for j in range(i+1,buttons.size()):expect(not buttons[i].rect.intersects(buttons[j].rect),"pause actions do not overlap")
	check_mouse=Vector2(540,239);await frontend_capture("pause10_resume")
	await frontend_click("resume")
	expect(state=="play" and not snd.action_paused,"resume click continues gameplay")
	set_pause();await frontend_click("options")
	expect(state=="options" and previous_state=="paused" and snd.action_paused,"options preserves paused run")
	panel_anim=0.4;await frontend_capture("pause10_options")
	await frontend_click("options_close")
	expect(state=="paused","options close returns to pause")
	await frontend_click("controls")
	expect(state=="options" and previous_state=="paused","controls opens original controls panel")
	activate("options_close")
	var escape=InputEventKey.new();escape.physical_keycode=KEY_ESCAPE;escape.pressed=true
	_input(escape)
	expect(state=="play" and not snd.action_paused,"escape resumes")
	set_pause();check_mouse=Vector2(540,461);await frontend_capture("pause10_garage")
	await frontend_click("retire")
	expect(state=="results" and awarded,"end run records result once")
	var rp=progress.rp;finish_run("repeat");expect(progress.rp==rp,"end run does not award RP twice")
	activate("retry");expect(state=="garage","results returns to garage")
	start_run();set_pause();check_mouse=Vector2(540,534);await frontend_capture("pause10_exit")
	expect(buttons.any(func(b):return b.id=="quit"),"desktop exit remains routed")
	print("PAUSE_MENU_CHECK: ","PASS" if test_errors.is_empty() else "FAIL", " ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func draw_results():
	if death_menu_active():draw_death_menu();return
	# Original road-sign artwork, Modern No. 20 statistics and Dirty Ego figures.
	draw_source_sign(Rect2(140,28,800,664))
	var escaped=progress.finished and result_reason.begins_with("You escaped")
	centered("ESCAPED" if escaped else "RUN ENDED",119,70,Color("#e4e9e7"),art.garage_font)
	draw_wrapped_text(result_reason,Rect2(204,139,672,48),24,Color("#bdcecb"),art.menu_font,true)
	var stats=[
		["Distance","%.2f km" % (maxf(0,position_z-start_z)/1000)],
		["Zombies / Soldiers","%d / %d" % [kills,soldier_kills]],
		["Hood kills",str(hood_kills)],
		["Civilians hit",str(civilians_hit)],
		["RP earned","+"+str(run_rp)],
		["Total RP",str(progress.rp)]
	]
	for i in range(stats.size()):
		var y=223.0+i*42+(16 if i>=4 else 0)
		draw_string(art.menu_font,Vector2(210,y),stats[i][0],HORIZONTAL_ALIGNMENT_LEFT,-1,28,Color("#d0ddda"))
		var text=String(stats[i][1])
		var size=42 if i>=4 else 36
		while size>20 and art.garage_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x>268:size-=1
		var width=art.garage_font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
		var position=Vector2(868-width,y+2)
		draw_string_outline(art.garage_font,position,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,2,Color(0,0,0,0.65))
		draw_string(art.garage_font,position,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,Color.WHITE)
	pause_source_button("retry","GARAGE & UPGRADES",Rect2(238,495,604,60))
	pause_source_button("menu","MAIN MENU",Rect2(350,566,380,54))
	draw_wrapped_text("Enter or Space to return to the garage",Rect2(202,646,676,30),21,Color("#bdcecb"),art.menu_font,true)

func run_results_menu_checks():
	ui_audio_check=true;preview_mode=true
	AudioServer.set_bus_volume_db(0,-80)
	mode="story";progress.checkpoint=0;progress.rp=92
	start_run();set_pause();activate("retire")
	expect(state=="results" and awarded and progress.rp==92,"zero-distance retirement preserves RP")
	check_mouse=Vector2(40,40);await frontend_capture("results11_zero")
	expect(buttons.size()==2,"results has garage and menu actions")
	for b in buttons:expect(Rect2(140,28,800,664).encloses(b.rect),"results action fits sign")
	expect(not buttons[0].rect.intersects(buttons[1].rect),"results actions do not overlap")
	check_mouse=Vector2(540,525);await frontend_capture("results11_garage_hover")
	await frontend_click("retry")
	expect(state=="garage" and not snd.action_paused,"garage click initializes garage")
	expect(progress.rp==92,"garage navigation does not charge or duplicate RP")
	start_run();position_z=start_z+12785;kills=117;soldier_kills=24;hood_kills=16;civilians_hit=3;run_rp=375
	finish_run("The car was destroyed.")
	var earned=run_rp;var bank=progress.rp
	check_mouse=Vector2(40,40);await frontend_capture("results11_crash")
	finish_run("repeat")
	expect(progress.rp==bank and run_rp==earned,"results redraw/duplicate finish cannot award twice")
	await frontend_click("menu");expect(state=="menu" and progress.rp==bank,"main menu preserves result")
	for key in [KEY_ENTER,KEY_SPACE]:
		start_run();finish_run("Time ran out.")
		var event=InputEventKey.new();event.physical_keycode=key;event.pressed=true
		_input(event);expect(state=="garage" and not snd.action_paused,"keyboard garage shortcut "+str(key))
	start_run();progress.finished=true;finish_run("You escaped Evans City.",true)
	check_mouse=Vector2(540,594);await frontend_capture("results11_escaped")
	expect(state=="results","escape result displayed")
	progress.rp=999999999999;run_rp=999999999;kills=99999;soldier_kills=99999
	position_z=start_z+99999999;hood_kills=999999;civilians_hit=999999
	result_reason="The nuclear strike reached the city. Your run has ended."
	check_mouse=Vector2(40,40);await frontend_capture("results11_large_values")
	print("RESULTS_MENU_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func draw_world():
	var offset=Vector2.ZERO
	if progress.settings.shake and shake>0.1:offset=Vector2(sin(total_time*57),cos(total_time*73))*shake
	draw_set_transform(Vector2.ZERO)
	var horizon_shift=camera_horizon()-255.0
	art.fit(self,"sky",0,Rect2(-20,0,RW+40,285+horizon_shift))
	var tunnel_distance=segment_position(22)-position_z
	if mode!="story" or segment>=20 or tunnel_distance<1300:
		art.fit(self,"hill",0,Rect2(-70-player_x,115+horizon_shift,RW+140,150),Color(1,1,1,0.50))
	art.fit(self,"city",0,Rect2(-70-player_x*1.5,170+horizon_shift,RW+140,100))
	draw_rect(Rect2(0,258+horizon_shift,RW,H-258-horizon_shift),Color("#555458"))
	var draw_distance=float([130,185,240][clampi(int(progress.settings.quality),0,2)])
	var background=scenery.duplicate()
	background.sort_custom(func(a,b):return a.z>b.z)
	for b in background:
		var z=float(b.z)-position_z
		if progress.settings.buildings and camera_depth(z)>1 and camera_depth(z)<draw_distance:draw_world_sprite("buildings",int(b.frame),b.x,z,b.height,b.x<0)
	for sign_actor in road_signs:draw_source_road_sign(sign_actor,true)
	draw_highway_geometry(self)
	var render_list=entities.duplicate()
	render_list.append_array(road_signs)
	if not helicopter.is_empty():render_list.append(helicopter)
	render_list.sort_custom(func(a,b):return a.z>b.z)
	for e in render_list:
		var z=float(e.z)-position_z
		if camera_depth(z)<=1.3 or camera_depth(z)>=draw_distance:continue
		if e.kind=="road_sign":draw_source_road_sign(e);continue
		if e.kind=="air_helicopter":draw_source_heli();continue
		if e.kind=="soldier" and String(e.get("behavior",""))=="hidden" and not bool(e.get("revealed",false)):continue
		var key=String(e.get("anim",""));var f=int(e.frame)
		if key!="" and e.kind!="cars":
			f=int(float(e.anim_time)*30)
			if key in ["soldier_Idle","soldier_IdleToFire","soldier_SlideOut","soldier_PullSpikeStrip","soldier_PullSpikeStripIdle","soldier_Hidden"]:f=mini(f,art.world_data.groups.get(key,[]).size()-1)
		elif key=="":key=String(e.kind)
		if e.has("bomb_positions"):
			for i in range(int(e.get("bomb_index",0)),7):draw_world_sprite("explosion",art.world_data.groups.explosion.size()-1,e.bomb_positions[i],z,4.5)
		draw_world_sprite(key,f,e.x,z,e.height,bool(e.get("flip",false)))
		if e.kind=="soldier" and e.fired and int(e.shots)%2==1:
			draw_circle(project_point(e.x,z,1.25),clampf(45/camera_depth(z),1,5),Color("#ffdf83"))
	if segment>=20:draw_world_sprite("tunnel",0,0,maxf(10,segment_position(22)-position_z),20)
	draw_air()
	for effect in effects:
		if effect.has("blast_x"):
			var z=float(effect.blast_z)-position_z
			if z>0:
				draw_world_sprite("explosion",int((0.9-float(effect.time))*30),effect.blast_x,z,4.5)
	for impact in impacts:draw_world_impact(impact)
	draw_set_transform(offset)
	draw_cockpit(offset)
	draw_set_transform(Vector2.ZERO)
	if red_flash>0:draw_rect(Rect2(0,0,RW,H),Color(0.7,0.01,0.01,red_flash*0.35))
	draw_set_transform(Vector2.ZERO)

func world_impact_position(impact:Dictionary) -> Vector2:
	var x=player_x+float(impact.attach_offset_x) if impact.has("attach_offset_x") else float(impact.x)
	var z=float(impact.get("depth",1.12 if bool(impact.get("attached",false)) else 3.8+float(impact.time)*8.0))
	return Vector2(x,z)

func draw_world_impact(impact:Dictionary):
	var f=int(impact.get("start",0))+int(float(impact.time)*30.0)
	var frames:Array=art.world_data.get("groups",{}).get(String(impact.kind),[])
	if f>=frames.size():return
	var pose=world_impact_position(impact)
	draw_world_sprite(String(impact.kind),f,pose.x,pose.y,float(impact.get("height",1.8)),bool(impact.get("flip",false)))

func right_hand_on_wheel() -> bool:
	return gear_arm_frame==0 or gear_arm_frame==93

func draw_cockpit(offset:Vector2):
	if death_menu_active() and death_explosion:
		draw_crash_cockpit();return
	art.cockpit_mode=true;art.cockpit_pose=Transform2D.IDENTITY
	if fire_started:art.draw_anim(self,"fire",int(elapsed*30))
	if armor_level==0 and car_hp<36:art.draw_anim(self,"smoke",int(elapsed*30),Vector2.ZERO,Color(1,1,1,0.7))
	if wall_contact!=0 and speed>3:art.draw_anim(self,"leftsidesparks15" if wall_contact<0 else "rightsidesparks15",int(elapsed*30))
	art.draw_anim(self,"bumper",bumper_frame())
	if armor_break_level>0:art.draw_anim(self,"armor_break_"+str(armor_break_level),int(armor_break_time*30))
	draw_clinger(false)
	art.draw_anim(self,"windshield",windshield_frame())
	draw_blood()
	art.draw_anim(self,"wipers",wiper_frame())
	# Original MC_PlayerCar depths: mirrors 14/15, side glass 16/17, cabin 19.
	# Cabin and glass occlude the exterior mirror mount, including damaged poses.
	for i in range(2):
		var mirror_key=("left" if i==0 else "right")+"mirror35"
		art.draw_anim(self,mirror_key,mini(side_mirror_frame(i),art.car_data.groups[mirror_key].size()-1))
	for i in [1,0]:
		var window_key=("left" if i==0 else "right")+"window35"
		art.draw_anim(self,window_key,mini(side_window_frame(i),art.car_data.groups[window_key].size()-1))
	art.draw_anim(self,"car_base35",0)
	art.draw_anim(self,"speedometer14",speedometer_frame())
	draw_dashboard_progress()
	var pivot=art.cockpit_map(Vector2(328.86,575.82))
	art.cockpit_pose=Transform2D(steering*deg_to_rad(25),pivot)*Transform2D(0,-pivot)
	art.draw_anim(self,"car_wheel14",0)
	if attack_time<=0:art.draw_anim(self,"leftarm",0)
	if right_hand_on_wheel():art.draw_anim(self,"rightarm",0)
	art.cockpit_pose=Transform2D.IDENTITY
	art.draw_anim(self,"shiftstick",gear_stick_frame)
	if not right_hand_on_wheel():art.draw_anim(self,"rightarm",gear_arm_frame)
	draw_clinger(true)
	if attack_time>0:
		var af=(49 if attack_kind=="shoot" else 4)+int(attack_elapsed*30)
		art.draw_anim(self,"leftarm",mini(89 if attack_kind=="shoot" else 45,af))
	art.cockpit_mode=false

func draw_clinger(inside:bool):
	if not hood.is_empty():
		var key=String(HOOD_SYMBOLS.get(String(hood.kind),""))
		art.prefetch_clinger(key)
		art.prefetch_clinger(key+"inside")
	var pose=hood_pose()
	if pose.is_empty() or bool(pose.inside)!=inside:return
	art.draw_anim(self,pose.key,pose.frame)

func quad(x1,x2,z1,z2,y,col):
	if z2-z1<0.001:return
	draw_primitive(PackedVector2Array([project_point(x1,z1,y),project_point(x1,z2,y),project_point(x2,z2,y),project_point(x2,z1,y)]),PackedColorArray([col]),PackedVector2Array())

func draw_highway_geometry(canvas:CanvasItem):
	# Original wall -> sloped shoulders -> road. Shared inner vertices sit at Y=0.
	# Eight sliding steps, RenderStepSize=int((200-.1)/7)=28.
	var render_step=28.0
	var road_camera_z=position_z-camera_back_offset()
	var looped=fposmod(road_camera_z,render_step)
	var cam_slide=int(floor(road_camera_z/render_step))
	for i in range(7,-1,-1):
		var z1=maxf(float(i)*render_step-looped,0.1)
		var z2=minf(float(i+1)*render_step-looped,200.0)
		if z2<=z1:continue
		var off=((cam_slide+i)%2)==0
		var ratio=clampf(z1/200.0,0.0,1.0)
		var wall_near=Color8(88,91,95) if off else Color8(98,101,105)
		var wall_far=Color8(64,66,69) if off else Color8(74,76,79)
		var side_near=Color8(100,97,91) if off else Color8(110,107,101)
		var side_far=Color8(85,81,71) if off else Color8(95,91,81)
		var road_near=Color8(48,47,53) if off else Color8(58,57,63)
		var road_far=Color8(33,32,36) if off else Color8(43,42,46)
		var wall_col=wall_near.lerp(wall_far,ratio)
		var side_col=side_near.lerp(side_far,ratio)
		var road_col=road_near.lerp(road_far,ratio)
		for side in [-1,1]:
			canvas.draw_colored_polygon(PackedVector2Array([project_road_point(side*10,z1,2.0),project_road_point(side*10,z2,2.0),project_road_point(side*10,z2,0.0),project_road_point(side*10,z1,0.0)]),wall_col)
		road_quad(-10,-7.5,z1,z2,0.1,side_col,0.0,canvas)
		road_quad(7.5,10,z1,z2,0.0,side_col,0.1,canvas)
		road_quad(-7.5,7.5,z1,z2,0.0,road_col,0.0,canvas)
		# Lane dashes stay phase-locked to world distance.
		var cursor=ceil((road_camera_z+z1)/YELLOW_LINE_SPACING)*YELLOW_LINE_SPACING
		while cursor<road_camera_z+minf(z2,YELLOW_LINE_VIEW_DISTANCE):
			var near=maxf(z1,cursor-road_camera_z);var far=minf(z2,cursor-road_camera_z+3.5)
			if far-near>0.1:
				var line_color=Color("#b9b451");line_color.a=clampf((YELLOW_LINE_VIEW_DISTANCE-(cursor-road_camera_z))/30.0,0.0,1.0)
				for x in [-2.5,2.5]:road_quad(x-0.06,x+0.06,near,far,0.012,line_color,0.012,canvas)
			cursor+=YELLOW_LINE_SPACING

func project_road_point(x:float,z:float,y:float=0.0) -> Vector2:
	# Original RDRoad.Project3DTo2DQuick uses MaxViewDistance=200 for its ramp.
	z=maxf(0.1,z)
	var ramp=pow(z/200.0,2.0)*11.66667
	return Vector2(RW*0.5+(x-player_x)*camera_focal().x/z,camera_horizon()+(camera_height()-y-ramp)*camera_focal().y/z)

func road_quad(x1:float,x2:float,z1:float,z2:float,y:float,col:Color,y2:float=NAN,canvas:CanvasItem=null):
	if z2-z1<0.001:return
	if canvas==null:canvas=self
	if is_nan(y2):y2=y
	canvas.draw_primitive(PackedVector2Array([project_road_point(x1,z1,y),project_road_point(x1,z2,y),project_road_point(x2,z2,y2),project_road_point(x2,z1,y2)]),PackedColorArray([col]),PackedVector2Array())

func draw_world_sprite(key:String,n:int,x:float,z:float,height:float,flipped:bool=false):
	var f=art.ready_world_record(key,n)
	if f.is_empty():return
	var base=art.world_frame(key,n if key in ["buildings","cars","vehicle"] else 0)
	var original_h=maxf(1,-float(base.offset[1]))
	var object_scale=1.30 if key not in ["buildings","tunnel","explosion"] else 1.0
	var source_scale=0.0
	if key=="vehicle":source_scale=6.0
	elif key=="fence":source_scale=3.5
	elif key=="tunnel":source_scale=12.0
	elif key=="hard" or key.begins_with("hard_"):source_scale=2.2
	elif key in ["male","female","super","civilian","soldier"] or key.begins_with("male_") or key.begins_with("female_") or key.begins_with("super_") or key.begins_with("civilian_") or key.begins_with("soldier_"):source_scale=2.0
	elif key in ["feeders","feeders_idle26"]:source_scale=3.0
	elif key=="spikes":source_scale=6.0
	elif key in ["box","cone","barrel","construction_sign","electronic_sign","shopping_cart","water","oil"]:source_scale=1.0
	var scale=source_scale*0.0034959*camera_focal().y/camera_depth(z) if source_scale>0 else height*object_scale*camera_focal().y/camera_depth(z)/original_h
	var density=maxf(1.0,float(f.get("density",1.0)))
	var draw_scale=scale/density
	var pos=project_point(x,z)
	var src=Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3])
	var off=Vector2(f.offset[0],f.offset[1])
	var size=src.size*draw_scale
	var alpha=clampf((240-camera_depth(z))/30,0,1)
	var target=Rect2(pos+off*draw_scale,size)
	if flipped:target=Rect2(pos+Vector2(-off.x-src.size.x,off.y)*draw_scale,size)
	var texture=art.world_texture(key,int(f.page))
	if texture==null:return
	if flipped:
		draw_set_transform(Vector2(pos.x*2,0),0,Vector2(-1,1))
		target=Rect2(pos+off*draw_scale,size)
	draw_texture_rect_region(texture,target,src,Color(1,1,1,alpha))
	if key=="vehicle":
		draw_vehicle_overlays(n,pos,scale,alpha)
	elif key=="buildings":
		draw_building_effects(n,pos,scale,alpha,flipped)
	if flipped:draw_set_transform(Vector2.ZERO)
	if state=="play" and perception and progress.upgrades[0]>0 and z>20 and key!="buildings" and (key!="soldier_Hidden" or progress.upgrades[0]>=2):
		var color=Color("#75a66b") if key.begins_with("civilian") or key=="water" else Color("#c35744")
		var pt=pos-Vector2(0,height*camera_focal().y/camera_depth(z)+8)
		draw_colored_polygon(PackedVector2Array([pt+Vector2(-4,-4),pt+Vector2(4,-4),pt+Vector2(0,3)]),color)

func draw_vehicle_overlays(vehicle_frame:int,pos:Vector2,base_scale:float,alpha:float):
	var overlays:Array=art.world_data.get("vehicle_overlays16",{}).get(str(vehicle_frame),[])
	for ov in overlays:
		var m:Array=ov.get("matrix",[])
		if m.size()<6:continue
		var key=String(ov.get("key",""))
		var frames:Array=art.world_data.get("groups",{}).get(key,[])
		if frames.is_empty():continue
		var fr=art.ready_world_record(key,int(elapsed*30.0))
		if fr.is_empty():continue
		var sx=float(m[0]);var sy=float(m[3])
		var src=Rect2(fr.rect[0],fr.rect[1],fr.rect[2],fr.rect[3])
		var origin=pos+Vector2(float(m[4]),float(m[5]))*base_scale
		var off=Vector2(float(fr.offset[0])*sx,float(fr.offset[1])*sy)*base_scale
		var size=Vector2(src.size.x*absf(sx),src.size.y*absf(sy))*base_scale
		var texture=art.world_texture(key,int(fr.page))
		if texture==null:continue
		draw_texture_rect_region(texture,Rect2(origin+off,size),src,Color(1,1,1,alpha))

func draw_air():
	if not helicopter.is_empty():
		var missiles:Array=helicopter.get("missiles",[])
		for m in missiles:
			var mz=float(m.z)-position_z
			if camera_depth(mz)>1.0 and camera_depth(mz)<240.0:draw_air_world_sprite("rocket19",mini(23,int(float(m.get("age",0.0))*30.0)),float(m.x),mz,float(m.y),3.0)
	if not jet.is_empty():
		var z=float(jet.z)-position_z
		if camera_depth(z)>1.0 and camera_depth(z)<300.0:
			var pos=project_point(float(jet.x),z,float(jet.y))
			var sc=4.0*0.0034959*camera_focal().y/camera_depth(z)
			art.draw(self,"jet",0,pos,Vector2(sc,sc))

func draw_air_world_sprite(key:String,n:int,x:float,z:float,y:float,source_scale:float,rotation:float=0.0,flipped:bool=false):
	var f=art.ready_world_record(key,n)
	if f.is_empty() or camera_depth(z)<=0:return
	var density=maxf(0.01,float(f.get("density",1.0)))
	var sc=source_scale*0.0034959*camera_focal().y/camera_depth(z)/density
	var pos=project_point(x,z,y)
	var src=Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3])
	var off=Vector2(f.offset[0],f.offset[1])
	var tex=art.world_texture(key,int(f.page))
	if tex==null:return
	draw_set_transform(pos,deg_to_rad(rotation),Vector2(-1.0 if flipped else 1.0,1.0))
	var alpha=clampf((200.0-camera_depth(z))/50.0,0.0,1.0) if key.begins_with("highway_sign") else 1.0
	draw_texture_rect_region(tex,Rect2(off*sc,src.size*sc),src,Color(1,1,1,alpha))
	draw_set_transform(Vector2.ZERO)

func draw_blood():
	if glass_hp<=0:return
	for b in blood:art.draw_anim(self,"windblood15_blood"+str(b.slot),int(b.frame))

func draw_hud():
	# The original cockpit communicates vehicle condition visually through blood,
	# cracked glass, smoke/fire and the dashboard. Keep the permanent HUD minimal.
	if progress.upgrades[2]>0:
		var bullets: Texture2D=art.native_texture("hud_bullets")
		if bullets!=null:
			var shown=clampi(ammo,0,12)
			if shown>0:
				var source_w=minf(float(bullets.get_width()),shown*20.0)
				draw_texture_rect_region(bullets,Rect2(838,648,source_w,56),Rect2(0,0,source_w,bullets.get_height()))
		else:
			label(str(ammo),Vector2(916,575),62,Color.WHITE,art.title_font)
	if mode=="time":
		var secs=maxf(0.0,time_left)
		var mins=int(secs)/60
		var whole=int(secs)%60
		var centis=int((secs-floor(secs))*100.0)
		centered("%02d:%02d:%02d" % [mins,whole,centis],72,42,Color.WHITE,art.title_font)
	elif mode=="police":
		centered("%.2f KM" % ((position_z-start_z)/1000.0),66,32,Color.WHITE,art.title_font)
	draw_checkpoint_message()
	draw_original_abort()
	for e in effects:
		if not String(e.text).is_empty():centered(e.text,e.y,24,Color(e.color,clampf(e.time,0,1)),art.road_font)
	draw_original_tutorial()
	if preview_mode or benchmark_mode:
		label("%d FPS" % Engine.get_frames_per_second(),Vector2(1007,25),11,Color("#d1cec6"))

func expect(condition: bool,message: String):
	if not condition:test_errors.append(message);push_error("TEST FAIL: "+message)

func run_tests():
	print("SELF_TEST: begin")
	expect(patterns.size()>20,"original level patterns loaded")
	for key in ["cockpit","hood","wheel","male","female","cars","garage","wipers","hood_male"]:
		expect(art.count(key)>0,"asset group "+key)
	for key in ["menu_native","garage_native","cockpit_shell","hood_clingerzombienormalmale","hud_bullets"]:
		expect(art.native_texture(key)!=null,"native asset "+key)
	for key in ["leftarm","rightarm","windshield","bumper","garage_head","clingerzombienormalmale","armor_break_1"]:
		expect(art.anim_count(key)>1,"timeline imported: "+key)
	expect(art.menu_count("menu_title")==13,"original animated title entrance")
	start_run()
	for i in range(90):simulate(1.0/60,1.0,false,false,0)
	expect(speed>0 and position_z>start_z,"accelerate and advance")
	var stopped=speed
	for i in range(30):simulate(1.0/60,0.0,true,false,0)
	expect(speed<stopped,"braking")
	speed=65;simulate(0.1,1.0,false,false,1)
	expect(player_x>0,"steering")
	var car_before=car_hp
	var obstacle=spawn_entity("cars",player_x,position_z+1)
	collide(obstacle);expect(car_hp<car_before,"car collision damage")
	hood={"kind":"male","hp":50.0,"attack":0.0,"grip":0.0};glass_hp=0;attack_time=0;progress.upgrades[2]=0
	attack();update_action_animation(0.6);attack_time=0;attack();update_action_animation(0.6)
	expect(hood.hp==50 and attack_time==0,"unarmed attack cannot punch hood zombie")
	progress.upgrades[2]=1;ammo=3;attack_time=0
	hood={"kind":"male","hp":50.0,"attack":0.0,"grip":0.0};attack();update_action_animation(0.6)
	expect(hood.is_empty() and ammo==2,"pistol consumes ammo and kills clinger")
	glass_hp=100;add_blood();wipe_time=0;wipe();update_wipers(0.7)
	expect(blood.is_empty() or int(blood[-1].frame)>0,"wipers advance blood clearing stages")
	var rp_before=progress.rp
	expect(not buy_upgrade(4) and progress.rp==rp_before,"unaffordable upgrade rejected")
	progress.rp=1000;expect(buy_upgrade(4),"upgrade purchase")
	expect(progress.rp==750 and progress.upgrades[4]==1,"upgrade exact source cost")
	mode="story";start_run();position_z=LENGTHS[0]+LENGTHS[1]+1;update_progression();update_progression()
	expect(progress.checkpoint==2,"checkpoint progression")
	health=0;finish_run("test")
	var rp_once=progress.rp;finish_run("test twice")
	expect(progress.rp==rp_once,"RP awarded only once")
	mode="police";start_run();progress.upgrades=[3,3,3,3,3,3,3,3]
	for tick in range(60*150):
		if state!="play":start_run()
		simulate(1.0/60,1.0,false,false,sin(tick/70.0))
		health=100;car_hp=100
		if tick%180==0:attack_time=0;attack()
		expect(entities.size()<450,"bounded entity pool")
		if not test_errors.is_empty():break
	# Real native save round trip, isolated from the player's progress file.
	var cfg=ConfigFile.new()
	cfg.set_value("test","rp",123);cfg.set_value("test","upgrades",[0,1,2,3])
	expect(cfg.save("user://port_validation.tmp")==OK,"local save write")
	var reread=ConfigFile.new()
	expect(reread.load("user://port_validation.tmp")==OK and reread.get_value("test","rp")==123,"local save read")
	DirAccess.remove_absolute("user://port_validation.tmp")
	var saved=Progress.new()
	saved.save_path="user://port_validation_progress.cfg";saved.rp=351;saved.checkpoint=6
	expect(saved.save(),"atomic initial save")
	saved.rp=707
	expect(saved.save(),"atomic save replacement")
	var restored=Progress.new();restored.save_path=saved.save_path;restored.read_save()
	expect(restored.rp==707 and restored.checkpoint==6,"progress save round trip")
	DirAccess.remove_absolute(saved.save_path);DirAccess.remove_absolute(saved.save_path+".bak")
	# Traverse every campaign transition and the escape result.
	mode="story";progress.checkpoint=0;start_run()
	for index in range(22):
		position_z=segment_start+LENGTHS[segment]+0.01
		update_progression()
	expect(state=="results" and progress.finished,"all campaign segments can finish")
	# Validate end states, consumable hazards and clean mode resets.
	mode="time";start_run();time_left=0.001;simulate(0.1,0,false,false,0)
	expect(state=="results","timed mode ends")
	mode="story";start_run();segment=20;nuke_time=0.001;simulate(0.1,0,false,false,0)
	expect(state=="results","nuclear timeout ends")
	mode="story";progress.checkpoint=0;start_run();car_hp=15;fire_started=true;simulate(0.1,0,true,false,0)
	expect(fire_started,"braking does not extinguish engine fire")
	var spike=spawn_entity("spikes",0,position_z);collide(spike)
	var expected_spike_damage=float([4.0,2.0,1.0,0.5][clampi(int(progress.upgrades[6]),0,3)])
	expect(is_equal_approx(tire_damage,expected_spike_damage),"spike strip uses source fractional tire damage")
	var water=spawn_entity("water",0,position_z);car_hp=15;fire_started=true;collide(water)
	expect(car_hp==35 and not fire_started and cooled,"water restores the original smoking engine damage stage")
	var cooled_hp=car_hp;simulate(0.2,0,false,false,0)
	expect(not fire_started and car_hp==cooled_hp,"cooled engine stays extinguished")
	armor_level=3;car_hp=1;damage_car(100)
	expect(armor_level==0 and car_hp==100,"armor breaks away to expose undamaged hood")
	expect(progress.upgrades[5]==3,"run damage does not erase purchased upgrades")
	car_hp=21;damage_car(10,20)
	expect(car_hp==20,"humanoid impact cannot push hood below its source damage floor")
	for hp_frame in [[100,0],[99,1],[80,2],[55,3],[27,4]]:
		glass_hp=hp_frame[0];expect(windshield_frame()==hp_frame[1],"windshield fixed damage state")
	glass_hp=0;glass_break_time=1;expect(windshield_frame()==30,"broken glass reaches empty final frame")
	hood={"kind":"male","hp":50.0,"anim":"Idle","grip":0.0}
	progress.upgrades[2]=1;ammo=3;attack_time=0;attack()
	update_action_animation(0.5);expect(ammo==3,"shot waits for muzzle event")
	update_action_animation(0.1);expect(ammo==2,"shot fires at source frame 67")
	print("SELF_TEST: ", "PASS" if test_errors.is_empty() else "FAIL", " patterns=",patterns.size()," frames=",art.groups.size()," simulation_seconds=150 errors=",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func enter_garage():
	drive_requested=false
	art.prepare_garage()
	clear_original_tutorial();abort_confirm=false
	garage_upgrade_anim=-1;garage_upgrade_time=0
	death_explosion=false;crash_texture=null;crash_page=-1
	stop_horn();wiper_pressed=false
	native_scenes.prepare_frames("garage_body",1)
	state="garage";ui_message_time=0;snd.stop_action();snd.pause_all(false);snd.set_music("Music_GarageMusic")
	garage_head_time=0;garage_head_anim="idle";garage_body_time=0
	garage_chatter_timer=0;garage_chatter_delay=rng.randf_range(8,16)
	var cause=pending_death_cause
	pending_death_cause=""
	# First story visit takes precedence, matching RDGameModeGarage.BeginGameMode.
	if not progress.settings.garage_seen and mode=="story":
		snd.speak("PlayerFirstTimeInGarage",true)
		progress.settings.garage_seen=true;progress.save()
	elif DEATH_DIALOGUES.has(cause):
		snd.speak(next_death_dialogue(cause),true)

func next_death_dialogue(cause: String) -> String:
	if not DEATH_DIALOGUES.has(cause):return ""
	var bag: Array=death_dialogue_bags.get(cause,[])
	if bag.is_empty():
		for i in range(1,int(DEATH_DIALOGUES[cause])+1):
			bag.append("PlayerDeath"+cause+str(i))
		bag.shuffle()
	var key: String=bag.pop_back()
	death_dialogue_bags[cause]=bag
	return key

func start_cinematic(name:String,next:String):
	if not native_scenes.has_clip(name):
		push_error("Missing native cinematic: "+name);return
	native_scenes.prepare_frames(name)
	state="cinematic";cinema_next=next;cinema_name=name;cinema_time=0
	cinema_canvas.clip_name=name;cinema_canvas.frame=0;cinema_canvas.queue_redraw();cinema_screen.show();cinema_overlay.show();cinema_overlay.queue_redraw()
	snd.stop_action();snd.music.stop()
	cinema.stream=load("res://assets/native_scene/"+name+".ogg")
	cinema.volume_db=(-8+linear_to_db(clampf(cinema_time/0.04,0.001,1))) if progress.settings.sound and not preview_mode else -80
	cinema.play()

func finish_cinematic():
	if state!="cinematic":return
	cinema.stop();cinema.stream=null;cinema_screen.hide();cinema_overlay.hide()
	if cinema_name=="intro":progress.settings.intro_seen=true;progress.save()
	snd.music_name=""
	if cinema_next=="garage":enter_garage()
	elif cinema_next=="menu":open_menu()
	else:state=cinema_next;snd.set_music("Music_GarageMusic")

func capture_fidelity():
	fidelity_suite=false
	var checks=["menu_enter","menu_settled","options","garage_stock","garage_motion","garage_upgraded","road_stock","hit_attach","steer_left","steer_right","road_armored","road_damaged","glass_cracked","glass_broken","punch","shoot","clinger","clinger_attack","fire","water","wall_left","wall_right","encounters","hidden_source","slideout_source","helicopter_source","jet_source"]
	for check in checks:
		match check:
			"menu_enter":state="menu";menu_time=0
			"menu_settled":menu_time=2;total_time=4
			"options":previous_state="menu";state="options";panel_anim=0.4
			"garage_stock":state="garage";progress.upgrades=[0,0,0,0,0,0,0,0]
			"garage_motion":garage_body_time=3.5;garage_head_anim="talk";garage_head_time=0.3
			"garage_upgraded":progress.upgrades=[3,3,3,3,3,3,3,3];garage_head_anim="blink";garage_head_time=0.1
			"road_stock":
				progress.upgrades=[0,0,0,0,0,0,0,0];start_run();speed=65;notice_time=0;subtitle_time=0
				spawn_entity("male",-2,15);spawn_entity("cars",4.3,30);spawn_entity("female",2.6,65)
			"hit_attach":
				start_run();entities.clear();impacts.clear();notice_time=0;subtitle_time=0;speed=90
				impacts.append({"kind":"male_FrontHit","time":0.18,"x":0.0,"height":1.8,"flip":false,"attached":true})
			"steer_left":steering=-1;gear_arm_frame=0
			"steer_right":steering=1;gear_arm_frame=0
			"road_armored":armor_level=3;car_hp=100;steering=0
			"road_damaged":car_hp=20
			"glass_cracked":glass_hp=50
			"glass_broken":glass_hp=0;glass_break_time=1
			"punch":glass_hp=100;attack_time=1;attack_kind="punch";attack_elapsed=16.0/30
			"shoot":attack_kind="shoot";attack_elapsed=17.0/30
			"clinger":attack_time=0;hood={"kind":"male","hp":50,"attack":0.0,"grip":0.0};hood_time=2
			"clinger_attack":hood.phase="attack";hood.anim_time=0.57
			"fire":hood.clear();armor_level=0;car_hp=10;fire_started=true;elapsed=2
			"water":collide(spawn_entity("water",0,position_z));notice_time=0
			"wall_left":start_run();speed=70;player_x=-9;wall_contact=-1;notice_time=0;subtitle_time=0
			"wall_right":player_x=9;wall_contact=1
			"encounters":
				start_run();speed=75;notice_time=0;subtitle_time=0
				spawn_entity("fence",-4,16);spawn_entity("electronic_sign",5,30);spawn_entity("shopping_cart",0,12)
				var operator=spawn_entity("soldier",6,20);operator.behavior="bomb";update_soldier(operator,20,0.1)
			"hidden_source":
				start_run();entities.clear();speed=0;notice_time=0;subtitle_time=0
				var hidden_actor=spawn_entity("soldier",-5,50);hidden_actor.behavior="hidden";hidden_actor.cover_x=-5;soldier_anim(hidden_actor,"Hidden")
			"slideout_source":
				start_run();entities.clear();speed=90;notice_time=0;subtitle_time=0
				var slide_actor=spawn_entity("soldier",-5,24);slide_actor.behavior="hidden";slide_actor.cover_x=-5
				slide_actor.revealed=true;slide_actor.slide_time=0.35;slide_actor.slide_target=-2;soldier_anim(slide_actor,"SlideOut")
			"helicopter_source":
				start_run();entities.clear();segment=16;chapter_index=8;notice_time=0;subtitle_time=0
				spawn_source_helicopter();helicopter.z=position_z+45;helicopter.x=2;helicopter.t=1.2
			"jet_source":
				start_run();entities.clear();segment=14;chapter_index=7;notice_time=0;subtitle_time=0
				spawn_source_jet();jet.z=position_z+70;jet.x=0;jet.t=0.5
		queue_redraw()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../analysis/fidelity_"+check+".png"))
		print("FIDELITY_CHECK: ",check)
	get_tree().quit()

func validate_cinematics():
	for name in ["intro","ending"]:
		expect(native_scenes.has_clip(name),"native timeline packaged: "+name)
		start_cinematic(name,"garage" if name=="intro" else "results")
		await get_tree().create_timer(3.0).timeout
		expect(state=="cinematic" and cinema_time>1.0 and cinema.playing,"native timeline and audio advance: "+name)
		cinema_time=40.0 if name=="intro" else 20.0
		cinema_canvas.frame=int(cinema_time*30);cinema_canvas.queue_redraw()
		queue_redraw();await RenderingServer.frame_post_draw
		var capture_dir=ProjectSettings.globalize_path("res://../analysis") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir().path_join("../analysis")
		expect(get_viewport().get_texture().get_image().save_png(capture_dir.path_join("native_cinema_"+name+".png"))==OK,"native cinematic screenshot saved")
		var perf_start=Time.get_ticks_msec()
		var perf_frames=0
		while Time.get_ticks_msec()-perf_start<5000:
			await get_tree().process_frame
			perf_frames+=1
		var perf_seconds=(Time.get_ticks_msec()-perf_start)/1000.0
		print("CINEMA_PERF: ",JSON.stringify({"clip":name,"average_fps":perf_frames/perf_seconds,"seconds":perf_seconds,"frames":perf_frames}))
		finish_cinematic()
		expect(state==("garage" if name=="intro" else "results"),"cinematic returns to correct screen")
	print("CINEMA_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func run_parity_checks():
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0]
	start_run();entities.clear();next_pattern=999999;air_delay=9999;speed=80
	for i in range(12):simulate(1.0/60,1,false,true,1)
	expect(player_x>0.45 and speed>75.0,"short handbrake turn moves sideways while retaining momentum")
	for i in range(90):simulate(1.0/60,1,false,true,-1)
	expect(speed<78,"held handbrake still loses speed")
	start_run();entities.clear();next_pattern=999999;speed=90
	var soldier=spawn_entity("soldier",0,20)
	for i in range(84):update_entities(1.0/60)
	expect(soldier.shots>=8,"soldier fires sustained rounds every 0.1 second")
	expect(glass_hp<100 and health==100,"windshield intercepts low damage rifle rounds")
	var shots_before=int(soldier.shots);var hp=health;glass_hp=0;player_x=6
	for i in range(60):update_entities(1.0/60)
	expect(soldier.shots>shots_before and health==hp,"soldier keeps firing but lateral evasion avoids hits")
	player_x=0
	for i in range(30):update_entities(1.0/60)
	expect(health>=80 and health<100,"rifle burst causes bounded body damage")
	start_run();entities.clear();glass_hp=0
	hood={"kind":"male","hp":50.0,"attack":0.0,"grip":0.0};attack_time=0
	attack();update_action_animation(0.6)
	expect(hood.hp==50 and attack_time==0,"unarmed attack leaves hood zombie untouched")
	attack_time=0;attack();update_action_animation(0.6)
	expect(hood.hp==50 and attack_time==0,"repeated unarmed attack cannot remove hood zombie")
	start_run();entities.clear();horn_time=1;player_x=0
	var civ=spawn_entity("civilian",2,18);civ.direction=-1
	update_entities(0.1)
	expect(civ.direction==1 and civ.x>2 and civ.z<18 and civ.flee,"civilian horn response runs away and advances toward camera")
	expect(native_scenes.count("garage_body")==260,"full garage body timeline is present")
	expect(native_scenes.count("intro")==3061,"complete live intro timeline is present")
	expect(native_scenes.count("ending")==2479,"complete live ending timeline is present")
	progress.settings.intro_seen=true;open_menu();activate("story")
	expect(pending_mode=="story" and state=="menu","normal selection asks where to start")
	confirm_mode("new")
	expect(state=="cinematic" and cinema is AudioStreamPlayer,"normal fresh start enters live cutscene even after prior viewing")
	finish_cinematic()
	expect(state=="garage","live intro skip enters garage")
	for side in [-1,1]:
		start_run();entities.clear();next_pattern=999999;air_delay=99999;player_x=-9.35 if side<0 else 9.05;speed=85;lateral=side*4
		simulate(0.1,1,false,false,side)
		expect(car_hp==100 and side_damage[0 if side<0 else 1]>0 and player_x>=-9.4 and player_x<=9.1,"wall clamps at source limits and damages its side "+str(side))
		var after_impact=float(side_damage[0 if side<0 else 1])
		for i in range(60):simulate(1.0/60,1,false,false,side)
		expect(side_damage[0 if side<0 else 1]>after_impact+2 and car_hp==100,"sustained scrape damages side without bumper or speed penalty")
		var leave_hp=car_hp;player_x=0;lateral=0;simulate(0.1,0,false,false,0)
		expect(car_hp==leave_hp and wall_contact==0,"wall damage stops after leaving contact")
	var pivot=art.cockpit_map(Vector2(328.86,575.82))
	var point=art.cockpit_map(Vector2(420,410))
	var rotated=Transform2D(deg_to_rad(25),pivot)*Transform2D(0,-pivot)
	expect(absf((point-pivot).length()-(rotated*point-pivot).length())<0.01,"steering preserves the original circular wheel and hand geometry")

	start_run();entities.clear();speed=90;player_x=0
	var hidden_soldier=spawn_entity("soldier",-6,20);hidden_soldier.behavior="hidden";hidden_soldier.cover_x=-6
	update_entities(0.1);expect(hidden_soldier.anim=="soldier_SlideOut" and hidden_soldier.shots==0,"hidden soldier plays slide before firing")
	for i in range(90):update_entities(1.0/60)
	expect(hidden_soldier.anim=="soldier_SlideFire" and hidden_soldier.shots>0,"hidden soldier transitions to sustained slide-fire")
	entities.clear()
	var operator=spawn_entity("soldier",-7,20);operator.behavior="spikes"
	var strip=spawn_entity("spikes",5,20);operator.strip=strip
	for i in range(10):
		if operator.get("trigger_started",false):break
		update_entities(1.0/60)
	expect(operator.anim=="soldier_PullSpikeStrip" and not strip.has("pull_target"),"spike operator starts authored trigger animation")
	for i in range(50):update_entities(1.0/60)
	expect(strip.has("pull_target") and strip.x<5,"spikes move only after the trigger animation event")
	entities.clear();effects.clear()
	var bomber=spawn_entity("soldier",7,40);bomber.behavior="bomb"
	for i in range(150):update_entities(1.0/60)
	expect(int(bomber.bomb_index)==7 and effects.size()==7,"explosives detonate in seven timed stages")
	start_run();entities.clear();effects.clear();speed=90;next_pattern=999999;air_delay=99999
	var moving_bomber=spawn_entity("soldier",7,40);moving_bomber.behavior="bomb"
	for i in range(180):simulate(1.0/60,1,false,false,0)
	expect(int(moving_bomber.get("bomb_index",0))==7,"bomb sequence completes after the car passes its operator")
	# Release 19 source-parity checks: hidden rifle damage, hazards, ambient cars and independent air entities.
	start_run();entities.clear();progress.upgrades=[0,0,0,0,0,0,0,0];speed=110;glass_hp=100;player_x=0
	var hidden_damage=spawn_entity("soldier",0,10);hidden_damage.behavior="hidden";hidden_damage.revealed=true
	hidden_damage["soldier_state"]="SlideFire";hidden_damage.anim="soldier_SlideFire";hidden_damage.fire_timer=0.0
	update_soldier(hidden_damage,10,0.11)
	expect(glass_hp==96,"hidden slide-out soldier uses source 4 windshield damage")
	start_run();entities.clear();progress.upgrades[6]=3
	var oil_test=spawn_entity("oil",0,position_z);collide(oil_test)
	expect(is_equal_approx(oil_duration,2.5) and is_equal_approx(oil_factor,1.0),"level-3 tires use source 2.5 second oil duration")
	var oil_before=oil_factor;simulate(0.5,0,false,false,0)
	expect(oil_factor<oil_before and oil_factor>0,"oil control factor decays with source power curve")
	var spike_a=spawn_entity("spikes",0,position_z);collide(spike_a)
	expect(is_equal_approx(tire_damage,0.5) and tires==0,"level-3 tires accumulate fractional spike damage")
	var spike_b=spawn_entity("spikes",0,position_z);collide(spike_b)
	expect(is_equal_approx(tire_damage,1.0) and tires==1,"fractional spike damage eventually blows a tire")
	expect(String(art.world_data.get("vehicle_ambient19",{}).get("0",""))=="BurningCar","burning-car source ambient mapping")
	expect(String(art.world_data.get("vehicle_ambient19",{}).get("30",""))=="PoliceSiren","police-car source siren mapping")
	start_run();entities.clear();segment=16;chapter_index=8;post_checkpoint_pending=false;speed=100;helicopter.clear();jet.clear();air_delay=99999
	spawn_source_helicopter()
	expect(int(helicopter.hp)==3 and bool(helicopter.can_missiles) and is_equal_approx(float(helicopter.z),position_z-400.0),"source helicopter spawns 400 behind with 3 HP and missiles at level 16")
	helicopter.z=position_z+20;helicopter.x=0.0;player_x=0;glass_hp=100;helicopter.firing=true
	helicopter.fire_phase_timer=0.0;helicopter.fire_phase_duration=99.0;helicopter.can_missiles=false;helicopter.bullet_timer=0.0
	update_source_helicopter(0.11)
	expect(glass_hp==97,"helicopter machine gun uses source 3 windshield damage")
	helicopter.can_missiles=true;helicopter.missile_mode=true;helicopter.switch_timer=0.0;helicopter.missile_timer=3.5;helicopter.missile_delay=3.0;helicopter.missiles.clear()
	update_source_helicopter(0.01)
	expect(helicopter.missiles.size()==1,"helicopter launches source-seeking missile")
	start_run();entities.clear();segment=14;chapter_index=7;speed=0;player_x=-5;jet.clear();helicopter.clear();air_delay=99999
	spawn_source_jet()
	expect(int(jet.total_drops)==1 and is_equal_approx(float(jet.z),position_z-400.0),"source jet level 14 starts one-drop run 400 behind")
	jet.phase="return";jet.z=position_z+50;jet.x=5.0;jet.return_sound=false;jet.bombs_dropped=false
	update_source_jet(0.01)
	expect(jet.bombs.size()==8,"jet drops original eight-bomb pattern")
	var dodge_before=air_dodges
	for i in range(270):update_source_jet(1.0/60.0)
	expect(air_dodges>dodge_before and String(jet.get("phase",""))=="done","missed jet bomb run awards dodge and leaves after final pass")
	for key in ["box","construction_sign","electronic_sign","fence","shopping_cart"]:
		expect(not art.world_frame(key,0).is_empty(),"original roadside prop present: "+key)
	expect(art.world_data.get("groups",{}).get("rocket19",[]).size()==44,"original 44-frame helicopter rocket timeline packaged")
	print("PARITY_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func capture_ui05(name: String, mouse: Vector2):
	check_mouse=mouse
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var base=ProjectSettings.globalize_path("res://../analysis/")
	if not OS.has_feature("editor"):base=OS.get_executable_path().get_base_dir()+"/../analysis/"
	get_viewport().get_texture().get_image().save_png(base+"ui05_"+name+".png")

func run_ui_audio_checks():
	preview_mode=true
	AudioServer.set_bus_volume_db(0,-80)
	snd.stop_action()
	snd.music.stop()
	state="garage"
	progress.upgrades=[0,0,0,0,0,0,0,0]
	progress.rp=20000
	progress.rp=0
	await capture_ui05("garage_reference",Vector2(500,450))
	for category in range(8):
		for level in range(3):
			progress.upgrades[category]=level
			await capture_ui05("info_%d_%d"%[category,level],Vector2(860,30+category*47))
		progress.upgrades[category]=0
	progress.rp=20000
	await capture_ui05("garage_stock",Vector2(860,80))
	# Exercise actual mouse routing for all eight rows and all three purchase levels.
	var names=["Perception","BodyArmor","Firearm","Windshield","Engine","Bumper","Tires","Horn"]
	for i in range(8):
		var raw=art.menu_data.buttons["garage_"+names[i]+"Button"].rect
		var pos=Vector2(raw[0]+12,raw[1]+raw[3]/2)
		for level in range(3):
			var before=int(progress.rp)
			var event=InputEventMouseButton.new()
			event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;event.position=pos+UI_OFFSET
			_input(event)
			if int(progress.upgrades[i])!=level+1 or int(progress.rp)!=before-int(COSTS[i][level]):
				test_errors.append("Upgrade row %d level %d mouse routing / cost"%[i,level])
		var capped_rp=progress.rp
		buy_upgrade(i)
		if progress.upgrades[i]!=3 or progress.rp!=capped_rp:test_errors.append("Max-level purchase charged RP")
	progress.upgrades[0]=0;progress.rp=0
	if buy_upgrade(0) or progress.upgrades[0]!=0 or progress.rp!=0:test_errors.append("Unaffordable purchase changed progress")
	await capture_ui05("garage_insufficient",Vector2(860,30))
	progress.upgrades[0]=3;progress.rp=500
	ui_message_time=0
	await capture_ui05("garage_max",Vector2(860,30))
	await capture_ui05("garage_back",Vector2(120,680))
	var back_event=InputEventMouseButton.new()
	back_event.button_index=MOUSE_BUTTON_LEFT;back_event.pressed=true;back_event.position=Vector2(120,680)+UI_OFFSET
	_input(back_event)
	if state!="menu":test_errors.append("Garage back navigation failed")
	await capture_ui05("menu_default",Vector2(5,300))
	for pair in [["story","StoryMode"],["police","MilitaryMode"],["time","TimeMode"],["options","Options"],["locked","StoryHardcoreMode"]]:
		var rr=art.menu_data.buttons[pair[1]].rect
		await capture_ui05("menu_"+pair[0],Vector2(rr[0]+rr[2]/2,rr[1]+rr[3]/2))
	# Real AudioStreamPlayer completion signals, including queued legacy interrupt calls.
	var events:Array=[]
	snd.voice_started.connect(func(key,caption,_duration):
		events.append({"event":"start","key":key,"caption":caption,"t":Time.get_ticks_msec()})
		if subtitle!=caption:test_errors.append("Caption did not follow actual voice start")
	)
	snd.voice_finished.connect(func(key):
		if not key.is_empty():events.append({"event":"end","key":key,"t":Time.get_ticks_msec()})
	)
	snd.silent=false;snd.enabled=true
	snd.speak("UpgradePerception",false,"First line")
	snd.speak("ErrorSound",true,"Second line")
	snd.speak("UpgradeTire",true,"Third line")
	if snd.voice_queue.size()!=2:test_errors.append("Dialogue dropped or interrupted")
	var deadline=Time.get_ticks_msec()+30000
	while events.size()<2 and Time.get_ticks_msec()<deadline:await get_tree().process_frame
	snd.pause_all(true)
	var gap=snd.voice_gap_left
	await get_tree().create_timer(0.7).timeout
	if events.size()!=2 or not is_equal_approx(gap,snd.voice_gap_left):test_errors.append("Voice gap advanced while paused")
	snd.pause_all(false)
	while events.size()<6 and Time.get_ticks_msec()<deadline:await get_tree().process_frame
	if events.size()!=6:
		test_errors.append("Dialogue queue did not play all three lines")
	else:
		for i in [0,2,4]:
			if events[i].event!="start" or events[i+1].event!="end" or events[i].key!=events[i+1].key:test_errors.append("Voice overlap / ordering")
		for i in [2,4]:
			if int(events[i].t)-int(events[i-1].t)<2450:test_errors.append("Radio gap shorter than 2.5 seconds")
	snd.speak("ErrorSound",false,"Cancel on scene change")
	snd.stop_action()
	if snd.voice.playing or not snd.voice_queue.is_empty() or subtitle_time>0:test_errors.append("Scene change leaked voice or caption")
	await check_garage_purchase_audio()
	print("UI_AUDIO_EVENTS: ",JSON.stringify(events))
	print("UI_AUDIO_CHECK: ","PASS" if test_errors.is_empty() else "FAIL "+str(test_errors))
	get_tree().quit(0 if test_errors.is_empty() else 1)

func check_garage_purchase_audio():
	state="garage"
	snd.stop_action();snd.pause_all(false);snd.silent=false;snd.enabled=true
	garage_chatter_delay=999;garage_chatter_timer=0;garage_blink_delay=999;garage_blink_timer=0
	progress.rp=100000;progress.upgrades=[0,0,0,0,0,0,0,0]
	var names=["Perception","BodyArmor","Firearm","Windshield","Engine","Bumper","Tires","Horn"]
	for i in range(8):
		for level in range(3):
			buy_upgrade(i)
			var expected="PlayerUpgrade"+names[i]+str(level+1)
			if snd.voice_key!=expected or not snd.voice.playing:test_errors.append("Purchase voice failed: "+expected)
			if snd.stream(expected)==null or snd.stream(expected).get_length()<0.1:test_errors.append("Invalid purchase clip: "+expected)
			if not snd.voice_envelopes.has(expected):test_errors.append("Missing speech envelope: "+expected)
			if not snd.voice_queue.is_empty():test_errors.append("Stale garage reaction queued")
			await get_tree().process_frame
	# Watch a real purchase clip complete, sampling rendered mouth poses along with playback.
	snd.stop_action();progress.upgrades[0]=0
	buy_upgrade(0)
	var poses={}
	var deadline=Time.get_ticks_msec()+6000
	while not snd.voice_key.is_empty() and Time.get_ticks_msec()<deadline:
		var frame=garage_head_frame()
		var pose=int(native_scenes.clip("Head").sequence[frame])
		if not poses.has(pose):
			poses[pose]=true
			await capture_ui05("john_speech_pose_"+str(pose),Vector2(500,450))
		await get_tree().process_frame
	if poses.size()<3:test_errors.append("John mouth did not animate during his purchase line")
	await get_tree().process_frame
	if garage_head_frame()!=0:test_errors.append("John continued talking after the clip ended")
	# A current radio line keeps playing, then the latest purchase is next after the radio gap.
	snd.stop_action();progress.upgrades[0]=0
	var times={}
	snd.voice_finished.connect(func(key):
		if key=="GarageChatter01":times["radio_end"]=Time.get_ticks_msec()
	)
	snd.voice_started.connect(func(key,_caption,_duration):
		if key=="PlayerUpgradePerception2":times["purchase_start"]=Time.get_ticks_msec()
	)
	snd.speak("GarageChatter01")
	buy_upgrade(0);buy_upgrade(0)
	if snd.voice_key!="GarageChatter01":test_errors.append("Garage purchase interrupted radio")
	if snd.voice_queue.size()!=1 or snd.voice_queue[0].key!="PlayerUpgradePerception2":test_errors.append("Queued garage reaction is stale")
	if garage_head_frame()!=0:test_errors.append("John mouths the radio instead of his own voice")
	deadline=Time.get_ticks_msec()+45000
	while not times.has("purchase_start") and Time.get_ticks_msec()<deadline:await get_tree().process_frame
	if not times.has("radio_end") or not times.has("purchase_start"):
		test_errors.append("Purchase reaction never followed radio")
	elif int(times.purchase_start)-int(times.radio_end)<2450:
		test_errors.append("Garage radio gap was lost")
	snd.stop_action()
	print("GARAGE_SPEECH_CHECK: poses=",poses.keys()," radio=",JSON.stringify(times)," errors=",test_errors)

func campaign_checkpoint(selected_mode: String) -> int:
	if selected_mode=="story":return int(progress.checkpoint)
	if selected_mode=="hardcore":return int(progress.hardcore_checkpoint)
	return 0

func confirm_mode(choice: String):
	if pending_mode.is_empty():return
	if choice=="cancel":
		pending_mode="";queue_redraw();return
	var campaign=pending_mode in ["story","hardcore"]
	if choice=="resume" and (not campaign or campaign_checkpoint(pending_mode)==0):return
	if choice not in ["new","resume","yes"]:return
	mode=pending_mode;pending_mode=""
	snd.play("UpgradePerception",-8)
	if campaign and choice=="new":
		if mode=="story":progress.checkpoint=0
		else:progress.hardcore_checkpoint=0
		progress.settings.garage_seen=false
		progress.save()
		start_cinematic("intro","garage")
	else:enter_garage()
	queue_redraw()

func draw_source_confirmation(message:String):
	buttons.clear()
	draw_rect(Rect2(-UI_OFFSET.x,0,RW,H),Color(0,0,0,0.65))
	art.draw_menu(self,"confirm_background")
	draw_wrapped_text(message,Rect2(193,122,694,73),25,Color.WHITE,art.menu_font,true)

func draw_start_confirmation():
	var campaign=pending_mode in ["story","hardcore"]
	var title="The Great Escape" if pending_mode=="story" else "Highway To Hell"
	var message="Where do you wanna start\n"+title+"?" if campaign else "It's recommended to play The Great Escape first.\nAre you sure you want to continue?"
	draw_source_confirmation(message)
	if campaign:
		flash_button("confirm_NewButton","confirm_new")
		flash_button("confirm_ResumeButton","confirm_resume",campaign_checkpoint(pending_mode)>0)
	else:
		flash_button("confirm_YesButton","confirm_yes")
		flash_button("confirm_NoButton","confirm_cancel")

func draw_cinema_overlay():
	if state!="cinematic":return
	var info:Dictionary=art.menu_data.buttons.cinema_skip
	var r=info.rect
	var rect=Rect2(r[0],r[1],r[2],r[3])
	var hover=rect.has_point(check_mouse if ui_audio_check else get_global_mouse_position()-UI_OFFSET)
	var key="down" if hover and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else ("over" if hover else "up")
	art.draw_menu(cinema_overlay,info[key])

func frontend_capture(name: String):
	queue_redraw();cinema_overlay.queue_redraw()
	await RenderingServer.frame_post_draw
	var base=ProjectSettings.globalize_path("res://../analysis/")
	if not OS.has_feature("editor"):base=OS.get_executable_path().get_base_dir()+"/../analysis/"
	expect(get_viewport().get_texture().get_image().save_png(base+"frontend08_"+name+".png")==OK,"frontend screenshot "+name)

func frontend_click(id: String):
	queue_redraw()
	await RenderingServer.frame_post_draw
	var found=false
	for b in buttons:
		if b.id==id:
			var event=InputEventMouseButton.new()
			event.button_index=MOUSE_BUTTON_LEFT;event.pressed=true;event.position=b.rect.get_center()+UI_OFFSET
			_input(event);found=true;break
	expect(found,"clickable "+id)

func run_frontend_checks():
	ui_audio_check=true
	AudioServer.set_bus_volume_db(0,-80)
	progress.finished=true;progress.checkpoint=6;progress.hardcore_checkpoint=10;progress.rp=5000
	progress.upgrades=[1,1,1,1,1,1,1,1]
	menu_time=2
	activate("story")
	expect(state=="menu" and pending_mode=="story","mode opens confirmation")
	await frontend_capture("story_prompt")
	var escape=InputEventKey.new();escape.physical_keycode=KEY_ESCAPE;escape.pressed=true
	_input(escape)
	expect(pending_mode.is_empty() and progress.checkpoint==6,"escape cancels without resetting")
	activate("story");await frontend_click("confirm_resume");start_run()
	expect(segment==6 and mode=="story","normal resumes its own checkpoint")
	open_menu();activate("hardcore")
	await frontend_capture("hardcore_prompt")
	await frontend_click("confirm_resume");start_run()
	expect(segment==10 and mode=="hardcore","hardcore resumes its own checkpoint")
	segment=11;segment_start=segment_position(11);position_z=segment_start+LENGTHS[11]+1;update_progression()
	expect(progress.hardcore_checkpoint==12 and progress.checkpoint==6,"hardcore checkpoint saves independently")
	open_menu();activate("story");await frontend_click("confirm_new")
	expect(state=="cinematic" and progress.checkpoint==0 and progress.hardcore_checkpoint==12,"beginning resets only selected checkpoint")
	expect(progress.rp==5000 and progress.upgrades==[1,1,1,1,1,1,1,1],"beginning preserves upgrades and RP")
	var outside=InputEventMouseButton.new();outside.button_index=MOUSE_BUTTON_LEFT;outside.pressed=true;outside.position=Vector2(400,300)
	await get_tree().process_frame
	_input(outside)
	expect(state=="cinematic","clicking scenery does not skip")
	preview_mode=true;cinema_time=40;cinema_canvas.frame=1200;cinema_canvas.queue_redraw()
	await frontend_capture("intro_skip")
	preview_mode=false
	await frontend_click("cinema_skip")
	expect(state=="garage" and not cinema.playing and not cinema_overlay.visible,"intro skip stops audio and opens garage")
	start_cinematic("ending","results")
	await frontend_click("cinema_skip")
	expect(state=="results" and not cinema.playing,"ending skip opens results")
	open_menu();activate("story")
	await frontend_capture("no_checkpoint")
	await get_tree().process_frame
	expect(not buttons.any(func(b):return b.id=="confirm_resume"),"resume disabled without checkpoint")
	confirm_mode("resume");expect(pending_mode=="story","missing checkpoint cannot resume")
	confirm_mode("cancel")
	for challenge in ["time","police"]:
		activate(challenge);await frontend_capture(challenge+"_prompt")
		await frontend_click("confirm_cancel")
		expect(state=="menu" and pending_mode.is_empty(),"challenge cancel")
		activate(challenge);await frontend_click("confirm_yes")
		expect(state=="garage" and mode==challenge,"challenge confirmation")
		open_menu()
	var saved=Progress.new();saved.save_path="user://frontend08_progress.cfg"
	saved.checkpoint=4;saved.hardcore_checkpoint=16;saved.rp=123
	expect(saved.save(),"checkpoint save")
	var restored=Progress.new();restored.save_path=saved.save_path;restored.read_save()
	expect(restored.checkpoint==4 and restored.hardcore_checkpoint==16 and restored.rp==123,"both checkpoints persist")
	var legacy=ConfigFile.new();legacy.set_value("progress","checkpoint",8);legacy.save(saved.save_path)
	restored=Progress.new();restored.save_path=saved.save_path;restored.read_save()
	expect(restored.checkpoint==8 and restored.hardcore_checkpoint==0,"old saves migrate safely")
	DirAccess.remove_absolute(saved.save_path)
	if FileAccess.file_exists(saved.save_path+".bak"):DirAccess.remove_absolute(saved.save_path+".bak")
	snd.silent=false;snd.enabled=true
	snd.update_menu_ambience(0,true);snd.menu_ambient_delay=0;snd.update_menu_ambience(0,true)
	var ambient_key=snd.menu_ambient_key
	expect(snd.menu_ambient.playing and "ZombieMoan" in ambient_key,"original zombie ambience plays")
	expect(snd.menu_ambient_bag.size()==20,"all 21 original moans in shuffle bag")
	snd.update_menu_ambience(10,true)
	expect(snd.menu_ambient_key==ambient_key,"ambient clips never overlap")
	snd.menu_ambient.stop();snd.menu_ambient.finished.emit()
	expect(snd.menu_ambient_delay>=5 and snd.menu_ambient_delay<=10,"original 5-10 second gap")
	snd.update_menu_ambience(0,false)
	expect(not snd.menu_ambient.playing,"ambience stops on menu exit")
	snd.update_menu_ambience(0,true);snd.menu_ambient_delay=0;snd.update_menu_ambience(0,true)
	snd.enabled=false;snd.update_menu_ambience(0,true)
	expect(not snd.menu_ambient.playing,"sound off mutes ambience")
	snd.enabled=true;snd.play("UpgradePerception")
	expect(snd.ui_effect.playing and snd.ui_effect.volume_db<=-14,"interface effect uses bounded single channel")
	snd.speak("PlayerUpgradeHorn1")
	expect(snd.voice.volume_db<=-6 and snd.voice_target_db<=-6,"voice has mix headroom")
	expect(snd.music_gain==-13 and AudioServer.get_bus_effect(0,0) is AudioEffectHardLimiter,"balanced music and clean peak protection")
	snd.update_engine(0,true,false)
	expect(is_equal_approx(snd.engine.volume_db,-14),"engine has mix headroom")
	snd.stop_action();snd.silent=true
	enter_garage();selected_upgrade=4;ui_message_time=0
	expect(buy_upgrade(4) and ui_message_time==0,"purchase has no extra message")
	check_mouse=Vector2(950,220)
	await frontend_capture("garage_purchase")
	progress.rp=0
	expect(not buy_upgrade(4) and ui_message_time==0,"insufficient RP has no extra message")
	progress.upgrades[4]=3
	expect(not buy_upgrade(4) and ui_message_time==0,"max upgrade has no extra message")
	print("FRONTEND_CHECK: ","PASS" if test_errors.is_empty() else "FAIL", " ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

var mix_capture_before: AudioEffectCapture
var mix_capture_after: AudioEffectCapture
var mix_reports:Array=[]

func measure_mix09(label_name: String, seconds: float, spam: bool=false):
	mix_capture_before.clear_buffer();mix_capture_after.clear_buffer()
	var peaks=Vector2.ZERO
	var squared=0.0
	var samples=0
	var clipped=0
	var spam_count=0
	var max_effects=0
	var start=Time.get_ticks_msec()
	var next_click=start
	while Time.get_ticks_msec()-start<seconds*1000:
		if spam and Time.get_ticks_msec()>=next_click:
			buy_upgrade(spam_count%8);spam_count+=1;next_click+=40
		for j in range(2):
			var capture=mix_capture_before if j==0 else mix_capture_after
			var frames=capture.get_buffer(capture.get_frames_available())
			for sample in frames:
				var peak=maxf(absf(sample.x),absf(sample.y))
				peaks[j]=maxf(peaks[j],peak)
				if j==0:
					squared+=sample.length_squared()
					samples+=2
					if peak>=0.999:clipped+=1
		var active=0
		for player in snd.effects:
			if player.playing:active+=1
		max_effects=maxi(max_effects,active)
		await get_tree().process_frame
	var report={"scenario":label_name,"pre_limiter_peak":peaks.x,"output_peak":peaks.y,"rms":sqrt(squared/maxi(1,samples)),"samples":samples,"full_scale_frames":clipped,"spam_clicks":spam_count,"pooled_effects":max_effects}
	mix_reports.append(report)
	expect(samples>1000 and peaks.x>0.0001,"actual audible samples captured: "+label_name)
	expect(peaks.x<0.90 and clipped==0,"mix has headroom without limiter distortion: "+label_name)
	expect(peaks.y<0.85,"bounded output: "+label_name)
	if spam:
		expect(spam_count>=50 and max_effects==0,"upgrade spam stays out of polyphonic effects pool")
	print("MIX09 ",JSON.stringify(report))

func run_mix_checks():
	# Capture before/after the limiter; the master fader mutes the verification run.
	AudioServer.set_bus_volume_db(0,-80)
	mix_capture_before=AudioEffectCapture.new();mix_capture_before.buffer_length=2
	mix_capture_after=AudioEffectCapture.new();mix_capture_after.buffer_length=2
	AudioServer.add_bus_effect(0,mix_capture_before,0)
	AudioServer.add_bus_effect(0,mix_capture_after)
	snd.silent=false;snd.enabled=true;progress.settings.sound=true
	progress.settings.music=true;snd.music_enabled=true;snd.music_name=""
	progress.settings.garage_seen=false
	enter_garage()
	await measure_mix09("garage_entry",3)
	snd.stop_action();progress.rp=100000;progress.upgrades=[0,0,0,0,0,0,0,0]
	await measure_mix09("rapid_upgrade_clicks",3.2,true)
	expect(progress.upgrades==[3,3,3,3,3,3,3,3],"all valid spam purchases still apply")
	expect(snd.ui_effect.playing and snd.ui_effect.volume_db<=-14,"single quiet feedback channel")
	snd.stop_action()
	expect(not snd.ui_effect.playing and snd.voice_queue.is_empty(),"scene change stops interface and voice")
	start_cinematic("intro","garage")
	await measure_mix09("intro_entry_and_flash",4.8)
	expect(cinema_time>4 and cinema_time<6,"cinematic audio clock advances in real time")
	expect(cinema.volume_db<=-8,"cinematic audio headroom")
	finish_cinematic()
	expect(not cinema.playing,"skip stops soundtrack")
	open_menu();snd.music_name="";snd.set_music("Music_MenuMusic")
	snd.update_menu_ambience(0,true);snd.menu_ambient_delay=0;snd.update_menu_ambience(0,true)
	await measure_mix09("menu_zombies",1.5)
	snd.stop_action();snd.music.stop();snd.silent=true
	preview_mode=true;set_process(false)
	start_cinematic("intro","garage");cinema.stop()
	for frame in [0,5,10,19]:
		cinema_time=float(frame)/30;cinema_canvas.frame=frame;cinema_canvas.queue_redraw()
		await frontend_capture("flash09_"+str(frame))
		var clip_data=native_scenes.clip("intro")
		var commands=clip_data.frames[int(clip_data.sequence[frame])]
		var whites=commands.filter(func(c):return c[0]==-2 and c[1]=="#ffffff")
		expect(whites.size()==1,"one authored flash overlay")
		var expected={0:1.0,5:0.73828125,10:0.47265625,19:0.0}
		if whites.size()==1:expect(is_equal_approx(float(whites[0][3][3]),expected[frame]),"original SWF fade alpha at "+str(frame))
	expect(native_scenes.count("intro")==3061 and native_scenes.count("ending")==2479,"transition fix preserves scene/audio duration")
	finish_cinematic()
	var base=ProjectSettings.globalize_path("res://../analysis/")
	if not OS.has_feature("editor"):base=OS.get_executable_path().get_base_dir()+"/../analysis/"
	var file=FileAccess.open(base+"mix09_report.json",FileAccess.WRITE)
	if file:file.store_string(JSON.stringify(mix_reports,"  "))
	print("MIX_CHECK: ","PASS" if test_errors.is_empty() else "FAIL", " ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func run_death_dialogue_checks():
	ui_audio_check=true;preview_mode=true
	AudioServer.set_bus_volume_db(0,-80)
	snd.silent=false;snd.enabled=true
	progress.settings.garage_seen=true;progress.upgrades=[0,0,0,0,0,0,0,0]
	mode="story";progress.checkpoint=0
	for cause in DEATH_DIALOGUES:
		var seen: Array=[]
		for i in range(int(DEATH_DIALOGUES[cause])):
			var key=next_death_dialogue(cause)
			expect(not key in seen,"reaction bag avoids duplicates: "+cause)
			seen.append(key)
			expect(snd.stream(key)!=null and snd.voice_envelopes.has(key),"original clip and mouth envelope: "+key)
	death_dialogue_bags.clear()
	var cases=["wall","car","zombie","soldier","hood_soldier","bomb","helicopter","jet","nuke"]
	var expected=["Crash","Crash","Zombie","Military","Military","Military","Helicopter","Jet","Nuke"]
	for i in range(cases.size()):
		start_run();entities.clear();next_pattern=1e9;air_delay=999
		var scenario=cases[i]
		match scenario:
			"wall":
				car_hp=1;speed=90;player_x=9.1;lateral=5;damage_car(2,0,false)
			"car":
				car_hp=1;speed=110
				collide({"kind":"cars","x":0.0})
			"zombie","hood_soldier":
				health=1;glass_hp=0;hood_time=5
				hood={"kind":"male" if scenario=="zombie" else "soldier","grip":0.0,"anim":"Inside" if scenario=="zombie" else "Attack","anim_time":0.0,"hit_index":0}
				update_hood(1.0,false)
			"soldier":
				health=1;glass_hp=0
				update_soldier({"kind":"soldier","behavior":"stationary","soldier_state":"Fire","anim":"soldier_Fire","anim_time":0.0,"x":0.0,"aim":1.0,"fire_timer":0.0,"shots":0,"cue_checked":true},20,0.11)
			"bomb":
				car_hp=1
				update_soldier({"kind":"soldier","behavior":"bomb","soldier_state":"PullSpikeStrip","anim":"soldier_PullSpikeStrip","anim_time":1.0,"x":0.0,"z":0.0,"cue_checked":true,"trigger_started":true,"trigger_time":1.0,"triggered":true,"bomb_positions":[0,20,20,20,20,20,20],"bomb_index":0,"bomb_time":0.0},0,0.01)
			"helicopter","jet":
				segment=8;car_hp=1;health=1
				air={"kind":scenario,"t":4.1,"target":0.0,"fired":false}
				update_air(0.01)
			"nuke":
				segment=20;nuke_time=0
		simulate(0.01,0,false,false,0)
		expect(state=="results" and pending_death_cause==expected[i],"fatal cause retained: "+scenario)
		var rp_before=progress.rp
		finish_run("duplicate",false,"Zombie")
		expect(progress.rp==rp_before and pending_death_cause==expected[i],"duplicate finish preserves cause and RP")
		if death_menu_active():update_death_menu(3.5)
		if i%3==0:
			await frontend_click("retry")
		else:
			var event=InputEventKey.new();event.physical_keycode=KEY_ENTER if i%3==1 else KEY_SPACE;event.pressed=true
			_input(event)
		expect(state=="garage" and snd.voice.playing and snd.voice_key.begins_with("PlayerDeath"+expected[i]),"garage plays death reaction: "+scenario)
		expect(pending_death_cause.is_empty() and garage_chatter_timer==0,"reaction consumed and radio timer reset")
		expect(snd.voice_target_db<=-6 and snd.voice_queue.is_empty(),"reaction uses protected single voice channel")
		snd.stop_action()
	# An armor break is not a death; a later lethal attack owns the cause.
	start_run();armor_level=3;car_hp=1;damage_car(100)
	expect(car_hp==100 and fatal_cause.is_empty(),"armor loss is not a fatal crash")
	health=1;damage_player(10,"Zombie");damage_car(200,0,false,"Jet")
	expect(fatal_cause=="Zombie","later same-frame damage does not replace lethal cause")
	for reason in ["You ended this run.","Time ran out.","You escaped Evans City."]:
		start_run();finish_run(reason,reason.begins_with("You escaped"))
		enter_garage()
		expect(snd.voice_key.is_empty(),"no death reaction for "+reason)
	start_run();finish_run("death",false,"Crash");open_menu();enter_garage()
	expect(snd.voice_key.is_empty(),"menu discards stale death reaction")
	start_run();finish_run("death",false,"Zombie");start_run()
	expect(pending_death_cause.is_empty() and fatal_cause.is_empty(),"new run clears old death")
	progress.settings.garage_seen=false
	finish_run("death",false,"Crash");enter_garage()
	expect(snd.voice_key=="PlayerFirstTimeInGarage","original first story visit has priority")
	snd.stop_action();progress.settings.garage_seen=true
	# Exercise a complete recorded reaction, its mouth frames, then the radio gap.
	start_run();finish_run("death",false,"Crash");enter_garage()
	garage_chatter_delay=999
	var death_key=snd.voice_key
	snd.speak("CheckPoint0Post")
	var started=Time.get_ticks_msec();var mouth_open=false;var mouth_closed=false
	while snd.voice_key==death_key and Time.get_ticks_msec()-started<30000:
		var frame=garage_head_frame()
		if frame>=10:mouth_open=true
		if frame==0:mouth_closed=true
		await get_tree().process_frame
	expect(mouth_open and mouth_closed,"death dialogue animates mouth including pauses")
	expect(snd.voice_key.is_empty() and snd.voice_gap_left>2,"radio waits after completed death reaction")
	await get_tree().create_timer(1).timeout
	expect(snd.voice_key.is_empty(),"radio does not overlap death reaction")
	await get_tree().create_timer(1.8).timeout
	expect(snd.voice_key=="CheckPoint0Post","radio resumes after normal speech gap")
	snd.stop_action()
	enter_garage()
	expect(snd.voice_key.is_empty(),"returning twice cannot replay consumed death")
	start_run();finish_run("death",false,"Military");enter_garage()
	snd.upgrade_voice("PlayerUpgradeBumper1")
	expect(snd.voice_key=="PlayerUpgradeBumper1" and snd.voice_queue.is_empty(),"purchase replaces death reaction without stacking")
	snd.stop_action()
	print("DEATH_DIALOGUE_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func update_viewport_layout():
	RW=get_viewport_rect().size.x
	UI_OFFSET=Vector2((RW-W)*0.5,0)
	art.cockpit_width=RW
	if cinema_screen!=null:cinema_screen.position=UI_OFFSET
	if cinema_overlay!=null:cinema_overlay.position=UI_OFFSET
	queue_redraw()

func speedometer_frame() -> int:
	# Native needle uses per-gear visual ratios, not linear road velocity.
	if car35.level!=int(progress.upgrades[4]):car35.reset(int(progress.upgrades[4]))
	if not is_equal_approx(speed,car35.speed):car35.seek_speed(speed)
	return car35.visual_frame()

func draw_dashboard_progress():
	if mode in ["story","hardcore"]:
		art.draw_anim(self,"km_base14",0)
		var level=mini(20,(segment/2)*2)
		var length=float(LENGTHS[level])+(float(LENGTHS[level+1]) if level<20 else 0.0)
		var fraction=clampf((position_z-segment_position(level))/length,0,1)
		var marker:Dictionary=art.anim_data.cockpit14.km_markers
		art.draw_anim(self,"km_needle14",0,Vector2((0.5+fraction*52.5-float(marker.Needle[4]))*1.8,0))
		if level<20:
			var checkpoint=float(LENGTHS[level])/length
			art.draw_anim(self,"km_checkpoint14",0,Vector2((0.5+checkpoint*52.5-float(marker.CheckPoint[4]))*1.8,0))


func source_world_sound_bag(name:String,actor:Dictionary,gain:float=-8.0,profile:String="default"):
	var bag:Array=art.world_data.get("sounds16",{}).get(name,[])
	if bag.is_empty():return
	snd.play_world(String(bag[rng.randi_range(0,bag.size()-1)]),actor.x,actor.z,gain,profile,4.0,actor)


func spawn_source_road_sign(x:float,z:float) -> Dictionary:
	var sign_actor={"kind":"road_sign","x":x,"z":z,"offroad_z":z,"crashed":false,"anim_time":0.0,"vz":0.0,"decel":0.0}
	road_signs.append(sign_actor)
	return sign_actor

func update_road_signs(dt:float):
	if position_z+200.0>=next_road_sign:
		spawn_source_road_sign(-ROAD_SIGN_SIDE_X if rng.randf()<0.5 else ROAD_SIGN_SIDE_X,next_road_sign)
		next_road_sign+=150.0+rng.randf()*100.0
	for sign_actor in road_signs:
		if bool(sign_actor.crashed):
			sign_actor.anim_time=float(sign_actor.anim_time)+dt
			sign_actor.vz=maxf(0.0,float(sign_actor.vz)-float(sign_actor.decel)*dt)
			sign_actor.z=float(sign_actor.z)+float(sign_actor.vz)*dt
	road_signs=road_signs.filter(func(s):return camera_depth(maxf(float(s.z),float(s.offroad_z))-position_z)>=-5.0)

func helicopter_sign_collision(old_z:float):
	if helicopter.is_empty():return
	var new_z=float(helicopter.z)
	for sign_actor in road_signs:
		if bool(sign_actor.crashed):continue
		if (old_z<float(sign_actor.z))==(new_z<float(sign_actor.z)):continue
		# Source bounds: helicopter X [-2,+2], Y [-1,+1]; sign X [-2,+2], Y [4,6].
		if absf(float(helicopter.x)-float(sign_actor.x))>4.0:continue
		if float(helicopter.y)+1.0<4.0 or float(helicopter.y)-1.0>6.0:continue
		var velocity=float(helicopter.get("vz",0.0))
		sign_actor.crashed=true;sign_actor.anim_time=0.0
		sign_actor.vz=velocity*1.15;sign_actor.decel=velocity*0.4
		source_helicopter_hit()

func source_helicopter_hit():
	if helicopter.is_empty() or bool(helicopter.broken):return
	snd.play_world("HugeCollision%02d"%rng.randi_range(1,2),helicopter.x,helicopter.z,-8,"default",1.0)
	helicopter.firing=false
	helicopter.fire_phase_timer=0.0;helicopter.bullet_timer=0.0
	var i=clampi(int(helicopter.difficulty)-1,0,5)
	helicopter.fire_phase_duration=float([5.0,4.5,4.0,3.5,3.0,2.5][i])+rng.randf()*0.5
	helicopter.missile_timer=0.0
	helicopter.missile_delay=float([3.0,3.0,3.0,3.0,3.0,2.0][i])+rng.randf()*0.5
	helicopter.hp=int(helicopter.hp)-1
	helicopter.anim_time=0.0
	if int(helicopter.hp)<=0:
		helicopter.broken=true;helicopter.anim="Crash"
		if not awarded:achievement_system.unlock(progress,8);flush_achievements364();air_dodges+=1
		if not awarded:snd.speak("HelicopterDefeated%02d"%rng.randi_range(1,2),false,"",-6)
	else:helicopter.anim="Hit"
	shake=maxf(shake,0.6)

func helicopter_source_frame() -> int:
	var anim=String(helicopter.get("anim","Idle"))
	var timing:Dictionary=art.world_data.get("release20",{})
	var first=int(timing.get("heli_labels",{}).get(anim,6))
	var last=int(timing.get("heli_end_frames",{}).get(anim,173))
	var length=maxi(1,last-first+1)
	var n=int(float(helicopter.get("anim_time",0.0))*30.0)
	return first-1+posmod(n,length)

func advance_helicopter_animation(dt:float):
	if helicopter.is_empty():return
	helicopter.anim_time=float(helicopter.get("anim_time",0.0))+dt
	if String(helicopter.get("anim","Idle"))=="Hit":
		var timing:Dictionary=art.world_data.get("release20",{})
		var first=int(timing.get("heli_labels",{}).get("Hit",181))
		var last=int(timing.get("heli_end_frames",{}).get("Hit",226))
		if float(helicopter.anim_time)*30.0>=last-first+1:
			helicopter.anim="Idle";helicopter.anim_time=0.0

func draw_source_heli():
	if helicopter.is_empty():return
	var z=float(helicopter.z)-position_z
	if camera_depth(z)<=1.0 or camera_depth(z)>=240.0:return
	var f=helicopter_source_frame()
	draw_air_world_sprite("heli20",f,helicopter.x,z,helicopter.y,4.0,float(helicopter.get("rotation",0.0)))
	if int(helicopter.hp)<=1 and not bool(helicopter.retreating):
		draw_air_world_sprite("heli_smoke20",f,helicopter.x,z,helicopter.y,4.0,float(helicopter.get("rotation",0.0)))
	if bool(helicopter.firing) and not bool(helicopter.broken) and not bool(helicopter.missile_mode):
		draw_air_world_sprite("heli_muzzle20",f,helicopter.x,z,helicopter.y,4.0,float(helicopter.get("rotation",0.0)))

func draw_source_road_sign(sign_actor:Dictionary,offroad:bool=false):
	var z=float(sign_actor.offroad_z if offroad else sign_actor.z)-position_z
	if camera_depth(z)<=0.1 or camera_depth(z)>=200:return
	var f=0
	if bool(sign_actor.crashed):f=mini(42,7+int(float(sign_actor.anim_time)*30.0))
	var key="highway_sign_offroad20" if offroad else ("highway_sign_left20" if float(sign_actor.x)<0 else "highway_sign20")
	# The source keeps its support in Layer_SideBackground, before wall painting.
	draw_air_world_sprite(key,f,sign_actor.x,z,0.0,1.0,0.0,false)

func run_release20_checks():
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0]
	start_run();entities.clear();road_signs.clear();next_road_sign=999999
	segment=16;speed=100;air_delay=999999
	expect(art.world_data.groups.heli20.size()==314,"all 314 helicopter source frames available")
	for key in ["heli_smoke20","heli_muzzle20","highway_sign20","highway_sign_left20","highway_sign_offroad20"]:
		expect(not art.world_data.groups.get(key,[]).is_empty(),"source visual group "+key)
	spawn_source_helicopter();helicopter.x=7.5;player_x=7.5
	for hit in range(3):
		var sign_actor=spawn_source_road_sign(7.5,position_z+19)
		helicopter.z=position_z+18;helicopter.y=5;helicopter.vz=30
		update_source_helicopter(0.11)
		expect(int(helicopter.hp)==2-hit,"physical sign collision removes one HP, hit "+str(hit+1))
		expect(bool(sign_actor.crashed) and sign_actor.vz>0 and is_equal_approx(float(sign_actor.offroad_z),position_z+19),"sign breaks, moves; off-road support remains in place")
		expect(not bool(helicopter.firing),"sign hit stops machine-gun fire")
		var hp=int(helicopter.hp)
		helicopter_sign_collision(position_z+18)
		expect(int(helicopter.hp)==hp,"same broken sign cannot deal repeated damage")
		road_signs.clear()
		if hit<2:
			expect(String(helicopter.anim)=="Hit","first two impacts play Hit")
			advance_helicopter_animation(2.0)
			expect(String(helicopter.anim)=="Idle","Hit returns to original Idle label")
	expect(bool(helicopter.broken) and String(helicopter.anim)=="Crash" and air_dodges==1,"third physical sign hit starts Crash and awards one defeat")
	var crash_frame=helicopter_source_frame()
	advance_helicopter_animation(3.0)
	expect(crash_frame>=239 and helicopter_source_frame()>=239 and helicopter_source_frame()<=305,"Crash follows source label and loop endpoint")
	var prior_speed=float(helicopter.vz);var prior_height=float(helicopter.y)
	update_source_helicopter(0.5)
	expect(float(helicopter.vz)<prior_speed and float(helicopter.y)>prior_height,"broken helicopter decelerates and rises with original constants")
	start_run();road_signs.clear();segment=16;player_x=0;speed=100;spawn_source_helicopter()
	helicopter.x=0;helicopter.z=position_z+18
	var miss_sign=spawn_source_road_sign(7.5,position_z+19)
	update_source_helicopter(0.11)
	expect(int(helicopter.hp)==3 and not bool(miss_sign.crashed),"non-overlapping sign cannot hit helicopter")
	player_x=7.5;helicopter.x=7.5;helicopter.y=8;helicopter.z=position_z+18
	update_source_helicopter(0.11)
	expect(int(helicopter.hp)==3,"height overlap required")
	snd.silent=false;snd.enabled=true;AudioServer.set_bus_volume_db(0,-80)
	snd.begin_world_frame(0,0)
	expect(is_equal_approx(snd.spatial_mix(0,5,"car").x,1.0),"source car full volume through five units")
	expect(is_equal_approx(snd.spatial_mix(0,42.5,"car").x,0.5),"source car linear 5-80 attenuation")
	expect(is_equal_approx(snd.spatial_mix(0,-20,"car").x,0.0),"source rear car distance is multiplied by four")
	expect(snd.spatial_mix(-5,5,"car").y==-1 and snd.spatial_mix(5,5,"car").y==1,"source stereo sides pan to left and right")
	for i in range(30):snd.world_loop("alarm_"+str(i),"CarAlarmSmall",true,float(i%3-1)*3,5.0+i,-14,"car",4.0,"alarm")
	snd.flush_world_frame(1.0)
	expect(snd.selected_alarm_channels.size()==1,"crowded road selects only one alarm")
	var alarm_slot=snd.world_slot("alarm_0")
	expect(not alarm_slot.is_empty() and alarm_slot.player.volume_db<=-26,"nearest alarm uses quiet mix cap")
	var play_position=float(alarm_slot.player.get_playback_position())
	snd.begin_world_frame(0,0)
	snd.world_loop("alarm_0","CarAlarmSmall",true,0,5,-14,"car",4,"alarm")
	snd.flush_world_frame(0.016)
	expect(float(alarm_slot.player.get_playback_position())>=play_position,"loop update preserves playback rather than restarting")
	for i in range(100):
		snd.begin_world_frame(0,float(i)*10)
		snd.world_loop("passing_"+str(i),"CarHornSmall",true,3,float(i)*10+5,-18,"car")
		snd.flush_world_frame(0.1)
	expect(snd.world_slots.size()==24,"world sound player pool stays bounded")
	snd.pause_all(true)
	var all_paused=true
	for slot in snd.world_slots:
		if slot.player.playing and not slot.player.stream_paused:all_paused=false
	expect(all_paused,"pause stops all positional playback clocks")
	snd.pause_all(false);snd.stop_action()
	var all_stopped=true
	for slot in snd.world_slots:
		if slot.player.playing:all_stopped=false
	expect(all_stopped and snd.world_requests.is_empty(),"menu transition clears every world loop")
	snd.silent=true
	for actor in ["male","female","hard","super","soldier","civilian"]:
		var variants=["Male1","Male2","Male3","Male5","Female1","Female3","Female4"] if actor=="civilian" else [""]
		for variant in variants:
			for velocity in [35.0,70.0,110.0]:
				for offset in [0.0,0.2,0.45,0.8]:
					speed=velocity
					var hit=source_hit_anim(actor,variant,offset)
					expect(not art.world_data.groups.get(hit.key,[]).is_empty(),"hit matrix "+actor+variant+" "+str(velocity)+" "+str(offset))
					if velocity<60:expect(hit.type=="RollOverHit" and bool(hit.slow),"slow rollover uses source rollover graphics")
	print("RELEASE20_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func release20_capture(name:String):
	queue_redraw()
	await RenderingServer.frame_post_draw
	var base=ProjectSettings.globalize_path("res://../analysis/")
	if not OS.has_feature("editor"):base=OS.get_executable_path().get_base_dir()+"/../analysis/"
	get_viewport().get_texture().get_image().save_png(base+"release20_"+name+".png")
	print("RELEASE20_CAPTURE: ",name)

func capture_release20():
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0]
	start_run();entities.clear();road_signs.clear();speed=90;notice_time=0;subtitle_time=0;segment=16
	spawn_source_helicopter();helicopter.z=position_z+38;helicopter.x=3;helicopter.anim_time=1.2
	spawn_source_road_sign(7.5,position_z+42)
	await release20_capture("heli_idle_sign")
	helicopter.firing=true
	await release20_capture("heli_firing")
	source_helicopter_hit();helicopter.anim_time=.4
	await release20_capture("heli_hit")
	source_helicopter_hit();helicopter.anim_time=.7
	await release20_capture("heli_smoke")
	source_helicopter_hit()
	for t in [0.0,0.5,1.4,2.1]:
		helicopter.anim_time=t
		await release20_capture("heli_crash_"+str(t).replace(".","_"))
	helicopter.clear()
	for sign_actor in road_signs:sign_actor.crashed=true;sign_actor.anim_time=.5
	await release20_capture("sign_break")
	road_signs.clear()
	for actor in ["male","female","hard","super","soldier","civilian"]:
		var variants=["Male1","Male2","Male3","Male5","Female1","Female3","Female4"] if actor=="civilian" else [""]
		for variant in variants:
			for hit in ["FrontHit","SideHit","RollOverHit","GibHit"]:
				var key=actor+"_"+hit+variant
				if actor=="civilian" and hit=="GibHit":key="civilian_GibHit"
				for frame in [0,6,12]:
					impacts.clear()
					impacts.append({"kind":key,"time":float(frame)/30.0,"x":0.0,"height":1.8,"flip":false,"attached":true})
					await release20_capture("hit_"+key+"_"+str(frame))
	print("RELEASE20_VISUAL: PASS")
	get_tree().quit()

func death_menu_active() -> bool:
	return state=="results" and not death_screen_clip.is_empty()

func results_ready() -> bool:
	return not death_menu_active() or death_screen_time>=3.0

func update_death_menu(dt:float):
	death_screen_time+=maxf(0,dt)
	if death_explosion:shake=maxf(0,.2*(1-death_screen_time))
	if not death_points_sound and death_screen_time>=0.5:
		death_points_sound=true;snd.play("UpgradePerception",-18)

func draw_death_menu():
	# Original MC_Hud.DeathScreens frame colors, at the source 30 fps.
	var frames:Array=death_screen_data.clips[death_screen_clip]
	var frame=mini(int(death_screen_time*30),frames.size()-1)
	for layer in frames[frame]:
		var color=Color(String(layer[0]));color.a=float(layer[1])
		draw_rect(Rect2(-UI_OFFSET.x,0,RW,H),color)
	if death_screen_time<0.5:return
	# RDHud.ShowPointsScreen: each row slides from x=-600 over .5 seconds,
	# with Quad.easeOut and a .25-second stagger, after PreStatsDelay=.5.
	for i in range(death_point_rows.size()):
		var t=clampf((death_screen_time-0.5-float(i)*0.25)/0.5,0,1)
		var x=-W*pow(1-t,2)
		var y=(60.3+float(i)*29.15)*1.8 if i<9 else 336.8*1.8
		var row:Array=death_point_rows[i]
		var desc=String(row[0]);var points=String(row[1])
		var ds=32;var ps=45 if i<9 else 58
		while ds>20 and art.menu_font.get_string_size(desc,HORIZONTAL_ALIGNMENT_LEFT,-1,ds).x>520:ds-=1
		while ps>22 and art.garage_font.get_string_size(points,HORIZONTAL_ALIGNMENT_LEFT,-1,ps).x>390:ps-=1
		var dp=Vector2(x+126,y+8);var pp=Vector2(x+666,y+10)
		draw_string_outline(art.menu_font,dp,desc,HORIZONTAL_ALIGNMENT_LEFT,-1,ds,3,Color.BLACK)
		draw_string(art.menu_font,dp,desc,HORIZONTAL_ALIGNMENT_LEFT,-1,ds,Color.WHITE)
		draw_string_outline(art.garage_font,pp,points,HORIZONTAL_ALIGNMENT_LEFT,-1,ps,3,Color.BLACK)
		draw_string(art.garage_font,pp,points,HORIZONTAL_ALIGNMENT_LEFT,-1,ps,Color.WHITE)
	if results_ready():
		pause_source_button("retry","GARAGE & UPGRADES",Rect2(80,648,545,56))
		pause_source_button("menu","MAIN MENU",Rect2(734,648,285,56))
		draw_string(art.menu_font,Vector2(150,646),"Enter or Space to continue",HORIZONTAL_ALIGNMENT_LEFT,-1,22,Color.WHITE)

func run_release21_checks():
	ui_audio_check=true;preview_mode=true;AudioServer.set_bus_volume_db(0,-80)
	mode="story";progress.checkpoint=0;progress.settings.garage_seen=true
	expect(death_screen_data.symbol==3352 and death_screen_data.fps==30,"original death symbol and frame rate")
	expect(death_screen_data.clips.FadeToRed.size()==251 and death_screen_data.clips.FlashToRed.size()==10,"complete source crash/zombie overlays")
	for scenario in ["car","wall","zombie"]:
		start_run();entities.clear();next_pattern=1e9;air_delay=999;position_z=start_z+1250
		if scenario=="car":
			car_hp=1;speed=110;collide({"kind":"cars","x":0.0})
		elif scenario=="wall":
			car_hp=1;speed=90;player_x=9.1;lateral=5;damage_car(2,0,false)
		else:
			health=1;glass_hp=0;hood_time=5
			hood={"kind":"male","grip":0.0,"anim":"Inside","anim_time":0.0}
			update_hood(1,false)
		simulate(.01,0,false,false,0)
		expect(death_menu_active(),"fatal "+scenario+" enters death menu")
		expect(death_screen_clip==("FlashToRed" if scenario=="zombie" else ("FadeToRed" if death_explosion else "FadeToBlack")),"cause selects source transition: "+scenario)
		var bank=progress.rp;var z=position_z;var hp=health
		var row_total=0
		for i in range(9):row_total+=int(String(death_point_rows[i][1]).split(" ")[0])
		expect(row_total==run_rp,"displayed breakdown equals awarded RP: "+scenario)
		var key=InputEventKey.new();key.physical_keycode=KEY_SPACE;key.pressed=true
		_input(key);activate("retry")
		expect(state=="results","input cannot skip initial death reveal")
		update_death_menu(.25)
		expect(position_z==z and health==hp and progress.rp==bank,"death menu freezes gameplay and RP")
		finish_run("duplicate",false,"Zombie")
		expect(progress.rp==bank and death_screen_time==.25,"duplicate death cannot award or restart")
		update_death_menu(3.25)
		expect(results_ready() and death_point_rows.size()==10,"full points screen and navigation become ready")
		await release20_capture("death21_"+scenario)
		expect(buttons.any(func(b):return b.id=="retry") and buttons.any(func(b):return b.id=="menu"),"death menu exposes garage and main menu")
		if scenario=="car":await frontend_click("retry")
		elif scenario=="wall":key.physical_keycode=KEY_ENTER;_input(key)
		else:_input(key)
		expect(state=="garage" and pending_death_cause.is_empty() and progress.rp==bank,"mouse/Enter/Space returns to garage once: "+scenario)
	start_run();finish_run("fatal",false,"Zombie");update_death_menu(3.5);activate("menu")
	expect(state=="menu" and death_screen_clip.is_empty() and pending_death_cause.is_empty(),"main menu clears old death")
	start_run();finish_run("Time ran out.")
	expect(not death_menu_active() and results_ready(),"nonfatal results stay immediately accessible")
	start_run();kill_hood(false);finish_run("death",false,"Crash");start_run()
	expect(death_screen_clip.is_empty() and hood_shot_kills==0 and hood_shaken_kills==0,"new run resets death display and counters")
	snd.silent=false;snd.enabled=true;snd.music_enabled=true
	start_run();finish_run("fatal",false,"Zombie")
	expect(snd.music_name=="FailStringer_1_V4" and snd.music.playing,"original failure sting plays on music channel")
	expect(snd.music.stream is AudioStreamWAV and snd.music.stream.loop_mode==AudioStreamWAV.LOOP_DISABLED,"failure sting never loops")
	expect(snd.voice.playing and snd.voice_key.begins_with("PlayerDevoured"),"zombie kill plays one original death scream")
	snd.stop_action();snd.music.stop();apply_settings();AudioServer.set_bus_volume_db(0,-80)
	expect(not snd.music.playing,"fullscreen/settings changes do not restart completed failure sting")
	update_death_menu(3.5);activate("retry")
	expect(snd.music_name=="Music_GarageMusic" and snd.voice_key.begins_with("PlayerDeathZombie"),"garage replaces failure audio with original reaction")
	snd.music_enabled=false
	start_run();finish_run("fatal",false,"Crash")
	expect(not snd.music.playing,"failure sting respects music off")
	snd.stop_action();snd.music.stop();snd.silent=true
	print("RELEASE21_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func capture_release21():
	ui_audio_check=true;mode="story";progress.checkpoint=0
	for cause in ["Crash","Zombie"]:
		start_run();entities.clear();speed=90;position_z=start_z+3800;kills=54;soldier_kills=12;hood_kills=4;hood_shot_kills=2;hood_shaken_kills=2;run_rp=110;civilians_hit=2;precision_hits=3;notice_time=0;subtitle_time=0
		spawn_entity("cars",4.3,18)
		if cause=="Zombie":
			health=0;glass_hp=0;hood={"kind":"male","anim":"Inside","anim_time":0.0,"grip":0.0}
		else:car_hp=0
		finish_run("John did not survive." if cause=="Zombie" else "The car was destroyed.",false,cause)
		for time in [0.0,0.15,0.5,1.5,3.5,8.5]:
			death_screen_time=time
			await release20_capture("death21_"+cause+"_"+str(time).replace(".","_"))
		RW=1728;UI_OFFSET=Vector2(324,0);death_screen_time=3.5
		get_viewport().size=Vector2i(1728,720)
		await release20_capture("death21_"+cause+"_wide")
		get_viewport().size=Vector2i(1280,720);update_viewport_layout()
	print("RELEASE21_VISUAL: PASS")
	get_tree().quit()

func crash_pose() -> Dictionary:
	# MC_PlayerCarBack: gotoAndPlay("Explosion") at frame 7, stop at 32.
	return crash_data.frames[mini(int(death_screen_time*30),crash_data.frames.size()-1)]

func run_release22_checks():
	ui_audio_check=true;preview_mode=true;AudioServer.set_bus_volume_db(0,-80)
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0];progress.settings.garage_seen=true
	expect(crash_data.symbol==3783 and crash_data.fps==30 and crash_data.source_start==7 and crash_data.source_stop==32,"original crash symbol, label and stop frame")
	expect(crash_data.frames.size()==26,"complete original explosion sequence")
	var box:Array=crash_data.raster_box
	var top=art.cockpit_map(Vector2(box[0],box[1])*1.8)
	var bottom=art.cockpit_map(Vector2(box[0]+box[2],box[1]+box[3])*1.8)
	expect(top.y<=0 and bottom.y>=H and top.x<=0 and bottom.x>=RW,"crash extraction covers the full viewport without clipped edges")
	for cause in ["car","wall"]:
		start_run();entities.clear();next_pattern=1e9;air_delay=999;position_z=start_z+1200
		if cause=="car":car_hp=1;speed=110;collide({"kind":"cars","x":0.0})
		else:car_hp=1;speed=90;player_x=9.1;lateral=5;damage_car(2,0,false)
		simulate(.01,0,false,false,0)
		expect(death_menu_active() and death_explosion and death_screen_clip=="FadeToRed","original crash/fade for "+cause)
		expect(speed==0 and lateral==0 and hood.is_empty() and red_flash==0,"crash freezes car and removes clinger/health flash")
		expect(int(crash_pose().source_frame)==7,"explosion begins at original frame 7")
		var bank=progress.rp
		var old_alpha=0.0
		for time in [0.0,.1,.5,1.0,3.5,8.5,15.0]:
			death_screen_time=time
			var frames:Array=death_screen_data.clips.FadeToRed
			var layers:Array=frames[mini(int(time*30),frames.size()-1)]
			var alpha=float(layers[0][1])
			expect(alpha>=old_alpha,"crash fade progressively darkens "+str(time));old_alpha=alpha
			if time>=1:expect(int(crash_pose().source_frame)==32,"explosion holds original stopped frame")
			await release20_capture("crash22_"+cause+"_"+str(time).replace(".","_"))
			expect(crash_texture!=null,"original exploded-car artwork is rendered")
		expect(is_equal_approx(old_alpha,.7294118),"original red fade settles at source opacity")
		finish_run("duplicate",false,"Zombie")
		expect(progress.rp==bank and pending_death_cause=="Crash","crash retains cause and single award")
		await frontend_click("retry")
		expect(state=="garage" and not death_explosion and crash_texture==null,"garage clears crash presentation")
	start_run();car_hp=1;armor_level=1;damage_car(20)
	expect(car_hp==100 and not death_explosion and state=="play","armor break remains survivable")
	start_run();health=0;finish_run("death",false,"Zombie")
	expect(not death_explosion and death_screen_clip=="FlashToRed","zombie death retains its own flash")
	start_run();finish_run("You ended this run.")
	expect(not death_explosion and death_screen_clip.is_empty(),"retiring is not a crash")
	start_run();car_hp=0;finish_run("death",false,"Crash");open_menu()
	expect(not death_explosion and crash_texture==null,"menu clears crash assets")
	print("RELEASE22_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func capture_release22():
	ui_audio_check=true;mode="story";progress.checkpoint=0
	start_run();entities.clear();car_hp=0;position_z=start_z+3800;kills=54;notice_time=0;subtitle_time=0
	spawn_entity("cars",4.3,18);finish_run("The car was destroyed.",false,"Crash")
	for time in [0.0,.1,.3,.5,.8,1.0,3.5,8.5]:
		death_screen_time=time
		await release20_capture("crash22_sequence_"+str(time).replace(".","_"))
	get_viewport().size=Vector2i(1728,720);update_viewport_layout();death_screen_time=8.5
	await release20_capture("crash22_wide")
	print("RELEASE22_VISUAL: PASS")
	get_tree().quit()

func run_release23_checks():
	ui_audio_check=true;preview_mode=true;AudioServer.set_bus_volume_db(0,-80)
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0];progress.settings.garage_seen=true
	expect(bool(crash_data.get("complete_source_bounds",false)),"full original wreck and explosion bounds are available for pullback")
	for cause in ["car","wall"]:
		start_run();entities.clear();next_pattern=1e9;air_delay=999;position_z=start_z+1200
		var normal_point=project_point(player_x+2.0,18.0)
		if cause=="car":car_hp=1;speed=110;collide({"kind":"cars","x":0.0})
		else:car_hp=1;speed=90;player_x=9.1;lateral=5;damage_car(2,0,false)
		simulate(.01,0,false,false,0)
		expect(crash_camera_active(),"fatal "+cause+" impact starts camera pullback")
		expect(is_equal_approx(camera_depth(0),5.0) and is_equal_approx(camera_height(),1.6),"original initial five-unit separation and 1.6 camera height")
		var frozen_z=position_z
		var frozen_x=player_x
		var awarded_rp=progress.rp
		var focal=camera_focal()
		var wreck_initial_width=1300.0*0.0034959*focal.y/camera_depth(0)
		var adjacent_initial=project_point(player_x+2.0,18.0).x-RW*.5
		expect(is_equal_approx(adjacent_initial,2.0*focal.x/23.0),"world actor at eighteen units is twenty-three from original failure camera")
		update_death_menu(1.0)
		expect(is_equal_approx(camera_depth(0),5.7),"camera moves backward at source 0.7 units per second")
		expect(int(crash_pose().source_frame)==32,"stopped wreck remains visible during retreat")
		update_death_menu(4.0)
		expect(is_equal_approx(camera_depth(0),8.5),"pullback continues after results menu appears")
		expect(camera_focal()==focal,"pullback retains original fixed FOV")
		expect(1300.0*.0034959*focal.y/camera_depth(0)<wreck_initial_width*.6,"wreck shrinks with physical distance")
		expect(project_point(player_x+2.0,18.0).x-RW*.5<adjacent_initial,"nearby traffic shares the retreating camera")
		expect(is_equal_approx(project_road_point(player_x+2.0,22.0).x, RW*.5+2.0*focal.x/22.0),"road depths are relative to camera and are not offset twice")
		expect(position_z==frozen_z and player_x==frozen_x and progress.rp==awarded_rp,"presentation does not move the wreck or award points again")
		await release20_capture("crash23_"+cause+"_pullback")
		expect(crash_texture!=null and results_ready(),"wreck and ready death menu render together")
		await frontend_click("retry")
		expect(state=="garage" and camera_back_offset()==0 and not death_explosion,"garage resets camera")
		start_run()
		expect(camera_depth(1)==1 and camera_height()==1.5 and camera_focal()==Vector2(FOCAL_X,FOCAL_Y),"retry restores normal driving camera")
		if cause=="car":expect(project_point(player_x+2,18).is_equal_approx(normal_point),"normal projection restored exactly")
	start_run();health=0;finish_run("death",false,"Zombie")
	expect(not crash_camera_active() and camera_back_offset()==0,"zombie death retains its own presentation")
	start_run();car_hp=1;armor_level=1;damage_car(20)
	expect(state=="play" and camera_back_offset()==0,"survivable armor damage does not pull back camera")
	start_run();car_hp=0;finish_run("death",false,"Crash");update_death_menu(8);open_menu()
	expect(camera_back_offset()==0 and not death_explosion and crash_texture==null,"main menu clears camera and wreck")
	print("RELEASE23_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func capture_release23():
	ui_audio_check=true;mode="story";progress.checkpoint=0
	start_run();entities.clear();car_hp=0;position_z=start_z+3800;kills=54;notice_time=0;subtitle_time=0
	spawn_entity("cars",4.3,18);finish_run("The car was destroyed.",false,"Crash")
	for time in [0.0,.1,.3,.5,.8,1.0,3.5,8.5,15.0]:
		death_screen_time=time
		await release20_capture("crash23_sequence_"+str(time).replace(".","_"))
	get_viewport().size=Vector2i(1728,720);update_viewport_layout();death_screen_time=3.5
	await release20_capture("crash23_wide")
	print("RELEASE23_VISUAL: PASS")
	get_tree().quit()

func update_world_effects(dt:float):
	for e in effects:e.time-=dt;e.y-=dt*30
	effects=effects.filter(func(e):return e.time>0)
	for impact in impacts:impact.time+=dt
	impacts=impacts.filter(func(impact):
		var frames=art.world_data.get("groups",{}).get(String(impact.kind),[]).size()
		var start=int(impact.get("start",0))
		return impact.time<maxf(0.25,float(maxi(0,frames-start))/30.0))

func update_death_world(dt:float):
	# RDWorld continues updating after RDPlayer fails; only the player stops.
	if not death_menu_active():return
	elapsed+=dt
	snd.begin_world_frame(player_x,position_z-camera_back_offset())
	update_road_signs(dt)
	update_entities(dt)
	# Existing aircraft/projectiles keep their timelines; no new encounter spawns.
	update_source_helicopter(dt)
	update_source_jet(dt)
	snd.flush_world_frame(dt)
	update_world_effects(dt)

func prepare_crash_textures():
	# Small cropped textures replace eight mostly empty 4096px crash sheets.
	# Warm once before the menu, so the collision and _draw do no disk work.
	for rec in crash_data.frames:
		crash_textures[rec.file]=load("res://assets/crash24/"+String(rec.file))
	for rows in crash_data.layers.values():
		for rec in rows:crash_textures[rec.file]=load("res://assets/crash24/"+String(rec.file))

func crash_loop_pose(key:String) -> Dictionary:
	var rows:Array=crash_data.layers[key]
	var child_age=maxi(0,int(death_screen_time*30)-2)
	return rows[posmod(child_age,rows.size())]

func draw_crash_record(rec:Dictionary):
	crash_texture=crash_textures[String(rec.file)];crash_page=int(rec.page)
	var src=Rect2(rec.rect[0],rec.rect[1],rec.rect[2],rec.rect[3])
	var pos=Vector2(rec.offset[0],rec.offset[1])
	var stage:Array=art.anim_data.cockpit14.stage_transform
	var origin=Vector2(stage[4],stage[5])*1.8
	var scale=camera_focal().y*.0034959/camera_depth(0)/1.8
	var anchor=project_point(player_x,0)
	draw_texture_rect_region(crash_texture,Rect2(anchor+(pos-origin)*scale,src.size*float(rec.scale)*scale),src,Color.WHITE)

func draw_crash_cockpit():
	if int(death_screen_time*30)<25:draw_crash_record(crash_pose())
	else:
		# The parent's frame-32 stop does not stop its nested fire/smoke clips.
		draw_crash_record(crash_loop_pose("smoke"))
		draw_crash_record(crash_loop_pose("fire"))
		draw_crash_record(crash_data.layers.body[0])

func run_release24_checks():
	ui_audio_check=true;preview_mode=true;AudioServer.set_bus_volume_db(0,-80)
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0]
	expect(crash_textures.size()==50 and crash_data.resident_rgba_bytes<220*1024*1024,"all original crash frames and independent child loops warmed within 220MB")
	start_run();entities.clear();road_signs.clear();next_road_sign=1e9
	var cache_bytes=art.texture_bytes.duplicate();art.prepare_driving()
	expect(art.texture_bytes==cache_bytes,"repeated warmup cannot double-count retained texture memory")
	var walker=spawn_entity("male",-2,position_z+30);walker.behavior="straight"
	var person=spawn_entity("civilian",3,position_z+45)
	var soldier=spawn_entity("soldier",-3,position_z+35);soldier.behavior="straight";soldier.fired=true
	var walker_z=float(walker.z);var person_x=float(person.x);var player_z=position_z;var player_pos=player_x
	spawn_source_helicopter();helicopter.z=position_z+60;helicopter.warned_player=true;helicopter.firing=true
	helicopter.hp=1
	car_hp=0;finish_run("The car was destroyed.",false,"Crash")
	var rp=progress.rp;var earned=run_rp;var dodges=air_dodges;var old_health=health;var old_car=car_hp
	var first_smoke=crash_loop_pose("smoke").file
	var first_fire=crash_loop_pose("fire").file
	for i in range(40):update_death_menu(.05);update_death_world(.05)
	expect(float(walker.z)!=walker_z and float(person.x)!=person_x,"zombie and civilian keep updating after player fails")
	expect(position_z==player_z and player_x==player_pos and speed==0,"wreck stays stopped while camera and world advance")
	expect(not soldier.fired and not helicopter.firing and not helicopter.missile_mode,"source failure stops soldier and helicopter attacks")
	damage_player(100);damage_car(100);damage_glass(100);collide({"kind":"cars","x":0.0})
	source_explosion(player_x,position_z,"Jet");source_helicopter_hit()
	expect(health==old_health and car_hp==old_car and progress.rp==rp and run_rp==earned and air_dodges==dodges,"continued world effects cannot damage player or change final points")
	death_screen_time=2.1
	expect(crash_pose().source_frame==32 and crash_loop_pose("smoke").file!=first_smoke and crash_loop_pose("fire").file!=first_fire,"parent stops at original frame32 while smoke and fire continue independently")
	await release20_capture("crash24_world_and_loops")
	expect(crash_sync_load_us==0 and art.perf_sync_paint_loads==0,"crash and gameplay painting do no synchronous texture loads")
	death_screen_time=5
	await frontend_click("retry")
	expect(state=="garage" and camera_back_offset()==0,"retry returns to garage and resets camera")
	start_run();health=0;finish_run("death",false,"Zombie")
	var stopped=position_z
	update_death_menu(.2);update_death_world(.2)
	expect(position_z==stopped and not death_explosion and death_screen_clip=="FlashToRed","zombie death retains original flash and stationary player")
	expect(art.texture_failed.is_empty(),"texture streaming has no failed requests")
	print("RELEASE24_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func run_release25_checks():
	ui_audio_check=true;preview_mode=true;AudioServer.set_bus_volume_db(0,-80)
	progress.settings.garage_seen=true;progress.checkpoint=0;mode="story";check_mouse=Vector2(40,40)
	# Reproduce the previous cold-cache state, including a stale upgraded pose.
	var empty_page=int(art.anim_record("garage_bumper",0).page)
	var empty_texture=art.anim_pages[empty_page]
	for key in ["garage_bumper","garage_wheel"]:
		art.ready_anim_record(key,1)
	art.anim_pages.erase(empty_page)
	for key in ["garage_bumper","garage_wheel"]:
		expect(art.ready_anim_record(key,0).is_empty(),"missing stock texture never substitutes purchased "+key)
	art.store_texture("anim",empty_page,empty_texture);art.prepare_garage()
	var before=art.texture_bytes.duplicate();art.prepare_garage()
	expect(art.texture_bytes==before,"garage warmup is idempotent")
	for level in range(4):
		for key in ["garage_bumper","garage_wheel"]:
			expect(art.ready_anim_record(key,level)==art.anim_record(key,level),"exact garage pose for "+key+" level "+str(level))
	for level in [0,3,0]:
		progress.upgrades=[level,level,level,level,level,level,level,level]
		start_run();entities.clear();car_hp=0;finish_run("The car was destroyed.",false,"Crash")
		death_screen_time=5;await frontend_click("retry")
		expect(state=="garage" and not death_explosion and crash_texture==null,"fatal crash retry clears wreck before garage")
		expect(garage_upgrade_anim==-1 and garage_upgrade_time==0,"garage starts without stale purchase animation")
		var initial:PackedByteArray
		for frame in range(31):
			queue_redraw();await RenderingServer.frame_post_draw
			var shot=get_viewport().get_texture().get_image()
			var car=shot.get_region(Rect2i(500,360,600,280)).get_data()
			if frame==0:initial=car
			expect(car==initial,"garage car stable after crash at level "+str(level)+" frame "+str(frame))
			if frame in [0,1,6,30]:
				var base=ProjectSettings.globalize_path("res://../analysis/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()+"/../analysis/"
				shot.save_png(base+"release25_garage_level"+str(level)+"_frame"+str(frame)+".png")
	# The real purchase animation must still run when explicitly buying windshield.
	progress.upgrades=[0,0,0,0,0,0,0,0];progress.rp=10000;enter_garage()
	expect(buy_upgrade(3) and garage_upgrade_anim==3 and garage_upgrade_time>0,"actual windshield purchase keeps its original animation")
	enter_garage()
	expect(garage_upgrade_anim==-1 and garage_upgrade_time==0,"entering garage clears previous purchase animation")
	expect(art.perf_sync_paint_loads==0 and art.texture_failed.is_empty(),"garage rendering never performs disk loads or failed streaming")
	print("RELEASE25_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func release26_image(name:String):
	queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var base=ProjectSettings.globalize_path("res://../analysis/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()+"/../analysis/"
	var img=get_viewport().get_texture().get_image()
	img.save_png(base+"release26_"+name+".png")
	return img

func run_release26_checks():
	set_process(false);test_mode=true;preview_mode=true;progress.ephemeral=true
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0];rng.seed=260026
	start_run()
	expect(entities.size()==5 and is_equal_approx(next_pattern,100),"source opening has five small fillers before the 100m pattern anchor")
	for e in entities:expect(e.kind in ["shopping_cart","cone","barrel","box","construction_sign","water"] and e.z<100,"opening fillers exclude vehicles and military hazards")
	expect(source_rules.patterns.size()==150 and source_rules.general.size()==55 and source_rules.military.size()==13,"all authored source SVG/SWF road patterns included")
	var seen:Dictionary={}
	for i in range(55):seen[source_pick_pattern("test_general",source_rules.general)]=true
	expect(seen.size()==55,"original RandomHat exhausts layouts before repeating")
	var opening_max=0
	for seed_value in range(100):
		rng.seed=seed_value;progress.checkpoint=0;start_run();post_checkpoint_pending=false
		spawn_source_pattern();opening_max=maxi(opening_max,entities.size())
		expect(last_pattern.name.begins_with("general") and last_pattern.optional==0,"fresh story uses zero optional hazards, seed "+str(seed_value))
		expect(last_pattern.gap>=20 and last_pattern.gap<40 and last_pattern.stretch>=1 and last_pattern.stretch<1.5,"source stretch and pattern spacing")
		for e in entities:expect(e.kind not in ["soldier","hard","super","feeders","spikes"],"chapter zero excludes locked threats")
	progress.checkpoint=8;start_run();post_checkpoint_pending=false;elapsed=10
	expect(position_z==segment_position(8) and spawn_segment==8 and int(source_rules.hazards[segment])==4,"resume starts at saved chapter with that chapter's hazard budget")
	next_hard_pattern=position_z;spawn_source_pattern()
	expect(last_pattern.name in source_rules.hard_patterns[8],"hard road layouts selected from saved chapter's authored pool")
	var authored:Dictionary=source_rules.patterns.general01
	var negative=false
	for item in authored.items:
		if float(item.z)<0:negative=true
	expect(negative,"source pattern coordinates retain offsets before the anchor")
	mode="hardcore";progress.hardcore_checkpoint=0;start_run();post_checkpoint_pending=false;spawn_source_pattern()
	expect(last_pattern.hazard_limit==2 and last_pattern.optional<=2,"hardcore retains original harder opening budget")
	mode="story";progress.checkpoint=0;start_run();post_checkpoint_pending=false
	position_z=segment_position(1)+1;update_progression()
	expect(progress.checkpoint==0,"entering military stretch does not save early")
	checkpoint_message.clear();checkpoint_queue.clear()
	progress.save_path="user://release26_checkpoint_validation.cfg";progress.ephemeral=false
	position_z=segment_position(2)+1;update_progression()
	var restored=Progress.new();restored.save_path=progress.save_path;restored.read_save()
	expect(restored.checkpoint==2 and restored.hardcore_checkpoint==0,"normal checkpoint saved independently and reloads")
	expect(checkpoint_message.title=="Progress Saved..." and checkpoint_message.message=="Monroeville","exact source checkpoint title and area")
	checkpoint_time=0.5;expect(checkpoint_pose().x== -900 and checkpoint_pose().y==1,"popup source half-second delay and initial offset")
	checkpoint_time=0.8;expect(absf(checkpoint_pose().x)<0.01,"popup source Quart slide finishes at 0.8 seconds")
	checkpoint_time=3.3;expect(checkpoint_pose().y==1,"popup holds for 2.5 seconds after slide")
	checkpoint_time=4.3;expect(absf(checkpoint_pose().y)<0.01,"popup source Quart fade completes at 4.3 seconds")
	mode="hardcore";start_run();checkpoint_message.clear();checkpoint_queue.clear()
	position_z=segment_position(2)+1;update_progression();restored.read_save()
	expect(restored.checkpoint==2 and restored.hardcore_checkpoint==2,"hardcore saves without altering normal checkpoint")
	progress.ephemeral=true
	for suffix in ["",".tmp",".bak"]:
		if FileAccess.file_exists(progress.save_path+suffix):DirAccess.remove_absolute(progress.save_path+suffix)
	progress.save_path=Progress.SAVE_PATH
	mode="story";progress.checkpoint=0;start_run();entities.clear();next_pattern=1e9;speed=90;player_x=0
	var stationary=spawn_entity("soldier",0,20);stationary.behavior="stationary"
	update_entities(1.0/60)
	expect(stationary.anim=="soldier_IdleToFire" and stationary.shots==0,"stationary soldier raises rifle before shooting")
	for i in range(14):update_entities(1.0/60)
	expect(stationary.shots==0,"soldier cannot damage player during original eight-frame raise animation")
	for i in range(30):update_entities(1.0/60)
	expect(stationary.shots>0 and glass_hp<100 and health==100,"forward aligned rifle rounds damage windshield")
	var before_glass=glass_hp;player_x=6;var before_shots=int(stationary.shots)
	for i in range(60):update_entities(1.0/60)
	expect(glass_hp==before_glass and stationary.shots>before_shots,"lateral evasion creates misses while rifle continues firing")
	position_z=stationary.z+0.1;update_entities(0.2)
	expect(not stationary.fired and glass_hp==before_glass,"passing the soldier stops bullets and damage")
	start_run();entities.clear();speed=90;player_x=0
	var aligner=spawn_entity("soldier",-6,60);aligner.behavior="align"
	update_entities(1.0/60);var target=float(aligner.adjust_target)
	expect(target>=0 and target<2 and aligner.anim=="soldier_Run","aligner selects the source tactical position once")
	player_x= -7
	for i in range(150):update_entities(1.0/60)
	expect(aligner.adjust_target==target and is_equal_approx(float(aligner.x),target) and aligner.anim=="soldier_Fire","aligner reaches chosen position and holds firing stance")
	expect(glass_hp==100,"aligner shooting from beside the moving car cannot damage it")
	start_run();entities.clear();speed=110;player_x=0
	var hidden=spawn_entity("soldier",0,20);hidden.behavior="hidden";hidden["flip"]=true
	update_entities(1.0/60)
	expect(hidden.anim=="soldier_SlideOut" and hidden.shots==0,"hidden rifleman plays source eleven-frame reveal")
	for i in range(20):update_entities(1.0/60)
	expect(hidden.shots==0 and hidden.x==0,"cover reveal does not double the artwork's slide with physical motion")
	for i in range(20):update_entities(1.0/60)
	expect(hidden.anim=="soldier_SlideFire" and glass_hp<100 and fposmod(100-glass_hp,4)==0,"hidden rifleman uses source four-point windshield damage")
	var after_hidden=glass_hp;player_x=6
	for i in range(120):update_entities(1.0/60)
	expect(glass_hp==after_hidden,"hidden rifleman's off-axis bursts miss")
	start_run();entities.clear();speed=90;player_x=0
	var car=spawn_entity("cars",-4,60)
	var blocked=spawn_entity("soldier",-6,60);blocked.behavior="align";blocked["adjust_target"]=0.0
	for i in range(120):update_entities(1.0/60)
	expect(blocked.x<car.x-car.radius-0.3,"tactical movement respects parked-car cover")
	start_run();entities.clear();speed=0
	var trap=spawn_entity("soldier",-7,2);trap.behavior="spikes";trap["strip"]=spawn_entity("spikes",5,2)
	for i in range(30):update_entities(1.0/60)
	expect(not trap.get("trigger_started",false),"trap distance scales with speed, without artificial six-meter minimum")
	expect(art.world_data.groups.feeders_idle26.size()==45 and art.world_data.groups.feeders.size()==20,"feeding idle and collision sequences remain separate")
	expect(art.world_data.feeders26.unique_frames>5,"source nested feeding animation produces changing poses")
	start_run();entities.clear();next_pattern=1e9;speed=0
	var feeder=spawn_entity("feeders",0,18)
	update_entities(0.6)
	expect(feeder.anim=="feeders_idle26" and feeder.frame==0 and is_equal_approx(float(feeder.anim_time),0.6),"feeding entity advances idle child timeline")
	feeder.anim_time=0;await release26_image("feeder_idle_start")
	feeder.anim_time=0.6;await release26_image("feeder_idle_bite")
	var idle_a=art.world_frame("feeders_idle26",0);var idle_b=art.world_frame("feeders_idle26",18)
	expect(idle_a.rect!=idle_b.rect,"idle bite selects a distinct exact source pose")
	speed=60;collide(feeder)
	expect(feeder.dead and not impacts.is_empty() and impacts[-1].kind=="feeders","collision switches to original hit sequence")
	start_run();entities.clear();next_pattern=1e9;speed=0;notice_time=0;subtitle_time=0
	checkpoint_message.clear();checkpoint_queue.clear();show_checkpoint_message("Progress Saved...","Monroeville");checkpoint_time=1.0
	await release26_image("checkpoint_saved")
	expect(checkpoint_fonts["1777"]!=null and checkpoint_fonts["1778"]!=null and source_rules.message_fields["1777"].font==22 and source_rules.message_fields["1778"].font==20,"original Modern No.20 title and Dirty Ego area fonts loaded")
	rng.seed=260026;start_run();next_pattern=1e9;await release26_image("fresh_opening")
	print("RELEASE26_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," opening_max_entities=",opening_max," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func release27_capture(name:String) -> Image:
	queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img=get_viewport().get_texture().get_image()
	var base=ProjectSettings.globalize_path("res://../analysis/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()+"/../analysis/"
	img.save_png(base+"release27_"+name+".png")
	return img

func run_release27_checks():
	set_process(false);test_mode=true;preview_mode=true;progress.ephemeral=true
	progress.settings.fullscreen=false;progress.settings.shake=false;apply_settings()
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0];rng.seed=270027
	start_run();entities.clear();scenery.clear();road_signs.clear();next_pattern=1e9;speed=0;notice_time=0;subtitle_time=0;checkpoint_message.clear();checkpoint_queue.clear()
	var sides:Dictionary={}
	for i in range(40):
		road_signs.clear();next_road_sign=position_z+50
		update_road_signs(0)
		expect(road_signs.size()==1 and absf(road_signs[0].x)==10.0,"signs spawn at original outside-wall position")
		sides[int(signf(road_signs[0].x))]=true
		expect(next_road_sign>=position_z+200 and next_road_sign<position_z+300,"original sign spacing retained")
	expect(sides.size()==2,"random placement uses both sides of highway")
	# Warm only sign pages for this visual check, keeping frame acquisition out
	# of the captured draws and respecting the normal bounded cache.
	for key in ["highway_sign20","highway_sign_left20","highway_sign_offroad20"]:
		for rec in art.world_data.groups[key]:art.request_texture("world",int(rec.page))
	for i in range(160):art.pump_textures();await get_tree().process_frame
	next_road_sign=1e9
	for width in [1280,1920]:
		RW=float(width);UI_OFFSET=Vector2((RW-W)/2,0);get_window().size=Vector2i(width,720)
		for steer_x in [-7.5,0.0,7.5]:
			player_x=steer_x
			for distance in [18.0,50.0]:
				road_signs.clear()
				var name=str(width)+"_x"+str(steer_x).replace(".","_")+"_z"+str(int(distance))
				var baseline=await release27_capture("wall_baseline_"+name)
				for side in [-1,1]:spawn_source_road_sign(float(side)*10.0,position_z+distance)
				var with_signs=await release27_capture("both_sides_"+name)
				for sign_actor in road_signs:
					expect(absf(sign_actor.x)==10,"both upper signs stay aligned with outside walls during steering")
					for h in [0.25,0.75,1.25,1.75]:
						var pt=project_road_point(float(sign_actor.x),camera_depth(distance),h)
						if pt.x<3 or pt.x>with_signs.get_width()-4 or pt.y<3 or pt.y>with_signs.get_height()-4:continue
						for dx in range(-1,2):
							for dy in range(-1,2):
								var pixel=Vector2i(int(pt.x)+dx,int(pt.y)+dy)
								expect(with_signs.get_pixelv(pixel)==baseline.get_pixelv(pixel),"wall hides lower sign support: "+name+" side "+str(sign_actor.x)+" height "+str(h))
	RW=1280;UI_OFFSET=Vector2(100,0);get_window().size=Vector2i(1280,720)
	print("RELEASE27_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func release28_capture(name:String,canvas:Node2D=null) -> Image:
	queue_redraw()
	if canvas!=null:canvas.queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var img=get_viewport().get_texture().get_image()
	if not name.is_empty():
		var base=ProjectSettings.globalize_path("res://../analysis/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()+"/../analysis/"
		img.save_png(base+"release28_"+name+".png")
	return img

func run_release28_checks():
	set_process(false);test_mode=true;preview_mode=true;progress.ephemeral=true
	progress.settings.fullscreen=false;progress.settings.shake=false;apply_settings()
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0];rng.seed=280028
	start_run();entities.clear();scenery.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;speed=0;notice_time=0;subtitle_time=0;checkpoint_message.clear();checkpoint_queue.clear()
	# Render the actual gameplay geometry above a conspicuous background.
	# Sampling the original sloped polygons catches any exposed scenery/ground,
	# including the former flat-shoulder gap, without relying on a similar gray.
	var sentinel=Color(1,0,1,1)
	var canvas=Node2D.new();canvas.z_index=100;add_child(canvas)
	canvas.draw.connect(func():canvas.draw_rect(Rect2(0,0,RW,H),sentinel);draw_highway_geometry(canvas))
	var checked=0;var missing=0;var legacy_gaps=0;var cases=0
	for width in [1280,1920]:
		RW=float(width);UI_OFFSET=Vector2((RW-W)/2,0);get_window().size=Vector2i(width,720)
		for crash in [false,true]:
			state="results" if crash else "play";death_explosion=crash;death_screen_time=3.5 if crash else 0.0
			for steer_x in [-9.0,0.0,9.0]:
				player_x=steer_x
				for phase in [0.0,0.05,13.0,27.85]:
					position_z=280.0+camera_back_offset()+phase
					var name="geometry_"+str(width)+"_x"+str(steer_x)+"_crash"+str(crash) if phase==13 else ""
					var img=await release28_capture(name,canvas);cases+=1
					for i in range(8):
						var z1=maxf(i*28.0-phase,0.1);var z2=minf((i+1)*28.0-phase,200.0)
						if z2<=z1:continue
						var road=PackedVector2Array([project_road_point(-7.5,z1),project_road_point(-7.5,z2),project_road_point(7.5,z2),project_road_point(7.5,z1)])
						for side in [-1,1]:
							var inner1=project_road_point(side*7.5,z1);var inner2=project_road_point(side*7.5,z2)
							var shoulder=PackedVector2Array([inner1,inner2,project_road_point(side*10.0,z2,0.1),project_road_point(side*10.0,z1,0.1)])
							var flat=PackedVector2Array([project_road_point(side*7.5,z1,0.1),project_road_point(side*7.5,z2,0.1),project_road_point(side*10.0,z2,0.1),project_road_point(side*10.0,z1,0.1)])
							for step in range(1,20):
								var join=inner1.lerp(inner2,step/20.0)
								if join.x<5 or join.x>img.get_width()-6 or join.y<220 or join.y>img.get_height()-6:continue
								for dx in range(-3,4):
									for dy in range(-6,3):
										var pixel=Vector2i(int(join.x)+dx,int(join.y)+dy)
										var center=Vector2(pixel)+Vector2(0.5,0.5)
										if not Geometry2D.is_point_in_polygon(center,shoulder) and not Geometry2D.is_point_in_polygon(center,road):continue
										checked+=1
										if not Geometry2D.is_point_in_polygon(center,flat) and not Geometry2D.is_point_in_polygon(center,road):legacy_gaps+=1
										if img.get_pixelv(pixel)==sentinel:missing+=1
	expect(cases==48 and checked>1000,"road joins checked across both sides, widths, steering, road phases and retreating crash camera")
	expect(legacy_gaps>100,"regression samples include pixels exposed by the previous flat sidewalks")
	expect(missing==0,"no exposed background pixels at sidewalk/road joins: "+str(missing)+" of "+str(checked))
	canvas.queue_free();await get_tree().process_frame
	state="play";death_explosion=false;death_screen_time=0;position_z=293;player_x=0
	# Inspect real building art against both walls with the cockpit and signs.
	for i in range(12):scenery.append({"x":-12.1 if i%2==0 else 12.1,"z":position_z+14+i*8.0,"frame":i%art.count("buildings"),"height":18.0})
	for key in ["buildings","highway_sign20","highway_sign_left20","highway_sign_offroad20"]:
		for rec in art.world_data.groups[key]:art.request_texture("world",int(rec.page))
	for i in range(160):art.pump_textures();await get_tree().process_frame
	for side in [-1,1]:spawn_source_road_sign(side*10.0,position_z+50)
	for steer_x in [-7.5,0.0,7.5]:
		player_x=steer_x
		await release28_capture("buildings_both_sides_x"+str(steer_x))
	print("RELEASE28_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," cases=",cases," sampled_pixels=",checked," former_gap_pixels=",legacy_gaps," exposed_pixels=",missing," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

# Native RDPlayer.PlayRandomVoice: radio gates Extra/Gameplay voices before
# chance selection. RandomHat consumes each recording once before refilling.
func source_player_voice(name:String,chance:float=1.0,priority:int=1,gain:float=-7.0) -> bool:
	if priority!=3 and (awarded or segment>=21):return false
	if priority in [1,2] and snd.radio.playing:return false
	if rng.randf()>=chance:return false
	if not player_voice_bags.has(name) or player_voice_bags[name].is_empty():
		player_voice_bags[name]=art.world_data.get("sounds16",{}).get(name,[]).duplicate()
	var bag:Array=player_voice_bags[name]
	if bag.is_empty():return false
	var key=String(bag.pop_at(rng.randi_range(0,bag.size()-1)))
	snd.player_reaction(key,priority,gain)
	return true

func update_nuke_dialogue():
	# RDGameModeStory: warning at 15 seconds; spoken count uses ceil(10..1).
	var call=11 if nuke_time<=15 and nuke_time>10 else (int(ceil(nuke_time)) if nuke_time<=10 and nuke_time>0 else -1)
	if call==last_nuke_call:return
	last_nuke_call=call
	if call==11:snd.play_radio("NukeRunCountStart",2)
	elif call>0:snd.play_radio("NukeRunCount"+str(call),2)

func source_radio_bag(name:String):
	if awarded:return
	if not player_voice_bags.has(name) or player_voice_bags[name].is_empty():
		player_voice_bags[name]=art.world_data.get("sounds16",{}).get(name,[]).duplicate()
	var bag:Array=player_voice_bags[name]
	if not bag.is_empty():snd.play_radio(String(bag.pop_at(rng.randi_range(0,bag.size()-1))),0)

func run_release29_checks():
	set_process(false);test_mode=true;preview_mode=true;progress.ephemeral=true
	AudioServer.set_bus_volume_db(0,-80)
	snd.silent=false;snd.enabled=true;snd.music_enabled=false;snd.music.stop()
	mode="story";progress.checkpoint=0;progress.upgrades=[0,0,3,0,0,3,0,0];progress.settings.garage_seen=true
	start_run();entities.clear();scenery.clear();next_pattern=1e9;next_road_sign=1e9
	var events:Array=[];var radio_events:Array=[]
	snd.voice_started.connect(func(key,_caption,_duration):events.append({"key":key,"t":Time.get_ticks_msec()}))
	snd.radio_started.connect(func(key,_duration):radio_events.append({"key":key,"t":Time.get_ticks_msec()}))
	# Each scenario goes through gameplay collide(), not a fake sound mapping.
	var counts:Dictionary={}
	for kind in ["civilian","male","female","hard","soldier"]:
		var total=0
		for i in range(120):
			snd.clear_voice();events.clear();rng.seed=290000+i*31
			speed=110;health=100;car_hp=100;armor_level=3;hood.clear();dying_hood.clear();hit_cooldown=0;impacts.clear()
			var e=spawn_entity(kind,0.8,position_z+1);collide(e)
			for event in events:
				total+=1
				expect(String(event.key).begins_with("PlayerHitCiv" if kind=="civilian" else "PlayerHitEnemy"),"correct John reaction for "+kind+": "+String(event.key))
			expect(snd.voice_queue.is_empty(),"collision reactions are never deferred")
			entities.clear()
		counts[kind]=total
		expect(total>10 and total<60,"original 25 percent reaction chance for "+kind+": "+str(total))
	# Precision response is zombie-only, followed by normal enemy chance.
	for kind in ["male","soldier"]:
		var precise=0
		for i in range(100):
			snd.clear_voice();events.clear();rng.seed=291000+i*17
			speed=110;car_hp=100;armor_level=3;hood.clear();dying_hood.clear();hit_cooldown=0;impacts.clear()
			var e=spawn_entity(kind,0.0,position_z+1);collide(e)
			for event in events:
				if String(event.key).begins_with("PlayerPreciseHit"):precise+=1
			entities.clear()
		expect(precise>20 if kind=="male" else precise==0,"precision voice belongs to original zombie event: "+kind+" "+str(precise))
	# RandomHat avoids repeated clips until the whole original bag is consumed.
	for bag_name in ["RDPlayer.m_HitCivilianVoices","RDPlayer.m_HitEnemyVoices","RDPlayer.m_BulletHitVoices","RDPlayer.m_CarOnFireVoices","RDPlayer.m_DeathScreamVoices","RDPlayer.m_FatalBulletHitVoices"]:
		player_voice_bags.erase(bag_name)
		var records:Array=art.world_data.sounds16.get(bag_name,[]);var seen:Dictionary={}
		expect(not records.is_empty(),"original voice bag exists: "+bag_name)
		for i in records.size():
			snd.clear_voice();events.clear();source_player_voice(bag_name,1.0,3)
			expect(events.size()==1,"original clip starts immediately: "+bag_name)
			if events.is_empty():continue
			var key=String(events[0].key)
			expect(not seen.has(key) and snd.stream(key)!=null,"no repeats or missing recordings before bag refill: "+key)
			seen[key]=true
	# Native channels and priority: grunts can accompany radio, extra/gameplay
	# speech is suppressed during a radio call, and story supersedes air support.
	snd.clear_voice();events.clear();radio_events.clear()
	snd.play_radio("HelicopterDispatch01",1)
	expect(snd.radio_key=="HelicopterDispatch01" and snd.radio.playing,"air radio starts at its event")
	source_player_voice("RDPlayer.m_HitCivilianVoices",1.0,1)
	expect(snd.voice_key.is_empty() and snd.voice_queue.is_empty(),"radio blocks optional collision speech without queuing it")
	source_player_voice("RDPlayer.m_HugeCollisionGruntVoices",1.0,0)
	expect(snd.voice_key.begins_with("PlayerHeavyGrunt") and snd.voice.playing and snd.radio.playing,"collision grunt and radio have independent source channels")
	snd.play_radio("CheckPoint0Post",2)
	expect(snd.radio_key=="CheckPoint0Post" and source_story_dialog_active(),"story immediately supersedes lower-priority radio")
	snd.play_radio("ApproachStationarySoldier02",0)
	expect(snd.radio_key=="CheckPoint0Post" and snd.voice_queue.is_empty(),"soldier cue cannot delay or replace story")
	snd.clear_radio();snd.play_radio("CheckPoint1Pre",2)
	post_checkpoint_pending=false
	expect(not source_story_dialog_active(),"original spawn gate watches post dialogue, not pre dialogue")
	snd.clear_voice();events.clear()
	snd.player_reaction("PlayerHitEnemy01",1)
	snd.player_reaction("PlayerHeavyGrunt01",0)
	expect(snd.voice_key=="PlayerHitEnemy01","generic grunt cannot replace optional speech")
	snd.player_reaction("PlayerFire01",2)
	expect(snd.voice_key=="PlayerFire01","urgent fire replaces lower-priority reaction immediately")
	snd.player_reaction("PlayerHitCiv01",1)
	expect(snd.voice_key=="PlayerFire01" and snd.voice_queue.is_empty(),"lower priority collision is discarded")
	# A real AudioStreamPlayer finished signal must allow the next event without
	# the old 2.5-second garage/radio queue delay.
	snd.clear_voice();snd.player_reaction("PlayerLightGrunt01",0)
	var deadline=Time.get_ticks_msec()+10000
	while not snd.voice_key.is_empty() and Time.get_ticks_msec()<deadline:await get_tree().process_frame
	expect(snd.voice_key.is_empty() and snd.voice_gap_left==0,"actual gameplay clip completion has no artificial gap")
	snd.player_reaction("PlayerHitCiv01",1)
	expect(snd.voice_key=="PlayerHitCiv01" and snd.voice.playing,"new event is accepted immediately after completion")
	# Actual chapter thresholds and resume behavior.
	start_run();next_pattern=1e9;entities.clear();snd.clear_voice()
	position_z=segment_start+float(source_rules.post_margins[0])-0.1;update_progression()
	expect(snd.radio_key.is_empty() and post_checkpoint_pending,"opening waits for original post margin")
	position_z+=0.2;update_progression()
	expect(snd.radio_key=="CheckPoint0Post" and not post_checkpoint_pending,"opening radio starts at original margin")
	snd.clear_voice();position_z=segment_start+float(LENGTHS[0])-float(source_rules.pre_margins[0])+0.1;update_progression()
	expect(snd.radio_key=="CheckPoint1Pre","first checkpoint pre radio uses original next-checkpoint recording")
	snd.clear_voice();progress.checkpoint=6;start_run();next_pattern=1e9;entities.clear()
	position_z=segment_start+float(source_rules.post_margins[3])+0.1;update_progression()
	expect(snd.radio_key=="CheckPoint3Post","resume uses current chapter post recording")
	# Nuke announcement at 15s and ceil-based spoken 10..1, not every 10s.
	snd.clear_voice();segment=20;last_nuke_call=-1;nuke_time=119;update_nuke_dialogue()
	expect(snd.radio_key.is_empty(),"no early countdown at 120 seconds")
	nuke_time=15;update_nuke_dialogue();expect(snd.radio_key=="NukeRunCountStart","countdown warning starts at 15 seconds")
	snd.clear_radio();nuke_time=9.9;update_nuke_dialogue();expect(snd.radio_key=="NukeRunCount10","ceil countdown speaks ten near 10 seconds")
	snd.clear_radio();nuke_time=8.9;update_nuke_dialogue();expect(snd.radio_key=="NukeRunCount9","countdown follows current remaining seconds")
	# Original hood/fire/ammo reactions; scene changes cancel both channels.
	progress.checkpoint=0;start_run();entities.clear();next_pattern=1e9
	car_hp=15;armor_level=0;cooled=false;fire_started=false;simulate(0.01,0,false,false,0)
	expect(snd.voice_key.begins_with("PlayerFire"),"engine fire uses an existing original clip")
	snd.clear_voice();hood={"kind":"male","hp":50.0,"grip":0.0,"anim":"Idle","anim_time":0.0};hood_reacted=false;ammo=2
	attack();update_action_animation(0.7)
	expect(snd.voice_key.begins_with("PlayerShootHoodEnemy"),"shooting a clinger triggers original reaction")
	attack_time=0;snd.clear_voice();hood={"kind":"male","hp":50.0,"grip":0.0,"anim":"Idle","anim_time":0.0};ammo=1
	attack();update_action_animation(0.7)
	expect(snd.voice_key.begins_with("PlayerGunEmpty"),"last bullet's gameplay-priority line supersedes hood reaction")
	start_run();snd.play_radio("CheckPoint0Post",2);finish_run("death",false,"Zombie")
	expect(snd.radio_key.is_empty() and snd.voice_key.begins_with("PlayerDevoured"),"fatal event cancels radio and plays original crucial scream")
	snd.play_radio("JetHit01",1);expect(snd.radio_key.is_empty(),"dead player receives no late air radio")
	enter_garage();expect(not snd.gameplay_dialogue and snd.radio_key.is_empty() and snd.voice_key.begins_with("PlayerDeathZombie"),"garage keeps its existing death dialogue")
	open_menu();expect(snd.voice_key.is_empty() and snd.radio_key.is_empty() and snd.voice_queue.is_empty(),"scene transition clears all gameplay dialogue")
	print("RELEASE29_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," collisions=",JSON.stringify(counts)," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func release30_image(name:String):
	queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image=get_viewport().get_texture().get_image()
	var base=ProjectSettings.globalize_path("res://../analysis/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()+"/../analysis/"
	expect(image.save_png(base+"release30_"+name+".png")==OK,"dialog screenshot "+name)
	return image

func run_release30_checks():
	set_process(false);test_mode=true;preview_mode=true;progress.ephemeral=true;ui_audio_check=true
	progress.settings.fullscreen=false;apply_settings();panel_anim=1.0
	open_menu();activate("options");panel_anim=1.0
	progress.rp=345;progress.checkpoint=6;progress.hardcore_checkpoint=4;progress.upgrades=[1,2,1,0,2,1,2,0];progress.best=4500;progress.finished=true
	var saved_keys:Array=progress.settings.keys.duplicate()
	var before=JSON.stringify([progress.rp,progress.checkpoint,progress.hardcore_checkpoint,progress.upgrades,progress.best,progress.finished])
	for width in [1280,1920]:
		RW=float(width);UI_OFFSET=Vector2((RW-W)/2,0);get_window().size=Vector2i(width,720)
		activate("delete_save");check_mouse=Vector2.ZERO
		await release30_image("delete_"+str(width))
		expect(buttons.size()==2 and buttons[0].id=="delete_yes" and buttons[1].id=="delete_cancel","only native confirmation buttons are interactive")
		for b in buttons:
			var original=art.menu_data.buttons["confirm_YesButton" if b.id=="delete_yes" else "confirm_NoButton"].rect
			expect(b.rect==Rect2(original[0],original[1],original[2],original[3]),"authored Yes/No hit targets retained")
		check_mouse=buttons[0].rect.get_center();await release30_image("delete_yes_hover_"+str(width))
		check_mouse=buttons[1].rect.get_center();await release30_image("delete_no_hover_"+str(width))
		var old_music=progress.settings.music
		activate("music")
		expect(progress.settings.music==old_music,"confirmation blocks underlying option activation")
		var cancel=InputEventKey.new();cancel.physical_keycode=KEY_ESCAPE;cancel.pressed=true;_input(cancel)
		expect(not delete_confirm and state=="options" and before==JSON.stringify([progress.rp,progress.checkpoint,progress.hardcore_checkpoint,progress.upgrades,progress.best,progress.finished]),"Escape cancels dialog and preserves progress")
		activate("delete_save");await frontend_click("delete_cancel")
		expect(not delete_confirm and state=="options" and progress.rp==345,"original No button cancels without deleting")
		activate("rebind_0");await release30_image("inline_key_capture_"+str(width))
		expect(rebind_index==0 and buttons.size()>2,"native key field editing leaves option artwork visible")
		var key=InputEventKey.new();key.physical_keycode=KEY_ESCAPE;key.pressed=true;_input(key)
		expect(rebind_index==-1 and progress.settings.keys==saved_keys,"Escape cancels original inline key capture")
		activate("rebind_0");key.physical_keycode=int(saved_keys[1]);_input(key)
		expect(progress.settings.keys[0]==saved_keys[1] and progress.settings.keys[1]==saved_keys[0],"binding duplicate keys keeps swap behavior")
		progress.settings.keys=saved_keys.duplicate()
		ui_message="Escape the city to unlock Hardcore.";ui_message_time=2;await release30_image("status_sign_"+str(width));ui_message_time=0
	# Exercise deletion only against ephemeral test progress. Real save is never read.
	activate("delete_save");await frontend_click("delete_yes")
	expect(progress.rp==0 and progress.checkpoint==0 and progress.hardcore_checkpoint==0 and progress.best==0 and not progress.finished and progress.upgrades==[0,0,0,0,0,0,0,0],"native Yes button deletes only explicitly confirmed test progress")
	expect(progress.settings.keys==saved_keys,"deletion preserves control bindings")
	await release30_image("deleted_feedback");ui_message_time=0
	activate("delete_yes");expect(not delete_confirm,"delete cannot run without an open confirmation")
	activate("options_close");expect(state=="menu" and not delete_confirm and rebind_index==-1,"closing options clears transient dialogs")
	activate("story");await release30_image("story_confirmation");confirm_mode("cancel")
	activate("police");await release30_image("challenge_confirmation");confirm_mode("cancel")
	# Paused options use the same dialog and return with driving still paused.
	mode="story";start_run();set_pause();activate("options");panel_anim=1.0;activate("delete_save")
	await release30_image("paused_options_delete");activate("delete_cancel");activate("options_close")
	expect(state=="paused" and snd.action_paused,"native modal does not resume paused gameplay")
	print("RELEASE30_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

var release31_isolated=false
var release31_reference:Dictionary={}

func release31_reference_draw(canvas:Node2D):
	canvas.draw_rect(Rect2(0,0,RW,H),Color("#e7aa78"))
	var r=release31_reference
	var record:Dictionary=art.world_data.groups[r.kind][int(r.frame)]
	# Independent RDObstacle/RDEntity projection: player+.1 minus camera(player-1).
	var depth=1.1+camera_back_offset()
	var source_scale=3.5 if r.kind=="fence" else (3.0 if r.kind=="feeders" else 1.0)
	var scale=source_scale*0.0034959*camera_focal().y/depth/maxf(1.0,float(record.get("density",1.0)))
	var point=Vector2(RW*.5+float(r.offset)*camera_focal().x/depth,camera_horizon()+(camera_height()-pow(depth/300.0,2)*11.66667)*camera_focal().y/depth)
	var region=Rect2(record.rect[0],record.rect[1],record.rect[2],record.rect[3])
	var offset=Vector2(record.offset[0],record.offset[1])
	var flipped=r.kind!="electronic_sign" and float(r.offset)<0.0
	if flipped:canvas.draw_set_transform(Vector2(point.x*2,0),0,Vector2(-1,1))
	canvas.draw_texture_rect_region(art.world_pages[int(record.page)],Rect2(point+offset*scale,region.size*scale),region)
	if flipped:canvas.draw_set_transform(Vector2.ZERO)

func release31_capture(name:String,save:bool=true) -> Image:
	queue_redraw()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image=get_viewport().get_texture().get_image()
	if save:
		var base=ProjectSettings.globalize_path("res://../analysis/") if OS.has_feature("editor") else OS.get_executable_path().get_base_dir()+"/../analysis/"
		expect(image.save_png(base+"release31_"+name+".png")==OK,"hit animation screenshot "+name)
	return image

func run_release31_checks():
	set_process(false);test_mode=true;preview_mode=true;progress.ephemeral=true;ui_audio_check=true
	progress.settings.fullscreen=false;apply_settings();mode="story";start_run()
	entities.clear();road_signs.clear();notice_time=0;subtitle_time=0;checkpoint_message.clear();checkpoint_queue.clear()
	var original_counts={"cone":10,"barrel":9,"box":9,"construction_sign":9,"electronic_sign":18,"fence":15,"shopping_cart":25,"water":19,"feeders":20}
	var reference_canvas=Node2D.new();reference_canvas.z_index=100;reference_canvas.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
	reference_canvas.draw.connect(func():release31_reference_draw(reference_canvas));add_child(reference_canvas);reference_canvas.hide()
	var rendered=0;var sampled=0;var mismatch=0;var legacy_mismatch=0
	for kind in original_counts:
		var rows:Array=art.world_data.groups[kind]
		expect(rows.size()==int(original_counts[kind]),"native destroy frame count "+kind)
		# Verify the spawn-time request covers every collision texture page.
		art.prefetch_actor(kind)
		for row in rows:
			var id="world:"+str(int(row.page))
			expect(art.world_pages.has(int(row.page)) or art.texture_queued.has(id) or art.texture_pending.has(id),"all short animation pages requested before impact "+kind+" "+id)
		var loaded=false
		for _wait in range(500):
			art.pump_textures();loaded=true
			for row in rows:
				if not art.world_pages.has(int(row.page)):loaded=false
			if loaded:break
			await get_tree().process_frame
		expect(loaded,"collision animation textures ready "+kind)
		if not loaded:continue
		for side in [-0.25,0.25]:
			RW=1920.0 if side>0 and kind in ["cone","construction_sign","electronic_sign"] else 1280.0
			UI_OFFSET=Vector2((RW-W)/2,0);get_window().size=Vector2i(int(RW),720)
			state="play";awarded=false;death_explosion=false;health=100;car_hp=100;speed=90;player_x=1.5;position_z=1200;entities.clear();impacts.clear()
			var obstacle=spawn_entity(kind,player_x+side,position_z+0.5);obstacle.last_z=3.0
			update_entities(0.0)
			expect(impacts.size()==1 and entities.is_empty(),"real collision replaces object once "+kind)
			if impacts.is_empty():continue
			var impact:Dictionary=impacts[0]
			var hp=car_hp;var impact_speed=speed
			update_entities(0.0)
			expect(impacts.size()==1 and car_hp==hp and speed==impact_speed,"destroyed prop cannot hit again "+kind)
			player_x+=2.0;position_z+=25.0
			var pose=world_impact_position(impact)
			expect(is_equal_approx(pose.y,1.1) and is_equal_approx(pose.x-player_x,side),"source attachment follows car movement "+kind)
			expect(bool(impact.flip)==(side<0 and kind!="electronic_sign"),"original directional hit flip "+kind)
			if kind in ["cone","barrel","box"]:expect(hp==100 and impact_speed==90,"harmless prop still has no damage or braking "+kind)
			release31_isolated=true
			for frame in [2,3,5]:
				impact.time=float(frame-1)/30.0+0.000001
				release31_reference={"kind":kind,"frame":frame,"offset":side}
				reference_canvas.hide()
				var actual=await release31_capture(kind+"_"+("left" if side<0 else "right")+"_frame"+str(frame))
				reference_canvas.show();reference_canvas.queue_redraw()
				var source_image=await release31_capture("reference",false)
				var case_mismatch=0
				for y in range(4,720,8):
					for x in range(4,int(RW),8):
						sampled+=1
						if actual.get_pixel(x,y)!=source_image.get_pixel(x,y):case_mismatch+=1
				mismatch+=case_mismatch;rendered+=1
				expect(case_mismatch==0,"rendered hit stays at original close depth "+kind+" side "+str(side)+" frame "+str(frame)+": "+str(case_mismatch))
				if kind=="cone" and side>0 and frame==3:
					reference_canvas.hide();var legacy=impact.duplicate();legacy.erase("attach_offset_x");legacy.erase("depth");legacy.attached=false;legacy.x=player_x+side;impacts=[legacy]
					var wrong=await release31_capture("former_far_cone",false)
					for y in range(4,720,8):
						for x in range(4,int(RW),8):
							if wrong.get_pixel(x,y)!=source_image.get_pixel(x,y):legacy_mismatch+=1
					impacts=[impact]
					expect(legacy_mismatch>100,"render comparison detects former distant-animation bug")
				reference_canvas.hide()
			# Pause freezes the impact; completion removes it instead of looping to idle.
			release31_isolated=false;impact.time=0.05;state="paused"
			simulate(0.2,0,false,false,0);expect(impact.time==0.05,"paused hit animation remains frozen "+kind)
			state="play";update_world_effects(1.0)
			expect(impacts.is_empty(),"native collision timeline completes without idle replay "+kind)
	# Real driving screenshots include cockpit occlusion and the retreating crash camera.
	RW=1280;UI_OFFSET=Vector2(100,0);get_window().size=Vector2i(1280,720);player_x=0;position_z=1000;entities.clear();impacts.clear();state="play";awarded=false;death_explosion=false
	for kind in ["cone","construction_sign","electronic_sign"]:
		impacts.clear();health=100;car_hp=100;speed=90
		collide(spawn_entity(kind,-0.25,position_z+1.5));entities.clear()
		# Publication is manual because this test disables the normal process loop.
		var first_page=int(art.world_data.groups[kind][2].page)
		for _wait in range(500):
			art.pump_textures()
			if art.world_pages.has(first_page):break
			await get_tree().process_frame
		expect(art.world_pages.has(first_page),"cockpit hit texture ready "+kind)
		notice_time=0;subtitle_time=0
		impacts[0].time=1.0/30.0+0.000001
		await release31_capture(kind+"_cockpit")
		if kind=="cone":
			car_hp=0;finish_run("The car was destroyed.",false,"Crash");death_screen_time=0.0
			await release31_capture("cone_crash_camera")
			var p=world_impact_position(impacts[0]);expect(is_equal_approx(camera_depth(p.y),6.1),"car-attached object shares retreating crash camera")
			state="play";awarded=false;death_explosion=false
	open_menu();start_run();expect(impacts.is_empty(),"new run clears collision effects")
	reference_canvas.queue_free();release31_isolated=false
	print("RELEASE31_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," rendered=",rendered," samples=",sampled," mismatched=",mismatch," former_bug_mismatches=",legacy_mismatch," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

# Original MC_TutorialDialog and RDGameModeGameplay.DisplayStartTutorial.
var tutorial_data:Dictionary={}
var tutorial_panel:Texture2D
var tutorial_body_font:Font
var tutorial_title_font:Font
var tutorial_buttons:Dictionary={}
var tutorial_queue:Array=[]
var tutorial_current:Dictionary={}
var tutorial_clock=0.0
var tutorial_closing=false
var tutorial_fade_clock=0.0
var abort_confirm=false
var abort_y=-90.0
var abort_from_y=-90.0
var abort_target_y=-90.0
var abort_clock=0.4

func prepare_original_tutorial():
	tutorial_data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/tutorial32/tutorial.json"))
	tutorial_panel=load("res://assets/tutorial32/panel.png")
	tutorial_body_font=load("res://assets/tutorial32/body.ttf")
	tutorial_title_font=load("res://assets/tutorial32/title.ttf")
	for name in ["up","over","down"]:tutorial_buttons[name]=load("res://assets/tutorial32/"+String(tutorial_data.buttons[name].file))

func clear_original_tutorial():
	tutorial_queue.clear();tutorial_current.clear();tutorial_clock=0.0;tutorial_closing=false;tutorial_fade_clock=0.0

func original_tutorial_active() -> bool:
	return not tutorial_queue.is_empty() or not tutorial_current.is_empty() and not tutorial_closing

func show_original_tutorial(title:String):
	var body=String(tutorial_data.texts.get(title,""))
	if body.is_empty():return
	for i in range(10):body=body.replace("{key"+str(i)+"}",OS.get_keycode_string(int(progress.settings.keys[i])))
	tutorial_queue.append({"title":title,"body":body})

func setup_original_tutorials():
	var sequences=[["Basic Controls","Aborting","Quality"],["Hand Brake"],["Wipers"],["Horn"],["Punching"],["Splatter Hits"],["Hit Combos"]]
	var index=clampi(int(progress.settings.tutorial_index),0,7)
	if index<sequences.size():
		for title in sequences[index]:show_original_tutorial(title)
		progress.settings.tutorial_index=index+1
	for title in ["Pistol","Helicopters","Mutated Zombies","Water Jugs","Enemies On Hood","No Windshield","Perception"]:
		var eligible=progress.upgrades[2]>0 if title=="Pistol" else (progress.upgrades[0]>0 if title=="Perception" else title in progress.settings.tutorial_encounters)
		if eligible and title not in progress.settings.tutorial_seen:
			show_original_tutorial(title);progress.settings.tutorial_seen.append(title)
	progress.save()

func record_tutorial_encounter(title:String):
	if title not in progress.settings.tutorial_encounters:progress.settings.tutorial_encounters.append(title)

func update_original_tutorial(dt:float):
	if tutorial_current.is_empty() and not tutorial_queue.is_empty():
		tutorial_current=tutorial_queue.pop_front();tutorial_clock=0.0;tutorial_closing=false;snd.play("UpgradePerception",-8)
	if not tutorial_current.is_empty():
		tutorial_clock+=dt
		if tutorial_closing:
			tutorial_fade_clock+=dt
			if tutorial_fade_clock>=0.25:tutorial_current.clear();tutorial_closing=false

func dismiss_original_tutorial():
	if tutorial_clock<0.9 or tutorial_current.is_empty() or tutorial_closing:return
	tutorial_closing=true;tutorial_fade_clock=0.0

func draw_original_tutorial():
	if tutorial_current.is_empty():return
	var slide=-1080.0*pow(1.0-clampf((tutorial_clock-0.5)/0.4,0,1),4)
	var alpha=pow(1.0-clampf(tutorial_fade_clock/0.25,0,1),4) if tutorial_closing else 1.0
	var extra=Vector2(slide,0);var color=Color(1,1,1,alpha)
	draw_texture(tutorial_panel,extra,color)
	var b:Array=tutorial_data.body_rect;var t:Array=tutorial_data.title_rect
	draw_wrapped_text(String(tutorial_current.title),Rect2(Vector2(t[0],t[1])+extra,Vector2(t[2],t[3])),int(tutorial_data.title_size),color,tutorial_title_font,true)
	draw_wrapped_text(String(tutorial_current.body),Rect2(Vector2(b[0],b[1])+extra,Vector2(b[2],b[3])),int(tutorial_data.body_size),color,tutorial_body_font)

func abort_button_rect() -> Rect2:
	var r:Array=tutorial_data.buttons.hittest.rect
	return Rect2(Vector2(540+float(r[0]),abort_y+float(r[1])),Vector2(r[2],r[3]))

func update_original_abort(dt:float):
	var hover=abort_button_rect().has_point(get_global_mouse_position()-UI_OFFSET)
	var target=0.0 if hover else -90.0
	if target!=abort_target_y:abort_from_y=abort_y;abort_target_y=target;abort_clock=0.0
	abort_clock=minf(0.4,abort_clock+dt)
	abort_y=lerpf(abort_from_y,abort_target_y,1.0-pow(1.0-abort_clock/0.4,2))

func draw_original_abort():
	var hover=abort_button_rect().has_point(get_global_mouse_position()-UI_OFFSET)
	var pose=("down" if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else "over") if hover else "up"
	var r:Array=tutorial_data.buttons[pose].rect
	draw_texture(tutorial_buttons[pose],Vector2(540+float(r[0]),abort_y+float(r[1])))

func abort_choice(yes:bool):
	if not abort_confirm:return
	abort_confirm=false
	if yes:
		clear_original_tutorial();progress.save();enter_garage()
	else:resume_run()

func draw_abort_confirmation():
	draw_source_confirmation("Abort your escape and\nreturn to the garage?")
	flash_button("confirm_YesButton","abort_yes")
	flash_button("confirm_NoButton","abort_no")

func attach_soldier_strip(e:Dictionary):
	var strip=spawn_entity("spikes",5.0 if float(e.x)<0 else -5.0,float(e.z))
	strip["operator_serial"]=int(e.serial);strip["source_type"]="SoldierSpikesStrip";e["strip"]=strip

func collision_overlap(e:Dictionary) -> bool:
	# RDWorld.EntityOverlapsInX: player [-1,1], original entity bounds.
	return float(e.x)-float(e.radius)<=player_x+1.0 and float(e.x)+float(e.radius)>=player_x-1.0

func release32_capture(name:String):
	queue_redraw();await RenderingServer.frame_post_draw
	var base=ProjectSettings.globalize_path("res://../analysis/") if not OS.has_feature("standalone") else OS.get_executable_path().get_base_dir().path_join("../analysis/")
	expect(get_viewport().get_texture().get_image().save_png(base+"release32_"+name+".png")==OK,"release32 screenshot "+name)

func run_release32_checks():
	set_process(false);test_mode=true;preview_mode=false;progress.ephemeral=true
	progress.settings.fullscreen=false;apply_settings();mode="story";progress.checkpoint=0;progress.upgrades=[0,0,0,0,0,0,0,0];start_run()
	print("RELEASE32_STAGE: collisions")
	var cases=0;var timeline_frames=0;var spawn_strips=0
	var widths={"cone":0.5,"barrel":0.5,"box":0.5,"construction_sign":0.5,"electronic_sign":0.5,"fence":2.0,"shopping_cart":0.5,"water":0.5,"feeders":1.0,"oil":1.5,"spikes":2.5,"male":0.5,"female":0.5,"hard":0.5,"super":0.5,"soldier":0.5,"civilian":0.5}
	for kind in widths:
		for side in [-1.0,1.0]:
			for gap in [-0.02,0.0,0.02]:
				entities.clear();impacts.clear();hood.clear();dying_hood.clear();effects.clear();speed=110;car_hp=100;health=100;glass_hp=100;tires=0;tire_damage=0;player_x=0;position_z=1000;armor_level=0;hit_cooldown=0
				var e=spawn_entity(kind,side*(float(widths[kind])+1.0+gap),position_z+0.5)
				e.moving=false;e.behavior="stationary";e.last_z=5.0
				expect(is_equal_approx(float(e.radius),float(widths[kind])),"source bounds "+kind)
				update_entities(0.0)
				expect(bool(e.hit)==(gap<=0.0),"left/right edge collision "+kind+" "+str(side)+" "+str(gap));cases+=1
				var hp=car_hp;var tires_before=tires;var kill_count=kills+soldier_kills+civilians_hit;var impact_count=impacts.size()
				update_entities(0.0)
				expect(car_hp==hp and tires==tires_before and kills+soldier_kills+civilians_hit==kill_count and impacts.size()==impact_count,"one collision per crossing "+kind)
	# Fast forward step jumps entirely across the old contact window.
	for kind in widths:
		entities.clear();impacts.clear();hood.clear();dying_hood.clear();effects.clear();speed=110;player_x=0;car_hp=100;health=100;armor_level=0
		var e=spawn_entity(kind,0,position_z+10);e.last_z=10.0;e.z=position_z-6.0;e.moving=false;e.behavior="stationary"
		update_entities(0.0);expect(bool(e.hit),"swept crossing catches fast frame "+kind);cases+=1
	# An early lateral miss must not consume the object's collision.
	for kind in ["fence","construction_sign","electronic_sign","cone"]:
		entities.clear();impacts.clear();speed=90;car_hp=100;health=100;armor_level=0;player_x=-5
		var e=spawn_entity(kind,0,position_z+1.5);e.last_z=5.0
		update_entities(0.0);expect(not e.hit,"no premature collision consumed "+kind)
		player_x=0;e.z=position_z+0.5;update_entities(0.0)
		expect(e.hit and impacts.size()==1,"steering into obstacle registers at front plane "+kind);cases+=1
	# Native parked-car bounds across every extracted vehicle model.
	for index in range(art.world_data.groups.vehicle.size()):
		var pose:Dictionary=art.world_data.groups.vehicle[index]
		var half=float(pose.rect[2])/float(pose.get("density",1.0))*0.0075
		for side in [-1.0,1.0]:
			entities.clear();impacts.clear();speed=110;car_hp=100;health=100;glass_hp=100;player_x=0;hit_cooldown=0
			var e=spawn_entity("cars",side*(half+0.99),position_z+0.5);e.anim="vehicle";e.frame=index;e.radius=half;e.last_z=5
			update_entities(0.0);expect(e.hit and car_hp<100,"native vehicle side "+str(index));cases+=1
	# The original cutoff legitimately absorbs light signs after a bumper upgrade.
	for kind in ["construction_sign","electronic_sign","fence","shopping_cart","water","feeders","cone","barrel","box"]:
		for armor in [0,1,2,3]:
			for game_mode in ["story","hardcore"]:
				entities.clear();impacts.clear();mode=game_mode;speed=110;car_hp=100;armor_level=armor;progress.upgrades[5]=armor
				var base=float({"construction_sign":0.5,"electronic_sign":4.0,"fence":1.0,"shopping_cart":0.5,"water":2.0,"feeders":3.0}.get(kind,0.0))*(2.0 if game_mode=="hardcore" else 1.0)
				var damage=0.0 if base<=float([0,2,5,8][armor]) else base*(1.0-float([0,.2,.4,.6][armor]))
				collide(spawn_entity(kind,0,position_z));expect(is_equal_approx(car_hp,100-damage),"original damage + armor "+kind+" "+str(armor)+" "+game_mode);cases+=1
	mode="story";progress.upgrades=[0,0,0,0,0,0,0,0];start_run();entities.clear();impacts.clear();scenery.clear();road_signs.clear();checkpoint_message.clear();checkpoint_queue.clear();speed=90
	print("RELEASE32_STAGE: cache and impact timelines")
	# Every exact frame stays resident through cache churn; no idle pose fallback.
	for kind in ["cone","barrel","box","construction_sign","electronic_sign","fence","shopping_cart","water","feeders"]:
		for row in art.world_data.groups[kind]:
			var retained=art.ready_world_record(kind,int(row.source_frame)-1)
			expect(not retained.is_empty() and art.world_texture(kind,int(retained.page))!=null,"short impact is warmed and retained "+kind)
	for page in range(10000,10016):
		art.store_texture("world",page,ImageTexture.create_from_image(Image.create(1024,1024,false,Image.FORMAT_RGBA8)))
	for page in range(10000,10016):
		if art.world_pages.has(page):
			art.world_pages.erase(page);art.world_lru.erase(page);art.texture_bytes.world-=int(art.texture_cost["world:"+str(page)]);art.texture_cost.erase("world:"+str(page))
	for kind in ["cone","barrel","box","construction_sign","electronic_sign","fence","shopping_cart","water","feeders"]:
		impacts.clear();collide(spawn_entity(kind,-0.25,position_z));entities.clear()
		for frame in range(1,art.world_data.groups[kind].size()):
			impacts[0].time=float(frame-1)/30.0+0.000001
			var expected:Dictionary=art.world_frame(kind,frame);var actual:Dictionary=art.ready_world_record(kind,frame)
			expect(actual.get("rect",[])==expected.rect and int(actual.get("page",-1))==int(expected.page),"exact advancing impact frame "+kind+" "+str(frame));timeline_frames+=1
			if kind in ["construction_sign","electronic_sign","fence"] and frame in [2,5]:await release32_capture(kind+"_frame"+str(frame))
		update_world_effects(2.0);expect(impacts.is_empty(),"destroy animation completes "+kind)
	print("RELEASE32_STAGE: spike generation")
	# Both original strip types are valid: authored road placements and soldier deployments.
	entities.clear();segment=16;post_checkpoint_pending=false
	for name in source_rules.patterns:
		load_source_pattern(String(name),position_z+200,0.8)
		for e in entities:
			if e.kind=="spikes":
				spawn_strips+=1
				if e.get("source_type","")=="Spikes":continue
				expect(e.has("operator_serial"),"soldier strip retains its operator "+String(name))
				var found=false
				for owner in entities:
					if owner.kind=="soldier" and owner.behavior=="spikes" and owner.serial==e.operator_serial and owner.strip==e:found=true
				expect(found,"spike/operator association "+String(name))
		entities.clear()
	for game_mode in ["time","police"]:
		mode=game_mode
		for i in range(50):
			spawn_pattern()
			for e in entities:
				if e.kind=="spikes":spawn_strips+=1;expect(e.get("source_type","")=="Spikes" or e.has("operator_serial"),"challenge strip is authored or operated")
			entities.clear()
	expect(spawn_strips>10,"spike generation audit exercises real operator spawns")
	mode="story";start_run();entities.clear();scenery.clear();road_signs.clear();checkpoint_message.clear();checkpoint_queue.clear();speed=80
	var operator=spawn_entity("soldier",-7,position_z+40);operator.behavior="spikes";attach_soldier_strip(operator)
	var strip:Dictionary=operator.strip
	update_entities(.01);expect(not strip.has("pull_target"),"operator windup precedes strip pull")
	operator.soldier_state="PullSpikeStrip";operator.trigger_time=13.0/30.0;operator.triggered=false
	update_entities(.01);expect(strip.has("pull_target") and float(strip.x)<5,"operator animation event moves strip")
	await release32_capture("soldier_spikes")
	print("RELEASE32_STAGE: original tutorial and UI")
	# Native tutorial sequence, remapping, readiness, original timing and persistence.
	progress.settings.tutorial_index=0;progress.settings.tutorial_seen=[];progress.settings.tutorial_encounters=[];progress.settings.keys[2]=KEY_UP
	setup_original_tutorials();expect(tutorial_queue.size()==3 and progress.settings.tutorial_index==1,"native initial three tutorials queued once")
	update_original_tutorial(.2);expect(tutorial_current.title=="Basic Controls" and "Up" in String(tutorial_current.body),"original tutorial uses remapped controls")
	dismiss_original_tutorial();expect(not tutorial_closing,"early Space cannot skip entrance")
	update_original_tutorial(.71);await release32_capture("tutorial_basic_controls")
	var z_before=position_z;simulate(.1,1,false,false,0);expect(position_z>z_before,"original tutorial does not pause driving")
	dismiss_original_tutorial();update_original_tutorial(.25);update_original_tutorial(1.0);expect(tutorial_current.title=="Aborting","tutorial queue advances after source fade")
	await release32_capture("tutorial_aborting")
	clear_original_tutorial();setup_original_tutorials();update_original_tutorial(1.0);expect(tutorial_current.title=="Hand Brake","next escape advances original story tutorial")
	clear_original_tutorial();progress.settings.tutorial_index=7;progress.upgrades[2]=1;record_tutorial_encounter("Water Jugs");setup_original_tutorials();expect(tutorial_queue.size()==2,"context tutorials after encountered hazard or pistol purchase")
	clear_original_tutorial();setup_original_tutorials();expect(tutorial_queue.is_empty(),"context tutorials shown only once")
	# Test save lives in its own fixture; the user's real save is untouched.
	var fixture=Progress.new();fixture.save_path="user://release32_fixture.cfg";fixture.settings.tutorial_index=3;fixture.settings.tutorial_seen=["Pistol"];fixture.settings.tutorial_encounters=["Water Jugs"];expect(fixture.save(),"tutorial save write")
	var reloaded=Progress.new();reloaded.save_path=fixture.save_path;reloaded.read_save();expect(reloaded.settings.tutorial_index==3 and reloaded.settings.tutorial_seen==["Pistol"] and reloaded.settings.tutorial_encounters==["Water Jugs"],"tutorial progression survives save reload")
	for suffix in ["",".bak",".tmp"]:
		if FileAccess.file_exists(fixture.save_path+suffix):DirAccess.remove_absolute(fixture.save_path+suffix)
	clear_original_tutorial();effects.clear();popup("PRECISION HIT",AMBER);popup("HOOD KILL +15 RP",AMBER);popup("+15 RP",AMBER);say("WATER — FIRE EXTINGUISHED",5);subtitle="TEST VOICE CAPTION";subtitle_time=10
	expect(effects.size()==1 and effects[0].text=="+15 RP","only +RP event popups survive")
	await release32_capture("rp_only")
	abort_y=0;set_pause();abort_confirm=true;await release32_capture("original_abort_dialog");abort_choice(false);expect(state=="play" and not abort_confirm,"native abort No returns to driving")
	var old_rp=progress.rp;abort_confirm=true;set_pause();abort_choice(true);expect(state=="garage" and progress.rp==old_rp,"native Abort returns to garage without awarding invented points")
	print("RELEASE32_STAGE: hood sprites")
	# Converted sprites carry a full repair audit and native frame dimensions.
	expect(int(art.anim_data.edges32.frames_audited)==1763 and int(art.anim_data.edges32.frames_repaired)>1000,"all clinger/inside sprites audited")
	expect(int(art.world_data.edges32.frames_audited)>2000,"world actors, vehicles, props, signs and scenery audited")
	for pair in [["hard",165],["male",160],["female",160],["super",160],["soldier",155]]:
		state="play";hood={"kind":pair[0],"anim":"Attack","anim_time":0.0,"hp":100.0,"attack":0.0,"grip":0.0};hood_time=2.0;dying_hood.clear();notice_time=0;subtitle_time=0;effects.clear();impacts.clear();entities.clear();checkpoint_message.clear()
		var key=String(HOOD_SYMBOLS[pair[0]]);art.prefetch_clinger(key)
		var wanted=int(art.anim_record(key,int(pair[1])).page)
		for _wait in range(1000):
			art.pump_textures()
			if art.anim_texture(wanted)!=null:break
			await get_tree().process_frame
		expect(art.anim_texture(wanted)!=null,"cleaned hood actor texture ready "+String(pair[0]))
		var span=hood_range(hood);hood.anim_time=(int(pair[1])-int(span[0])+1)/30.0
		await release32_capture("hood_clean_"+String(pair[0]))
	art.texture_queue.clear();art.texture_queued.clear()
	for _wait in range(500):
		art.pump_textures()
		if art.texture_pending.is_empty():break
		await get_tree().process_frame
	for _wait in range(4):
		await get_tree().process_frame;art.pump_textures()
	print("RELEASE32_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," collision_cases=",cases," advancing_frames=",timeline_frames," owned_spike_spawns=",spawn_strips," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

var release33_isolated=false
var release33_pose:Dictionary={}
var release33_original_pages:Dictionary={}

func release33_original_draw(canvas:Node2D):
	canvas.draw_rect(Rect2(0,0,RW,H),Color("#e7aa78"))
	var r=release33_pose
	if r.is_empty():return
	var f:Dictionary=art.world_data.groups[r.key][int(r.frame)]
	var src=Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3])
	var density=maxf(.01,float(f.get("density",1.0)))
	var sc=.0034959*camera_focal().y/camera_depth(float(r.z))/density
	var pos=project_point(float(r.x),float(r.z))
	canvas.draw_set_transform(pos)
	canvas.draw_texture_rect_region(release33_original_pages[int(f.page)],Rect2(Vector2(f.offset[0],f.offset[1])*sc,src.size*sc),src)
	canvas.draw_set_transform(Vector2.ZERO)

func release33_capture(name:String="") -> Image:
	queue_redraw();await RenderingServer.frame_post_draw
	var im=get_viewport().get_texture().get_image()
	if not name.is_empty():
		var base=ProjectSettings.globalize_path("res://../analysis/") if not OS.has_feature("standalone") else OS.get_executable_path().get_base_dir().path_join("../analysis/")
		expect(im.save_png(base+"release33_"+name+".png")==OK,"upper sign screenshot "+name)
	return im

func run_release33_checks():
	set_process(false);test_mode=true;preview_mode=false;progress.ephemeral=true
	progress.settings.fullscreen=false;apply_settings();rng.seed=330033;mode="story";start_run()
	entities.clear();scenery.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;speed=0;player_x=0;position_z=1000;notice_time=0;subtitle_time=0;checkpoint_message.clear();checkpoint_queue.clear()
	var keys=["highway_sign20","highway_sign_left20","highway_sign_offroad20"]
	expect(art.highway_pages.size()==int(art.highway_data.unique_textures),"all compact sign textures warmed before driving")
	expect(art.highway_resident_bytes==int(art.highway_data.resident_bytes) and art.highway_resident_bytes<120*1024*1024,"complete native sign set stays below120MiB")
	var exact=0;var rendered=0;var sampled=0;var mismatch=0;var visible=0
	var ids:Dictionary={}
	for page in art.highway_pages:ids[page]=art.highway_pages[page].get_rid()
	# Reproduce the pressure that evicted the old sign sheets while an animation ran.
	for page in range(12000,12024):art.store_texture("world",page,ImageTexture.create_from_image(Image.create(1024,1024,false,Image.FORMAT_RGBA8)))
	for key in keys:
		for frame in range(85):
			var source:Dictionary=art.world_data.groups[key][frame]
			var actual:Dictionary=art.ready_world_record(key,frame)
			expect(not actual.is_empty(),"sign pose always available "+key+" "+str(frame))
			expect(actual.get("source_rect",[])==source.rect and actual.offset==source.offset and actual.rect.slice(2)==source.rect.slice(2),"exact native pose and pivot "+key+" "+str(frame))
			expect(art.world_texture(key,int(actual.page))!=null and art.world_texture(key,int(actual.page)).get_rid()==ids[int(actual.page)],"sign texture survives cache eviction "+key)
			exact+=1
		for row in art.world_data.groups[key]:
			var id="world:"+str(int(row.page))
			expect(not art.texture_queued.has(id) and not art.texture_pending.has(id),"painting signs requests no evictable atlas "+key)
	# Intact and breaking signs coexist without one borrowing the other's pose.
	for key in keys:
		for frame in [7,19,42]:
			var broken=art.ready_world_record(key,frame);var intact=art.ready_world_record(key,0)
			expect(broken.source_rect==art.world_data.groups[key][frame].rect and intact.source_rect==art.world_data.groups[key][0].rect,"simultaneous idle and impact stay independent "+key)
	# Compare the rendered replacement against untouched original atlas frames.
	for key in keys:
		for row in art.world_data.groups[key]:
			var page=int(row.page)
			if not release33_original_pages.has(page):release33_original_pages[page]=load("res://assets/world03/atlas_%d.png"%page)
	var reference=Node2D.new();reference.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;reference.z_index=100
	reference.draw.connect(func():release33_original_draw(reference));add_child(reference);reference.hide()
	release33_isolated=true
	for key in keys:
		for frame in [0]+range(7,43):
			release33_pose={"key":key,"frame":frame,"x":-10.0 if key=="highway_sign_left20" else 10.0,"z":24.0}
			var actual=await release33_capture()
			reference.show();reference.queue_redraw();var expected=await release33_capture()
			for y in range(2,720,6):
				for x in range(2,int(RW),6):
					var a=actual.get_pixel(x,y);var b=expected.get_pixel(x,y);sampled+=1
					if maxf(maxf(absf(a.r-b.r),absf(a.g-b.g)),absf(a.b-b.b))>0.012:mismatch+=1
					var bg=Color("#e7aa78")
					if maxf(maxf(absf(b.r-bg.r),absf(b.g-bg.g)),absf(b.b-bg.b))>.04:visible+=1
			reference.hide();rendered+=1
	expect(mismatch==0 and visible>100,"original sign render matches every playable pose under cache pressure")
	reference.queue_free();release33_isolated=false;release33_pose.clear();queue_redraw()
	await get_tree().process_frame
	release33_original_pages.clear()
	# Source helicopter trigger, break timeline and stationary off-road support.
	for side in [-1,1]:
		start_run();entities.clear();scenery.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;speed=0;position_z=1000;player_x=0;checkpoint_message.clear();checkpoint_queue.clear()
		segment=16;spawn_source_helicopter()
		var sign_actor=spawn_source_road_sign(side*10.0,position_z+40)
		helicopter.x=sign_actor.x;helicopter.y=5;helicopter.z=position_z+41;helicopter.vz=30
		helicopter_sign_collision(position_z+39)
		expect(sign_actor.crashed and int(helicopter.hp)==2,"physical helicopter impact starts upper sign animation")
		var hp=int(helicopter.hp);helicopter_sign_collision(position_z+39);expect(int(helicopter.hp)==hp,"one helicopter hit per sign")
		var fixed_support=float(sign_actor.offroad_z);var previous=7
		for i in range(48):
			update_road_signs(1.0/30.0)
			var frame=mini(42,7+int(float(sign_actor.anim_time)*30))
			expect(frame>=previous and frame<=42,"break frames advance and hold the final native frame")
			expect(sign_actor.offroad_z==fixed_support and sign_actor.x==side*10.0,"support stays fixed behind original side wall")
			previous=frame
			if i in [0,9,24,47]:
				helicopter.clear();await release33_capture(("left" if side<0 else "right")+"_break_"+str(i))
		expect(previous==42,"broken upper sign holds native source frame43")
		var elapsed_before=sign_actor.anim_time;state="paused";simulate(.2,0,false,false,0);expect(sign_actor.anim_time==elapsed_before,"pause freezes sign timeline")
	# Close active workers cleanly and preserve real saves through ephemeral fixtures.
	art.texture_queue.clear();art.texture_queued.clear()
	for i in range(500):
		art.pump_textures();queue_redraw()
		if art.texture_pending.is_empty():break
		await get_tree().process_frame
	print("RELEASE33_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," exact_frames=",exact," rendered=",rendered," sampled=",sampled," mismatched=",mismatch," visible=",visible," sign_mib=",float(art.highway_resident_bytes)/1048576.0," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func draw_building_effects(frame:int,pos:Vector2,scale:float,alpha:float,flipped:bool):
	var cfg:Dictionary=art.resident_data.get("building_effects",{}).get(str(frame),{})
	if cfg.is_empty():return
	var density=float(cfg.density)
	var base=Transform2D(Vector2((-1.0 if flipped else 1.0)*scale*density,0),Vector2(0,scale*density),pos)
	for child in cfg.effects:
		var key=String(child.key);var f=art.ready_world_record(key,int(elapsed*30.0))
		if f.is_empty():continue
		var m:Array=child.matrix
		var local=Transform2D(Vector2(m[0],m[1]),Vector2(m[2],m[3]),Vector2(m[4],m[5]))
		var src=Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3])
		draw_set_transform_matrix(base*local)
		var child_density=maxf(1.0,float(f.get("density",1.0)))
		draw_texture_rect_region(art.world_texture(key,int(f.page)),Rect2(Vector2(f.offset[0],f.offset[1])/child_density,src.size/child_density),src,Color(1,1,1,alpha*float(child.opacity)))
	draw_set_transform( Vector2(pos.x*2,0),0,Vector2(-1,1)) if flipped else draw_set_transform(Vector2.ZERO)

var release34_isolated=false
var release34_pose:Dictionary={}
var release34_reference_pages:Dictionary={}

func release34_reference_draw(canvas:Node2D):
	canvas.draw_rect(Rect2(0,0,RW,H),Color("#e7aa78"))
	if release34_pose.is_empty():return
	var r=release34_pose
	var source:Dictionary=art.world_data.groups[r.key][int(r.frame)]
	var scale=(2.2 if String(r.key).begins_with("hard_") else 2.0)*.0034959*camera_focal().y/camera_depth(float(r.z))/maxf(1.0,float(source.get("density",1.0)))
	var src=Rect2(source.rect[0],source.rect[1],source.rect[2],source.rect[3])
	var pos=project_point(float(r.x),float(r.z))
	canvas.draw_texture_rect_region(release34_reference_pages[int(source.page)],Rect2(pos+Vector2(source.offset[0],source.offset[1])*scale,src.size*scale),src)

func release34_capture(name:String="") -> Image:
	queue_redraw();await RenderingServer.frame_post_draw
	var im=get_viewport().get_texture().get_image()
	if not name.is_empty():
		var base=ProjectSettings.globalize_path("res://../analysis/") if not OS.has_feature("standalone") else OS.get_executable_path().get_base_dir().path_join("../analysis/")
		expect(im.save_png(base+"release34_"+name+".png")==OK,"animation capture "+name)
	return im

func run_release34_checks():
	set_process(false);test_mode=true;preview_mode=false;progress.ephemeral=true;progress.settings.fullscreen=false;progress.settings.shake=false;apply_settings();rng.seed=340034;mode="story";start_run()
	entities.clear();scenery.clear();road_signs.clear();impacts.clear();next_pattern=1e9;next_road_sign=1e9;position_z=1000;player_x=0;speed=0;notice_time=0;subtitle_time=0;checkpoint_message.clear();checkpoint_queue.clear()
	expect(art.resident_pages.size()==int(art.resident_data.unique_textures),"complete compact bank prepared before driving")
	expect(art.resident_bytes==int(art.resident_data.resident_bytes) and art.resident_bytes<1400*1048576,"retained gameplay pixels fit the memory target")
	var ids:Dictionary={}
	for page in art.resident_pages:ids[page]=art.resident_pages[page].get_rid()
	for page in range(11000,11080):art.store_texture("world",page,ImageTexture.create_from_image(Image.create(2048,2048,false,Image.FORMAT_RGBA8)))
	var frames=0
	for bank in ["world","anim"]:
		for key in art.resident_data[bank]:
			var rows:Array=art.resident_data[bank][key]
			for n in range(rows.size()):
				var actual:Dictionary=art.ready_world_record(key,n) if bank=="world" else art.ready_anim_record(key,n)
				expect(actual==rows[n] and art.resident_pages[int(actual.page)].get_rid()==ids[int(actual.page)],"exact retained frame under cache churn "+bank+" "+key+" "+str(n));frames+=1
	# Remove the synthetic cache pressure before native-reference captures.
	art.world_pages.clear();art.world_lru.clear();art.texture_bytes.world=0
	for id in art.texture_cost.keys():
		if String(id).begins_with("world:"):art.texture_cost.erase(id)
	await get_tree().process_frame
	var keys=["male_WalkFront","male_WalkSide","female_WalkFront","female_WalkSide","hard_WalkFront","hard_WalkSide","super_WalkFront","super_WalkSide","civilian_Male1","civilian_Male2","civilian_Male3","civilian_Male5","civilian_Female1","civilian_Female3","civilian_Female4","soldier_Run","soldier_Fire"]
	var reference=Node2D.new();reference.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR;reference.z_index=100;reference.draw.connect(func():release34_reference_draw(reference));add_child(reference);reference.hide()
	release34_isolated=true
	var rendered=0;var mismatch=0;var visible=0
	for key in keys:
		release34_reference_pages.clear()
		for row in art.world_data.groups[key]:
			if not release34_reference_pages.has(int(row.page)):release34_reference_pages[int(row.page)]=load("res://assets/world03/atlas_%d.png"%int(row.page))
		for n in range(art.world_data.groups[key].size()):
			release34_pose={"bank":"world","key":key,"frame":n,"x":0.0,"z":8.0,"height":1.8}
			var actual=await release34_capture();reference.show();reference.queue_redraw();var expected=await release34_capture()
			for y in range(4,720,12):
				for x in range(4,int(RW),12):
					var a=actual.get_pixel(x,y);var b=expected.get_pixel(x,y)
					if maxf(maxf(absf(a.r-b.r),absf(a.g-b.g)),absf(a.b-b.b))>.012:mismatch+=1
					var bg=Color("#e7aa78")
					if maxf(maxf(absf(b.r-bg.r),absf(b.g-bg.g)),absf(b.b-bg.b))>.04:visible+=1
			reference.hide();rendered+=1
	expect(mismatch==0 and visible>100,"all walking running and firing poses match untouched native renderer")
	reference.queue_free();release34_isolated=false;release34_pose.clear();queue_redraw();await get_tree().process_frame;release34_reference_pages.clear()
	# Standing actors use FrontPose, patrols WalkSide, and moving front actors WalkFront.
	for kind in ["male","female","hard","super"]:
		entities.clear();var e=spawn_entity(kind,2,position_z+120);e.moving=false;e.behavior="patrol";update_entities(.1)
		expect(e.anim==kind+"_FrontPose","original standing pose "+kind)
		e.moving=true;e.patrol_wait=0;update_entities(.1);expect(e.anim==kind+"_WalkSide","original patrol side walk "+kind)
		e.patrol_wait=1;update_entities(.1);expect(e.anim==kind+"_FrontPose","original pause standing pose "+kind)
		e.behavior="straight";update_entities(.1);expect(e.anim==kind+"_WalkFront","original front walk "+kind)
		var clock=e.anim_time;update_entities(.1);expect(e.anim_time>clock,"same animation does not restart every tick "+kind)
	entities.clear()
	for variant in ["Male1","Male2","Male3","Male5","Female1","Female3","Female4"]:
		var e=spawn_entity("civilian",0,position_z+120);e.variant=variant;update_entities(.1);expect(e.anim=="civilian_"+variant,"original civilian run "+variant)
	var clock=elapsed;state="paused";simulate(.2,0,false,false,0);expect(elapsed==clock,"pause freezes animation clock")
	# Native building child playback on both sides, behind highway walls.
	entities.clear();state="play";progress.settings.buildings=true
	expect(art.resident_data.building_effects.size()==5,"all five animated building variants restored")
	for key in ["building_fx34_3662","building_fx34_3671"]:
		var unique:Dictionary={}
		for row in art.resident_data.world[key]:unique[int(row.page)]=true
		expect(unique.size()>4,"building smoke/fire child moves across original poses "+key)
	for side in [-1,1]:
		scenery=[{"x":side*12.1,"z":position_z+50,"frame":14,"height":18.0}]
		elapsed=0;var first=await release34_capture(("left" if side<0 else "right")+"_building_0")
		elapsed=8.0/30;var second=await release34_capture(("left" if side<0 else "right")+"_building_8")
		var changed=0
		for y in range(0,310,2):
			for x in range(0,int(RW),2):
				if first.get_pixel(x,y)!=second.get_pixel(x,y):changed+=1
		expect(changed>5,"building child animation visible behind wall "+str(side))
		var held=await release34_capture();expect(second.get_data()==held.get_data(),"unchanged clock keeps building pose stable")
	expect(art.perf_sync_paint_loads==0 and art.texture_queue.is_empty() and art.texture_pending.is_empty(),"normal gameplay drawing performs no atlas requests or synchronous reads")
	art.retired_textures.clear()
	print("RELEASE34_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," exact_frames=",frames," rendered=",rendered," mismatched=",mismatch," visible=",visible," resident_mib=",float(art.resident_bytes)/1048576.0," ",test_errors)
	get_tree().quit(0 if test_errors.is_empty() else 1)

func run_release35_checks():
	progress.ephemeral=true;progress.settings.fullscreen=false;progress.settings.garage_seen=true;progress.settings.shake=false;apply_settings();AudioServer.set_bus_volume_db(0,-80)
	mode="story";snd.silent=false;snd.enabled=true;test_mode=true
	enter_garage();snd.speak("PlayerFirstTimeInGarage")
	expect(snd.voice.playing,"fixture starts real garage John voice")
	var click_start=Time.get_ticks_usec();activate("drive")
	var click_ms=float(Time.get_ticks_usec()-click_start)/1000.0
	expect(click_ms<100 and drive_requested and state=="garage","cold Drive returns to event loop immediately")
	expect(not snd.voice.playing and snd.voice_key.is_empty() and snd.voice_queue.is_empty(),"Drive stops John and clears queued garage dialogue before loading")
	activate("drive");activate("buy_4")
	expect(progress.upgrades[4]==0,"duplicate Drive and purchases ignored during transition")
	for i in range(4):await get_tree().process_frame
	activate("menu");await get_tree().process_frame
	expect(state=="menu" and not drive_requested,"navigation cancels requested transition")
	enter_garage();snd.speak("PlayerFirstTimeInGarage");activate("drive")
	var begin=Time.get_ticks_msec();var frames=0;var worst_ms=0.0;var last=Time.get_ticks_usec()
	while state=="garage" and Time.get_ticks_msec()-begin<120000:
		await get_tree().process_frame
		var now=Time.get_ticks_usec();worst_ms=maxf(worst_ms,float(now-last)/1000.0);last=now;frames+=1
		if frames%30==0:expect(not snd.voice.playing and not snd.radio.playing,"garage voices stay stopped during pending Drive")
	var loading_seconds=float(Time.get_ticks_msec()-begin)/1000.0
	expect(state=="play" and art.prepared_driving and art.driving_failed.is_empty(),"cold garage transitions successfully into highway")
	expect(frames>20 and worst_ms<250,"render/event loop stays responsive throughout cold preparation")
	expect(art.resident_pages.size()==2427 and art.highway_pages.size()==104,"complete exact gameplay/sign frame banks retained")
	expect(art.car_pages.size()==art.car_data.textures.size(),"all original side window and mirror frames retained")
	set_process(false);snd.stop_action()
	var car=preload("res://scripts/car35.gd").new()
	for level in range(4):
		car.reset(level)
		for stage in range(1,5):
			car.state=car.ACCEL;car.clock=float(car.ACCEL_TIMES[stage]);car.resolve()
			expect(absf(car.speed-float(car.RATIOS[level][stage])*float(car.MAX_SPEEDS[level]))<.001,"source speed knot engine "+str(level)+" gear "+str(stage))
			expect(car.visual_frame()==roundi(100*float(car.VISUAL[level][stage])),"source nonlinear needle knot engine "+str(level)+" gear "+str(stage))
		car.state=car.ACCEL;car.clock=0;car.resolve();car.update(1,1,false,false)
		expect(absf(car.clock-float(car.SCALES[level]))<.001,"upgrade engine scale controls elapsed acceleration")
		car.seek_speed(float(car.MAX_SPEEDS[level]));car.update(0,1,true,false)
		expect(car.state==car.MAX_SPEED,"forward takes priority over pedal brake")
		car.update(0,1,true,true);expect(car.state==car.HAND_BRAKE,"handbrake takes priority over forward and brake")
		expect(car.clock==0,"handbrake maps max speed to original coast start")
		car.update(1,0,false,true)
		expect(absf(car.clock-float(car.SCALES[level]))<.001 and car.speed>0,"handbrake advances original coast timeline")
		car.update(0,0,true,false)
		var before_clock=car.clock
		car.update(.2,0,true,false)
		expect(absf(car.clock-before_clock-.2*float(car.SCALES[level]))<.001,"brake timing follows authored recording scale")
		car.update(5,0,true,false);car.update(0,0,false,false)
		expect(car.speed==0 and car.state==car.IDLE,"pedal brake reaches idle")
		car.state=car.ACCEL;car.clock=10;car.resolve();car.hit_speed_loss(.2,.7)
		expect(absf(car.clock-8.6)<.001,"impact reduces engine clock using original bumper factor")
		var reduced=car.speed;car.update(.1,1,false,false)
		expect(car.speed>reduced and car.clock<9,"acceleration continues from post-collision clock")
		for engine_state in range(6):
			var prefix=String(["CarIdle","CarAccel","CarMaxSpeed","CarDeccelNoBrake","CarDeccelBrake","CarDeccelNoBrake"][engine_state])
			var key=prefix+str(level+1)
			expect(snd.stream(key,engine_state in [0,2])!=null,"original engine recording available: "+key)
			snd.update_engine(70,true,false,level,engine_state,1.0,float(car.SCALES[level]),level*10+engine_state)
			expect(snd.engine.playing and snd.engine_key==key and snd.engine.pitch_scale==1,"engine state plays correct unpitched recording: "+key)
			if engine_state in [0,2]:expect(snd.engine.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD,"idle/max recording loops")
	var audio_key=snd.engine_key;snd.pause_all(true);snd.update_engine(0,false,false)
	expect(snd.engine_key==audio_key and snd.engine.stream_paused,"pause keeps engine and its timeline paused")
	snd.pause_all(false);snd.stop_action()
	for level in range(4):
		progress.upgrades=[0,level,0,0,level,0,0,0];start_run();entities.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9;helicopter_delay=1e9
		health=50;body_recovery=8;simulate(.2,0,false,false,0)
		expect(absf(health-(50+.2*float([1,1.5,2,2.5][level])))<.001,"source armor recovery without artificial wait")
		damage_player(1000,"Military");simulate(.01,0,false,false,0)
		expect(health==0 and death_menu_active(),"fatal body damage cannot regenerate")
		start_run();entities.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9;helicopter_delay=1e9
		speed=float(car35.MAX_SPEEDS[level]);fire_started=true;car_hp=15;simulate(.1,1,false,false,0)
		expect(speed==float(car35.MAX_SPEEDS[level]),"burning engine retains source top speed")
		update_car_audio();expect(snd.action_loops.burning_engine.playing,"original engine fire loop plays")
		glass_hp=0;update_car_audio();expect(snd.action_loops.heavy_wind.playing,"broken windshield wind sound plays")
		car35.state=car35.BRAKE;update_car_audio();expect(snd.action_loops.tire_brake.playing,"pedal brake tire sound plays")
		car35.state=car35.COAST;oil_time=1;update_car_audio();expect(snd.action_loops.tire_brake.playing,"oil skid shares original tire brake loop")
		snd.stop_action();expect(not snd.engine.playing and snd.action_loops.values().all(func(p):return not p.playing),"scene exit stops all car loops")
	progress.upgrades=[0,0,0,0,0,0,0,0]
	for side in [-1,1]:
		start_run();entities.clear();scenery.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9;helicopter_delay=1e9
		var index=0 if side<0 else 1
		player_x=-9.4 if side<0 else 9.1;speed=110;lateral=side*4
		simulate(.5,1,false,false,side)
		expect(absf(float(side_damage[index])-10)<.001 and car_hp==100 and speed==110,"wall damages side at source 20HP/sec and keeps bumper/speed")
		expect(snd.action_loops.side_scrape.playing,"original side scraping loop plays")
		for i in range(10):simulate(.5,1,false,false,side)
		expect(side_damage[index]==100 and side_window_frame(index)>4 and side_mirror_frame(index)>4,"side glass/mirror break animation advances")
		var old=float(side_damage[index]);player_x=0;lateral=0;simulate(.1,0,false,false,0)
		expect(side_damage[index]==old and wall_contact==0 and not snd.action_loops.side_scrape.playing,"scraping stops when leaving wall")
		var capture=await release34_capture("car35_"+("left" if side<0 else "right")+"_broken")
		expect(capture!=null,"original side damage cockpit draws")
	start_run();entities.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9;helicopter_delay=1e9
	for i in range(26):simulate(1.0/60,1,false,false,0)
	expect(speed==0,"car waits for source first hand-on-stick frame")
	for i in range(1500):simulate(1.0/60,1,false,false,0)
	expect(speed==110 and gear==4 and speedometer_frame()==70,"stock engine completes original acceleration and four gears")
	car_hp=15;fire_started=true;collide(spawn_entity("water",0,position_z));update_car_audio()
	expect(car_hp==35 and not fire_started and not snd.action_loops.burning_engine.playing,"water extinguishes original fire to smoking damage stage")
	start_run();entities.clear();next_pattern=1e9;next_road_sign=1e9;speed=110
	var before_body=health;var collision_car=spawn_entity("cars",player_x,position_z+1)
	collide(collision_car)
	expect(health==before_body and car_hp<100 and glass_hp<100 and collision_bump_strength==1.0,"parked-car impact damages glass/bumper and bumps car without invented body damage")
	var post_hit_speed=speed;simulate(.1,1,false,false,0)
	expect(speed>=post_hit_speed and player_x!=0,"original engine timeline and lateral bump survive the next tick")
	var needle=await release34_capture("car35_stock")
	enter_garage();var warm_start=Time.get_ticks_usec();activate("drive")
	expect(state=="play" and not drive_requested and Time.get_ticks_usec()-warm_start<100000,"repeat Drive uses resident frames immediately")
	var report={"cold_click_ms":click_ms,"cold_loading_seconds":loading_seconds,"rendered_loading_frames":frames,"worst_loading_frame_ms":worst_ms,"max_texture_handoff_ms":art.driving_max_pump_ms,"errors":test_errors}
	var base=ProjectSettings.globalize_path("res://../analysis/") if not OS.has_feature("standalone") else OS.get_executable_path().get_base_dir().path_join("../analysis/")
	var out=FileAccess.open(base+"release35_car_check.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"\t"));out.close()
	print("RELEASE35_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",JSON.stringify(report))
	get_tree().quit(0 if test_errors.is_empty() else 1)

func source_spike_level() -> int:
	if mode in ["story","hardcore"]:return segment
	# Challenge patterns receive m_iLevel*2, using their own source distances.
	var lengths=[1000,1000,1500,1500,2000,2000,2500,2500,3000,3000] if mode=="police" else [2000,2500,3000,3500,4000,4500,5000,5500,6000,6500]
	var chapter=0;var boundary=float(lengths[0])
	while chapter<9 and position_z>=boundary:
		chapter+=1;boundary+=float(lengths[chapter])
	return chapter*2

func release36_key(code:int,pressed:bool,echo:bool=false):
	var event=InputEventKey.new();event.physical_keycode=code;event.keycode=code;event.pressed=pressed;event.echo=echo
	Input.parse_input_event(event)
	await get_tree().process_frame

func run_release36_checks():
	set_process(false);test_mode=true;preview_mode=false;progress.ephemeral=true
	progress.settings.fullscreen=false;progress.settings.shake=false;apply_settings();AudioServer.set_bus_volume_db(0,-80)
	progress.settings.keys=[KEY_A,KEY_D,KEY_W,KEY_S,KEY_SPACE,KEY_E,KEY_R,KEY_F,KEY_Q,KEY_P]
	mode="story";progress.checkpoint=0;start_run();clear_original_tutorial();entities.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9;helicopter_delay=1e9
	snd.silent=false;snd.enabled=true
	var horn_checks=0;var authored_checks=0;var authored_patterns=0
	for level in range(4):
		progress.upgrades[7]=level
		for tutorial in [false,true]:
			clear_original_tutorial();state="play"
			if tutorial:tutorial_current={"title":"Basic Controls","body":"fixture"};tutorial_clock=1.0
			await release36_key(KEY_W,true);await release36_key(KEY_A,true);await release36_key(KEY_E,true)
			expect(held(2) and held(0) and held(5),"actual Godot pressed-state retains W+A+E chord")
			expect(horn_pressed and horn_time>0 and snd.horn_player.playing and not snd.horn_player.stream_paused,"horn plays during W+A with tutorial="+str(tutorial)+" level="+str(level));horn_checks+=1
			expect(snd.horn_player.stream==snd.stream("Horn"+str(level+1),true) and snd.horn_player.stream.loop_mode==AudioStreamWAV.LOOP_FORWARD,"correct original horn upgrade loops")
			for frame in range(8):await get_tree().process_frame
			var before=snd.horn_player.get_playback_position()
			await release36_key(KEY_E,true,true)
			expect(snd.horn_player.get_playback_position()>=before,"key echo cannot restart horn loop")
			await release36_key(KEY_W,false);await release36_key(KEY_A,false)
			expect(horn_pressed and snd.horn_player.playing,"releasing acceleration/steering does not stop held horn")
			await release36_key(KEY_E,false)
			expect(not horn_pressed and not snd.horn_player.playing,"horn key release stops sound")
			await release36_key(KEY_W,true);await release36_key(KEY_A,true)
			for tap in range(12):
				await release36_key(KEY_E,true);expect(horn_pressed and snd.horn_player.playing,"spam press plays horn");horn_checks+=1
				await release36_key(KEY_E,false);expect(not horn_pressed and not snd.horn_player.playing,"spam release stops horn")
			await release36_key(KEY_W,false);await release36_key(KEY_A,false)
	# A rebound horn and the overlay dismissal retain their distinct actions.
	progress.settings.keys[5]=KEY_H;tutorial_current={"title":"Horn","body":"fixture"};tutorial_clock=1
	await release36_key(KEY_W,true);await release36_key(KEY_A,true);await release36_key(KEY_H,true)
	expect(horn_pressed and snd.horn_player.playing,"rebound horn works with W+A during tutorial")
	await release36_key(KEY_SPACE,true);expect(tutorial_closing and horn_pressed,"Space dismisses tutorial without blocking or cutting horn")
	await release36_key(KEY_SPACE,false);await release36_key(KEY_H,false);await release36_key(KEY_W,false);await release36_key(KEY_A,false)
	clear_original_tutorial();progress.settings.keys[5]=KEY_E
	await release36_key(KEY_E,true);set_pause();expect(not horn_pressed and not snd.horn_player.playing,"pause stops held horn")
	await release36_key(KEY_E,false);state="play";snd.pause_all(false)
	await release36_key(KEY_E,true);expect(horn_pressed and snd.horn_player.playing and not snd.horn_player.stream_paused,"horn restarts after pause")
	await release36_key(KEY_E,false)
	await release36_key(KEY_E,true);_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	expect(state=="paused" and not horn_pressed and not snd.horn_player.playing,"focus loss stops horn and pauses safely")
	await release36_key(KEY_E,false);state="play";snd.pause_all(false);snd.stop_action()
	print("RELEASE36_STAGE: source spike placements")
	mode="story";segment=3;post_checkpoint_pending=false
	var spike_item={"type":"Spikes","x":5.0,"z":30.0,"red":0.0,"blue":0.0,"alpha":1.0}
	expect(not source_item_allowed(spike_item),"no standalone spikes before source chapter level 4")
	segment=4;post_checkpoint_pending=true
	expect(source_item_allowed(spike_item),"authored standalone spikes allowed at level 4 even during story dialogue")
	var operator_item=spike_item.duplicate();operator_item.type="SoldierSpikes"
	segment=5;expect(not source_item_allowed(operator_item),"spike soldiers remain absent before level 6")
	segment=6;expect(not source_item_allowed(operator_item),"first spike soldier waits until checkpoint dialogue finishes")
	post_checkpoint_pending=false;expect(source_item_allowed(operator_item),"spike soldier allowed after first dialogue")
	segment=18;expect(not source_item_allowed(operator_item) and source_item_allowed(spike_item),"late no-military chapters retain authored standalone strips")
	segment=4
	for name in source_rules.patterns:
		var has_spikes=false
		for item in source_rules.patterns[name].items:
			if item.type!="Spikes":continue
			has_spikes=true
			for stretch in [1.0,1.5]:
				for flipped in [false,true]:
					entities.clear();source_spawn_item(item,1000.0,stretch,flipped,0.5)
					expect(entities.size()==1 and entities[0].kind=="spikes" and not entities[0].has("operator_serial"),"authored standalone strip is restored "+String(name))
					if entities.size()==1:
						var e:Dictionary=entities[0]
						expect(is_equal_approx(float(e.x),float(item.x)*(-1 if flipped else 1)) and is_equal_approx(float(e.z),1000+float(item.z)*stretch),"authored x/z survive source mirror/stretch "+String(name))
						expect(e.radius==2.5,"source spike strip lane collision width")
					authored_checks+=1
		if has_spikes:authored_patterns+=1
	expect(authored_checks>0 and authored_patterns>0,"audit exercises original authored spike templates")
	for side in [-1.0,1.0]:
		entities.clear();var operator=spawn_entity("soldier",side*7,position_z+40);operator.behavior="spikes";attach_soldier_strip(operator)
		var strip:Dictionary=operator.strip
		expect(strip.x==-side*5 and strip.z==operator.z and strip.operator_serial==operator.serial,"soldier strip starts in opposite lane at soldier depth")
		operator.soldier_state="PullSpikeStrip";operator.trigger_time=13.0/30.0;operator.triggered=false;speed=80
		update_entities(.01);expect(strip.has("pull_target") and strip.pull_target==0,"native pull event targets middle lane on both sides")
	# Challenge spike gates follow their own chapter lengths, passed as level*2.
	mode="police";position_z=999;expect(source_spike_level()==0,"police early chapter has no spikes")
	position_z=1000;expect(source_spike_level()==2 and source_item_allowed(spike_item),"police standalone strips unlock after original first 1000m")
	mode="time";position_z=4499;expect(source_spike_level()==2 and not source_item_allowed(spike_item),"timed challenge strips stay locked before original level 4")
	position_z=4500;expect(source_spike_level()==4 and source_item_allowed(spike_item),"timed challenge strips unlock after original 4500m")
	# Full generation retains either an authored source record or an attached operator.
	for game_mode in ["story","hardcore","time","police"]:
		mode=game_mode;segment=16;post_checkpoint_pending=false;position_z=16000;next_pattern=position_z+100
		for pattern in range(60):
			entities.clear();spawn_pattern()
			for e in entities:
				if e.kind=="spikes":expect(e.get("source_type","")=="Spikes" or e.has("operator_serial"),"generated strip has original authored placement or operator")
	mode="story";position_z=0;start_run();clear_original_tutorial();entities.clear();scenery.clear();road_signs.clear();checkpoint_message.clear();checkpoint_queue.clear();next_pattern=1e9;next_road_sign=1e9
	expect(segment_position(21)==49600 and segment_position(22)==50000,"original 49.6km campaign and 400m final tunnel unchanged")
	expect(YELLOW_LINE_SPACING==20 and YELLOW_LINE_VIEW_DISTANCE==80,"source highway marking distances restored")
	var far=project_road_point(0,200,0);expect(is_finite(far.y),"original 200m road projection remains valid")
	var screenshot=await release34_capture("road36_original_spacing")
	expect(screenshot!=null,"road with restored source spacing renders")
	var report={"horn_chord_checks":horn_checks,"authored_spike_coordinate_checks":authored_checks,"authored_spike_patterns":authored_patterns,"campaign_distance_m":49600,"final_tunnel_m":400,"road_far_m":200,"lane_marker_spacing_m":20,"errors":test_errors}
	var base=ProjectSettings.globalize_path("res://../analysis/") if not OS.has_feature("standalone") else OS.get_executable_path().get_base_dir().path_join("../analysis/")
	var out=FileAccess.open(base+"release36_input_road_check.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"\t"));out.close()
	print("RELEASE36_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",JSON.stringify(report))
	get_tree().quit(0 if test_errors.is_empty() else 1)

func check_release362_behaviour(errors:Array):
	AudioServer.set_bus_mute(0,true)
	AudioServer.set_bus_volume_db(0,-80)
	var initial_mode=DisplayServer.window_get_mode()
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	await get_tree().process_frame
	var initial_size=DisplayServer.window_get_size()
	progress.settings.fullscreen=false
	var old_test=test_mode;var old_preview=preview_mode
	test_mode=false;preview_mode=false
	for action in ["music_off","music_on","sound_off","sound_on","vol_down","vol_up","fps"]:
		activate(action)
		await get_tree().process_frame
		if DisplayServer.window_get_mode()!=DisplayServer.WINDOW_MODE_MAXIMIZED or DisplayServer.window_get_size()!=initial_size:errors.append("Maximized window changed on "+action)
	progress.settings.fullscreen=true;apply_window_mode()
	await get_tree().process_frame
	if DisplayServer.window_get_mode()!=DisplayServer.WINDOW_MODE_FULLSCREEN:errors.append("Explicit fullscreen failed")
	progress.settings.fullscreen=false;apply_window_mode()
	await get_tree().process_frame
	if DisplayServer.window_get_mode()!=DisplayServer.WINDOW_MODE_WINDOWED:errors.append("Exit fullscreen failed")
	test_mode=old_test;preview_mode=old_preview
	DisplayServer.window_set_mode(initial_mode)
	await get_tree().process_frame
	var quiet=0;var alarms=0;var sounding=0
	for row in vehicle_catalog.spawn_choices362.AllCar:
		if String(row.sound).is_empty():quiet+=1
		else:sounding+=1
		if String(row.sound).begins_with("CarAlarm"):alarms+=1
	if quiet!=93 or alarms!=23:errors.append("Original car sound probabilities changed: "+str([quiet,alarms,sounding]))
	var shared=[]
	for row in vehicle_catalog.spawn_choices362.AllCar:
		if int(row.frame)==16:shared.append(String(row.sound))
	if shared!=["","CarHornSmall"]:errors.append("Silent variant merged into sounding variant")
	start_run();entities.clear();road_signs.clear();next_road_sign=1e9;next_pattern=1e9;air_delay=1e9
	snd.silent=false;snd.enabled=true
	var alarm=spawn_entity("cars",4,position_z+60)
	alarm["ambient_sound"]="CarAlarmSmall";alarm["ambient_channel"]="near_alarm362"
	snd.begin_world_frame(player_x,position_z);update_entities(.016);snd.flush_world_frame(1.0)
	if not snd.selected_alarm_channels.is_empty():errors.append("Distant alarm audible")
	alarm.z=position_z+12
	snd.begin_world_frame(player_x,position_z);update_entities(.016);snd.flush_world_frame(1.0)
	if snd.selected_alarm_channels.size()!=1:errors.append("Nearby source alarm missing")
	car_hp=0;finish_run("Crash fixture",false,"Crash")
	if not snd.selected_alarm_channels.is_empty():errors.append("Alarm survived crash transition")
	for i in range(20):update_death_world(.05)
	if not snd.selected_alarm_channels.is_empty():errors.append("Death world restarted highway alarms")
	for slot in snd.world_slots:
		if String(slot.channel)=="near_alarm362" and slot.player.playing:errors.append("Alarm player remained active after death")
	snd.silent=true
	start_run();entities.clear();road_signs.clear();next_road_sign=1e9;next_pattern=1e9;air_delay=1e9
	gear=2;gear_arm_frame=20;gear_stick_frame=20;speed=10;car35.reset(0)
	update_gears(.016,0)
	if shift_start!=67 or shift_end!=70 or shift_target_gear!=1:errors.append("Low-gear downshift used the wrong authored clip")
	# An engine gear change during the clip cannot change its completion target.
	car35.source_gear=2
	update_gears(1.0,0)
	if gear!=1 or gear_arm_frame!=70 or right_hand_on_wheel():errors.append("Downshift did not finish on its original gear-stick pose")
	car35.reset(0);speed=0
	update_gears(.016,0)
	if shift_time>0 or right_hand_on_wheel():errors.append("Stopping changed the original hand-on-stick behavior")
	for pose in ["left","right","shift","returned","punch","shoot"]:
		start_run();entities.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9
		steering=-.8 if pose=="left" else .8
		if pose=="shift":gear_arm_frame=20
		if pose=="returned":gear_arm_frame=93
		if pose in ["punch","shoot"]:attack_time=1;attack_kind=pose;attack_elapsed=17.0/30
		queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var folder=OS.get_environment("ROTD_CHECK_OUTPUT")
		if not folder.is_empty():get_viewport().get_texture().get_image().save_png(folder+"/hands362_"+pose+".png")
	for damage in [0,16,31,61,91,100]:
		start_run();entities.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9
		side_damage=[float(damage),float(damage)];side_mirror_time=[.1,.1];side_window_time=[.1,.1]
		queue_redraw()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var folder=OS.get_environment("ROTD_CHECK_OUTPUT")
		if not folder.is_empty():get_viewport().get_texture().get_image().save_png(folder+"/mirrors_"+str(damage)+".png")
	if art.perf_sync_paint_loads!=0:errors.append("Hands triggered synchronous loads while drawing")
	open_menu()


func run_release363_checks():
	set_process(false);test_mode=true;preview_mode=false;progress.ephemeral=true
	progress.settings.fullscreen=false;progress.settings.shake=false;apply_settings()
	# Let the new window register input before the first synthetic key press.
	await get_tree().process_frame
	await get_tree().process_frame
	progress.settings.keys=[KEY_A,KEY_D,KEY_W,KEY_S,KEY_SPACE,KEY_E,KEY_R,KEY_F,KEY_Q,KEY_P]
	mode="story";progress.checkpoint=0;start_run();clear_original_tutorial();entities.clear();road_signs.clear();scenery.clear();notice_time=0;subtitle_time=0;checkpoint_message.clear();checkpoint_queue.clear()
	snd.silent=true;player_x=0;position_z=1000;speed=0
	var pulses=0;var cases=0
	# Real press/release events at all horn levels must not restart a heard walk.
	for kind in ["female","male","hard"]:
		for level in range(4):
			progress.upgrades[7]=level
			for side in [-1,1]:
				entities.clear();var e=spawn_entity(kind,side*4.0,position_z+50)
				e.direction=side;e.moving=true;e.patrol_wait=0
				await release36_key(KEY_E,true);update_entities(.05)
				expect(horn_pressed,"initial horn event reached zombie fixture "+kind+" "+str(level)+" "+str(side))
				expect(e.anim==kind+"_WalkSide","horn sound uses original side alignment "+kind+" "+str(level))
				var clock=float(e.anim_time);var prior_x=absf(float(e.x));var prior_z=float(e.z)
				for tap in range(12):
					await release36_key(KEY_E,false);update_entities(.05)
					await release36_key(KEY_E,true);update_entities(.05);pulses+=1
					expect(e.anim==kind+"_WalkSide" and float(e.anim_time)>clock,"spam preserves active walk and clock "+kind+" "+str(level)+" "+str(tap))
					expect(absf(float(e.x))<prior_x and float(e.z)<prior_z,"heard zombie keeps approaching "+kind+" level="+str(level)+" side="+str(side)+" tap="+str(tap)+" x="+str(e.x)+" prior_x="+str(prior_x)+" z="+str(e.z)+" prior_z="+str(prior_z)+" alert="+str(e.get("zombie_alert","none")))
					clock=float(e.anim_time);prior_x=absf(float(e.x));prior_z=float(e.z)
				await release36_key(KEY_E,false)
				expect(bool(e.flip)==(side>0),"side walk faces original alignment direction "+kind)
				cases+=1
	# Quiet patrols and standing actors keep their original behavior.
	for kind in ["female","male","hard"]:
		entities.clear();var e=spawn_entity(kind,4,position_z+50);e.moving=true;e.direction=1
		update_entities(.1);var old_x=float(e.x)
		expect(e.anim==kind+"_WalkSide","quiet patrol side walk "+kind)
		update_entities(.1);expect(float(e.x)>old_x,"quiet patrol retains its direction "+kind)
		entities.clear();e=spawn_entity(kind,4,position_z+50);e.moving=false
		update_entities(.1);expect(e.anim==kind+"_FrontPose","quiet stationary pose "+kind)
		await release36_key(KEY_E,true);update_entities(.1);await release36_key(KEY_E,false);update_entities(.1)
		expect(e.anim==kind+"_WalkSide","stationary zombie remembers horn "+kind)
		# Horn alignment turns front once near the player's X and stays front.
		e.x=.1;update_entities(.1);expect(e.anim==kind+"_WalkFront","aligned zombie faces front "+kind)
		var clock=float(e.anim_time)
		for tap in range(6):
			await release36_key(KEY_E,true);update_entities(.05);await release36_key(KEY_E,false);update_entities(.05)
		expect(e.anim==kind+"_WalkFront" and float(e.anim_time)>clock,"aligned front walk survives horn spam "+kind)
		# Original close hearing (10) and resting vision (20), not global 20.
		entities.clear();e=spawn_entity(kind,4,position_z+15);e.moving=true;e.direction=1
		update_entities(.1);expect(e.anim==kind+"_WalkSide","moving patrol outside hearing range "+kind)
		e.patrol_wait=1;update_entities(.1);expect(e.anim==kind+"_WalkFront","waiting patrol sees nearby player "+kind)
		entities.clear();e=spawn_entity(kind,4,position_z+8);e.moving=false
		update_entities(.1);expect(e.anim==kind+"_WalkFront","nearby stationary zombie hears car "+kind)
		e.z=position_z+50;update_entities(.1);expect(e.anim==kind+"_WalkFront","chase survives increasing distance "+kind)
		# At each horn upgrade the close vision range starts a persistent chase.
		for level in range(4):
			progress.upgrades[7]=level;entities.clear();e=spawn_entity(kind,4,position_z+float([20,25,30,35][level])-.5);e.moving=false
			await release36_key(KEY_E,true);update_entities(.05);await release36_key(KEY_E,false);update_entities(.05)
			expect(e.anim==kind+"_WalkFront","horn vision uses persistent chase "+kind+" "+str(level))
		# Too-far and passed zombies must not react to repeated horn presses.
		entities.clear();e=spawn_entity(kind,4,position_z+120);e.moving=false
		await release36_key(KEY_E,true);update_entities(.1);expect(e.anim==kind+"_FrontPose","out of range horn does not alert "+kind)
		await release36_key(KEY_E,false);e.z=position_z-1;update_entities(.1)
		expect(e.anim==kind+"_WalkFront","passed zombie continues straight "+kind)
	# Render consecutive female walk poses after multiple press/release cycles.
	entities.clear();progress.upgrades[7]=0;var woman=spawn_entity("female",2,position_z+12);woman.moving=false
	await release36_key(KEY_E,true);update_entities(.1);await release36_key(KEY_E,false)
	var folder=OS.get_environment("ROTD_CHECK_OUTPUT")
	for step in range(3):
		update_entities(4.0/30);queue_redraw();await get_tree().process_frame;await RenderingServer.frame_post_draw
		if not folder.is_empty():get_viewport().get_texture().get_image().save_png(folder+"/female_horn363_"+str(step)+".png")
	expect(art.perf_sync_paint_loads==0,"horn reaction drawing has no synchronous texture reads")
	stop_horn()
	var report={"spam_pulses":pulses,"kind_level_direction_cases":cases,"errors":test_errors}
	print("RELEASE363_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",JSON.stringify(report))
	get_tree().quit(0 if test_errors.is_empty() else 1)

func prepare_achievements364():
	for name in achievement_system.data.fields:
		var field:Dictionary=achievement_system.data.fields[name]
		var base:Font=load(String(field.file))
		if int(field.font)==20:
			var spaced=FontVariation.new();spaced.base_font=base;spaced.spacing_glyph=4
			achievement_fonts[name]=spaced
		else:achievement_fonts[name]=base

func flush_achievements364():
	if achievement_system.pending.is_empty():return
	for id in achievement_system.pending:
		var row:Dictionary=achievement_system.data.rows[id]
		achievement_messages.append({"title":row.name,"message":str(int(row.reward))+" RP" if int(row.reward)>0 else "Well done!"})
	achievement_system.pending.clear()
	progress.save()

func update_achievement_messages364(dt:float):
	if state in ["paused","cinematic"] or (state in ["options","controls"] and previous_state=="paused"):return
	if achievement_message.is_empty() and not checkpoint_message.is_empty() and (state=="play" or death_menu_active()):return
	if achievement_message.is_empty() and not achievement_messages.is_empty():
		achievement_message=achievement_messages.pop_front();achievement_message_time=0.0
	if achievement_message.is_empty():return
	var before=achievement_message_time;achievement_message_time+=dt
	if before<.5 and achievement_message_time>=.5:snd.play("UpgradePerception",-8)
	if achievement_message_time>=4.3:achievement_message.clear()

func draw_achievement_message364():
	if achievement_message.is_empty() or achievement_message_time<.5:return
	# Original MessageBox: .5 delay, .3 Quart-out slide, 2.5 hold, 1 fade.
	var slide=clampf((achievement_message_time-.5)/.3,0,1)
	var alpha=1.0-pow(clampf(achievement_message_time-3.3,0,1),4)
	var offset=-500.0*pow(1-slide,4)*1.8
	for cid in ["1777","1778"]:
		var field:Dictionary=source_rules.message_fields[cid]
		var font:Font=checkpoint_fonts[cid];var size=int(float(field.height)*1.8)
		var width=(float(field.bounds[1])-float(field.bounds[0])-4.0)*1.8
		var pos=Vector2(297.575 if cid=="1777" else 298.025,85.55 if cid=="1777" else 102.7)*1.8+Vector2(offset-width/2,font.get_ascent(size))
		var text=String(achievement_message.title if cid=="1777" else achievement_message.message)
		draw_multiline_string_outline(font,pos+Vector2(2,3),text,HORIZONTAL_ALIGNMENT_CENTER,width,size,-1,3,Color(0,0,0,alpha*.8))
		draw_multiline_string(font,pos,text,HORIZONTAL_ALIGNMENT_CENTER,width,size,-1,Color(1,1,1,alpha))

func achievements_scroll_max364() -> float:
	return 5.0*40+24.0*45+5.0*10-180

func update_achievements_menu364(dt:float):
	panel_anim=minf(.4,panel_anim+dt)
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):achievement_scroll_direction=0
	if achievement_scroll_direction!=0:
		var key="achievements_ScrollUp" if achievement_scroll_direction<0 else "achievements_ScrollDown"
		var raw:Array=art.menu_data.buttons[key].rect
		if not Rect2(raw[0],raw[1],raw[2],raw[3]).has_point(achievement_pointer):achievement_scroll_direction=0
	achievement_scroll=clampf(achievement_scroll+achievement_scroll_direction*200.0*dt,0,achievements_scroll_max364())

func draw_achievement_field364(key:String,text:String,origin:Vector2,alpha:float):
	var field:Dictionary=achievement_system.data.fields[key]
	var bounds:Array=field.bounds;var matrix:Array=field.matrix
	var font:Font=achievement_fonts[key];var size=roundi(float(field.height)*1.8)
	var left=Vector2(float(matrix[4])+float(bounds[0])+2,float(matrix[5])+float(bounds[2])+2)*1.8+origin
	var width=(float(bounds[1])-float(bounds[0])-4)*1.8
	var align=HORIZONTAL_ALIGNMENT_RIGHT if int(field.layout.align)==1 else (HORIZONTAL_ALIGNMENT_CENTER if int(field.layout.align)==2 else HORIZONTAL_ALIGNMENT_LEFT)
	draw_string(font,left+Vector2(0,font.get_ascent(size)),text,align,width,size,Color(1,1,1,alpha))

func draw_achievements364():
	var t=1-pow(1-clampf(panel_anim/.4,0,1),2)
	var extra=Vector2(-600.0*(1-t)*1.8,0);var back=Vector2(0,100.0*(1-t)*1.8)
	art.draw_menu(self,"achievements_Achievements_base",0,extra)
	art.draw_menu(self,"achievements_BackPanel",0,back)
	var y=0.0
	for group in achievement_system.data.groups:
		draw_achievement_row364(-1,String(group[0]),y,extra);y+=40
		for id in range(int(group[1]),int(group[2])+1):
			draw_achievement_row364(id,"",y,extra);y+=45
		y+=10
	flash_button("achievements_ScrollUp","achievements_up",true,extra)
	flash_button("achievements_ScrollDown","achievements_down",true,extra)
	flash_button("achievements_Close","achievements_close",true,back)

func draw_achievement_row364(id:int,section:String,y:float,extra:Vector2):
	var relative=y-achievement_scroll
	var fade=clampf((relative+45)/45,0,1) if relative<100 else 1-clampf((relative-170+45)/45,0,1)
	if fade<=0:return
	var origin=Vector2(300,55+70+relative)*1.8+extra
	if id<0:draw_achievement_field364("SectionName",section,origin,fade);return
	var row:Dictionary=achievement_system.data.rows[id]
	var alpha=fade*(1.0 if bool(progress.achievements[id]) else .5)
	draw_achievement_field364("AchievementName",String(row.name),origin,alpha)
	draw_achievement_field364("Hint",String(row.hint),origin,alpha)
	draw_achievement_field364("Reward",str(int(row.reward))+" RP",origin,alpha)


func release364_capture(name:String):
	queue_redraw();await get_tree().process_frame;await RenderingServer.frame_post_draw
	var folder=OS.get_environment("ROTD_CHECK_OUTPUT")
	if not folder.is_empty():get_viewport().get_texture().get_image().save_png(folder+"/"+name+".png")

func release364_reset():
	progress.reset_achievements();progress.rp=0;achievement_system.reset_run();achievement_system.pending.clear();achievement_messages.clear();achievement_message.clear()

func release364_hood(kind:String,action:String="Idle"):
	hood={"kind":kind,"hp":100.0,"attack":0.0,"grip":0.0,"anim":action,"anim_time":0.0,"wait":0.0}
	dying_hood.clear()

func run_release364_checks():
	set_process(false);test_mode=true;progress.ephemeral=true;progress.settings.fullscreen=false;progress.settings.shake=false;apply_settings()
	await get_tree().process_frame;await get_tree().process_frame
	var tracker=preload("res://scripts/achievements.gd").new()
	var p=Progress.new();p.ephemeral=true
	expect(tracker.data.rows.size()==24 and tracker.data.groups.size()==5,"original 24 achievements and five categories")
	# Exact original thresholds, including zero-based combo counters.
	for n in range(4):tracker.road_hit(p,"female","",n*.2)
	expect(not p.achievements[9],"zombie combo below original counter threshold")
	tracker.road_hit(p,"male","",.8);expect(p.achievements[9],"zombie combo threshold")
	tracker.road_hit(p,"soldier","",1);expect(tracker.zombie_combo==0,"soldier breaks zombie combo")
	tracker.reset_run()
	for n in range(16):tracker.road_hit(p,"female" if n%2==0 else "soldier","",10+n*3.0)
	expect(not p.achievements[10],"alternating counter below threshold, independent of timing")
	tracker.road_hit(p,"male","",60);expect(p.achievements[10],"alternating counter threshold")
	tracker.road_hit(p,"civilian","",61);expect(tracker.flip_count==0 and tracker.flip_kind=="","civilian resets combos")
	for n in range(9):tracker.road_hit(p,"male","SlowRollOverHit",100+n*3.0)
	expect(not p.achievements[11],"nine slow kills")
	tracker.road_hit(p,"female","SlowRollOverHit",130);expect(p.achievements[11],"ten slow kills")
	for n in range(3):tracker.car_hit(p,n*.1)
	expect(not p.achievements[15],"vehicle combo below threshold")
	tracker.car_hit(p,.3);expect(p.achievements[15],"vehicle combo threshold")
	tracker.car_hit(p,1);expect(tracker.car_combo==0,"vehicle combo timeout")
	tracker.road_hit(p,"male","",200);tracker.road_hit(p,"male","",202);expect(tracker.zombie_combo==0,"zombie combo two-second timeout")
	tracker.hood_removed(p,"male",false,false,false);expect(not p.achievements[5] and not p.achievements[6],"swerve alone is not side-wall or pistol achievement")
	tracker.hood_removed(p,"female",false,true,false);tracker.hood_removed(p,"hard",true,false,false)
	tracker.hood_removed(p,"super",false,false,false);tracker.hood_removed(p,"soldier",true,false,true)
	expect(p.achievements[5] and p.achievements[6] and p.achievements[12] and p.achievements[21],"hood removal achievements")
	p.upgrades.fill(3);tracker.check_upgrades(p);expect(p.achievements[4],"all upgrades Tank")
	tracker.update_distance(p,"story",0,true,true,60);tracker.update_distance(p,"story",499,true,true,60)
	expect(not p.achievements[13] and not p.achievements[17],"speed below threshold and time achievement mode-specific")
	tracker.update_distance(p,"story",500,true,true,60);expect(p.achievements[13],"500m maximum speed")
	tracker.update_distance(p,"story",2999,true,true,60);expect(not p.achievements[14],"blown tires below threshold")
	tracker.update_distance(p,"story",3000,true,true,60);expect(p.achievements[14],"3km all blown tires")
	tracker.update_distance(p,"time",9999,false,false,44.9);expect(not p.achievements[2] and not p.achievements[17],"time mode below thresholds")
	tracker.update_distance(p,"time",10000,false,false,45);tracker.update_distance(p,"police",10000,false,false,0)
	expect(p.achievements[2] and p.achievements[3] and p.achievements[17],"mode distance and bonus time achievements")
	tracker.escaped(p,"story",14.99);expect(p.achievements[0] and not p.achievements[16],"escape below nuke threshold")
	tracker.escaped(p,"hardcore",15);expect(p.achievements[1] and p.achievements[16],"hardcore escape and nuke threshold")
	for n in range(50-int(p.achievement_totals.soldiers)):tracker.road_hit(p,"soldier","",300+n*3.0)
	for n in range(30):tracker.road_hit(p,"male","GibHit",500+n*3.0)
	for n in range(25-int(p.achievement_totals.civilians)):tracker.road_hit(p,"civilian","",700+n*3.0)
	for n in range(9):tracker.super_dodged(p);tracker.bombing_dodged(p)
	expect(not p.achievements[22] and not p.achievements[23],"nine super and bombing dodges")
	tracker.reset_run();expect(p.achievement_totals.soldiers==50 and tracker.slow_kills==0,"global counters survive runs; local counters reset")
	tracker.super_dodged(p);tracker.bombing_dodged(p);tracker.unlock(p,7);tracker.unlock(p,8)
	expect(p.achievements.all(func(flag):return bool(flag)),"all 24 original achievements reachable")
	var rewards=0
	for row in tracker.data.rows:rewards+=int(row.reward)
	expect(p.rp==rewards and tracker.pending.size()==24,"exact original one-time RP totals and notifications")
	for id in range(24):expect(not tracker.unlock(p,id),"duplicate unlock ignored "+str(id))
	expect(p.rp==rewards and tracker.pending.size()==24,"repeat awards never farm RP")
	# Interrupted distance attempts must restart from the next eligible position.
	var q=Progress.new();q.ephemeral=true;tracker.reset_run()
	tracker.update_distance(q,"story",0,true,true,0);tracker.update_distance(q,"story",499,false,false,0)
	tracker.update_distance(q,"story",500,true,true,0);tracker.update_distance(q,"story",999,true,true,0)
	expect(not q.achievements[13] and not q.achievements[14],"speed and tire interruption resets distance")
	# Round trip and migration use ONLY the isolated check output path.
	var folder=OS.get_environment("ROTD_CHECK_OUTPUT")
	if not folder.is_empty():
		p.ephemeral=false;p.save_path=folder+"/achievement_test_save.cfg";p.checkpoint=8;p.settings.music=false;expect(p.save(),"save extended progress")
		var loaded=Progress.new();loaded.save_path=p.save_path;loaded.read_save()
		expect(loaded.achievements==p.achievements and loaded.rp==rewards and loaded.achievement_totals==p.achievement_totals and loaded.achievement_hood_types==p.achievement_hood_types,"all achievement data round trip")
		expect(loaded.checkpoint==8 and not loaded.settings.music,"ordinary progress and settings round trip")
		tracker.reset_run();tracker.unlock(loaded,0);expect(loaded.rp==rewards,"reload prevents reward duplication")
		var cfg=ConfigFile.new();cfg.set_value("progress","rp",1234);cfg.set_value("progress","checkpoint",6);cfg.set_value("progress","finished",true);cfg.set_value("progress","upgrades",[3,3,3,3,3,3,3,3]);cfg.set_value("settings","music",false)
		cfg.save(folder+"/legacy_save.cfg");loaded=Progress.new();loaded.save_path=folder+"/legacy_save.cfg";loaded.read_save()
		expect(loaded.rp==1234 and loaded.checkpoint==6 and not loaded.settings.music and loaded.achievements[0] and loaded.achievements[4] and loaded.achievements.count(true)==2,"legacy save migration preserves RP, upgrades and settings without invented history")
		cfg.set_value("achievements","completed",[true]);cfg.set_value("achievements","soldiers",-3);cfg.set_value("achievements","hood_types",["female","female","invalid"]);cfg.save(folder+"/legacy_save.cfg");loaded.read_save()
		expect(loaded.achievements.size()==24 and loaded.achievement_totals.soldiers==0 and loaded.achievement_hood_types==["female"],"sanitize short flags, negative totals and duplicate hood types")
	# Exercise the port's actual gameplay events, not just the tracker.
	mode="time";progress.checkpoint=0;start_run();clear_original_tutorial();entities.clear();road_signs.clear();scenery.clear();release364_reset();snd.silent=true
	expect(time_left==30,"original Dead On Time starts at 30 seconds")
	achievement_system.update_distance(progress,mode,0,false,false,time_left);expect(not progress.achievements[17],"no instant Time To Spare on new run")
	fire_started=false;collide(spawn_entity("water",0,position_z+10));expect(not progress.achievements[7],"water without fire does not unlock")
	fire_started=true;collide(spawn_entity("water",0,position_z+10));expect(progress.achievements[7] and not fire_started,"burning engine water jug unlock")
	release364_hood("female");kill_hood(false,true);expect(not progress.achievements[5] and time_left==36,"handbrake removal bonus without side-wall award")
	release364_hood("male");hood_collision(200,true);expect(progress.achievements[5] and time_left==42,"actual side collision removes hood enemy")
	release364_hood("soldier","Attack");update_hood(12.0/30,false);expect(bool(hood.get("gun_out",false)),"original soldier draw-gun event opens Quick Draw window")
	kill_hood(true);expect(progress.achievements[12] and progress.achievements[6] and time_left==42,"shooting armed hood soldier unlocks Quick Draw, no zombie time bonus")
	progress.achievements[12]=false;release364_hood("soldier","Attack");update_hood(29.0/30,false);expect(not bool(hood.get("gun_out",false)),"soldier fire closes Quick Draw window")
	kill_hood(true);expect(not progress.achievements[12],"late soldier shot cannot unlock Quick Draw")
	release364_hood("hard");kill_hood(true);expect(time_left==50,"hood pistol zombie time bonus eight")
	achievement_system.update_distance(progress,mode,0,false,false,time_left);flush_achievements364();expect(progress.achievements[17],"earned time bonus unlocks Time To Spare")
	dying_hood={"kind":"male","time":0.0,"gun":true,"tossed":false,"anim":"Shot"};speed=30;car35.seek_speed(speed);var clock_before=time_left
	collide(spawn_entity("female",0,position_z+10));expect(time_left==clock_before+2 and achievement_system.slow_kills==1,"actual low speed road zombie and first time bonus")
	speed=30;car35.seek_speed(speed);total_time+=.1;collide(spawn_entity("male",0,position_z+10));expect(time_left==clock_before+5,"actual chained zombie bonus three")
	speed=100;car35.seek_speed(speed);clock_before=time_left;collide(spawn_entity("soldier",0,position_z+10));expect(time_left==clock_before,"road soldier has no zombie time bonus")
	collide(spawn_entity("civilian",0,position_z+10));expect(time_left==clock_before-10,"civilian time penalty ten")
	collide(spawn_entity("feeders",0,position_z+10));expect(time_left==clock_before-7,"feeders bonus three")
	achievement_system.car_combo=0;achievement_system.car_time=-9999;hit_cooldown=1
	for n in range(4):total_time=100+n*.1;var car=spawn_entity("cars",0,position_z+10);collide(car);collide(car)
	expect(progress.achievements[15] and achievement_system.car_combo==3,"unique car contacts count through damage cooldown; duplicate actor cannot inflate combo")
	entities.clear();position_z=1000;spawn_entity("super",8,position_z-20);var dodge_count=int(progress.achievement_totals.super_dodges);update_entities(.01);update_entities(.01)
	expect(progress.achievement_totals.super_dodges==dodge_count+1,"passed unhit mutant counted once")
	spawn_source_helicopter();source_helicopter_hit();source_helicopter_hit();expect(not progress.achievements[8],"helicopter not defeated after two hits")
	source_helicopter_hit();expect(progress.achievements[8],"actual helicopter defeat")
	var bombs_before=int(progress.achievement_totals.bomb_dodges)
	spawn_source_jet();jet.phase="return";jet.z=position_z-300;jet.return_sound=false;jet.bombs_dropped=true;jet.player_hit=false;jet.result_timer=3.99;jet.drops=1;jet.total_drops=2;jet.bombs=[]
	update_source_jet(.02);update_source_jet(.02);expect(progress.achievement_totals.bomb_dodges==bombs_before+1 and jet.phase=="wait","actual missed bombing pass counted once")
	jet.phase="return";jet.result_timer=3.99;jet.player_hit=true;update_source_jet(.02);expect(progress.achievement_totals.bomb_dodges==bombs_before+1,"bombing that hits player does not count as dodge")
	var soldier_total=int(progress.achievement_totals.soldiers);mode="story";start_run();clear_original_tutorial();expect(progress.achievement_totals.soldiers==soldier_total and progress.achievements[7],"new run preserves achievements and cumulative counts")
	release364_reset();position_z=start_z;nuke_time=15;finish_run("check",true);expect(progress.rp==700 and progress.achievements[0] and progress.achievements[16],"escape RP comes from original one-time achievements")
	start_run();clear_original_tutorial();position_z=start_z;nuke_time=15;finish_run("check",true);expect(progress.rp==700,"repeat escape cannot farm achievement RP")
	# Original menu, modal behavior, completed brightness, scrolling and close.
	state="menu";await frontend_click("achievements");expect(state=="achievements" and achievement_scroll==0,"main menu Achievements button opens panel")
	activate("story");expect(state=="achievements","achievement panel blocks underlying mode buttons")
	panel_anim=.4;achievement_messages.clear();achievement_message.clear();checkpoint_message.clear();checkpoint_queue.clear();await release364_capture("achievements_top364")
	achievement_scroll=560;await release364_capture("achievements_middle364")
	achievement_scroll=achievements_scroll_max364();await release364_capture("achievements_bottom364")
	# Use held mouse input at the original arrow, then leave its hit box.
	achievement_scroll=0;panel_anim=.4;queue_redraw();await get_tree().process_frame;await RenderingServer.frame_post_draw
	var down_rect:Array=art.menu_data.buttons.achievements_ScrollDown.rect
	var arrow_pos=Rect2(down_rect[0],down_rect[1],down_rect[2],down_rect[3]).get_center()+UI_OFFSET
	var motion=InputEventMouseMotion.new();motion.position=arrow_pos;motion.global_position=arrow_pos;Input.parse_input_event(motion);await get_tree().process_frame
	var click=InputEventMouseButton.new();click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;click.position=arrow_pos;Input.parse_input_event(click);await get_tree().process_frame
	update_achievements_menu364(.5);expect(achievement_scroll==100,"held original down arrow scrolls at 200 source units per second: "+str([achievement_scroll,achievement_scroll_direction,Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT),achievement_pointer,arrow_pos]))
	motion.position=Vector2(1,1);motion.global_position=Vector2(1,1);Input.parse_input_event(motion);await get_tree().process_frame;update_achievements_menu364(.5);expect(achievement_scroll==100 and achievement_scroll_direction==0,"leaving arrow stops held scrolling: "+str([achievement_scroll,achievement_scroll_direction,achievement_pointer]))
	click.pressed=false;Input.parse_input_event(click);await get_tree().process_frame
	achievement_scroll=0;DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	await get_tree().process_frame;await get_tree().process_frame;update_viewport_layout();await release364_capture("achievements_maximized364")
	expect(DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_MAXIMIZED,"achievement menu preserves maximized window")
	achievement_scroll=99999;update_achievements_menu364(.01);expect(achievement_scroll==1150,"scroll lower bound matches original content height")
	achievement_scroll=-10;update_achievements_menu364(.01);expect(achievement_scroll==0,"scroll upper bound")
	activate("achievements_down");var release=InputEventMouseButton.new();release.button_index=MOUSE_BUTTON_LEFT;release.pressed=false;_input(release);expect(achievement_scroll_direction==0,"mouse release stops held arrow")
	var esc=InputEventKey.new();esc.keycode=KEY_ESCAPE;esc.physical_keycode=KEY_ESCAPE;esc.pressed=true;_input(esc);expect(state=="menu","Escape closes achievement menu")
	activate("achievements");panel_anim=.4;await frontend_click("achievements_close");expect(state=="menu","original Close button returns to main menu")
	# Notice queue waits for checkpoint, pauses, and displays original RP message.
	state="play";achievement_messages=[{"title":"Hydroficial Intelligence","message":"25 RP"}];checkpoint_message={"title":"checkpoint"};update_achievement_messages364(.6);expect(achievement_message.is_empty(),"notice waits for checkpoint message")
	state="paused";update_achievement_messages364(.6);expect(achievement_message.is_empty(),"notice freezes while paused")
	state="garage";update_achievement_messages364(.9);expect(achievement_message.title=="Hydroficial Intelligence","queued notice displays original name and RP")
	panel_anim=1;await release364_capture("achievement_notice364");update_achievement_messages364(4.3);expect(achievement_message.is_empty(),"notice expires with original timeline")
	# Cancel preserves progress; only confirmed Delete Data clears achievements.
	state="options";var flags=progress.achievements.duplicate();activate("delete_save");activate("delete_cancel");expect(progress.achievements==flags,"cancel deletion preserves achievements")
	activate("delete_save");activate("delete_yes");expect(progress.achievements.count(true)==0 and progress.achievement_totals.values().all(func(v):return int(v)==0),"confirmed delete clears achievement flags and totals")
	print("RELEASE364_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",JSON.stringify({"original_achievements":24,"reward_total":rewards,"errors":test_errors}))
	get_tree().quit(0 if test_errors.is_empty() else 1)

func run_release365_checks():
	set_process(false);test_mode=true;progress.ephemeral=true;preview_mode=false
	progress.settings.fullscreen=false;progress.settings.shake=false;progress.upgrades=[0,0,0,0,0,0,0,0]
	apply_settings();AudioServer.set_bus_volume_db(0,-80)
	await get_tree().process_frame;await get_tree().process_frame
	mode="story";start_run();set_process(false);snd.silent=true;position_z=1000;entities.clear()
	var walked=0;var overlaps=0;var flips=0
	for fps in [30,60,120]:
		for side in [-1,1]:
			entities.clear();speed=0;player_x=-8
			var car=spawn_entity("cars",0,1050);car.radius=2.0
			var civ=spawn_entity("civilian",side*.1,1060);civ.direction=-side;civ.plea_played=true
			var previous=int(civ.direction);var changes=0
			for n in range(fps*7):
				move_civilian365(civ,1.0/fps)
				if absf(float(civ.z)-float(car.z))<2.4 and absf(float(civ.x))<2.49:overlaps+=1
				if int(civ.direction)!=previous:changes+=1;previous=int(civ.direction)
			flips+=changes
			expect(float(civ.z)<1045 and changes<7,"civilian passes parked car without jitter "+str([fps,side,civ.x,civ.z,changes]))
			walked+=1
		# Two staggered cars, a narrow gap, and an initially overlapping spawn.
		entities.clear();speed=0;player_x=-8
		var a=spawn_entity("cars",-1,1050);a.radius=2.0
		var b=spawn_entity("cars",3.3,1050);b.radius=1.7
		var c=spawn_entity("civilian",0,1050);c.plea_played=true
		for n in range(fps*5):
			move_civilian365(c,1.0/fps)
			for car in [a,b]:
				if absf(float(c.z)-float(car.z))<2.4 and absf(float(c.x)-float(car.x))<float(car.radius)+.49:overlaps+=1
		expect(float(c.z)<1045,"civilian escapes staggered parked vehicles "+str(fps))
		entities.clear();player_x=0;speed=0;position_z=1000;civilians_hit=0;time_left=30;run_rp=0
		var stopped=spawn_entity("civilian",0,1006);stopped.plea_played=true;stopped.direction_time=999;stopped.direction=1
		for n in range(fps*3):update_entities(1.0/fps)
		expect(not stopped.dead and civilians_hit==0 and time_left==30 and run_rp==0,"stopped player cannot kill or penalize civilian "+str(fps))
		var contact=spawn_entity("civilian",0,1000.5);contact.last_z=2;contact.plea_played=true
		collide(contact);expect(not contact.dead and civilians_hit==0,"direct stopped collision is harmless")
		speed=15;collide(contact);expect(contact.dead and civilians_hit==1,"moving player still hits civilian")
	expect(overlaps==0,"civilian movement never penetrates parked vehicles: "+str(overlaps))
	# A solid row may hold a pedestrian; it must not flip every frame.
	entities.clear();speed=0;player_x=-8
	for x in [-7,0,7]:var car=spawn_entity("cars",x,1050);car.radius=4
	var boxed=spawn_entity("civilian",0,1054);var old_direction=boxed.direction
	for n in range(300):move_civilian365(boxed,1.0/60)
	expect(boxed.z>=1052.4 and boxed.direction==old_direction,"boxed civilian waits steadily outside cars")
	# Sample real source catalog choices, and validate passable long-vehicle rows.
	var spawned=0;var silent_cars=0;var alarms=0;var bad_rows=0
	mode="story";segment=12;spawn_segment=12;position_z=0;speed=0;player_x=0
	for seed_value in range(24):
		rng.seed=365000+seed_value;entities.clear()
		for name in source_rules.patterns:
			entities.clear();load_source_pattern(name,100,0.6)
			for car in entities:
				if car.kind!="cars":continue
				spawned+=1
				if String(car.ambient_sound).is_empty():silent_cars+=1
				if String(car.ambient_sound).begins_with("CarAlarm"):alarms+=1
				var nearby:Array=[];var has_long=false
				for other in entities:
					if other.kind=="cars" and absf(float(other.z)-float(car.z))<12:
						nearby.append(other);has_long=has_long or float(other.radius)>=3.5
				if has_long and not free_lanes365(nearby,1.1).any(func(lane):return lane.y-lane.x>=.4):bad_rows+=1
	# Explicit bus/truck plus small car across the full width.
	entities.clear();var truck=spawn_entity("cars",-2,100);truck.radius=6.315
	var blocker=spawn_entity("cars",7,100);blocker.radius=2.0;space_vehicle365(blocker)
	expect(blocker.z>=112 and is_equal_approx(float(truck.radius),6.315),"blocking row separates without shrinking original truck")
	expect(spawned>5000 and silent_cars>0 and alarms>0 and bad_rows==0,"source pattern road clearance and silent variants "+str([spawned,silent_cars,alarms,bad_rows]))
	var challenge_rows=0
	for game_mode in ["story","hardcore","time","police"]:
		mode=game_mode;segment=12;spawn_segment=12;position_z=15000;next_pattern=position_z+100;entities.clear()
		for pattern in range(80):
			spawn_pattern()
			for car in entities:
				if car.kind!="cars":continue
				var nearby:Array=[];var has_long=false
				for other in entities:
					if other.kind=="cars" and absf(float(other.z)-float(car.z))<12:
						nearby.append(other);has_long=has_long or float(other.radius)>=3.5
				if has_long:
					challenge_rows+=1
					expect(free_lanes365(nearby,1.1).any(func(lane):return lane.y-lane.x>=.4),"adjacent generated long rows remain passable "+game_mode)
			entities=entities.filter(func(e):return float(e.z)>next_pattern-150)
	expect(challenge_rows>100,"all four modes and neighboring patterns exercise wide-vehicle clearance")
	# Glass impacts use the seven original samples; exposed body uses flesh cycle.
	snd.silent=false;snd.enabled=true;awarded=false;mode="story";health=100;glass_hp=100;bullet_hit_bag365.clear();bullet_flesh365=0
	var hits:Dictionary={}
	for n in range(7):
		for player in snd.effects:player.stop()
		take_bullet365(1,1,"Military");hits[last_bullet_sound365]=true
		expect(snd.effects.any(func(player):return player.playing and player.stream==snd.stream(last_bullet_sound365)),"actual military glass impact stream "+str(n))
	expect(hits.size()==7 and glass_hp==93 and health==100,"military glass hits use original nonrepeating impact bag")
	glass_hp=0
	for n in range(6):
		for player in snd.effects:player.stop()
		take_bullet365(1,1,"Military")
		expect(last_bullet_sound365=="BulletHitFlesh%02d" % (n%3+1),"original flesh impact cycle "+str(n))
		expect(snd.effects.any(func(player):return player.playing and player.stream==snd.stream(last_bullet_sound365)),"actual military body impact stream "+str(n))
	expect(health<100,"unprotected military bullets damage body")
	for player in snd.effects:player.stop()
	damage_player(1,"Zombie")
	expect(not snd.effects.any(func(player):return player.playing),"zombie body damage cannot play metal gun impacts")
	entities.clear();player_x=0;position_z=0;glass_hp=100;health=100;speed=60
	var gunner=spawn_entity("soldier",0,30);gunner.behavior="stationary";gunner.soldier_state="Fire";gunner.anim_time=0;gunner.fire_timer=0
	snd.begin_world_frame(player_x,position_z);update_entities(.11)
	expect(glass_hp<100 and last_bullet_sound365.begins_with("BulletHit") and snd.world_requests.any(func(request):return request.key=="SoldierMachineGunFire"),"actual roadside soldier uses source automatic gun and glass impact")
	glass_hp=0;update_entities(.11);expect(last_bullet_sound365.begins_with("BulletHitFlesh"),"actual roadside soldier uses flesh after windshield is gone")
	# Healthy clear-road cruise must not start any random skid, scraping or menu sound.
	start_run();set_process(false);entities.clear();scenery.clear();road_signs.clear();next_pattern=1e9;next_road_sign=1e9;air_delay=1e9;helicopter_delay=1e9;jet_delay=1e9
	snd.update_menu_ambience(0,false);car35.seek_speed(60);speed=60;player_x=0;glass_hp=100;car_hp=100;tires=0;oil_time=0;fire_started=false
	for n in range(1200):simulate(1.0/60,1,false,false,0)
	expect(not snd.menu_ambient.playing and not snd.action_loops.tire_brake.playing and not snd.action_loops.tire_scrape.playing and not snd.action_loops.side_scrape.playing,"healthy clear-road drive has no unrelated ambient/skid/scrape loops")
	car35.state=car35.BRAKE;update_car_audio();expect(snd.action_loops.tire_brake.playing,"original braking skid retained")
	car35.state=car35.COAST;oil_time=0;update_car_audio();expect(not snd.action_loops.tire_brake.playing,"skid stops when braking ends")
	# Authored engine physics at all upgrades and three frame rates.
	for level in range(4):
		var distances:Array=[]
		for fps in [30,60,120]:
			var model=preload("res://scripts/car35.gd").new();model.reset(level)
			var distance=0.0
			for n in range(fps*30):model.update(1.0/fps,1,false,false,true);distance+=model.speed/3.6/fps
			expect(is_equal_approx(model.speed,float(model.MAX_SPEEDS[level])),"original upgraded top speed "+str([level,fps]))
			distances.append(distance)
			for n in range(fps*5):model.update(1.0/fps,0,true,false,true)
			expect(model.speed<.01,"source brake stops car "+str([level,fps]))
			expect(absf(float(distances[0])-distance)<2,"physics consistent across frame rates "+str([level,fps]))
	# Original oil sprite is scale 1; its three-metre collision bounds stay intact.
	var oil=art.world_frame("oil",0)
	expect(absf(float(oil.rect[2])/maxf(1,float(oil.get("density",1)))*.0034959-4.523)<.02,"native oil artwork width follows original scale and aspect")
	start_run();set_process(false);snd.silent=true;speed=60;car35.seek_speed(60);player_x=0;position_z=1000;entities.clear();road_signs.clear();scenery.clear();hood.clear();effects.clear();impacts.clear();blood.clear()
	var slick=spawn_entity("oil",-3,1025);expect(slick.radius==1.5,"original oil collision width remains three metres")
	await release364_capture("oil_scale365")
	entities.clear();truck=spawn_entity("cars",-3.481,1040);truck.anim="vehicle";truck.frame=120;truck.radius=6.315
	blocker=spawn_entity("cars",7,1040);blocker.radius=2.0;space_vehicle365(blocker)
	spawn_entity("civilian",5,1027);await release364_capture("highway_clearance365")
	snd.stop_action();snd.stop_world_audio()
	var report={"civilian_cases":walked,"civilian_overlaps":overlaps,"direction_changes":flips,"source_vehicles":spawned,"silent_variants":silent_cars,"alarms":alarms,"blocked_long_rows":bad_rows,"adjacent_long_rows":challenge_rows,"errors":test_errors}
	var folder=OS.get_environment("ROTD_CHECK_OUTPUT")
	if not folder.is_empty():var out=FileAccess.open(folder+"/release365_check.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"\t"));out.close()
	print("RELEASE365_CHECK: ","PASS" if test_errors.is_empty() else "FAIL"," ",JSON.stringify(report))
	get_tree().quit(0 if test_errors.is_empty() else 1)

