/**
 * VGLine 0.1: The Videogame Timeline <http://www.mauriciogiraldo.com/vgline/beta/>
 *
 * VGLine is (c) 2009-2010 Mauricio Giraldo Arteaga
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 *
 */
package {
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

	/**
	 * @author Mauricio Giraldo Arteaga <http://www.mauriciogiraldo.com/> 
	 */
	public class TLResultItem extends MovieClip {

		public var hit_mc:MovieClip;
		public var text_txt:TextField;
		public var background_mc:MovieClip;
		public var dot:TLDot;
		public var active:Boolean = false;

		public function TLResultItem() {
			background_mc.stop();
		}

		public function init(d:TLDot):void {
			dot = d;
			var data:Object = dot.eventdata;
			var ss:StyleSheet = new StyleSheet();
			var css:String = ".text { color:#333333; font-family:Inconsolata; font-size:10; } ";
			var itemhtml:String;
			itemhtml = "<span class='date" + data.nid + "'>";
			css += ".date" + data.nid + " { color:" + StringUtils.rgb2web(data.color.r, data.color.g, data.color.b) + "; font-family:Inconsolata; font-size:10; } ";
			ss.parseCSS(css);
			if (data.mes != null && data.dia != null) {
				itemhtml += data.dia + "/" + StringUtils.month2name(data.mes).substr(0, 3) + "/" + data.anotext;
			} else if (data.mes != null) {
				itemhtml += StringUtils.month2name(data.mes).substr(0, 3) + "/" + data.anotext;
			} else {
				itemhtml += data.anotext;
			}
			itemhtml += ":</span>";
			itemhtml += "<span class='text'> " + data.titulo + "</span>";
			text_txt = new TextField();
			text_txt.width = 170;
			text_txt.height = 20;
			text_txt.multiline = true;
			text_txt.wordWrap = true;
			text_txt.embedFonts = true;
			text_txt.selectable = false;
			text_txt.antiAliasType = "advanced";
			text_txt.styleSheet = ss;
			text_txt.htmlText = itemhtml;
			addChild(text_txt);
			swapChildren(hit_mc, text_txt);
			addListeners();
		}

		private function rollOver(e:MouseEvent):void {
			if (!active) {
				background_mc.gotoAndStop(2);
			}
		}

		private function rollOut(e:MouseEvent):void {
			if (!active) {
				background_mc.gotoAndStop(1);
			}
		}

		private function click(e:MouseEvent):void {
			dispatchEvent(new Event("click"));
		}

		private function addListeners():void {
			hit_mc.buttonMode = true;
			hit_mc.addEventListener(MouseEvent.ROLL_OVER, rollOver);
			hit_mc.addEventListener(MouseEvent.ROLL_OUT, rollOut);
			hit_mc.addEventListener(MouseEvent.CLICK, click);
		}

		private function removeListeners():void {
			hit_mc.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
			hit_mc.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
			hit_mc.removeEventListener(MouseEvent.CLICK, click);
		}

		public function setActive(a:Boolean):void {
			active = a;
			if (!active) {
				background_mc.gotoAndStop(1);
			} else {
				background_mc.gotoAndStop(2);
			}
		}

		public function kill():void {
			removeListeners();
		}
	}
}
