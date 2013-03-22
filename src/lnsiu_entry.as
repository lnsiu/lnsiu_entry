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
		-perhaps move fractal generation to its own class?
		-add developer info
	
	Completed Tasks:
	
	Versions:
	Flash Builder 4.5 as3
	Photoshop CS5
	CrazyBump Beta test
	
	Tutorials used:
	http://gotoandlearn.com/play.php?id=165
	http://away3d.com/tutorials/Introduction_to_Materials
	http://www.youtube.com/watch?v=VSiI4FYYuoc
	//grouping -> http://www.flashmagazine.com/tutorials/detail/away3d_basics_4_-_manipulating_3d_objects/
	http://away3d.com/forum/viewthread/123/
	
	Test in different browser and plattforms:
	PC:Explorer
	MAC:Safari
	FLash Versions: 
	*/
	
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	[SWF(width="512", height="512", frameRate="60")]
	
	public class lnsiu_entry extends MovieClip
	{
		[Embed(source="img/blueCircle.png")]
		private var I1:Class;
		
		[Embed(source="img/partes-verdes-normal-map.jpg")]
		private var I2:Class;
		
		private var view:View3D;
		private var meshPlane:Mesh;
		private var hc:HoverController;
		
		private var viewHolderMc:MovieClip = new MovieClip();
		private var mainBmp:BitmapData;
		
		private var light1:DirectionalLight;
		private var light2:DirectionalLight;
		private var light3:DirectionalLight;
		
		private var bct:BitmapTexture;
		private var bctNormal:BitmapTexture;
		private var bctnew:BitmapTexture;// = new BitmapTexture(new BitmapData(512,512, true));
		private var textMat:TextureMaterial;
		private var oldtextMat:TextureMaterial;
		private var thelightPicker:StaticLightPicker;
		
		private var bmd:BitmapData = new BitmapData(512, 512, true);
		private var mycircleViewer:CircleViewer;
		
		public function lnsiu_entry()
		{
			setupScene();
			setupViewer();
		}
		
		private function setupViewer():void
		{
			//provide bitmap to circleviewer somehow
			mycircleViewer = new CircleViewer(bmd);
			addChild(mycircleViewer);
		}
		
		private function setupScene():void
		{
			view = new View3D();
			
			addChild(viewHolderMc)
			viewHolderMc.addChild(view);
			
			sceneSettings();
			initLights();	
			
			mainBmp = new I1().bitmapData;
			bct = new BitmapTexture(mainBmp);
			
			var tempbmp:BitmapData = new I2().bitmapData;
			bctNormal = new BitmapTexture(tempbmp);
			
			var planeGeom:PlaneGeometry = new PlaneGeometry(250,250);
			planeGeom.doubleSided = true;
			meshPlane = new Mesh(planeGeom, new TextureMaterial(bct));
			//meshPlane.x = 50;

			//meshPlane.material.bothSides = true;
			//meshPlane.material.lightPicker = new StaticLightPicker([light1]);
			thelightPicker = new StaticLightPicker([light1,light2,light3]);
			meshPlane.material.lightPicker = thelightPicker;

				
			view.scene.addChild(meshPlane);
			
			view.camera.z = -300;
			view.camera.y = 300;
			view.camera.lookAt(new Vector3D());
			
			hc = new HoverController(view.camera,null,150,10,100);
			
			addEventListener(Event.ENTER_FRAME,loop);
			//addEventListener(MouseEvent.CLICK, clickFunc);
			
		}
		
		private function initLights():void
		{
			light1 = new DirectionalLight();
			light1.direction = new Vector3D(0, 0, 0);
			light1.position = new Vector3D(-200,-200,100);
			light1.ambient = 0.6;
			light1.castsShadows = true;
			light1.color = 0xFF0000;
			light1.diffuse = 1;
			
			light2 = new DirectionalLight();
			light2.direction = new Vector3D(0, 0, 0);
			light2.position = new Vector3D(200,200,100);
			light2.ambient = 0.6;
			light2.castsShadows = true;
			light2.color = 0x00FF00;
			light2.diffuse = 0.1;
			
			light3 = new DirectionalLight();
			light3.direction = new Vector3D(0, 0, 0);
			light3.position = new Vector3D(200,-200,100);
			light3.ambient = 0.6;
			light3.castsShadows = true;
			light3.color = 0x0000FF;
			light3.diffuse = 0.1;
			
			view.scene.addChild(light1);
			view.scene.addChild(light2);
			view.scene.addChild(light3);
		}
		
		private function sceneSettings():void
		{
			//view.antiAlias = 4;
			view.backgroundColor = 0xffAAff;			
		}
		
		private function texRender():void
		{
			//get 3D view image
			//bmd = new BitmapData(512, 512, true);
			view.stage3DProxy.context3D.present();
			view.renderer.queueSnapshot(bmd);
			view.render();
			
			//draw on org image with 60% alpha
			var adjustAlpha:ColorTransform = new ColorTransform();
			adjustAlpha.alphaMultiplier = 0.6;
			bmd.colorTransform(new Rectangle(0,0,512,512),adjustAlpha);
			mainBmp.draw(bmd);
			
			//clean before replacing
			bct.dispose();
			bct = new BitmapTexture(mainBmp);
			
			textMat = new TextureMaterial(bct,true,false,true);

			//textMat.texture.getTextureForStage3D(t);
			//textMat.texture = bctnew;
			/*textMat.normalMap = new BitmapTexture(mainBmp);*/
			//textMat.ambient = 20;
			//textMat.specularMap = Texture2DBase(bct);
			//textMat.ambientTexture = Texture2DBase(bct);
			textMat.normalMap = Texture2DBase(bctNormal);
			
			meshPlane.material = textMat;
			meshPlane.material.lightPicker = thelightPicker;
			
			//add motion
			//meshPlane.rotationY +=0.2;
			
			//meshPlane.castsShadows = true;
			//meshPlane.material.bothSides = true;
			
		}
		
		protected function loop(event:Event):void
		{
			//update views bmp
			mycircleViewer.bmpD = bmd;
			//
			hc.panAngle = mouseX - 256;
			hc.tiltAngle = mouseY  - 256;
			
			view.render();
			texRender();
		}
	}
}