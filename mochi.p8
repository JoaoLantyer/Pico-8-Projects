pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--variables
function _init()
	
	palt(12, true) 
	palt(0, false)
	gravity=0.3
	friction=0.7
	seconds=0

	poke(0x5f5c,255)
	poke(0x5f5d,255)
   
	player={
		sp=017,
		x=15,
		y=63,
		w=8,
		h=8,
		fx=false,
		dx=0,
		dy=0,
		max_dx=1.5,
		max_dy=3,
		acc=0.5,
		boost=4,
		anim=0,
		frame_duration = 1,
		running=false,
		jumping=false,
		falling=false,
		crouching=false,
		landed=false
		}

	playerhead={
		sp=1,
		x=player.x,
		y=(player.y-8),
		fx=false
		}
		
	enemyblob={
		sp=032,
		x=64,
		y=80,
		fx=false,
		anim=0,
		first_frame=032,
		last_frame=35
		}
			   
   end
-->8
--update and draw

function _update()
	player_update()
    player_animate()
	enemies_animate()

	end
   
 function _draw()	
	 cls(12)
	 map(0,0)
	 spr(player.sp, player.x, player.y,1,1,player.fx)
	 spr(playerhead.sp,player.x,(player.y-8),1,1,playerhead.fx)
		spr(enemyblob.sp,enemyblob.x,enemyblob.y,1,1,enemyblob.fx)

		print(time())

	if player.jumping then
		print("jumping")
	elseif player.falling then
		print("falling")
	elseif player.running then
		print("running")
	else
		print("idle")
	end
	
	if btnp(➡️) then
		print("btnp ➡️")
	end
	
	if btnp(⬅️) then
		print("btnp ⬅️")
	end

	 print(player.dy)
	 print(player.dx)
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
		x1=x-1   y1=y
		x2=x    y2=y+h-1
		elseif aim== "right" then
		x1=x+w-1   y1=y
		x2=x+w     y2=y+h-1
		elseif aim=="up" then
		x1=x+2   y1=y-1
		x2=x+w-3 y2=y
		elseif aim=="down" then
		x1=x+2     y1=y+h
		x2=x+w-3   y2=y+h
		
		end


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
			playerhead.fx=true
	end
	
	if btn(➡️) and not btn(⬇️) then
			player.dx+=player.acc
			player.running=true
			player.fx=false
			playerhead.fx=false	
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
		gravity=1
		friction=0.95
	else
		player.crouching=false
		gravity=0.3
		friction=0.7
	end
	
	--jump
	if btnp(❎) and player.landed then
			player.dy-=player.boost
			player.landed=false
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
		end
		elseif player.dy<0 then
		player.jumping=true
		if collide_map(player,"up",1) then
				player.dy=0
		end
	end			
	
--check collision left and right
	if	player.dx<0 then

		player.dx=limit_speed(player.dx, player.max_dx)

	if collide_map(player,"left",1) then
			player.dx=0
		end
		elseif player.dx>0 then

		player.dx=limit_speed(player.dx, player.max_dx)

	if collide_map(player,"right",1) then
	player.dx=0
		end
	end
		player.x+=player.dx
		player.y+=player.dy
	
end

function player_animate()
	if player.jumping and not player.crouching then
		playerhead.sp=6
		player.sp=22
	
	elseif player.falling and not player.crouching then
		playerhead.sp=10
		player.sp=26

	elseif player.crouching then
		playerhead.sp=11
		player.sp=27
		
	elseif player.running then

		if btnp(⬅️) or btnp(➡️) then
			playerhead.sp=6
			player.sp=22
		end

		if time()-player.anim>.15 then
			player.anim=time()
			playerhead.sp+=1
			player.sp+=1
			if player.sp>24 then
				playerhead.sp=5
				player.sp=21
			end
		end
	else --player idle
			if player.sp~=17 then
				player.frame_duration=0.3
			else
				player.frame_duration=2
			end

			if time()-player.anim>player.frame_duration then

				player.anim=time()
				playerhead.sp+=1
				player.sp+=1
					if player.sp>20 then
					playerhead.sp=1
					player.sp=17
					end
			end
	end
end

function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)
end
-->8
-- enemies

function enemies_animate()
	if time()-enemyblob.anim>.1 then
		enemyblob.anim=time()
		enemyblob.sp+=1
		if enemyblob.sp>enemyblob.last_frame then
			enemyblob.sp=enemyblob.first_frame
		end
	end
end
__gfx__
c0c00c0cc000ccccc000ccccc0ccccccc000ccccc000ccccc00000ccc000ccccc00000ccc000ccccc000cccccccccccccccccccccccccccccccccccccccccccc
090aa090022200cc022200cc02000ccc022200cc022200cc0288880c022200cc0288880c022200cc022200cccccccccccccccccccccccccccccccccccccccccc
c090090cc088880cc088880c022220ccc088880cc088880c08899980c088880c08899980c088880cc088880ccccccccccccccccccccccccccccccccccccccccc
0a0cc0a00889998008899980c088880c08899980088999800899999008899980089999900889998008899980c000cccccccccccccccccccccccccccccccccccc
0a0cc0a008a9a9a008a9a9a00889a98008a9a9a008a9a9a009a2a2a008a9a9a009a2a2a008a9a9a008a9a9a0022200cccccccccccccccccccccccccccccccccc
c090090c099292900992929008a9a9a0099292900992929009e4f4e00992929009e4f4e00992929009929290c088880ccccccccccccccccccccccccccccccccc
090aa09009e4f4e009e4f4e0099f9f9009e4f4e009e4f4e0c09fff0c09e4f4e0c09fff0c09e4f4e009e4f4e008899980cccccccccccccccccccccccccccccccc
c0c00c0cc09fff0cc09fff0c09e2f2e0c09fff0cc09fff0cc022820cc09fff0cc022820cc09fff0cc09fff0c08a9a9a0cccccccccccccccccccccccccccccccc
ccccccccc022820cc022820cc09ff770c022820cc022820cc0778260c022820c06288770c022820cc022820c099f9f90cccccccccccccccccccccccccccccccc
cc000ccc0228882002288770022287600228877002288820c0768860022888200728876002288820c077826009e2f2e0cccccccccccccccccccccccccccccccc
c08820cc07688860076887600768820c0768876007688860c049a90c07688860c049a00c07688860c0768860c077f770cccccccccccccccccccccccccccccccc
08a9820c0779a9600779a90c0779a90c0779a90c0779a960028884400779a960c028440c0779a960c049a90c02672760cccccccccccccccccccccccccccccccc
08aa9820c088880cc088880cc088880cc088880cc088880c05504220c088880cc084220cc088880c028884400829a920cccccccccccccccccccccccccccccccc
c088200cc0240240c0240240c0240240c0240240c0240240c000220cc0240240c04220ccc0240240055042200288880ccccccccccccccccccccccccccccccccc
cc000cccc0440440c0440440c0440440c0440440c0440440cccc00ccc0440440cc000cccc0440440c000220c02442440cccccccccccccccccccccccccccccccc
ccccccccc0000000c0000000c0000000c0000000c0000000ccccccccc0000000ccccccccc0000000cccc00ccc000000ccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccc0cccc0ccc0cc0cccccc0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccc0000cc0e0cc0e0c080080cccc080cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc0000ccccccccccccccccccc0ffff0cc0c00c0cc088880000c080cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c0ffff0ccc0000cccccccccc0e0f0fe0cc0ff0ccc0181e0888080ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0e0f0ee0c0ffff0cc00000cc0e1f1ee0cc0ee0cccc0228888880cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
081e18e0081f18e00efffe0c081e18e0c0c00c0ccc0882882880cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0eeeeee00eeeeee0081e18e00eeeeee00e0cc0e0c0822880880ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c000000cc000000cc000000cc000000cc0cccc0ccc00000c00cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c00cc00cccccccccccc00ccccc0000cccc0000cccc0000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
03b00b30c00cc00ccc0660ccc09aa90cc066660cc066660ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0b0bb0b003b00b30c077760009aaaa900677776006777760cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0e1bb1e00b0bb0b0c0767765090aa0900707707007077070cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
083333800e1bb1e007776060081aa1800817718008177180cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c013310c0833338007660c0c049999400677776006777760cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0bb11bb00b1331b00660ccccc044440cc060060c06066060cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c000000cc000000cc00ccccccc0000cccc0cc0ccc0c00c0ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
33333333333333333333333333333333ccccccccccc828cccccc00cccccc0c0cccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
b88b8aa8bbbbbbbbbbbeaaebcaacbebbcccccccccc88a88ccc00330ccc00b030cccc0fe0cc0000cccccccccccccccccccccccccccccccccccccccccccccccccc
bbb3b88bbbbbb33bbbbbeebbbccbeaebcccccccccc2a9a2cc08240ccc02bb30cccc07620c0b33b0ccccccccccccccccccccccccccccccccccccccccccccccccc
33333bb33bbb33333bbbbb333bbbbeb3cccccccccc88988c08222a0c02988bb0cc0b350c0b33b370cccccccccccccccccccccccccccccccccccccccccccccccc
33343333333334433333333333bbbb33c33cccccccc838cc0889980c08889b0ccc0310cc03b77730cccccccccccccccccccccccccccccccccccccccccccccccc
994443344333994423333394433333343bb3c33ccccc3cbc0888880c0898820cc0400cccc03bb30ccccccccccccccccccccccccccccccccccccccccccccccccc
24442994422499242244299442333394c33b3b3ccccc3bccc08880cc028820cc040ccccccc0330cccccccccccccccccccccccccccccccccccccccccccccccccc
44442244444442244444224442244994ccc3b3cccccc3ccccc000cccc0000cccc0ccccccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccc
44444444444444444444444444444444c000000ccc0000ccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
499944444444499449944444444444440efffff0c0effe0ccc08800cccc0ccccc000c00ccc0000cccccccccccccccccccccccccccccccccccccccccccccccccc
4999244444442994299499444444444402efeff00efe77e0cc082770cc090ccc02f70f70c08ee70ccccccccccccccccccccccccccccccccccccccccccccccccc
49992444444422442244992444444444022efef00fe77770c0777f70c00a00cc02ef2ef0c0288e0ccccccccccccccccccccccccccccccccccccccccccccccccc
4422244449944444444442244444444402e2eff00fee77f0077ff47009aaa90c02eeeee0c0288e0ccccccccccccccccccccccccccccccccccccccccccccccccc
44444994499244444994444444444444022e2ef00efeefe00ff4400cc09a90ccc02eee0cc082280ccccccccccccccccccccccccccccccccccccccccccccccccc
44442994442244444992444444444444022222e0c0effe0c04400ccc09a0a90ccc02e0cccc0000cccccccccccccccccccccccccccccccccccccccccccccccccc
44442244444444444422444444444444c000000ccc0000ccc00cccccc00c00ccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccc000000cccc00cccc000000ccc0000ccccccccccccccccccc9c9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccc02888820cc0670cc0c777770c01cc10cccccc000000cccccccacccc9cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccc000000cc004400ccc0670cc01c7c77001c17710ccc00aaaaaa00ccccc9009accccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc02888820c09aa90cc066770c011c7c700c177770cc0aa444444aa0cccc0760cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c000000cc09aa90ccc0440ccc056670c01c1c7700c1177c0cc0a49999994a0cccc0650cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
02888820cc0440ccc09aa90c05566770011c1c7001c11c10c0a4999999994a0c9c9009cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c09aa90cc09aa90cc004400c05556670011111c0c01cc10cc0a499a99a994a0caaccccaccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
028888200288882002888820c000000cc000000ccc0000ccc0a49aa99aa94a0ccc9cc9cccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccc6666ccccccc666ccccccccccc000000ccc0000ccc0a49aa99aa94a0ccc9ccacccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccc677776ccccc67776c66cccccc09aaaaa0c09aa90cc0a49aa99aa94a0ccaccc99ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc66c67777776ccc6777776776ccccc049a9aa009a97790c0a49aa99aa94a0c9c900cc9cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc677677777776ccc677776777766ccc0449a9a00a977770c0a49aa99aa94a0ccc0760c9cccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c67777777666776cc6667777777776cc04949aa00a9977a0c0a49aa99aa94a0ccc0650accccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c67667676666676c666667766677766c044949a009a99a90c0a49aa99aa94a0ccc9009accccccccccccccccccccccccccccccccccccccccccccccccccccccccc
6766666666666676666666666666777604444490c09aa90cc0a49aa99aa94a0cccaacccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c66666666666666cc66666666666666cc000000ccc0000ccc0a49aa99aa94a0cccc9cc9ccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
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
c0000cccc0000cccccccccccccc0ccccccccc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
028880cc088820cccccccccccc010cccc00c0770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
088880cc088880cccccccccccc0c0ccc09900770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
08888200288880cccccccccccc0c0ccc09400770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
08888800888880cccccccccccc0c0cccc00c0770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
08888800888880cccccccccccc0c0ccccccc0770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
08828822882880c0000ccc000c0c000cc00c0770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
088088228808800aaaa000bbb00cccc009900770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
08802888820880aaaaaa0bbbbb0ccccc09900770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
08800888800880aa00aa0b303b0c101c09900660cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
08800288200880a0cc0a0b0c000c0c0c0990c00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0880c0880c08809a00a903b0bb0c0c0c09900770cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0280c0220c082009aa90c03bb0010c0104400660cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c00ccc00ccc00cc0000ccc000cc0ccc0c00cc00ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000000030303030100000000000000000000000000000001000000000000000000000000000000010000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000727300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007071000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000007474740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000074747400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000006667000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4500440000004400004500467677440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4142434243424142424142434241424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5153505351535053515350535153505300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5352535253525352535253525352535200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5053515350535153505351535053515300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5352535253525352535253525352535200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5153505351535053515350535153505300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000010500205002050040501a6501a6501a6501d0501b6501d0501d0501965019650176501a0501865015650156501565016650156501865013650156500b05011650176501865003050000503405037050
001000000000000000000000000000000000000000000000267002670026700247001f7001c7001b7001c7001c700000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01024344

