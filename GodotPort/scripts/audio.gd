extends Node

signal voice_started(key: String, caption: String, duration: float)
signal voice_finished(key: String)
signal radio_started(key:String,duration:float)
signal radio_finished(key:String)
const VOICE_GAP = 2.5
var clips: Dictionary = {}
var cache: Dictionary = {}
var music: AudioStreamPlayer
var horn_player: AudioStreamPlayer
var engine: AudioStreamPlayer
var voice: AudioStreamPlayer
var radio: AudioStreamPlayer
var radio_key=""
var radio_priority=-1
var voice_priority=-1
var gameplay_dialogue=false
var gameplay_failed=false
var effects: Array[AudioStreamPlayer] = []
var enabled = true
var music_enabled = true
var silent = false
var music_name = ""
var music_looped = true
var music_gain = -13.0
var ui_effect: AudioStreamPlayer
var voice_target_db = -6.0
var voice_queue: Array[Dictionary] = []
var last_voice_key = ""
var voice_key = ""
var voice_envelopes: Dictionary = {}
var voice_gap_left = 0.0
var action_paused = false
var menu_ambient: AudioStreamPlayer
var menu_ambient_active = false
var menu_ambient_delay = 5.0
var menu_ambient_bag: Array[String] = []
var menu_ambient_key = ""
var action_loops: Dictionary = {}
var engine_key=""
var engine_revision=-1

func _ready():
	clips = JSON.parse_string(FileAccess.get_file_as_string("res://assets/sounds.json"))
	voice_envelopes=JSON.parse_string(FileAccess.get_file_as_string("res://assets/voice_envelopes.json"))
	menu_ambient = _player()
	menu_ambient.finished.connect(func():menu_ambient_delay=randf_range(5,10))
	var limiter=AudioEffectHardLimiter.new()
	limiter.pre_gain_db=0
	limiter.ceiling_db=-1.5
	AudioServer.add_bus_effect(0,limiter)
	ui_effect=_player()
	music = _player()
	engine = _player()
	horn_player = _player()
	radio=_player();radio.finished.connect(_radio_completed)
	voice = _player()
	voice.finished.connect(_voice_completed)
	for i in range(12): effects.append(_player())
	setup_world_audio()
	warm_audio()

func _player() -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	add_child(p)
	return p

func _process(dt: float):
	var music_target=music_gain-4 if voice.playing or radio.playing else music_gain
	music.volume_db=move_toward(music.volume_db,music_target,dt*180)
	if voice.playing:voice.volume_db=move_toward(voice.volume_db,voice_target_db,dt*300)
	if ui_effect.playing:ui_effect.volume_db=move_toward(ui_effect.volume_db,-14,dt*300)
	if action_paused: return
	if not enabled or silent:
		if not voice_key.is_empty() or not voice_queue.is_empty() or not radio_key.is_empty(): clear_voice()
		return
	if not voice_key.is_empty(): return
	voice_gap_left = maxf(0, voice_gap_left - dt)
	if voice_gap_left <= 0: _start_next_voice()

func stream(key: String, looped: bool = false) -> AudioStream:
	if not clips.has(key): return null
	var ck = key + ("_loop" if looped else "")
	if not cache.has(ck):
		var snd = load(clips[key])
		if snd == null: return null
		if looped:
			snd = snd.duplicate()
			if snd is AudioStreamWAV:
				snd.loop_mode = AudioStreamWAV.LOOP_FORWARD
				snd.loop_begin = 0
				snd.loop_end = int(snd.get_length()*snd.mix_rate)
		cache[ck] = snd
	return cache[ck]

func set_action_loop(channel:String,key:String,active:bool,gain:float=-10.0):
	var p:AudioStreamPlayer
	if not action_loops.has(channel):
		p=_player();action_loops[channel]=p
	else:p=action_loops[channel]
	if not active or silent or not enabled:
		p.stop();return
	var clip=stream(key,true)
	if clip==null:return
	if p.playing and p.stream==clip:
		p.volume_db=gain;return
	p.stop();p.stream=clip;p.volume_db=gain;p.stream_paused=action_paused;p.play()

func play(key: String, gain: float = -7, pitch: float = 1):
	if silent or not enabled: return
	var sound = stream(key)
	if sound == null: return
	if key.begins_with("Upgrade") or key=="ErrorSound":
		# A single feedback channel: spam cannot stack or repeatedly restart transients.
		if ui_effect.playing:return
		ui_effect.stream=sound;ui_effect.volume_db=-36;ui_effect.pitch_scale=1;ui_effect.play()
		return
	for p in effects:
		if not p.playing:
			p.stream=sound; p.volume_db=minf(-7,gain); p.pitch_scale=pitch; p.play()
			return

# Legacy callers may pass interrupt; scene changes explicitly clear dialogue instead.
func speak(key: String, _interrupt: bool = false, caption: String = "", gain: float = -4):
	if silent or not enabled or not clips.has(key): return
	if gameplay_dialogue:
		if key.begins_with("Player"):player_reaction(key,gameplay_priority(key),gain)
		else:play_radio(key,2 if key.begins_with("CheckPoint") or key.begins_with("NukeRunCount") else (1 if key.begins_with("Helicopter") or key.begins_with("Jet") else 0),gain)
		return
	if key == voice_key: return
	for item in voice_queue:
		if item.key == key: return
	# Countdown updates describe current time: keep only the newest waiting number.
	if key.begins_with("NukeRunCount") and key != "NukeRunCountStart":
		for i in range(voice_queue.size()-1,-1,-1):
			if String(voice_queue[i].key).begins_with("NukeRunCount") and voice_queue[i].key != "NukeRunCountStart":
				voice_queue.remove_at(i)
	voice_queue.append({"key":key,"caption":caption,"gain":gain})
	if not action_paused and voice_key.is_empty() and voice_gap_left <= 0: _start_next_voice()

func _start_next_voice():
	if voice_queue.is_empty() or not voice_key.is_empty() or action_paused: return
	var item: Dictionary = voice_queue.pop_front()
	var sound = stream(item.key)
	if sound == null: return
	voice_key = item.key
	voice.stream = sound
	voice_target_db = minf(-6,float(item.gain))
	voice.volume_db = -36
	voice.play()
	voice_started.emit(voice_key, item.caption, sound.get_length())

func _voice_completed():
	var finished_key = voice_key
	last_voice_key=voice_key
	voice_key = ""
	voice_priority=-1
	voice_gap_left = 0.0 if gameplay_dialogue else VOICE_GAP
	voice_finished.emit(finished_key)

func clear_voice():
	clear_radio();voice_priority=-1
	voice.stop()
	voice_queue.clear()
	last_voice_key=""
	voice_key = ""
	voice_gap_left = 0
	voice_finished.emit("")

func dialogue_busy() -> bool:
	return not voice_key.is_empty() or not radio_key.is_empty() or not voice_queue.is_empty() or voice_gap_left > 0

func set_music(key: String, looped: bool = true):
	if key == music_name and looped == music_looped: return
	music_looped=looped
	music_name=key
	music.stop()
	if silent: return
	music.stream=stream(key,looped)
	if music.stream and music_enabled:
		music.volume_db=-50;music.play()

func update_engine(_speed:float,active:bool,_brake:bool,level:int=0,engine_state:int=0,clock:float=0.0,scale:float=1.0,revision:int=0):
	if action_paused:return
	if not active or not enabled or silent:
		engine.stop();engine_key="";engine_revision=-1;return
	var names=["CarIdle","CarAccel","CarMaxSpeed","CarDeccelNoBrake","CarDeccelBrake","CarDeccelNoBrake"]
	var key=String(names[clampi(engine_state,0,5)])+str(clampi(level,0,3)+1)
	var looped=engine_state in [0,2]
	if key!=engine_key or revision!=engine_revision:
		engine.stop();engine.stream=stream(key,looped);engine_key=key;engine_revision=revision
		engine.pitch_scale=1.0;engine.volume_db=-14.0
		if engine.stream!=null:engine.play(0.0 if looped else clampf(clock/scale,0.0,maxf(0.0,engine.stream.get_length()-.001)))
	elif looped and not engine.playing:engine.play()

func pause_all(paused: bool):
	action_paused=paused
	engine.stream_paused=paused
	horn_player.stream_paused=paused
	voice.stream_paused=paused
	radio.stream_paused=paused
	ui_effect.stream_paused=paused
	for p in effects: p.stream_paused=paused
	for p in action_loops.values():p.stream_paused=paused
	for slot in world_slots:slot.player.stream_paused=paused

func stop_action():
	gameplay_dialogue=false;gameplay_failed=false
	update_menu_ambience(0,false)
	engine.stop();engine_key="";engine_revision=-1
	horn_player.stop()
	ui_effect.stop()
	clear_voice()
	for p in effects: p.stop()
	for p in action_loops.values():p.stop()
	stop_world_audio()

# Garage purchase reactions replace John's previous reaction, as in PlayPlayerDialog.
# A radio line already playing is allowed to finish; its normal gap is retained.
func upgrade_voice(key: String):
	if silent or not enabled or not clips.has(key):return
	for i in range(voice_queue.size()-1,-1,-1):
		if String(voice_queue[i].key).begins_with("PlayerUpgrade") or voice_queue[i].key=="PlayerFirstTimeInGarage":
			voice_queue.remove_at(i)
	if voice_key.begins_with("Player"):
		var old_key=voice_key
		voice.stop()
		voice_key=""
		voice_gap_left=0
		voice_finished.emit(old_key)
	voice_queue.push_front({"key":key,"caption":"","gain":-2.0})
	if not action_paused and voice_key.is_empty():
		# Idle garage reactions do not inherit a pause from an older John line.
		if last_voice_key.begins_with("Player"):voice_gap_left=0
		if voice_gap_left<=0:_start_next_voice()

func voice_level() -> float:
	if not voice.playing or action_paused:return 0.0
	var envelope:Array=voice_envelopes.get(voice_key,[])
	if envelope.is_empty():return 1.0
	var sample=clampi(int(voice.get_playback_position()*30),0,envelope.size()-1)
	return float(envelope[sample])


# Source RDGame uses all 21 zombie moans and waits 5-10 seconds after each clip.
func update_menu_ambience(dt: float, active: bool):
	active=active and enabled and not silent
	if not active:
		menu_ambient.stop()
		menu_ambient_active=false
		menu_ambient_key=""
		return
	if not menu_ambient_active:
		menu_ambient_active=true
		menu_ambient_delay=randf_range(5,10)
	if menu_ambient.playing:return
	menu_ambient_delay=maxf(0,menu_ambient_delay-dt)
	if menu_ambient_delay>0:return
	if menu_ambient_bag.is_empty():
		for i in range(1,10):menu_ambient_bag.append("MaleZombieMoan%02d"%i)
		for i in range(1,13):menu_ambient_bag.append("FemaleZombieMoan%02d"%i)
		menu_ambient_bag.shuffle()
	menu_ambient_key=menu_ambient_bag.pop_back()
	menu_ambient.stream=stream(menu_ambient_key)
	menu_ambient.volume_db=-10
	if menu_ambient.stream:menu_ambient.play()
	menu_ambient_delay=randf_range(5,10)

# A single held horn channel, matching source StartHorning/StopHorning.
func set_horn(key:String,active:bool):
	if not active or silent or not enabled:
		horn_player.stop();return
	var clip=stream(key,true)
	if clip==null:return
	if horn_player.playing and horn_player.stream==clip:return
	horn_player.stop();horn_player.stream=clip;horn_player.volume_db=-12;horn_player.play()


# Release 20: source RDEntity stereo pan / longitudinal attenuation.
# World pool is bounded; one bus panner per slot avoids screen-space audio transforms.
const WORLD_POOL_SIZE = 24
const MAX_CAR_ALARMS = 1
const CAR_ALARM_GAIN_DB = -26.0
var world_slots: Array[Dictionary] = []
var world_requests: Array[Dictionary] = []
var world_listener = Vector2.ZERO
var world_serial = 0
var selected_alarm_channels: Array[String] = []

func setup_world_audio():
	for i in range(WORLD_POOL_SIZE):
		var bus_name="World20_"+str(i)
		var bus=AudioServer.get_bus_index(bus_name)
		if bus<0:
			AudioServer.add_bus()
			bus=AudioServer.bus_count-1
			AudioServer.set_bus_name(bus,bus_name)
			AudioServer.set_bus_send(bus,"Master")
			AudioServer.add_bus_effect(bus,AudioEffectPanner.new())
		var p=_player()
		p.bus=bus_name
		world_slots.append({"player":p,"pan":AudioServer.get_bus_effect(bus,0),"channel":"","loop":false,"target":-80.0})

func spatial_mix(x:float,z:float,profile:String="default",back:float=4.0) -> Vector2:
	var params=Vector4(5,100,1,5)
	match profile:
		"car":params=Vector4(5,80,1,5)
		"loud":params=Vector4(10,200,2,10)
		"superloud":params=Vector4(500,1000,2,10)
		"voice":params=Vector4(20,100,1,5)
		"military":params=Vector4(10,120,1,5)
	var dz=z-world_listener.y
	var distance=dz if dz>=0 else -dz*back
	var volume=clampf(1.0-(distance-params.x)/(params.y-params.x),0.0,1.0)
	var dx=x-world_listener.x
	var pan=signf(dx)*clampf((absf(dx)-params.z)/(params.w-params.z),0.0,1.0)
	return Vector2(volume,pan)

func begin_world_frame(x:float,z:float):
	world_listener=Vector2(x,z)
	world_requests.clear()

func world_loop(channel:String,key:String,active:bool,x:float,z:float,gain:float=-10.0,profile:String="default",back:float=4.0,category:String=""):
	if not active or silent or not enabled:return
	var mix=spatial_mix(x,z,profile,back)
	if mix.x<=0:return
	if category=="alarm":gain=minf(gain,CAR_ALARM_GAIN_DB)
	world_requests.append({"channel":channel,"key":key,"x":x,"z":z,"gain":gain,"profile":profile,"back":back,"category":category,"mix":mix})

func world_slot(channel:String) -> Dictionary:
	for slot in world_slots:
		if slot.channel==channel:return slot
	for slot in world_slots:
		if String(slot.channel).is_empty():return slot
	return {}

func flush_world_frame(dt:float):
	selected_alarm_channels.clear()
	if silent or not enabled:
		stop_world_audio()
		return
	var alarms: Array[Dictionary] = []
	var selected: Array[Dictionary] = []
	for request in world_requests:
		if request.category=="alarm":alarms.append(request)
		else:selected.append(request)
	# Keep the current alarm in near ties: passing a row of cars cannot chatter/restart every frame.
	alarms.sort_custom(func(a,b):
		var wa=float(a.mix.x);var wb=float(b.mix.x)
		for slot in world_slots:
			if slot.channel==a.channel:wa*=1.12
			if slot.channel==b.channel:wb*=1.12
		return wa>wb)
	for i in range(mini(MAX_CAR_ALARMS,alarms.size())):
		selected.append(alarms[i])
		selected_alarm_channels.append(alarms[i].channel)
	var wanted: Dictionary = {}
	var car_count=0
	for request in selected:
		if request.profile=="car":car_count+=1
	selected.sort_custom(func(a,b):return float(a.mix.x)*db_to_linear(a.gain)>float(b.mix.x)*db_to_linear(b.gain))
	for request in selected:
		var slot=world_slot(request.channel)
		if slot.is_empty():continue
		var p:AudioStreamPlayer=slot.player
		var clip=stream(request.key,true)
		if clip==null:continue
		var mix:Vector2=request.mix
		var target=float(request.gain)+linear_to_db(maxf(0.0001,mix.x))
		if request.profile=="car" and car_count>1:target-=linear_to_db(sqrt(float(car_count)))
		if slot.channel!=request.channel or p.stream!=clip:
			p.stop();p.stream=clip;p.pitch_scale=1;p.volume_db=-70
			slot.channel=request.channel;p.play()
		slot.loop=true;slot.target=target
		slot.pan.pan=mix.y
		p.volume_db=move_toward(p.volume_db,target,dt*180.0)
		wanted[request.channel]=true
	for slot in world_slots:
		var p:AudioStreamPlayer=slot.player
		if String(slot.channel).is_empty():continue
		if bool(slot.loop):
			if not wanted.has(slot.channel):
				p.volume_db=move_toward(p.volume_db,-80,dt*300)
				if p.volume_db<=-70:p.stop();slot.channel=""
		else:
			if not p.playing:slot.channel="";continue
			var actor:Dictionary=slot.get("actor",{})
			if not actor.is_empty() and bool(actor.get("dead",false)):p.stop();slot.channel="";continue
			var x=float(actor.get("x",slot.x));var z=float(actor.get("z",slot.z))
			var mix=spatial_mix(x,z,slot.profile,slot.back)
			p.volume_db=float(slot.gain)+linear_to_db(maxf(0.0001,mix.x))
			slot.pan.pan=mix.y

func play_world(key:String,x:float,z:float,gain:float=-9.0,profile:String="default",back:float=4.0,actor:Dictionary={}):
	if silent or not enabled:return
	var mix=spatial_mix(x,z,profile,back)
	if mix.x<=0:return
	var clip=stream(key)
	if clip==null:return
	var slot=world_slot("")
	if slot.is_empty():return
	world_serial+=1
	var p:AudioStreamPlayer=slot.player
	slot.channel="oneshot_"+str(world_serial);slot.loop=false
	slot.x=x;slot.z=z;slot.gain=gain;slot.profile=profile;slot.back=back;slot.actor=actor
	slot.pan.pan=mix.y
	p.stream=clip;p.pitch_scale=1
	p.volume_db=gain+linear_to_db(maxf(0.0001,mix.x));p.play()

func stop_world_audio():
	world_requests.clear()
	selected_alarm_channels.clear()
	for slot in world_slots:
		slot.player.stop();slot.channel=""

func warm_audio():
	# Retain source clips before the menu; first playback never reads a file.
	for key in clips:
		stream(key)
		if "Loop" in key or "Alarm" in key or "Engine" in key or key in ["CarHorn","BurningEngine","TireBrake","HeavyWind","SideScraping"] or key.begins_with("CarIdle") or key.begins_with("CarMaxSpeed"):stream(key,true)

# RDPlayer.PlayRadioComm and RDEntityWithVoice.PlayVoiceSound use independent
# channels. Gameplay events never wait in the garage dialogue queue.
func begin_gameplay_dialogue():
	clear_voice();gameplay_dialogue=true;gameplay_failed=false

func player_reaction(key:String,priority:int=1,gain:float=-6.0) -> bool:
	if silent or not enabled or action_paused or not clips.has(key):return false
	if gameplay_failed and priority!=3:return false
	if priority in [1,2] and radio.playing:return false
	if voice.playing and priority<=voice_priority:return false
	var sound=stream(key)
	if sound==null:return false
	if not voice_key.is_empty():
		var previous=voice_key
		voice.stop();voice_key="";voice_finished.emit(previous)
	voice_key=key;voice_priority=priority;voice_gap_left=0
	voice.stream=sound;voice_target_db=minf(-6,gain);voice.volume_db=-36;voice.play()
	voice_started.emit(key,"",sound.get_length())
	return true

func play_radio(key:String,priority:int=0,gain:float=-6.0) -> bool:
	if silent or not enabled or action_paused or not clips.has(key):return false
	if gameplay_failed:return false
	if radio.playing and priority<=radio_priority:return false
	var sound=stream(key)
	if sound==null:return false
	clear_radio()
	radio_key=key;radio_priority=priority;radio.stream=sound;radio.volume_db=minf(-6,gain);radio.play()
	radio_started.emit(key,sound.get_length())
	return true

func _radio_completed():
	var previous=radio_key;radio_key="";radio_priority=-1
	radio_finished.emit(previous)

func clear_radio():
	if radio==null:return
	var previous=radio_key
	radio.stop();radio_key="";radio_priority=-1
	if not previous.is_empty():radio_finished.emit(previous)

func gameplay_priority(key:String) -> int:
	if key.begins_with("PlayerDevoured") or key.begins_with("PlayerFatalBullet"):return 3
	if key.begins_with("PlayerFire") or key.begins_with("PlayerBlownTires") or key.begins_with("PlayerGunEmpty") or key.begins_with("PlayerHelicopterReaction") or key.begins_with("PlayerJetReaction"):return 2
	if "Grunt" in key:return 0
	return 1