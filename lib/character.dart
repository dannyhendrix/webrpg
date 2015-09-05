part of webrpg;

class Character
{
  DivElement el_character;
  
  List<String> _allowActive = ["A","INPUT","BUTTON","TEXTAREA"];
  
  Cordinate position;
  //collision (or center) point of the character
  Cordinate collision;
  //dimension of 1 frame
  Cordinate dimension;
  //start position of the first frame in the image
  Cordinate imgstart;
  //animations info
  Animation anim_walk, anim_default;
  
  //rectangular field in which the character can walk
  Cordinate fieldZero, fieldMax;
  
  //state
  STATE state = STATE.DEFAULT;
  MOVE currentmove = MOVE.DOWN;
  //current animation and frame
  Animation anim;
  int anim_frame = 0;
  //ticks since last frame change
  int imgtime = 0;
  //how many ticks before going to next frame in animation
  int frametimer;
  
  //element below the character
  Element el_hover = null;
  //element below the character that can be activated (_allowActive)
  Element el_active = null;

  int walkspeed;
  //highlight style of elements when the character is placed over them
  String hoverStyle;
  String backupStyle;
  
  //map movement to the correct row of frames in the image.
  //i.e. if the top row is the character walking to the right; MOVE.RIGHT:0
  Map<MOVE,int> moveToFrameMapping;
  
  Character({
    this.frametimer : 6, 
    this.walkspeed : 1, 
    String img : "images/character.png", 
    this.hoverStyle : "outline:5px solid #DF8B30;",
    this.position,
    this.dimension,
    this.collision,
    this.imgstart,
    this.fieldZero,
    this.fieldMax,
    this.anim_default : const Animation(const [0]),
    this.anim_walk : const Animation(const [2,0,1,0]),
    this.moveToFrameMapping
      })
  {
    //My cordinates are not constants :/
   if(position == null)
      position = new Cordinate(0,0);
   if(dimension == null)
     dimension = new Cordinate(32,48);
   if(collision == null)
     collision = new Cordinate(16,40);
   if(imgstart == null)
      imgstart = new Cordinate(0,0);
   if(fieldZero == null)
     fieldZero = new Cordinate(0,0);
   //if(fieldMax == null) //null is no border
   //  fieldMax = new Cordinate(400,800);
   if(moveToFrameMapping == null)
   {
     moveToFrameMapping = new Map<MOVE,int>();
     int i = 0;
     for(MOVE m in MOVE.values)
       moveToFrameMapping[m] = i++;
    }
   
    //set default animation
    anim = anim_default;
   
    //create DOM element
    el_character = new DivElement();
    el_character.setAttribute("style", 'background:url("$img"); z-index:100000; position:absolute; width:${dimension.x}px; height:${dimension.y}px;');
    updateElementPosition();
  }
  
  void setAsCurrentCharacter()
  {
    el_character.style.zIndex = "100001";
  }
  void unsetAsCurrentCharacter()
  {
    el_character.style.zIndex = "100000";
  }
  
  void checkBounds()
  {
    if(position.x < fieldZero.x)
      position.x = fieldZero.x;
    if(position.y < fieldZero.y)
      position.y = fieldZero.y;
    
    if(fieldMax != null)
    {
      if(position.x > fieldMax.x)
        position.x = fieldMax.x;
      if(position.y > fieldMax.y)
        position.y = fieldMax.y;
    }
  }
  
  void updateElementPosition()
  {
    el_character.style.top = "${position.y-collision.y}px";
    el_character.style.left = "${position.x-collision.x}px";
    
    scrollWindow();
  }
  
  void onUpdateNotMoving()
  {
    _setImage(anim_default,currentmove);
  }
  
  void onUpdateMove(MOVE move)
  {
    currentmove = move;
    Point bk = new Point(position.x,position.y);
    //update position
    switch(move)
    {
      case MOVE.UP:
        position.y -= walkspeed;
        break;
      case MOVE.DOWN:
        position.y += walkspeed;
        break;
      case MOVE.LEFT:
        position.x -= walkspeed;
        break;
      case MOVE.RIGHT:
        position.x += walkspeed;
        break;
    }
    checkBounds();
    bool moved = bk.x != position.x || bk.y != position.y;
    
    if(!moved)
    {
      _setImage(anim_default, move);
      return;
    }
    //change image frame
    _setImage(anim_walk, move);

    //move div element
    updateElementPosition();
  }
  
  void update(MOVE move)
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
  
  void _setImage(Animation newanim, MOVE move)
  {
    if(newanim != anim)
    {
      anim = newanim;
      anim_frame = 0;
    }
    else
    {
      if(imgtime++ < frametimer)
        return;
      anim_frame++;
      
      if(anim_frame >= anim.frames.length)
        anim_frame = 0;
    }
    imgtime = 0;

    int frameh = moveToFrameMapping[move];
    //set frame image
    el_character.style.backgroundPosition = "-${imgstart.x+dimension.x*anim.frames[anim_frame]}px -${imgstart.y+dimension.y*frameh}px";
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
    while(el != null && _allowActive.indexOf(el.tagName) == -1)
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