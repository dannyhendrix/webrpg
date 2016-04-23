library webrpg;

import "dart:html";

part "player.dart";
part "character.dart";

const int orientation_bound = 10;

enum MoveDirection {Down, Left, Right, Up}
enum CharacterState {Default, Walk}

class Animation
{
  final List<int> frames;
  final bool repeat;

  const Animation(this.frames,[this.repeat = true]);
}

class Position
{
  int x,y;
  Position(this.x,this.y);
}

class Dimensions extends Position
{
  Dimensions(int x, int y) : super(x,y);
}

class Area
{
  int x,y,w,h;
  Area(this.x, this.y, this.w, this.h);
  Area.fromZero(this.w, this.h) : x=0, y=0;
  bool inArea(Position p)
  {
    return p.x > x && p.x < x+w && p.y > y && p.y < y+h;
  }
  void stayWithinArea(Position p)
  {
    if(p.x < x)
      p.x = x;
    if(p.y < y)
      p.y = y;
    if(p.x > x+w)
      p.x = x+w;
    if(p.y > y+h)
      p.y = y+h;
  }
}

class windowArea extends Area
{
  int offsetLeft, offsetTop, offsetRight, offsetBottom;
  int get w => document.body.offsetWidth - offsetRight - offsetLeft;
  int get h => document.body.offsetHeight - offsetBottom - offsetTop;
  int get x => offsetLeft;
  int get y => offsetTop;
  windowArea([this.offsetLeft = 0, this.offsetTop = 0, this.offsetRight = 0, this.offsetBottom = 0]) : super(0,0,null,null);
  windowArea.withOffset(int offset) : offsetRight = offset, offsetBottom = offset, super(offset,offset,null,null);
}

class WebRPG
{
  int lastTime = 0;
  Player player;
  List<Character> characters;
  int _currentCharacterIndex = 0;
  
  get currentCharacter => characters[_currentCharacterIndex];
  
  WebRPG(this.characters,{bool enableOrientation : true, bool autoStart : true})
  {
    //append characters to dom
    for(Character c in characters)
    {
      c.init();
      document.body.append(c.el_character);
    }

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
    
    currentCharacter.setAsCurrentCharacter();

    //start
    if(autoStart)
      start();
  }
  
  void start()
  {
    window.requestAnimationFrame(loop);
  }
  
  bool onActivate()
  {
    return currentCharacter.activateCurrent();
  }
  
  bool onNextChar()
  {
    if(characters.length <= 1)
       return false;
    currentCharacter.unsetAsCurrentCharacter();
    _currentCharacterIndex++;
    if(_currentCharacterIndex == characters.length)
      _currentCharacterIndex = 0;
    currentCharacter.setAsCurrentCharacter();
    return true;
  }
  
  void loop(double loopTime)
  {
    for(Character c in characters)
      if (c == currentCharacter)
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
            handleOrientation(e.gamma, MoveDirection.Left, MoveDirection.Right);
        else
            handleOrientation(e.beta, MoveDirection.Up, MoveDirection.Down);
      }
      if(orientation == 180)
      {
        if(e.gamma.abs() > e.beta.abs())
            handleOrientation(e.gamma, MoveDirection.Right, MoveDirection.Left);
        else
            handleOrientation(e.beta, MoveDirection.Down, MoveDirection.Up);
      }
      if(orientation == 90)
      {
        if(e.gamma.abs() > e.beta.abs())
            handleOrientation(e.gamma, MoveDirection.Down, MoveDirection.Up);
        else
            handleOrientation(e.beta, MoveDirection.Left, MoveDirection.Right);
      }
      if(orientation == 270)
      {
        if(e.gamma.abs() > e.beta.abs())
            handleOrientation(e.gamma, MoveDirection.Up, MoveDirection.Down);
        else
            handleOrientation(e.beta, MoveDirection.Right, MoveDirection.Left);
      }
    });
  }
  
  void handleOrientation(double val, MoveDirection neg, MoveDirection pos)
  {
    if(val.abs() < orientation_bound)
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