
#@ File(style="directory") Source_Directory
LoadingPath = Source_Directory +File.separator;
listFileInFolder = getFileList(LoadingPath);
#@ String(label="Currrent extension", choices={"czi", "lsm"}, style="list") Imextension
FolderProcessedName = File.getName(LoadingPath);
PathRawImages = LoadingPath+"Tiff converted images"+File.separator;
File.makeDirectory(PathRawImages);

//start the batch
 
for (b=0; b<lengthOf(listFileInFolder); b++) {
	showProgress(b/lengthOf(listFileInFolder));
	filename = listFileInFolder[b];	
	if (endsWith(filename, "tif") || endsWith(filename, Imextension )) {
		openingPath = LoadingPath+filename;
		print(openingPath);
		run("Bio-Formats Importer", "open=["+LoadingPath+filename+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT ");
		saveAs("tiff", PathRawImages+filename);
		run("Close All");
	}
}
