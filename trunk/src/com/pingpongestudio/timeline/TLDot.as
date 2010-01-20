/**
 * VGLine 0.1: The Videogame Timeline <http://www.mauriciogiraldo.com/vgline/beta/>
 *
 * VGLine is (c) 2009-2010 Mauricio Giraldo Arteaga
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 *
 */
package com.pingpongestudio.timeline {
	import com.pingpongestudio.utils.StringUtils;
	import com.webdevils.display.ImageLoader;

	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;

	/**
	 * @author Mauricio Giraldo Arteaga <http://www.mauriciogiraldo.com/> 
	 */
	public class TLDot extends MovieClip {

		private var _mode:String;
		private var clickHandler:Function;
		public var hit_mc:MovieClip;
		public var circulo_mc:MovieClip;
		public var eventdata:Object;
		public var active:Boolean = true;
		public var label_txt:TextField;
		public var minilabel_txt:TextField;
		public var photo_mc:MovieClip;
		public var fondo_mc:MovieClip;
		public var fondo_mini_mc:MovieClip;
		public var blanco_mini_mc:MovieClip;
		public var blanco_full_mc:MovieClip;
		public var shadow_mini_mc:MovieClip;
		public var shadow_full_mc:MovieClip;

		public function TLDot() {
		}
		
		public function init(click:Function):void {
			clickHandler = click;
			//setActive(false);
			// color de fondo
			var ct:ColorTransform = new ColorTransform(eventdata.color.r / 255, eventdata.color.g / 255, eventdata.color.b / 255);
			fondo_mc.transform.colorTransform = ct;
			fondo_mini_mc.transform.colorTransform = ct;
			// el texto
			var ss:StyleSheet = new StyleSheet();
			var css:String = ".date { color:" + StringUtils.rgb2web(eventdata.color.r, eventdata.color.g, eventdata.color.b) + "; font-family:Inconsolata; font-size:10; }";
			css += ".text { color:#333333; font-family:Inconsolata; font-size:10; } ";
			ss.parseCSS(css);
			var str:String = "";
			if (eventdata.dia != null) str += eventdata.dia + "/";
			if (eventdata.mes != null) str += eventdata.mes + "/";
			str += eventdata.anotext;
			
			label_txt = new TextField();
			label_txt.width = 65;
			label_txt.height = 48;
			label_txt.x = 41;
			label_txt.y = -1;
			label_txt.multiline = true;
			label_txt.wordWrap = true;
			label_txt.embedFonts = true;
			label_txt.selectable = false;
			label_txt.antiAliasType = "advanced";
			label_txt.styleSheet = ss;
			label_txt.htmlText = "<span class=\"date\">" + str + "</span><br><span class=\"text\">" + eventdata.titulo + "</span>";

			addChild(label_txt);
			
			minilabel_txt = new TextField();
			minilabel_txt.width = 115;
			minilabel_txt.height = 25;
			minilabel_txt.x = 1;
			minilabel_txt.y = -1;
			minilabel_txt.multiline = true;
			minilabel_txt.wordWrap = true;
			minilabel_txt.embedFonts = true;
			minilabel_txt.selectable = false;
			minilabel_txt.antiAliasType = "advanced";
			minilabel_txt.styleSheet = ss;
			
			var ministr:String = eventdata.titulo;
			if (ministr.length > 20) {
				ministr = ministr.substr(0, 17) + "...";
			}
			minilabel_txt.htmlText = "<span class=\"text\">" + ministr + "</span>";

			addChild(minilabel_txt);
			
			swapChildren(hit_mc, minilabel_txt);
			
			// la foto
			if (eventdata.thumb != null) {
				var load:ImageLoader = new ImageLoader(eventdata.thumb, 40, 40, 0, 0x000000, Inconsolata, 10);
				photo_mc.addChild(load);
			}
			setActive(true);
			setMode("full");
		}
		
		public function setMode(mode:String):void {
			_mode = mode; 
			if (mode == "full") {
				minilabel_txt.visible = false;
				blanco_mini_mc.visible = false;
				shadow_mini_mc.visible = false;
				fondo_mini_mc.visible = false;
				photo_mc.visible = true;
				label_txt.visible = true;
				blanco_full_mc.visible = true;
				shadow_full_mc.visible = true;
				fondo_mc.visible = true;
			} else {
				minilabel_txt.visible = true;
				blanco_mini_mc.visible = true;
				shadow_mini_mc.visible = true;
				fondo_mini_mc.visible = true;
				photo_mc.visible = false;
				label_txt.visible = false;
				blanco_full_mc.visible = false;
				shadow_full_mc.visible = false;
				fondo_mc.visible = false;
			}
		}

		public function setActive(a:Boolean):void {
			active = a;
			if (a) {
				addDotListeners();
				hit_mc.buttonMode = true;
			} else {
				removeDotListeners();
				dispatchEvent(new Event("close"));
				//removeTooltip();
				hit_mc.buttonMode = false;
			}
		}
		
		private function dotRollOver(e:MouseEvent):void {
			if (active) {
				grow();
				dispatchEvent(new Event("open"));
				//showTooltip();
			}
		}

		private function dotRollOut(e:MouseEvent):void {
			if (active) {
				shrink();
				dispatchEvent(new Event("close"));
				//removeTooltip();
			}
		}

		private function dotClick(e:MouseEvent):void {
			if (active) {
				//setActive(false);
				grow();
			}
		}
		
		private function addDotListeners():void {
			hit_mc.addEventListener(MouseEvent.ROLL_OVER, dotRollOver);
			hit_mc.addEventListener(MouseEvent.ROLL_OUT, dotRollOut);
			hit_mc.addEventListener(MouseEvent.CLICK, dotClick);
			hit_mc.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		private function removeDotListeners():void {
			hit_mc.removeEventListener(MouseEvent.ROLL_OVER, dotRollOver);
			hit_mc.removeEventListener(MouseEvent.ROLL_OUT, dotRollOut);
			hit_mc.removeEventListener(MouseEvent.CLICK, dotClick);
			hit_mc.removeEventListener(MouseEvent.CLICK, clickHandler);
		}

		public function grow():void {
			circulo_mc.width = 8;
			circulo_mc.height = 8;
		}

		public function shrink(e:MouseEvent = null):void {
			circulo_mc.width = 4;
			circulo_mc.height = 4;
		}
	}
}
