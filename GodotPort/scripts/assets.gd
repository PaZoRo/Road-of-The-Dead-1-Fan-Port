extends RefCounted

var groups: Dictionary = {}
var pages: Dictionary = {}
var ui_font: Font
var title_font: Font
var road_font: Font
var native: Dictionary = {}

var menu_data: Dictionary = {}
var menu_pages: Array[Texture2D] = []
var menu_font: Font
var garage_font: Font
var anim_data: Dictionary = {}
var anim_pages: Dictionary = {}
var anim_lru: Array = []
var cockpit_width=1280.0
var cockpit_mode=false
var cockpit_pose=Transform2D.IDENTITY
var world_data:Dictionary={}
var world_pages:Dictionary={}
var world_lru:Array=[]
# Upper signs use compact native crops retained outside the evictable world cache.
var highway_data:Dictionary={}
var highway_pages:Dictionary={}
var highway_resident_bytes=0
var resident_data:Dictionary={}
var resident_pages:Dictionary={}
var resident_bytes=0
var car_data:Dictionary={}
var car_pages:Dictionary={}
var driving_loading=false
var driving_tasks:Array=[]
var driving_pending:Dictionary={}
var driving_failed:Array=[]
var driving_total=0
var driving_completed=0
var driving_max_pump_ms=0.0

func _init():
	var world_path="res://assets/world03/world.json"
	if FileAccess.file_exists(world_path):world_data=JSON.parse_string(FileAccess.get_file_as_string(world_path))
	groups = JSON.parse_string(FileAccess.get_file_as_string("res://assets/sprites.json"))
	for key in groups:
		for f in groups[key]:
			var p = int(f.page)
			if not pages.has(p):
				pages[p] = load("res://assets/atlas_%d.png" % p)
	garage_font = load("res://assets/menu/garage.ttf")
	ui_font = load("res://assets/ui.ttf")
	title_font = load("res://assets/title.ttf")
	road_font = load("res://assets/road.ttf")
	for key in [
		"menu_native", "menu_police_hover", "menu_time_hover", "menu_hardcore_hover", "menu_story_hover", "menu_options_hover",
		"garage_native", "garage_bg", "garage_car", "garage_character",
		"cockpit_native", "cockpit_base", "cockpit_shell", "cockpit_wheel", "cockpit_leftarm", "cockpit_rightarm", "cockpit_shiftstick",
		"cockpit_wipers", "cockpit_smoke", "cockpit_fire", "cockpit_leftsidesparks", "cockpit_rightsidesparks",
		"hud_native", "hud_bullets", "results_native", "death_native",
		"hood_clingerzombiehard", "hood_clingerzombienormalmale", "hood_clingerzombienormalfemale",
		"hood_clingerzombieveryhard", "hood_clingersoldier",
		"hood_clingerzombiehardinside", "hood_clingerzombienormalmaleinside",
		"hood_clingerzombienormalfemaleinside", "hood_clingerzombieveryhardinside"
	]:
		var path = "res://assets/original_svg/%s.png" % key
		if ResourceLoader.exists(path): native[key] = load(path)
	var menu_path="res://assets/menu/menu.json"
	if FileAccess.file_exists(menu_path):
		menu_data=JSON.parse_string(FileAccess.get_file_as_string(menu_path))
		for i in range(int(menu_data.get("pages",0))):
			menu_pages.append(load("res://assets/menu/atlas_%d.png" % i))
		if ResourceLoader.exists("res://assets/menu/tooltip.ttf"):
			menu_font=load("res://assets/menu/tooltip.ttf")
	var anim_path="res://assets/flashanim/anim.json"
	if FileAccess.file_exists(anim_path):
		anim_data=JSON.parse_string(FileAccess.get_file_as_string(anim_path))
	var highway_path="res://assets/highway33/signs.json"
	if FileAccess.file_exists(highway_path):highway_data=JSON.parse_string(FileAccess.get_file_as_string(highway_path))
	var resident_path="res://assets/resident34/frames.json"
	if FileAccess.file_exists(resident_path):resident_data=JSON.parse_string(FileAccess.get_file_as_string(resident_path))
	car_data=JSON.parse_string(FileAccess.get_file_as_string("res://assets/car35/frames.json"))
	prepare_garage()


func native_texture(key: String) -> Texture2D:
	return native.get(key, null)

func anim_count(key: String) -> int:
	if anim_data.is_empty(): return 0
	return anim_data.get("groups",{}).get(key,[]).size()

func anim_record(key: String,n: int=0) -> Dictionary:
	var car:Array=car_data.get("groups",{}).get(key,[])
	if not car.is_empty():return car[posmod(n,car.size())]
	var retained:Array=resident_data.get("anim",{}).get(key,[])
	if not retained.is_empty():return retained[posmod(n,retained.size())]
	if anim_data.is_empty(): return {}
	var list:Array=anim_data.get("groups",{}).get(key,[])
	if list.is_empty(): return {}
	return list[posmod(n,list.size())]

func draw_anim(canvas:CanvasItem,key:String,n:int=0,extra:Vector2=Vector2.ZERO,color:Color=Color.WHITE):
	var rec=ready_anim_record(key,n)
	if rec.is_empty(): return
	var page=int(rec.page)
	if page<0:return
	var texture=anim_texture(page)
	if texture==null:return
	var src=Rect2(rec.rect[0],rec.rect[1],rec.rect[2],rec.rect[3])
	var pos=Vector2(rec.offset[0],rec.offset[1])+extra
	if cockpit_mode:cockpit_region(canvas,texture,Rect2(pos,src.size*float(rec.get("scale",1.0))),src,color)
	else:canvas.draw_texture_rect_region(texture,Rect2(pos,src.size*float(rec.get("scale",1.0))),src,color)

func draw_native(canvas: CanvasItem, key: String, rect: Rect2, color: Color = Color.WHITE):
	var tex: Texture2D = native_texture(key)
	if tex != null:
		if cockpit_mode:cockpit_region(canvas,tex,rect,Rect2(Vector2.ZERO,tex.get_size()),color)
		else:canvas.draw_texture_rect(tex, rect, false, color)

func count(key: String) -> int:
	return groups.get(key, []).size()

func frame(key: String, n: int = 0) -> Dictionary:
	var list: Array = groups.get(key, [])
	if list.is_empty():
		return {}
	return list[posmod(n, list.size())]

func draw(canvas: CanvasItem, key: String, n: int, pos: Vector2, scale: Vector2 = Vector2.ONE, color: Color = Color.WHITE):
	var f = frame(key,n)
	if f.is_empty(): return
	var rect = Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3])
	var off = Vector2(f.offset[0],f.offset[1])
	canvas.draw_texture_rect_region(pages[int(f.page)],Rect2(pos+off*scale,rect.size*scale),rect,color)

func fit(canvas: CanvasItem, key: String, n: int, rect: Rect2, color: Color = Color.WHITE):
	var f = frame(key,n)
	if f.is_empty(): return
	canvas.draw_texture_rect_region(pages[int(f.page)],rect,Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3]),color)

func menu_count(key: String) -> int:
	if menu_data.is_empty(): return 0
	return menu_data.get("groups",{}).get(key,[]).size()

func menu_record(key: String, n: int=0) -> Dictionary:
	if menu_data.is_empty(): return {}
	var list: Array=menu_data.get("groups",{}).get(key,[])
	if list.is_empty(): return {}
	return list[posmod(n,list.size())]

func draw_menu(canvas: CanvasItem,key:String,n:int=0,extra:Vector2=Vector2.ZERO,color:Color=Color.WHITE):
	var f=menu_record(key,n)
	if f.is_empty(): return
	var page=int(f.page)
	if page<0 or page>=menu_pages.size(): return
	var src=Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3])
	var pos=Vector2(f.offset[0],f.offset[1])+extra
	canvas.draw_texture_rect_region(menu_pages[page],Rect2(pos,src.size),src,color)

func draw_menu_affine(canvas:CanvasItem,key:String,m:Array,n:int=0,color:Color=Color.WHITE):
	var f=menu_record(key,n)
	if f.is_empty() or m.size()<6:return
	var page=int(f.page)
	if page<0 or page>=menu_pages.size():return
	var src=Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3])
	var local_pos=Vector2(f.offset[0],f.offset[1])
	var tr=Transform2D(Vector2(float(m[0]),float(m[1])),Vector2(float(m[2]),float(m[3])),Vector2(float(m[4])*1.8,float(m[5])*1.8))
	canvas.draw_set_transform_matrix(Transform2D(0,Vector2((cockpit_width-1080)*0.5,0))*tr)
	canvas.draw_texture_rect_region(menu_pages[page],Rect2(local_pos,src.size),src,color)
	canvas.draw_set_transform_matrix(Transform2D(0,Vector2((cockpit_width-1080)*0.5,0)))

func anim_texture(page: int) -> Texture2D:
	if car_pages.has(page):return car_pages[page]
	if resident_pages.has(page):return resident_pages[page]
	if not anim_pages.has(page):request_texture("anim",page);return null
	anim_lru.erase(page);anim_lru.append(page)
	return anim_pages[page]

func cockpit_map(v:Vector2) -> Vector2:
	# RDEntity.Render/RDCamera: one uniform scale, centered in the live viewport.
	var layout:Dictionary=anim_data.cockpit14
	var stage:Array=layout.stage_transform
	var origin=Vector2(stage[4],stage[5])*1.8
	return Vector2(cockpit_width*0.5,float(layout.original_camera_y)*1.8)+(v-origin)*float(layout.original_camera_scale)

func cockpit_region(canvas:CanvasItem,texture:Texture2D,dest:Rect2,src:Rect2,color:Color):
	var vertices=PackedVector2Array()
	var uvs=PackedVector2Array()
	for c in [Vector2.ZERO,Vector2(1,0),Vector2.ONE,Vector2(0,1)]:
		vertices.append(cockpit_pose*cockpit_map(dest.position+c*dest.size))
		uvs.append((src.position+c*src.size)/texture.get_size())
	canvas.draw_polygon(vertices,PackedColorArray([color]),uvs,texture)

func world_frame(key:String,n:int) -> Dictionary:
	var retained:Array=resident_data.get("world",{}).get(key,[])
	if not retained.is_empty():return retained[posmod(n,retained.size())]
	var resident:Array=highway_data.get("groups",{}).get(key,[])
	if not resident.is_empty():return resident[posmod(n,resident.size())]
	var records:Array=world_data.get("groups",{}).get(key,[])
	if records.is_empty():return frame(key,n)
	return records[posmod(n,records.size())]

func world_texture(key:String,page:int) -> Texture2D:
	if resident_data.get("world",{}).has(key):return resident_pages.get(page,null)
	if highway_data.get("groups",{}).has(key):return highway_pages.get(page,null)
	if not world_data.get("groups",{}).has(key):return pages.get(page,null)
	if not world_pages.has(page):request_texture("world",page);return null
	world_lru.erase(page);world_lru.append(page)
	return world_pages[page]

func draw_menu_in_rect(canvas: CanvasItem, key: String, n: int, destination: Rect2):
	var f=menu_record(key,n)
	if f.is_empty():return
	canvas.draw_texture_rect_region(menu_pages[int(f.page)],destination,Rect2(f.rect[0],f.rect[1],f.rect[2],f.rect[3]))

# Disk reads and image decoding run on workers. Painting only uses ready textures.
const TEXTURE_BUDGET_BYTES=768*1024*1024
const ANIM_BUDGET_BYTES=1024*1024*1024
var texture_queue:Array=[]
var texture_queued:Dictionary={}
var texture_pending:Dictionary={}
var texture_failed:Dictionary={}
var retired_textures:Array=[]
var texture_bytes={"anim":0,"world":0}
var texture_cost:Dictionary={}
var texture_pinned:Dictionary={}
var prepared_driving=false
var last_anim_pose:Dictionary={}
var last_world_pose:Dictionary={}
var prefetch_marks:Dictionary={}
var perf_texture_misses=0
var perf_sync_paint_loads=0
var perf_load_events:Array=[]

func request_texture(bank:String,page:int):
	var cache:Dictionary=anim_pages if bank=="anim" else world_pages
	if cache.has(page):
		var lru:Array=anim_lru if bank=="anim" else world_lru
		lru.erase(page);lru.append(page);return
	var id=bank+":"+str(page)
	if texture_queued.has(id) or texture_pending.has(id) or texture_failed.has(id):return
	texture_queued[id]=true;texture_queue.append({"id":id,"bank":bank,"page":page})

func store_texture(bank:String,page:int,texture:Texture2D):
	var cache:Dictionary=anim_pages if bank=="anim" else world_pages
	var lru:Array=anim_lru if bank=="anim" else world_lru
	var cost=texture.get_width()*texture.get_height()*4
	var id=bank+":"+str(page)
	texture_bytes[bank]=int(texture_bytes[bank])-int(texture_cost.get(id,0))
	cache[page]=texture;texture_cost[id]=cost
	texture_bytes[bank]=int(texture_bytes[bank])+cost
	lru.erase(page);lru.append(page)
	while int(texture_bytes[bank])>(ANIM_BUDGET_BYTES if bank=="anim" else TEXTURE_BUDGET_BYTES) and lru.size()>1:
		var old=-1
		for candidate in lru:
			if not texture_pinned.has(bank+":"+str(candidate)) and int(candidate)!=page:old=int(candidate);break
		if old<0:break
		lru.erase(old)
		texture_bytes[bank]=int(texture_bytes[bank])-int(texture_cost[bank+":"+str(old)])
		# Canvas commands retain texture RIDs through the rendered frame.
		retired_textures.append({"texture":cache[old],"until":Engine.get_process_frames()+3})
		cache.erase(old);texture_cost.erase(bank+":"+str(old))

func pump_textures():
	retired_textures=retired_textures.filter(func(row):return Engine.get_process_frames()<int(row.until))
	for id in texture_pending.keys():
		var task:Dictionary=texture_pending[id]
		var status=ResourceLoader.load_threaded_get_status(task.path)
		if status==ResourceLoader.THREAD_LOAD_LOADED:
			var start=Time.get_ticks_usec()
			var texture:Texture2D=ResourceLoader.load_threaded_get(task.path)
			store_texture(task.bank,int(task.page),texture)
			perf_texture_misses+=1
			if perf_load_events.size()<400:perf_load_events.append({"path":task.path,"ms":float(Time.get_ticks_usec()-start)/1000.0,"async":true})
			texture_pending.erase(id)
			break # Publish at most one GPU texture per frame.
		elif status==ResourceLoader.THREAD_LOAD_FAILED:
			texture_failed[id]=true;texture_pending.erase(id)
	while texture_pending.size()<2 and not texture_queue.is_empty():
		var task:Dictionary=texture_queue.pop_front()
		texture_queued.erase(task.id)
		var cache:Dictionary=anim_pages if task.bank=="anim" else world_pages
		if cache.has(int(task.page)):continue
		task.path="res://assets/"+("flashanim" if task.bank=="anim" else "world03")+"/atlas_%d.png"%int(task.page)
		if ResourceLoader.load_threaded_request(task.path,"Texture2D",false)==OK:texture_pending[task.id]=task
		else:texture_failed[task.id]=true

func prefetch_records(bank:String,key:String,records:Array,n:int,all_frames:bool=false):
	if resident_data.get(bank,{}).has(key):return
	if records.is_empty():return
	var mark=bank+":"+key+":"+str(int(n/15))+(":all" if all_frames else "")
	if all_frames and prefetch_marks.has(mark) and Time.get_ticks_msec()-int(prefetch_marks[mark])<600:return
	prefetch_marks[mark]=Time.get_ticks_msec()
	if prefetch_marks.size()>1000:prefetch_marks.clear()
	if all_frames:
		for rec in records:request_texture(bank,int(rec.page))
	else:
		for ahead in [0,15,30,45,60,90]:request_texture(bank,int(records[posmod(n+ahead,records.size())].page))

func ready_anim_record(key:String,n:int) -> Dictionary:
	if car_data.get("groups",{}).has(key):
		var car=anim_record(key,n)
		return car if car_pages.has(int(car.page)) else {}
	if resident_data.get("anim",{}).has(key):
		var pose=anim_record(key,n)
		return pose if resident_pages.has(int(pose.page)) else {}
	var rows:Array=anim_data.get("groups",{}).get(key,[])
	if rows.is_empty():return {}
	prefetch_records("anim",key,rows,n)
	var rec:Dictionary=rows[posmod(n,rows.size())]
	request_texture("anim",int(rec.page))
	if anim_pages.has(int(rec.page)):last_anim_pose[key]=rec;return rec
	# Upgrade selectors are discrete states; another cached frame is never a valid substitute.
	if key.begins_with("garage_") or key.begins_with("clinger"):return {}
	if last_anim_pose.has(key) and anim_pages.has(int(last_anim_pose[key].page)):return last_anim_pose[key]
	for row in rows:
		if anim_pages.has(int(row.page)):return row
	return {}

func ready_world_record(key:String,n:int) -> Dictionary:
	if resident_data.get("world",{}).has(key):
		var pose=world_frame(key,n)
		return pose if resident_pages.has(int(pose.page)) else {}
	if highway_data.get("groups",{}).has(key):
		var pose=world_frame(key,n)
		return pose if highway_pages.has(int(pose.page)) else {}
	var rows:Array=world_data.get("groups",{}).get(key,[])
	if rows.is_empty():return frame(key,n)
	prefetch_records("world",key,rows,n)
	var rec:Dictionary=rows[posmod(n,rows.size())]
	request_texture("world",int(rec.page))
	if world_pages.has(int(rec.page)):last_world_pose[key]=rec;return rec
	if key in ["cone","barrel","box","construction_sign","electronic_sign","fence","shopping_cart","water","feeders"]:return {}
	if last_world_pose.has(key) and world_pages.has(int(last_world_pose[key].page)):return last_world_pose[key]
	for row in rows:
		if world_pages.has(int(row.page)):return row
	return {}

func prepare_driving():
	if prepared_driving:return
	prepare_highway_signs()
	prepare_resident()
	for i in range(car_data.get("textures",[]).size()):
		if not car_pages.has(200000+i):car_pages[200000+i]=load("res://assets/car35/"+String(car_data.textures[i].file))
	var required={"anim":{},"world":{}}
	for key in ["bumper","windshield","car_base14","car_wheel14","speedometer14","leftarm","rightarm","wipers","shiftstick","km_base14","km_needle14","km_checkpoint14"]:
		if not resident_data.get("anim",{}).has(key):
			for rec in anim_data.get("groups",{}).get(key,[]):required.anim[int(rec.page)]=true
	for key in ["clingerzombienormalmale","clingerzombienormalfemale","clingerzombiehard","clingerzombieveryhard","clingersoldier"]:
		var rows:Array=anim_data.get("groups",{}).get(key,[])
		if not rows.is_empty() and not resident_data.get("anim",{}).has(key):required.anim[int(rows[0].page)]=true
	for key in ["buildings","vehicle","feeders_idle26","cone","barrel","box","construction_sign","electronic_sign","fence","shopping_cart","water","feeders"]:
		if not resident_data.get("world",{}).has(key):
			for rec in world_data.get("groups",{}).get(key,[]):required.world[int(rec.page)]=true
	# This warm-up occurs before the run, never from _draw or a collision.
	for bank in required:
		for page in required[bank]:
			var path="res://assets/"+("flashanim" if bank=="anim" else "world03")+"/atlas_%d.png"%int(page)
			texture_pinned[bank+":"+str(page)]=true
			if not (anim_pages if bank=="anim" else world_pages).has(int(page)):store_texture(bank,int(page),load(path))

	prepared_driving=true;driving_loading=false

func prefetch_actor(kind:String,variant:String="",frame:int=0):
	for key in [kind,kind+"_WalkFront",kind+"_WalkSide","civilian_"+variant,"feeders_idle26" if kind=="feeders" else ""]:
		var rows:Array=world_data.get("groups",{}).get(key,[])
		# Run-through animations are short; request every page before the car reaches them.
		var all_hit_frames=key==kind and kind in ["cone","barrel","box","construction_sign","electronic_sign","fence","shopping_cart","water","feeders"]
		prefetch_records("world",key,rows,frame,all_hit_frames)

func prefetch_clinger(key:String):
	prefetch_records("anim",key,anim_data.get("groups",{}).get(key,[]),0,true)

func prepare_garage():
	# Warm exact stock/upgrade layers before the first garage paint and retain them.
	var required:Dictionary={}
	for key in ["garage_carbase","garage_bumper","garage_wheel"]:
		for rec in anim_data.get("groups",{}).get(key,[]):required[int(rec.page)]=true
	for page in required:
		texture_pinned["anim:"+str(page)]=true
		if not anim_pages.has(page):store_texture("anim",page,load("res://assets/flashanim/atlas_%d.png"%page))

func prepare_highway_signs():
	for page in range(highway_data.get("textures",[]).size()):
		if highway_pages.has(page):continue
		var rec:Dictionary=highway_data.textures[page]
		var texture:Texture2D=load("res://assets/highway33/"+String(rec.file))
		if texture!=null:
			highway_pages[page]=texture
			highway_resident_bytes+=texture.get_width()*texture.get_height()*4

func prepare_resident():
	for page in range(resident_data.get("textures",[]).size()):
		if resident_pages.has(100000+page):continue
		var rec:Dictionary=resident_data.textures[page]
		var tex:Texture2D=load("res://assets/resident34/"+String(rec.file))
		if tex!=null:
			resident_pages[100000+page]=tex
			resident_bytes+=tex.get_width()*tex.get_height()*4

# Cold garage transitions use worker reads, with a bounded handoff each frame.
# The immutable native frame bank stays resident after preparation.
func begin_driving_prepare():
	if prepared_driving or driving_loading:return
	driving_loading=true;driving_failed.clear();driving_tasks.clear();driving_pending.clear();driving_completed=0
	for bank in ["resident","highway","car"]:
		var data:Dictionary=resident_data if bank=="resident" else (highway_data if bank=="highway" else car_data)
		var cache:Dictionary=resident_pages if bank=="resident" else (highway_pages if bank=="highway" else car_pages)
		var prefix=100000 if bank=="resident" else (200000 if bank=="car" else 0)
		var folder="resident34" if bank=="resident" else ("highway33" if bank=="highway" else "car35")
		for i in range(data.get("textures",[]).size()):
			if not cache.has(prefix+i):driving_tasks.append({"bank":bank,"page":prefix+i,"path":"res://assets/"+folder+"/"+String(data.textures[i].file)})
	var required:Dictionary={}
	for key in ["clingerzombienormalmale","clingerzombienormalfemale","clingerzombiehard","clingerzombieveryhard","clingersoldier"]:
		var rows:Array=anim_data.get("groups",{}).get(key,[])
		if not rows.is_empty():required[int(rows[0].page)]=true
	for page in required:
		texture_pinned["anim:"+str(page)]=true
		if not anim_pages.has(page):driving_tasks.append({"bank":"anim","page":page,"path":"res://assets/flashanim/atlas_%d.png"%page})
	driving_total=driving_tasks.size()

func driving_fraction() -> float:
	return 1.0 if prepared_driving else float(driving_completed)/maxi(1,driving_total)

func pump_driving_prepare():
	if not driving_loading:return
	var start=Time.get_ticks_usec()
	var published=0
	for path in driving_pending.keys():
		var task:Dictionary=driving_pending[path]
		var status=ResourceLoader.load_threaded_get_status(path)
		if status==ResourceLoader.THREAD_LOAD_LOADED:
			var texture:Texture2D=ResourceLoader.load_threaded_get(path)
			if texture==null:driving_failed.append(path)
			elif task.bank=="resident":resident_pages[int(task.page)]=texture;resident_bytes+=texture.get_width()*texture.get_height()*4
			elif task.bank=="highway":highway_pages[int(task.page)]=texture;highway_resident_bytes+=texture.get_width()*texture.get_height()*4
			elif task.bank=="car":car_pages[int(task.page)]=texture
			else:store_texture(task.bank,int(task.page),texture)
			driving_pending.erase(path);driving_completed+=1;published+=1
		elif status in [ResourceLoader.THREAD_LOAD_FAILED,ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:
			driving_failed.append(path);driving_pending.erase(path);driving_completed+=1
		if published>=16 or Time.get_ticks_usec()-start>=4000:break
	while driving_pending.size()<8 and not driving_tasks.is_empty() and Time.get_ticks_usec()-start<4000:
		var task:Dictionary=driving_tasks.pop_front()
		if ResourceLoader.load_threaded_request(task.path,"Texture2D",false)==OK:driving_pending[task.path]=task
		else:driving_failed.append(task.path);driving_completed+=1
	driving_max_pump_ms=maxf(driving_max_pump_ms,float(Time.get_ticks_usec()-start)/1000.0)
	if driving_tasks.is_empty() and driving_pending.is_empty():
		driving_loading=false;prepared_driving=driving_failed.is_empty()
