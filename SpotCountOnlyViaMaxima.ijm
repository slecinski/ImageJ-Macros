run("Set Measurements...", "area mean standard integrated display redirect=None decimal=3");

if (nImages == 0) {
	showMessage("error", "There is no images open");
	exit
}
else {
	RoiCount = roiManager("count");
	getImageID();
	fileName = getTitle();
}

// check overlay or roi already there
InitOverlay = false ; 
if (Overlay.size != 0){
	run("To ROI Manager"); 
	RoiCount = roiManager("count");
	roiManager("deselect");
	run("Select None");
	run("Duplicate...", "title=ImInit-Overlay");
	InitOverlay = true ; 
	selectWindow("ImInit-Overlay");
	run("*From ROI Manager");
	roiManager("deselect");
	roiManager("delete");
}
else {

	if (RoiCount != 0){ 
		roiManager("deselect");
		run("Select None");
		run("Duplicate...", "title=ImInit-Overlay");
		selectWindow("ImInit-Overlay");
		run("From ROI Manager");
		InitOverlay = true ; 
		roiManager("deselect");
		roiManager("delete");
	}
	
}



selectWindow(fileName);
run("Duplicate...", "title=Mask-Seg");
selectWindow("Mask-Seg");
setAutoThreshold("Minimum dark no-reset");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Dilate");
run("Analyze Particles...", "size=0.00-100.00 add"); //just detect everything
selectWindow(fileName);
roiManager("deselect");
roiManager("show all");
Rcounts = roiManager("count");
roiManager("measure"); //M capital measure all
run("Summarize");
SumMeanIndex = Rcounts +1 ;
SumMeanIndex = Rcounts +2 ;
meanSpots = getResult("Mean", SumMeanIndex);
stdSpots = getResult("StdDev",SumMeanIndex);
nbnoise = meanSpots-stdSpots; 
print(nbnoise);
run("Clear Results");
selectWindow("Mask-Seg");
close();
roiManager("deselect");
roiManager("delete");

selectWindow(fileName);

//// Manage Overlay
if (InitOverlay == true){
	selectWindow("ImInit-Overlay");
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




for (i=0; i<RoiCount; i++) { 
		selectWindow(fileName);
		roiManager("select", i);
		run("Find Maxima...", "noise="+nbnoise+" output=Count");
		run("Find Maxima...", "prominence="+nbnoise+" output=[Point Selection]");
		roiManager("Update");	
}


run("Tile");