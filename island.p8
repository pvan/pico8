pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


xsteps={1,0,-1,0}
ysteps={0,1,0,-1}



function _init()
 srand(0)
 init_mouse()
 init_tiles()
end


// center somewhere in middle
cx,cy=-(63-8),5*8-8


function _update()

 mouse_pan()
 
 
 update_player()
 
 
 if (outline==nil) outline=false
 if (btnp(🅾️)) outline=not outline

-- cx,cy=px-64,py-64

 msx,msy=get_mouse()
 mwx,mwy=msx+cx,msy+cy
 mix,miy=world2iso(mwx,mwy)
 
 
end

function _draw()

 cls()
  
 
 camera(cx,cy)
 
 
-- mix,miy=ptx,pty
 
 draw_terrain()
 
 
-- --selection
-- hlx,hly=iso2world(ntx,nty)
-- ts=tget(ntx,nty) 
-- palt(1,true)
-- palt(2,true)
-- palt(3,true)
-- pal(7,10)
-- spr(68,hlx,hly-#ts*8,4,2)
-- pal()
-- palt(1,false)
-- palt(2,false)
--	palt(3,false)
--   

 
-- local pwx,pwy=pgroundpos()
-- local hotspotsx={-2,2}
-- local hotspotsy={-4,0}
-- for j=1,#hotspotsy do
--  local hy=hotspotsy[j]
--  for i=1,#hotspotsx do
--   local hx = hotspotsx[i]
--    pset(pwx+hx,pwy+hy,0)
----    pset(px+hx,py+hy,0)
--  end
-- end
-- pset(pwx,pwy,7)
---- pset(px,py,7)
 
 
 
 camera()
 color(7)
 

-- -- quilt debug
-- --(test tile of every pixel)
-- if btn(🅾️) then
--  for x=-32,32 do
--   for y=0,64 do
--    local tx,ty=world2isofloat(x+cx,y+cy)
--    tx,ty=flr(tx),flr(ty)
--    srand(tx+ty*100)
--    pset(x,y,rnd(16))
--   end
--  end
-- end
-- if btn(❎) then
--  for x=-32,32 do
--   for y=0,64 do
--    local tx,ty=world2iso(x+cx,y+cy)
--    srand(tx+ty*100)
--    pset(x,y,rnd(16))
--   end
--  end
-- end
 
 
 print2("cpu:"..stat(1))
 
 spr(16,msx,msy)
 print2(msx..","..msy)
 
 local mts=tget(mix,miy)
 print2(mix..","..miy.." h:"..#mts)
 
 print2("c:"..cx..","..cy)


-- pwx,pwy=pgroundpos()
-- tempx,tempy=isofloat2world(pwfx,pwfy)
-- print2(pwx..","..pwy)
-- print2(tempx..","..tempy)


 if (not allowx) xstep=0
 if (not allowy) ystep=0
 print2(xstep)
 print2(ystep)
 
 --check isofloat conversions 
-- print2("morg:"..mwx..","..mwy) 
-- local mwfx,mwfy=world2isofloat(mwx,mwy)
-- print2("mwf:"..mwfx..","..mwfy)
-- local backx,backy=isofloat2world(mwfx,mwfy)
-- print2("bck:"..backx..","..backy)


end


function print2(str,col)
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


function rndbw(l,h)
 return flr(rnd(h+1-l))+l
end

function near(num)
 if num>0 then return flr(num+0.5) 
 else return ceil(num-0.5) 
 end
end
-->8
--tiles



blocks={
128,  //1 water
132,  //2 grass
136,  //3 dirt
140,  //4 sand
}


tw=32    //tile width
th=tw/2  //tile height
htw=tw/2 //half tile width
hth=th/2 //half tile height


function init_tiles()
 // each tile is a list of blocks
 // ordered top to bottom
 // eg {1,2,3} 1 is topmost block
 tiles={}
 for x=1,20 do
  row={}
  for y=1,20 do
   row[y]={2}
   if (rnd(20)<2) row[y]={3}
   if (rnd(20)<1) row[y]={4}
   if (rnd(10)<2) add(row[y],rndbw(3,4))
   if (rnd(50)<2) add(row[y],rndbw(3,4)) add(row[y],rndbw(3,4))
   if (x==10 and y==10) row[y]={4,4,4,4}
  end
  tiles[x]=row
 end
 
 --add extra dirt layer
 for row in all(tiles) do
  for ts in all(row) do
   add(ts,3)
  end
 end
 
end


function tget(x,y)
 local row=tiles[x]
 if (row==nil) return {}
 if (row[y]==nil) return {}
 return row[y] 
end


function iso2world(x,y)
 return htw*x-htw*y,hth*x+hth*y
end
function bbtile(sx,sy)
 return flr(sx/tw),flr(sy/th)
end
function bblocal(sx,sy) 
 return sx%tw,sy%th
end
function world2iso(sx,sy)
 local bx,by=bbtile(sx,sy)
 local lx,ly=bblocal(sx,sy)
 local ix,iy=bx+by,by-bx
 col=sget(32+lx,32+ly)--pixels
 if (col==0) ix-=1
 if (col==1) ix+=1
 if (col==2) iy-=1
 if (col==3) iy+=1
 return ix,iy
end

function world2isofloat(wx,wy)
 wx-=htw
 wx+=0.001 --kind of a hack to fix edge fill conventions
 local isox=(wx/htw+wy/hth)/2
 local isoy=(wy/hth-wx/htw)/2
 return isox,isoy
end
function isofloat2world(fx,fy)
 local wx=(fx-fy)*htw
 local wy=(fx+fy)*hth
 --undo our edge fill hack and round near() to stick with integer coords
 return (wx+htw-0.001),(wy)
end


--uses (at least):
--camera cx,cy
--mouse tile mix,miy (for selection)
function draw_terrain()

 local selx,sely=iso2world(mix,miy)
 
 --local ptx,pty=world2iso(px,py)
 
 local tlx,tly=world2iso(cx,cy)
 local countx=128/tw+1 //+1 to avoid calc'ing exact row counts
 local county=(128/th+1)*2 //*2 since we zig zag down the column
 county+=5 //need more extra y the taller our terrain gets (add max height tiles can be should work)
 local rx,ry=tlx-1,tly //start one tile to the tl
 for y=0,county do 
	 for x=0,countx do
	  
	  local tx,ty=rx+x,ry-x
	  local sx,sy=iso2world(tx,ty)
	  
	  local ts=tget(tx,ty)
	  
	  if #ts==0 then
 	  --water
 	  spr(blocks[1],sx,sy,4,2)
 	 else
		  local lts=tget(tx,ty+1)
		  local rts=tget(tx+1,ty)
		  local count=max(#ts-#lts,#ts-#rts)
		  count=max(count+1,1)
		  for ti=count,1,-1 do
			  local t=ts[ti]
			  local h=#ts-ti+1
		   spr(blocks[t],sx,sy-h*8,4,4)
	   end
   end

   --selection
   if tx==mix and ty==miy then 
    palt(1,true)
    palt(2,true)
    palt(3,true)
    spr(68,selx,sely-#ts*8,4,2)
    palt(1,false)
    palt(2,false)
    palt(3,false)
    mts=ts --just for print debugging
   end
   
   --player
   if tx==ptx and ty==pty then
    draw_player(tx,ty)
   end
  
  end
  --zig zag down left column
  --which dir we start going
  --depends on if our tl tile
  --is halfway on or off screen
  --but instead of dealing with that
  --lets just iterate 1 extra row/col
  if y%2==1 then ry+=1
  else rx+=1 end
 end
 
 
 --selection icon (bg)
	local ts=tget(mix,miy)
 spr(100,selx,sely-#ts*8,4,2)
--  pal(7,14)
-- 	spr(100,selx,sely-t*8,4,2)
--  pal()
 
 
end
-->8
--player



--in iso coordinates
truepx=10
truepy=10


function pgroundpos()
 local ptx,pty=world2iso(px,py) 
 local ts=tget(ptx,pty)
 return px,py-#ts*hth
end


function update_player()

 local speed=2
 if (btn(🅾️)) speed=1
 
 
 --direction in screen coords
 --[[
 local pdx,pdy=0,0
 if (btn(⬆️)) pdy=-1
 if (btn(⬇️)) pdy=1
 if (btn(⬅️)) pdx=-2
 if (btn(➡️)) pdx=2
 
	xstep,ystep=0,0
	if pdx!=0 or pdy!=0 then
	 local mag=sqrt(pdx*pdx+pdy*pdy)
	 pdx/=mag
	 pdy/=mag
	 
	 xstep,ystep=pdx*speed,pdy*speed
	 spx,spy=isofloat2world(truepx,truepy)
	 npx,npy=spx+xstep,spy+ystep
	 local nwfx,nwfy=world2isofloat(npx,npy)
  local wfdx,wfdy=nwfx-truepx,nwfy-truepy
  xstep,ystep=wfdx,wfdy --converted to isofloat coords
	
	end
 ]]
 

 --direction in iso coords
 local truedx,truedy=0,0
 if (btn(⬆️)) truedx-=1 truedy-=1
 if (btn(⬇️)) truedx+=1 truedy+=1
 if (btn(⬅️)) truedx-=1 truedy+=1
 if (btn(➡️)) truedx+=1 truedy-=1
 xstep,ystep=0,0
	if truedx!=0 or truedy!=0 then
	 local mag=sqrt(truedx*truedx+truedy*truedy)
	 truedx/=mag
	 truedy/=mag
	 xstep,ystep=truedx*speed/16,truedy*speed/16
	end
	

 -- collisiton detection here 
 allowx=true
 allowy=true
 pwfx,pwfy=truepx,truepy
 ptx,pty=flr(pwfx),flr(pwfy)
 ts=tget(ptx,pty)
 
-- hotspotsx={-4/16,1/16}
-- hotspotsy={-4/16,1/16}
-- hotspotsx={-2/16,2/16}
-- hotspotsy={-4/16,2/16}
 hotspotsx={0}
 hotspotsy={0}
 for j=1,#hotspotsy do
  local hy = hotspotsy[j]
  for i=1,#hotspotsx do
   local hx = hotspotsx[i]

		 local nwfx,nwfy=pwfx+hx+xstep,pwfy+hy+ystep
		 ntx,nty=flr(nwfx),flr(nwfy)
		 
		 local xts=tget(ntx,pty)
		 local yts=tget(ptx,nty)
		 if (#xts>#ts) allowx=false 
		 if (#yts>#ts) allowy=false
		 
  end
 end
 
 
 --if we run into an exact
 --outside corner, both the
 --the x,y separate checks
 --might pass the check ok (allowx,y true)
 --even though the combined 
 --new x,y would be impassable (allowx,y false)
 --in that case, we just 
 --pick one direction to slide 
-- if allowx and allowy then
--  bts=tget(ntx,nty)
--  if (#bts>#ts) allowx=false 
-- end
 

	if (allowx) truepx+=xstep
	if (allowy) truepy+=ystep
	 
	 
end



function draw_player(tx,ty)

 local psx,psy=isofloat2world(truepx,truepy)
 ts=tget(flr(truepx),flr(truepy))
 pwx,pwy=psx,psy-#ts*8
 pset(pwx,pwy,0)
 --keeping the px,py point
 --near the bottom so we don't
 --overdraw the player with the next tile
 local ofx,ofy=3,4
 spr(32,pwx-ofx,pwy-ofy,1,1)
 
 ofx+=5  --offset from shadow
 ofy+=12 --to body
 spr(1,pwx-ofx,pwy-ofy,2,2)


 for j=1,#hotspotsy do
  local hy = hotspotsy[j]
  for i=1,#hotspotsx do
   local hx = hotspotsx[i]
   
   local psx,psy=isofloat2world(truepx+hx,truepy+hy)
   pset(psx,psy-#ts*8,2)
  end
 end

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000003bb300000000000000000000000000003bb300000000000000
0070070000000dddddd0000000000000000000000000000000000000000000000000000000003bbbbbb30000000000000000000000003bbbbbb3000000000000
0007700000000ddddddd0000000000000000000000000000000000000000000000000000003bbbbbbbbbb3000000000000000000003bbbbbbbbbb30000000000
00077000000066ddddddd0000000000000000000000000000000000000000000000000003bbbbbbbbb3bbbb300000000000000003bbbbbbbbbbbbbb300000000
0070070000006666dddd600000000000000000000000000000000000000000000000003bbbbbbbbbb13bbbbbb30000000000003bbbbbbbbbbbbbbbbbb3000000
00000000000002266dd66000000000000000000000000000000000000000000000003bbbbbbbb3bbbbbbbbbbbbb3000000003bbbbbbbbbbbbbbbbbbbbbb30000
000000000000622266d622000000000000000000000000000000000000000000003bbbbbb3bb13bbbbbbbbb3bbbbb300003bbbbbbbbbbbbbbbbbbbbbbbbbb300
77770000000ff22666666200000000000000000000000000000000000000000013bbbbbb13bbbbbbbb3bbb13bbbbbb1313bbbbbbbbbbbbbbbbbbbbbbbbbbbbb3
70000000006ff2666dd6660000000000000000000000000000000000000000001313bbbbbbbbbbbbb13bbbbbbbbb13131313bbbbbbbbbbbbbbbbbbbbbbbbb3b3
7000000000666666dddd66000000000000000000000000000000000000000000111313bbbbbbbbbbbbbbbbbbbb131333111313bbbbbbbbbbbbbbbbbbbbb3b333
700000000006666ddddd6600000000000000000000000000000000000000000011111313bbbbbbb3bbbbbbbb1313333311111313bbbbbbbbbbbbbbbbb3b33333
000000000000666ddddd600000000000000000000000000000000000000000001111111313bbbb13bbbbbb13133331111111111313bbbbbbbbbbbbb3b3333111
00000000000011dddddd00000000000000000000000000000000000000000000111111111313bbbbbbbb131333331444111111111313bbbbbbbbb3b333331444
000000000000010000100000000000000000000000000000000000000000000055551111111313bbbb1313333331499955551111111313bbbbb3b33333314999
0000000000000000000000000000000000000000000000000000000000000000444451111111131313133333331499994444511111111313b3b3333333149999
0111110000000000000000000000000000000000000000000000000000000000455445111111111313331111114995591444451111111113b333111111499994
11111110000000000000000000000000000000000000000000000000000000004114445555511111333144444499944944144455555111113331444444999499
11111110000000000000000000000000000000000000000000000000000000004444444444451111331499999999999944441444444511113314999999949999
01111100000000000000000000000000000000000000000000000000000000004444444554445111114999559999999944444414444451111149999994999999
00000000000000000000000000000000000000000000000000000000000000004444444114444555449999449999999944444444144445554499999499999999
00000000000000000000000000000000000000000000000000000000000000004444444444444444499999999999999944444444441444449999949999999999
00000000000000000000000000000000000000000000000000000000000000004444444444444449999999999999999944444444444414449994999999999999
00000000000000000000000000000000000000000000000000000000000000004444444444444444499999999999999944444444444444149499999999999999
00000000000000000000000000000000000000000000000000000000000000004444444444444449999999999999999944444444444444449999999999999999
00000000000000000000000000000000000000000000000000000000000000000044444444444444499999999999990000444444444444449999999999999900
00000000000000000000000000000000000000000000000000000000000000000000444444444449999999999999000000004444444444449999999999990000
00000000000000000000000000000000000000000000000000000000000000000000004444444444499999999900000000000044444444449999999999000000
00000000000000000000000000000000000000000000000000000000000000000000000044444449999999990000000000000000444444449999999900000000
00000000000000000000000000000000000000000000000000000000000000000000000000444444499999000000000000000000004444449999990000000000
00000000000000000000000000000000000000000000000000000000000000000000000000004449999900000000000000000000000044449999000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000044490000000000000000000000000000449900000000000000
00000000000000000000000000000000000000000000000022222222222222220000000000000000000000000000000000000000000000000000000000000000
00000000000000444400000000000000000000000000007777222222222222220000000000000044440000000000000000000000000000333300000000000000
00000000000044444444000000000000000000000000777777772222222222220000000000004444444400000000000000000000000033333333000000000000
00000000004444444444440000000000000000000077777777777722222222220000000000444444444444000000000000000000003333333333330000000000
00000000444444444444444400000000000000007777777777777777222222220000000044444444444444440000000000000000333333333333333300000000
00000044444444444444444444000000000000777777777777777777772222220000004444444444444444444400000000000033333333333333333333000000
00004444444444444444444444440000000077777777777777777777777722220000444444444444444444444444000000003333333333333333333333330000
00444444444444444444444444444400007777777777777777777777777777220044444444444444444444444444440000333333333333333333333333333300
4444444444444444444444444444444477777777777777777777777777777777444444444444444444444444444444441333333333333333333333333333333b
55444444444444444444444444444499337777777777777777777777777777115544444444444444444444444444449913133333333333333333333333333b3b
555544444444444444444444444499993333777777777777777777777777111155554444444444444444444444449999111313333333333333333333333b3bbb
5555554444444444444444444499999933333377777777777777777777111111555555444444444444444444449999991111131333333333333333333b3bbbbb
55555555444444444444444499999999333333337777777777777777111111115555555544444444444444449999999911111113133333333333333b3bbbb333
555555555544444444444499999999993333333333777777777777111111111155555555554444444444449999999999111111111313333333333b3bbbbb3444
5555555555554444444499999999999933333333333377777777111111111111555555555555444444449999999999995555111111131333333b3bbbbbb34999
55555555555555444499999999999999333333333333337777111111111111115555555555555544449999999999999944445111111113133b3bbbbbbb349999
55555555555555559999999999999999000000000000000770000000000000005555555555555555999999999999999914444511111111133bbb333333499994
5555555555555555999999999999999900000000000007000070000000000000005555555555555599999999999999000014445555511111bbb3444444999400
5555555555555555999999999999999900000000000700000000700000000000000055555555555599999999999900000000144444451111bb34999999940000
55555555555555559999999999999999000000000700000000000070000000000000005555555555999999999900000000000014444451113349999994000000
55555555555555559999999999999999000000070000000000000000700000000000000055555555999999990000000000000000144445554499999400000000
55555555555555559999999999999999000007000000000000000000007000000000000000555555999999000000000000000000001444449999940000000000
55555555555555559999999999999999000700000000000000000000000070000000000000005555999900000000000000000000000014449994000000000000
55555555555555559999999999999999070000000000000000000000000000700000000000000055990000000000000000000000000000149400000000000000
55555555555555559999999999999999070000000000000000000000000000701100000000000001000000000000001100000000000000009999999999999977
00555555555555559999999999999900000700000000000000000000000070000011000000000001000000000000110000000000000000009999999999997700
00005555555555559999999999990000000007000000000000000000007000000000110000000001000000000011000000000000000000009999999999770000
00000055555555559999999999000000000000070000000000000000700000000000001100000001000000001100000000000000000000009999999977000000
00000000555555559999999900000000000000000700000000000070000000000000000011000001000000110000000000000000000000009999997700000000
00000000005555559999990000000000000000000007000000007000000000000000000000110001000011000000000000000000000000009999770000000000
00000000000055559999000000000000000000000000070000700000000000000000000000001101001100000000000000000000000000009977000000000000
00000000000000559900000000000000000000000000000770000000000000000000000000000011110000000000000000000000000000007700000000000000
00000000000000111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000011cccc1100000000000000000000000000b3b30000000000000000000000000000599400000000000000000000000000004ff900000000000000
000000000011cccccccc110000000000000000000000b3bbbbb3000000000000000000000000599999940000000000000000000000004ffffff9000000000000
0000000011cccccccccccc11000000000000000000b3bbbbbbbbb300000000000000000000599999999994000000000000000000004ffffffffff90000000000
00000011cccccccccccccccc1100000000000000b3bbbbbbbbbbbbb30000000000000000599999999999999400000000000000004ffffffffffffff900000000
000011cccccccc11cccccccccc110000000000b3bbbbbbbbbbbbbbbbb3000000000000599999999999999999940000000000004ffffffffffffffffff9000000
0011cccccccccccc11cccccccccc11000000b3bbbbbbbbbbbbbbbbbbbbb300000000599999999999999999999994000000004ffffffffffffffffffffff90000
11ccccccccccccccccc1cccccccccc1100b3bbbbbbbbbbbbbbbbbbbbbbbbb30000599999999999999999999999999400004ffffffffffffffffffffffffff900
1cccccccc11ccccccccccccccccccccc03bbbbbbbbbbbbbbbbbbbbbbbbbbbb30099999999999999999999999999999400fffffffffffffffffffffffffffff90
001cccccccc11cccccccccc1ccccc10033b3bbbbbbbbbbbbbbbbbbbbbbbbb33355599999999999999999999999994994444fffffffffffffffffffffffff9ff9
00001cccccccc11cccccccccccc100001333b3bbbbbbbbbbbbbbbbbbbbb3b33b1545599999999999999999999949944954f44fffffffffffffffffffff9ff99f
0000001ccccccccc1cccccccc1000000333333b3bbbbbbbbbbbbbbbbb3b33333555545599999999999999999499444444444f44fffffffffffffffff9ff99999
000000001cccccccccccccc10000000013333333b3bbbbbbbbbbbbb3b333333b15555545599999999999994994444449544444f44fffffffffffff9ff999999f
00000000001cccccccccc100000000003333333333b3bbbbbbbbb3b3333344495555555545599999999949944444444444444444f44fffffffff9ff999999999
0000000000001cccccc1000000000000155113333333b3bbbbb3b33333399999155555555545599999499444444444495444444444f44fffff9ff9999999999f
000000000000001cc10000000000000044444133333333b3b3b333333399999955555555555545594994444444444444444444444444f44f9ff9999999999999
00000000000000000000000000000000144444533333333333333333399999951555555555555545944444444444444554444444444444f4f999999999999994
000000000000000000000000000000000014444451133333b3333444999995000015555555555555444444444444450000544444444444449999999999999400
0000000000000000000000000000000000001444444133333333999999950000000015555555555494444444444500000000544444444449f999999999940000
000000000000000000000000000000000000001444441333b3399999950000000000001555555555444444444500000000000054444444449999999994000000
0000000000000000000000000000000000000000144445333399999500000000000000001555555494444445000000000000000054444449f999999400000000
00000000000000000000000000000000000000000014445549999500000000000000000000155555444445000000000000000000005444449999940000000000
0000000000000000000000000000000000000000000014449995000000000000000000000000155494450000000000000000000000005449f994000000000000
00000000000000000000000000000000000000000000001545000000000000000000000000000015450000000000000000000000000000544400000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000003bb3000000000000000000000000000033330000000000000000000000000000b3b30000000000000000000000000000000000000000000000
0000000000003bbbbbb300000000000000000000000033333333000000000000000000000000b3bbbbb300000000000000000000000000000000000000000000
00000000003bbbbbbbbbb30000000000000000000033333333333300000000000000000000b3bbbbbbbbb3000000000000000000000000000000000000000000
000000003bbbbbbbbbbbbbb3000000000000000033333333333333330000000000000000b3bbbbbbbbbbbbb30000000000000000000000000000000000000000
0000003bbbbbbbbbbbbbbbbbb300000000000033333333333333333333000000000000b3bbbbbbbbbbbbbbbbb300000000000000000000000000000000000000
00003bbbbbbbbbbbbbbbbbbbbbb30000000033333333333333333333333300000000b3bbbbbbbbbbbbbbbbbbbbb3000000000000000000000000000000000000
003bbbbbbbbbbbbbbbbbbbbbbbbbb3000033333333333333333333333333330000b3bbbbbbbbbbbbbbbbbbbbbbbbb30000000000000000000000000000000000
13bbbbbbbbbbbbbbbbbbbbbbbbbbbbb31333333333333333333333333333333b03bbbbbbbbbbbbbbbbbbbbbbbbbbbb3b00000000000000000000000000000000
1313bbbbbbbbbbbbbbbbbbbbbbbbb3b313133333333333333333333333333b3b33b3bbbbbbbbbbbbbbbbbbbbbbbbb33300000000000000000000000000000000
111313bbbbbbbbbbbbbbbbbbbbb3b333111313333333333333333333333b3bbb1333b3bbbbbbbbbbbbbbbbbbbbb3b33b00000000000000000000000000000000
11111313bbbbbbbbbbbbbbbbb3b333331111131333333333333333333b3bbbbb333333b3bbbbbbbbbbbbbbbbb3b3333300000000000000000000000000000000
1111111313bbbbbbbbbbbbb3b333311111111113133333333333333b3bbbb33311113333b3bbbbbbbbbbbbb3b333333b00000000000000000000000000000000
111111111313bbbbbbbbb3b333331444111111111313333333333b3bbbbb34445555133333b3bbbbbbbbb3b33333444400000000000000000000000000000000
55551111111313bbbbb3b333333149995555111111131333333b3bbbbbb34999444451333333b3bbbbb3b3333334999900000000000000000000000000000000
4444511111111313b3b333333314999944445111111113133b3bbbbbbb34999944444513333333b3b3b333333349999900000000000000000000000000000000
1444451111111113b33311111149999414444511111111133bbb3333334999941444445111133333333333333499999400000000000000000000000000000000
001444555551111133314444449994000014445555511111bbb34444449994000014444555513333b33334444999940000000000000000000000000000000000
000014444445111133149999999400000000144444451111bb349999999400000000144444451333333349999994000000000000000000000000000000000000
00000014444451111149999994000000000000144444511133499999940000000000001444445133b33499999400000000000000000000000000000000000000
00000000144445554499999400000000000000001444455544999994000000000000000014444511334999940000000000000000000000000000000000000000
00000000001444449999940000000000000000000014444499999400000000000000000000144455449994000000000000000000000000000000000000000000
00000000000014449994000000000000000000000000144499940000000000000000000000001444999400000000000000000000000000000000000000000000
00000000000000149400000000000000000000000000001494000000000000000000000000000015440000000000000000000000000000000000000000000000
