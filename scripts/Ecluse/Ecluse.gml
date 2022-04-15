enum ECLUSE_STATE
{
	FERME,
	OUVERT_SEC,
	OUVERT_REMPLISSAGE,
	OUVERT_REMPLI,
	OUVERT_VIDAGE
};

function EcluseInit()
{
	SetState(ECLUSE_STATE.FERME);
	stateMachine[0] = EcluseStateFerme;
	stateMachine[1] = EcluseStateOuvertSec;
	stateMachine[2] = EcluseStateOuvertRemplissage;
	stateMachine[3] = EcluseStateOuvertRempli;
	stateMachine[4] = EcluseStateOuvertVidage;
	
	coolDown = true;
	sens = 0;
}

function EcluseUpdate()
{
	script_execute(stateMachine[state]);
}

function EcluseStateFerme()
{
	sprite_index = sEcluseFerme;
	
	if (sens == 0) exit;

	var _pos = GridGetPosition(x, y);
	var _xPos = _pos[0];
	var _yPos = _pos[1];
	
	var _suivant = ds_grid_get(ControlGetGameGrid(), _xPos, _yPos + sens);
	
	EcluseVidageTotal(_suivant);
	
	oCascade.portee = 0;
	with (oRiviere)
	{
		if (IsState(RIVIERE_STATE.REMPLI) or IsState(RIVIERE_STATE.REMPLISSAGE))
		{
			oCascade.portee++;
		}
	}
}

function EcluseStateOuvertSec()
{
	sprite_index = sEcluseOuverte;
}

function EcluseStateOuvertRemplissage()
{
	sprite_index = sEcluseOuverte;
}

function EcluseStateOuvertRempli()
{
	sprite_index = sEcluseOuverte;
	
	var _voisins = GridGetVoisins(x, y);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if (_voisin == GRID.AUCUN) continue;
		
		if (_voisin.object_index == oRiviere)
		{
			if (IsState(RIVIERE_STATE.SEC, _voisin) and (CascadeGetPortee() < CascadeGetPorteeMax()))
			{
				SetState(RIVIERE_STATE.REMPLISSAGE, _voisin);
				oCascade.portee++;
				_voisin.alarm[0] = 60;
			}
		}
	}
}

function EcluseStateOuvertVidage()
{
	sprite_index = sEcluseFerme;
}

function EcluseMouseLeftPressed()
{
	if (coolDown)
	{
		if (IsState(ECLUSE_STATE.FERME))
		{
			SetState(ECLUSE_STATE.OUVERT_SEC);
		}
		else
		{
			SetState(ECLUSE_STATE.FERME);
		}
		coolDown = false;
		alarm[11] = 120;
	}
}

function EcluseVidageTotal(_suivant)
{
	var _voisins = GridGetVoisins(_suivant.x, _suivant.y);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if (_voisin == GRID.AUCUN) continue;
		
		if (_voisin.object_index == oRiviere)
		{
			if (IsState(RIVIERE_STATE.REMPLI, _voisin) or IsState(RIVIERE_STATE.REMPLISSAGE, _voisin))
			{
				SetState(RIVIERE_STATE.VIDAGE, _voisin);
				
				alarm[0] = -1;
				_voisin.alarm[0] = -1;
				_voisin.alarm[1] = 60;
				
				EcluseVidageTotal(_voisin);
			}
		}
		else if (_voisin.object_index == oEcluse)
		{
			if (IsState(ECLUSE_STATE.OUVERT_REMPLI, _voisin) or IsState(ECLUSE_STATE.OUVERT_REMPLISSAGE, _voisin))
			{
				SetState(ECLUSE_STATE.OUVERT_VIDAGE, _voisin);
				
				alarm[0] = -1;
				_voisin.alarm[0] = -1;
				_voisin.alarm[1] = 60;
				
				EcluseVidageTotal(_voisin);
			}
		}
	}
}
