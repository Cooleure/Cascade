// Script assets have changed for v2.3.0 see
/// STATES

// Set le state à la valeur donnée en paramètre
function SetState(_state, _object = self)
{
	_object.state = _state;
}

// Vérifie le state à la valeur donnée en paramètre
function IsState(_state, _object = self)
{
	return (_object.state == _state);
}

// Renvoie le state de l'instance donnée
function GetState(_object)
{
	return _object.state;
}
