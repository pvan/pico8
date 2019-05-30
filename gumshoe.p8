pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


--sprite flags
--1 - on if walkable
--2 - 
--3 - 
--6 - has frosted (pink) pixels
--7 - draw over player (dep?)


function palreset()
 pal()
 palt(0,false)
 palt(3,true)
end


function _init()

 init_player()
 palreset()

end



function _update()
 
 
 --debug menu
 if btn(❎) and btn(🅾️) then
  pause_menu=true
  
  --pm=0
  if (btnp(⬆️)) then
   if (pm==3) pm=0 else pm=1
  end
  if (btnp(⬅️)) then
   if (pm==4) pm=0 else pm=2
  end
  if (btnp(⬇️)) then
   if (pm==1) pm=0 else pm=3
  end
  if (btnp(➡️)) then
   if (pm==2) pm=0 else pm=4
  end
  return --dont update the rest
 else
  pause_menu=false
  if (pm==1) debugcols=not debugcols
  if (pm==2) debugtrigs=not debugtrigs
  if (pm==3) debugxxx=not debugxxx
  if (pm==4) debugxxx=not debugxxx
  pm=0
 end
 
 
 player_update(dx,dy)


 
end


function draw_player_behind_glass()

 glasspix={}
 for obj in all(things) do
	 if ybase(obj)>pybase() then
	  if fget(obj.spr,6) then
	   spx=(obj.spr%16)*8
	   spy=flr(obj.spr/16)*8
	   for x=0,obj.sprw*8 do
	    for y=0,obj.sprh*8 do
	     if sget(spx+x,spy+y)==14 then
	      --pset(x,y,14)
	      screenx=obj.x+x
	      screeny=obj.y+y
	      add(glasspix,{screenx,screeny})
	     end
	    end
	   end
	  end
  end
 end
 
 --red bg
 for p in all(glasspix) do
  pset(p[1],p[2],8)
 end
 
 --drawing player here will
 --potentially overdraw the red
 player_draw()
 
 --check what isn't red any more
 for p in all(glasspix) do
  if pget(p[1],p[2])!=8 then
   pset(p[1],p[2],13)
  else
   pset(p[1],p[2],6)
  end
 end
 
-- local plr_y = pybase()
-- 
-- --right now the only glass
-- --is on closed doors
-- --but potentiall other things
-- --in future
-- 
-- --could clarify like this?
-- --make list of all pixels
-- --that are glass
-- --then iterate over those
-- --instead of the objects twice
-- 
-- for i=1,#things do
--  local obj=things[i]
-- 
--  --only do doors below player
--  --since we dont want to cover
--  --up things alerady drawn
--	 if ybase(obj)>plr_y then
--	 
--		 --if closed door
--		 if obj.spr==13 then 
--		  basex=obj.x+1
--		  basey=obj.y+5
--		
--		  --red bg
--			 for x=0,5 do
--			  for y=0,3 do
--			   pset(basex+x,basey+y,8)
--			  end
--			 end
--			 
--			end
--		end
--	end
--
-- --(only do once no matter
-- --(how many doors we have)	
-- --draw over the red
-- --this is now also the 
-- --only time player is drawn
-- player_draw()
--
--	
-- --check what isn't red anymore
-- for i=1,#things do
--  local obj=things[i]
--	 if ybase(obj)>plr_y then
--		 if obj.spr==13 then 
--		  basex=obj.x+1
--		  basey=obj.y+5		 
--		  
--			 for x=0,5 do
--			  for y=0,3 do
--			   col=pget(basex+x,basey+y)
--			   if col!=8 then
--			    pset(basex+x,basey+y,13)
--			   else
--			    pset(basex+x,basey+y,6)
--			   end
--			  end
--			 end
--			 
--			 --used to draw letterin here
--			 --but now drawing transparent
--			 --sprite over this (pink pixel method)
--
--			end
--		end
--	end


end

function _draw()
 cls()
 
 map()

 --sort objects + player
 ypos={}
 for i=1,#things do
  local obj=things[i]
  local ybase=ybase(obj)
  add(ypos,{ybase,i})
 end
 add(ypos,{pybase(),0})
 sort_objs(ypos)
 
 --ok this is pretty simple
 --except for the special glass
 --basically draw everything
 --in order of y (sorted above)
 --a "things" index of i=0
 --is code for the player
 --for glass...
 --(pink, only closed doors)
 --if behind player, just 
 --change pink to gray
 --when we draw the player,
 --run our special code to 
 --render the glass on all doors
 --in front of the player
 --and later, when those 
 --door sprites are drawn,
 --change pink to transparent
 --to save the special glass
 --pixels we already rendered
 drewplayer=false
 for i=1,#ypos do
  if ypos[i][2]==0 then
   draw_player_behind_glass()
   drewplayer=true
  else
   local obj=things[ypos[i][2]]
   if fget(obj.spr,6) then --has transparent pixels
    if drewplayer then  
	    palt(14,true) --transparent
  	 else
 	   pal(14,6) --grey
	   end
   end
   draw_obj(obj)
   palreset()
  end
 end
 
 
-- draw_obj(rack)
-- draw_obj(door)
-- player_draw()
 
 
-- map(0,0,0,0,16,16,0x80)
 
 
 if pause_menu then
  spr(15,64-4,64-4)
  spr(15+16,64-4,64-4-10)
  spr(15+16*2,64-4-10,64-4)
  spr(15+16*3,64-4,64-4+10)
  spr(62,64-4+10,64-4)
  
  local rx,ry=64-4,64-4
  if (pm==1) rx=64-4 ry=64-4-10
  if (pm==2) rx=64-4-10 ry=64-4
  if (pm==3) rx=64-4 ry=64-4+10
  if (pm==4) rx=64-4+10 ry=64-4
  rect(rx-1,ry-1,rx+8,ry+8)
 end
	 
 
 if (debugtrigs) then
  for obj in all(things) do
   rect2(obj_trig(obj),7)
  end
 end
 
 if (debugcols) then
  for obj in all(things) do
   c=9
   if (obj.solid) c=10
   rect2(obj_col(obj),c)
  end
 end


end



-->8
--player


--psprs={236,237,238,239}
psprs={128,129,130,131}


--for sorting
function pybase()
 return py+16 --(bottom of sprite)
end


function init_player()
	px,py=60,60
	pd=2
	
	pt=0
	
	pclothes=true
	
--	-4,0,3
-- hoty={-2,0,2}
 
 hotx={0,3,7}
 hoty={12,14,17}
	
end


function player_update()

 
 local dx,dy=0,0
 if (btn(⬅️)) dx-=1 
 if (btn(➡️)) dx+=1 
 if (btn(⬆️)) dy-=1 
 if (btn(⬇️)) dy+=1
 
 if dx!=0 or dy!=0 then
	 usebox={px+dx*4,
	         py+11+dy*4,
	         8,8}
 end
 
 if pstate=="use" then
	 dx,dy=0,0
  pstatetimeleft-=1
  if pstatetimeleft==0 then
   pstate="stand"
  end
 end
 
 if pstate!="use" then
	 if btnp(❎) and p_use_released then
	  dx,dy=0,0
	  pstate="use"
	  pstatetimeleft=10
	  p_use_ready=true
	  p_use_released=false
	 else
		 if dx!=0 or dy!=0 then
		  pstate="walk"
		 else
		  pstate="stand"
		  pt=1
		 end
	 end
 end
 
 if (not btn(❎)) p_use_released=true
 
 if (dx>0) pflip=false 
 if (dx<0) pflip=true
 
 
 --collision / movement
 if dx!=0 or dy!=0 then
  local allowx,allowy=true,true 
  for x in all(hotx) do
   for y in all(hoty) do
    local hx,hy=px+x,py+y
    if (solidtile(hx+dx,hy)) allowx=false
    if (solidtile(hx,hy+dy)) allowy=false
    
--    --check objs here sep from walls so we can ignore them easier    
--			 if (newobjcol(hx,hy,dx,0)) allowx=false
--			 if (newobjcol(hx,hy,0,dy)) allowy=false

   end
  end
  if (allowx) px+=dx
  if (allowy) py+=dy
 end
 
 if p_use_ready and
    usebox!=nil and
    pstate=="use" 
 then
  for obj in all(things) do
   if obj.usefunc then
    if usetrig(usebox,obj) then
     p_use_ready=false
    end
   end
	 end
 end
 
 --anim
 pt+=0.2
 if (pt>#psprs) pt=0
 pa=flr(pt)
 
end


function player_draw()
  
 local psprx=px
 local pspry=py
 
 --do fake project shadow?
 spr(64,psprx,pspry+12)
 
 if pstate=="walk" then
  pspr=psprs[pa+1]
 end
 if pstate=="stand" then
  pspr=psprs[1]
 end
 if pstate=="use" then
  pspr=psprs[4]+1
 end
 if (pclothes) pspr+=(160-128)
 spr(pspr,psprx,pspry,1,2,pflip)

 if debugcols then
  pset(px,py,11)
  
  for x in all(hotx) do
  for y in all(hoty) do
  pset(px+x,py+y,10)
  end end
 end
 if debugtrigs then
  if usebox!=nil then
   rect2(usebox,7) end
 end

end



-->8
--util



--sort list of pairs {y,i}
--by the 1st val (y in this case)
function sort_objs(t) 
	for n=2,#t do
		local i=n
		while i>1 and 
		 t[i][1] < t[i-1][1] --[1]=metric
		do
			t[i],t[i-1]=t[i-1],t[i]
			i-=1
		end
	end
end


--rects collide
--using x,y,w,h style rects
function rectcol(a,b)
 return a[1]+a[3]>b[1] and 
								a[1]<b[1]+b[3] and
								a[2]+a[4]>b[2] and
								a[2]<b[2]+b[4] 
end



--drop shadow
function print2(str,col)
 local cursor_x=peek(0x5f26)
 local cursor_y=peek(0x5f27)
 if (col==nil) col=7
 print(str,cursor_x+1,cursor_y+1,0)
 print(str,cursor_x,cursor_y+1,0)
 print(str,cursor_x,cursor_y,col)
 poke(0x5f27,cursor_y+6)
end



function pinrect(px,py,r)
 local rx,ry,rw,rh=r[1],r[2],r[3],r[4]
 return px>=rx and px<rx+rw
    and py>=ry and py<ry+rh
end



--function rect2(x,y,w,h,c)
-- rect(x,y,x+w-1,y+h-1,c)
--end
function rect2(r,c)
 if (c==nil) c=10
 rect(r[1],r[2],r[1]+r[3]-1,r[2]+r[4]-1,c)
end

-->8
--objects


function draw_obj(obj)
 spr(obj.spr,obj.x,obj.y,
     obj.sprw,obj.sprh)
end



function userack(rack)
 pclothes=not pclothes
 rack.spr=34
 if (pclothes) rack.spr=32
end

function usedoor(door)
 door.spr+=1
 if (door.spr==15) door.spr=13
 if door.spr==13 then
  door.solid=true
 else
  door.solid=false
 end
end



function named_mold(m)
 nm={}
 nm.name=m[1]
 
 nm.spr=m[2]
 nm.sprw=m[3]
 nm.sprh=m[4]
 
 nm.solid=m[5]
 nm.relcol={}
 nm.relcol.x=m[6]
 nm.relcol.y=m[7]
 nm.relcol.w=m[8]
 nm.relcol.h=m[9]
 
 nm.reltrig={}
 nm.reltrig.x=m[10]
 nm.reltrig.y=m[11]
 nm.reltrig.w=m[12]
 nm.reltrig.h=m[13]

 nm.usefunc=m[14]
 return nm
end


function obj_col(obj)
 return {
  obj.x+obj.relcol.x,
  obj.y+obj.relcol.y,
  obj.relcol.w,
  obj.relcol.h
  }
end

function obj_trig(obj)
 return {
  obj.x+obj.reltrig.x,
  obj.y+obj.reltrig.y,
  obj.reltrig.w,
  obj.reltrig.h
  }
end

--for sorting
function ybase(obj)
 return obj.y+obj.sprh*8
end


function spawn(x,y,mold)
 obj={}
 
 obj.x=x
 obj.y=y
 
 local nm=named_mold(mold)
 for k,v in pairs(nm) do
  obj[k]=v
 end
 
 add(things,obj)
end



function usetrig(r,obj)
 if rectcol(r,obj_trig(obj))
 then
  obj.usefunc(obj)
  return true
 end 
 return false
end





mold_door={
 "door",
 13,  --sprite
 1,2, --tilesize
 true, --is solid
 0,8+4,8,8-4,  --col rel to sprite
 0,8,8,8, --trig rel to sprite
 usedoor, --trigger handler
-- 0, --sort offset?
}
mold_rack={
 "rack",
 32,  --sprite
 2,2, --tilesize
 true, --is solid
 4,10,7,6,  --col rel to sprite
 4,10,7,6, --trig rel to sprite
 userack, --trigger handler
-- 0, --sort offset?
}
mold_window={
 "window",
 40,  --sprite
 2,2, --tilesize
 true, --is solid
 0,8,16,8,  --col rel to sprite
 0,0,0,0, --trig rel to sprite
 nil, --trigger handler
-- 0, --sort offset?
}


things={}
spawn(4*8,5*8,mold_door)
spawn(5*8,5*8,mold_door)
spawn(6*8,5*8,mold_door)
spawn(7*8,5*8,mold_door)

spawn(5*8,14*8,mold_door)

spawn(3*8,2*8,mold_rack)
spawn(9*8,14*8,mold_window)


-->8


function solidtile(x,y)

 local tile=mget(x/8,y/8)
 if (fget(tile,0)==false) return true
 
 for obj in all(things) do
		if obj.solid then
			if pinrect(x,y,obj_col(obj)) then
 			return true
			end
		end
	end
	
 return false

end


function newobjcol(x,y,dx,dy)
 for obj in all(things) do
		if obj.solid then
		 --ignore obj if we are
		 --already on top of it
			if not pinrect(x,y,obj_col(obj)) and
			   pinrect(x+dx,y+dy,obj_col(obj)) then
 			return true
			end
		end
	end
	return false
end
__gfx__
00000000dddddddd66666666dddddddddddddddd0000000016666666000000000000000066666666666666660000000066666666333333333333333311111111
00000000ddddddddd666666ddddddddddddddddd0000000016666666000000000000000066666666666666660000000066666666333333333333333317777771
00700700dddddddddd666d6ddddddddddddddddd0000000016666666000000000000000011111111111111110000000011111111333333333333333317555771
00077000ddddddddddd66d6ddddddddddddddddd0000000016ddddd60000000000000000dddddddddddddddd00000000dddddddd333333333333333317575d71
00077000ddddddddddd6dddddddddddddddddddd0000000016d666d60000000000000000dddddddddddddddd0000000011111111111111111113333317555d71
00700700dddd6dddddd6dddddddddddddddddddd0000000016ddddd60000000000000000dddddddddddddddd00000000333333331eeeeee115133333177ddd71
00000000dddd6ddddddddddddddddddddddddddd00000000166666660000000000000000dddddddddddddddd00000000333333331e00e0e1d513333317777771
00000000ddd666dddddddddddddddddddddddddd00000000111111110000000000000000dddddddddddddddd00000000333333331e0ee0e1d513333311111111
00000000d666666ddddddddddddddddddddddddd00000000155555555555555500000000dddddddddddddddd00000000333333331eeeeee11513333311111111
0000000066666666dddddddddddddddddddddddd00000000155555555555555500000000dddddddddddddddd0000000033333333155555511513333314444441
0000000011111111111111111111111111111111000000001555555555555555000000001111111111111111000000003333333315555551151333331444a4a1
0000000044444444444414444444444444444444000000001111111111111111000000004444144444444444000000003333333315111151d513333314444441
0000000022222222222414222222222222222222000000005555555551555555000000002224142222222222000000003333333315144451d51333331444a4a1
0000000022222222222414222222222222222222000000005555555551555555000000002224142222222222000000003333333315555551151333331aaa4441
000000002222222222241422222222222222222200000000555555555155555500000000222414222222222200000000333333331111111111133333144a4441
00000000111111111111111111111111111111110000000011111111111111110000000011111111111111110000000033333333333333333333333311111111
33333333333333333333333333333333444444444444444444444444555555556666666666666666000000000000000000000000000000000000000011111111
333337333733333333333733373333334444444444444444444444445dddddd51111111111111111000000000000000000000000000000000000000014441111
333333767333333333333376733333334444444444444444eeee4444511111151eeeeeeeeeeeeee1000000000000000000000000000000000000000014477711
33333336333333333333333633333333444444666444444ffffe444411111111eeeeeeeeeeeeeeee000000000000000000000000000000000000000014474711
33333736373333333333443634443333444477766774444ffffe444451111115e0000e000e00000e000000000000000000000000000000000000000017777711
33333376733333333334447674663333444477766774446ffffe44445dddddd5e0eeee0e0e0e0e0e000000000000000000000000000000000000000017447441
33333336333333333334443634643333444477766774446ffffe44445dddddd5e0000e000e0e0e0e000000000000000000000000000000000000000017777441
33333336333333333334443634643333444477747774444ffff444441dddddd1eeee0e0e0e0eee0e000000000000000000000000000000000000000011111111
3333333633333333333444363444333344444444444444444444444454444445e0000e0e0e0eee0e000000000000000000000000000000001111111111111111
3333333633333333333444363333333311111111111111111111111151111115eeeeeeeeeeeeeeee000000000000000000000000000000001444444117776d71
3333333633333333333444363333333311111111111111111111111151111115e00e00e00e0ee00e00000000000000000000000000000000144444411776dd71
3333333633333333333443363333333311100000000000000000011151111115e0ee00e00e00e0ee0000000000000000000000000000000014444441176ddd71
33333dd6dd33333333333dd6dd33333311100000000000000000011154444445ee0e0ee00e00e00e000000000000000000000000000000001444444117ddd771
3333ddddddd333333333ddddddd3333311100000000000000000011154444445e00e0ee00e0ee00e000000000000000000000000000000001444444117dd7771
33333ddddd33333333333ddddd33333311100000000000000000011154444445eeeeeeeeeeeeeeee000000000000000000000000000000001444444115777771
33333333333333333333333333333333111000000000000000000111511111151111111111111111000000000000000000000000000000001111111111111111
33333333000000000000000000000000000000000000600000006100000061000000610000006500000051000000100000000000000010000000000000005000
33333333000000000000000000000000000000000066606000666160006661600066616000666560005551500011101000000000001110100000000000555050
30000003000000000000000000000000000600000000006000111160001111600011116000555560001111500000001000000000000000100000000000000050
00000000000000000000000000000000060000000600006006111160061111600611116006555560051111500100001000000000010000100000000005000050
00000000000000000000000000000000066666000066666006666660066666600666666006666660055555500111111000000000011111100000000005555550
30000003000000000000000000000000000000000000000000111100001110000011110000111100001111000000000000000000000000000000000000000000
33333333000000000000000000000000006600000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000660000060000000d7770000d7700000d7770000d77700005666000010000000000000010000000000000000000000
00005000000000000000000000005000060000000660006006dd7d0006dd7d0006dd7dd005dd7dd00d5565500110000ddd000000100000ddd000000005000000
005550000000500000005000005550006600000006000060066ddd00066ddd00066dddd0055dddd00dd555500100001110000000101101110000000005500000
0000050000555000005550000000050060000000060000600666dd000666dd000666ddd00555ddd00ddd55500100001100000000111101100000000005550000
0555550000000500000005000555550060000000066000600dd6dd000dd6d6000dd66d600dd55d60055dd5d00110000000000000111100000000000000055000
0000000005555500055555000000000066000000006000600066d0000066d00000666d0000555d0000ddd5000010000000000000000000000000000000555000
005500000000000000000000055000000660000000000000000000000066d00000666d0000555d0000ddd5000000000000000000000000000000000000555000
000550000055000005500000005000000060000000000000000000000066d00000666d0000555d0000ddd5000000000000000000000000000000000000555000
0005500000050500005055000000550000000000000000000000000000dd110000dd111000dd1110005511100000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00006100000061000000610000001000000061000000060000000600000060000000600000006000000000000000000000000000000060000000000000006000
00666160006661600066616000111010006661600066660600666600006660000066600000666000000000000000000000000000006661600000000000666160
0011116000111160001111600000001000111160000000060000000600000060000000600000006000ddd0000000000000000000001111600000000000111160
061111600611116006111160010000100611116006000006060000060600006006000060060000600dffff0000ddd00000ddd000061111600000000006111160
066666600666666006666660011111100666666006666666066666660666666006666660066666600df1f1000dffff000dffff00066666600000000006666660
0011110000111100001111000000000000111100001111100011111000111100001111000011110000ffff000df1f1000df1f10000f1f1000000000000f1f100
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffff0000ffff0000ffff000000000000ffff00
00dd7d0000dd770000dd77000010010000d711d000d711d000d711d000d7110000d7110000771100007711000066616006661660077717700000000007771770
066dddd0066dd7d0066dd7d00100011006dd717606dd717d06dd716006dd716006dd716007777170077771700777717077771770777717700000000077771770
0666ddd00666ddd00666dd6001000110066d7176066d717d066d7160066d7160066d716007777170077771700777717077771770777717700000000077771770
06666dd006666dd006666d6001000110066671760666717d06667160066671600666716007777170077771700777717077771770777717700000000077771770
0dd66dd0077666d00776667001000110077677770776777607767770077677600776776006677770066777700ff77770ff777770ff77777000000000ff777770
00666d000055560000ddd5000010010000ddd55000ddd55000ddd55000ddd5500066dd60005551100055511000666dd006666dd0055551100000000005555110
00666d000055560000ddd5000010010000ddd55000ddd55000ddd55000ddd55000555110005551100055511000666dd006666dd0055551100000000005555110
00dd11100011ddd00066ddd00000011000666ddd00666ddd00666ddd00666ddd00000ddd00666ddd00666ddd00ddd1110ddd11110666dddd000000000666dddd
33333333333333333333333333333333333333330000500000000000000000000000500000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333330055500000005000000050000055500000000000000000000000000000004000000000000000000000000000
33333333333333333333333333333333333333330000050000555000005550000000050000000000000000000000400000444600000044000000400000000000
3333333333ddd3333333d33333333333333333330555550000000500000005000555550000000000000000000044460000666600006666000044460000000000
33ddd3333dffff3333ddd33333ddd33333ddd3330000000005555500055555000000000000000000000000000466664004444440044444400466664000000000
3dffff333df1f1333dffff333dffff333dffff330055000000000000000000000550000000000000000000000444444000f1f10000ffff000444444000000000
3df1f13333ffff333df1f1333df1f1333df1f13300055000005500000550000000500000000000000000000000f1f10000ffff0000f1f10000f1f10000000000
33ffff333666163333ffff3333ffff3333ffff3300055000000505000050550000005500000000000000000000ffff000466160000ffff0000ffff0000000000
33661633377717333666163336661633336661330000000000000000000000000000000000000000000000000466160044771740046616000466610000000000
377717737777173377771733777717733777777f0000000000000000000000000000000000000000000000004447174044771740044717400444710000000000
7777177377f71733777177f37777177f3777777f0000000000000000000000000000000000000000000000004447174044717740044717400444f10000000000
7777177377f77731777177f37771777f3777713300000000000000000000000000000000000000000000000044471740f4777740044717404444f70000000000
ff7777733666ddd1ff777733f777777337777733000000000000000000000000000000000000000000000000ff47774044666d40044777404447770000000000
36666dd3d666ddd1d666ddd33366dd3336666d3300000000000000000000000000000000000000000000000004466d4046666d4004666d0044d6660000000000
36666dd3d6633333d666ddd33366d33336666d3300000000000000000000000000000000000000000000000004466d404660011044666d0044dd660000000000
3ddd1111dd333333d333311133d111333ddd11130000000000000000000000000000000000000000000000000ddd11110dd000000ddd110001110dd000000000
33333333333333333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333343333333333333333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33334333334446333333443333334333333343330000000000000000000000000000000000000000000000000000000000000000000044000000400000000000
3344463333666633336666333344463333444633000000000000000000ddd0000000000000000000000000000000000000000000006666000044460000000000
34666643344444433444444334666643346666430000000000ddd0000dffff0000ddd00000ddd000000000000000000000000000044444400466664000000000
3444444333f1f13333ffff333444444334444443000000000dffff000df1f1000dffff000dffff0000000000000000000000000000ffff000444444000000000
33f1f13333ffff3333f1f13333f1f13333f1f133000000000df1f10000ffff000df1f1000df1f10000000000000000000000000000f1f10000df1f0000000000
33ffff333466163333ffff3333ffff3333ffff330000000000ffff000466160000ffff0000ffff0000000000000000000000000000ffff00000fff0000000000
34661633444717333446163334661633334661330000000004661600444717000446160004661600004661000000000000000000044461000446610000000000
444717434447173344471733447717433444444f00000000444717404447170044471700447717400444444f0000000000000000044471400447710000000000
4447174344f71733444177f34477174f3444444f000000004447174044f71700444717f04477174f0444444f0000000000000000444771404447710000000000
4447174344f77731444177f34471774f34447133000000004447174044f77701444717f04477174f0444710000000000000000004f4717404447770000000000
ff4777434446ddd1ff477733f47777433447773300000000ff4777404446ddd1ff477700f47777400447770000000000000000004f477740ff47770000000000
34466d434466ddd14446ddd34466dd4334466d330000000004466d40d666ddd14466ddd04466dd0004466d0000000000000000000466dd0044666d0000000000
34466d43d66333334466ddd34466d33334466d330000000006666dd0d6600000d666ddd00066d00006666d000000000000000000446ddd004466dd0000000000
3ddd1111dd333333d333311133d111333ddd1113000000000ddd1111dd000000d000011100d111000ddd111000000000000000000dd001100d01100000000000
00000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000050000000000000000000000000000055505000000000000000000000000000000000000000000000000000000000000040000000000000000000
00000000005550500000000000000000000000000000005000000000000000000000000000000000000040000000400000000000004446000000400000000000
00000000000000500000000000000000000000000500005000000000000000000000000000000000004446000044400000000000046666400044460000000000
00ddd0000500005000ddd00000ddd00000000000055555500000000000ddd00000ddd00000ddd000046666400400004000000000044444400466664000000000
0dffff00055555500dffff000d9999000000000000000000000000000dffff000dffff000dffff0004444440044444400000000000f1f1000444444000000000
0df1f100000000000df1f1000d9191000000000000000000000000000df1f1000df1f1000df1f10000f1f100000000000000000000ffff0000f1f10000000000
00ffff0000ffff0000ffff000099990000000000000000000000000000ffff0000ffff0000ffff0000ffff0000000000000000000066610000ffff0000000000
066616600500000006d717d004561650000000000500000000000000066616600d66160004661600046616000400000000000000004471000066610000000000
7777177055500040666d77d04445165000000000055000000000000077771770ddd717d044471740444717404440004000000000044471000444710000000000
77771770555504406666d7d04444565000000000055500000000000077771770ddd717d0444717404447174044400040000000000ff471000444710000000000
777717700055544066666dd04444455000000000000550000000000077771770ddd717d0444717404447174044400040000000000ff47100f444710000000000
ff777770ff555440ff666dd099444550000000000055500000000000ff777770ffd777d0ff477740ff477740004000400000000004477700f447770100000000
06666dd00555544006666d000444455000000000005550000000000006666dd00dd66dd004466d4004466d4004400040000000000466660004666dd100000000
06666dd00555540006666d000444455000000000005550000000000006666dd006666dd004466d4004466d400440004000000000046666000466ddd100000000
0ddd11110ddd11110ddd11100ddd11110000000000000000000000000ddd11110ddd11110ddd11110ddd1111000000000000000000dd11000dd0000000000000
000000000000000000000000000000000000000000000000000000000666f6600466160022222222000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000777777704447174022222222000000000000000000000000000040000000000000000000
00000000000000000000000000000000000000000000000000000000777777704447174022220222000000000000000000004000004446000000440000004000
00000000000000000000000000000000000000000000000000000000777777704447174022000622000000000000000000444600006666000066660000444600
00ddd0000000000000000000000000000000000000ddd00000000000ff777770ff47774020666602000000000000000004666640044444400444444004666640
0dffff00000000000000000000000000000000000d4444000000000006666dd004466d402000000200000000000000000444444000f1f10000ffff0004444440
0df1f100000000000000000000000000000000000d4141000000000006666dd006666dd022f1f122000000000000000000f1f10000ffff0000f1f10000f1f100
00ffff000000000000000000000000000000000000444400000000000ddd11110ddd111122ffff22000000000000000000ffff000466160000ffff0000ffff00
0d6616000d6616000466160004661600046616000664446000000000000000000000000020660622000000000000000004661600447717400446160004461600
6dd717605dd717d04447174044471740444717407774477000000000000000000000000000070702000000000000000044471740447717404447174004471700
66d7176055d717d04447174044471740444717407777477000000000000000000000000000070702000000000000000044471740444f77404447174044471700
66671760555717504447174044471740444717407777677000000000000000000000000000070702000000000000000044471740444f774044471740444f1700
ff677760ff577750ff477740ff477740ff47774044776770000000000000000000000000ff0777020000000000000000ff4777404666dd404ff77740444f7700
066dd66005566d5004466d4004466d4044466d40066767d000000000000000000000000020055112000000000000000004466d404666dd404466dd0044666d00
0555111006666dd006666dd004466d4044466d4006666dd000000000000000000000000025555112000000000000000004466d40466001104d66dd004466dd00
0666dddd0ddd11110ddd11110ddd11110ddd11110ddd11110000000000000000000000002666dddd00000000000000000ddd11110dd000000d00011000001100
__gff__
01000000000000000081810081c1810000000000000001010000000001410100000000000000000041410000000000000000000000000000414100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0203030103030303020103030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1213121112131213121112131213000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617162716171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617242526171716000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1616161617171617343536171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161617161717161716171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161617161717161716171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617161716171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617161716171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617171716171617161716161717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171717161616171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1616161716161617161716171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617161716171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1617161716171617161716171617000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a090a090c090a0928290a090a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
191a191a191c191a1938391a191a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
