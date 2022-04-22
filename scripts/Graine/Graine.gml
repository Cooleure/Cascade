#macro NB_GRAINE 4

#macro CAROTTE_DUREE 20 // En secondes
#macro CAROTTE_ENERGIE 30
#macro POIREAU_DUREE 10
#macro POIREAU_ENERGIE 10
#macro COURGE_DUREE 30
#macro COURGE_ENERGIE 50
#macro CANNABIS_DUREE 10
#macro CANNABIS_ENERGIE -100


enum GRAINE_STATE
{
	VIDE,
	POUSSE_DEBUT,
	POUSSE_FIN,
	MATURITE,
	COUPE
};

enum TYPE_GRAINE
{
	CAROTTE,
	POIREAU,
	COURGE,
	CANABIS
};

function GraineInit()
{
	SetState(GRAINE_STATE.VIDE);
	stateMachine[0] = GraineStateVide;
	stateMachine[1] = GraineStatePousseDebut;
	stateMachine[2] = GraineStatePousseFin
	stateMachine[3] = GraineStateMaturite;
	stateMachine[4] = GraineStateCoupe;
}

function GraineUpdate()
{
	script_execute(stateMachine[state]);
}


function GraineStateVide()
{
	switch (irandom(2))
	{
		case 0: sprite_index = sGraineTerreau1; break;
		case 1: sprite_index = sGraineTerreau2; break;
		case 2: sprite_index = sGraineTerreau3; break;
	}
	
	var _idGraine = irandom(NB_GRAINE - 1);
	
	switch (_idGraine)
	{
		case TYPE_GRAINE.CAROTTE:
			spritePousse = sGraineCarottePousse;
			spriteMaturite = sGraineCarotteMaturite;
			duree = CAROTTE_DUREE;
			energie = CAROTTE_ENERGIE;
			break;
			
		case TYPE_GRAINE.POIREAU:
			spritePousse = sGrainePoireauPousse;
			spriteMaturite = sGrainePoireauMaturite;
			duree = POIREAU_DUREE;
			energie = POIREAU_ENERGIE;
			break;
			
		case TYPE_GRAINE.COURGE:
			spritePousse = sGraineCourge1;
			spriteMaturite = sGraineCourge2;
			duree = COURGE_DUREE;
			energie = COURGE_ENERGIE;
			break;
			
		case TYPE_GRAINE.CANABIS:
			spritePousse = sGraineCanabis1;
			spriteMaturite = sGraineCanabis2;
			duree = CANNABIS_DUREE;
			energie = CANNABIS_ENERGIE;
			break;
	}
	
	timer = 0;
	
	sprite = sVide;

	SetState(GRAINE_STATE.POUSSE_DEBUT);
}

function GraineStatePousseDebut()
{
	var _voisins = GridGetVoisins(x, y);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if ((_voisin.object_index == oRiviere) and IsState(RIVIERE_STATE.REMPLI, _voisin))
		{
			timer++;
			break;
		}
	}
	
	if (timer > (duree * room_speed) div 2)
	{
		SetState(GRAINE_STATE.POUSSE_FIN);
	}
	
	sprite = sVide;
}

function GraineStatePousseFin()
{
	var _voisins = GridGetVoisins(x, y);
	
	for (var _i = 0; _i < 4; _i++)
	{
		var _voisin = _voisins[_i];
		
		if (_voisin == GetNull()) continue;
		
		if ((_voisin.object_index == oRiviere) and IsState(RIVIERE_STATE.REMPLI, _voisin))
		{
			timer++;
			break;
		}
	}
	
	if (timer >= duree * room_speed)
	{
		SetState(GRAINE_STATE.MATURITE);
	}
	
	sprite = spritePousse;
}

function GraineStateMaturite()
{
	sprite = spriteMaturite;
}

function GraineStateCoupe()
{
	sprite_index = sVide;
}

function GraineDraw()
{
	draw_self();
	
	if (!IsState(GRAINE_STATE.COUPE))
	{
		draw_sprite(sprite, 0, x, y);
	}
}

function GraineMouseLeftPressed()
{
	if (IsState(GRAINE_STATE.POUSSE_FIN))
	{
		SetState(GRAINE_STATE.COUPE);
		
		alarm[0] = 10 * room_speed;
		
		audio_play_sound(sndCoupe, 10, false);
	}
	else if (IsState(GRAINE_STATE.MATURITE))
	{
		EnergieAdd(energie);
		
		SetState(GRAINE_STATE.COUPE);
		
		alarm[0] = 10 * room_speed;
		
		audio_play_sound(sndCoupe, 10, false);
	}
}
