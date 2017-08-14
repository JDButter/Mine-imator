/// res_load_pack_model_textures()

// Free old
if (model_texture_map != null)
{
	var key = ds_map_find_first(model_texture_map);
	while (!is_undefined(key))
	{
		texture_free(model_texture_map[?key])
		key = ds_map_find_next(model_texture_map, key)
	}
	ds_map_destroy(model_texture_map)
}

// Create new
debug_timer_start()

model_texture_map = ds_map_create()
for (var t = 0; t < ds_list_size(mc_version.model_texture_list); t++)
{
	var name, fname;
	name = mc_version.model_texture_list[|t]
	fname = textures_directory + name + ".png"
	model_texture_map[?name] = texture_create(fname)
}

debug_timer_stop("res_load_pack_model_textures")