extends RefCounted

# RDPlayer.as: engine time is the position in the authored engine sound,
# scaled by the upgrade. Keep that clock independent of muted audio output.
const IDLE=0
const ACCEL=1
const MAX_SPEED=2
const COAST=3
const BRAKE=4
const HAND_BRAKE=5
const ACCEL_TIMES=[0.0,3.27,6.1,11.6,24.0]
const COAST_TIMES=[20.485,16.55,14.3,9.3,0.0]
const BRAKE_TIMES=[4.002,3.2,2.25,0.92,0.0]
const SCALES=[1.0,1.15535,1.33484,1.54221]
const MAX_SPEEDS=[110.0,115.0,120.0,125.0]
const RATIOS=[[0.0,.4,.7,.9,1.0],[0.0,.46,.74,.92,1.0],[0.0,.52,.78,.94,1.0],[0.0,.58,.82,.96,1.0]]
const VISUAL=[[0.0,.175,.35,.525,.7],[0.0,.24,.452,.64,.8],[0.0,.315,.5715,.765,.9],[0.0,.4,.7,.9,1.0]]
var level=0
var state=IDLE
var clock=0.0
var source_gear=0
var gear_ratio=0.0
var speed=0.0
var revision=0

func reset(upgrade:int):
	level=clampi(upgrade,0,3);state=IDLE;clock=0;source_gear=0;gear_ratio=0;speed=0;revision+=1

func times(kind:int) -> Array:
	return ACCEL_TIMES if kind in [ACCEL,MAX_SPEED] else (BRAKE_TIMES if kind==BRAKE else COAST_TIMES)

func seek_speed(value:float):
	var ratio=clampf(value/MAX_SPEEDS[level],0.0,1.0)
	var rows:Array=RATIOS[level]
	for g in range(4):
		if ratio<=float(rows[g+1]):
			source_gear=g;gear_ratio=(ratio-float(rows[g]))/(float(rows[g+1])-float(rows[g]));break
	if ratio<=0:state=IDLE;clock=0
	else:
		if state in [IDLE,MAX_SPEED]:state=ACCEL
		var table=times(state)
		clock=lerpf(float(table[source_gear]),float(table[source_gear+1]),gear_ratio)
	speed=ratio*MAX_SPEEDS[level];revision+=1

func update(dt:float,throttle:float,brake:bool,handbrake:bool,on_stick:bool=true):
	if not on_stick:return
	var next=IDLE
	if handbrake and speed>0:next=HAND_BRAKE
	elif throttle>0 and not handbrake:next=MAX_SPEED if speed>=MAX_SPEEDS[level] else ACCEL
	elif brake and speed>0:next=BRAKE
	elif speed>0:next=COAST
	if next!=state:
		state=next
		if state not in [IDLE,MAX_SPEED]:
			var table=times(state)
			clock=lerpf(float(table[source_gear]),float(table[source_gear+1]),gear_ratio)
	else:
		clock+=dt*float(SCALES[level])
	resolve()

func resolve():
	if state==IDLE:gear_ratio=0;speed=0;return
	if state==MAX_SPEED:source_gear=3;gear_ratio=1;speed=MAX_SPEEDS[level];return
	var table=times(state)
	clock=clampf(clock,0.0,24.0 if state==ACCEL else float(table[0]))
	for g in range(4):
		if (clock<=float(table[g+1]) if state==ACCEL else clock>=float(table[g+1])):
			source_gear=g
			gear_ratio=(clock-float(table[g]))/(float(table[g+1])-float(table[g]))
			break
	speed=lerpf(float(RATIOS[level][source_gear]),float(RATIOS[level][source_gear+1]),gear_ratio)*MAX_SPEEDS[level]

func visual_frame() -> int:
	if state==IDLE:return 0
	return roundi(100.0*lerpf(float(VISUAL[level][source_gear]),float(VISUAL[level][source_gear+1]),gear_ratio))

func hit_speed_loss(loss:float,bumper_factor:float):
	if state==ACCEL:clock=maxf(0.0,clock-loss*bumper_factor*clock)
	elif state==MAX_SPEED:
		state=ACCEL;clock=24.0/float(SCALES[level]);clock=maxf(0.0,clock-loss*bumper_factor*clock)
	elif state in [COAST,HAND_BRAKE]:clock=minf(20.485,clock+loss*bumper_factor*(20.485-clock))
	elif state==BRAKE:clock=minf(4.002,clock+loss*bumper_factor*(4.002-clock))
	resolve();revision+=1
