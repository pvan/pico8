pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

px,py,pd,pa=10,10,0,0

ex,ey,ed,ea=15,15,0,0

alt=0   //0-buz, 1-low, 2-mid, 3-high
lvlh=10 //alt per level
buzh=3  //alt at lowest


xsteps={1,0,-1,0}
ysteps={0,1,0,-1}


--tw=20    //tile width
--th=tw/2  //tile height
--htw=tw/2 //half tile width
--hth=th/2 //half tile height
--xzero=63 //center pixel

tw=16    //tile width
th=11    //tile height
--htw=tw/2 //half tile width
--hth=th/2 //half tile height
--xzero=63 //center pixel

xstepxo=7
xstepyo=7
ystepxo=-10
ystepyo=5


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
 --return htw*x-htw*y,hth*x+hth*y
 return xstepxo*x+ystepxo*y, 
        xstepyo*x+ystepyo*y
end
--function bbtile(sx,sy)
-- return flr(sx/tw),flr(sy/th)
--end
--function bblocal(sx,sy) 
-- return sx%tw,sy%th
--end
function screen2iso(sx,sy)

-- local xx=xstepxo
-- local xy=xstepyo
-- local yx=ystepxo
-- local yy=ystepyo
-- local ix=(yy*sx-yx*sy)/
--           (1+yx*xx)
-- local iy=(sy-xy*ix)/yy
-- return flr(ix),flr(iy)

-- local xx=-xstepxo
-- local xy=xstepyo
-- local yx=-ystepxo
-- local yy=ystepyo
-- local ix=(yx*sy+yy*sx)/
--          (xy*yx-xx*yy)
-- local iy=(xy*sx+xx*sy)/
--          (yx*xy-yy*xx)
-- return flr(ix),-flr(iy)

 --thank you wolfram alpha
 --for fixing my algebra
 local xx=xstepxo
 local xy=xstepyo
 local yx=ystepxo
 local yy=ystepyo
 local ix=(yx*sy-yy*sx)/
          (xy*yx-xx*yy)
 local iy=(xy*sx-xx*sy)/
          (yx*xy-yy*xx)
 return flr(ix),flr(iy)

-- local bx,by=bbtile(sx,sy)
-- local lx,ly=bblocal(sx,sy)
-- local ix,iy=bx+by,by-bx
-- --160 was 104
-- col=sget(160+lx,ly)
-- if (col==0) ix-=1
-- if (col==1) ix+=1
-- if (col==2) iy-=1
-- if (col==3) iy+=1
-- return ix,iy
end

function _init()
 init_mouse()
 init_tiles()
end

// center on tile 10,10
// cx = -(63-htw)
// cy = 10*th-hth
--cx,cy=-53,42
cx,cy=-(63-tw/2),5*th-th
function _update()

 mouse_pan()
 
 if btn(❎) then
  if (btnp(⬆️)) pa+=1
  if (btnp(⬇️)) pa-=1
  if btn(🅾️) then 
	  if (btnp(⬆️)) alt+=1
	  if (btnp(⬇️)) alt-=1
  end
 elseif btn(🅾️) then
  if (btnp(⬆️)) lvlh+=1
  if (btnp(⬇️)) lvlh-=1
 else
  if (btnp(⬆️)) px+=xsteps[pd+1] py+=ysteps[pd+1]
  if (btnp(⬇️)) px-=1
  if (btnp(⬅️)) pd=(pd+3)%4
  if (btnp(➡️)) pd=(pd+1)%4
  if band(btnp(),0b1111)!=0 then
   local ai=flr(rnd(5))
   if (ai==0) ex+=xsteps[ed+1] ey+=ysteps[ed+1]
   if (ai==1) ed=(ed+3)%4
   if (ai==2) ed=(ed+1)%4
   if (ai==3) ea+=1
   if (ai==4) ea-=1
   ea=min(max(ea,0),3)
  end
 end
 
 
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
   --spr(32+t*3,sx,sy,3,2)
   
   --the offset amouts
   --from tile 0,0 to 
   --draw point ofsprite
   sx+=ystepxo --tile 0,0 -> spr dwg pt
   spr(128+t*2,sx,sy,2,2)
  end
 end

 
 if (outline==nil) outline=true
 if (btnp(🅾️)) outline=not outline
 if outline then
	 for x,r in pairs(tiles) do
	  for y,t in pairs(r) do
	   local sx,sy=iso2screen(x,y)
	   --spr(46,sx,sy,2,2)
    sx+=ystepxo --tile 0,0 -> spr dwg pt
	   spr(162,sx,sy,2,2)
	  end
	 end
 end
 
 
-- --higher levels
-- for x,r in pairs(tiles) do
--  for y,t in pairs(r) do
--   local sx,sy=iso2screen(x,y)
--   pal(11,7)
--   spr(224,sx,sy-alt,2,2)
--   pal()
--  end
-- end
 
 --selection icon (bg)
 local selx,sely=iso2screen(mix,miy)
 selx+=ystepxo --tile 0,0 -> spr dwg pt
 if mix==px and miy==py then
  pal(12,7)
  spr(35,selx,sely-pa*10,3,2)
  pal()
  --192
  spr(164,selx,sely-pa*10-8,3,2)
 else
  spr(164,selx,sely,3,2)
 end
 if mix==ex and miy==ey then
  pal(12,7)
  spr(35,selx,sely-ea*10,3,2)
  pal()
  spr(164,selx,sely-ea*10-8,3,2)
 else
  spr(164,selx,sely,3,2)
 end
 
 
 --planes
 draw_plane(6,5,0,1, 12,0)
 draw_plane(5,5,0,1, 12,0)
 draw_plane(5,6,0,1, 12,0)
 draw_plane(6,6,0,1, 12,0)
 draw_plane(7,6,0,1, 12,0)
 draw_plane(7,7,0,1, 12,0)
 
 draw_plane(ex,ey,ed,ea,12,0)
 
 draw_plane(px,py,pd,pa)
 
 
 --selection icon (fg)
 if mix==px and miy==py then
--  spr(224,selx,sely-8-pa*10,3,2)
  for i=0,pa do
   spr(224,selx,sely-8-i*10,3,2)
  end
 end
 if mix==ex and miy==ey then
--  spr(224,selx,sely-8-pa*10,3,2)
  for i=0,ea do
   spr(224,selx,sely-8-i*10,3,2)
  end
 end
 
 
 
  
-- palt(3,true)
-- for i=0,alt do
--  spr(195,selx,sely-9-i*10,3,3)
-- end 
-- pal()
 

 -- quilt debug
 --(test tile of every pixel)
 if btn(❎) then
	 for x=-32,32 do
	  for y=0,64 do
	   local tx,ty=screen2iso(x,y)
	   srand(tx+ty*100)
	--   local bbx,bby=bbtile(x,y)
	--   srand(bbx+bby*100)
	   pset(x,y,rnd(16))
	  end
	 end
 end
 
 
 
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
 
 dprint("alt "..alt)
 dprint("lvlh "..lvlh)

 

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
-->8
--player



function draw_plane(ix,iy,d,a,c1,c2)

 if (c1==nil) c1=2
 if (c2==nil) c2=8
 pal(2,c1)
 pal(8,c2)

 local sx,sy=iso2screen(ix,iy)
 sx+=ystepxo --tile 0,0 -> spr dwg pt
 
 --sprite base pos
-- local bx,by=sx+3,sy-3
 local bx,by=sx+1,sy+1
 local h=3+a*lvlh
 
 --center of sprite pos
 local midx,midy=bx+7,by+7
 
 spr(100+d*2,bx,by,2,2)
 
 if a>0 then
	 for i=1,h,2 do
	  pset(midx,midy-i,10)
	 end
	 for i=1,a-1 do
	  circfill(midx,midy-i*lvlh,1,10)
	 end
 end
 
 spr(68+d*2,bx,by-h,2,2)

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
000000bb00bb00000000000000000000000800000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000
00000000bb0000000000000000000000000808000000000000000000008080000000000000000000000000000000000000000000000000000000000000000000
000000bb00bb00000000088800660000000220000008800000088000000220000000666000088000000880000666000000000000000000000000000000000000
0000bb000000bb000000008880266000008822208888800000088888022288000000622008888000000888800226000000000000000000000000000000000000
00bb0000000000bb0000000822226000000002222880000000000882222000000000622228800000000008822226000000000000000000000000000000000000
bb000000000000000000080222880000000008826660000000000666288000000000088822208000000802228880000000000000000000000000000000000000
00bb0000000000bb0000082220888000000888806660000000000666088880000008888002228280082822200888800000000000000000000000000000000000
0000bb000000bb000000008000088000000880006660000000000666000880000008800000022200002220000008800000000000000000000000000000000000
000000bb00bb00000000000000000000000000000000000000000000000000000000000000088000000880000000000000000000000000000000000000000000
00000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000bb00bb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000bb000000bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bb0000000000bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000000000000001000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008080000000000000110000001100000110000001100000000000000110000000110000000000000000000000000000000000000000000
00000000000000000002200000088000001111101111100000111110111110000000011011110000000111101100000000000000000000000008800000000000
00000099900000000088222088888000000001111110000000001111110000000000011111000000000001111100000000000000000000000008888002200000
00000999990000000000022228800000000001111100000000000111110000000000111111000000000001111110000000000000000000000000088222200000
00000999990000000000088266600000000111101100000000000110111100000011111011111000001111101111100000000000000000000000022288800000
00000099900000000008888066600000000110000000000000000000001100000011000000110000000110000001100000000000000000000002222008888000
00000000000000000008800066600000000000000000000000000000000000000000000001000000000001000000000000000000000000000002200000088000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000b000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000030000000000000000000000
0000000b333000000000000cccc00000000000000000000000000000000000000000000000000000000000000000000000000003333000000000000000000000
00000b33333b000000000ccccccc0000000000044000000000000000000000000000000000000000000000000000000000000333333300000000000000000000
000b333333333000000cccccccccc000000004444400000000000000000000000000000000000000000000000000000000033333333330000000000000000000
0b33333333333b000ccccccccccccc00000002444440000000000777700000000000000000000000000000000000000003333333333333000000000000000000
3333333333333330ccccccccccccccc000011222449000000000777d770000000000000000000000000000000000000033333333333333300000000000000000
033333333333333b0ccccccccccccccc00111242999000000000077d777000000000000000000000000000000000000003333333333333330000000000000000
003333333333333300cccccccccccccc000111429990000000000077770000000000000000000000000000000000000000333333333333330000000000000000
0003333333333300000ccccccccccc00000011129000000000000000000000000000000000000000000000000000000000033333333333000000000000000000
00003333333300000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000003333333300000000000000000000
000003333300000000000ccccc000000000000000000000000000000000000000000000000000000000000000000000000000333330000000000000000000000
0000003300000000000000cc00000000000000000000000000000000000000000000000000000000000000000000000000000033000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007111111000000000b000000000000000700000000000000000000000000000000000000000000000000000000000000bb0000000000000000000000
00000007777111110000000bb0b000000000000700000000000000000000000000000000000000000000000000000000000000bb00b000000000000000000000
000007777777111100000bb0000b000000000700000700000000000000000000000000000000000000000000000000000000bb00000b00000000000000000000
0007777777777111000bb0000000b000000700000000000000000000000000000000000000000000000000000000000000bb00000000b0000000000000000000
07777777777777110bb0000000000b000700000000000700000000000000000000000000000000000000000000000000bb00000000000b000000000000000000
7777777777777771b0000000000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000b00000000000000000
2777777777777777000000000000000b0700000000000007000000000000000000000000000000000000000000000000000000000000000b0000000000000000
22777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22277777777777330000000000000000000700000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000
22227777777733330000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222777773333330000000000000000000007000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222277333333330000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddddddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000707000000000000000000000000000000000000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb33000000004444444444334444444444444444443300000000
000000070000070000000000000000000707000000000000bbbbbbbb333333bbbbbbbbbbbbbb3333000000004444444433333344444444444444333300000000
000007000000000700000000000000070000070000000000bbbbbb3333333333bbbbbbbbbb333333000000004444443333333333444444444433333300000000
000700000000000007000000000007000000000700000000bbbb33333333333333bbbbbb33333333000000004444333333333333334444443333333300000000
070000000000000000000000000700000000000007000000bb333333333333333333bb3333333333000000004433333333333333333344333333333300000000
0007000000000000070000000700000000000000000000003333333333333333333333333333333300000000bb333333333333333333bb333333333300000000
000007000000000700000000700700000000000007070000bb333333333333333333bb333333333300000000bbbb33333333333333bbbbbb3333333300000000
000000070000070000000000000007000000000700000000bbbb33333333333333bbbbbb3333333300000000bbbbbb3333333333bbbbbbbbbb33333300000000
000000000707000000000000700000070000070000070000bbbbbb3333333333bbbbbbbbbb33333300000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000
000000000000000000000000000000000707000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb3300000000
000000000000000000000000700000000070000000070000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb3300000000bbbbbbbbbb99bbbbbbbbbbbbbbbbbb3300000000
000000000000000000000000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000bbbbbbbb999999bbbbbbbbbbbbbb333300000000
000000000000000000000000700000000070000000070000bbbbbb3333333333bbbbbbbbbb33333300000000bbbbbb9999999999bbbbbbbbbb33333300000000
000000000000000000000000000000000000000000000000bbbb33333333333333bbbbbb3333333300000000bbbb99999999999999bbbbbb3333333300000000
000000000000000000000000700000000070000000070000bb333333333333333333bb333333333300000000bb999999999999999999bb333333333300000000
0000000000000000000000000000000000000000000000003333333333333333333333333333333300000000dd99999999999999999988333333333300000000
000000000000000000000000000000000070000000000000bb333333333333333333bb333333333300000000dddd999999999999998888883333333300000000
000000000000000000000000000000000000000000000000bbbb33333333333333bbbbbb3333333300000000dddddd9999999999888888888833333300000000
000000000000000000000000000000000070000000000000bbbbbb3333333333bbbbbbbbbb33333300000000dddddddd99999988888888888888333300000000
000000000000000000000000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000dddddddddd998888888888888888883300000000
070000000000000000070000000000000000000000000000bbbbbbbbbb33bbbbbbbbbbbbbbbbbb3300000000dddddddddd338888888888888888883300000000
000000000000000000000000000000000000000000000000bbbbbbbb333333bbbbbbbbbbbbbb333300000000dddddddd33333388888888888888333300000000
070000000000000000070000000000000000000000000000bbbbbb3333333333bbbbbbbbbb33333300000000dddddd3333333333888888888833333300000000
000000000000000000000000000000000000000000000000bbbb33333333333333bbbbbb3333333300000000dddd333333333333338888883333333300000000
070000000000000000070000000000000000000000000000bb333333333333333333bb333333333300000000dd33333333333333333388333333333300000000
00000000007000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
07000000000000000007000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000007000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000007000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000000000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
00000000007000000000000000000000000000000000000033333333333333333333333333333333000000003333333333333333333333333333333300000000
