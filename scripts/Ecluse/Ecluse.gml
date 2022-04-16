enum ECLUSE_STATE
{
	FERME,
	OUVERT_SEC,
	OUVERT_REMPLISSAGE,
	OUVERT_REMPLI,
	OUVERT_VIDAGE
};

#macro ECLUSE_COOLDOWN 120

function EcluseInit()
{
	SetState(ECLUSE_STATE.FERME);
	stateMachine[0] = EcluseStateFerme;
	stateMachine[1] = EcluseStateOuvertSec;
	stateMachine[2] = EcluseStateOuvertRemplissage;
	stateMachine[3] = EcluseStateOuvertRempli;
	stateMachine[4] = EcluseStateOuvertVidage;
	
	coolDown = true;
}

function EcluseUpdate()
{
	script_execute(stateMachine[state]);
}

function EcluseStateFerme()
{
	sprite_index = sEcluseFerme;
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
				_voisin.alarm[0] = RIVIERE_REMPLISSAGE_TIME;
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
		var _id = irandom(1);
		
		if (IsState(ECLUSE_STATE.FERME))
		{
			if (_id == 0) audio_play_sound(sndOuverture1, 10, false);
			else audio_play_sound(sndOuverture2, 10, false);
			
			// Etat
			var _voisins = GridGetVoisins(x, y);

			if (IsState((RIVIERE_STATE.REMPLI), _voisins[VOISIN_BAS]) and IsState((RIVIERE_STATE.REMPLI), _voisins[VOISIN_HAUT]))
			{
				SetState(ECLUSE_STATE.OUVERT_REMPLI);
			}
			else
			{
				SetState(ECLUSE_STATE.OUVERT_SEC);
			}
		}
		else
		{
			// Etat
			SetState(ECLUSE_STATE.FERME);
			
			// Audio
			if (_id == 0) audio_play_sound(sndFermeture1, 10, false);
			else audio_play_sound(sndFermeture2, 10, false);
			
			// Recheche du sens
			var _voisins = GridGetVoisins(x, y);
			
			var _trouveBas = EcluseRechercheCascade(_voisins[VOISIN_BAS], id, [id]);
			var _trouveHaut = EcluseRechercheCascade(_voisins[VOISIN_HAUT], id, [id]);
			
			show_debug_message(_trouveHaut);
			show_debug_message(_trouveBas);
			
			var _sens = _trouveBas - _trouveHaut; // -1 = assèchement vers le bas // 1 = assèchement vers le haut
			
			// Assèchement
			if (_sens == 0) exit;
			
			var _suivant = (_sens < 0) ? _voisins[VOISIN_BAS] : _voisins[VOISIN_HAUT];
			
			EcluseVidageTotal(_suivant);
	
			// Mis à jour de la portee
			oCascade.portee = 0;
			
			with (oRiviere)
			{
				if (IsState(RIVIERE_STATE.REMPLI) or IsState(RIVIERE_STATE.REMPLISSAGE))
				{
					oCascade.portee++;
				}
			}
		}
		
		coolDown = false;
		alarm[11] = ECLUSE_COOLDOWN;
	}
}

function EcluseDraw()
{
	image_speed = 2;
	var _voisins = GridGetVoisins(x, y);
	
	if (IsState(ECLUSE_STATE.OUVERT_REMPLISSAGE))
	{
		draw_sprite(sRiviereRemplissage, image_speed, x, y);
	}
	else if (IsState(ECLUSE_STATE.OUVERT_REMPLI))
	{
		draw_sprite(sRiviere, image_speed, x, y);
	}
	else if (IsState(RIVIERE_STATE.REMPLI, _voisins[VOISIN_BAS]) and IsState(RIVIERE_STATE.REMPLI, _voisins[VOISIN_HAUT]))
	{
		draw_sprite(sRiviere, image_speed, x, y);
	}
	
	draw_self();
	
	draw_text(x + 10, y + 30, id);
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
				_voisin.alarm[1] = RIVIERE_VIDAGE_TIME;
				
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
				_voisin.alarm[1] = RIVIERE_REMPLISSAGE_TIME;
				
				EcluseVidageTotal(_voisin);
			}
		}
	}
}

function EcluseRechercheCascade(_suivant, _precedent, _ecluses)
{
	var _voisins = GridGetVoisins(_suivant.x, _suivant.y);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		// On ne veut pas continuer le parcours sur le précédent
		// On s'arrete sur le départ
		if ((_voisin == GRID.AUCUN) or (_voisin == _precedent)) continue;
		
		// On s'arrête si on est sur une écluse déjà terminée (évite les boucles infinies)
		var _ecluseAlready = false;
		for (var _j = 0; _j < array_length(_ecluses); _j++)
		{
			if (_voisin == _ecluses[_j]) // Si c'est une écluse par laquelle on est déjà passé
			{
				_ecluseAlready = true;
				break;
			}
		}
		
		if (_ecluseAlready) continue;
		
		if (_voisin.object_index == oRiviere)
		{
			if (IsState(RIVIERE_STATE.REMPLI, _voisin) or IsState(RIVIERE_STATE.REMPLISSAGE, _voisin))
			{
				if (EcluseRechercheCascade(_voisin, _suivant, _ecluses)) return 1; // On propage au suivant en se considérant comme le précédent
			}
		}
		else if (_voisin.object_index == oEcluse)
		{
			if (IsState(ECLUSE_STATE.OUVERT_REMPLI, _voisin) or IsState(ECLUSE_STATE.OUVERT_REMPLISSAGE, _voisin))
			{
				// Copie des écluses déjà traversées
				var _tailleEcluses = array_length(_ecluses);
				var _eclusesCopy = array_create(_tailleEcluses + 1);
				for (var _j = 0; _j < _tailleEcluses; _j++)
				{
				   _eclusesCopy[_j] = _ecluses[_j];
				}
				_eclusesCopy[_tailleEcluses] = _voisin;
				
				// Continue le chemin en ajoutant l'écluse qui vient d'être traversée
				if (EcluseRechercheCascade(_voisin, _suivant, _eclusesCopy)) return 1;
			}
		}
		else if (_voisin.object_index = oCascade)
		{
			return 1;
		}
	}
	
	return 0;
}
