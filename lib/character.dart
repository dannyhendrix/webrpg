part of webrpg;

abstract class Character
{
  DivElement el_character;

  final List<String> _allowActive = ["a","input","button","textarea"];

  final Position position;
  //collision (or center) point of the character that is being used to determine the DOM elment that is below the character
  final Position collision = new Position(1337,16);
  //dimension of 1 frame
  final Dimensions dimension = new Position(32,32);
  //start position of the first frame in the image
  final Position imageStart = new Position(0,0);
  //animations info
  Animation animationDefault = const Animation(const [0]);
  Animation animationWalk = const Animation(const [0]);
  
  //rectangular field in which the character can walk
  final Area border = new windowArea();

  //state
  CharacterState currentState = CharacterState.Default;
  MoveDirection currentMove = MoveDirection.Down;
  //current animation and frame
  Animation currentAnimation;
  int animationFrame = 0;
  //ticks since last frame change
  int imageTime = 0;
  //how many ticks before going to next frame in animation
  int frameTimer = 10;
  
  //element below the character
  Element el_hover = null;
  //element below the character that can be activated (_allowActive)
  Element el_active = null;

  int stepSize = 6;
  //highlight style of elements when the character is placed over them
  String hoverStyle;
  String backupStyle;
  
  //map movement to the correct row of frames in the image.
  //i.e. if the top row is the character walking to the right; MOVE.RIGHT:0
  Map<MoveDirection,int> moveToFrameMapping = {MoveDirection.Up:0,MoveDirection.Left:1,MoveDirection.Down:2,MoveDirection.Right:3};
  
  Character(this.position);

  init()
  {
    currentAnimation = animationDefault;
    //create DOM element
    el_character = createCharacterElement();
    updateElementPosition();
  }

  Element createCharacterElement()
  {
    Element el = new DivElement();
    el.className = "webrpg_character";
    return el;
  }
  
  void setAsCurrentCharacter()
  {
    el_character.style.zIndex = "100001";
  }
  void unsetAsCurrentCharacter()
  {
    el_character.style.zIndex = "100000";
  }
  
  void updateElementPosition()
  {
    el_character.style.top = "${position.y-collision.y}px";
    el_character.style.left = "${position.x-collision.x}px";
    scrollWindow();
  }
  
  void onUpdateNotMoving()
  {
    _setImage(animationDefault,currentMove);
  }
  
  void onUpdateMove(MoveDirection move)
  {
    currentMove = move;
    Point bk = new Point(position.x,position.y);
    //update position
    switch(move)
    {
      case MoveDirection.Up:
        position.y -= stepSize;
        break;
      case MoveDirection.Down:
        position.y += stepSize;
        break;
      case MoveDirection.Left:
        position.x -= stepSize;
        break;
      case MoveDirection.Right:
        position.x += stepSize;
        break;
    }
    if(border != null)
      border.stayWithinArea(position);
    bool moved = bk.x != position.x || bk.y != position.y;
    
    if(!moved)
    {
      _setImage(animationDefault, move);
      return;
    }
    //change image frame
    _setImage(animationWalk, move);

    //move div element
    updateElementPosition();
  }
  
  void update(MoveDirection move)
  {
    if(move == null)
      onUpdateNotMoving();
    else
    {
      onUpdateMove(move);
      setHoverElement();
    }
  }
  
  void hideElement(bool hide)
  {
    el_character.hidden = hide;
  }
  
  void _setImage(Animation newanim, MoveDirection move)
  {
    if(newanim != currentAnimation)
    {
      currentAnimation = newanim;
      animationFrame = 0;
    }
    else
    {
      if(imageTime++ < frameTimer)
        return;
      animationFrame++;
      
      if(animationFrame >= currentAnimation.frames.length)
        animationFrame = 0;
    }
    imageTime = 0;

    int frameh = moveToFrameMapping[move];
    //set frame image
    el_character.style.backgroundPosition = "-${imageStart.x+dimension.x*currentAnimation.frames[animationFrame]}px -${imageStart.y+dimension.y*frameh}px";
  }
  
  //hover element
  void setHoverElement()
  {
    //get the element at a specific (x,y) cordinate
    //the character element is on top, make it temporarily hidden
    //TODO: other characters might still be on top :p
    hideElement(true);
    Element el = document.elementFromPoint(position.x-window.pageXOffset, position.y-window.pageYOffset);
    hideElement(false);
    
    //only continue if the character moved to a different element
    if(el == el_hover)
      return;
    
    //restore old active element's style
    if(el_active != null)
      restoreStyleOfPreviousActiveElement(el_active);
    
    el_hover = el;
    //is the character on any element
    if(el_hover == null)
      return;
    
    //find active element
    while(el != null && !_allowActive.contains(el.tagName.toLowerCase()))
      el = el.parent;
    
    el_active = el;
    if(el == null)
      return;
    
    //highlight active element
    setStyleToActiveElement(el);
  }
  
  void setStyleToActiveElement(Element el)
  {
    //backup previous style of the element
    backupStyle = el.getAttribute("style");
    if(backupStyle == null)
      backupStyle = "";
    
    el.setAttribute("style","$backupStyle; $hoverStyle");
  }
  
  void restoreStyleOfPreviousActiveElement(Element el)
  {
    el.setAttribute("style", backupStyle);
  }
  
  bool activateCurrent()
  {
    if(el_active == null)
      return false;
    
    if(!el_active.attributes.containsKey("href"))
      el_active.click();
    else if (window.confirm("Go to "+el_active.getAttribute("href")+"?"))
      el_active.click();
    return true;
  }

  //scroll window according to the character
  void scrollWindow()
  {
    if(position.y+(dimension.y-collision.y) > window.innerHeight+window.pageYOffset)
      window.scroll(window.pageXOffset,position.y+(dimension.y-collision.y)-window.innerHeight);
    if(position.y-dimension.y-window.pageYOffset < 0)
      window.scroll(window.pageXOffset,position.y-dimension.y);
    if(position.x+(dimension.x-collision.x) > window.innerWidth+window.pageXOffset)
      window.scroll(position.x+(dimension.x-collision.x)-window.innerWidth,window.pageYOffset);
    if(position.x-dimension.x-window.pageXOffset < 0)
      window.scroll(position.x-dimension.x,window.pageYOffset);
  }
}

class CharacterWithImage extends Character
{
  final String imageSource;
  @override
  final Dimensions dimension;
  @override
  final Position collision;
  @override
  final Position imageStart = new Position(0,0);
  @override
  String hoverStyle = "outline:5px solid #DF8B30;";
  @override
  Animation animationDefault = const Animation(const [0,1,2]);
  @override
  Animation animationWalk = const Animation(const [3,4,5]);
  @override
  int stepSize = 2;
  @override
  int frameTimer = 6;

  CharacterWithImage(Position position, this.imageSource, this.dimension, this.collision) : super(position);

  @override
  Element createCharacterElement()
  {
    Element el = new DivElement();
    el.className = "webrpg_character";
    el.setAttribute("style", 'background:url("$imageSource"); z-index:100000; position:absolute; width:${dimension.x}px; height:${dimension.y}px;');
    return el;
  }
}