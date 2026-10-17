extends RefCounted

# Names, hints, RP and categories are extracted from the original RDAchievement.
var data:Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/achievements364/achievements.json"))
var pending:Array[int]=[]
var slow_kills=0
var zombie_combo=0
var zombie_time=-9999.0
var flip_count=0
var flip_kind=""
var car_combo=0
var car_time=-9999.0
var speed_start=-1.0
var tires_start=-1.0

func reset_run():
	slow_kills=0;zombie_combo=0;zombie_time=-9999.0;flip_count=0;flip_kind=""
	car_combo=0;car_time=-9999.0;speed_start=-1.0;tires_start=-1.0

func unlock(progress,id:int) -> bool:
	if id<0 or id>=24 or bool(progress.achievements[id]):return false
	progress.achievements[id]=true
	progress.rp+=int(data.rows[id].reward)
	pending.append(id)
	return true

func threshold(progress,key:String,target:int,id:int):
	if int(progress.achievement_totals[key])>=target:unlock(progress,id)

func road_hit(progress,kind:String,hit:String,clock:float):
	if kind=="civilian":
		progress.achievement_totals.civilians+=1;threshold(progress,"civilians",25,20)
		zombie_combo=0;zombie_time=-9999.0;flip_count=0;flip_kind=""
		return
	var group="soldier" if kind=="soldier" else "zombie"
	# The source combo counters start at zero on the first hit.
	flip_count=flip_count+1 if flip_kind!="" and flip_kind!=group else 0
	flip_kind=group
	if flip_count>=16:unlock(progress,10)
	if group=="soldier":
		progress.achievement_totals.soldiers+=1;threshold(progress,"soldiers",50,18)
		zombie_combo=0;zombie_time=-9999.0
	else:
		if hit=="GibHit":
			progress.achievement_totals.splatters+=1;threshold(progress,"splatters",30,19)
		elif hit=="SlowRollOverHit":
			slow_kills+=1
			if slow_kills>=10:unlock(progress,11)
		zombie_combo=zombie_combo+1 if clock-zombie_time<2.0 else 0
		zombie_time=clock
		if zombie_combo>=4:unlock(progress,9)

func hood_removed(progress,kind:String,gun:bool,wall:bool,gun_out:bool):
	if gun:unlock(progress,6)
	elif wall:unlock(progress,5)
	if gun and kind=="soldier":
		progress.achievement_totals.soldiers+=1;threshold(progress,"soldiers",50,18)
		if gun_out:unlock(progress,12)
	if kind not in progress.achievement_hood_types:progress.achievement_hood_types.append(kind)
	if progress.achievement_hood_types.size()==5:unlock(progress,21)

func car_hit(progress,clock:float):
	car_combo=car_combo+1 if clock-car_time<0.5 else 0
	car_time=clock
	if car_combo>=3:unlock(progress,15)

func super_dodged(progress):
	progress.achievement_totals.super_dodges+=1;threshold(progress,"super_dodges",10,22)

func bombing_dodged(progress):
	progress.achievement_totals.bomb_dodges+=1;threshold(progress,"bomb_dodges",10,23)

func check_upgrades(progress):
	if progress.upgrades.all(func(level):return int(level)==3):unlock(progress,4)

func update_distance(progress,mode:String,z:float,max_speed:bool,all_tires:bool,time_left:float):
	if mode=="time":
		if z>=10000:unlock(progress,2)
		if time_left>=45:unlock(progress,17)
	elif mode=="police" and z>=10000:unlock(progress,3)
	if max_speed:
		if speed_start<0:speed_start=z
		if z-speed_start>=500:unlock(progress,13)
	else:speed_start=-1.0
	if all_tires:
		if tires_start<0:tires_start=z
		if z-tires_start>=3000:unlock(progress,14)
	else:tires_start=-1.0

func escaped(progress,mode:String,nuke_time:float):
	if mode not in ["story","hardcore"]:return
	if nuke_time>=15:unlock(progress,16)
	unlock(progress,1 if mode=="hardcore" else 0)
