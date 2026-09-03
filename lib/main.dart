import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'models/carrom_rules.dart';
import 'models/game_models.dart';
import 'services/game_feedback.dart';
import 'services/settings_service.dart';
import 'online_lobby.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CarromArenaApp());
}

const gold = Color(0xFFF5C94C);
const bg = Color(0xFF101114);
const card = Color(0xFF202124);
const textMuted = Color(0xFFB9B4A9);

class CarromArenaApp extends StatelessWidget {
  const CarromArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrom Arena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gold,
          brightness: Brightness.dark,
          surface: card,
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;
  final pages = const [
    HomePage(),
    PlayPage(),
    SocialPage(),
    TournamentsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        height: 76,
        backgroundColor: bg,
        indicatorColor: const Color(0xFF332B12),
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports), label: 'Play'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people), label: 'Social'),
          NavigationDestination(icon: Icon(Icons.emoji_events_outlined), selectedIcon: Icon(Icons.emoji_events), label: 'Tourney'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  final String title;
  const TopBar(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: card, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: gold.withOpacity(.35)),
            ),
            child: const Icon(Icons.sports_baseball, color: gold),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: gold))),
          const CircleAvatar(radius: 25, backgroundColor: card, child: Icon(Icons.notifications_none, color: gold)),
          const SizedBox(width: 12),
          const CircleAvatar(radius: 23, backgroundColor: Color(0xFF393939), child: Icon(Icons.person, color: gold)),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const AppCard({required this.child, this.onTap, super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: card,
    borderRadius: BorderRadius.circular(22),
    child: InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(22), child: child),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const TopBar('Home'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 26),
          child: AppCard(
            child: Row(children: [
              CircleAvatar(radius: 42, backgroundColor: gold, child: Icon(Icons.person, size: 48, color: bg)),
              SizedBox(width: 20),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Guest Player', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('🏅 1000 Rating', style: TextStyle(color: gold, fontSize: 17)),
              ])),
              Chip(label: Text('LVL 1')),
            ]),
          ),
        ),
        const SizedBox(height: 70),
        Center(
          child: Container(
            width: 270, height: 270,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(colors: [Color(0xFFFFE88C), Color(0xFFC28A12)]), boxShadow: [BoxShadow(color: gold.withOpacity(.35), blurRadius: 40)]),
            child: const Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Play Carrom', style: TextStyle(fontSize: 40, color: bg, fontWeight: FontWeight.w900)),
              SizedBox(height: 12),
              Text('PLAY NOW', style: TextStyle(fontSize: 24, color: bg, fontWeight: FontWeight.w800)),
              SizedBox(height: 12),
              Chip(label: Text('ONLINE MATCH')),
            ]),
          ),
        ),
        const SizedBox(height: 60),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Game Modes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800))),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(children: [
            ModeTile(icon: Icons.track_changes, title: 'Practice', subtitle: 'Hone your skills offline'),
            ModeTile(icon: Icons.smart_toy_outlined, title: 'VS AI', subtitle: 'Play against bot levels', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DifficultyPage()))),
            const ModeTile(icon: Icons.people_outline, title: 'Pass & Play', subtitle: 'Local multiplayer'),
          ]),
        ),
      ],
    );
  }
}

class ModeTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback? onTap;
  const ModeTile({required this.icon, required this.title, required this.subtitle, this.onTap, super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: AppCard(
      onTap: onTap,
      child: Row(children: [
        CircleAvatar(radius: 31, backgroundColor: const Color(0xFF292A2E), child: Icon(icon, color: gold)),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 5),
          Text(subtitle, style: const TextStyle(fontSize: 16, color: textMuted)),
        ])),
        const Icon(Icons.chevron_right, size: 32),
      ]),
    ),
  );
}

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      const TopBar('Play'),
      const Padding(padding: EdgeInsets.all(26), child: Text('Select Game Mode', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Choose how you want to play today.', style: TextStyle(fontSize: 18, color: textMuted))),
      const SizedBox(height: 28),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 26), child: Column(children: [
        ModeTile(icon: Icons.track_changes, title: 'Practice', subtitle: 'Hone your skills solo without timers', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamePage(difficulty: 'Practice')))),
        ModeTile(icon: Icons.smart_toy_outlined, title: 'VS AI', subtitle: 'Test your strategy against increasing difficulty', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DifficultyPage()))),
        ModeTile(icon: Icons.public, title: 'Quick Match', subtitle: 'Find a live online opponent', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineLobbyPage()))),
        ModeTile(icon: Icons.vpn_key_outlined, title: 'Private Room', subtitle: 'Create or join with a room code', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoomPage()))),
      ])),
    ],
  );
}

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      const TopBar('Social'),
      const Padding(padding: EdgeInsets.all(26), child: Row(children: [
        Chip(label: Text('Friends (12)')),
        SizedBox(width: 16),
        Text('Online (4)', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 24),
        Text('Recent', style: TextStyle(fontWeight: FontWeight.bold)),
      ])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 26), child: TextField(
        decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search players...', filled: true, fillColor: card, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none)),
      )),
      const SizedBox(height: 20),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 26), child: Column(children: const [
        FriendTile(name: 'ShadowStriker', status: 'Grandmaster Division', action: 'Challenge', online: true),
        FriendTile(name: 'QueenPocket', status: 'Master League', action: 'Challenge', online: true),
        FriendTile(name: 'FlickMaster', status: 'In a Match (02:14)', action: 'Spectate', online: false),
        FriendTile(name: 'WoodBoardX', status: 'Offline (2h ago)', action: '', online: false),
      ])),
    ],
  );
}

class FriendTile extends StatelessWidget {
  final String name, status, action;
  final bool online;
  const FriendTile({required this.name, required this.status, required this.action, required this.online, super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: AppCard(child: Row(children: [
      CircleAvatar(radius: 30, backgroundColor: const Color(0xFF383838), child: const Icon(Icons.person)),
      const SizedBox(width: 18),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        Text(status, style: TextStyle(color: online ? textMuted : Colors.grey)),
      ])),
      if (action.isNotEmpty) FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: bg), child: Text(action)),
    ])),
  );
}

class TournamentsPage extends StatelessWidget {
  const TournamentsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(children: [
    const TopBar('Tournaments'),
    const Padding(padding: EdgeInsets.fromLTRB(26, 24, 26, 6), child: Text('Tournaments', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900))),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: Text('Compete in high-stakes professional carrom arenas.', style: TextStyle(fontSize: 18, color: textMuted))),
    const SizedBox(height: 24),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Chip(label: Text('LIVE')),
      SizedBox(height: 18),
      Text('Pro Master Series 2026', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      SizedBox(height: 12),
      Text('🪙 50K PRIZE    👥 64 PLAYERS'),
      SizedBox(height: 20),
      Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: null, child: Text('WATCH ▶'))),
    ]))),
    const SizedBox(height: 16),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 26), child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Weekend Qualifier #4', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
      SizedBox(height: 12),
      Text('🪙 10K   •   👥 32 PLAYERS   •   REGISTERED', style: TextStyle(color: gold)),
    ]))),
  ]);
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(children: [
    const TopBar('Profile'),
    Padding(padding: const EdgeInsets.all(26), child: Column(children: [
      const AppCard(child: Column(children: [
        CircleAvatar(radius: 72, backgroundColor: gold, child: Icon(Icons.person, size: 90, color: bg)),
        SizedBox(height: 16),
        Text('Guest Player', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 8),
        Chip(label: Text('⭐ Level 12 Pro')),
        SizedBox(height: 20),
        LinearProgressIndicator(value: .75, minHeight: 14),
        SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('LVL 12'), Text('4,500 / 6,000 XP')]),
      ])),
      const SizedBox(height: 18),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14,
        childAspectRatio: 1.3,
        children: const [
          StatTile(icon: Icons.emoji_events, value: '142', label: 'WINS'),
          StatTile(icon: Icons.trending_up, value: '71%', label: 'WIN RATE'),
          StatTile(icon: Icons.local_fire_department, value: '5', label: 'HOT STREAK'),
          StatTile(icon: Icons.thumb_down_alt_outlined, value: '58', label: 'LOSSES'),
        ],
      ),
      const SizedBox(height: 28),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Achievements', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)), Text('VIEW ALL', style: TextStyle(color: gold))]),
      const SizedBox(height: 16),
      Row(children: const [
        Expanded(child: Achievement(title: 'First Win', icon: Icons.workspace_premium)),
        SizedBox(width: 10),
        Expanded(child: Achievement(title: 'Sharp Shooter', icon: Icons.track_changes)),
        SizedBox(width: 10),
        Expanded(child: Achievement(title: 'Queen Master', icon: Icons.military_tech)),
      ]),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage())),
        icon: const Icon(Icons.settings), label: const Text('Settings'),
      ),
    ])),
  ]);
}

class StatTile extends StatelessWidget {
  final IconData icon; final String value, label;
  const StatTile({required this.icon, required this.value, required this.label, super.key});
  @override
  Widget build(BuildContext context) => AppCard(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, color: gold, size: 30), const SizedBox(height: 8),
    Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
    Text(label, style: const TextStyle(color: textMuted)),
  ]));
}

class Achievement extends StatelessWidget {
  final String title; final IconData icon;
  const Achievement({required this.title, required this.icon, super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 150, padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(18)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircleAvatar(backgroundColor: const Color(0xFF303035), child: Icon(icon, color: gold)),
      const SizedBox(height: 10),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
    ]),
  );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  Map<String,bool> values={};
  @override void initState(){super.initState();SettingsService.load().then((v){if(mounted)setState(()=>values=v);});}
  Future<void> _set(String key,bool value) async {setState(()=>values[key]=value);await SettingsService.save(key,value);}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(backgroundColor:bg,title:const Text('Settings')),body:values.isEmpty?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.all(26),children:[const Text('Settings',style:TextStyle(fontSize:36,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('Customize your gameplay experience.',style:TextStyle(fontSize:18,color:textMuted)),const SizedBox(height:28),_section('Audio & Haptics',[ _switch('Sound Effects','Strikes, pockets, and UI sounds',SettingsService.sound),_switch('Background Music','Lobby and match ambience',SettingsService.music),_switch('Vibration','Haptic feedback on impact',SettingsService.vibration)]),const SizedBox(height:18),_section('Gameplay',[ _switch('Aim Guide','High precision trajectory line',SettingsService.aimGuide),_switch('Ultra Graphics','Enhanced board reflections and lighting',SettingsService.ultra)]),const SizedBox(height:18),AppCard(child:ListTile(leading:const Icon(Icons.person_outline),title:const Text('Account Details'),trailing:const Icon(Icons.chevron_right))),const SizedBox(height:12),AppCard(child:ListTile(leading:const Icon(Icons.help_outline),title:const Text('Help & Support'),trailing:const Icon(Icons.chevron_right))),const SizedBox(height:40),const Center(child:Text('Version 1.1.0 (Build 2)',style:TextStyle(color:textMuted))),]));
  Widget _section(String title,List<Widget> children)=>AppCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontSize:26,fontWeight:FontWeight.w800,color:gold)),const SizedBox(height:10),...children]));
  Widget _switch(String title,String sub,String key)=>SwitchListTile(contentPadding:const EdgeInsets.symmetric(vertical:4),title:Text(title,style:const TextStyle(fontWeight:FontWeight.w700,fontSize:18)),subtitle:Text(sub,style:const TextStyle(color:textMuted)),value:values[key]??true,onChanged:(v)=>_set(key,v),activeColor:gold);
}

class DifficultyPage extends StatelessWidget {
  const DifficultyPage({super.key});
  @override
  Widget build(BuildContext context) {
    const levels = [
      ['Easy', 'For beginners learning the basics', Icons.sentiment_satisfied],
      ['Normal', 'A balanced challenge for most players', Icons.sports_esports],
      ['Hard', 'Tough opponent. Expect precision.', Icons.local_fire_department],
      ['Expert', 'The ultimate carrom challenge', Icons.emoji_events],
    ];
    return Scaffold(
      appBar: AppBar(backgroundColor: bg, title: const Text('Difficulty')),
      body: Column(children: [
        const SizedBox(height: 30),
        const Text('Select Difficulty', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: gold)),
        const SizedBox(height: 8),
        const Text('Choose your AI opponent', style: TextStyle(fontSize: 18, color: textMuted)),
        const SizedBox(height: 42),
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          itemCount: levels.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: AppCard(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(difficulty: levels[i][0] as String))),
              child: Row(children: [
                CircleAvatar(radius: 34, backgroundColor: const Color(0xFF15161A), child: Icon(levels[i][2] as IconData, color: gold)),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(levels[i][0] as String, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(levels[i][1] as String, style: const TextStyle(color: textMuted)),
                ])),
              ]),
            ),
          ),
        )),
      ]),
    );
  }
}

class RoomPage extends StatelessWidget {
  const RoomPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: bg, title: const Text('Room')),
    body: Padding(padding: const EdgeInsets.all(26), child: Column(children: [
      const SizedBox(height: 20),
      const Text('PRIVATE MATCH', style: TextStyle(color: gold, letterSpacing: 2, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(22)), child: const Text('582741', textAlign: TextAlign.center, style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900))),
      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.share), label: const Text('Share Invite Link')),
      const SizedBox(height: 36),
      const AppCard(child: ListTile(leading: CircleAvatar(child: Icon(Icons.person)), title: Text('ShadowStriker'), subtitle: Text('Host • Win Rate: 68%'))),
      const SizedBox(height: 22),
      const CircleAvatar(radius: 34, backgroundColor: card, child: Text('VS')),
      const SizedBox(height: 22),
      const AppCard(child: ListTile(leading: CircleAvatar(child: Icon(Icons.person_add)), title: Text('Waiting for opponent...'), subtitle: Text('Slot 2'))),
      const Spacer(),
      SizedBox(width: double.infinity, height: 58, child: FilledButton(onPressed: null, style: FilledButton.styleFrom(backgroundColor: gold, foregroundColor: bg), child: const Text('START MATCH', style: TextStyle(fontWeight: FontWeight.w900)))),
      const SizedBox(height: 14),
      const Text('Waiting for all players to join', style: TextStyle(color: textMuted)),
    ])),
  );
}

class GamePage extends StatefulWidget {
  final String difficulty;
  const GamePage({required this.difficulty, super.key});
  @override State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  final List<CarromCoin> _coins = [];
  final List<CoinKind> _turnPocketed = [];
  final CarromRules _rules = CarromRules();
  double _power = .55, _aimAngle = -math.pi / 2;
  bool _yourTurn = true, _moving = false, _showAim = true, _ultra = true;
  int _you = 0, _ai = 0;
  Size? _board;

  @override void initState() { super.initState(); _ticker = createTicker(_tick)..start(); _loadSettings(); }
  Future<void> _loadSettings() async { final s = await SettingsService.load(); if (mounted) setState(() { _showAim=s[SettingsService.aimGuide]??true; _ultra=s[SettingsService.ultra]??true; }); }
  @override void dispose() { _ticker.dispose(); super.dispose(); }

  void _setup(Size size) {
    if (_coins.isNotEmpty) return;
    final c = Offset(size.width/2,size.height/2);
    _coins.add(CarromCoin(id:'queen',kind:CoinKind.queen,position:c,radius:10));
    for(int i=0;i<6;i++){
      final a=i*math.pi/3;
      _coins.add(CarromCoin(id:'w$i',kind:CoinKind.white,position:c+Offset(math.cos(a)*24,math.sin(a)*24),radius:10));
      _coins.add(CarromCoin(id:'b$i',kind:CoinKind.black,position:c+Offset(math.cos(a+.18)*42,math.sin(a+.18)*42),radius:10));
    }
    _coins.add(CarromCoin(id:'striker',kind:CoinKind.striker,position:Offset(size.width/2,size.height-46),radius:15));
  }
  CarromCoin get _striker => _coins.firstWhere((c)=>c.isStriker);
  void _tick(Duration elapsed) {
    if(_last==Duration.zero){_last=elapsed;return;} final dt=((elapsed-_last).inMicroseconds/1e6).clamp(0,.03).toDouble(); _last=elapsed;
    if(_moving && mounted && _board!=null) _simulate(dt,_board!);
  }
  void _simulate(double dt, Size size) {
    const margin=26.0,pocketR=22.0; final pockets=[const Offset(margin,margin),Offset(size.width-margin,margin),Offset(margin,size.height-margin),Offset(size.width-margin,size.height-margin)];
    var movingNow=false;
    for(final c in _coins){ if(c.pocketed) continue; c.position+=c.velocity*dt; c.velocity*=math.pow(.075,dt).toDouble(); if(c.velocity.distance>1.8)movingNow=true; else c.velocity=Offset.zero;
      final min=margin+c.radius,maxX=size.width-min,maxY=size.height-min;
      if(c.position.dx<min||c.position.dx>maxX){c.velocity=Offset(-c.velocity.dx*.78,c.velocity.dy);c.position=Offset(c.position.dx.clamp(min,maxX).toDouble(),c.position.dy);}
      if(c.position.dy<min||c.position.dy>maxY){c.velocity=Offset(c.velocity.dx,-c.velocity.dy*.78);c.position=Offset(c.position.dx,c.position.dy.clamp(min,maxY).toDouble());}
      for(final p in pockets){ if(!c.pocketed&&(c.position-p).distance<pocketR-2){c.pocketed=true;c.velocity=Offset.zero;_turnPocketed.add(c.kind);GameFeedback.pocket();} }
    }
    for(int i=0;i<_coins.length;i++){final a=_coins[i];if(a.pocketed)continue;for(int j=i+1;j<_coins.length;j++){final b=_coins[j];if(b.pocketed)continue;final d=b.position-a.position,dist=d.distance,minDist=a.radius+b.radius;if(dist>0&&dist<minDist){final n=d/dist,over=minDist-dist;a.position-=n*(over/2);b.position+=n*(over/2);final rel=b.velocity-a.velocity,impact=rel.dx*n.dx+rel.dy*n.dy;if(impact<0){final impulse=-impact*.86;a.velocity-=n*impulse;b.velocity+=n*impulse;GameFeedback.hit();}}}}
    if(!movingNow) _finishTurn(size); else setState((){});
  }
  void _finishTurn(Size size){
    final out=_rules.resolveTurn(_turnPocketed);
    if(_yourTurn) _you=math.max(0,_you+out.scoreDelta); else _ai=math.max(0,_ai+out.scoreDelta);
    if(out.strikerFoul) GameFeedback.foul();
    _turnPocketed.clear(); _moving=false; final s=_striker; if(s.pocketed)s.pocketed=false; s.velocity=Offset.zero;
    final finished=_coins.where((c)=>!c.isStriker&&!c.pocketed).isEmpty;
    if(finished){setState((){});Future.delayed(const Duration(milliseconds:300),()=>_showResult());return;}
    if(!out.keepTurn) _yourTurn=!_yourTurn;
    s.position=_yourTurn?Offset(size.width/2,size.height-46):Offset(size.width/2,46);
    setState((){}); if(!_yourTurn&&widget.difficulty!='Practice')Future.delayed(const Duration(milliseconds:650),_aiShot);
  }
  void _showResult(){if(!mounted)return;showDialog(context:context,builder:(_)=>AlertDialog(title:const Text('Match Complete'),content:Text('You $_you  •  ${widget.difficulty=='Practice'?'Score':'AI '+_ai.toString()}'),actions:[TextButton(onPressed:(){Navigator.pop(context);Navigator.pop(context);},child:const Text('EXIT')),FilledButton(onPressed:(){Navigator.pop(context);_newGame(_board!);},child:const Text('PLAY AGAIN'))]));}
  void _aiShot(){if(!mounted||_moving||_yourTurn)return;final target=_coins.where((c)=>!c.pocketed&&!c.isStriker).toList();if(target.isEmpty)return;final coin=target[math.Random().nextInt(target.length)],d=coin.position-_striker.position;_striker.velocity=d/d.distance*(360+math.Random().nextDouble()*180);setState(()=>_moving=true);}
  void _strike(){if(_moving||!_yourTurn)return;_striker.velocity=Offset(math.cos(_aimAngle),math.sin(_aimAngle))*(220+_power*620);GameFeedback.hit();setState(()=>_moving=true);}
  void _newGame(Size size){setState((){_coins.clear();_you=0;_ai=0;_moving=false;_yourTurn=true;_turnPocketed.clear();_setup(size);});}

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(backgroundColor:bg,title:Text('${widget.difficulty} Match'),actions:[IconButton(icon:const Icon(Icons.refresh),onPressed:()=>_newGame(_board??Size.zero))]),
    body:Column(children:[Padding(padding:const EdgeInsets.fromLTRB(18,12,18,8),child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[Column(children:[const Text('YOU'),Text('$_you',style:const TextStyle(fontSize:30,color:gold,fontWeight:FontWeight.w900))]),Chip(backgroundColor:_yourTurn?gold:card,label:Text(_moving?'IN MOTION':_yourTurn?'YOUR TURN':'AI TURN',style:TextStyle(color:_yourTurn?bg:Colors.white,fontWeight:FontWeight.w800))),Column(children:[Text(widget.difficulty=='Practice'?'SCORE':'AI'),Text('${widget.difficulty=='Practice'?_you:_ai}',style:const TextStyle(fontSize:30,fontWeight:FontWeight.w900))])])),
      Expanded(child:LayoutBuilder(builder:(context,c){final side=math.min(c.maxWidth-52,c.maxHeight-18);final board=Size(side,side);_board=board;_setup(board);return Center(child:GestureDetector(onPanUpdate:_moving||!_yourTurn?null:(d){final center=Offset(board.width/2,board.height-46);final p=d.localPosition-Offset((c.maxWidth-board.width)/2,(c.maxHeight-board.height)/2);setState(()=>_aimAngle=math.atan2(p.dy-center.dy,p.dx-center.dx));},child:SizedBox(width:side,height:side,child:CustomPaint(painter:_CarromPainter(coins:_coins,aimAngle:_aimAngle,showAim:_showAim&&_yourTurn&&!_moving,ultra:_ultra)))));})),
      Container(color:card,padding:const EdgeInsets.fromLTRB(24,14,24,24),child:Column(children:[Row(children:[const Icon(Icons.bolt,color:gold),const SizedBox(width:10),const Text('POWER',style:TextStyle(fontWeight:FontWeight.w800)),Expanded(child:Slider(value:_power,activeColor:gold,onChanged:_moving||!_yourTurn?null:(v)=>setState(()=>_power=v)))]),SizedBox(width:double.infinity,height:58,child:FilledButton.icon(onPressed:_moving||!_yourTurn?null:_strike,style:FilledButton.styleFrom(backgroundColor:gold,foregroundColor:bg),icon:const Icon(Icons.sports_baseball),label:const Text('STRIKE',style:TextStyle(fontSize:22,fontWeight:FontWeight.w900))))]))]));
}

class _CarromPainter extends CustomPainter {
  final List<CarromCoin> coins; final double aimAngle; final bool showAim,ultra;
  const _CarromPainter({required this.coins,required this.aimAngle,required this.showAim,required this.ultra});
  @override void paint(Canvas canvas,Size size){final outer=RRect.fromRectAndRadius(Offset.zero&size,const Radius.circular(24));canvas.drawRRect(outer,Paint()..color=const Color(0xFF3D2818));canvas.save();canvas.clipRRect(outer);final inner=Rect.fromLTWH(18,18,size.width-36,size.height-36);canvas.drawRect(inner,Paint()..color=const Color(0xFFD7A86B));canvas.drawRect(inner.deflate(22),Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=const Color(0xFF74431F));final c=inner.center;canvas.drawCircle(c,56,Paint()..style=PaintingStyle.stroke..strokeWidth=3..color=const Color(0xFF8B5529));canvas.drawCircle(c,28,Paint()..style=PaintingStyle.stroke..strokeWidth=2..color=const Color(0xFF8B5529));const m=26.0;for(final p in [const Offset(m,m),Offset(size.width-m,m),Offset(m,size.height-m),Offset(size.width-m,size.height-m)])canvas.drawCircle(p,22,Paint()..color=Colors.black);
    final striker=coins.where((e)=>e.isStriker&&!e.pocketed).cast<CarromCoin?>().firstOrNull;if(showAim&&striker!=null){final end=striker.position+Offset(math.cos(aimAngle),math.sin(aimAngle))*150;canvas.drawLine(striker.position,end,Paint()..color=gold.withOpacity(.75)..strokeWidth=2);}
    for(final coin in coins){if(coin.pocketed)continue;final color=switch(coin.kind){CoinKind.white=>Colors.white,CoinKind.black=>const Color(0xFF202124),CoinKind.queen=>const Color(0xFFE25353),CoinKind.striker=>const Color(0xFFF0C857)};if(ultra)canvas.drawCircle(coin.position+const Offset(2,3),coin.radius+4,Paint()..color=Colors.black.withOpacity(.22));canvas.drawCircle(coin.position,coin.radius,Paint()..color=color);canvas.drawCircle(coin.position,coin.radius-3,Paint()..style=PaintingStyle.stroke..strokeWidth=1.5..color=Colors.black.withOpacity(.35));}canvas.restore();}
  @override bool shouldRepaint(covariant _CarromPainter old)=>true;
}

extension FirstOrNull<T> on Iterable<T>{T? get firstOrNull=>isEmpty?null:first;}
