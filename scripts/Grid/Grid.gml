function GridGetPosition(_gameGrid, _x, _y) // Coordonées en pixel
{
	return [_x div GRID_SIZE, _y div GRID_SIZE];
}

function GridGetCoord(_gameGrid, _x, _y) // Position
{
	return [_x * GRID_SIZE, _y * GRID_SIZE];
}

function GridDraw(_gameGrid, _size)
{
	for (var _i = 0; _i < ds_grid_width(_gameGrid); _i++)
	{
		draw_line(_i * _size, 0, _i * _size, 1080);
	}
	
	for (var _j = 0; _j < ds_grid_height(_gameGrid); _j++)
	{
		draw_line(0, _j * _size, 1920, _j * _size);
	}
	
	for (var _i = 0; _i < ds_grid_width(_gameGrid); _i++)
	{
		for (var _j = 0; _j < ds_grid_height(_gameGrid); _j++)
		{
			draw_text(_i * _size, _j * _size, ds_grid_get(_gameGrid, _i, _j));
		}
	}
}
