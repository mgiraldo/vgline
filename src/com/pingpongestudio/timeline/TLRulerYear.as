/**
 * VGLine 0.1: The Videogame Timeline <http://www.mauriciogiraldo.com/vgline/beta/>
 *
 * VGLine is (c) 2009-2010 Mauricio Giraldo Arteaga
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 *
 */
package com.pingpongestudio.timeline {
	import flash.text.TextField;
	import flash.display.MovieClip;

	/**
	 * @author Mauricio Giraldo Arteaga <http://www.mauriciogiraldo.com/> 
	 */
	public class TLRulerYear extends MovieClip {

		public var year_txt:TextField;
		public var bimesters:Array;
		public var id:int;

		public function TLRulerYear() {
			bimesters = [0,[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]];
		}
	}
}
