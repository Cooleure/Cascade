#macro VOISIN_DROITE 0
#macro VOISIN_BAS 1
#macro VOISIN_GAUCHE 2
#macro VOISIN_HAUT 3

function GridGetPosition(_x, _y) // Coordonées en pixel
{
	return [_x div GRID_SIZE, _y div GRID_SIZE];
}

function GridGetCoord(_x, _y) // Position
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
			draw_text(_i * _size, _j * _size, GetState(ds_grid_get(_gameGrid, _i, _j)));
		}
	}
}

function GridGetVoisins(_x, _y)
{
	var _voisins = array_create(4);

	var _pos = GridGetPosition(_x, _y);
	var _xPos = _pos[0];
	var _yPos = _pos[1];
	
	if (_xPos < GRID_MAX_HORIZONTAL - 1) // Droite
	{
		_voisins[0] = ds_grid_get(ControlGetGameGrid(), _xPos + 1, _yPos);
	}
	else
	{
		_voisins[0] = GetNull();
	}
	
	if (_yPos < GRID_MAX_VERTICAL - 1) // Bas
	{
		_voisins[1] = ds_grid_get(ControlGetGameGrid(), _xPos, _yPos + 1);
	}
	else
	{
		_voisins[1] = GetNull();
	}
	
	if (_xPos > 0) // Gauche
	{
		_voisins[2] = ds_grid_get(ControlGetGameGrid(), _xPos - 1, _yPos);
	}
	else
	{
		_voisins[2] = GetNull();
	}
	
	if ( _yPos > 0) // Haut
	{
		_voisins[3] = ds_grid_get(ControlGetGameGrid(), _xPos, _yPos - 1);
	}
	else
	{
		_voisins[3] = GetNull();
	}
	
	return _voisins;
}
