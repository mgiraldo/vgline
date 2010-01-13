/**
 * VGLine 0.1: The Videogame Timeline <http://www.mauriciogiraldo.com/vgline/beta/>
 *
 * VGLine is (c) 2009-2010 Mauricio Giraldo Arteaga
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 *
 */
 package {

	/**
	 * @author Mauricio Giraldo Arteaga <http://www.mauriciogiraldo.com/> 
	 */
	// externals
	import flash.display.StageQuality;
	import flash.events.KeyboardEvent;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.net.ObjectEncoding;

	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.cartogrammar.drawing.DashedLine;

	public class Timeline extends Sprite {

		// constantes
		private const _url:String = "http://www.mauriciogiraldo.com/vgline/";
		private const _amfurl:String = _url + "services/amfphp";
		private const minevents:int = 200; // este luego se saca de xml
		private const maxevents:int = 2000; // este luego se saca de xml
		private const swidth:int = 960;
		private const timelineheight:int = 2048;
		private const dotxdif:int = 15;
		private const dotydif:int = 60;
		private const monthydif:int = 12;
		private const detailx:int = 243;
		private const detaily:int = 80;
		private const connectorx:int = -2;
		private const connectory:int = -4;
		private const xdotdetail:int = detailx - 45;
		private const resultsx:int = 121;
		private const resultsy:int = 80;
		private const bcyearname:String = "BC";
		private const relationxfin:int = 117;
		private const relationyfin:int = 13;
		// colores
		private const eventcolors:/*String*/Array = ["",
			"#ffcc00", //1|Console
			"#00ffff", //2|Controller
			"#00ff00", //3|Game
			"#ff00ff", //4|Business
			"#0000ff", //5|Technology
			"#666666", //6|Cultural
			"#ff0000", //7|Person
			"#cccccc"//8|Other
		];
		// constantes pepas
		private const monthspermark:int = 1;
		// clips a ser manipulados y vars relacionadas
		private var detail:TLDetail;
		public var timelineClip:MovieClip;
		public var rulerClip:MovieClip;
		public var epochClip:MovieClip;
		public var scrubdragging:Boolean = false;
		public var timelinedragging:Boolean = false;
		private var relationsClip:MovieClip;
		private var epochmaxx:int;
		private var epochminx:int;
		// el ancho de las cosas
		public var rayitas_mc:MovieClip;
		public var scrub_mc:MovieClip;
		public var track_mc:MovieClip;
		public var miniwidth:Number = 0;
		public var localeventsy:int = 30;
		public var globaleventsy:int = -30;
		// el ancho de un año en mini es en relacion a las barras
		public var oneyearminiwidth:Number;
		// los eventos
		private var hasloaded:Boolean = false;
		private var lastaddress:String = "/";
		private var minyear:int = 1000;
		private var maxyear:int = 2020;
		private var deltayears:int = maxyear - minyear;
		private const oneyearfullwidth:int = 186;
		private var timelineevents:Array;
		private var timelineepochs:Array;
		private var currenteventindex:int;
		private var emptystartyear:int;
		private var emptyendyear:int;
		private var eventDots:/*TLDot*/Array;
		private var _scrubspeed:Number;
		private var _prev_mouseX:int = 0;
		private var _timelinespeed:Number;
		// botones y clips varios
		public var timeline_mc:MovieClip;
		public var buscar_btn:MovieClip;
		public var keyword_txt:TextField;
		public var status_txt:TextField;
		public var noevents_mc:MovieClip;
		public var person_mc:MovieClip;
		public var technology_mc:MovieClip;
		public var business_mc:MovieClip;
		public var console_mc:MovieClip;
		public var controller_mc:MovieClip;
		public var game_mc:MovieClip;
		public var cultural_mc:MovieClip;
		public var other_mc:MovieClip;
		public var related_mc:MovieClip;
		public var inspired_mc:MovieClip;
		public var predecessor_mc:MovieClip;
		// teclado
		private var spacepressed:Boolean = false;
		private var personvisible:Boolean = true;
		private var technologyvisible:Boolean = true;
		private var businessvisible:Boolean = true;
		private var consolevisible:Boolean = true;
		private var controllervisible:Boolean = true;
		private var gamevisible:Boolean = true;
		private var culturalvisible:Boolean = true;
		private var othervisible:Boolean = true;
		private var relatedvisible:Boolean = true;
		private var inspiredvisible:Boolean = true;
		private var predecessorvisible:Boolean = true;

		public function Timeline() {
			init();
		}

		public function setupTimeline():void {
			// cuadrar ancho vs tiempo
			timelineClip = new MovieClip();
			// ponemos las epocas
			//plotEpochs();
			// ponemos los años en el pie
			plotRuler();
			// las relaciones deben salir encima de la regla
			relationsClip = new MovieClip();
			timelineClip.addChild(relationsClip);
			// poner los puntos
			plotEvents();
			// meter en el fondo
			timeline_mc.addChild(timelineClip);
		}

		/* *********************************************************************
		 * INICIALIZACION Y MANEJO DE EVENTOS
		 */
		public function inventEvent():Object {
			var o:Object = {};
			o.ano = Math.ceil(Math.random() * deltayears + minyear);
			o.mes = Math.ceil(Math.random() * 12);
			o.dia = Math.ceil(Math.random() * 31);
			o.tipo = Math.random() < 0.9 ? "local" : "global";
			o.titulo = StringUtils.paragraph(10);
			o.texto = StringUtils.paragraph(200);
			o.color = getColorForYear(o.ano);
			o.links = ["http://www.yahoo.com","http://www.google.com"];
			return o;
		}

		public function getColorForYear(year:int):Object {
			var o:Object;
			var i:int, l:int = timelineepochs.length;
			for (i = 0;i < l;++i) {
				if (timelineepochs[i].ini <= year && timelineepochs[i].fin > year) {
					return timelineepochs[i].color;
				} else {
					o = timelineepochs[l - 1].color;
				}
			}
			return o;
		}

		public function generateEvents():void {
			var l:int = Math.ceil(Math.random() * (maxevents - minevents)) + minevents;
			timelineevents = [];
			var i:int;
			for (i = 0;i < l;++i) {
				timelineevents.push(inventEvent());
			}
			timelineevents.sortOn(["ano","mes","dia"], Array.NUMERIC);
		}

		public function generateEpochs():void {
			timelineepochs = [];
			var ln:int = minyear;
			var tmp:Object;
			while (ln < maxyear) {
				tmp = {
					color: {r:(Math.random() * 255), g:(Math.random() * 255), b:(Math.random() * 255)}, ini: ln, titulo: StringUtils.paragraph(5)
				};
				ln += Math.round(Math.random() * 200);
				if (ln > maxyear) ln = maxyear;
				tmp.fin = ln;
				timelineepochs.push(tmp);
			}
		}

		public function plotRuler():void {
			var i:int;
			var year:int;
			var txt:String;
			rulerClip = new MovieClip();
			rulerClip.name = "ruler_mc";
			var yearClip:TLRulerYear;
			for (i = 0;i <= deltayears;++i) {
				year = i + minyear;
				if (year < 0) {
					txt = Math.abs(year).toString() + " " + bcyearname;
				} else {
					txt = year.toString();
				}
				yearClip = new TLRulerYear();
				yearClip.id = i;
				yearClip.name = txt;
				yearClip.year_txt.text = txt;
				//yearClip.y = Math.round(timelineheight - yearClip.height);
				yearClip.x = (year > 0) ? (i - 1) * yearClip.width : i * yearClip.width;
				rulerClip.addChild(yearClip);
			}
			timelineClip.addChild(rulerClip);
		}

		public function plotEpochs():void {
			var i:int;
			epochClip = new MovieClip();
			epochClip.name = "epoch_mc";
			var eClip:TLEpoch;
			var grad:Shape;
			var miniClip:Shape;
			var e:Object;
			var l:int = timelineepochs.length;
			var prev:Object;
			for (i = 0;i < l;++i) {
				e = timelineepochs[i];
				eClip = new TLEpoch();
				//eClip.label_txt.text = e.titulo;
				eClip.background_mc.width = (e.fin - e.ini + 1) * oneyearfullwidth;
				eClip.background_mc.height = timelineheight;
				eClip.x = (e.ini - minyear) * oneyearfullwidth;
				var ct:ColorTransform = new ColorTransform(e.color.r / 255, e.color.g / 255, e.color.b / 255);
				eClip.background_mc.transform.colorTransform = ct;
				
				// el gradiente
				if (i > 0) {
					// solo si no es ni la primera ni última
					grad = new Shape();
					prev = timelineepochs[i - 1].color;
					grad.graphics.beginGradientFill(GradientType.LINEAR, [StringUtils.rgb2hex(prev.r, prev.g, prev.b),StringUtils.rgb2hex(e.color.r, e.color.g, e.color.b)], [1,1], [0,255]);
					grad.graphics.drawRect(-oneyearfullwidth, 0, oneyearfullwidth * 2, timelineheight);
					grad.graphics.endFill();
					//grad.x = eClip.x + eClip.width;
					eClip.addChild(grad);
					eClip.swapChildren(grad, eClip.label_txt);
				}
				
				epochClip.addChild(eClip);
				
				// el color de la barrita
				miniClip = new Shape();
				miniClip.graphics.beginFill(StringUtils.rgb2hex(e.color.r, e.color.g, e.color.b));
				var miniw:int = Math.round((e.fin - e.ini + 1) * oneyearminiwidth) + scrub_mc.width;
				miniClip.graphics.drawRect(0, 0, miniw, track_mc.height);
				miniClip.graphics.endFill();
				miniClip.x = Math.round((e.ini - minyear) * oneyearminiwidth);
				track_mc.addChild(miniClip);
			}
			timelineClip.addChild(epochClip);
		}

		public function plotEvents():void {
			var i:int;
			var d:TLDot;
			var yearClip:TLRulerYear;
			var txt:String;
			var ev:Object;
			var bim:int;
			var ydif:int;
			var h:int;
			eventDots = [];
			// buscamos en los eventos
			// se asume que los eventos están ordenados cronológicamente
			for (i = 0;i < timelineevents.length;++i) {
				// por año
				ev = timelineevents[i];
				// los años en el arreglo están sin AC y con signo
				txt = ev.anotext;
				yearClip = TLRulerYear(rulerClip.getChildByName(txt));
				if (ev.mes != null) {
					// por bimestre
					// el 0 se ignora porque bim empieza en 1
					bim = Math.ceil(ev.mes / monthspermark);
				} else {
					bim = 1;
				}
				// la diferencia en y
				ydif = localeventsy;
				// la diferencia adicional en y
				h = yearClip.bimesters[bim][0];
				// sumamos uno a la cant de puntos en esa marca
				yearClip.bimesters[bim][0]++;
				// ponemos el punto donde corresponde
				d = new TLDot();
				d.name = "event_" + i.toString();
				// bim empieza en 1 pero la marca en 0 para x
				d.x = (bim - 1) * dotxdif + yearClip.x;
				d.y = ydif + (h * dotydif) + yearClip.y;
				if (ev.dia != null) {
					d.y += (monthydif * ev.dia);
				}
				// datos del evento
				ev.index = i;
				d.eventdata = ev;
				// metemos en el arreglo de eventos
				eventDots[i] = d;
				d.addEventListener("open", showTooltip);
				d.addEventListener("close", removeTooltip);
				d.init(eventClick);
				timelineClip.addChild(d);
			}
		}

		private function plotRelations():void {
			// relaciones
			var i:int;
			var l:int = eventDots.length;
			var d:TLDot;
			clearRelations();
			for (i = 0;i < l; ++i) {
				d = eventDots[i];
				if (d.eventdata.tipo == 1) {		
					// Console
					// consolas con sus empresas
					if (businessvisible && consolevisible && inspiredvisible) drawRelations(d, 4, d.eventdata.inspired);
					// consolas con consolas que las anteceden
					if (consolevisible && predecessorvisible) drawRelations(d, 1, d.eventdata.predecessor, "predecessor");
					// consolas con personas relacionadas
					if (consolevisible && personvisible && relatedvisible) drawRelations(d, 7, d.eventdata.related, "related");
				} else if (d.eventdata.tipo == 2) {
					// Controller
					// controles con su consola
					if (consolevisible && controllervisible && relatedvisible) drawRelations(d, 1, d.eventdata.related, "related");
				} else if (d.eventdata.tipo == 3) {
					// Game
					// juegos con juegos que los anteceden
					if (gamevisible && predecessorvisible) drawRelations(d, 3, d.eventdata.predecessor, "predecessor");
					// juegos con creadores
					if (personvisible && gamevisible && inspiredvisible) drawRelations(d, 7, d.eventdata.inspired);
					// juegos con empresas
					if (businessvisible && gamevisible && inspiredvisible) drawRelations(d, 4, d.eventdata.inspired);
					// juegos con juegos relacionados
					if (gamevisible && relatedvisible) drawRelations(d, 3, d.eventdata.related, "related");
				} else if (d.eventdata.tipo == 4) {
					// Business
					// negocios con sus fundadores
					if (personvisible && businessvisible && inspiredvisible) drawRelations(d, 7, d.eventdata.inspired);
				} else if (d.eventdata.tipo == 5) {
					// Technology
					// tecnologías con personas creadoras
					if (businessvisible && technologyvisible && inspiredvisible) drawRelations(d, 7, d.eventdata.inspired);
					// tecnologías con empresas
					if (businessvisible && technologyvisible && inspiredvisible) drawRelations(d, 4, d.eventdata.inspired);
					// tecnologías con consolas relacionadas
					if (consolevisible && technologyvisible && relatedvisible) drawRelations(d, 1, d.eventdata.related, "related");
				} else if (d.eventdata.tipo == 6) {
					// Cultural
					// cultura con su creador
					if (personvisible && culturalvisible && inspiredvisible) drawRelations(d, 7, d.eventdata.inspired);
					// cultura con su antecesora
					if (culturalvisible && predecessorvisible) drawRelations(d, 6, d.eventdata.predecessor, "predecessor");
					// cultura con juegos relacionados
					if (culturalvisible && gamevisible && relatedvisible) drawRelations(d, 6, d.eventdata.related, "related");
				} else if (d.eventdata.tipo == 7) {	// Person
				} else if (d.eventdata.tipo == 8) {	// Other
				}
			}
		}

		private function clearRelations():void {
			relationsClip.graphics.clear();
			var i:int;
			var l:int = relationsClip.numChildren;
			if (l > 0) {
				for (i = l-1;i >= 0; --i) {
					relationsClip.removeChildAt(i);
				}
			}
		}

		private function drawRelations(from:TLDot, totype:int, nidarray:Array, linetype:String = "solid"):void {
			var dotxy:Point;
			var relxy:Point;
			var color:Number = StringUtils.rgb2hex(from.eventdata.color.r, from.eventdata.color.g, from.eventdata.color.b);
			dotxy = from.localToGlobal(new Point(0, 0));
			var to:TLDot;
			var i:int;
			var start:Point;
			var end:Point;
			var ydif:int;
			var decade:int;
			var dashedline:DashedLine;
			if (nidarray.length > 0) {
				for (i = 0;i < nidarray.length; ++i) {
					to = getEventByNid(nidarray[i]);
					if (to.eventdata.tipo == totype) { 
						// relacionamos controles con su consola
						// convertir coords rdot a global
						relxy = to.localToGlobal(new Point(relationxfin, relationyfin));
						start = relationsClip.globalToLocal(dotxy);
						end = relationsClip.globalToLocal(relxy);
						ydif = (start.y < end.y) ? Math.round((end.y - start.y) / 3) : Math.round((end.y - start.y) / 4);
						decade = parseInt(String(from.eventdata.ano).substr(2, 2));
						if (Math.abs(start.y - end.y) == relationyfin) {
							// están al mismo y
							ydif += dotydif / 5 + Math.round(decade / 8);
						}
						if (from.y == localeventsy || to.y == localeventsy) {
							// está en el "techo"
							ydif += Math.round(dotydif / 6);
						}
						if (from.eventdata.mes != null) {
							ydif += Math.round(from.eventdata.mes/2);
						}
						if (to.eventdata.mes != null) {
							ydif += Math.round(to.eventdata.mes/3);
						}
						if (from.eventdata.dia != null) {
							ydif += Math.round(from.eventdata.dia/4);
						}
						if (to.eventdata.dia != null) {
							ydif += Math.round(to.eventdata.dia/5);
						}
						if (linetype == "predecessor") {
							ydif += 3;
						}
						if (linetype == "related") {
							ydif += 4;
						}
						// pintamos la raya en funcion de las globales
						if (linetype == "solid") {
							relationsClip.graphics.lineStyle(0, color, 1, false, "normal", null);
							relationsClip.graphics.moveTo(start.x, start.y);
							if (start.x > end.x) {
								relationsClip.graphics.lineTo(start.x - oneyearfullwidth / 4, start.y + ydif);
								relationsClip.graphics.lineTo(end.x + oneyearfullwidth / 4, start.y + ydif);
							} else {
								relationsClip.graphics.lineTo(start.x + oneyearfullwidth / 5, start.y + ydif);
								relationsClip.graphics.lineTo(end.x - oneyearfullwidth / 5, start.y + ydif);
							}
							relationsClip.graphics.lineTo(end.x, end.y);
						} else {
							if (linetype == "predecessor") {
								dashedline = new DashedLine(1, color, new Array(4, 2));
							} else if (linetype == "related") {
								dashedline = new DashedLine(1, color, new Array(6, 2, 2, 2));
							}
							dashedline.moveTo(start.x, start.y);
							if (start.x > end.x) {
								dashedline.lineTo(start.x - oneyearfullwidth / 5, start.y + ydif);
								dashedline.lineTo(end.x + oneyearfullwidth / 5, start.y + ydif);
							} else {
								dashedline.lineTo(start.x + oneyearfullwidth / 6, start.y + ydif);
								dashedline.lineTo(end.x - oneyearfullwidth / 6, start.y + ydif);
							}
							dashedline.lineTo(end.x, end.y);
							relationsClip.addChild(dashedline);
						}
					}
				}
			}
		}

		private function getEventByNid(nid:int):TLDot {
			var dot:TLDot;
			var i:int;
			for (i = 0;i < eventDots.length; ++i) {
				if (eventDots[i].eventdata.nid == nid) {
					dot = eventDots[i];
					break;
				}
			}
			return dot;
		}

		private function getEventIndexFromNid(nid:int):int {
			var index:int;
			var i:int;
			for (i = 0;i < eventDots.length;++i) {
				if (eventDots[i].eventdata.nid == nid) {
					index = i;
					break;
				}
			}
			return index;
		}

		public function eventDisable(index:int = -1):void {
			var i:int;
			var d:TLDot;
			removeDetail();
			for (i = 0;i < eventDots.length;++i) {
				d = eventDots[i];
				//d.setActive(false);
				if (i != index) {
					d.shrink();
				}
			}
		}

		public function eventEnableVisible(e:* = null):void {
			if (e);
			var i:int;
			var d:TLDot;
			var visibleyears:Array = visibleYears();
			var c:int = 0;
			for (i = 0;i < eventDots.length;++i) {
				d = eventDots[i];
				d.setActive(true);
				d.shrink(e);
				if (eventDots[i].eventdata.ano >= visibleyears[0] && eventDots[i].eventdata.ano < visibleyears[1]) {
					c++;
				}
			}
			if (!timeline_mc.getChildByName("detail")) {
				if (c == 0) {
					// no hay eventos visibles
					eventsEmpty(false, visibleyears[0], visibleyears[1]);
				} else {
					eventsEmpty(true, visibleyears[0], visibleyears[1]);
				}
			}
		}

		private function eventsEmpty(empty:Boolean, ini:int = 0, fin:int = 0):void {
			noevents_mc.visible = !empty;
			emptystartyear = ini;
			emptyendyear = fin;
		}

		public function eventReset(index:int = 0):void {
			var i:int;
			var d:TLDot;
			for (i = 0;i < eventDots.length;++i) {
				d = eventDots[i];
				if (i != index) {
					d.shrink();
				}
			}
		}

		public function eventUpdate():void {
			//eventDisable();
			eventEnableVisible();
		}

		public function visibleYears():Array {
			// los visibles son dados por el x del timeline
			var firstyear:int = minyear + Math.floor(Math.abs(timelineClip.x) / oneyearfullwidth);
			var lastyear:int = minyear + Math.ceil((Math.abs(timelineClip.x) + swidth) / oneyearfullwidth);
			return [firstyear,lastyear];
		}

		public function eventClick(e:MouseEvent):void {
			var d:TLDot = TLDot(e.target.parent);
			var index:int = int(d.name.substr(6));
			//eventDisable(index);
			currenteventindex = index;
			processSWFAddress("/" + d.eventdata.nid);
		}

		private function showTooltip(e:Event):void {
			var dot:TLDot = TLDot(e.target);
			timelineClip.setChildIndex(dot, timelineClip.numChildren - 1);
		}

		private function removeTooltip(e:Event):void {
			if (timeline_mc.getChildByName("tip")) timeline_mc.removeChild(timeline_mc.getChildByName("tip"));
		}

		private function showDetail(eventdata:Object):void {
			removeDetail();
			detail = new TLDetail();
			detail.name = "detail";
			var global:Point = new Point(detailx, detaily);
			var local:Point = timeline_mc.globalToLocal(global);
			detail.x = local.x;
			detail.y = local.y;
			detail.addEventListener("prevClick", eventPrev);
			detail.addEventListener("nextClick", eventNext);
			detail.close_mc.addEventListener(MouseEvent.CLICK, closeClick);
			detail.close_mc.addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			detail.close_mc.addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
			detail.close_mc.buttonMode = true;
			timeline_mc.addChild(detail);
			detail.initWithData(eventdata);
			if (eventdata.index < eventDots.length - 1) {
				detail.arrow_r_mc.visible = true;
			} else {
				detail.arrow_r_mc.visible = false;
			}
			if (eventdata.index > 0) {
				detail.arrow_l_mc.visible = true;
			} else {
				detail.arrow_l_mc.visible = false;
			}
			eventReset(eventdata.index);
		}

		private function connectDetail(dot:TLDot):void {
			removeDetailConnector();
			if (timeline_mc.getChildByName("detail")) {
				var detail:TLDetail = TLDetail(timeline_mc.getChildByName("detail"));
				var connector:Shape = new Shape();
				var tl_dot:Point = dot.localToGlobal(new Point(0, 0));
				var origin:Point = detail.localToGlobal(new Point(0, 0));
				var tl_origin:Point = timeline_mc.globalToLocal(origin);
				connector.name = "connector";
				connector.graphics.beginFill(StringUtils.rgb2hex(dot.eventdata.color.r, dot.eventdata.color.g, dot.eventdata.color.b));
				connector.graphics.drawRect(tl_origin.x + connectorx, tl_origin.y + connectory, Math.abs(connectorx), tl_dot.y - origin.y + Math.abs(connectory));
				timeline_mc.addChild(connector);
			}
		}

		private function removeDetail():void {
			var detail:TLDetail;
			removeDetailConnector();
			if (timeline_mc.getChildByName("detail")) {
				detail = TLDetail(timeline_mc.getChildByName("detail"));
				detail.removeEventListener("prevClick", eventPrev);
				detail.removeEventListener("nextClick", eventNext);
				detail.close_mc.removeEventListener(MouseEvent.CLICK, closeClick);
				detail.close_mc.removeEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
				detail.close_mc.removeEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
				timeline_mc.removeChild(detail);
				stage.focus = stage;
			}
		}

		private function removeDetailConnector():void {
			if (timeline_mc.getChildByName("connector")) {
				timeline_mc.removeChild(timeline_mc.getChildByName("connector"));
			}
		}

		private function showLineButtons():void {
			related_mc.visible = inspired_mc.visible = predecessor_mc.visible = true;
		}

		private function hideLineButtons():void {
			related_mc.visible = inspired_mc.visible = predecessor_mc.visible = false;
		}

		private function toggleClick(e:MouseEvent):void {
			var btn:MovieClip = MovieClip(e.currentTarget);
			var t:Boolean;
			switch (btn.name) {
				case "person_mc":
					t = personvisible = !personvisible;
					break;
				case "technology_mc":
					t = technologyvisible = !technologyvisible;
					break;
				case "business_mc":
					t = businessvisible = !businessvisible;
					break;
				case "console_mc":
					t = consolevisible = !consolevisible;
					break;
				case "controller_mc":
					t = controllervisible = !controllervisible;
					break;
				case "game_mc":
					t = gamevisible = !gamevisible;
					break;
				case "cultural_mc":
					t = culturalvisible = !culturalvisible;
					break;
				case "other_mc":
					t = othervisible = !othervisible;
					break;
				case "related_mc":
					t = relatedvisible = !relatedvisible;
					break;
				case "predecessor_mc":
					t = predecessorvisible = !predecessorvisible;
					break;
				case "inspired_mc":
					t = inspiredvisible = !inspiredvisible;
					break;
			}
			btn.gotoAndStop(t ? 1 : 2);
			updateView();
			if (spacepressed) plotRelations();
		}

		private function toggleRollOver(e:MouseEvent):void {
			var btn:MovieClip = MovieClip(e.currentTarget);
			var t:Boolean;
			switch (btn.name) {
				case "person_mc":
					t = personvisible;
					break;
				case "technology_mc":
					t = technologyvisible;
					break;
				case "business_mc":
					t = businessvisible;
					break;
				case "console_mc":
					t = consolevisible;
					break;
				case "controller_mc":
					t = controllervisible;
					break;
				case "game_mc":
					t = gamevisible;
					break;
				case "cultural_mc":
					t = culturalvisible;
					break;
				case "other_mc":
					t = othervisible;
					break;
				case "related_mc":
					t = relatedvisible;
					break;
				case "predecessor_mc":
					t = predecessorvisible;
					break;
				case "inspired_mc":
					t = inspiredvisible;
					break;
			}
			btn.gotoAndStop(t ? 2 : 1);
		}

		private function toggleRollOut(e:MouseEvent):void {
			var btn:MovieClip = MovieClip(e.currentTarget);
			var t:Boolean;
			switch (btn.name) {
				case "person_mc":
					t = personvisible;
					break;
				case "technology_mc":
					t = technologyvisible;
					break;
				case "business_mc":
					t = businessvisible;
					break;
				case "console_mc":
					t = consolevisible;
					break;
				case "controller_mc":
					t = controllervisible;
					break;
				case "game_mc":
					t = gamevisible;
					break;
				case "cultural_mc":
					t = culturalvisible;
					break;
				case "other_mc":
					t = othervisible;
					break;
				case "related_mc":
					t = relatedvisible;
					break;
				case "predecessor_mc":
					t = predecessorvisible;
					break;
				case "inspired_mc":
					t = inspiredvisible;
					break;
			}
			btn.gotoAndStop(t ? 1 : 2);
		}

		private function buttonRollOver(e:MouseEvent):void {
			var b:MovieClip = MovieClip(e.target);
			b.gotoAndStop(2);
		}

		private function buttonRollOut(e:MouseEvent):void {
			var b:MovieClip = MovieClip(e.target);
			b.gotoAndStop(1);
		}

		private function closeClick(e:MouseEvent):void {
			removeDetail();
			eventEnableVisible();
		}

		private function eventPrev(e:Event):void {
			var d:TLDot = getEvent(-1);
			var index:int = int(d.name.substr(6));
			//eventDisable(index);
			currenteventindex = index;
			processSWFAddress("/" + d.eventdata.nid);
		}

		private function eventNext(e:Event):void {
			var d:TLDot = getEvent(1);
			var index:int = int(d.name.substr(6));
			//eventDisable(index);
			currenteventindex = index;
			processSWFAddress("/" + d.eventdata.nid);
		}

		private function getEvent(diff:int):TLDot {
			var d:TLDot;
			var event:int;
			if (diff == -1 && currenteventindex == 0) {
				event = 0;
			} else if (diff == 1 && currenteventindex == eventDots.length - 1) {
				event = eventDots.length - 1;			
			} else {
				event = currenteventindex + diff;
			}
			d = eventDots[event];
			return d;
		}

		private function eventPrevEmpty(event:MouseEvent):void {
			var d:TLDot = getEventEmpty(-1);
			var index:int = int(d.name.substr(6));
			//eventDisable(index);
			currenteventindex = index;
			processSWFAddress("/" + d.eventdata.nid);
		}

		private function eventNextEmpty(event:MouseEvent):void {
			var d:TLDot = getEventEmpty(1);
			var index:int = int(d.name.substr(6));
			//eventDisable(index);
			currenteventindex = index;
			processSWFAddress("/" + d.eventdata.nid);
		}

		private function getEventEmpty(diff:int):TLDot {
			var d:TLDot;
			var i:int;
			var l:int = eventDots.length;
			for (i = 0;i < l; ++i) {
				if (diff == -1) {
					// buscar el ultimo evento con año inmediatamente menor al que nos dan
					if (eventDots[i].eventdata.ano > emptystartyear) {
						break;
					}
				} else {
					// buscar el primer evento con año inmediatamente mayor al que nos dan
					if (eventDots[i].eventdata.ano >= emptyendyear) {
						d = eventDots[i];
						break;
					}
				}
				d = eventDots[i];
			}
			return d;
		}

		private function hideEmpty():void {
			eventsEmpty(true);
		}

		private function updateView():void {
			var i:int;
			var l:int = eventDots.length;
			var d:TLDot;
			for (i = 0;i < l; ++i) {
				d = eventDots[i];
				if (d.eventdata.tipo == 1) {						
					d.visible = consolevisible;
				} else if (d.eventdata.tipo == 2) {						
					d.visible = controllervisible;
				} else if (d.eventdata.tipo == 3) {						
					d.visible = gamevisible;
				} else if (d.eventdata.tipo == 4) {						
					d.visible = businessvisible;
				} else if (d.eventdata.tipo == 5) {
					d.visible = technologyvisible;
				} else if (d.eventdata.tipo == 6) {						
					d.visible = culturalvisible;
				} else if (d.eventdata.tipo == 7) {
					d.visible = personvisible;
				} else if (d.eventdata.tipo == 8) {						
					d.visible = othervisible;
				}
			}
		}

		/* *********************************************************************
		 * FUNCIONES DE ARRASTRE
		 */
		public function centerOnEvent(dot:TLDot, index:int = -1):void {
			hideEmpty();
			if (index != -1) {
				// aca sacar el dot
			}
			showDetail(dot.eventdata);
			timelineClip.setChildIndex(dot, timelineClip.numChildren - 1);
			// epoch
			dot.grow();
			var newepochx:int = timelineClip.x + xdotdetail - dot.localToGlobal(new Point(0, 0)).x;
			if (newepochx > epochmaxx) newepochx = epochmaxx;
			if (newepochx < epochminx) newepochx = epochminx;
			TweenMax.to(timelineClip, 1.0, {x:newepochx, ease:Expo.easeOut, onComplete:connectDetail, onCompleteParams:[dot]});
			// scrub
			var newx:int;
			newx = Math.round(((miniwidth) * newepochx) / epochminx);
			if (newx > miniwidth) newx = miniwidth;
			if (newx < 0) newx = 0;
			TweenMax.to(scrub_mc, 1.0, {x:newx, ease:Expo.easeOut});
		}

		public function centerOnYear(year:int):void {
			hideEmpty();
			// el clip año
			var clip:TLRulerYear = TLRulerYear(rulerClip.getChildByName(year.toString()));
			var newepochx:int = timelineClip.x + xdotdetail - clip.localToGlobal(new Point(0, 0)).x;
			if (newepochx > epochmaxx) newepochx = epochmaxx;
			if (newepochx < epochminx) newepochx = epochminx;
			TweenMax.to(timelineClip, 1.0, {x:newepochx, ease:Expo.easeOut, onComplete:eventEnableVisible});
			// scrub
			var newx:int;
			newx = Math.round(((miniwidth) * newepochx) / epochminx);
			if (newx > miniwidth) newx = miniwidth;
			if (newx < 0) newx = 0;
			TweenMax.to(scrub_mc, 1.0, {x:newx, ease:Expo.easeOut});
		}

		public function scrubTimeline(e:MouseEvent):void {
			hideEmpty();
			removeDetailConnector();
			//eventDisable();
			var newx:int = Math.round(track_mc.mouseX - (scrub_mc.width / 2));
			if (newx > miniwidth) newx = miniwidth;
			if (newx < 0) newx = 0;
			// el x del scrub es igual a newx
			TweenMax.to(scrub_mc, 1.0, {x:newx, ease:Expo.easeOut});
			// epoch
			var newepochx:int;
			newepochx = -Math.round(((epochmaxx - epochminx) * newx) / miniwidth);
			TweenMax.to(timelineClip, 1.0, {x:newepochx, ease:Expo.easeOut, onComplete:eventEnableVisible});
		}

		public function dragTimeline(e:MouseEvent):void {
			if (e.target.name != "hit_mc") {
				addEventListener(Event.ENTER_FRAME, timelineInertia);
				removeDetailConnector();
				//eventDisable();
				timelinedragging = true;
				timelineClip.startDrag(false, new Rectangle(timeline_mc.x - (timelineClip.width - swidth), timelineClip.y, timelineClip.width - swidth, 0));
			}
		}

		public function dropTimeline(e:MouseEvent):void {
			timelinedragging = false;
			timelineClip.stopDrag();
		}

		private function timelineInertia(e:Event):void {
			hideEmpty();
			var newx:int;
			if (timelinedragging) {
				_timelinespeed = mouseX - _prev_mouseX;
				// scrub
				newx = getNewX("scrub");
				if (newx > miniwidth) newx = miniwidth;
				if (newx < 0) newx = 0;
				scrub_mc.x = newx;
			} else {
				timelineClip.x += _timelinespeed;
				_timelinespeed *= 0.9;
				// scrub
				newx = getNewX("scrub");
				scrub_mc.x = newx;
				if (timelineClip.x > epochmaxx) {
					timelineClip.x = epochmaxx;
					scrub_mc.x = 0;
					_timelinespeed = 0; //-_timelinespeed;
				} else if (timelineClip.x < epochminx) {
					timelineClip.x = epochminx;
					scrub_mc.x = miniwidth;
					_timelinespeed = 0; //-_timelinespeed;
				}
				if (Math.abs(_timelinespeed) < 0.1) {
					timelineClip.x = Math.round(timelineClip.x);
					scrub_mc.x = Math.round(scrub_mc.x);
					eventEnableVisible();
					removeEventListener(Event.ENTER_FRAME, timelineInertia);
				}
			}
			_prev_mouseX = mouseX;
		}

		public function dragScrub(e:MouseEvent):void {
			addEventListener(Event.ENTER_FRAME, scrubInertia);
			removeDetailConnector();
			//eventDisable();
			scrubdragging = true;
			scrub_mc.startDrag(false, new Rectangle(track_mc.x, track_mc.y, miniwidth, 0));
		}

		public function dropScrub(e:MouseEvent):void {
			scrubdragging = false;
			scrub_mc.stopDrag();
		}

		private function scrubInertia(e:Event):void {
			hideEmpty();
			var newepochx:int;
			if (scrubdragging) {
				_scrubspeed = mouseX - _prev_mouseX;
				// epoch
				newepochx = getNewX("epoch");
				timelineClip.x = newepochx;
			} else {
				scrub_mc.x += _scrubspeed;
				_scrubspeed *= 0.2;
				// epoch
				newepochx = getNewX("epoch");
				timelineClip.x = newepochx;
				if (scrub_mc.x > miniwidth) {
					timelineClip.x = epochminx;
					scrub_mc.x = miniwidth;
					_scrubspeed = 0; //-_scrubspeed;
				} else if (scrub_mc.x < 0) {
					timelineClip.x = epochmaxx;
					scrub_mc.x = 0;
					_scrubspeed = 0; //-_scrubspeed;
				}
				if (Math.abs(_scrubspeed) < 0.05) {
					timelineClip.x = Math.round(timelineClip.x);
					scrub_mc.x = Math.round(scrub_mc.x);
					eventEnableVisible();
					removeEventListener(Event.ENTER_FRAME, scrubInertia);
				}
			}
			_prev_mouseX = mouseX;
		}

		private function mousePosition(e:MouseEvent):void {
			if (!scrubdragging && !timelinedragging) {
				_prev_mouseX = mouseX;
			}
		}

		private function getNewX(clip:String):int {
			var x:int;
			if (clip == "epoch") {
				x = -Math.round(((epochmaxx - epochminx) * scrub_mc.x) / miniwidth);
			} else if (clip == "scrub") {
				x = Math.round(((miniwidth) * timelineClip.x) / epochminx);
			}
			return x;
		}

		/* *********************************************************************
		 * BUSCADOR
		 */
		private function showResults(str:String):void {
			removeResults();
			trace(str);
			// mientras se hace bien
			var d:TLDot = getEvent(1);
			var index:int = int(d.name.substr(6));
			//eventDisable(index);
			centerOnEvent(d);
			currenteventindex = index;
			showDetail(d.eventdata);
			// cajita resultados
			var r:TLResults = new TLResults();
			r.name = "results";
			var global:Point = new Point(resultsx, resultsy);
			var local:Point = timeline_mc.globalToLocal(global);
			r.x = local.x;
			r.y = local.y;
			r.close_mc.addEventListener(MouseEvent.CLICK, closeResultsClick);
			r.close_mc.addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			r.close_mc.addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
			r.close_mc.buttonMode = true;
			timeline_mc.addChild(r);
		}

		private function removeResults():void {
			var r:TLResults;
			if (timeline_mc.getChildByName("results")) {
				r = TLResults(timeline_mc.getChildByName("results"));
				r.close_mc.removeEventListener(MouseEvent.CLICK, closeResultsClick);
				r.close_mc.removeEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
				r.close_mc.removeEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
				timeline_mc.removeChild(r);
			}
		}

		private function searchClick(event:MouseEvent):void {
			var str:String = keyword_txt.text;
			if (0) showResults(str);
		}

		private function closeResultsClick(event:MouseEvent):void {
			removeResults();
			eventEnableVisible();
		}

		/* *********************************************************************
		 * INICIALIZACION
		 */
		private function init():void {
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, handleSWFAddress);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP;
			eventsEmpty(true);
			hideLineButtons();
			if (1) {
				loadEvents();
			} else {
				generateEpochs();
				
				generateEvents();				
			}
		}

		private function setupListeners():void {
			noevents_mc.arrow_l_mc.buttonMode = true;
			noevents_mc.arrow_l_mc.addEventListener(MouseEvent.CLICK, eventPrevEmpty);
			noevents_mc.arrow_l_mc.addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			noevents_mc.arrow_l_mc.addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
			
			noevents_mc.arrow_r_mc.buttonMode = true;
			noevents_mc.arrow_r_mc.addEventListener(MouseEvent.CLICK, eventNextEmpty);
			noevents_mc.arrow_r_mc.addEventListener(MouseEvent.ROLL_OVER, buttonRollOver);
			noevents_mc.arrow_r_mc.addEventListener(MouseEvent.ROLL_OUT, buttonRollOut);
			
			buscar_btn.buttonMode = true;
			buscar_btn.addEventListener(MouseEvent.CLICK, searchClick);
			
			track_mc.addEventListener(MouseEvent.MOUSE_UP, scrubTimeline);

			scrub_mc.addEventListener(MouseEvent.MOUSE_DOWN, dragScrub);
			scrub_mc.addEventListener(MouseEvent.MOUSE_UP, dropScrub);
			scrub_mc.buttonMode = true;
			
			timelineClip.addEventListener(MouseEvent.MOUSE_DOWN, dragTimeline);
			timelineClip.addEventListener(MouseEvent.MOUSE_UP, dropTimeline);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mousePosition);
			stage.addEventListener(MouseEvent.MOUSE_UP, dropScrub);
			stage.addEventListener(MouseEvent.MOUSE_UP, dropTimeline);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			
			// barra toggles
			person_mc.buttonMode = true;
			person_mc.hitArea = person_mc.hit_mc;
			person_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			person_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			person_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			technology_mc.buttonMode = true;
			technology_mc.hitArea = person_mc.hit_mc;
			technology_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			technology_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			technology_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			business_mc.buttonMode = true;
			business_mc.hitArea = person_mc.hit_mc;
			business_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			business_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			business_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			console_mc.buttonMode = true;
			console_mc.hitArea = person_mc.hit_mc;
			console_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			console_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			console_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			controller_mc.buttonMode = true;
			controller_mc.hitArea = person_mc.hit_mc;
			controller_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			controller_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			controller_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			game_mc.buttonMode = true;
			game_mc.hitArea = person_mc.hit_mc;
			game_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			game_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			game_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			cultural_mc.buttonMode = true;
			cultural_mc.hitArea = person_mc.hit_mc;
			cultural_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			cultural_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			cultural_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			other_mc.buttonMode = true;
			other_mc.hitArea = person_mc.hit_mc;
			other_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			other_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			other_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			
			// botones rayitas
			related_mc.buttonMode = true;
			related_mc.hitArea = related_mc.hit_mc;
			related_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			related_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			related_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			predecessor_mc.buttonMode = true;
			predecessor_mc.hitArea = predecessor_mc.hit_mc;
			predecessor_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			predecessor_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			predecessor_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
			inspired_mc.buttonMode = true;
			inspired_mc.hitArea = inspired_mc.hit_mc;
			inspired_mc.addEventListener(MouseEvent.CLICK, toggleClick);
			inspired_mc.addEventListener(MouseEvent.ROLL_OVER, toggleRollOver);
			inspired_mc.addEventListener(MouseEvent.ROLL_OUT, toggleRollOut);
		}

		/* *********************************************************************
		 * TECLADO
		 */
		private function keyDownHandler(e:KeyboardEvent):void {
			// 32 = SPACE
			var code:uint = e.keyCode;
			if (code == 32 && !spacepressed) {
				stage.quality = StageQuality.LOW;
				spacepressed = true;
				var i:int;
				for (i = 0;i < eventDots.length; ++i) {
					eventDots[i].setMode("mini");
				}
				showLineButtons();
				plotRelations();
			}
		}
		
		private function keyUpHandler(e:KeyboardEvent):void {
			// 32 = SPACE
			var code:uint = e.keyCode;
			if (code == 32) {
				stage.quality = StageQuality.HIGH;
				spacepressed = false;
				var i:int;
				for (i = 0;i < eventDots.length; ++i) {
					eventDots[i].setMode("full");
				}
				hideLineButtons();
				clearRelations();
			}
		}
		
		/* *********************************************************************
		 * SWFADDRESS
		 */
		private function handleSWFAddress(e:SWFAddressEvent):void {
			lastaddress = e.value;
			if (hasloaded) {
				gotoURL(e.value);
			}
		}

		private function gotoURL(url:String):void {
			var nid:int = parseInt(url.replace("/", ""));
			var d:TLDot = getEventByNid(nid);
			centerOnEvent(d);
		}

		private function processSWFAddress(url:String):void {
			var nid:int = parseInt(url.replace("/", ""));
			var index:int = getEventIndexFromNid(nid);
			currenteventindex = index;
			if (lastaddress != url) {
				lastaddress = url;
				SWFAddress.setValue(url);
			} else {
				gotoURL(url);
			}
		}

		/* *********************************************************************
		 * FLASH REMOTING
		 */
		private function setStatus(str:String = null):void {
			if (str == null || str == "") {
				status_txt.text = "";
				status_txt.visible = false;
			} else {
				status_txt.text = str;
				status_txt.visible = true;
			}
		}

		private function loadEvents():void {
			setStatus("loading events...");
			var conn:NetConnection = new NetConnection;
			conn.objectEncoding = ObjectEncoding.AMF3;
			conn.connect(_amfurl);
			var res:Responder = new Responder(onEventsLoaded, onFault);
			conn.call("views.get", res, "events_all");
		}

		private function onEventsLoaded(r:*):void {
			hasloaded = true;
			setStatus("parsing...");
			timelineevents = [];
			var o:Object;
			minyear = 2010;
			maxyear = 0;
			for each (var node in r) {
				if (node.field_year[0].value < minyear) {
					minyear = node.field_year[0].value;
				}
				if (node.field_year[0].value > maxyear) {
					maxyear = node.field_year[0].value;
				}
				o = {};
				o.nid = node.nid;
				o.ano = node.field_year[0].value;
				o.anotext = o.ano;
				if (o.ano < 0) {
					o.anotext = Math.abs(o.ano) + " " + bcyearname;
				}
				o.mes = node.field_month[0].value;
				o.dia = node.field_day[0].value;
				o.tipo = node.field_category[0].value;
				o.titulo = node.title;
				o.texto = node.body;
				o.color = StringUtils.web2rgb(eventcolors[o.tipo]);
				o.links = [{name:"source", url:node.field_source[0].value},{name:"permalink", url:_url + "node/" + node.nid}];
				if (node.field_photo[0] != null) {
					o.thumb = (node.field_photo[0].filepath == null) ? null : _url + "sites/default/files/imagecache/event-th/" + String(node.field_photo[0].filepath).replace("sites/default/files/", "");
					o.photo = (node.field_photo[0].filepath == null) ? null : _url + "sites/default/files/imagecache/event-big/" + String(node.field_photo[0].filepath).replace("sites/default/files/", "");
				}
				// relaciones
				var rel:*;
				o.inspired = [];
				if (node.field_inspired[0] != null) {
					for each (rel in node.field_inspired) {
						if (rel.nid != null) o.inspired.push(rel.nid);
					}
				}
				o.related = [];
				if (node.field_related[0] != null) {
					for each (rel in node.field_related) {
						if (rel.nid != null) o.related.push(rel.nid);
					}
				}
				o.predecessor = [];
				if (node.field_predecessor[0] != null) {
					for each (rel in node.field_predecessor) {
						if (rel.nid != null) o.predecessor.push(rel.nid);
					}
				}
				// tags
				o.tags = [];
				if (node.taxonomy.length > 0) {
					for each (var tag in node.taxonomy) {
						if (tag.name != null) o.tags.push(tag.name);
					}
				}
				timelineevents.push(o);
			}
			minyear--;
			maxyear += 3;
			timelineepochs = [];
			timelineepochs.push({
				color: {r:0, g:0, b:0}, ini: minyear, fin: maxyear, titulo: ""
			});
			
			deltayears = maxyear - minyear;
			epochmaxx = 0;
			epochminx = -Math.floor((oneyearfullwidth * (deltayears)) - swidth);
			miniwidth = track_mc.width - scrub_mc.width;
			oneyearminiwidth = miniwidth / deltayears;
			
			setupTimeline();
			setupListeners();
			// cargar el url que venía deep linked
			setStatus();
			if (lastaddress != "/") {
				processSWFAddress(lastaddress);
			} else {
				centerOnYear(1950);
			}
		}

		private function onFault(f:Object):void {
			for each (var node in f) {
				trace(node);
			}
		}
	}
}
