pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--variables
function _init()
	
	palt(12, true)
	palt(0, false)
	gravity=0.3
	friction=0.7

	poke(0x5f5c,255)
	poke(0x5f5d,255)
   
	player={
		sp=1,
		x=15,
		y=63,
		w=8,
		h=16,
		fx=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=5,
		acc=0.5,
		boost=3.5,
		jmp_counter=2,
		anim=0,
		frame_duration = 1,
		running=false,
		jumping=false,
		falling=false,
		crouching=false,
		landed=false,
		attacking=false
		}

	playerbody={
		sp=17,
		fx=false
		}

	attack={
		sp=30,
		w=0,
		h=0,
		fx=false,
		anim=0,
		frame_duration=0.3
		}

	parts={

		}
		
	blob={
		sp=32,
		x=64,
		y=80,
		fx=false,
		anim=0,
		frame_duration=0.1,
		first_frame=032,
		last_frame=35
		}
		
		froggy={
		sp=48,
		x=80,
		y=80,
		fx=false,
		anim=0,
		frame_duration=0.3,
		first_frame=48,
		last_frame=49
		}
		
		--simple camera
		cam_x=0
		
		--map limits
		map_start=0
		map_end=1024
		
		----------test----------
		x1r=0 y1r=0 x2r=0 y2r=0
		collide_l="no"
		collide_r="no"
		collide_u="no"
		collide_d="no"
		------------------------	   
   end
-->8
--update and draw

function _update()
	player_update()
    player_animate()
	particles_update()
	get_item()
	blob.anim, blob.sp=enemies_animate(blob.anim, blob.frame_duration, blob.sp, blob.last_frame, blob.first_frame)
	froggy.anim, froggy.sp=enemies_animate(froggy.anim, froggy.frame_duration, froggy.sp, froggy.last_frame, froggy.first_frame)

	
	--simple camera
	cam_x=player.x-64+(player.w/2)
	if cam_x<map_start then
		cam_x=map_start	
	end
	if cam_x>map_end-128 then
		cam_x=map_end-128
	end
	camera(cam_x,0)

	end

 function _draw()	
	 cls(12)
	 map(0,0)
	 spr(player.sp, player.x, player.y,1,1,player.fx)
	 spr(playerbody.sp,player.x,(player.y+8),1,1,playerbody.fx)
	 spr(attack.sp, player.x+8, player.y+5, attack.w, attack.h, attack.fx)
	 spr(blob.sp,blob.x,blob.y,1,1,blob.fx)
	 spr(froggy.sp,froggy.x,froggy.y,1,1,froggy.fx)
	 particles_draw()
		
	--[[	print(time())

	if player.jumping then
		print("jumping")
	elseif player.falling then
		print("falling")
	elseif player.running then
		print("running")
	else
		print("idle")
	end

	print(player.attacking)

--------------------test------------------------
	 rect(x1r,y1r,x2r,y2r,7)
	 print("⬅️= "..collide_l,player.x,player.y-10)
	 print("➡️= "..collide_r,player.x,player.y-16)
	 print("⬆️= "..collide_u,player.x,player.y-22)
	 print("⬇️= "..collide_d,player.x,player.y-28)
	 
	 ]]--
	 
 end
 
 
-->8
--collisions

function collide_map(obj,aim,flag)
		--obj = table needs x,y,w,h
		--aim = left, right, up, down
		
		local x=obj.x local y=obj.y
		local w=obj.w local h=obj.h
		
		local x1=0 local y1=0
		local x2=0 local y2=0
		
		if aim =="left" then
			if not player.crouching then
			x1=x-1   y1=y
			x2=x    y2=y+h-1
			else
			x1=x-1   y1=y+8
			x2=x    y2=y+h-1
			end
		elseif aim== "right" then
			if not player.crouching then
			x1=x+w-1   y1=y
			x2=x+w     y2=y+h-1
			else
			x1=x+w-1   y1=y+8
			x2=x+w     y2=y+h-1
			end
		elseif aim=="up" then
			if not player.crouching then
			x1=x+2   y1=y-1
			x2=x+w-3 y2=y
			else
			x1=x+2   y1=y+8
			x2=x+w-3 y2=y+8
		end
		elseif aim=="down" then
		x1=x+2     y1=y+h
		x2=x+w-3   y2=y+h
		
		end

-----test----
x1r=x1 y1r=y1
x2r=x2	y2r=y2
-------------

--pixels to tiles
x1/=8    y1/=8
x2/=8    y2/=8

if fget(mget(x1,y1), flag)
or fget(mget(x1,y2), flag)
or fget(mget(x2,y1), flag)
or fget(mget(x2,y2), flag) then
		return true
	else
	return false
	
	end
	
	end
-->8
--player

function player_update()
	--physics
	player.dy+=gravity
	player.dx*=friction
	
	--controls
	if btn(⬅️) and not btn(⬇️) then
		player.dx-=player.acc
		player.running=true
		player.fx=true
		playerbody.fx=true
	end
	
	if btn(➡️) and not btn(⬇️) then
		player.dx+=player.acc
		player.running=true
		player.fx=false
		playerbody.fx=false	
	end

	if player.running 
	and not btn(⬅️) 
	and not btn(➡️) 
	and not player.falling 
	and not player.jumping then
		player.running=false
	end

	--crouch

	if btn(⬇️) then
		player.crouching=true
		gravity=2
		friction=0.97
	else
		player.crouching=false
		gravity=0.3
		friction=0.7
	end
	
	--jump

	if player.landed then
		player.jmp_counter=2
	end

	if btnp(❎) then
		if player.jmp_counter>0 then
			player.jmp_counter-=1
			player.dy-=player.boost
			player.landed=false
			
			if btn(⬅️) then
				player.dx-=player.acc
			elseif btn(➡️) then
				player.dx+=player.acc
		end
		end
	end

	if btnp(🅾️) and not player.crouching and not player.running and not player.jumping and not player.falling then
		player.attacking=true
		for i=1, 10 do
			add(parts,{
				x=(player.x+12),
				y=(player.y+9),
				sx=rnd(3)-1,
				sy=rnd(3)-1,
			})
		end
	else
		player.attacking=false
		attack.w=0
		attack.h=0
	end
		
	--check collision up and down
	if player.dy>0 then
			player.falling=true
			player.landed=false
			player.jumping=false
			
			player.dy=limit_speed(player.dy, player.max_dy)

			if collide_map(player,"down",0) then
				player.landed=true
				player.falling=false
				player.dy=0
				player.y-=(player.y+player.h)%8

				--------test---------
				collide_d="yes"
			else 
				collide_d="no"
				---------------------
		end
		elseif player.dy<0 then
		player.jumping=true
		if collide_map(player,"up",1) then
				player.dy=0

				--------test---------
				collide_u="yes"
			else 
				collide_u="no"
				---------------------
		end
	end			
	
--check collision left and right
	if	player.dx<0 then

		player.dx=limit_speed(player.dx, player.max_dx)

	if collide_map(player,"left",1) then
			player.dx=0

			--------test---------
			collide_l="yes"
		else 
			collide_l="no"
			---------------------

		end
		elseif player.dx>0 then

		player.dx=limit_speed(player.dx, player.max_dx)

	if collide_map(player,"right",1) then
	player.dx=0

	--------test---------
	collide_r="yes"
else 
	collide_r="no"
	---------------------
	
		end
	end
		player.x+=player.dx
		player.y+=player.dy
	
		--limit player to map
		if player.x<map_start then
			player.x=map_start
		end
		if player.x>map_end-player.w then
			player.x=map_end-player.w
		end
end

function player_animate()
	if player.jumping and not player.crouching then
		if player.jmp_counter == 0 then
		player.sp=12
		playerbody.sp=28
		else
		player.sp=6
		playerbody.sp=22

		end
	
	elseif player.falling and not player.crouching then
		player.sp=10
		playerbody.sp=26

	elseif player.crouching then
		player.sp=11
		playerbody.sp=27
		
	elseif player.running then

		if btn(⬅️) and btn(➡️) then
			player.sp=5
			playerbody.sp=21
		end

		if btnp(⬅️) or btnp(➡️) then
			player.sp=6
			playerbody.sp=22
		end

		if time()-player.anim>.15 then
			player.anim=time()
			playerbody.sp+=1
			player.sp+=1
			if player.sp>8 then
				player.sp=5
				playerbody.sp=21
			end
		end

	elseif player.attacking then
		player.sp=13
		playerbody.sp=29
		attack.w=1
		attack.h=1


	else --player idle
			if player.sp~=1 then
				player.frame_duration=0.3
			else
				player.frame_duration=2
			end

			if time()-player.anim>player.frame_duration then
				player.anim=time()
				player.sp+=1
				playerbody.sp+=1
					if player.sp>4 then
					player.sp=1
					playerbody.sp=17
					end
			end
	end
end

function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)
end
-->8
-- enemies

function enemies_animate(anim, fd, sp, lf, ff) -- Animation, Frame duration, Sprite, Last frame, First frame
	if time()-anim>fd then
		anim=time()
		sp+=1
		if sp>lf then                               
			sp=ff
		end
	end
	return anim, sp
end

-->8
-- items

function get_item()
	cell_value = mget((player.x/8),(player.y/8+1))
	cell_value2= mget((player.x/8+1),(player.y/8+1))
	cell_value3= mget((player.x/8-1),(player.y/8+1))
	cell_value4= mget((player.x/8),(player.y/8))
	cell_value5= mget((player.x/8+1),(player.y/8))
	cell_value6= mget((player.x/8-1),(player.y/8))
	cell_value7= mget((player.x/8),(player.y/8-1))
	cell_value8= mget((player.x/8),(player.y/8+2))

	if collide_map(player, "left", 4)
	or collide_map(player, "right", 4)
	or collide_map(player, "up", 4)
	or collide_map(player, "down", 4)  then
		if cell_value == 70 or cell_value == 71 or cell_value == 72 or cell_value == 73 then
			mset((player.x/8),(player.y/8+1), 69)
			sfx(0)
		elseif cell_value2 == 70 or cell_value2 == 71 or cell_value2 == 72 or cell_value2 == 73 then
			mset((player.x/8+1),(player.y/8+1), 69)
			sfx(0)
		elseif cell_value3 == 70 or cell_value3 == 71 or cell_value3 == 72 or cell_value3 == 73 then
			mset((player.x/8-1),(player.y/8+1), 69)
			sfx(0)
		elseif cell_value4 == 70 or cell_value4 == 71 or cell_value4 == 72 or cell_value4 == 73 then
			mset((player.x/8),(player.y/8), 69)
			sfx(0)
		elseif cell_value5 == 70 or cell_value5 == 71 or cell_value5 == 72 or cell_value5 == 73 then
			mset((player.x/8+1),(player.y/8),69)
			sfx(0)
		elseif cell_value6 == 70 or cell_value6 == 71 or cell_value6 == 72 or cell_value6 == 73 then
			mset((player.x/8-1),(player.y/8),69)
			sfx(0)
		elseif cell_value7 == 70 or cell_value7 == 71 or cell_value7 == 72 or cell_value7 == 73 then
			mset((player.x/8),(player.y/8-1),69)
			sfx(0)
		elseif cell_value8 == 70 or cell_value8 == 71 or cell_value8 == 72 or cell_value8 == 73 then
			mset((player.x/8),(player.y/8+2),69)
			sfx(0)
		end
	end
end
-->8
--particles

function particles_draw()
	for p in all(parts) do
		spr(89,p.x,p.y)
	end
end

function particles_update()
	for p in all(parts) do
		p.x+=p.sx
		p.y+=p.sy

		
		if p.x>(player.x+16) or p.x<(player.x+6) or p.y>(player.y+10) or p.y<(player.y-10) then
			del(parts,p)
		end
	end
end

__gfx__
c0c00c0cc000ccccc000ccccc0ccccccc000ccccc000ccccc00000ccc000ccccc00000ccc000ccccc000ccccccccccccc00000ccc000cccccccccccccccccccc
090aa090022200cc022200cc02000ccc022200cc022200cc0288880c022200cc0288880c022200cc022200cccccccccc0288880c022200cccccccccccccccccc
c090090cc088880cc088880c022220ccc088880cc088880c08899980c088880c08899980c088880cc088880ccccccccc08899980c088880ccccccccccccccccc
0a0cc0a00889998008899980c088880c08899980088999800899999008899980089999900889998008899980c000cccc0899999008899980cccccccccccccccc
0a0cc0a008a9a9a008a9a9a00889a98008a9a9a008a9a9a009a2a2a008a9a9a009a2a2a008a9a9a008a9a9a0022200cc09a2a27008a9a9a0cccccccccccccccc
c090090c099292900992929008a9a9a0099292900992929009e4f4e00992929009e4f4e00992929009929290c088880c09e4f46009929290cccccccccccccccc
090aa09009e4f4e009e4f4e0099f9f9009e4f4e009e4f4e0c09fff0c09e4f4e0c09fff0c09e4f4e009e4f4e008899980c09fff2009e4f4e0cccccccccccccccc
c0c00c0cc09fff0cc09fff0c09e2f2e0c09fff0cc09fff0cc022820cc09fff0cc022820cc09fff0cc09fff0c08a9a9a0c0228220c09fff00cccccccccccccccc
ccccccccc022820cc022820cc09ff770c022820cc022820cc0778260c022820c06288770c022820cc022820c099f9f900628880cc0228222c000cccccccccccc
cc000ccc0228882002288770022287600228877002288820c0768860022888200728876002288820c077826009e2f2e00728880c0228882206760ccccccccccc
c08820cc07688860076887600768820c0768876007688860c049a90c07688860c049a00c07688860c0768860c077f770c049a00c0768880006760ccccccccccc
08a9820c0779a9600779a90c0779a90c0779a90c0779a960028884400779a960c028440c0779a960c049a90c02672760c028440c0779a90c76760ccccccccccc
08aa9820c088880cc088880cc088880cc088880cc088880c05504220c088880cc084220cc088880c028884400829a920c084220cc088880c77770ccccccccccc
c088200cc0240240c0240240c0240240c0240240c0240240c000220cc0240240c04220ccc0240240055042200288880cc04220ccc024024027760ccccccccccc
cc000cccc0440440c0440440c0440440c0440440c0440440cccc00ccc0440440cc000cccc0440440c000220c02442440cc000cccc04404400000cccccccccccc
ccccccccc0000000c0000000c0000000c0000000c0000000ccccccccc0000000ccccccccc0000000cccc00ccc000000cccccccccc0000000cccccccccccccccc
ccccccccccccccccccccccccccccccccc0cccc0ccc0cc0cccccc0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccc0000cc0e0cc0e0c080080cccc080ccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc0000ccccccccccccccccccc0ffff0cc0c00c0cc088880000c080cc088000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c0ffff0ccc0000cccccccccc0e0f0fe0cc0ff0ccc0181e0888080cccc088880ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0e0f0ee0c0ffff0cc00000cc0e1f1ee0cc0ee0cccc0228888880cccc08888990cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
081e18e0081f18e00efffe0c081e18e0c0c00c0ccc0882882880cccc0888a9a0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0eeeeee00eeeeee0081e18e00eeeeee00e0cc0e0c0822880880ccccc0889f290cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c000000cc000000cc000000cc000000cc0cccc0ccc00000c00cccccc0299e4f0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c00cc00cccccccccccc00ccccc0000cccc0000cccc0000ccccccccccc099ff0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
03b00b30c00cc00ccc0660ccc09aa90cc066660cc066660cccccccccc0222200cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0b0bb0b003b00b30c077760009aaaa900677776006777760ccccccccc0822222cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0e1bb1e00b0bb0b0c0767765090aa0900707707007077070ccccccccc0888222cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
083333800e1bb1e007776060081aa1800817718008177180ccccccccc0449a00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c013310c0833338007660c0c049999400677776006777760ccccccccc088880ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0bb11bb00b1331b00660ccccc044440cc060060c06066060ccccccccc0220220cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c000000cc000000cc00ccccccc0000cccc0cc0ccc0c00c0cccccccccc0240240cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
33333333333333333333333333333333ccccccccccc828cccccc00ccc0000000ccccc00cccc00ccccccccccccccccccccccccccccccccccccccccccccccccccc
b88b8aa8bbbbbbbbbbbeaaebcaacbebbcccccccccc88a88ccc00330ccc00b030cccc0fe0cc08800ccccccccccccccccccccccccccccccccccccccccccccccccc
bbb3b88bbbbbb33bbbbbeebbbccbeaebcccccccccc2a9a2cc08240ccc02bb30cccc07620cc082770cccccccccccccccccccccccccccccccccccccccccccccccc
33333bb33bbb33333bbbbb333bbbbeb3cccccccccc88988c08222a0c02988bb0cc0b350cc0777f70cccccccccccccccccccccccccccccccccccccccccccccccc
33343333333334433333333333bbbb33c33cccccccc838cc0889980c08889b0ccc0310cc077ff470cccccccccccccccccccccccccccccccccccccccccccccccc
994443344333994423333394433333343bb3c33ccccc3cbc0888880c0898820cc0400ccc0ff4400ccccccccccccccccccccccccccccccccccccccccccccccccc
24442994422499242244299442333394c33b3b3ccccc3bccc08880cc028820cc040ccccc04400ccccccccccccccccccccccccccccccccccccccccccccccccccc
44442244444442244444224442244994ccc3b3cccccc3ccccc000cccc0000cccc0ccccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444444444444444444444444444c000000ccc0000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
499944444444499449944444444444440efffff0c0effe0ccc0000cccc0000ccc000c00cccc0cccccccccccccccccccccccccccccccccccccccccccccccccccc
4999244444442994299499444444444402efeff00efe77e0c0b33b0cc08ee70c02f70f70cc090ccccccccccccccccccccccccccccccccccccccccccccccccccc
49992444444422442244992444444444022efef00fe777700b33b370c0288e0c02ef2ef0c00a00cccccccccccccccccccccccccccccccccccccccccccccccccc
4422244449944444444442244444444402e2eff00fee77f003b77730c0288e0c02eeeee009aaa90ccccccccccccccccccccccccccccccccccccccccccccccccc
44444994499244444994444444444444022e2ef00efeefe0c03bb30cc082280cc02eee0cc09a90cccccccccccccccccccccccccccccccccccccccccccccccccc
44442994442244444992444444444444022222e0c0effe0ccc0330cccc0000cccc02e0cc09a0a90ccccccccccccccccccccccccccccccccccccccccccccccccc
44442244444444444422444444444444c000000ccc0000ccccc00cccccccccccccc00cccc00c00cccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc000000cccc00cccc000000ccc0000ccccccccccccccccccc9c9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc02888820cc0670cc0c777770c01cc10cccccc000000cccccccacccc9cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc000000cc004400ccc0670cc01c7c77001c17710ccc00aaaaaa00ccccc9009acc0000cccc0000cccccccccccccc0ccccccccc00ccccccccccccccccc
cccccccc02888820c09aa90cc066770c011c7c700c177770cc0aa444444aa0cccc0760cc028880cc088820cccccccccccc010cccc00c0770cccccccccccccccc
c000000cc09aa90ccc0440ccc056670c01c1c7700c1177c0cc0a49999994a0cccc0650cc088880cc088880cccccccccccc0c0ccc09900770cccccccccccccccc
02888820cc0440ccc09aa90c05566770011c1c7001c11c10c0a4999999994a0c9c9009cc08888200288880cccccccccccc0c0ccc09400770cccccccccccccccc
c09aa90cc09aa90cc004400c05556670011111c0c01cc10cc0a499a99a994a0caaccccac08888800888880cccccccccccc0c0cccc00c0770cccccccccccccccc
028888200288882002888820c000000cc000000ccc0000ccc0a49aa99aa94a0ccc9cc9cc08888800888880cccccccccccc0c0ccccccc0770cccccccccccccccc
cccccccc6666ccccccc666ccccccccccc000000ccc0000ccc0a49aa99aa94a0ccc9ccacc08828822882880c0000ccc000c0c000cc00c0770cccccccccccccccc
ccccccc677776ccccc67776c66cccccc09aaaaa0c09aa90cc0a49aa99aa94a0ccaccc99c088088228808800aaaa000bbb00cccc009900770cccccccccccccccc
ccc66c67777776ccc6777776776ccccc049a9aa009a97790c0a49aa99aa94a0c9c900cc908802888820880aaaaaa0bbbbb0ccccc09900770cccccccccccccccc
cc677677777776ccc677776777766ccc0449a9a00a977770c0a49aa99aa94a0ccc0760c908800888800880aa00aa0b303b0c101c09900660cccccccccccccccc
c67777777666776cc6667777777776cc04949aa00a9977a0c0a49aa99aa94a0ccc0650ac08800288200880a0cc0a0b0c000c0c0c0990c00ccccccccccccccccc
c67667676666676c666667766677766c044949a009a99a90c0a49aa99aa94a0ccc9009ac0880c0880c08809a00a903b0bb0c0c0c09900770cccccccccccccccc
6766666666666676666666666666777604444490c09aa90cc0a49aa99aa94a0cccaacccc0280c0220c082009aa90c03bb0010c0104400660cccccccccccccccc
c66666666666666cc66666666666666cc000000ccc0000ccc0a49aa99aa94a0cccc9cc9cc00ccc00ccc00cc0000ccc000cc0ccc0c00cc00ccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
__gff__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010101010000101010100000000000000f0303030100000000000000000000000000000001000000000000000000000000000000010000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000055000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000055540055000000000000000000000000000000000000000000000000000000000000000000000000000000000000000041000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000055000055000000000000000000000000000000000000000000000000000000000000000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000727300000000000000000000000000000000000000000000000000000055005455000000000000000000000000000000000000000000000000000000000000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000055000055000000000000000000000000000000000000000000000000000000000000000000000000000000000041000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007071000000000000000000000000000000000000000000000000000000000000000000000055540055000000000000000000000000000000000000000000000000000000000000000000000000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000047000000000000000049000000000000000000000000000000000000000000000000000055000055000000000000000000000000000000000000000000000000000000000000000000000000000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000006464640000480000005454540000000000505050000000000000000065656565650000000055005455000041410000006565656500005454540000000000005454545400656565650000000000000041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000074747400000000000000000000505050000000000000000000650065000000000055000055000000000000000065006500000000000000000000000000000000006500650000000000004100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006667000000000000505050000000000000000000650065000000000055540055000041410000000065006500000000000000000000000000000000006500650000000000410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4500440000004400004500467677440000000000000000000000000000000000650065000000000055000055000000000000000065006500000000000000000000000000000000006500650000000041000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4142434243424142424142434241424341404341424143414141414141414141414141404140434142414341414141414141414141414140414043414241434141414141414141414141414141414141410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5153505351535053515350535153505351535053515350535153505351535053515350535151535053515350535153505351535153505351535053515350535153505351535053515350535153505351535053515350000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5352535253525352535253525352535253525352535253525352535253525352535253525353525352535253525352535253525352535253525352535253525352535253525352535253525352535253525352535253000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5053515350535153505351535053515350535153505351535053515350535153505351535050535153505351535053515350535053515350535153505351535053515350535153505351535053515350535153505351000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5352535253525352535253525352535253525352535253525352535253525352535253525353525352535253525352535253525352535253525352535253525352535253525352535253525352535253525352535253000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5153505351535053515350535153505351535053515350535153505351535053515350535151535053515350535153505351535153505351535053515350535153505351535053515350535153505351535053515350000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0002000017550145501155011550165501f550045002e500000000050000500005000050001500015000250003500035000450000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000267002670026700247001f7001c7001b7001c7001c700000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01024344

