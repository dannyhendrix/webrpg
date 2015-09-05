import 'dart:html' hide Animation;
import 'package:webrpg/webrpg.dart';

void main() 
{
  List<Character> characters = new List<Character>();
  characters.add(new Character(
      walkspeed:2,
      img:"character.png",
      position:new Cordinate(window.innerWidth~/2,100),
      dimension:new Cordinate(22,39),
      collision:new Cordinate(10,34),
      anim_default : const Animation(const [0,1,2]),
      anim_walk : const Animation(const [3,4,5]),
      moveToFrameMapping : {MOVE.UP:0,MOVE.LEFT:1,MOVE.DOWN:2,MOVE.RIGHT:3}
      ));
  new WebRPG(characters);
}

