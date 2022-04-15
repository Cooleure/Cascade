x = mouse_x;
y = mouse_y;


	
with (oGraine)
{
	if (collision_point(mouse_x, mouse_y, self, false, false))
	{
		if (IsState(GRAINE_STATE.POUSSE) or IsState(GRAINE_STATE.MATURITE))
		{
			other.sprite_index = sCurseurFaux;
			exit;
		}
	}
	else
	{
		other.sprite_index = sMain;
	}
}
