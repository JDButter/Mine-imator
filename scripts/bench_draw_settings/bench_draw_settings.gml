/// bench_draw_settings(x, y, width, height)
/// @arg x
/// @arg y
/// @arg width
/// @arg height

var padding = 5;

dx = argument0
dy = argument1
dw = argument2
dh = argument3
content_x = dx
content_y = dy
content_width = dw
content_height = dh

// Header
draw_set_font(setting_font_bold)
draw_text(dx + padding, dy + padding, text_get("type" + bench_settings.type))
draw_set_font(setting_font)
draw_separator_horizontal(dx + padding, dy + padding + 20, dw - padding * 2)

// Settings
var sdy, type, buttony, listh;
type = bench_settings.type
sdy = dy
listh = 0

dx += padding + 5
dy += padding + 20 + 15
dw -= padding * 2 + 10
dh -= padding + 20 + 30

if (type_is_timeline(type))
{
	buttony = dy + dh / 2 - 16
}
else
{
	dh -= 32 + 5
	
	// Preview
	preview_draw(bench_settings.preview, dx + floor(dw / 2) - 80, dy, 160)
	dy += 160 + 10
	dh -= 160 + 10
	
	// Settings
	switch (type)
	{
		case "char":
		case "spblock":
		{
			var labeltext, list, texcap, capwid;
			if (type = "char")
			{
				labeltext = text_get("benchcharmodel")
				list = bench_settings.char_list
				texcap = "benchcharskin"
			}
			else
			{
				labeltext = text_get("benchblock")
				list = bench_settings.special_block_list
				texcap = "benchspblocktex"
			}
			capwid  = text_caption_width(texcap)
			
			// Model
			draw_label(labeltext + ":", dx, dy + 8, fa_left, fa_middle)
			dy += 22
			listh = 200 + bench_settings.height_custom
			sortlist_draw(list, dx, dy, dw, listh, bench_settings.char_model_name)
			dy += listh + 30
			
			// States
			var model, state;
			model = mc_version.model_name_map[?bench_settings.char_model_name]
			state = ds_map_find_first(bench_settings.char_model_state_map)
			while (!is_undefined(state))
			{
				capwid = max(capwid, string_width(minecraft_get_name("modelstate", state) + ":") + 20)
				state = ds_map_find_next(bench_settings.char_model_state_map, state)
			}
			
			state = ds_map_find_first(bench_settings.char_model_state_map);
			while (!is_undefined(state))
			{
				menu_model_current = model
				menu_model_state_current = model.states_map[?state]
				draw_button_menu(state, e_menu.LIST, dx, dy, dw, 24, bench_settings.char_model_state_map[?state], minecraft_get_name("modelstatevalue", bench_settings.char_model_state_map[?state]), action_bench_char_model_state, null, null, capwid, text_get("benchmodelstatetip"))
				state = ds_map_find_next(bench_settings.char_model_state_map, state)
				dy += 24 + 8
			}
			menu_model_current = null
			
			// Skin
			var text, texture;
			text = bench_settings.char_skin.display_name
			with (bench_settings.char_skin)
				texture = res_get_model_texture(other.bench_settings.char_model_texture_name)
			draw_button_menu(texcap, e_menu.LIST, dx, dy, dw, 40, bench_settings.char_skin, text, action_bench_char_skin, texture, null, capwid)
			dy += 40
			break
		}
		
		case "scenery":
		{
			var capwid, text, tex;
			capwid = text_caption_width("benchschematic", "benchblocktex")
			
			// Schematic
			text = text_get("listnone")
			if (bench_settings.scenery)
				text = bench_settings.scenery.display_name
			draw_button_menu("benchschematic", e_menu.LIST, dx, dy, dw, 32, bench_settings.scenery, text, action_bench_scenery, null, null, capwid)
			dy += 32 + 8

			// Texture
			draw_button_menu("benchblocktex", e_menu.LIST, dx, dy, dw, 40, bench_settings.block_tex, bench_settings.block_tex.display_name, action_bench_block_tex, bench_settings.block_tex.block_preview_texture, null, capwid)
			dy += 40
			break
		}
		
		case "item":
		{
			var capwid, res, text, sprite;
			capwid = text_caption_width("typeitem", "benchitemtex")
			res = bench_settings.item_tex
			if (!res.ready)
				res = res_def
			
			// Preview
			draw_label(text_get("typeitem") + ":", dx, dy + 8, fa_left, fa_middle)
			if (res.item_sheet_texture != null)
			{
				draw_texture_slot(res.item_sheet_texture, bench_settings.item_slot, dx + capwid, dy, 16, 16, res.item_sheet_size[X], res.item_sheet_size[Y])
			}
			else
			{
				var scale = min(16 / texture_width(res.texture), 16 / texture_height(res.texture));
				draw_texture(res.texture, dx + capwid, dy, scale, scale)
			}
			dy += 22
			
			// Item select
			if (res.item_sheet_texture != null)
			{
				var slots = test(res.type = "pack", ds_list_size(mc_version.item_texture_list), res.item_sheet_size[X] * res.item_sheet_size[Y]);
				listh = 200 + bench_settings.height_custom
				draw_texture_picker(bench_settings.item_slot, res.item_sheet_texture, dx, dy, dw, listh, slots, res.item_sheet_size[X], res.item_sheet_size[Y], bench_settings.item_scroll, action_bench_item_slot)
				dy += listh + 8
			}
			
			// Image
			draw_button_menu("benchitemtex", e_menu.LIST, dx, dy, dw, 40, bench_settings.item_tex, bench_settings.item_tex.display_name, action_bench_item_tex, bench_settings.item_tex.block_preview_texture, null, capwid)
			dy += 40 + 8
			
			// Settings
			draw_checkbox("benchitem3d", dx, dy, bench_settings.item_3d, action_bench_item_3d)
			draw_checkbox("benchitemfacecamera", dx + floor(dw * 0.3), dy, bench_settings.item_face_camera, action_bench_item_face_camera)
			draw_checkbox("benchitembounce", dx + floor(dw * 0.7), dy, bench_settings.item_bounce, action_bench_item_bounce)
			dy += 16
			break
		}
		
		case "block":
		{
			var capwid, text, sprite;
			capwid = text_caption_width("benchblocktex")
			
			// Block
			draw_label(text_get("benchblock") + ":", dx, dy + 8, fa_left, fa_middle)
			dy += 22
			listh = 172 + bench_settings.height_custom
			sortlist_draw(bench_settings.block_list, dx, dy, dw, listh, bench_settings.block_name)
			dy += listh + 30
			
			// States
			var block, state;
			block = mc_version.block_name_map[?bench_settings.block_name]
			state = ds_map_find_first(bench_settings.block_state_map)
			while (!is_undefined(state))
			{
				capwid = max(capwid, string_width(minecraft_get_name("blockstate", state) + ":") + 20)
				state = ds_map_find_next(bench_settings.block_state_map, state)
			}
			
			state = ds_map_find_first(bench_settings.block_state_map);
			while (!is_undefined(state))
			{
				menu_block_current = block
				menu_block_state_current = block.states_map[?state]
				draw_button_menu(state, e_menu.LIST, dx, dy, dw, 24, bench_settings.block_state_map[?state], minecraft_get_name("blockstatevalue", bench_settings.block_state_map[?state]), action_bench_block_state, null, null, capwid, text_get("benchblockstatetip"))
				state = ds_map_find_next(bench_settings.block_state_map, state)
				dy += 24 + 8
			}
			menu_block_current = null
			
			// Texture
			draw_button_menu("benchblocktex", e_menu.LIST, dx, dy, dw, 40, bench_settings.block_tex, bench_settings.block_tex.display_name, action_bench_block_tex, bench_settings.block_tex.block_preview_texture, null, capwid)
			dy += 40
			break
		}
		
		case "bodypart":
		{
			var capwid = text_caption_width("benchbodypart", "benchbodypartskin");
			
			// Model
			draw_label(text_get("benchmodel") + ":", dx, dy + 8, fa_left, fa_middle)
			dy += 22
			listh = 200 + bench_settings.height_custom
			sortlist_draw(bench_settings.bodypart_char_list, dx, dy, dw, listh, bench_settings.char_model)
			dy += listh + 30
			
			// Bodypart
			//draw_button_menu("benchbodypart", e_menu.LIST, dx, dy, dw, 24, bench_settings.char_bodypart, text_get(bench_settings.char_model.part_name[bench_settings.char_bodypart]), action_bench_char_bodypart, null, 0, capwid)
			dy += 24 + 8
					
			// Skin
			//draw_button_menu("benchbodypartskin", e_menu.LIST, dx, dy, dw, 40, bench_settings.char_skin, bench_settings.char_skin.display_name, action_bench_char_skin, bench_settings.char_skin.mob_texture[bench_settings.char_model.index], null, capwid)
			break
		}
		
		case "particles":
		{
			// Particles
			draw_label(text_get("benchparticlespreset") + ":", dx, dy + 8, fa_left, fa_middle)
			dy += 22
			listh = 200 + bench_settings.height_custom
			sortlist_draw(bench_settings.particles_list, dx, dy, dw, listh, bench_settings.particle_preset)
			dy += listh + 20
			break
		}
		
		case "text":
		{
			// Font
			draw_button_menu("benchtextfont", e_menu.LIST, dx, dy, dw, 32, bench_settings.text_font, bench_settings.text_font.display_name, action_bench_text_font)
			dy += 32 + 8
			
			// Face camera
			draw_checkbox("benchtextfacecamera", dx, dy, bench_settings.text_face_camera, action_bench_text_face_camera)
			dy += 16
			break
		}
		
		default: // Shapes
		{
			// Texture
			var text, tex;
			text = text_get("listnone")
			tex = null
			if (bench_settings.shape_tex)
			{
				text = bench_settings.shape_tex.display_name
				if (bench_settings.shape_tex.type != "camera")
					tex = bench_settings.shape_tex.texture
			}
			draw_button_menu("benchshapetex", e_menu.LIST, dx, dy, dw, 40, bench_settings.shape_tex, text, action_bench_shape_tex, tex)
			dy += 40 + 8
			
			// Is mapped
			if (bench_settings.type = "cube" || 
				bench_settings.type = "cylinder" || 
				bench_settings.type = "cone")
			{
				draw_checkbox("benchshapetexmap", dx, dy, bench_settings.shape_tex_mapped, action_bench_shape_tex_map)
				dy += 16
			}
			else if (bench_settings.type = "surface")
			{
				draw_checkbox("benchshapefacecamera", dx, dy, bench_settings.shape_face_camera, action_bench_shape_face_camera)
				dy += 16
			}
			
			break
		}
	}
	dy += 10
	buttony = dy
	dy += 32 + padding * 2
}

if (draw_button_normal("benchcreate", dx + floor(dw / 2) - 50, floor(buttony), 100, 32))
{
	action_bench_create()
	bench_show_ani_type = "hide"
}

bench_settings.width_goal = bench_settings.width_custom + 370
bench_settings.height_goal = bench_settings.height_custom + max(bench_height, dy - sdy - bench_settings.height_custom * (listh > 0))