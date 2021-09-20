//Macro sarah plot profile
setOption("ExpandableArrays", true);
setTool("line");
if (nImages == 0){
	exit("Image not found");
}

if (isOpen("Log")) {
	selectWindow("Log");
	print("\\Clear");
}
if (isOpen("Results")) {
	waitForUser("Results table is open", "Save Results if necessary, click OK to continue");
	if (isOpen("Results")) {
		selectWindow("Results");
		run("Close");	
	}	
}


if (roiManager("count") != 0) {
	roiManager("show none");
	roiManager("deselect");
	roiManager("delete");
	roishow = 0 ;
				
}	

imgID = getImageID();
imgTitle = getTitle();
imgTitleWtExtenssion = substring(imgTitle, 0, lengthOf(imgTitle)-4);
setOption("DisablePopupMenu", true);
print("Draw line first! \n <Spacebar> to calculate distance between the 2 maxima \n <alt> to clean tables and start again \n <shift> button to visualise lines done \n close log or press escape to escape macro");
selectImage(imgID);
PrntIndex = 0;
Imgdir = getDirectory("image");
strSavedir = Imgdir+File.separator+"Table plot profile "+imgTitleWtExtenssion;
Savedir = File.makeDirectory(strSavedir);
print(strSavedir);
selectWindow(imgTitle);
roishow = 0 ;


while (isOpen("Log")) {
	//roishow = 0 ;
	imgID = getImageID();
	if (isKeyDown("alt")){
		selectWindow("Log");
		print("\\Clear");
		print("Draw line first! \n <Spacebar> to calculate distance between the 2 maxima \n <alt> to clean tables and start again \n <shift> button to visualise lines done \n close log or press escape to escape macro");
		PrntIndex = 0;
		if (isOpen("Results")) {
			selectWindow("Results");
			run("Clear Results");
		}	
		run("Select None");
		if (roiManager("count") != 0) {
			roiManager("deselect");
			roiManager("delete");
			roishow = 0;		
		}		
	}

	if (isKeyDown("shift")){  // button to look at the lines done 
		roishow = roishow + 1 ;
		if (roiManager("count") == 0) {
			print("No lines to show yet start messuring");	
		}		
		
		if (roishow == 1) {
			roiManager("show all with labels");
			wait(300);
		}
		if (roishow == 2) {
			roishow = 0;
			roiManager("show none");
			wait(300);
		}
		}
	
	
	if (isKeyDown("space")){ 
			if (is("line")) {
				imgID = getImageID();
				//setBatchMode(true); ///// start batch
				roiManager("Add");
				IntSel = getProfile();
				roiManager("select", roiManager("count")-1);
				run("Plot Profile");
				Plot.getValues(xpoints, ypoints);
				run("Close");
				Xdistaxis = xpoints;
				
				Array.getStatistics(IntSel, min, max, mean, stdDev);
				maxval = Array.findMaxima(IntSel,min); /// changed stdv to min
				if (lengthOf(maxval)>=2) {
					equivDist = newArray();
					equivInt = newArray();
					for (i = 0; i < lengthOf(maxval); i++) { // from here necessary if there's more than 2 maxima, so we can pick the 2 highest ones
						In = maxval[i];
						equivDist[i] = Xdistaxis[In];
						equivInt[i] = IntSel[In];	
					}	
					SortequivInt = Array.copy(equivInt);
					Array.sort(SortequivInt);
					Max1= SortequivInt[lengthOf(equivInt)-1]; // last index is the higher value -1 to match index 
					Max2= SortequivInt[lengthOf(equivInt)-2]; // second last index is the 2nd highest value -2 to match index 
					for (j = 0; j < lengthOf(equivInt); j++){
						if (equivInt[j]==Max1) {
							dist1 = equivDist[j];					
						}
						if (equivInt[j]==Max2) {
							dist2 = equivDist[j];				
						}
					}	
				
					selectImage(imgID);
					getPixelSize(unit, pixelWidth, pixelHeight);
					MaximaDist = maxOf(dist1, dist2) - minOf(dist1, dist2);
					print("MaximaDist is "+ MaximaDist+" "+unit);
					wait(80);
					setResult("Distance("+unit+")", PrntIndex, MaximaDist);
					wait(80);
					PrntIndex = PrntIndex +1;
					IJ.deleteRows(PrntIndex, PrntIndex); // hack to make the result table appear, I am deleting a row that doesn't exist
					
					tableName = "plot profile dist int_"+PrntIndex;
					Table.create(tableName);
					Table.setLocationAndSize(100, 100, 200, 200);
					Table.setColumn("Distance("+unit+")", Xdistaxis);
					wait(80);
					Table.setColumn("intensity", IntSel);
					wait(80);
					Table.save(strSavedir+File.separator+tableName+".csv");
					selectWindow(tableName);
					run("Close");
					run("Select None");
					if (isOpen("Plot Values")) {
						selectWindow("Plot Values");
						run("Close");						
					}
					
				}
				else {
					print("NaN !! Only one maxima found");
					wait(300);
					IJ.deleteRows(PrntIndex+1, PrntIndex+1);
					run("Select None");
					roiManager("select", roiManager("count")-1); // delete the NaN line with only one maxima
					roiManager("delete");
				}
			
			}
			else {
				print("No line detected: Draw a line selection and hit space again");
				wait(100);
				run("Select None");
			}
	
		//setBatchMode(false);
	}
	
}
if (getVersion>="1.37r")
setOption("DisablePopupMenu", false);