#@ File(style="directory") Source_Directory
#@ String(label="Merge name", description="output file name") outname 

LoadingPath = Source_Directory +File.separator;
listFileInFolder = getFileList(LoadingPath);
FolderProcessedName = File.getName(LoadingPath);
PathMergedImg = LoadingPath   //+"FileName"+File.separator;   //>> to create a new folder un comment and choose your file name
File.makeDirectory(PathMergedImg);
setOption("ExpandableArrays", true);


//start the batch
n=0
finalStrCom = "open ";
listczifile = newArray;
for (b=0; b<lengthOf(listFileInFolder); b++) {
	filename = listFileInFolder[b];
	print(filename);
	if (endsWith(filename, "tif")) {
		openingPath = LoadingPath+filename;
		print(openingPath);
		open(LoadingPath+filename);
		//run("Bio-Formats Importer", "open=["+LoadingPath+filename+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT ");
		Newfilename = replace(filename, " ", "");
		Newfilename = replace(Newfilename, "Image", "");
		Newfilename = replace(Newfilename, ".czi", ""); 
		rename(Newfilename);
		if (lengthOf(Newfilename)==1){
			Newfilename = "00"+Newfilename;
			rename(Newfilename);
		}
		if (lengthOf(Newfilename)==2){
			Newfilename = "0"+Newfilename;
			rename(Newfilename);
		}
		listczifile[n]= Newfilename;
	}
		n =n+1;
}

sortedListczifiles = Array.sort(listczifile);
Array.print(listczifile);
for (i = 0; i < lengthOf(sortedListczifiles); i++) {
	buildcom = "image"+(i+1)+"="+sortedListczifiles[i]+" ";
	finalStrCom = finalStrCom+buildcom;	
}

run("Concatenate...","title="+outname+" "+ finalStrCom);
//run("Make Composite");


saveAs("tiff", PathMergedImg+outname);