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
	public final class StringUtils {

		public static function word(newLength:uint = 1, userAlphabet:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"):String {
			var alphabet:Array = userAlphabet.split("");
			var alphabetLength:int = alphabet.length;
			var randomLetters:String = "";
			var i:int;
			for (i = 0;i<newLength; ++i) {
				randomLetters += alphabet[int(Math.floor(Math.random() * alphabetLength))];
			}
			return randomLetters;
		}		

		public static function paragraph(wordCount:int = 1):String {
			var p:String = "";
			var i:int;
			var l:int;
			for (i = 0;i<wordCount;++i) {
				l = Math.ceil(Math.random()*9);
				p += StringUtils.word(l);
				if (i+1<wordCount) {
					p += " ";
				}
			}
			return p;
		}
		
		/* *********************************************************************
		 * COLORES
		 */
		public static function rgb2hex(r:int,g:int,b:int):Number {
			return(r << 16 | g << 8 | b);
		}

		public static function hex2rgb(hex:Number):Object {
			var red:Number = hex >> 16;
			var greenBlue:Number = hex - (red << 16);
			var green:Number = greenBlue >> 8;
			var blue:Number = greenBlue - (green << 8);
			return({r:red, g:green, b:blue});
		}

		public static function rgb2web(r:int,g:int,b:int):String {
			var red:String = (r.toString(16).length < 2) ? "0" + r.toString(16) : r.toString(16);
			var green:String = (g.toString(16).length < 2) ? "0" + g.toString(16) : g.toString(16);
			var blue:String = (b.toString(16).length < 2) ? "0" + b.toString(16) : b.toString(16);
			return("#" + red + "" + green + "" + blue);
		}

		public static function hex2web(hex:Number):String {
			var red:Number = hex >> 16;
			var greenBlue:Number = hex - (red << 16);
			var green:Number = greenBlue >> 8;
			var blue:Number = greenBlue - (green << 8);
			return("#" + red.toString(16) + green.toString(16) + blue.toString(16));
		}
		
		public static function web2hex(web:String):Number {
			web = web.replace("#", "");
			var r:Number = parseInt(web.substr(0, 2), 16);
			var g:Number = parseInt(web.substr(2, 2), 16);
			var b:Number = parseInt(web.substr(4, 2), 16);
			return(r << 16 | g << 8 | b);
		}
		
		public static function web2rgb(web:String):Object {
			web = web.replace("#", "");
			var red:Number = parseInt(web.substr(0, 2), 16);
			var green:Number = parseInt(web.substr(2, 2), 16);
			var blue:Number = parseInt(web.substr(4, 2), 16);
			return({r:red, g:green, b:blue});
		}
		
		public static function month2name(m:int, lang:String = "en"):String {
			if (lang == "en") {
				switch (m) {
					case 1:
						return "january";
					case 2:
						return "february";
					case 3:
						return "march";
					case 4:
						return "april";
					case 5:
						return "may";
					case 6:
						return "june";
					case 7:
						return "july";
					case 8:
						return "august";
					case 9:
						return "september";
					case 10:
						return "october";
					case 11:
						return "november";
					case 12:
						return "december";
				}
			} else if (lang == "es") {
				switch (m) {
					case 1:
						return "enero";
					case 2:
						return "febrero";
					case 3:
						return "marzo";
					case 4:
						return "abril";
					case 5:
						return "mayo";
					case 6:
						return "junio";
					case 7:
						return "julio";
					case 8:
						return "agosto";
					case 9:
						return "septiembre";
					case 10:
						return "octubre";
					case 11:
						return "noviembre";
					case 12:
						return "diciembre";
				}
			}
			return "";
		}

	}
}
