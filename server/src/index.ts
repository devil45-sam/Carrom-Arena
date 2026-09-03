import express from 'express'; import { createServer } from 'node:http'; import { Server } from 'socket.io';
const app=express(); const http=createServer(app); const io=new Server(http,{cors:{origin:process.env.CLIENT_ORIGIN?.split(',')??'*'}});
app.get('/health',(_,res)=>res.json({ok:true,service:'carrom-arena-authoritative-server'}));
const sessions=new Map<string,{players:string[],turn:string,lastSequence:number}>();
io.on('connection',socket=>{
 socket.on('join-match',(matchId:string)=>{let s=sessions.get(matchId); if(!s){s={players:[],turn:socket.id,lastSequence:0};sessions.set(matchId,s)} if(!s.players.includes(socket.id)&&s.players.length<2)s.players.push(socket.id); if(!s.turn)s.turn=socket.id; socket.join(matchId); io.to(matchId).emit('match-state',{players:s.players,turn:s.turn});});
 socket.on('shot',(e:{matchId:string,sequence:number,angle:number,power:number})=>{const s=sessions.get(e.matchId); if(!s||s.turn!==socket.id||e.sequence<=s.lastSequence||e.power<0||e.power>1||!Number.isFinite(e.angle))return socket.emit('action-rejected',{reason:'invalid-shot'}); s.lastSequence=e.sequence; s.turn=s.players.find(x=>x!==socket.id)??socket.id; io.to(e.matchId).emit('authoritative-shot',{...e,playerId:socket.id,nextTurn:s.turn});});
 socket.on('disconnect',()=>{for(const [id,s] of sessions){if(s.players.includes(socket.id)){s.players=s.players.filter(x=>x!==socket.id);io.to(id).emit('opponent-disconnected',{graceSeconds:60});}}});
});
http.listen(Number(process.env.PORT||3001),()=>console.log('Carrom server listening'));
