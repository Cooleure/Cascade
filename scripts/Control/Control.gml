#macro GRID_SIZE 100

enum GRID
{
	AUCUN,
	RIVIERE,
	GRAINE,
	ECLUSE
}

function ControlCreate()
{
	gameGrid = ds_grid_create(19, 11);
	ds_grid_clear(gameGrid, GRID.AUCUN);
	
	 ControlCreateObject(oSurfaceRiviere, oRiviere, "Riviere", GRID.RIVIERE);
	 ControlCreateObject(oSurfaceGraine, oGraine, "Graine", GRID.GRAINE);
	 ControlCreateObject(oSurfaceEcluse, oEcluse, "Riviere", GRID.ECLUSE);
}

function ControlStep()
{
	
}

function ControlDrawGUI()
{
	GridDraw(gameGrid, GRID_SIZE);
}

function ControlGetGameGrid()
{
	return oControl.gameGrid;
}

function ControlCreateObject(_surface, _object, _layer, _value)
{
	with (_surface)
	{
		var _posRiviere = GridGetPosition(ControlGetGameGrid(), x, y);
		var _xRiviere = _posRiviere[0];
		var _yRiviere = _posRiviere[1];
		
		var _scale = max(image_xscale, image_yscale);
		
		if (image_xscale > image_yscale)
		{
			for (var _i = 0; _i < _scale; _i++)
			{
				instance_create_layer(x + _i * GRID_SIZE, y, _layer, _object);
				ds_grid_set(ControlGetGameGrid(), _xRiviere + _i, _yRiviere, _value);
			}
		}
		else if (image_xscale < image_yscale)
		{
			for (var _i = 0; _i < _scale; _i++)
			{
				instance_create_layer(x, y + _i * GRID_SIZE, _layer, _object);
				ds_grid_set(ControlGetGameGrid(), _xRiviere, _yRiviere + _i, _value);
			}
		}
		else
		{
			instance_create_layer(x, y, "Riviere", _object);
			ds_grid_set(ControlGetGameGrid(), _xRiviere, _yRiviere, _value);
		}
	}
}


