package
{
	/*
	Tasks:
		-clipping on ground, remove
		-add shadow
		-center circles
	*/
	import away3d.Away3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FilteredShadowMapMethod;
	import away3d.materials.methods.ShadowMapMethodBase;
	import away3d.primitives.CylinderGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;
	import away3d.textures.Texture2DBase;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class CircleViewer extends MovieClip
	{
		//vars
		//private var view:View3D;
		private var group:ObjectContainer3D;
		private var meshBkg:Mesh;
		//private var hc:HoverController;
		
		private var myCircleViewer:View3D;
		private var bct:Object;
		
		private var chc:HoverController;
		
		//circle arrays
		private var circleArr:Array = new Array();
		private var meshArr:Array = new Array();
		
		//Circle grid
		private var nmbWidth:Number = 8;//2,4,8,16,32... etc
		private var nmbHeight:Number = 8;
		private var wspacing:Number = 1;
		private var hspacing:Number = 1*Math.SQRT2;//
		private var startvalw:Number = 250/4;
		private var startvalh:Number = 250/4;
		
		//lights
		private var light1:DirectionalLight;
		private var thelightPicker:StaticLightPicker;
		
		//bitmap vars
		private var btmsize:int = 512;
		public var bmpD:BitmapData = new BitmapData(btmsize,btmsize);
		private var bmpDquote:int = btmsize/nmbWidth;
		private var pixelArr:Array = new Array();
		
		[Embed(source="img/blueCircle.png")]
		private var I1:Class;
		
		
		public function CircleViewer(bmd:BitmapData)
		{
			setUpViewer();
		}
		
		private function setUpViewer():void
		{
			//create 3dview
			myCircleViewer = new View3D();
			
			addChild(myCircleViewer);
			
			//camera
			myCircleViewer.camera.z = -600;
			myCircleViewer.camera.y = 600;
			myCircleViewer.camera.lookAt(new Vector3D());
			myCircleViewer.camera.lens = new OrthographicLens(100);
			//myCircleViewer.camera.r
			
			//myCircleViewer.antiAlias = 4;
			
			//create plane
			var planeGeom:PlaneGeometry = new PlaneGeometry(250,250);
			
			// Create a group and add to scene
			group = new ObjectContainer3D();
			myCircleViewer.scene.addChild(group);
			
			initLights();
			thelightPicker = new StaticLightPicker([light1]);
			
			//planeGeom.doubleSided = true;
			var tempbmp:BitmapData = new I1().bitmapData;
			var bctNormal:BitmapTexture = new BitmapTexture(tempbmp);
			var mat:TextureMaterial = new TextureMaterial(bctNormal);//new ColorMaterial(0xFF0000);
			//var shaMeth:FilteredShadowMapMethod = new FilteredShadowMapMethod(light1); 
			
			mat.lightPicker = thelightPicker;
			mat.specular = 0.5;
			mat.shadowMethod = new FilteredShadowMapMethod(light1);
			
			
			meshBkg = new Mesh(planeGeom);
			meshBkg.material = mat;
			meshBkg.castsShadows = true;
			
			//meshBkg.material.l
			//meshBkg.material.shadowMethod = new HardShadowMapMethod(light1); 
			//meshBkg.material.lightPicker = thelightPicker;
			//
			group.addChild(meshBkg);
			
			//create circle plane
			setupCircles();
			
			//make plane react to bitmapdata
			chc = new HoverController(myCircleViewer.camera,null,150,10,100);
			
			addEventListener(Event.ENTER_FRAME,loop);
			
		}
		
		private function setupCircles():void
		{
			
			//circle
			var cradius:Number = 5;
			var cheight:Number = 5;
			var csegmentsH:Number = 2;
			var csegmentsW:Number = 16;
			var aboveH:Number = 5;
			
			for (var i:int = 0; i < nmbWidth; i++) 
			{
				circleArr[i] = new Array();
				meshArr[i] = new Array();
				
				for (var j:int = 0; j < nmbHeight; j++) 
				{
					//create circle
					var theCircle:CylinderGeometry = new CylinderGeometry(cradius,cradius,cheight,csegmentsW,csegmentsH);
					circleArr[i][j] = theCircle;
					
					//add to a mesh
					
					var cmesh:Mesh = new Mesh(theCircle, new ColorMaterial(Math.random()*0xFFFFFF));
					cmesh.castsShadows = true;
					cmesh.material.lightPicker = thelightPicker;
					
					//cmesh.material.bothSides = true;
					
					meshArr[i][j] = cmesh;
					
					//cmesh.lookAt(myCircleViewer.camera.position);
					
					//add circle to scene
					//group.addChild(cmesh);
					myCircleViewer.scene.addChild(cmesh);
					
					
					//move half 
					var hval:Number = (i%2)*((cradius*2 + wspacing)/2);
					
					//position circle
					cmesh.transform.position = new Vector3D(
						i*(cradius*2 + wspacing)-startvalw,
						aboveH,
						j*(cradius*2 + hspacing)-startvalh+hval
					);
					
				}				
			}			
		}
		
		private function initLights():void
		{
			light1 = new DirectionalLight();
			light1.direction = new Vector3D(0, 0, 0);
			light1.position = new Vector3D(200,200,100);
			light1.ambient = 0.5;
			light1.castsShadows = true;
			//light1.shadowMapper
			light1.color = 0xFFFFFF;
			light1.diffuse = 1;
			light1.specular = 1;
			
			//light1.shadowMapper.autoUpdateShadows = true;
			
			/*light1 = new PointLight();
			//light1.direction = new Vector3D(0, 0, 0);
			light1.position = new Vector3D(200,200,100);
			light1.castsShadows = true;
			light1.radius = 500;
			light1.fallOff = 750;
			light1.y = 500;*/
			
			//var shadowMethod:FilteredShadowMapMethod = new FilteredShadowMapMethod(light1);
			//material.shadowMethod = shadowMethod 
						
			myCircleViewer.scene.addChild(light1);
		}
		
		protected function loop(event:Event):void
		{
			chc.panAngle = mouseX - 256;
			chc.tiltAngle = mouseY  - 256;
			
			//get pixelvals
			setPixelArr(bmpD);
			
			//set props
			setCircleProp();
			
			myCircleViewer.render();
		}
		
		private function setPixelArr(bmp:BitmapData):void
		{
			var bmpW:int = bmp.width;
			var bmpH:int = bmp.height;
			
			var i:int = 0;
			var j:int = 0;
				
			for (i=0; i < circleArr.length; i++) 
			{
				pixelArr[i] = new Array();
				
				for (j=0; j < circleArr[i].length; j++) 
				{
					//bmpDquote
					//pixelval
					var pixelValue:uint = bmpD.getPixel(i*bmpDquote, j*bmpDquote);
					pixelArr[i][j] = [(( pixelValue >> 16 ) & 0xFF),( (pixelValue >> 8) & 0xFF ),( pixelValue & 0xFF )];
				}
			}
		}
		
		private function setCircleProp():void
		{
			var i:int = 0;
			var j:int = 0;
			var len:int = circleArr.length
			
			for (i=0; i < len; i++) 
			{				
				for (j=0; j < len; j++) 
				{
					var theMesh:Mesh = meshArr[i][j];
					//var meshPos = theMesh.transform.position;
					
					//set radius
					var radi:int = (pixelArr[i][j][0]*5/254 + pixelArr[i][j][1]*5/254 + pixelArr[i][j][2]*5/254)/3;
					circleArr[i][j].topRadius = circleArr[i][j].bottomRadius = radi;
					
					//set blue color
					//theMesh.material = new ColorMaterial((pixelArr[i][j][0]<<16)|(pixelArr[i][j][1] << 8)|pixelArr[i][j][2]);
					theMesh.material = new ColorMaterial((Math.floor((pixelArr[i][j][0]+pixelArr[i][j][1])/2)<<16)|(Math.floor((pixelArr[i][j][0]+pixelArr[i][j][1])/2)<< 8)|pixelArr[i][j][2]);
					//set y pos
					theMesh.transform.position.z = pixelArr[i][j][1];
					
					//set rotation to face camera
					var camPos:Vector3D = myCircleViewer.camera.position.clone();
					var objPos:Vector3D = theMesh.transform.position;
					//camPos.negate();
					camPos.x = theMesh.transform.position.x;
					camPos.y = theMesh.transform.position.y;
					camPos.z = theMesh.transform.position.z;
					
					//theMesh.lookAt(camPos, new Vector3D(0,1,0));//myCircleViewer.camera.position
					
					//theMesh.transform.appendRotation(90,theMesh.position);
					//theMesh.transform.position = objPos;
					//theMesh.transform.appendRotation(90,theMesh.position);
					//.rotationX = 90;
					//theMesh.transform.appendRotation(myCircleViewer.camera.rotationX, new Vector3D(0,1,0));
					//theMesh.transform.pointAt(myCircleViewer.camera.position);
					theMesh.rotationX = myCircleViewer.camera.rotationX;
					theMesh.rotationY = myCircleViewer.camera.rotationY;
					theMesh.rotationZ = myCircleViewer.camera.rotationZ;
					theMesh.rotationX += 90;
					theMesh.transform.position = camPos;
					
				}
			}
		}
	}
}