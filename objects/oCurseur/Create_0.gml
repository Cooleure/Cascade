image_xscale = 0.5;
image_yscale = 0.5;

function CurseurOnGraine()
{
	with (oGraine)
	{
		if (collision_point(mouse_x, mouse_y, self, false, false))
		{
			if (IsState(GRAINE_STATE.POUSSE_FIN) or IsState(GRAINE_STATE.MATURITE))
			{
				return true;
			}
		}
	}
	
	return false;
}
