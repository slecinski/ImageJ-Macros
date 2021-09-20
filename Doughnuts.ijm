//MACRO  Doughnuts : for each initial ROIselection, grow or reduce sequentialy the selection
// Doghnut macro V15
// output: in RoiManager list : The new selections generated
// Requirements: (1) one image
			// --(2) Stored overlay or Selections in RoiManager (the initial segmentation)
			// --(3) the width of growth en reduction wanted and the number of resizing iteration to perform 
			//    >>  Width(microns) : negative value to reduce the size and positive to increase it

run("Set Measurements...", "area mean min integrated display redirect=None decimal=3"); // remove if you want to custumised parameter the "Set Measurement", mean and integrated density should stay selected

if (nImages == 0) {
	showMessage("error", "There is no images open");
	exit
}
else {
	getImageID();
	initialimagetitle= getTitle();
	StackSlice = nSlices;	
}

initialroiCount = roiManager("count");
getImageID();
initialimagetitle= getTitle();
StackSlice = nSlices;

C0 = "C0-"+initialimagetitle;
C1 = "C1-"+initialimagetitle;
C2 = "C2-"+initialimagetitle;
C3 = "C3-"+initialimagetitle;
C4 = "C4-"+initialimagetitle;
ChoicesChannel = newArray(C1,C2,C3,C4);
n=1;

//--------- Dialogue Box ----------//
Dialog.create("Set Values");
Dialog.addNumber("Width (microns):", -0.5); 
Dialog.addNumber("iteration", 1);			  
Dialog.addChoice("Fluorescent Channel:", ChoicesChannel);
Dialog.addCheckbox("Background correction?", false);  
Dialog.addNumber("If yes, Background Mean value:", 0);
Dialog.show();
X = Dialog.getNumber(); // attribut variable choose in the dialog box to enlarge or extand selection , negative value to shrink
nbiteration = Dialog.getNumber(); // attribut the number of iteration chose in the dialog box, iteration to apply for each cells 
FluorescentChannel = Dialog.getChoice();
NoiseYes = Dialog.getCheckbox();
BackgroudMean = Dialog.getNumber();
//----------------------------------

/// Manage the Overlay 

if (Overlay.size != 0){
	run("To ROI Manager"); 
	initialroiCount = roiManager("count");
}
	else {
		if (initialroiCount == 0) {
		waitForUser("No selection","Create a ROI List and click OK to continue");
		initialroiCount = roiManager("count");
		}
	}		

/// Manage stack , composite image or not

selectWindow(initialimagetitle);
if (StackSlice != 1) {
	run("Split Channels"); 
	selectWindow(FluorescentChannel);
	ImageAnalysedID = getImageID(); 
	}
	else { 
		selectWindow(initialimagetitle);
		ImageAnalysedID = getImageID(); 
	}

/// Make doughnuts and Roi Manager nunerical sorting

if (nbiteration == 0) {
	for (i=0; i<initialroiCount; i++) {	
		roiManager("select", i); 
		if ( i < 10 ) {   // for all indexes before 10, this to have 2decimal in the name (numering name using the index, if i=0 it becomes 00 = two decimal, renamed j=00) === help to get the right numerical sorting at the end
			j="0"+i;
		}
			else { 
				j=i; // after 10 its already 2decimal numbers so no change, keep the index (13 will stay 13)
			}
		roiManager("rename", "cell-"+j+"_00");
	}
}

	else {

for (i=0; i<initialroiCount; i++) {	
	roiManager("select", i); 
	if ( i < 10 ) {   // for all indexes before 10, this to have 2decimal in the name
		j="0"+i;
	}
		else { 
			j=i; // after 10 its already 2decimal numbers so no change, keep the index (13 will stay 13)
		}
		roiManager("rename", "cell-"+j+"_00"); //rename initial selection in roi Manager
	   	run("Enlarge...", "enlarge="+X); //chose the enlarge/expand value
		roiManager("Add");
		NewRoiCount = roiManager("count");
	 	while (n<= nbiteration) { // < and not <= to get really the right number of iteration as an output
			roiManager("select", NewRoiCount-1); //select the last ROI entry in the ROI list as the index thing start by O ->> counting shift by 1
			run("Enlarge...", "enlarge="+X); //chose the enlarge/expand value, need to be the same as above
			roiManager("Add");
			if ( n < 10 ) {   // same for the iteration numering (1 will become 01 and 10 will stay 10 _ need that if I want to sort in order)
				m="0"+n;
			}
				else { 
					m=n; //  (13 will stay 13)
				}
			roiManager("rename", "cell-"+j+"_"+m); // rename in roimanager the iteration new selection 
			n= n+1 ; // n is already superior to nbiteration after first cell and all iteration so need to reset the n to go to next cells	
			NewRoiCount = NewRoiCount+1;						
					}
		roiManager("select", NewRoiCount-1); // don't know why there is an extra selection measurement at the end that I can't rename -but this two line remove it 
		roiManager("delete");		
		n=1;		// n reset here for the next run, next cell, next selection, n=1 instead of zero to reequilibrate and get really the right nb of iteration output	
}
	}
			 
roiManager("Deselect");
roiManager("Sort");	// sort at the end so that initial and schrink selection are together, one after an other		
selectImage(ImageAnalysedID); // select fluorescent channel choose in the dialogue box 
roiManager("Show All");
roiManager("measure");

// Get the names of the selection in roi manager, the roi.names and rewrite the labels of the measurment table

for (i=0; i<nResults; i++) {
	roiManager("select", i); 
	newLabel = getInfo("roi.name");
    setResult("Label", i, newLabel);  
    if (NoiseYes == true) {
    MeanCorrected = getResult("Mean", i)-BackgroudMean;
    intDentCorrected = getResult("IntDen", i)-(getResult("Area", i)*BackgroudMean);
    setResult("Mean_NoiseCorrection", i, MeanCorrected);
    setResult("IntDent_NoiseCorrection", i, intDentCorrected);
    }
    
  }
  
// Mean in the doughnugh area _ Substration mean value

nDoughnutResult = nResults-2; // to stop at the last value to substract at the n+1 to get donut
k=0;    // to select value at the right index in the array (n for "k" and n+1 for "l")
l = 1; // to select value at the right index in the array 
Doughnutcount= 1;
 for (i = 0; i <= nDoughnutResult ; i++) {
	if (Doughnutcount<=nbiteration) {
	IntDoughnutArea = getResult("IntDen", k)-getResult("IntDen", l); // the operation = substraction 
		if (NoiseYes == true) {
			IntDoughnutAreaCorr = getResult("IntDent_NoiseCorrection", k)-getResult("IntDent_NoiseCorrection", l); // the operation = substraction
	   		InitialLabelName = getResultString("Label", i); 
			Compositenumbername = substring(InitialLabelName, 0, 7);
			setResult("Doughnut", i, Compositenumbername+"_Donut_"+Doughnutcount); // create a collumn with labels
			setResult("IntDen-Doughnut", i, IntDoughnutArea);  // create a collumn with doughnut value
			setResult("IntDen-Corrected-Doughnut", i, IntDoughnutAreaCorr);  // create a collumn with doughnut value
			k= k+1; 
			l= l+1; 
			Doughnutcount = Doughnutcount+1;  		   		 
   		 }
   		 else {
   		 	InitialLabelName = getResultString("Label", i); 
			Compositenumbername = substring(InitialLabelName, 0, 7);
			setResult("Doughnut", i, Compositenumbername+"_Donut_"+Doughnutcount); // create a collumn with labels
			setResult("IntDen-Doughnut", i, IntDoughnutArea);  // create a collumn with doughnut value
			k= k+1; 
			l= l+1; 
			Doughnutcount = Doughnutcount+1;
   		 }

		}
		else {                              
			setResult("Doughnut", i, "------");
			setResult("IntDen-Doughnut", i, "------");
			if (NoiseYes == true) {
				setResult("IntDen-Corrected-Doughnut", i, "------");
			}
			Doughnutcount = 1 ;
			k= k+1;
			l= l+1;
		}
	}
