extends RefCounted

const SAVE_PATH = "user://native_port_save.cfg"
var save_path = SAVE_PATH
var rp = 0
var checkpoint = 0
var hardcore_checkpoint = 0
var upgrades: Array = [0,0,0,0,0,0,0,0]
var best = 0.0
var finished = false
var settings = {"music":true,"sound":true,"fullscreen":false,"fps":60,"shake":true,"volume":1.0,"quality":2,"buildings":true,"keys":[65,68,87,83,32,69,82,70,81,80],"intro_seen":false,"garage_seen":false,"tutorial_index":0,"tutorial_seen":[],"tutorial_encounters":[]}
var achievements:Array=[]
var achievement_totals={"soldiers":0,"splatters":0,"civilians":0,"super_dodges":0,"bomb_dodges":0}
var achievement_hood_types:Array=[]

func _init():
	reset_achievements()

func reset_achievements():
	achievements.clear();achievements.resize(24);achievements.fill(false)
	for key in achievement_totals:achievement_totals[key]=0
	achievement_hood_types.clear()

var ephemeral = false
var last_error = ""

func read_save():
	var cfg=ConfigFile.new()
	if cfg.load(save_path)!=OK:return
	rp=maxi(0,int(cfg.get_value("progress","rp",0)))
	checkpoint=clampi(int(cfg.get_value("progress","checkpoint",0)),0,20)
	checkpoint-=checkpoint%2
	hardcore_checkpoint=clampi(int(cfg.get_value("progress","hardcore_checkpoint",0)),0,20)
	hardcore_checkpoint-=hardcore_checkpoint%2
	best=maxf(0,float(cfg.get_value("progress","best",0)))
	finished=bool(cfg.get_value("progress","finished",false))
	var values=cfg.get_value("progress","upgrades",upgrades)
	if values is Array and values.size()==8:
		for i in range(8): upgrades[i]=clampi(int(values[i]),0,3)
	for key in settings:
		settings[key]=cfg.get_value("settings",key,settings[key])
	reset_achievements()
	var completed=cfg.get_value("achievements","completed",[])
	if completed is Array:
		for i in range(mini(24,completed.size())):achievements[i]=bool(completed[i])
	for key in achievement_totals:achievement_totals[key]=maxi(0,int(cfg.get_value("achievements",key,0)))
	var types=cfg.get_value("achievements","hood_types",[])
	if types is Array:
		for kind in types:
			if kind in ["male","female","hard","super","soldier"] and kind not in achievement_hood_types:achievement_hood_types.append(kind)
	# Older ports already paid 500 RP for an escape. Mark known legacy progress
	# without paying that reward again; no unrecorded gameplay is inferred.
	if not cfg.has_section("achievements"):
		if finished:achievements[0]=true
		if upgrades.all(func(level):return int(level)==3):achievements[4]=true


	if not settings.keys is Array or settings.keys.size()!=10:settings.keys=[65,68,87,83,32,69,82,70,81,80]

	settings.tutorial_index=clampi(int(settings.tutorial_index),0,7)
	if not settings.tutorial_seen is Array:settings.tutorial_seen=[]
	if not settings.tutorial_encounters is Array:settings.tutorial_encounters=[]

func save() -> bool:
	if ephemeral:return true
	var cfg=ConfigFile.new()
	cfg.set_value("progress","rp",rp)
	cfg.set_value("progress","checkpoint",checkpoint)
	cfg.set_value("progress","hardcore_checkpoint",hardcore_checkpoint)
	cfg.set_value("progress","best",best)
	cfg.set_value("progress","finished",finished)
	cfg.set_value("progress","upgrades",upgrades)
	for key in settings:cfg.set_value("settings",key,settings[key])
	cfg.set_value("achievements","completed",achievements)
	for key in achievement_totals:cfg.set_value("achievements",key,achievement_totals[key])
	cfg.set_value("achievements","hood_types",achievement_hood_types)
	var err=cfg.save(save_path+".tmp")
	if err!=OK:
		last_error="Save write failed: "+str(err)
		push_error(last_error)
		return false
	if FileAccess.file_exists(save_path):
		DirAccess.copy_absolute(save_path,save_path+".bak")
	err=DirAccess.rename_absolute(save_path+".tmp",save_path)
	if err!=OK:
		last_error="Save replacement failed: "+str(err)
		push_error(last_error)
		return false
	return true