if (nImages == 0) {
	showMessage("Macro error", "Need Image(s)");
	exit
}

ImageOpen = getList("image.titles");
Dialog.create("input");
Dialog.addChoice("Grand-truth", ImageOpen);
Dialog.addChoice("Automatic Segmentation", ImageOpen);
Dialog.show();

truth = Dialog.getChoice();
Seg = Dialog.getChoice();

imageCalculator("Difference create", truth, Seg);
selectWindow("Result of "+truth);
rename("Diff_Mask");
changeValues(255, 255, 1);
run("Enhance Contrast", "saturated=0.35");
run("Select All");
run("Measure");
SumAllPixels=getResult("RawIntDen", nResults-1);
getRawStatistics(nPixels);
selectWindow("Results");
run("Close");

percent_loss = (SumAllPixels*100)/(nPixels);
percent_identical = 100-percent_loss;
print ("Images identical at :"+percent_identical+"%");
print ("lost "+percent_loss+"%");
run("Tile");
selectWindow("Log");


