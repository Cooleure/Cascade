#macro ENERGIE_MIN 0
#macro ENERGIE_MAX 500

function EnergieCreate()
{
	energie = 100;
}

function EnergieUpdate()
{
	energie -= 1 / room_speed;
	var _ratio = round(500 / 23);
	var _palier = energie div _ratio;
	
	image_index = _palier;
	
	EnergieClamp();
}

function EnergieDraw()
{
	draw_self();
	var _ratio = round(500 / 23);
	var _palier = energie div _ratio;
	draw_text(x, y, _palier);
	draw_text(x, y + 20, energie);
}



function EnergieAdd(_value)
{
	oEnergie.energie += _value;
	EnergieClamp();
}

function EnergieClamp()
{
	oEnergie.energie = clamp(oEnergie.energie, ENERGIE_MIN, ENERGIE_MAX);
}
