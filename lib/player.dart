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
  List<MOVE> keydown = new List();
  
  Player(this.activationListener, this.nextCharacterListener);
  
  MOVE getMove()
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

    MOVE index = null;
    if(key == 37)//left & a
      index = MOVE.LEFT;
    else if(key == 39)//right & d
      index = MOVE.RIGHT;
    else if(key == 38)//up & w
      index = MOVE.UP;
    else if(key == 40)//down & s
      index = MOVE.DOWN;

    if(index == null)
      return false;
    
    keydown.remove(index);
    if(down == true)
      keydown.add(index);
    return true;
  }
  
  //force movement
  void setMove(MOVE m, [removeothers = true])
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