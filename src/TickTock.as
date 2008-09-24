package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	import flash.events.MouseEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.TextEvent;

	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLStream;
	import flash.net.URLVariables;
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;

	
	public class TickTock extends Sprite
	{
		public static const HOST:String = "http://localhost:3000";
		public static const XML_EXT:String = ".xml";
		public static const PADDING:Number = 5;
		public static const POST:String = "POST";
		public static const TEXT:String = "text";
		public static const LABEL:String = "label";
		public static const SUBMIT:String = "submit";

		public static const OK:int = 200;
		public static const CREATED:int = 201;
		public static const NO_CONTENT:int = 204;
		public static const MOVED_PERMANENTLY:int = 301;
		public static const BAD_REQUEST:int = 400;
		public static const GONE:int = 410;

		private var task_name_txt:TextField;
		private var current_form:DisplayObjectContainer;

		private var next_y:Number = 0;
		private var form_x:Number = 5;


		/** TickTock:
		 *
		 */
		public function TickTock( ) {
			super( );
			createUI( );
		}


		/** createUI: 
		 *
		 */
		public function createUI( ):void {
			form( "tasks" );
				label( "Name" );
				input = { name:"name", text:C.task.name };

				input = { type:SUBMIT };
			end;

			form( "projects" );
				label( "Project #" );
				input = { name:"number" };
				label( "Name" );
				input = { name:"name" };

				input = { type:SUBMIT };
			end;

			form( "events" );
				label( "Duration" );
				input = { name:"duration" };
				label( "Notes" );
				input = { name:"notes" };

				label( "Task" );
				input = { name:"task_id" };
				label( "Project" );
				input = { name:"project_id" };
				label( "User" );
				input = { name:"user_id", text:"1" };

				input = { type:SUBMIT };
			end;
		}


		/** form: 
		 *
		 */
		public function form( path:String, method:String = POST ):void {
			trace( path );
			var path_parts:Array = path.split( '.' );
			var parent:DisplayObjectContainer = this;
			var child:DisplayObjectContainer;

			for each( var part:String in path_parts )
			{
				if( part == "" ) continue;
				trace( part );

				if( parent.getChildByName(part) == null )
				{
					child = new Sprite( );
					child.name = part;
					parent.addChild( child );
				}

				parent = child;
			}

			child.x = form_x;
			current_form = child;
		}


		/** input: 
		 *
		 */
		public function set input( opts:Object ):void {
			// replace with a factory
			if( opts.type == null ) opts.type = "text";
			var obj:DisplayObject;

			switch( opts.type )
			{
				case LABEL:
					opts.readonly = true;
				case TEXT:
					obj = createTextField( opts );
					break;

				case SUBMIT:
					obj = createSubmitButton( opts );
					break;
			}

			obj.y = next_y;
			next_y = obj.y + obj.height + PADDING;

			current_form.addChild( obj );
		}


		/** end: 
		 *
		 */
		public function get end( ):DisplayObjectContainer {
			next_y = 0;
			form_x = current_form.x + current_form.width + PADDING;
			return current_form = null;
		}


		/** label: 
		 *
		 */
		public function label( theLabelText:String ):void {
			input = { text:theLabelText, type:LABEL };
		}


		/** createTextField: 
		 *
		 */
		public function createTextField( opts:Object ):DisplayObject {
			var tf:TextField = new TextField( );
			
			if(opts.name != undefined ) tf.name = opts.name;
			if(opts.readonly == undefined)
			{
				tf.type = TextFieldType.INPUT;
				tf.background = true;
				tf.border = true;
			}

			tf.height = 16;
			tf.width = 200;

			if( opts.text != undefined ) tf.text = opts.text;

			return tf;
		}


		/** createSubmitButton: 
		 *
		 */
		public function createSubmitButton( opts:Object ):DisplayObject {
			var sp:Sprite = new Sprite( );
			var shape:Shape = new Shape( );
			var tf:TextField = new TextField( );

			shape.graphics.beginFill( 0xc3c3c3 );
			shape.graphics.lineStyle( 1, 0x000000 );
			shape.graphics.drawRect( 0, 0, 100, 22 );
			shape.graphics.endFill( );

			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "Submit";
			tf.x = (shape.width - tf.width) / 2;
			tf.y = (shape.height - tf.height) / 2 + 1;
			tf.selectable = false;

			sp.addChild( shape );
			sp.addChild( tf );
			sp.addEventListener( MouseEvent.CLICK, submitListener );
			sp.buttonMode = true;
			sp.name = SUBMIT;

			return sp;
		}


		/** submitListener: 
		 *
		 */
		private function submitListener( event:MouseEvent ):void {
			var focus:DisplayObject = event.target as DisplayObject;
			while( focus.name != SUBMIT ) focus = focus.parent;
			var form:DisplayObjectContainer = focus.parent;

			var request:URLRequest = new URLRequest( HOST + buildPath(form) + XML_EXT );
			request.data = buildVariables( form );
			request.method = URLRequestMethod.POST;
			var headers:Array = request.requestHeaders;
			headers.push( new URLRequestHeader("Content-type","text/xml") );

			var loader:URLStream = new URLStream( );
			loader.addEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
			loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, statusListener );
			loader.load( request );
		}


		/** ioErrorListener: 
		 *
		 */
		private function ioErrorListener( e:IOErrorEvent ):void {
			trace( "Error" );
		}


		/** statusListener: 
		 *
		 */
		private function statusListener( e:HTTPStatusEvent ):void {
			trace( "Status " + e.status );
		}


		/** buildPath: 
		 *
		 */
		private function buildPath( bottomChild:DisplayObjectContainer ):String {
			var path:String = "";
			var	current_parent:DisplayObjectContainer = bottomChild;

			while( current_parent != null )
			{
				if( current_parent == this ) break;
				path = "/" + current_parent.name + path;
				current_parent = current_parent.parent;
			}

			return path;
		}


		/** attr: 
		 *
		 */
		private function attr( theAttributes:Object ):String {
			if( theAttributes == null ) return "";

			var attr:String = "";

			for each( var key:String in theAttributes )
			{
				// TODO: Escape each individual attribute to main.
				attr += " " + key + "=\"" + theAttributes[key] + "\"";
			}

			return attr;
		}


		/** tag: 
		 *
		 */
		private function tag( theNodeName:String, theContents:String = null, theAttributes:Object = null ):String {
			if( theNodeName == "" ) throw ArgumentError( "The node name must be supplied." );
			var tag:String = "<" + theNodeName + attr( theAttributes );
			
			if( theContents === null )
			{
				return tag + "/>";
			}
			else if( theContents === "" )
			{
				return tag + ">";
			}
			else
			{
				return tag + ">" + theContents + endTag( theNodeName );
			}
		}


		/** end_tag: 
		 *
		 */
		private function endTag( theNodeName:String ):String {
			return "</" + theNodeName + ">";
		}


		/** buildVariables: 
		 *
		 */
		private function buildVariables( dob:DisplayObjectContainer ):Object {
			var len:int = dob.numChildren;
			var contents:String = ""

			for( var i:int = 0; i < len; i++ )
			{
				var tf:TextField = dob.getChildAt( i ) as TextField;
				if( !tf || tf.type != TextFieldType.INPUT ) continue;

				contents += tag( tf.name, tf.text );
			}

			var variables:String = tag( dob.name.slice(0, dob.name.length-1), contents );
			trace( variables );

			return variables;
		}
	}

}
