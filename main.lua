-- black       = 0
-- dark_blue   = 1
-- dark_purple = 2
-- dark_green  = 3
-- brown       = 4
-- dark_gray   = 5
-- light_gray  = 6
-- white       = 7
-- red         = 8
-- orange      = 9
-- yellow      = 10
-- green       = 11
-- blue        = 12
-- indigo      = 13
-- pink        = 14
-- peach       = 15

heatmap_colors = {0, 1, 13, 12, 11, 10, 9, 14, 8, 2}

terrainmap_colors = {[0]=1,  1, -- deep ocean
										 12, 15,    -- coastline
										 11, 11, 3, 3, -- green land
										 4,  5,  6,  7} -- mountains

biomes = {
	[0]={ --desert
		[0]=1,
		12,15,
		10,10,10,11,11,3,
		4,5,6
	},
	{ --forest
		[0]=1,1,
		12,15,
		11,11,3,3,
		4,5,6,7
	},
	{ --ice
		[0]=1,12,
		12,7,
		7,7,7,7,
		7,7,7,7
	}
}

function falloff_help(x,c,r)
 return max(abs(c-x)-r,0)
end
local function falloff(x,y,xc,xr,yc,yr)
 return 1 - max(falloff_help(x,xc,xr)/(xc-xr),falloff_help(y,yc,yr)/(yc-yr))
end

local function SimplexOctaves2D(noisedx,noisedy,octaves,freqx,freqy,persistance,x,y)
 local max_amp = 0
 local amp = 1
 local value = 0
 for n=1,octaves do
	 value = value + Simplex2D(noisedx + freqx * x,
														 noisedy + freqy * y)
	 max_amp += amp
	 amp *= persistance
	 freqx *= 2
	 freqy *= 2
 end
 value /= max_amp
 return value
end

local xsize=64
local ysize=32
local freq=1

local function generate()
 -- generate some terrain
 local noisedx = rnd(1024)
 local noisedy = rnd(1024)
 local bndx = rnd(1024)
 local bndy = rnd(1024)
 for x=0,xsize-1 do
	 for y=0,ysize-1 do
		 local value = SimplexOctaves2D(noisedx,noisedy,5,freq*.01,freq*.015,.65,x,y)
		 if value>1 then value = 1 end
		 if value<-1 then value = -1 end
		 value += 1
		 --value *= 1 - (max(abs(64 - x), abs(64 - y)) / 64)
		 value *= falloff(x,y,xsize/2,8,ysize/2,ysize)
		 value *= #terrainmap_colors/2
		 value = flr(value+.5)

		 local biome = SimplexOctaves2D(bndx,bndy,3,freq*.03,freq*.01,.65,x,y)
		 biome *= 0.5
		 biome += (((abs((ysize/2)-y)/(ysize/4))-1)*1)-0.2
		 local bdev = #biomes/2
		 biome = (biome+1)*bdev
		 if biome>2 then biome = 2 end
		 if biome<0 then biome = 0 end
		 biome = flr(biome+.5)

		 local color = biomes[biome][value]
		 pset(x,y,color)
		 local gx=x*2
		 local gy=y*2
		 -- rectfill(gx,gy,gx+1,gy+1,color)
		 mset(x,y,color)
	 end
 end
end

function _init()
 cls()
 generate()
end

local vx,vy=0,0
local cx,cy=0,0
local dx,dy=0,0
local view=false

local scrollsp=0.05
local cursp=0.5

function _update60()
	if (btnp(4) or btnp(5)) view=true
	vx = (vx*(1-scrollsp))+((cx-60)*scrollsp)
	vy = (vy*(1-scrollsp))+((cy-60)*scrollsp)
	if view then
		dx*=0.9
		dy*=0.9
		if btn(0) then
			if(dx>0) dx=0
			dx-=cursp
		end
		if btn(1) then
			if(dx<0) dx=0
			dx+=cursp
		end
		if btn(2) then
			if(dy>0) dy=0
			dy-=cursp
		end
		if btn(3) then
			if(dy<0) dy=0
			dy+=cursp
		end
		if(not btn(0) and not btn(1)) dx = 0
		if(not btn(2) and not btn(3)) dy = 0
		cx += dx
		cy += dy
	end
end

function _draw()
	if view then
		cls()
		camera(vx,vy)
		map(0,0,0,0,xsize,ysize)
		spr(16,cx,cy)
	end
end
