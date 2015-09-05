library webrpg;

import "dart:html";

part "player.dart";
part "character.dart";

const int ORIENTATION_BOUND = 10;

enum MOVE {DOWN, LEFT, RIGHT, UP}
enum STATE {DEFAULT, WALK}

class Animation
{
  final List<int> frames;
  final bool repeat;

  const Animation(this.frames,[this.repeat = true]);
}

class Cordinate
{
  int x,y;
  Cordinate(this.x,this.y);
}

class WebRPG
{
  int lasttime = 0;
  Player player;
  List<Character> characters;
  int _character = 0;
  
  get currentcharacter => characters[_character];
  
  WebRPG(this.characters,{bool enableOrientation : true, bool autostart : true})
  {
    //append characters to dom
    for(Character c in characters)
      document.body.append(c.el_character);

    player = new Player(onActivate,onNextChar);
    
    window.onKeyDown.listen((KeyboardEvent e){
      if(player.handleKey(e.keyCode, true))
        e.preventDefault();
    });
    window.onKeyUp.listen((KeyboardEvent e){
      if(player.handleKey(e.keyCode, false))
        e.preventDefault();
    });
    
    //use orientation in mobile devices for movement
    if(enableOrientation)
      setupOrientation();
    
    currentcharacter.setAsCurrentCharacter();

    //start
    if(autostart)
      start();
  }
  
  void start()
  {
    window.requestAnimationFrame(loop);
  }
  
  bool onActivate()
  {
    return currentcharacter.activateCurrent();
  }
  
  bool onNextChar()
  {
    if(characters.length <= 1)
       return false;
    currentcharacter.unsetAsCurrentCharacter();
    _character++;
    if(_character == characters.length)
      _character = 0;
    currentcharacter.setAsCurrentCharacter();
    return true;
  }
  
  void loop(double looptime)
  {
    for(Character c in characters)
      if (c == currentcharacter)
        c.update(player.getMove());
      else
        c.update(null);
    
    window.requestAnimationFrame(loop);
  }
  
  
  
  
  /** Mobile devices that support orientation **/
  void setupOrientation()
  {
    //create a button to activate the DOM element
    createActivateButton();
    
    window.onDeviceOrientation.listen((DeviceOrientationEvent e){
      if(e.gamma == null)
        return;
            
      int orientation = window.orientation;
      if(orientation < 0)
        orientation += 360;
      //gamma moves left/right
      //beta moves up/down
      if(orientation == 0)
      {
        if(e.gamma.abs() > e.beta.abs())
            handleOrientation(e.gamma, MOVE.LEFT, MOVE.RIGHT);
        else
            handleOrientation(e.beta, MOVE.UP, MOVE.DOWN);
      }
      if(orientation == 180)
      {
        if(e.gamma.abs() > e.beta.abs())
            handleOrientation(e.gamma, MOVE.RIGHT, MOVE.LEFT);
        else
            handleOrientation(e.beta, MOVE.DOWN, MOVE.UP);
      }
      if(orientation == 90)
      {
        if(e.gamma.abs() > e.beta.abs())
            handleOrientation(e.gamma, MOVE.DOWN, MOVE.UP);
        else
            handleOrientation(e.beta, MOVE.LEFT, MOVE.RIGHT);
      }
      if(orientation == 270)
      {
        if(e.gamma.abs() > e.beta.abs())
            handleOrientation(e.gamma, MOVE.UP, MOVE.DOWN);
        else
            handleOrientation(e.beta, MOVE.RIGHT, MOVE.LEFT);
      }
    });
  }
  
  void handleOrientation(double val, MOVE neg, MOVE pos)
  {
    if(val.abs() < ORIENTATION_BOUND)
    {
      player.clearMove();
      return;
    }
    if(val < 0)
      player.setMove(neg);
    else
      player.setMove(pos);
  }
  
  /**
   * Normally pressing enter would activate the active element, with modile devices there is no enter; use a manual button instead
   */
  void createActivateButton()
  {
    DivElement el_btn = new DivElement();
    el_btn.text = "Activate";
    el_btn.setAttribute("style", 'background:rgba(0,0,0,0.5); z-index:100000; position:fixed; right:0px; top:0px; bottom:0px; color:white; padding:0px 20px');
    document.body.append(el_btn);
    
    el_btn.onTouchStart.listen((TouchEvent e){
      onActivate();
    });
    el_btn.onClick.listen((Event e){
      onActivate();
    });
  }
}