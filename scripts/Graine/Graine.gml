enum GRAINE_STATE
{
	VIDE,
	POUSSE,
	MATURITE,
	COUPE
};

function GraineInit()
{
	SetState(GRAINE_STATE.VIDE);
	stateMachine[0] = GraineStateVide;
	stateMachine[1] = GraineStatePousse;
	stateMachine[2] = GraineStateMaturite;
	stateMachine[3] = GraineStateCoupe;
}

function GraineUpdate()
{
	script_execute(stateMachine[state]);
}


function GraineStateVide()
{
	
}

function GraineStatePousse()
{

}

function GraineStateMaturite()
{

}

function GraineStateCoupe()
{
	
}
