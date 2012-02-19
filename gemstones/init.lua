--------------------------------------------------------------------------------
--    Gemstones!
--------------------------------------------------------------------------------
--    This mod adds gems such as rubies, sapphires, emeralds, etc. Tools and
--    "solid" blocks can be crafted from the gems.
--
--    (c) 2011 Fernando Zapata
--    Code licensed under GNU GPLv3
--    Content licensed under CC BY-SA 3.0
--
--    2011-12-04    13:26:40
--------------------------------------------------------------------------------

-- List containing the names and quantity of the ores --
minerallist = {}

---- Big, bad function to declare gems -----------------------------------------
register_gem = function( gemtype, max_clusters, min_depth, basetime, durability, toolrules )

	-- Ores --
	mineralname = "gemstones:mineral_" .. gemtype
	mineraltex  = "default_stone.png^gemstones_mineral_" .. gemtype .. ".png"

	-- Gems/lumps --
	gemname     = "gemstones:gem_" .. gemtype
	gemtex      = "gemstones_gem_" .. gemtype .. ".png"
	craftname   = gemname

	-- Solid block --
	blockname   = "gemstones:block_" .. gemtype
	blocktex    = "gemstones_block_" .. gemtype .. ".png"
	-- maximal number of clusters at depth d will be
	-- a*(1-exp(-(b * depth) ^ 2)), where a = max_clusters,
	-- we want at least one cluster at depth == min_depth
	-- http://www.wolframalpha.com/input/?i=solve+n*%281-exp%28-%28b+*+d%29+**+2%29%29+%3D+1+for+b%2C+n%3E0%2C+d%3E0%2C+b%3E0
	--
	-- example for max_clusters == 10, min_depth=32
	-- http://www.wolframalpha.com/input/?i=solve+n*%281-exp%28-%28b+*+d%29+**+2%29%29+%3D+1+for+b%2C+n%3D10%2C+d%3D32%2C+b%3E0
	-- b = 0.0101435264367031644904753805829301386268546982656322629837...
	-- http://www.wolframalpha.com/input/?i=plot+n*%281-exp%28-%28b+*+d%29+**+2%29%29+where+b+%3D+0.010143526%2C+n+%3D+10%2C+d+%3D+0+to+200
	-- http://www.wolframalpha.com/input/?i=plot+n*%281-exp%28-%28b+*+d%29+**+2%29%29+where+b+%3D+0.010143526%2C+n+%3D+10%2C+d+%3D+0+to+40
	local depth_scale = math.sqrt( math.log( max_clusters/(max_clusters-1) ))/min_depth
	table.insert( minerallist, { name=mineralname, a = max_clusters, b = depth_scale } )

	minetest.register_craftitem( gemname, {
		image = gemtex,
		on_place_on_ground = minetest.craftitem_place_item,
	} )

	-- Mineral block --
	minetest.register_node( mineralname, {
		tile_images           = { mineraltex },
		inventory_image       = minetest.inventorycube( mineraltex ),
		is_ground_content     = true,
		material              = minetest.digprop_stonelike(1.0),
		drop                  = craftname .. ' 1',

	} )

	-- Solid block --
	minetest.register_node( blockname, {
		--drawtype              = "glasslike",
		tile_images           = { blocktex },
		inventory_image       = blocktex,
		--alpha                 = 200,
		is_ground_content     = true,
		material              = minetest.digprop_glasslike(3.0),
	} )

	-- Tools, with "add_tool" by MarkTraceur
	register_tool_type("gemstones", gemtype, craftname, basetime, durability, toolrules)

	-- Crafting blocks --
	minetest.register_craft( {
		output                = blockname .. ' 1',
		recipe = {
			                { craftname,craftname,craftname },
			                { craftname,craftname,craftname },
			                { craftname,craftname,craftname },
		},
	} )

	minetest.register_craft( {
		output                = craftname .. ' 9',
		recipe = {
			                { blockname .. '"' },
		},
	} )
end

---- Create gems on chunk generation -------------------------------------------
-- celeron55 said:
-- "It is somewhat doable, but not very fancily. Off the top of my head
-- without any testing:"
-- + My fixes
local generate_gem = function( minp, maxp )
	for c, oreinfo in ipairs( minerallist ) do
		local average_pos = {
		      x =minp.x + (maxp.x - minp.x)/2,
		      y =minp.y + (maxp.y - minp.y)/2,
		      z =minp.z + (maxp.z - minp.z)/2
		}
		local depth = minetest.env:get_ground_level(average_pos) - average_pos.y
		local max_amount = math.floor(oreinfo.a * (1-math.exp(-(oreinfo.b * depth) ^ 2)))
		local max_amount = math.floor(max_amount)
		local amount = math.random( 0, max_amount )
		for a = 0, amount do
			local pos = {
				x = math.random( minp.x, maxp.x ),
				y = math.random( minp.y, maxp.y ),
				z = math.random( minp.z, maxp.z ),
			}
			for i = -1, 1 do
				for j = -1, 1 do
					for k = -1, 1 do
						if math.random() > 0.2 then
							--continue
						else
							local p = { x=pos.x+i, y=pos.y+j, z=pos.z+k }
							local n = minetest.env:get_node( p )
							if n.name == "default:stone" then
								minetest.env:add_node( p, { name = oreinfo.name } )
							end
						end
					end
				end
			end
		end
	end
end

minetest.register_on_generated( generate_gem )
---- Register new gemstones ----------------------------------------------------

---- Amethyst ----
-- Less durable but slightly faster than steel.
register_gem( "amethyst", 50, 8 , 0.9, 250,  { sword_time = 1 } )

---- Cubic Zirconia ----
-- Almost wood slow, but almost mese-like durability
register_gem( "czirconia",50, 8, 1.6, 1000, { sword_time = 1 } )

---- Emerald ----
-- Just a bit less durable than steel
register_gem( "emerald", 50, 8, 1.0, 300,  { sword_time = 1 } )

---- Ruby ----
-- Faster, but much less durable than steel
register_gem( "ruby", 50, 8, 0.7, 180,  { sword_time = 1 } )

---- Sapphire ----
-- Slow, but more durable than steel
register_gem( "sapphire", 50, 5, 1.2, 500, { sword_time = 1 } )

---- Was loaded? ---------------------------------------------------------------
-- Just to be sure, may remove if you like.
print( " ++ loaded : Gemstones, by ZLovesPancakes" )
