import 'package:flutter/material.dart';
import 'services/firebase_multiplayer_service.dart';
import 'online_game_page.dart';

const _gold = Color(0xFFF5C94C);
const _bg = Color(0xFF101114);
const _card = Color(0xFF202124);
const _muted = Color(0xFFB9B4A9);

class OnlineLobbyPage extends StatefulWidget {
  const OnlineLobbyPage({super.key});
  @override State<OnlineLobbyPage> createState() => _OnlineLobbyPageState();
}
class _OnlineLobbyPageState extends State<OnlineLobbyPage> {
  final service = FirebaseMultiplayerService.instance;
  final code = TextEditingController();
  bool busy = false;
  String? roomCode, error;
  @override void dispose(){code.dispose(); super.dispose();}
  Future<void> create() async {
    setState(()=>busy=true);
    try { final room=await service.createRoom(); if(mounted)setState(()=>roomCode=room.code); }
    catch(e){if(mounted)setState(()=>error='$e');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  Future<void> join() async {
    if(code.text.trim().length!=6){setState(()=>error='Enter a valid 6-digit room code');return;}
    setState(()=>busy=true);
    try {await service.joinRoom(code.text.trim()); if(mounted)setState(()=>roomCode=code.text.trim());}
    catch(e){if(mounted)setState(()=>error='$e');}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context){
    if(roomCode!=null)return OnlineRoomPage(code:roomCode!,service:service);
    return Scaffold(backgroundColor:_bg,appBar:AppBar(backgroundColor:_bg,title:const Text('Online Match')),
      body:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        const Icon(Icons.public,color:_gold,size:70),const SizedBox(height:16),
        const Text('Play Online',textAlign:TextAlign.center,style:TextStyle(fontSize:34,fontWeight:FontWeight.w900)),
        const SizedBox(height:10),const Text('Create a room or join a friend with a 6-digit code.',textAlign:TextAlign.center,style:TextStyle(color:_muted)),
        const SizedBox(height:32),ElevatedButton.icon(onPressed:busy?null:create,icon:const Icon(Icons.add),label:const Text('CREATE ONLINE ROOM'),
          style:ElevatedButton.styleFrom(backgroundColor:_gold,foregroundColor:Colors.black,padding:const EdgeInsets.symmetric(vertical:18))),
        const SizedBox(height:28),TextField(controller:code,maxLength:6,keyboardType:TextInputType.number,
          decoration:InputDecoration(counterText:'',hintText:'000000',filled:true,fillColor:_card,border:OutlineInputBorder(borderRadius:BorderRadius.circular(18),borderSide:BorderSide.none))),
        const SizedBox(height:12),OutlinedButton.icon(onPressed:busy?null:join,icon:const Icon(Icons.login),label:const Text('JOIN ROOM'),
          style:OutlinedButton.styleFrom(foregroundColor:_gold,padding:const EdgeInsets.symmetric(vertical:17))),
        if(busy)const Padding(padding:EdgeInsets.all(24),child:Center(child:CircularProgressIndicator(color:_gold))),
        if(error!=null)Padding(padding:const EdgeInsets.all(12),child:Text(error!,textAlign:TextAlign.center,style:const TextStyle(color:Colors.redAccent)))
      ])));
  }
}
class OnlineRoomPage extends StatelessWidget {
  final String code; final FirebaseMultiplayerService service;
  const OnlineRoomPage({super.key,required this.code,required this.service});
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:_bg,appBar:AppBar(backgroundColor:_bg,title:const Text('Private Online Room')),
    body:StreamBuilder<OnlineRoom?>(stream:service.watchRoom(code),builder:(context,s){
      final room=s.data; return Padding(padding:const EdgeInsets.all(24),child:Column(children:[
        const Text('ROOM CODE',style:TextStyle(color:_gold,letterSpacing:2)),const SizedBox(height:8),
        SelectableText(code,style:const TextStyle(fontSize:48,fontWeight:FontWeight.w900,letterSpacing:8)),
        const SizedBox(height:16),Text(room==null?'LOADING...':room.status=='active'?'MATCH READY':'WAITING FOR OPPONENT',
          style:TextStyle(color:room?.status=='active'?_gold:_muted,fontWeight:FontWeight.w800)),
        const SizedBox(height:36),_PlayerTile(number:1,active:room?.players.isNotEmpty==true),const SizedBox(height:16),
        _PlayerTile(number:2,active:(room?.players.length??0)>1),const Spacer(),
        if(room?.status=='active')ElevatedButton.icon(onPressed:()=>service.submitMove(code,{'type':'ready'}),icon:const Icon(Icons.play_arrow),
          label:const Text('START ONLINE MATCH'),style:ElevatedButton.styleFrom(minimumSize:const Size.fromHeight(58),backgroundColor:_gold,foregroundColor:Colors.black)),
        const SizedBox(height:16),TextButton(onPressed:() async {await service.leaveRoom(code);if(context.mounted)Navigator.pop(context);},
          child:const Text('LEAVE ROOM',style:TextStyle(color:Colors.redAccent)))
      ]));}));
}
class _PlayerTile extends StatelessWidget {
  final int number; final bool active; const _PlayerTile({required this.number,required this.active});
  @override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:_card,borderRadius:BorderRadius.circular(18)),
    child:Row(children:[CircleAvatar(backgroundColor:active?_gold:Colors.grey.shade800,child:Icon(active?Icons.person:Icons.hourglass_empty,color:Colors.black)),
      const SizedBox(width:16),Expanded(child:Text(active?'Player $number connected':'Waiting for Player $number',style:const TextStyle(fontWeight:FontWeight.w700))),
      Icon(active?Icons.check_circle:Icons.more_horiz,color:active?_gold:_muted)]));
}
