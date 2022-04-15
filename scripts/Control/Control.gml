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
	
	ControlCreateObject(oSurfaceRiviere, oRiviere, "Riviere");
	ControlCreateObject(oSurfaceGraine, oGraine, "Graine");
	ControlCreateObject(oSurfaceEcluse, oEcluse, "Ecluse");
	ControlCreateObject(oSurfaceCascade, oCascade, "Cascade");
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

function ControlCreateObject(_surface, _object, _layer)
{
	with (_surface)
	{
		var _posRiviere = GridGetPosition(x, y);
		var _xRiviere = _posRiviere[0];
		var _yRiviere = _posRiviere[1];
		
		var _scale = max(image_xscale, image_yscale);
		
		if (image_xscale > image_yscale)
		{
			for (var _i = 0; _i < _scale; _i++)
			{
				var _inst = instance_create_layer(x + _i * GRID_SIZE, y, _layer, _object);
				
				if (ds_grid_get(ControlGetGameGrid(), _xRiviere + _i, _yRiviere) == GRID.AUCUN)
				{
					ds_grid_set(ControlGetGameGrid(), _xRiviere + _i, _yRiviere, _inst.id);
				}
			}
		}
		else if (image_xscale < image_yscale)
		{
			for (var _i = 0; _i < _scale; _i++)
			{
				var _inst = instance_create_layer(x, y + _i * GRID_SIZE, _layer, _object);
				
				if (ds_grid_get(ControlGetGameGrid(), _xRiviere, _yRiviere + _i) == GRID.AUCUN)
				{
					ds_grid_set(ControlGetGameGrid(), _xRiviere, _yRiviere + _i, _inst.id);
				}
			}
		}
		else
		{
			var _inst = instance_create_layer(x, y, "Riviere", _object);
			
			if (ds_grid_get(ControlGetGameGrid(), _xRiviere, _yRiviere) == GRID.AUCUN)
			{
				ds_grid_set(ControlGetGameGrid(), _xRiviere, _yRiviere, _inst.id);
			}
		}
	}
}


