/// model_file_load_shape(map)
/// @arg map
/// @desc Adds a shape from the given map (JSON object)

var map = argument0;

if (!is_string(map[?"type"]))
{
	log("Missing parameter \"type\"")
	return null
}

if (!ds_list_valid(map[?"from"]))
{
	log("Missing array \"from\"")
	return null
}

if (!ds_list_valid(map[?"to"]))
{
	log("Missing array \"to\"")
	return null
}

if (!ds_list_valid(map[?"uv"]))
{
	log("Missing array \"uv\"")
	return null
}

with (new(obj_model_shape))
{
	// Type
	type = map[?"type"]

	// Description (optional)
	if (is_string(map[?"description"]))
		description = map[?"description"]
	else
		description = ""
		
	// Texture (optional)
	if (is_string(map[?"texture"]))
	{
		texture_name = map[?"texture"]
		texture_inherit = id
		
		// Texture size
		if (!ds_list_valid(map[?"texture_size"]))
		{
			log("Missing array \"texture_size\"")
			return null
		}
		
		texture_size = value_get_point2D(map[?"texture_size"])
	}
	else
	{
		// Inherit
		texture_name = ""
		texture_inherit = other.texture_inherit
		texture_size = texture_inherit.texture_size
	}
		
	// Mirror (optional)
	if (is_real(map[?"texture_mirror"]))
		texture_mirror = map[?"texture_mirror"]
	else
		texture_mirror = false
	
	// Invert (optional)
	if (is_real(map[?"invert"]))
		invert = map[?"invert"]
	else
		invert = false
	
	// From/To
	from = value_get_point3D(map[?"from"])
	to = value_get_point3D(map[?"to"])
	
	// Position (optional)
	position = value_get_point3D(map[?"position"], point3D(0, 0, 0))
		
	// Rotation (optional)
	rotation = value_get_point3D(map[?"rotation"], vec3(0, 0, 0))
		
	// Scale (optional)
	scale = value_get_point3D(map[?"scale"], vec3(1, 1, 1))
		
	matrix = matrix_create(position, rotation, vec3(1))
	matrix = matrix_multiply(matrix_create(point3D(0, 0, 0), vec3(0), scale), matrix) // Add scale
	matrix_bend = matrix_create(position, rotation, vec3(1))
	matrix_bend_half = matrix_create(point3D(0, 0, 0), rotation, vec3(1))
	
	// Bending
	bend_part = other.bend_part
	bend_axis = other.bend_axis
	bend_direction = other.bend_direction
	bend_offset = other.bend_offset
	bend_vbuffer = null
	
	// UV
	uv = value_get_point2D(map[?"uv"])
		
	// Generate
	if (type = "block")
	{
		vbuffer = vbuffer_start()
		model_file_load_shape_block()
		vbuffer_done()
		
		if (bend_part != null)
		{
			bend_vbuffer = vbuffer_start()
			model_file_load_shape_block(true)
			vbuffer_done()
		}
	}
	else if (type = "plane")
	{
		to[Y] = from[Y]
		
		vbuffer = vbuffer_start()
		model_file_load_shape_plane()
		vbuffer_done()
		
		if (bend_part != null)
		{
			bend_vbuffer = vbuffer_start()
			model_file_load_shape_plane(true)
			vbuffer_done()
		}
	}
	else
	{
		log("Invalid shape type", type)
		return null
	}
	
	// Update bounds
	var startpos = point3D_mul_matrix(from, matrix);
	var endpos   = point3D_mul_matrix(to, matrix);
	bounds_start[X] = min(startpos[X], endpos[X])
	bounds_start[Y] = min(startpos[Y], endpos[Y])
	bounds_start[Z] = min(startpos[Z], endpos[Z])
	bounds_end[X]	= max(startpos[X], endpos[X])
	bounds_end[Y]	= max(startpos[Y], endpos[Y])
	bounds_end[Z]	= max(startpos[Z], endpos[Z])
	other.bounds_start[X] = min(other.bounds_start[X], bounds_start[X])
	other.bounds_start[Y] = min(other.bounds_start[Y], bounds_start[Y])
	other.bounds_start[Z] = min(other.bounds_start[Z], bounds_start[Z])
	other.bounds_end[X] = max(other.bounds_end[X], bounds_end[X])
	other.bounds_end[Y] = max(other.bounds_end[Y], bounds_end[Y])
	other.bounds_end[Z] = max(other.bounds_end[Z], bounds_end[Z])
	
	return id
}