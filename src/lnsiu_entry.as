package
{
	/*
	
	Written by lnsiu 2013-04 for kirupa contest:
	http://www.kirupa.com/forum/forumdisplay.php?160-Animate-Blue-Circles
	
	lnsiu contest thread:
	http://www.kirupa.com/forum/showthread.php?377734-lnsiu-Contest-Thread
	
	Notes:
	-clean project before committing to github.
	
	Updates:
	
	Tasks:
	-test to dynamically update texture
	-add light and shadow
	-add bitmap blending function to a percentage value
	
	Versions:
	Flash Builder 4.5
	Photoshop
	
	Tutorials used:
	http://gotoandlearn.com/play.php?id=165
	
	*/
	
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.errors.AbstractMethodError;
	import away3d.materials.ColorMaterial;
	import away3d.materials.SkyBoxMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapCubeTexture;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	[SWF(width="256", height="256", frameRate="60")]
	
	public class lnsiu_entry extends MovieClip
	{
		[Embed(source="img/blueCircle.png")]
		private var I1:Class;
		
		private var view:View3D;
		private var cube:Mesh;
		private var hc:HoverController;
		
		private var viewHolderMc:MovieClip = new MovieClip();
		private var mainBmp:BitmapData;
		
		public function lnsiu_entry()
		{
			
			setupScene();
		}
		
		private function setupScene():void
		{
			view = new View3D();
			
			addChild(viewHolderMc)
			viewHolderMc.addChild(view);
			
			mainBmp = new I1().bitmapData;
			
			var bct:BitmapCubeTexture = new BitmapCubeTexture(mainBmp,mainBmp,mainBmp,mainBmp,mainBmp,mainBmp);
			
			cube = new Mesh(new CubeGeometry(), new SkyBoxMaterial(bct));
			view.scene.addChild(cube);
			
			view.camera.z = -500;
			view.camera.y = 300;
			view.camera.lookAt(new Vector3D());
			
			view.antiAlias = 12;
			view.backgroundColor = 0xff00ff;
			
			hc = new HoverController(view.camera,null,150,10,100);
			
			addEventListener(Event.ENTER_FRAME,loop);
			addEventListener(MouseEvent.CLICK, clickFunc);
			
		}
		
		protected function clickFunc(event:MouseEvent):void
		{
			var bmd:BitmapData = new BitmapData(256, 256, true);
			view.stage3DProxy.context3D.present();
			view.renderer.queueSnapshot(bmd);
			view.render();
			
			var adjustAlpha:ColorTransform = new ColorTransform();
			adjustAlpha.alphaMultiplier = 0.5;
			bmd.colorTransform(new Rectangle(0,0,256,256),adjustAlpha);
			mainBmp.draw(bmd);
			
			var bctnew:BitmapCubeTexture = new BitmapCubeTexture(mainBmp,mainBmp,mainBmp,mainBmp,mainBmp,mainBmp);
			cube.material = new SkyBoxMaterial(bctnew);
			
			/*var b:Bitmap = new Bitmap(bmd);
			addChild(b);*/
		}
		
		protected function loop(event:Event):void
		{
			hc.panAngle = mouseX - 320;
			hc.tiltAngle = mouseY  - 240;
			view.render();
		}
	}
}