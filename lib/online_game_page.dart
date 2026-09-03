import 'package:flutter/material.dart';
import 'services/firebase_multiplayer_service.dart';

class OnlineGamePage extends StatefulWidget {
  final String code; final FirebaseMultiplayerService service;
  const OnlineGamePage({super.key, required this.code, required this.service});
  @override State<OnlineGamePage> createState()=>_OnlineGamePageState();
}
class _OnlineGamePageState extends State<OnlineGamePage>{
  bool sending=false; String message='Synchronizing match...';
  Future<void> _shot() async { if(sending)return; setState(()=>sending=true); try{ await widget.service.submitMove(widget.code, {'type':'shot','angle':0.0,'power':0.7,'sequence':DateTime.now().microsecondsSinceEpoch}); setState(()=>message='Shot sent. Waiting for authoritative state.'); } catch(e){setState(()=>message='$e');} finally {if(mounted)setState(()=>sending=false);} }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Online Match')),body:StreamBuilder<OnlineRoom?>(stream:widget.service.watchRoom(widget.code),builder:(c,s){final room=s.data; final board=room?.board??{}; return Padding(padding:const EdgeInsets.all(20),child:Column(children:[Text(room==null?'Connecting...':'Room ${widget.code}',style:const TextStyle(fontSize:22,fontWeight:FontWeight.bold)),const SizedBox(height:12),Text('Players: ${room?.players.length??0}/2'),const SizedBox(height:12),Text('Last event: ${board['lastMove'] ?? 'No shot yet'}'),const Spacer(),Container(height:360,width:double.infinity,decoration:BoxDecoration(color:const Color(0xFFD7A86B),borderRadius:BorderRadius.circular(20),border:Border.all(color:const Color(0xFF3D2818),width:14)),child:const Center(child:Text('ONLINE CARROM BOARD\nPhysics state synchronization next',textAlign:TextAlign.center,style:TextStyle(color:Colors.black,fontSize:22,fontWeight:FontWeight.bold)))),const SizedBox(height:16),Text(message,textAlign:TextAlign.center),const SizedBox(height:12),SizedBox(width:double.infinity,height:56,child:ElevatedButton(onPressed:sending?null:_shot,child:Text(sending?'SENDING...':'TAKE TEST SHOT')))]));}));
}
