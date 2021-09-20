/* 
 *  MACRO: Spot detection, Spot count per cell 
 * 
 * Input: The image and RoiManager selection if needed (for spot per cell count)
 * Output: Table with counts spot detected and result table with spot intensity, area ect
 * 
 * Installation: Save file under Fiji-win64>>Fiji.app>>plugins
 * 
 */

///// Set initial variable and parameters- check there is an image open//////
if (nImages == 0) {
	showMessage("Macro error", "There is no images open");
	exit
}
else {
	fileName = getInfo("image.filename"); // to save in the name of the file where the image is 
	initialimagetitle= getTitle(); // get the name of the image active on imagej
	StackSlice = nSlices; // number is 1 if the image is not a stack
	RoiCount = roiManager("count");
}
run("Set Measurements...", "area mean integrated display redirect=None decimal=3");


ChoicesChannel = newArray(1,2,3,4);
ChoiceThreshold = newArray("Default","Otsu","Huang","Minimum","Intermodes","MaxEntropy","RenyiEntropy","Yen"); 


///// Dialogue box ///////////

Dialog.create("Set parameters");
Dialog.addChoice("Automatic Threshold ", ChoiceThreshold);
Dialog.addCheckbox("Manual Threshold instead", false);
Dialog.addMessage("----To help segmentation----");
Dialog.addCheckbox("Add Background substraction (On a duplicate image - original untouched)", false);
Dialog.addNumber("if yes, rolling ball radius:", 0 );
Dialog.addMessage("--------");
Dialog.addChoice("Fluorescent channel", ChoicesChannel);
Dialog.addMessage("Dot size range");
Dialog.addNumber("Min size:", 0);
Dialog.addNumber("Max size:", 100);
Dialog.show();

Thresholdop = Dialog.getChoice();
ManualTresh = Dialog.getCheckbox();
RollingBall = Dialog.getCheckbox();
RBradius = Dialog.getNumber();
FluorescentChannel = Dialog.getChoice();
MinSize = Dialog.getNumber();
MaxSize = Dialog.getNumber();


C1 = "C1-"+initialimagetitle;
C2 = "C2-"+initialimagetitle;
C3 = "C3-"+initialimagetitle;
C4 = "C4-"+initialimagetitle;
ChoicesChannelName = newArray(C1,C2,C3,C4);

ImageAnalysedName = ChoicesChannelName[FluorescentChannel-1];


//// Manage stack , composite image or not

selectWindow(initialimagetitle);
if (StackSlice != 1) {
	run("Split Channels"); 
	selectWindow(ImageAnalysedName);
	ImageAnalysedID = getImageID(); 
	}
	else { 
		selectWindow(initialimagetitle);
		ImageAnalysedID = getImageID(); 
	}

//// Manage Overlay

if (Overlay.size != 0){
	run("To ROI Manager"); 
	RoiCount = roiManager("count");
}
	else {
		if (RoiCount == 0) {
			waitForUser("Create ROIs","Create ROI(s) and Click OK to continue \n if no ROI added, the entire image becomes the ROI");
			RoiCount = roiManager("count");
			if (RoiCount ==0){
				run("Select All");
				roiManager("Add");
				RoiCount = RoiCount+1;
			}
		}
	}	

///// spot thresholding on duplicate image
run("Select None");
selectImage(ImageAnalysedID);
run("Duplicate...", "title=---Duplicate");
selectWindow("---Duplicate");
if (RollingBall==true){
	run("Subtract Background...", "rolling="+RBradius);
}
run("Enhance Contrast...", "saturated=0.5 normalize");
run("Gaussian Blur...", "sigma=1");
if (ManualTresh==true){
	selectWindow("---Duplicate");
	waitForUser("make binary image");
	run("Make Binary");
	run("Convert to Mask");
	run("Fill Holes");
}
else {
	//setAutoThreshold("Minimum dark no-reset");
	setAutoThreshold(Thresholdop+" dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Fill Holes");
}

//////  Set independant table 

titleNewTab2 = "[Spot count table]"; 
run("New... ", "name="+titleNewTab2+" type=Table"); 
print(titleNewTab2,"\\Headings:Cell-Number \t Spot-count");

/////


for (i=0; i<RoiCount; i++) { 
		RoiCountStart = roiManager("count");
		roiManager("select", i); 
		selectWindow("---Duplicate");
		run("Analyze Particles...", "size="+MinSize+"-"+MaxSize+" add");
		NewRoicount = roiManager("count");
//		if (NewRoicount != RoiCountStart) {
//			roiManager("Update");
//		}
		//roiManager("Update");
		print(NewRoicount);
		SpotCount = NewRoicount - RoiCountStart;
		print(SpotCount);
		print(titleNewTab2, i +"\t"+SpotCount);
		RoiFirstSpot = NewRoicount - SpotCount;
		j = 1;
			for (k=RoiFirstSpot; k<NewRoicount; k++) { 
				roiManager("Select", k);
				roiManager("Rename", "Spot"+j+"_Cell"+i);
				j = j+1;
			}		
}

// back to original image and measure intensities
roiManager("Show None");
selectImage(ImageAnalysedID);
roiManager("Show All without labels");
roiManager("Deselect");
roiManager("Measure");



run("Tile");
selectWindow("Results");
selectWindow("Spot count table");
selectWindow("ROI Manager");
roiManager("show all");

