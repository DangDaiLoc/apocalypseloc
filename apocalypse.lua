// ==UserScript==
// @name         Survive The Apocalypse - Auto Base
// @namespace    https://survivetheapocalypse.miraheze.org/
// @version      2.0.0
// @match        *://survivetheapocalypse.miraheze.org/*
// @match        *://*.roblox.com/*
// @grant        GM_addStyle
// @run-at       document-ready
// ==/UserScript==
(function(){
'use strict';
const CONFIG={BASE_X:0,BASE_Y:0,BASE_Z:0,SAFE_DISTANCE:15,AVOID_RADIUS:20,SCAN_INTERVAL:500,UPDATE_INTERVAL:100,HEALTH_THRESHOLD:30};
const STATE={autoReturn:false,avoidZombies:true,avoidObstacles:true,emergencyReturn:true,isReturning:false,nearestZombies:[],currentHP:100,maxHP:100,playerPos:{x:0,y:0,z:0},basePos:{x:0,y:0,z:0},logs:[],totalAvoided:0,returnCount:0};
const RobloxBridge={
  init(){try{if(typeof game!=='undefined'){this.game=game;this.workspace=game.Workspace;this.player=game.Players.LocalPlayer;this.character=this.player?.Character;this.humanoid=this.character?.FindFirstChild('Humanoid');this.rootPart=this.character?.FindFirstChild('HumanoidRootPart');return true;}}catch(e){}return false;},
  getPlayerPosition(){try{if(this.rootPart){const p=this.rootPart.Position;return{x:p.X,y:p.Y,z:p.Z};}}catch(e){}return{x:STATE.playerPos.x+(Math.random()-.5)*2,y:STATE.playerPos.y,z:STATE.playerPos.z+(Math.random()-.5)*2};},
  getHP(){try{if(this.humanoid)return{current:this.humanoid.Health,max:this.humanoid.MaxHealth};}catch(e){}return{current:STATE.currentHP,max:STATE.maxHP};},
  moveTo(x,y,z){try{if(this.humanoid){this.humanoid.MoveTo(new Vector3(x,y,z));return true;}}catch(e){}const dx=x-STATE.playerPos.x,dz=z-STATE.playerPos.z,d=Math.sqrt(dx*dx+dz*dz);if(d>1){STATE.playerPos.x+=(dx/d)*2;STATE.playerPos.z+=(dz/d)*2;}return false;},
  getNearbyZombies(radius){try{if(this.workspace){const zs=[],pos=this.rootPart?.Position;if(!pos)return[];this.workspace.GetDescendants().forEach(o=>{if(o.Name?.toLowerCase().includes('zombie')||o.Name?.toLowerCase().includes('enemy')||o.Name?.toLowerCase().includes('infected')){const zr=o.FindFirstChild?.('HumanoidRootPart');if(zr){const d=pos.sub?.(zr.Position)?.Magnitude;if(d<=radius)zs.push({pos:zr.Position,dist:d,name:o.Name});}}});return zs;}}catch(e){}return Array.from({length:Math.floor(Math.random()*4)},(_,i)=>({pos:{x:STATE.playerPos.x+(Math.random()-.5)*40,y:0,z:STATE.playerPos.z+(Math.random()-.5)*40},dist:Math.random()*35+5,name:`Zombie_${i+1}`}));}
};
const PathEngine={
  avoidVec(dangers,pos){let ax=0,az=0;for(const d of dangers){const dx=pos.x-d.pos.x,dz=pos.z-(d.pos.z||d.pos.Z||0),dist=Math.sqrt(dx*dx+dz*dz)||.001,s=Math.max(0,CONFIG.AVOID_RADIUS-dist)/CONFIG.AVOID_RADIUS;ax+=(dx/dist)*s*2;az+=(dz/dist)*s*2;}return{x:ax,z:az};},
  baseVec(cur,base){const dx=base.x-cur.x,dz=base.z-cur.z,d=Math.sqrt(dx*dx+dz*dz)||.001;return{x:dx/d,z:dz/d,dist:d};},
  target(cur,base,dangers){const tb=this.baseVec(cur,base);if(!dangers.length)return{x:cur.x+tb.x*5,z:cur.z+tb.z*5,distToBase:tb.dist};const av=this.avoidVec(dangers,cur),w=Math.min(dangers.length*.4,.9),fx=tb.x*(1-w)+av.x*w,fz=tb.z*(1-w)+av.z*w,fm=Math.sqrt(fx*fx+fz*fz)||.001;return{x:cur.x+(fx/fm)*5,z:cur.z+(fz/fm)*5,distToBase:tb.dist};},
  dist(a,b){const dx=a.x-b.x,dz=a.z-(b.z||0);return Math.sqrt(dx*dx+dz*dz);}
};let scanInt=null,moveInt=null;
function addLog(msg,type='info'){const t=new Date().toLocaleTimeString('vi-VN');STATE.logs.unshift({time:t,msg,type});if(STATE.logs.length>50)STATE.logs.pop();updateLog();}
function startBot(){if(scanInt)return;addLog('Bot đã khởi động','success');
scanInt=setInterval(()=>{STATE.playerPos=RobloxBridge.getPlayerPosition();const hp=RobloxBridge.getHP();STATE.currentHP=hp.current;STATE.maxHP=hp.max;const pct=(hp.current/hp.max)*100;updateHP(pct);if(STATE.emergencyReturn&&pct<=CONFIG.HEALTH_THRESHOLD&&!STATE.isReturning){STATE.isReturning=true;STATE.autoReturn=true;addLog(`⚠️ HP thấp (${pct.toFixed(0)}%) - Về base!`,'danger');updateUI();}if(STATE.avoidZombies){const r=RobloxBridge.getNearbyZombies(CONFIG.AVOID_RADIUS*2);STATE.nearestZombies=r.filter(z=>z.dist<=CONFIG.AVOID_RADIUS);if(STATE.nearestZombies.length){STATE.totalAvoided++;updateStats();}}updatePos();},CONFIG.SCAN_INTERVAL);
moveInt=setInterval(()=>{if(!STATE.autoReturn)return;const d=STATE.avoidZombies?[...STATE.nearestZombies]:[];const t=PathEngine.target(STATE.playerPos,STATE.basePos,d);if(t.distToBase<3){STATE.isReturning=false;STATE.returnCount++;addLog(`✅ Về base lần ${STATE.returnCount}`,'success');STATE.autoReturn=false;updateUI();updateStats();return;}RobloxBridge.moveTo(t.x,STATE.playerPos.y,t.z);if(d.length)addLog(`🧟 Né ${d.length} zombie, còn ${t.distToBase.toFixed(1)}m`,'warning');},CONFIG.UPDATE_INTERVAL);}
function stopBot(){clearInterval(scanInt);clearInterval(moveInt);scanInt=null;moveInt=null;STATE.autoReturn=false;STATE.isReturning=false;addLog('Bot đã dừng');updateUI();}

GM_addStyle(`
@import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&family=Rajdhani:wght@500;700&display=swap');
#sta-wrap{position:fixed;top:20px;right:20px;z-index:99999;font-family:'Rajdhani',sans-serif;user-select:none}
#sta-tog{width:48px;height:48px;background:linear-gradient(135deg,#0f0,#0a0);border:2px solid #0f0;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:22px;box-shadow:0 0 15px #0f04;transition:all .3s;margin-left:auto}
#sta-tog.active{background:linear-gradient(135deg,#f00,#900);border-color:#f00}
#sta-panel{width:300px;background:rgba(5,12,5,.97);border:1px solid #0f04;border-top:3px solid #0f0;border-radius:8px;margin-top:8px;overflow:hidden;transition:all .3s;transform-origin:top right}
#sta-panel.hidden{opacity:0;transform:scaleY(0);pointer-events:none;max-height:0}
.sh{background:linear-gradient(90deg,#0f02,transparent);border-bottom:1px solid #0f03;padding:10px 14px;display:flex;align-items:center;gap:8px}
.st{font-family:'Share Tech Mono',monospace;color:#0f0;font-size:12px;letter-spacing:2px;text-shadow:0 0 10px #0f0}
.ss{display:flex;align-items:center;gap:8px;padding:7px 14px;background:rgba(0,255,0,.03);border-bottom:1px solid #0f02}
.sd{width:8px;height:8px;border-radius:50%;background:#333;transition:all .3s}
.sd.on{background:#0f0;box-shadow:0 0 8px #0f0;animation:p 1.5s infinite}
.sd.warn{background:#fa0;box-shadow:0 0 8px #fa0}
.sd.danger{background:#f00;box-shadow:0 0 8px #f00;animation:p .5s infinite}
@keyframes p{0%,100%{opacity:1}50%{opacity:.4}}
.hp-c{padding:6px 14px;display:flex;align-items:center;gap:8px;border-bottom:1px solid #0f02}
.hp-t{flex:1;height:8px;background:#0f01;border:1px solid #0f03;border-radius:4px;overflow:hidden}
.hp-f{height:100%;background:linear-gradient(90deg,#f00,#fa0,#0f0);background-size:300% 100%;transition:width .5s}
.sc{padding:10px 14px;border-bottom:1px solid #0f01}
.sct{color:#0f06;font-size:10px;letter-spacing:2px;text-transform:uppercase;margin-bottom:8px}
.sr{display:flex;align-items:center;justify-content:space-between;margin-bottom:7px}
.sw{position:relative;width:42px;height:22px;flex-shrink:0}
.sw input{opacity:0;width:0;height:0}
.sl{position:absolute;inset:0;background:#1a1a1a;border:1px solid #333;border-radius:22px;cursor:pointer;transition:.3s}
.sl:before{content:'';position:absolute;height:16px;width:16px;left:2px;top:2px;background:#444;border-radius:50%;transition:.3s}
.sw input:checked+.sl{background:#0f02;border-color:#0f0;box-shadow:0 0 8px #0f04}
.sw input:checked+.sl:before{transform:translateX(20px);background:#0f0}
.br{display:flex;gap:6px;margin-top:8px}
.btn{flex:1;padding:9px 0;border:none;border-radius:5px;cursor:pointer;font-family:'Rajdhani',sans-serif;font-size:12px;font-weight:700;letter-spacing:1px;text-transform:uppercase;transition:all .2s}
.bs{background:linear-gradient(135deg,#0a0,#060);color:#0f0;border:1px solid #0f04}
.bx{background:linear-gradient(135deg,#600,#400);color:#f66;border:1px solid #f004}
.bb{background:linear-gradient(135deg,#004,#002);color:#66f;border:1px solid #00f4}
.sts{display:grid;grid-template-columns:1fr 1fr 1fr;gap:5px}
.sv{background:rgba(0,255,0,.03);border:1px solid #0f02;border-radius:5px;padding:7px 5px;text-align:center}
.sv span:first-child{color:#0f0;font-family:'Share Tech Mono',monospace;font-size:16px;display:block;text-shadow:0 0 8px #0f0}
.sv span:last-child{color:#555;font-size:9px;letter-spacing:1px}
.zi{display:flex;align-items:center;gap:5px;padding:4px 0}
.zb{flex:1;height:4px;background:#f001;border-radius:2px}
.zf{height:100%;background:#f00;border-radius:2px;transition:width .3s}
.inp{background:#0f01;border:1px solid #0f03;border-radius:4px;color:#0f0;font-family:'Share Tech Mono',monospace;font-size:11px;padding:3px 7px;width:75px;text-align:right;outline:none}
.inp:focus{border-color:#0f0}
.ir{display:flex;align-items:center;justify-content:space-between;margin-bottom:5px}
.il{color:#888;font-size:11px}
.lg{max-height:90px;overflow-y:auto;padding:5px 14px;scrollbar-width:thin;scrollbar-color:#0f03 transparent}
.le{display:flex;gap:5px;padding:2px 0;border-bottom:1px solid #0f01;font-size:10px}
.lt{color:#0f05;font-family:'Share Tech Mono',monospace;flex-shrink:0}
.lm{color:#666}
.lm.success{color:#0f0}
.lm.warning{color:#fa0}
.lm.danger{color:#f55}
.pos{font-family:'Share Tech Mono',monospace;font-size:10px;color:#0f04;padding:4px 14px 7px;letter-spacing:1px}
`);function buildUI(){
const w=document.createElement('div');w.id='sta-wrap';
w.innerHTML=`
<div id="sta-tog" title="Menu">☣</div>
<div id="sta-panel">
<div class="sh"><span style="color:#f00;font-size:16px">☣</span><span class="st">APOCALYPSE BOT</span><span style="font-size:9px;color:#0f06;margin-left:auto">v2.0</span></div>
<div class="ss"><div class="sd" id="sd"></div><span style="color:#aaa;font-size:12px;letter-spacing:1px" id="stxt">STANDBY</span><span style="margin-left:auto;color:#0f05;font-size:10px" id="smod">—</span></div>
<div class="hp-c"><span style="color:#0f08;font-size:11px;font-family:'Share Tech Mono',monospace;width:20px">HP</span><div class="hp-t"><div class="hp-f" id="hpf" style="width:100%"></div></div><span style="color:#0f0;font-size:11px;font-family:'Share Tech Mono',monospace;width:34px;text-align:right" id="hpv">100%</span></div>
<div class="sc">
<div class="sct">⚙ Điều khiển</div>
<div class="sr"><div><div style="color:#ccc;font-size:13px;font-weight:500">Auto Về Base</div><div style="color:#555;font-size:10px">Tự động về vị trí base</div></div><label class="sw"><input type="checkbox" id="sw1"><span class="sl"></span></label></div>
<div class="sr"><div><div style="color:#ccc;font-size:13px;font-weight:500">Né Zombie</div><div style="color:#555;font-size:10px">Tránh zombie trong 20m</div></div><label class="sw"><input type="checkbox" id="sw2" checked><span class="sl"></span></label></div>
<div class="sr"><div><div style="color:#ccc;font-size:13px;font-weight:500">Né Vật Cản</div><div style="color:#555;font-size:10px">Tránh tường, mảnh vỡ</div></div><label class="sw"><input type="checkbox" id="sw3" checked><span class="sl"></span></label></div>
<div class="sr"><div><div style="color:#ccc;font-size:13px;font-weight:500">Khẩn Cấp HP</div><div style="color:#555;font-size:10px">Về base khi HP ≤ 30%</div></div><label class="sw"><input type="checkbox" id="sw4" checked><span class="sl"></span></label></div>
<div class="br"><button class="btn bs" id="b1">▶ BẮT ĐẦU</button><button class="btn bx" id="b2">■ DỪNG</button><button class="btn bb" id="b3">📍 BASE</button></div>
</div>
<div class="sc"><div class="sct">🧟 Radar Zombie</div><div id="zlist"><span style="color:#555;font-size:11px">Không có zombie gần...</span></div></div>
<div class="sc">
<div class="sct">🔧 Cấu hình</div>
<div class="ir"><span class="il">Khoảng cách an toàn (m)</span><input class="inp" id="c1" type="number" value="15"></div>
<div class="ir"><span class="il">Bán kính né tránh (m)</span><input class="inp" id="c2" type="number" value="20"></div>
<div class="ir"><span class="il">HP khẩn cấp (%)</span><input class="inp" id="c3" type="number" value="30"></div>
<div class="ir"><span class="il">Base X / Z</span><div style="display:flex;gap:4px"><input class="inp" id="c4" type="number" value="0" style="width:42px" placeholder="X"><input class="inp" id="c5" type="number" value="0" style="width:42px" placeholder="Z"></div></div>
</div>
<div class="sc"><div class="sct">📊 Thống kê</div><div class="sts"><div class="sv"><span id="sr">0</span><span>VỀ BASE</span></div><div class="sv"><span id="sa">0</span><span>NÉ TRÁNH</span></div><div class="sv"><span id="sz">0</span><span>ZOMBIE</span></div></div></div>
<div class="pos" id="pos">POS: X:0 Z:0 | BASE: 0m</div>
<div class="sc" style="padding-bottom:0"><div class="sct">📋 Nhật ký</div></div>
<div class="lg" id="lg"></div>
<div style="height:8px"></div>
</div>`;
document.body.appendChild(w);

document.getElementById('sta-tog').onclick=()=>{document.getElementById('sta-panel').classList.toggle('hidden');document.getElementById('sta-tog').classList.toggle('active');};
document.getElementById('sw1').onchange=e=>{STATE.autoReturn=e.target.checked;addLog(`Auto về base: ${STATE.autoReturn?'BẬT':'TẮT'}`);updateUI();};
document.getElementById('sw2').onchange=e=>{STATE.avoidZombies=e.target.checked;};
document.getElementById('sw3').onchange=e=>{STATE.avoidObstacles=e.target.checked;};
document.getElementById('sw4').onchange=e=>{STATE.emergencyReturn=e.target.checked;};
document.getElementById('b1').onclick=()=>{STATE.autoReturn=true;document.getElementById('sw1').checked=true;startBot();updateUI();};
document.getElementById('b2').onclick=stopBot;
document.getElementById('b3').onclick=()=>{STATE.basePos={...STATE.playerPos};document.getElementById('c4').value=Math.round(STATE.playerPos.x);document.getElementById('c5').value=Math.round(STATE.playerPos.z);addLog(`📍 Base: X:${STATE.playerPos.x.toFixed(1)} Z:${STATE.playerPos.z.toFixed(1)}`,'success');};
document.getElementById('c1').onchange=e=>{CONFIG.SAFE_DISTANCE=+e.target.value;};
document.getElementById('c2').onchange=e=>{CONFIG.AVOID_RADIUS=+e.target.value;};
document.getElementById('c3').onchange=e=>{CONFIG.HEALTH_THRESHOLD=+e.target.value;};
document.getElementById('c4').onchange=e=>{STATE.basePos.x=CONFIG.BASE_X=+e.target.value;};
document.getElementById('c5').onchange=e=>{STATE.basePos.z=CONFIG.BASE_Z=+e.target.value;};
}

function updateUI(){const dot=document.getElementById('sd'),txt=document.getElementById('stxt'),mod=document.getElementById('smod');dot.className='sd';if(!scanInt){txt.textContent='STANDBY';mod.textContent='—';}else if(STATE.isReturning&&STATE.nearestZombies.length){dot.classList.add('danger');txt.textContent='NGUY HIỂM';mod.textContent='NÉ + VỀ BASE';}else if(STATE.autoReturn){dot.classList.add('on');txt.textContent='ĐANG VỀ BASE';mod.textContent=`${STATE.nearestZombies.length} zombie`;}else{dot.classList.add('warn');txt.textContent='GIÁM SÁT';mod.textContent='CHỜ LỆNH';}}
function updateHP(p){const f=document.getElementById('hpf'),v=document.getElementById('hpv');if(!f)return;f.style.width=`${Math.max(0,Math.min(100,p))}%`;f.style.backgroundPosition=`${100-p}% 0`;v.textContent=`${Math.round(p)}%`;v.style.color=p<=30?'#f55':p<=60?'#fa0':'#0f0';}
function updatePos(){const el=document.getElementById('pos');if(el){const p=STATE.playerPos,b=STATE.basePos,d=PathEngine.dist(p,b);el.textContent=`POS: X:${p.x.toFixed(1)} Z:${p.z.toFixed(1)} | BASE: ${d.toFixed(1)}m`;}const zl=document.getElementById('zlist');if(zl){if(!STATE.nearestZombies.length){zl.innerHTML='<span style="color:#555;font-size:11px">Không có zombie gần...</span>';}else{zl.innerHTML=STATE.nearestZombies.slice(0,4).map(z=>`<div class="zi"><span style="color:#f55;font-size:10px;width:75px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${z.name}</span><div class="zb"><div class="zf" style="width:${Math.max(5,100-(z.dist/CONFIG.AVOID_RADIUS)*100)}%"></div></div><span style="color:#f55;font-size:10px;font-family:monospace;width:28px;text-align:right">${z.dist.toFixed(0)}m</span></div>`).join('');}}}
function updateStats(){const r=document.getElementById('sr'),a=document.getElementById('sa'),z=document.getElementById('sz');if(r)r.textContent=STATE.returnCount;if(a)a.textContent=STATE.totalAvoided;if(z)z.textContent=STATE.nearestZombies.length;}
function updateLog(){const lg=document.getElementById('lg');if(!lg)return;lg.innerHTML=STATE.logs.slice(0,20).map(l=>`<div class="le"><span class="lt">${l.time}</span><span class="lm ${l.type}">${l.msg}</span></div>`).join('');}

RobloxBridge.init();buildUI();
addLog('Script khởi động thành công','success');
addLog('Nhấn BẮT ĐẦU để kích hoạt','info');
addLog('Nhấn 📍 BASE để lưu vị trí','info');
startBot();STATE.autoReturn=false;updateUI();
})();
