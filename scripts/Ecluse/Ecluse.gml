enum ECLUSE_STATE
{
	FERME,
	OUVERT
};

#macro ECLUSE_COOLDOWN 40



/// State Machine
function EcluseInit()
{
	SetState(ECLUSE_STATE.OUVERT);
	stateMachine[0] = EcluseStateFerme;
	stateMachine[1] = EcluseStateOuvert;
	
	// Liens au rivières
	var _pos = GridGetPosition(x, y);
	riviereBas = ds_grid_get(ControlGetGameGrid(), _pos[0], _pos[1] + 1);
	riviereHaut = ds_grid_get(ControlGetGameGrid(), _pos[0], _pos[1]);
	riviereBas.ecluse = id;
	riviereHaut.ecluse = id;
	
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

function EcluseStateOuvert()
{
	sprite_index = sEcluseOuvert;
}



/// Events
function EcluseMouseLeftPressed()
{
	if (!coolDown) exit;
		
	coolDown = false;
	alarm[11] = ECLUSE_COOLDOWN;
	
	if (IsState(ECLUSE_STATE.FERME))
	{
		// Etat
		SetState(ECLUSE_STATE.OUVERT);
		
		// Son
		if (irandom(1))	audio_play_sound(sndOuverture1, 10, false);
		else			audio_play_sound(sndOuverture2, 10, false);
		
		// Remplissage
		if (IsState(RIVIERE_STATE.SEC, riviereBas) and IsState(RIVIERE_STATE.REMPLI, riviereHaut) and (CascadeGetPortee() < CascadeGetPorteeMax()))
		{
			SetState(RIVIERE_STATE.REMPLISSAGE, riviereBas);
			oCascade.portee++;
		}
	
		if (IsState(RIVIERE_STATE.SEC, riviereHaut) and IsState(RIVIERE_STATE.REMPLI, riviereBas) and (CascadeGetPortee() < CascadeGetPorteeMax()))
		{
			SetState(RIVIERE_STATE.REMPLISSAGE, riviereHaut);
			oCascade.portee++;
		}
	}
	else
	{
		// Etat
		SetState(ECLUSE_STATE.FERME);
		
		// Son
		if (irandom(1))	audio_play_sound(sndFermeture1, 10, false);
		else			audio_play_sound(sndFermeture2, 10, false);
			
		// Recheche du sens (on part du principe qu'il ne sont pas remplis et qu'il n'amènent pas à la cascade
		var _trouveBas = 0;
		var _trouveHaut = 0;
		
		if (IsState(RIVIERE_STATE.REMPLI, riviereBas))
		{
			_trouveBas = EcluseRechercheCascade(riviereBas, id, [riviereBas]);
		}
		
		if (IsState(RIVIERE_STATE.REMPLI, riviereBas))
		{
			_trouveHaut	= EcluseRechercheCascade(riviereHaut, id, [riviereHaut]);
		}
		
		var _sens = _trouveBas - _trouveHaut; // -1 = assèchement vers le bas // 1 = assèchement vers le haut
		show_debug_message(_sens);
		// Assèchement
		if (_sens == 0) exit;
			
		var _suivant = (_sens < 0) ? riviereBas : riviereHaut;
		
		SetState(RIVIERE_STATE.VIDAGE, _suivant);
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
}

function EcluseDraw()
{
	draw_self();
	//draw_text(x + 10, y + 30, coolDown);
}



/// Internal
function EcluseVidageTotal(_suivant)
{
	var _voisins = GridGetVoisins(_suivant.x, _suivant.y);
	RiviereVoisinClearTwin(_voisins, _suivant);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if (_voisin.object_index == oRiviere)
		{
			if (IsState(RIVIERE_STATE.REMPLI, _voisin) or IsState(RIVIERE_STATE.REMPLISSAGE, _voisin))
			{
				SetState(RIVIERE_STATE.VIDAGE, _voisin);
				
				//_voisin.image_index = 0; // On remet à 0 l'animation pour que le vidage soit bien synchro
				
				EcluseVidageTotal(_voisin);
			}
		}
	}
}

function EcluseRechercheCascade(_suivant, _precedent, _riviere)
{
	show_debug_message(_riviere);
	var _voisins = GridGetVoisins(_suivant.x, _suivant.y);
	RiviereVoisinClearTwin(_voisins, _suivant);

	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		// On ne veut pas continuer le parcours sur le précédent
		// On s'arrete sur le départ
		if ((_voisin == GetNull()) or (_voisin == _precedent))	continue;
		if (EcluseAlreadyRiviere(_voisin, _riviere))			continue; // On s'arrête si on est sur un croisement déjà traversé (évite les boucles infinies)
		
		if (_voisin.object_index == oRiviere)
		{
			if (IsState(RIVIERE_STATE.REMPLI, _voisin) or IsState(RIVIERE_STATE.REMPLISSAGE, _voisin))
			{
				if (_voisin.riviereType >= RIVIERE_TYPE.T_BAS) // On sauvegarde les croisements
				{
					// Copie des croisement déjà traversés
					var _tailleRiviere = array_length(_riviere);
					var _riviereCopy = array_create(_tailleRiviere + 1);
				
					for (var _j = 0; _j < _tailleRiviere; _j++)
					{
					   _riviereCopy[_j] = _riviere[_j];
					}
					_riviereCopy[_tailleRiviere] = _voisin;
				
					// Continue le chemin en ajoutant le croisement qui vient d'être traversée
					if (EcluseRechercheCascade(_voisin, _suivant, _riviereCopy)) return 1;
				}
				else
				{
					if (EcluseRechercheCascade(_voisin, _suivant, _riviere)) return 1;
				}
			}
		}
		else if (_voisin.object_index == oCascade)
		{
			return 1;
		}
	}
	
	return 0;
}

function EcluseAlreadyRiviere(_voisin, _riviere)
{
	for (var _j = 0; _j < array_length(_riviere); _j++)
	{
		if (_voisin == _riviere[_j]) // Si c'est un croisement par lequelle on est déjà passé
		{
			return true;
		}
	}
	
	return false;
}

