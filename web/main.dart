import 'dart:html' hide Animation;
import 'package:webrpg/webrpg.dart';

void main() 
{
  List<Character> characters = [
    new CharacterWithImage(new Position(window.innerWidth~/2,100), "character.png", new Dimensions(22,39), new Position(10,34))
  ];
  new WebRPG(characters);
}

