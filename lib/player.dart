part of webrpg;

typedef bool OnActivate();
typedef bool OnNextCharacter();

/**
 * Handles key presses and movement
 */

class Player
{
  OnActivate activationListener;
  OnNextCharacter nextCharacterListener;
  
  //holds keys that are currently being pressed
  List<MoveDirection> keydown = new List();
  
  Player(this.activationListener, this.nextCharacterListener);
  
  MoveDirection getMove()
  {
    if(keydown.isEmpty)
      return null;
    //handle the key that was pressed last
    return keydown.last;
  }
  
  bool handleKey(int key, bool down)
  {
    if((key == 13 || key == 81) && down) //enter & e
      return activationListener();
    
    if((key == 9) && down) //tab
      return nextCharacterListener();

    MoveDirection index = null;
    if(key == 37)//left & a
      index = MoveDirection.Left;
    else if(key == 39)//right & d
      index = MoveDirection.Right;
    else if(key == 38)//up & w
      index = MoveDirection.Up;
    else if(key == 40)//down & s
      index = MoveDirection.Down;

    if(index == null)
      return false;
    
    keydown.remove(index);
    if(down == true)
      keydown.add(index);
    return true;
  }
  
  //force movement
  void setMove(MoveDirection m, [removeothers = true])
  {
    if(removeothers)
      keydown.clear();
    keydown.add(m);
  }
  void clearMove()
  {
      keydown.clear();
  }
}