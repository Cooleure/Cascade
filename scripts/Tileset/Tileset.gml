function TilesetSol()
{
	var _layer				= layer_get_id("Sol");
	var _tile_tilemap_id	= layer_tilemap_get_id(_layer);

	var _tile_width			= tilemap_get_tile_width(_tile_tilemap_id);
	var _tile_height		= tilemap_get_tile_height(_tile_tilemap_id);

	var _total_tiles_x		= room_width div _tile_width;
	var _total_tiles_y		= room_height div _tile_height;

	for (var _tile_x = 0; _tile_x < _total_tiles_x; _tile_x++)
	{
		for (var _tile_y = 0; _tile_y < _total_tiles_y; _tile_y++)
		{
			var _tile_data = tilemap_get(_tile_tilemap_id, _tile_x, _tile_y);
			
			_tile_data = tile_set_index(_tile_data, irandom(3) + 1);
			_tile_data = tile_set_mirror(_tile_data, irandom(1));
			_tile_data = tile_set_rotate(_tile_data, irandom(1));
			_tile_data = tile_set_flip(_tile_data, irandom(1));
			
			tilemap_set(_tile_tilemap_id, _tile_data, _tile_x, _tile_y);
		}
	}
}

