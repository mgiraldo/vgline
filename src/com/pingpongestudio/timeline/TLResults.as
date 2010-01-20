/**
 * VGLine 0.1: The Videogame Timeline <http://www.mauriciogiraldo.com/vgline/beta/>
 *
 * VGLine is (c) 2009-2010 Mauricio Giraldo Arteaga
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 *
 */
package com.pingpongestudio.timeline {
	import flash.events.MouseEvent;

	import com.webdevils.controls.SimpleScrollText;

	import flash.events.Event;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.display.MovieClip;

	/**
	 * @author Mauricio Giraldo Arteaga <http://www.mauriciogiraldo.com/> 
	 */
	public class TLResults extends MovieClip {

		public var close_mc:MovieClip;
		public var title_txt:TextField;
		public var results_txt:TextField;
		public var track_mc:MovieClip;
		public var drag_mc:MovieClip;
		public var dataClip:MovieClip;
		public var mask_mc:MovieClip;
		public var currentResult:TLDot;
		public var results:/*TLResultItem*/Array = [];

		public function TLResults() {
		}
		
		public function initWithResultsAndQuery(r:Array, str:String):void {
			// el clip con el texto
			dataClip = new MovieClip();
			dataClip.x = 2;
			dataClip.y = 40;
			dataClip.mask = mask_mc;
			
			var i:int;
			var l:int = r.length;
			
			var titlehtml:String = "<p class='title'>search results:</p>";
			var texthtml:String;
			
			if (l>1) {
				texthtml = "<p class='text'>" + l + " results found for '" + str + "'</p>";
			} else if (l==1) {
				texthtml = "<p class='text'>1 result found for '" + str + "'</p>";
			} else {
				texthtml = "<p class='text'>No results found for '" + str + "'. Try removing filters.</p>";
			}
			
			var ss:StyleSheet = new StyleSheet();
			var css:String = ".title { color:#999999; font-family:Inconsolata; font-size:10; } ";
			css += ".text { color:#333333; font-family:Inconsolata; font-size:10; leading:0; } ";
			ss.parseCSS(css);
			
			var item:TLResultItem;
			var dot:TLDot;
			for (i=0; i<l; ++i) {
				dot = TLDot(r[i]);
				item = new TLResultItem();
				item.init(dot);
				item.y = i * (item.height + 1);
				dataClip.addChild(item);
				setupListeners(item);
				results.push(item);
			}

			addChild(dataClip);
			
			title_txt.styleSheet = ss;
			title_txt.htmlText = titlehtml;
			results_txt.styleSheet = ss;
			results_txt.htmlText = texthtml;
			
			// Make a scroll bar from movieclips on the stage
			new SimpleScrollText(drag_mc, track_mc, null, null, null, dataClip, mask_mc);
			
			drag_mc.addEventListener(MouseEvent.ROLL_OVER, controlRollOver);
			drag_mc.addEventListener(MouseEvent.ROLL_OUT, controlRollOut);
			drag_mc.addEventListener(MouseEvent.MOUSE_DOWN, controlDown);
			
			if (results.length > 0) {
				updateResults(results[0]);
			}
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

		private function setupListeners(item:TLResultItem):void {
			item.addEventListener("click", resultClick);
		}
		
		private function resultClick(e:Event):void {
			var r:TLResultItem = TLResultItem(e.currentTarget);
			updateResults(r);
		}

		private function updateResults(r:TLResultItem):void {
			currentResult = r.dot;
			dispatchEvent(new Event("update"));
			var i:int;
			var l:int = results.length;
			var item:TLResultItem;
			for (i=0; i<l; ++i) {
				item = results[i];
				if (item != r) {
					item.setActive(false);
				} else {
					item.setActive(true);
				}
			}
		}
	}
}
