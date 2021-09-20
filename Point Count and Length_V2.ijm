// getCursorLoc() Demo modification sarah to make a dynamic counting tool

//  This macro demonstrates how to use the getCursorLoc() function.
//  To use it, run the macro, open an image and move the cursor over it. 
//  Try pressing the left mouse button and/or the shift, control or 
//  alt keys. Pressing the alt key may not work on windows.   ###### ---  used isKeyDown() function instead for alt (works on windows)
//  The macro stops running when the "Log" window is closed.  ##### --- kept that as it make the main "time dynamic functional loop" 
//  Information about tool macros is available at:
//  http://rsb.info.nih.gov/ij/developer/macro/macros.html#tools
// 
// With ImageJ 1.42i or later, this macro displays "inside"
// if the cursor is inside the current area selection.


setOption("ExpandableArrays", true);

function length (x1, y1, x2, y2) {
	sum_difference_squared = pow((x2 - x1),2) + pow((y2 - y1),2);
 	output = pow(sum_difference_squared, 0.5);  // here the root square to get the distance
 return output;
}

rightButton=4;
leftButton=16;
setTool("hand");
run("Select None");

x2=-1; y2=-1; z2=-1; flags2=-1;
CountsLeftClick = 0;
penalty = 0;
n= 0;

P1cor =newArray();
P2cor =newArray();
PcorIndex = 0;

Length_List = newArray();
Point1_List= newArray();
Point2_List = newArray();

if (nImages == 0){
	exit("Image not found");
}

getPixelSize(unit, pixelWidth, pixelHeight);
Table.create("Table Length");
Table.setLocationAndSize(100, 100, 200, 200);

if (Overlay.size != 0) {
	Overlay.remove;			
}

if (isOpen("Log")) {
	run("Close");	
}
if (isOpen("Results")) {
	waitForUser("Results table is open", "Save Results if necessary, click OK to continue");
	if (isOpen("Results")) {
		selectWindow("Results");
		run("Close");	
	}	
}

print("<Right click> Add point  &  <Left click> remove point \n <shift> print total counts \n <Alt> delete all and start over \n close log window to exit macro \n <spacebar> to calculate distance between the last two points \n");
imgID = getImageID();
selectImage(imgID);

if (getVersion>="1.37r")
setOption("DisablePopupMenu", true);
while (isOpen("Log")) {
	getCursorLoc(x, y, z, flags);
	if (isKeyDown("shift")){
		finalcount = CountsLeftClick - penalty;
		print("Total counts : " +finalcount);
		wait(250);
	}
	if (isKeyDown("alt")){
		selectWindow("Log");
		print("\\Clear");
		print("<Right click> Add point  &  <Left click> remove point \n <Spacebar> print total counts \n <Alt> delete all and start over \n close log window to exit macro \n <shift> to calculate distance between the last two points \n");
		CountsLeftClick = 0;
		penalty = 0;
		n= 0;
		if (isOpen("Results")) {
			selectWindow("Results");
			run("Clear Results");
		}	
		run("Select None");
		if (Overlay.size != 0) {
			Overlay.remove;			
		}

		if (isOpen("Table Length")) {
			selectWindow("Table Length");
			run("Close");
			Table.create("Table Length");
			Table.setLocationAndSize(100, 100, 200, 200);
			P1cor =newArray();
			P2cor =newArray();
			PcorIndex = 0;
			Length_List = newArray();
			Point1_List= newArray();
			Point2_List = newArray();
		}	
	}
	/// get distance between your 2 last points
	if (isKeyDown("space")){
		LastIndexRes = nResults-1; 
		x1 = getResult("X", LastIndexRes-1);
		y1 = getResult("Y", LastIndexRes-1);
		x2 = getResult("X", LastIndexRes);
		y2 = getResult("Y", LastIndexRes);
		z1 = getResult("Z/Slice", LastIndexRes-1);
		z2 = getResult("Z/Slice", LastIndexRes);
	    LengthP1P2 = length(x1, y1, x2, y2);
	    Scaled_LengthP1P2 = LengthP1P2;
	    toScaled(Scaled_LengthP1P2);
	    //print("LenghtP1_P2: "+ LenghtP1P2 +"px");
	    //wait(40);
	    print("Scaled LenghtP1_P2: "+ Scaled_LengthP1P2 +" "+unit);
	    wait(40);
	    ArrayLengthScaled = newArray(1);
	    ArrayLengthScaled[0] = Scaled_LengthP1P2;
	    Length_List = Array.concat(Length_List,ArrayLengthScaled);
		
	    P1cor[PcorIndex]= " "+x1+","+y1+","+z1+" ";
	    P2cor[PcorIndex] = " "+x2+","+y2+","+z2+" ";
	    
	    Table.setColumn("Length("+unit+")", Length_List);
	    wait(40);
	    Table.setColumn("point1(x,y,z)", P1cor);
	    wait(40);
	    Table.setColumn("point2(x,y,z)", P2cor);
	    wait(80);
	    PcorIndex =PcorIndex+1;
	   	makeLine(x1, y1, x2, y2, 4);
	    
	}

	
	if (x!=x2 || y!=y2 || z!=z2 || flags!=flags2) {     
		s = " ";
		if (flags&leftButton!=0){
			s = s + "<left click (+1)>";
			CountsLeftClick = CountsLeftClick + 1;
			getCursorLoc(x, y, z, flags);
			print(x+" "+y+" "+z+" "+ s);
			setResult("X", n, x);
			setResult("Y", n, y);
			setResult("Z/Slice", n, z+1);
			makePoint(x, y, "tiny green hybrd");
			Overlay.addSelection;
			wait(320);	// important otherwise click is interpreted twice, end up with duplicate coordonates, plus delay minimise double click errors
			n=n+1;
			IJ.deleteRows(n, n); // hack to make the result table appear, I am deleting a row that doesn't exist
			

		}
		if (flags&rightButton!=0){
			s = s + "<penalty(-1) removed>";
			run("Undo"); // for the selection
			penalty = penalty + 1 ;
			getCursorLoc(x, y, z, flags);
			print(s);
			IJ.deleteRows(n-1, n-1);
			n = n-1;
			Overlay.removeSelection(n);
			wait(100);
			run("Select None");
			wait(100);
		}
	 }
	 x2=x; y2=y; z2=z; flags2=flags;
     wait(10);	
}

run("Select None");
if (Overlay.size != 0) {
	Overlay.remove;			
}
if (getVersion>="1.37r")
setOption("DisablePopupMenu", false);
