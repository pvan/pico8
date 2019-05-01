pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


alt=16

tw=20    //tile width
th=tw/2  //tile height
htw=tw/2 //half tile width
hth=th/2 //half tile height
xzero=63 //center pixel


function init_tiles()
 tiles={}
 for x=1,20 do
  row={}
  for y=1,20 do
   if rnd(16)<13 then
    row[y]=0
   elseif rnd(16)<15 then
    row[y]=1
   else
    row[y]=2
   end
   if (x==10 and y==10) row[y]=3
  end
  tiles[x]=row
 end
end

function iso2screen(x,y)
 return htw*x-htw*y,hth*x+hth*y
end
function bbtile(sx,sy)
 return flr(sx/tw),flr(sy/th)
end
function bblocal(sx,sy) 
 return sx%tw,sy%th
end
function screen2iso(sx,sy)
 local bx,by=bbtile(sx,sy)
 local lx,ly=bblocal(sx,sy)
 local ix,iy=bx+by,by-bx
 col=sget(104+lx,ly)
 if (col==0) ix-=1
 if (col==1) ix+=1
 if (col==2) iy-=1
 if (col==3) iy+=1
 return ix,iy
end

function _init()
 init_mouse()
 init_tiles()
end

// center on tile 10,10
// cx = -(63-htw)
// cy = 10*th-hth
--cx,cy=-53,42
cx,cy=-(63-htw),5*th-th
function _update()

 mouse_pan()
 
 if (btn(⬅️)) cx-=1
 if (btn(➡️)) cx+=1
 if (btn(⬆️)) cy-=1
 if (btn(⬇️)) cy+=1
 
 msx,msy=get_mouse()
 mwx,mwy=msx+cx,msy+cy
 mix,miy=screen2iso(mwx,mwy)
 
 
end

function _draw()

 cls()
 
 camera(cx,cy)
 
 
 for x,r in pairs(tiles) do
  for y,t in pairs(r) do
   local sx,sy=iso2screen(x,y)
   spr(32+t*3,sx,sy,3,2)
  end
 end

 
 if (outline==nil) outline=true
 if (btnp(🅾️)) outline=not outline
 if outline then
	 for x,r in pairs(tiles) do
	  for y,t in pairs(r) do
	   local sx,sy=iso2screen(x,y)
	   spr(46,sx,sy,2,2)
	  end
	 end
 end
 
 
 local selx,sely=iso2screen(mix,miy)
 palt(3,true)
 spr(192,selx,sely-5,3,3)
 pal()
 
 
 camera()
 color(7)
 spr(16,msx,msy)
 dprint(msx..","..msy)
 
 local r=tiles[mix]
 if (r==nil) r={}
 local t=r[miy]
 if (t==nil) t=0 
 dprint(mix..","..miy.." "..t)
 
 dprint(cx..","..cy)
 

end


function dprint(str,col)
 local cursor_x=peek(0x5f26)
 local cursor_y=peek(0x5f27)
 if (col==nil) col=7
 print(str,cursor_x+1,cursor_y+1,0)
 print(str,cursor_x,cursor_y+1,0)
 print(str,cursor_x,cursor_y,col)
 poke(0x5f27,cursor_y+6)
end
function rect2(x,y,w,h,c)
 rect(x,y,x+w-1,y+h-1,c)
end
function rectfill2(x,y,w,h,c)
 rectfill(x,y,x+w-1,y+h-1,c)
end
-->8
--mouse

--mouse down coords
mdx=0
mdy=0
mdrag = false

-- middle or even right mouse
-- clicks might be iffy on web?
lmwasdown=false
rmwasdown=false
mmwasdown=false

function init_mouse()
 poke(0x5f2d, 1) --enable mouse
end

function get_mouse()
 return stat(32)-1, stat(33)-1
end

function cache_mouse_state()
 --for mouse edge triggers
 lmwasdown=lmouse()
	rmwasdown=rmouse()
	mmwasdown=mmouse()
end

function nmouse() return stat(34)==0 end
function lmouse() return stat(34)==1 end
function rmouse() return stat(34)==2 end
function mmouse() return stat(34)==4 end

function lmup() return not lmouse() and lmwasdown end
function rmup() return not rmouse() and rmwasdown end
function mmup() return not mmouse() and mmwasdown end

function lmdown() return lmouse() and not lmwasdown end
function rmdown() return rmouse() and not rmwasdown end
function mmdown() return mmouse() and not mmwasdown end

--can delete
function debug_print_mouse()
 print(mx)
 print(my)
 print("lmup"..tostr(lmup()))
 print("lmdown"..tostr(lmdown()))
 print("lmouse"..tostr(lmouse()))
end

--camera pan
function mouse_pan()
 mx,my=get_mouse()
 --mwheel drag
 if mmdown() then
  camdrag=true
  camclickworldx=mx+cx
  camclickworldy=my+cy
 end
 if mmouse() then
  if camdrag then
   cx=camclickworldx-mx
   cy=camclickworldy-my
  end
 end
 if mmup() then
  camdrag=false
 end
-- mx-=cx
-- my-=cy
 cache_mouse_state()
end
-->8
--util



function near(num)
 if num>0 then return flr(num+0.5) 
 else return ceil(num-0.5) 
 end
end
__gfx__
0000000000000000bb33333333333333000000000000000000000000111111111100222222222200444444443344444444000000000000007777222222220000
000000000000880033bb3333333333bb000000000000000000000000111111110000002222222200444444333333444444070000000000777777772222220000
00700700800088003333bb333333bb33000000000000000000000000111111000000000022222200444433333333334444000000000077777777777722220000
0007700021122226333333bb33bb3333000000000000000000000000111100000000000000222200443333333333333344070000007777777777777777220000
000770008222882633333333bb33333300000000bb00000000000000110000000000000000002200333333333333333333000000777777777777777777770000
0070070080008800333333bb33bb3333000000bb33bb000000000000000000000000000000000000333333333333333333070000337777777777777777110000
00000000000088003333bb333333bb330000bb333333bb0000000000330000000000000000004400bb33333333333333bb000000333377777777777711110000
000000000000000033bb3333333333bb00bb3333333333bb00000000333300000000000000444400bbbb3333333333bbbb070000333333777777771111110000
7777000000000000bb33333333333333bb33333333333333bb000000333333000000000044444400bbbbbb333333bbbbbb000000333333337777111111110000
700000000000000033bb3333333333bb00bb3333333333bb00000000333333330000004444444400bbbbbbbb33bbbbbbbb070000333333333311111111110000
70000000000000003333bb333333bb330000bb333333bb0000000000333333333300444444444400000000000000000000000000000000000000000000000000
7000000000000000333333bb33bb3333000000bb33bb000000000000000000000000000000000000070707070707070707000000000000000000000000000000
000000000000000033333333bb33333300000000bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000333333bb33bb3333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000003333bb333333bb33000000000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000
000000000000000033bb3333333333bb000000000000000000000002222220000000000000000000000000000000000000000000000000000000000000000000
00000000b33300000000000000000000cccc00000000000000000222222222200000000000000000b33300000000000000000000000000000000000bb0000000
000000b33333330000000000000000cccccccc0000000000000004422222299000000000000000b33333330000000000000000000000000000000bb000000000
0000b33333333333000000000000cccccccccccc000000000000b44442299493000000000000b33377773333000000000000000000000000000bb00000000000
00b33333333333333300000000cccccccccccccccc00000000b33499449499933300000000b333777dd777333300000000000000000000000bb0000000000000
b33333333333333333330000cccccccccccccccccccc0000b33334994499999333330000b333377dddddd773333300000000000000000000b000000000000000
00b33333333333333300000000cccccccccccccccc00000000b33339449993333300000000b333777dd777333300000000000000000000000bb0000000000000
0000b33333333333000000000000cccccccccccc000000000000b33334933333000000000000b33377773333000000000000000000000000000bb00000000000
000000b33333330000000000000000cccccccc0000000000000000b33333330000000000000000b33333330000000000000000000000000000000bb000000000
00000000b33300000000000000000000cccc00000000000000000000b33300000000000000000000b33300000000000000000000000000000000000bb0000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bb0000000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bb000000bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000bb00bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000bb00bb00000000088800660000000088880066000000000000000000000000000000000000000880000000000000088000066600000000000000000000
0000bb000000bb000000008880266000000000882226600000000880000220000000088002200000000888800220000000088880022600000000000000000000
00bb0000000000bb0000000822226000000000222226600000000008822000000000000880000000000008822220000000000882222600000000000000000000
bb000000000000000000080222880000000022222800000000000002288000000000022008800000000002228880000000080222888000000000000000000000
00bb0000000000bb0000082220888000002222288888000000000220000880000002200000000000000222200888800008282220088880000000000000000000
0000bb000000bb000000008000088000000022000088000000022000000000000000000000000000000220000008800000222000000880000000000000000000
000000bb00bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000088000000000000000000000000000
00000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000bb00bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bb000000bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bb0000000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008080000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000002200000088000000110000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000099900000000088222088888000001111101111100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000999990000000000022228800000000001111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000999990000000000088266600000000001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000099900000000008888066600000000111101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008800066600000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000330000000000000000000000000000000033332222222222222222550000000000000000999999999999999555666666666666aa0000000000000000
000000333333000000000000000000000000000033333333222222222222555500000000000000004499999999999555555566666666aaaa0000000000000000
0000333333333300000000000000000000000033333333333322222222555555000000000000000044449999999555555555556666aaaaaa0000000000000000
00333333333333330000000000000000000033333333333333332222555555550000000000000000444444999555555555555555aaaaaaaa0000000000000000
33333333333333333300000000000000003333333333333333333355555555550000000000000000444444bbb555555555555555aaaaaaaa0000000000000000
333333333333333333000000000000003333333333333333333333555555555500000000000000004444bbbbbbb55555555555eeeeaaaaaa0000000000000000
0033333333333333000000000000000044333333333333333333445555555555000000000000000044bbbbbbbbbbb5555555eeeeeeeeaaaa0000000000000000
00003333333333000000000000000000444433333333333333444444555555550000000000000000bbbbbbbbbbbbbbb555eeeeeeeeeeeeaa0000000000000000
00000033333300000000000000000000444444333333333344444444445555550000000000000000bbbbbbbbbbbbbbb999eeeeeeeeeeeecc0000000000000000
0000000033000000000000000000000044444444333333444444444444445555000000000000000066bbbbbbbbbbb9999999eeeeeeeecccc0000000000000000
000000000000000000000000000000004444444444334444444444444444445500000000000000006666bbbbbbb99999999999eeeecccccc0000000000000000
00000000000000000000000000000000444444444455444444444444444444330000000000000000666666bbb999999999999999cccccccc0000000000000000
00000000000000000000000000000000444444445555554444444444444433330000000000000000666666ddd999999000999999cccccccc0000000000000000
000000000000000000000000000000004444445555555555444444444433333300000000000000006666ddddddd99009990099ffffcccccc0000000000000000
0000000000000000000000000000000044445555555555555544444433333333000000000000000066ddddddddd00999999900ffffffcccc0000000000000000
00000000000000000000000000000000445555555555555555554433333333330000000000000000ddddddddd00dddd999ffff00ffffffcc0000000000000000
00000000b33300000000000000000000555555555555555555555533333333330000000000000000ddddddddd00dddd555ffff00ffffffaa0000000000000000
000000b333333300000000000000000000000000000000000000000033333333000000000000000044ddddddd0d00555555500f0ffffaaaa0000000000000000
0000b3333333333300000000000000000000000000000000000000000033333300000000000000004444ddddd0d55005550055f0ffaaaaaa0000000000000000
00b33333333333333300000000000000000000000000000000000000000003330000000000000000444444ddd055555000555550aaaaaaaa0000000000000000
b3333333333333333333000000000000000000000000000000000000000000000000000000000000444444bbb055555505555550aaaaaaaa0000000000000000
00b333333333333333000000000000000000000000000000000000000000000000000000000000004444bbbbbbb55555055555eeeeaaaaaa0000000000000000
0000b33333333333000000000000000000000000000000000000000000000000000000000000000044bbbbbbbbbbb5550555eeeeeeeeaaaa0000000000000000
000000b3333333000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbb505eeeeeeeeeeeeaa0000000000000000
00000000b33300000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbbbbbbb999eeeeeeeeeeeecc0000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000066bbbbbbbbbbb9999999eeeeeeeecccc0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006666bbbbbbb99999999999eeeecccccc0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000666666bbb999999999999999cccccccc0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000666666ddd999999999999999cccccccc0000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000006666ddddddd99999999999ffffcccccc0000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000066ddddddddddd9999999ffffffffcccc0000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddddddddddd999ffffffffffffcc0000000000000000
000000000000000000000000000000000000000000000000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb33000000004444444444334444444444444444443300000000
000000007777000000000000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb3333000000004444444433333344444444444444333300000000
000000770000770000000000000000000000000000000000bbbbbb3333333333bbbbbbbbbb333333000000004444443333333333444444444433333300000000
000077000000007700000000000000000000000000000000bbbb33333333333333bbbbbb33333333000000004444333333333333334444443333333300000000
007700000000000077000000000000000000000000000000bb333333333333333333bb3333333333000000004433333333333333333344333333333300000000
7700000033330000007700000000000000000000000000003333333333333333333333333333333300000000bb333333333333333333bb333333333300000000
707700333333330077070000000000000000000000000000bb333333333333333333bb333333333300000000bbbb33333333333333bbbbbb3333333300000000
700077333333337700070000000000000000000000000000bbbb33333333333333bbbbbb3333333300000000bbbbbb3333333333bbbbbbbbbb33333300000000
703333773333773333070000000000000000000000000000bbbbbb3333333333bbbbbbbbbb33333300000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000
733333337777333333370000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb3300000000
003333333373333333000000000000000000000000000000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb3300000000bbbbbbbbbb99bbbbbbbbbbbbbbbbbb3300000000
000033333373333300000000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000bbbbbbbb999999bbbbbbbbbbbbbb333300000000
000000333373330000000000000000000000000000000000bbbbbb3333333333bbbbbbbbbb33333300000000bbbbbb9999999999bbbbbbbbbb33333300000000
000000003373000000000000000000000000000000000000bbbb33333333333333bbbbbb3333333300000000bbbb99999999999999bbbbbb3333333300000000
000000000000000000000000000000000000000000000000bb333333333333333333bb333333333300000000bb999999999999999999bb333333333300000000
0000000000000000000000000000000000000000000000003333333333333333333333333333333300000000dd99999999999999999988333333333300000000
000000000000000000000000000000000000000000000000bb333333333333333333bb333333333300000000dddd999999999999998888883333333300000000
000000000000000000000000000000000000000000000000bbbb33333333333333bbbbbb3333333300000000dddddd9999999999888888888833333300000000
000000000000000000000000000000000000000000000000bbbbbb3333333333bbbbbbbbbb33333300000000dddddddd99999988888888888888333300000000
000000000000000000000000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000dddddddddd998888888888888888883300000000
000000000000000000000000000000000000000000000000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb3300000000dddddddddd338888888888888888883300000000
000000000000000000000000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000dddddddd33333388888888888888333300000000
000000000000000000000000000000000000000000000000bbbbbb3333333333bbbbbbbbbb33333300000000dddddd3333333333888888888833333300000000
000000000000000000000000000000000000000000000000bbbb33333333333333bbbbbb3333333300000000dddd333333333333338888883333333300000000
000000000000000000000000000000000000000000000000bb333333333333333333bb333333333300000000dd33333333333333333388333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000