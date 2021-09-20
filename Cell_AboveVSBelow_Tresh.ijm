/*
 *Macro highlight selections above and below a threshold 
 */

if (nImages == 0) {
	showMessage("error", "There is no images open");
	exit
}
else {
	fileName = getInfo("image.filename");
	initialimagetitle = getTitle();
	initialimageID= getImageID();
	StackSlice = nSlices;
	RoiCount = roiManager("count");
}


C1 = "C1-"+initialimagetitle; 
C2 = "C2-"+initialimagetitle;
C3 = "C3-"+initialimagetitle; 
Choice = newArray(C1,C2,C3);
ChoiceColor = newArray("green","red","magenta");

//----------Dialogue box------------//
Dialog.create(" Mean intensity threshold Value"); 
Dialog.addNumber("Threshold value", 195);
Dialog.addMessage("---");
Dialog.addChoice("Color above thershold", ChoiceColor, ChoiceColor[0]);
Dialog.addString("Label:", "above Thresh");
Dialog.addMessage("---");
Dialog.addChoice("Color below threshold", ChoiceColor,ChoiceColor[2]);
Dialog.addString("Label:", "below Thresh");

if (nSlices!=1) {
	Dialog.addChoice("Channel to analyse", Choice);
}
Dialog.show();
thresholdValue = Dialog.getNumber();
ColorAboveThreshold = Dialog.getChoice();
labelAbove = Dialog.getString();
ColorBelowThreshold = Dialog.getChoice();
labelBelow = Dialog.getString();

if (nSlices!=1) {
	ImageToProcess = Dialog.getChoice();
}
//------------------------------------

/// Manage the Overlay 

if (Overlay.size != 0){
	run("To ROI Manager"); 
	RoiCount = roiManager("count");
}
	else {
		if (RoiCount == 0) {
		waitForUser("No selection","Create a ROI List and click OK to continue");
		RoiCount = roiManager("count");
		}
	}		


/// Manage stack or single image

selectImage(initialimagetitle);

if (StackSlice != 1) {
	run("Split Channels"); 
	selectWindow(ImageToProcess);
	ImageAnalysedID = getImageID(); 
	}
	else { 
		selectImage(initialimagetitle);
		ImageAnalysedID = getImageID(); 
	}
selectImage(ImageAnalysedID);

if (RoiCount == 0) { //maybe not necessary, wait for user will be more usefull
	run("Select All");
	roiManager("Add");
	RoiCount = RoiCount+1;
}

x = -1; // for Number of red cells -1 for index 
ArrayRoiSelection = newArray(); 


//__Thresholding and labeling step
Ai = 1;
Bi = 1; 
for (i=0; i<RoiCount; i++) { 
		roiManager("select", i); 
		getStatistics(area, mean);
		if (mean > thresholdValue ){
			roiManager("rename", "#"+labelAbove+Ai+" ");
			Roi.setStrokeColor(ColorAboveThreshold);
			roiManager("update");
			x = x+1; // number of red positive cell
			ArrayRoiSelection = Array.concat(ArrayRoiSelection, x); //To select afterwards only the roi selection of interest , will help creating tables
			Ai = Ai+1;
		}
		else {
			Roi.setStrokeColor(ColorBelowThreshold);
			roiManager("rename", "#"+labelBelow+Bi+" ");
			roiManager("update");
			Bi = Bi+1;
			}
}

//__Generate result table with cell above the threshold value, here red cells

arrayAbove= lengthOf(ArrayRoiSelection);

roiManager("Sort");
selectImage(ImageAnalysedID);
roiManager("deselect");

if (arrayAbove == 0){
	print(" Selection's mean are all below the thresold");
}
else {
	roiManager("Select", ArrayRoiSelection);
	roiManager("measure"); // measure only the Roi stored in the array
	Table.rename("Results", labelAbove); 
}


//__Generate result table with all cells

roiManager("deselect");
selectImage(ImageAnalysedID);
roiManager("Measure");
Table.rename("Results", "Everything ");

//__Generate result table with cells below the threshold, here the green cells
if (x == -1 ){
	
}
else {
	roiManager("deselect");
	roiManager("Measure");
	Table.deleteRows(0, x);
	Table.rename("Results", labelBelow);
}

roiManager("show all with labels");