/**
 * VGLine 0.1: The Videogame Timeline <http://www.mauriciogiraldo.com/vgline/beta/>
 *
 * VGLine is (c) 2009-2010 Mauricio Giraldo Arteaga
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 *
 */
package {
	import flash.events.TextEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.StyleSheet;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;

	import com.webdevils.controls.SimpleScrollText;
	import com.webdevils.display.ImageLoader;

	/**
	 * @author Mauricio Giraldo Arteaga <http://www.mauriciogiraldo.com/> 
	 */
	public class TLDetail extends MovieClip {

		public var close_mc:MovieClip;
		public var date_txt:TextField;
		public var title_txt:TextField;
		public var content_txt:TextField;
		public var arrow_r_mc:MovieClip;
		public var arrow_l_mc:MovieClip;
		public var track_mc:MovieClip;
		public var drag_mc:MovieClip;
		public var photo_mc:MovieClip;
		public var dataClip:MovieClip;
		public var mask_mc:MovieClip;
		public var fondo_mc:MovieClip;
		public var taglink:String;

		public function TLDetail() {
		}

		public function initWithData(data:Object):void {
			// el clip con el texto
			dataClip = new MovieClip();
			dataClip.x = 8;
			dataClip.y = 21;
			dataClip.mask = mask_mc;
			
			// color de fondo
			var ct:ColorTransform = new ColorTransform(data.color.r / 255, data.color.g / 255, data.color.b / 255);
			fondo_mc.transform.colorTransform = ct;
			// la foto
			if (data.photo != null) {
				photo_mc.visible = true;
				var load:ImageLoader = new ImageLoader(data.photo, 200, 200, 0, 0x000000, Inconsolata, 14);
				photo_mc.addChild(load);
			} else {
				photo_mc.visible = false;
			}
			
			var titlehtml:String = "<p class='title'>" + data.titulo + "</p>";
			var texthtml:String = "<p class='text'>" + data.texto + "</p>";
			
			if (data.tags.length > 0) {
				texthtml += "<p class='text'>Tags: ";
				for each (var tag in data.tags) {
					texthtml += "<a class='link' href='event:" + tag + "'>" + tag + "</a> ";
				}
				texthtml += "<br>&nbsp;</p>";
			}
			if (data.links != null) {
				var i:int;
				texthtml += "<ul>";
				for (i = 0;i < data.links.length;++i) {
					texthtml += "<li class='link'><a href='" + data.links[i].url + "' target='_blank'>" + data.links[i].name + "</a></li>";
				}
				texthtml += "</ul><p>&nbsp;</p>";
			}
			
			var ss:StyleSheet = new StyleSheet();
			var css:String = ".title { color:#333333; font-family:Inconsolata; font-size:16; leading:2; } ";
			css += ".date { color:" + StringUtils.rgb2web(data.color.r, data.color.g, data.color.b) + "; font-family:Inconsolata; font-size:14; leading:4; } ";
			css += ".text { color:#333333; font-family:Inconsolata; font-size:11; leading:4; } ";
			css += ".link { color:#000000; font-family:Inconsolata; font-size:11; leading:4; text-decoration:underline; } ";
			css += "a:hover { text-decoration:none; } ";
			ss.parseCSS(css);
			
			var fechahtml:String = "<span class='date'>";
			if (data.mes != null && data.dia != null) {
				fechahtml += data.dia + " " + StringUtils.month2name(data.mes) + " " + data.anotext;
			} else if (data.mes != null) {
				fechahtml += StringUtils.month2name(data.mes) + " " + data.anotext;
			} else {
				fechahtml += data.anotext;
			}
			
			fechahtml += "</span>";
			
			date_txt = new TextField();
			date_txt.width = 275;
			date_txt.embedFonts = true;
			date_txt.antiAliasType = "advanced";
			date_txt.styleSheet = ss;
			date_txt.htmlText =  fechahtml;
			date_txt.x = 8;
			date_txt.y = 3;

			addChild(date_txt);

			title_txt = new TextField();
			title_txt.width = 320;
			title_txt.multiline = true;
			title_txt.wordWrap = true;
			title_txt.embedFonts = true;
			title_txt.autoSize = TextFieldAutoSize.LEFT;
			title_txt.styleSheet = ss;
			title_txt.htmlText = titlehtml;
			
			dataClip.addChild(title_txt);

			content_txt = new TextField();
			content_txt.width = 320;
			content_txt.multiline = true;
			content_txt.wordWrap = true;
			content_txt.embedFonts = true;
			content_txt.antiAliasType = "advanced";
			content_txt.autoSize = TextFieldAutoSize.LEFT;
			content_txt.styleSheet = ss;
			content_txt.htmlText = texthtml;
			content_txt.y = title_txt.height + 5;

			dataClip.addChild(content_txt);
			
			addChild(dataClip);
			
			// Make a scroll bar from movieclips on the stage
			new SimpleScrollText(drag_mc, track_mc, null, null, null, dataClip, mask_mc);
			
			content_txt.addEventListener(TextEvent.LINK, taglinkHandler);
			arrow_l_mc.buttonMode = true;
			arrow_r_mc.buttonMode = true;
			arrow_l_mc.addEventListener(MouseEvent.CLICK, eventPrev);
			arrow_r_mc.addEventListener(MouseEvent.CLICK, eventNext);
			arrow_l_mc.addEventListener(MouseEvent.ROLL_OVER, controlRollOver);
			arrow_l_mc.addEventListener(MouseEvent.ROLL_OUT, controlRollOut);
			arrow_r_mc.addEventListener(MouseEvent.ROLL_OVER, controlRollOver);
			arrow_r_mc.addEventListener(MouseEvent.ROLL_OUT, controlRollOut);
			drag_mc.addEventListener(MouseEvent.ROLL_OVER, controlRollOver);
			drag_mc.addEventListener(MouseEvent.ROLL_OUT, controlRollOut);
			drag_mc.addEventListener(MouseEvent.MOUSE_DOWN, controlDown);
		}
		
		private function taglinkHandler(e:TextEvent):void {
			taglink = e.text;
			dispatchEvent(new Event("link"));
		}

		private function controlRollOver(e:MouseEvent):void {
			var a:MovieClip = MovieClip(e.target);
			a.gotoAndStop(2);
		}

		private function controlRollOut(e:MouseEvent):void {
			var a:MovieClip = MovieClip(e.target);
			a.gotoAndStop(1);
		}

		private function controlDown(e:MouseEvent):void {
			var a:MovieClip = MovieClip(e.target);
			a.gotoAndStop(3);
		}

		private function eventPrev(e:MouseEvent):void {
			dispatchEvent(new Event("prevClick"));
		}

		private function eventNext(e:MouseEvent):void {
			dispatchEvent(new Event("nextClick"));
		}
	}
}
