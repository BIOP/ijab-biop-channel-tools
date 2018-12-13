// Install the BIOP Library
call("BIOP_LibInstaller.installLibrary", "BIOP"+File.separator+"BIOPLib.ijm");

// Name ActionBar
bar_name = "BIOP Channel Tools";

bar_file = replace(bar_name, " ", "_")+".ijm";
bar_jar  = replace(bar_name, " ", "_")+".jar";


runFrom = "jar:file:BIOP/"+bar_jar+"!/"+bar_file;
//////////////////////////////////////////////////////////////////////////////////////////////
// The line below is for debugging. Place this VSI file in the ActionBar folder within Plugins
//////////////////////////////////////////////////////////////////////////////////////////////
//runFrom = "/plugins/ActionBar/Debug/"+bar_file;

if(isOpen(bar_name)) {
	run("Close AB", bar_name);
}

run("Action Bar",runFrom);
exit();


//Start of ActionBar

<codeLibrary>
function toolName() {
	return "Channel Tools";
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// specific library


function channelsLUTSelection(){
	run("Make Composite", "display=Color");
	getDimensions(width, height, channels, slices, frames);
	
	defaultsArray = newArray("Red","Green","Blue","Grays","Cyan","Magenta","Yellow","Fire");
	names    = newArray(0);
	types    = newArray(0);
	defaults = newArray(0);

	

	for (i=0;i<channels;i++){
		names = Array.concat(names, "color channel "+(i+1)+" using LUT");
		types = Array.concat(types,"lut");
		defaults = Array.concat(defaults, defaultsArray[i]);
	}

	promptParameters(names, types, defaults);
	
}

function channelsLUTApply(){
	run("Make Composite", "display=Color");
	Stack.setDisplayMode("color");
	getDimensions(width, height, channels, slices, frames);
		
	colorFirstChannel =  getData("color channel 1 using LUT");
	
	if (colorFirstChannel ==""){
		noLutRecorded = true;
	}else{
		noLutRecorded = false;
	}
	
	if( noLutRecorded ){			//if no LUT slected  
			showMessage("Please select LUT for channels");	
	}else{					//get from the record
		for (i=0;i<channels;i++){
			chNbr=(i+1);
			recColorTemp = getData("color channel "+chNbr+" using LUT");
			if(nSlices>1) {
				Stack.setChannel(chNbr);
			}
			run(recColorTemp);
		}
	}
}


function brightnessAndContrastSetting(){
	getDimensions(width, height, channels, slices, frames);
	for (i=0;i<channels;i++){
		chNbr=(i+1);
		if(nSlices>1) {
			Stack.setChannel(chNbr);
		}
		run("Brightness/Contrast...");
		waitForUser(" Set B&C for channel "+chNbr+"\n Please set Min and Max \n and press Ok");
		getMinAndMax(min, max);
		setData("min ch"+chNbr,min);
		setData("max ch"+chNbr,max);
	}
}

function brightnessAndContrastSettingApply(){
	getDimensions(width, height, channels, slices, frames);
	for (i=0;i<channels;i++){
		chNbr=(i+1);
		if(nSlices>1) {
			Stack.setChannel(chNbr);
		}
		min = getData("min ch"+chNbr);
		max = getData("max ch"+chNbr);
		setMinAndMax(min, max);
	}
}

//montage options
function montageOptions(){

	// Get dimensions
	getDimensions(x,y,c,z,t);

	// Check if ROIS
	nRois = roiManager("Count");
	
	useScale = getBoolD("Use Scalebar", true);
	// Scale bar position
	scalePos = getDataD("ScaleBar Position", "Lower Right");
	// scale bar size
	scaleLength = getDataD("ScaleBar Length", 100);
	// scalebar height
	scaleHeight = getDataD("ScaleBar height", 5);
	
	// Which Position gets the scalebar
	atImage = getDataD("Scalebar At", "");
	
	// nrows ncols
	mRows = getDataD("Montage Rows", "As Row");
	mCols = getDataD("Montage Cols", 1);
	// position of composite
	cPos = getDataD("Channel Merge Position", "First");
	isIgnore = getBoolD("Ignore LUTs except for Merged", false);
	advMon = getDataD("Advanced Montage", "");
	
	// border size
	bSize = getDataD("Montage Border", 0);

	zSlices = getDataD("Z Slices", "");

	// Image Legend
	fontSize = getDataD("Font Size", 14);
	chanNames = getDataD("Channel Names", "");
	position = getDataD("Legend Position", "bottom left");
	slice = getDataD("Legend Montage Position", 1);
	
	// ROIs
	isShowRois = getBoolD("Display ROIs", false);
	roiOrder   = getDataD("ROI Order","");
	roiColors  = getDataD("ROI Colors","");
	
	// border color
	rowChoice= newArray("As Row", "1","2", "3", "4", "5", "6");
	colChoice= newArray("As Column","1", "2", "3", "4", "5", "6");
	scalePoses=newArray("Lower Right", "Lower Left", "Upper Right", "Upper Left");
	imgPos=newArray("First", "Last");
	positions = newArray("top left", "top right", "bottom left", "bottom right");

	
	
	Dialog.create("Montage Options");
	Dialog.addCheckbox("Use Scalebar", useScale);
	Dialog.addChoice("Scalebar Position", scalePoses, scalePos);
	Dialog.addNumber("Scalebar Length", scaleLength, 0, 5, "um");
	Dialog.addNumber("Scalebar Height", scaleHeight, 0, 5, "px");
	Dialog.addString("Scalebar At Image", atImage);
	Dialog.addChoice("Montage Rows", rowChoice, mRows);
	Dialog.addChoice("Montage Columns", colChoice, mCols);
	Dialog.addChoice("Merged Image Position", imgPos, cPos);
	Dialog.addCheckbox("Ignore LUTs except for Merged", isIgnore);
	Dialog.addString("Advanced Montage", advMon);
	
	Dialog.addNumber("Montage Border", bSize,0,5,"px");

	if (z > 1) {
		Dialog.addMessage("Image is Z Stack (nZ = "+z+")\nLeave blank to do all slices");
		Dialog.addString("Choose slice range for MIP", zSlices);
	}
	Dialog.addMessage("Montage Lengend");
	Dialog.addString("Names for the Channels", chanNames);
	Dialog.addNumber("Font Size", fontSize);
	Dialog.addChoice("Legend Position", positions, position);
	Dialog.addNumber("Legend At Image", slice);

	//ROIS
	if(nRois > 0) {
		Dialog.addMessage("There are "+nRois+" ROIs");
		Dialog.addCheckbox("Show ROIs on Montage?", isShowRois);
		Dialog.addString("ROI Order", roiOrder);
		Dialog.addString("ROI Colors", roiColors);
		
	}
	
	Dialog.show();
	
	// Scale bar position
	useScale = Dialog.getCheckbox();
	scalePos = Dialog.getChoice();
	scaleLen = Dialog.getNumber();
	scaleHei = Dialog.getNumber();
	atImage  = Dialog.getString();
	mRows    = Dialog.getChoice();
	mCols    = Dialog.getChoice();
	cPos     = Dialog.getChoice();
	isIgnore = Dialog.getCheckbox();
	advMon   = Dialog.getString();
	bSize    = Dialog.getNumber();
	
	if (z > 1) {
		zSlices = Dialog.getString();
	} else {
		zSlices = "None";
	}

	chanNames= Dialog.getString();
	fontSize = Dialog.getNumber();
	position = Dialog.getChoice();
	slice    = Dialog.getNumber();

		//ROIS
	if(nRois > 0) {		
		isShowRois = Dialog.getCheckbox();
		roiOrder   = Dialog.getString();
		roiColors   = Dialog.getString();	
	}



	
	setBool("Use Scalebar", useScale);
	
	setData("ScaleBar Position", scalePos);
	setData("ScaleBar Length", scaleLen);
	setData("ScaleBar Height", scaleHei);
	setData("Scalebar At", atImage);
	setData("Montage Rows", mRows);
	setData("Montage Cols", mCols);
	setData("Channel Merge Position", cPos);
	setBool("Ignore LUTs except for Merged", isIgnore);
	setData("Advanced Montage", advMon);
	setData("Montage Border", bSize);
	setData("Z Slices", zSlices);
	setData("Font Size", fontSize);
	setData("Channel Names", chanNames);
	setData("Legend Position", position);
	setData("Legend Montage Position", slice);

	setBool("Display ROIs",isShowRois);
	setData("ROI Order",roiOrder);
	setData("ROI Colors",roiColors);
	
}

function montageApply(){
	// Use scalebar
	useScale = getBoolD("Use Scalebar", true);
	// Scale bar position
	scalePos = getData("ScaleBar Position");
	// scale bar size
	scaleLength = getData("ScaleBar Length");
	// scalebar height
	scaleHeight = getData("ScaleBar Height");
	// nrows ncols
	mRows = getData("Montage Rows");
	mCols = getData("Montage Cols");
	// position of composite
	cPos = getData("Channel Merge Position");
	// border size
	bSize = getData("Montage Border");

	//Ignore LUT colors and keep gray
	isIgnore = getBoolD("Ignore LUTs except for Merged", false);
	
	// border color
	bColor = getData("Montage Border Color");

	advMon = getData("Advanced Montage");

	atImage = getData("Scalebar At");

	zSlices = getData("Z Slices");

	if(scalePos == "") {
		showMessage("Montage Settings not set.");
		exit();
	}


	
	ori = getTitle();

	// Get LUTS
	Stack.getDimensions(dx,dy,dc,dz,dt);
	r = newArray(dc);
	g = newArray(dc);
	b = newArray(dc);
	
	for(ch=0; ch<dc;ch++) {
		Stack.setPosition(ch+1,1,1);
		getLut(reds, greens, blues);
		r[ch] = reds[255];
		g[ch] = greens[255];
		b[ch] = blues[255];
	}
	
	if(zSlices != "None" && zSlices != "") {
		
		zds = split(zSlices,"-");
		if ( lengthOf(zds) == 2) {
			zStart = parseInt(zds[0]);
			zStop  = parseInt(zds[1]);
		} else {
			zStart = parseInt(zSlices);
			zStop  = zStart;
		}
		run("Z Project...", "start="+zStart+" stop="+zStop+" projection=[Max Intensity]");
		rename(ori+" Slice_"+zSlices);
	} else if (zSlices == "") {
		run("Z Project...", "projection=[Max Intensity]");
		rename(ori+" Slice_All");
	}
	
	ori = getTitle();
	if (advMon != "") {

		run("Make Composite", "display=Composite");
		run("Duplicate...", " duplicate channels");
		name = getTitle();
		run("Split Channels");
		
		
		// Get the number of separate images we need to create
		monImages = split(advMon, ", ");
		finalImages = newArray(lengthOf(monImages));
		c =  monImages.length-1;
		for(i=0; i< monImages.length; i++) {
			channels = split(monImages[i], "+");
			str = "";
			for (ch=0; ch<channels.length; ch++) {
				str += "c"+(ch+1)+"=[C"+channels[ch]+"-"+name+"] ";
			}
			for (k=ch-1;k<7;k++) {
				str += "c"+(k+1)+"=[*None*] ";
			}
			//print("Position "+(i+1)+"String: "+str);
			if(channels.length>1) {
				run("Merge Channels...", str+"create keep");
			} else {
				selectImage("C"+monImages[i]+"-"+name);
				run("Duplicate...", "title=[temp]");
			}
			run("RGB Color");
			rename("Position "+(i+1));
			finalImages[i] = "Position "+(i+1);
		}

		
		for(i=1; i< monImages.length; i++) {
			// Make Montage
			selectImage(finalImages[i]);
			
			run("Copy");
			close();
			selectImage(finalImages[0]);
			run("Add Slice");
			run("Paste");
		}
		

		
	} else {
		getDimensions(x,y,c,z,t);
			
		Stack.setDisplayMode("composite");
		name = getTitle();
		run("Duplicate...", " duplicate channels");
		name2 = getTitle();
		// Make RGB
		run("Stack to RGB");
		rgbName = getTitle();
	
		//Split the other images
		selectImage(name2);
		run("Split Channels");
		
		//Make each an RGB image
		RGBnames = newArray(c);
		for (i=1;i<=c; i++) {
			if (cPos == "First") {
				k = i;
			} else {
				k=c-i+1;
			}
				selectImage("C"+k+"-"+name2);
				if(isIgnore) { 
					getMinAndMax(min, max);
					run ("Grays");
					setMinAndMax(min, max);
				}
				
				run("RGB Color");
				run("Copy");
				close();
				selectImage(rgbName);
				run("Add Slice");
				run("Paste");
	
		}
	
		// Make the RGB first or last
		if (cPos == "Last") {
			run("Reverse");
		}
	}
	//Set the scale
	if (useScale) {
		if (atImage=="") {
			run("Scale Bar...", "width="+scaleLength+" height="+scaleHeight+" font=9 color=White background=None location=["+scalePos+"] bold hide");
		} else {
			setSlice(parseInt(atImage));
			run("Scale Bar...", "width="+scaleLength+" height="+scaleHeight+" font=9 color=White background=None location=["+scalePos+"] bold hide");
		}
	}

	// If there are channel names, add them
	channelNames = getData("Channel Names");
	fontSize = parseInt(getData("Font Size"));
	position = getData("Legend Position");
	slice = getData("Legend Montage Position");
	if(channelNames != "") {
		nameChannels(channelNames, fontSize, r,g,b, slice, position);
	}

	// Here we have a stack and maybe some ROIs exist in the ROI manager
	dealWithRois();
		

	if(nSlices >1) {

		if (mRows == "As Row") {
			run("Make Montage...", "columns="+(c+1)+" rows=1 scale=1.0 border="+bSize+" use");
		} else if (mCols == "As Column") {
			run("Make Montage...", "columns=1 rows="+(c+1)+" scale=1.0 border="+bSize+" use");
		} else {
		// Assemble the stack for 
		run("Make Montage...", "columns="+mCols+" rows="+mRows+" scale=1.0 border="+bSize+" use");
		}
	
	}

	rename(ori+"_Montage");
	
	selectWindow(ori+"_Montage");
	
}

function dealWithRois() {
	name = getTitle();
	// Right now we have the montage and we want to see if we put some ROIs in there
	isShowRois = getBoolD("Display ROIs", false);
	if (!isShowRois) return;

	getDimensions(x,y,c,z,t);
	
	// Work on the Rois
	roiOrder   = split(getDataD("ROI Order" ,""),",");
	roiColors  = split(getDataD("ROI Colors",""),",");
	roiWidth   = getDataD("ROI Width" ,2);
	roiIdx = 0;
	for(i=0; i<roiOrder.length; i++) {
		selectImage(name);
		if(roiOrder[i] != "") {
			roiManager("Select", roiOrder[i]);
			Roi.setStrokeWidth(roiWidth);
			Roi.setStrokeColor(roiColors[i]);
			setSlice(i+1);
			run("Add Selection...");
			roiIdx++;
		}
	}
		
	run("Flatten", "stack");
	
}


function getLargestString(stringArray) {
	maxLen = -1;
	for(i=0; i<stringArray.length; i++) {
		if(lengthOf(stringArray[i]) > maxLen) {
			maxLen = lengthOf(stringArray[i]);
			largest = stringArray[i];
		}
	}
	return largest;
}

function nameChannels(channelNames, fontSize, r,g,b, slice, position) {
	padding=5;
	// work in the right position
	setSlice(slice);
	
	// Width and height of the image
	height = getHeight();
	width  = getWidth();

	// Find dimensions of legend
	//   Split Channel names
	channels = split(channelNames, ",");
	
	setFont("SansSerif", fontSize, "bold");
	largestS = getLargestString(channels);
	
	boxWidth = getStringWidth(largestS)+2*padding;
	boxHeight = (fontSize+1)*channels.length+2*padding;
	
	// Get the position of the legend
	thePos = split(position, " ");
	if (thePos[0] == "top") {
		posy = 0;
	} else {
		posy = height - boxHeight;
	}

	if (thePos[1] == "left") {
		posx = 0;
	} else {
		posx = width - boxWidth;
	}

	// Create a box around the fonts
	setColor(128,128,128);
	fillRect(posx, posy, boxWidth, boxHeight);

	// Make the text the right color
	textString = channels[0];
	for(i=0; i<channels.length;i++) {
		setColor(r[i]-25,g[i]-25,b[i]-25);
		textString= channels[i];
		posy += fontSize+1;
		drawString(textString, posx+padding, posy+padding);
		
	}
}

</codeLibrary>


<text><html><font size=1 color=#66666f>
<text><html><font size=3 color=#66666f> Parameters
<line>
<button>
label=Save Parameters
icon=noicon
arg=<macro>
saveParameters();
</macro>

<button>
label=Load Parameters
icon=noicon
arg=<macro>
loadParameters();
</macro>
</line>


<text><html><font size=1 color=#66666f>
<text><html><font size=3 color=#66666f> Lookup Table Modification
<line>
<button>
label= Channels LUT Selection
icon=noicon
arg=<macro>
channelsLUTSelection();
</macro>
</line>
<line>
<button>
label= Apply to Image
icon=noicon
arg=<macro>
channelsLUTApply();
</macro>
<button>
label= Apply To Folder...
icon=noicon
arg=<macro>
dir = getDirectory("Please , select a folder containing images");			//get the folder
file = getFileList(dir);
savingDir = dir+"saving_selectedLUT"+File.separator;
File.makeDirectory(savingDir);

for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);						// open the image
		fileNameNoExt = File.nameWithoutExtension;			// get the file name without the extension
		
		channelsLUTApply();
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_LUT.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}
</macro>
</line>
<text><html><font size=1 color=#66666f>
<text><html><font size=3 color=#66666f> Brightness & Contrast Modification
<line>
<button>
label= B&C Selection
icon=noicon
arg=<macro>
brightnessAndContrastSetting();
</macro>
</line>
<line>
<button>
label= Apply to Image
icon=noicon
arg=<macro>
brightnessAndContrastSettingApply();
</macro>
<button>
label= Apply To Folder...
icon=noicon
arg=<macro>
dir = getDirectory("Please , select a folder containing images");			//get the folder
file = getFileList(dir);
savingDir = dir+"saving_selectedBC"+File.separator;
File.makeDirectory(savingDir);

for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);						// open the image
		fileNameNoExt = File.nameWithoutExtension;			// get the file name without the extension
		
		brightnessAndContrastSettingApply();
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_BC.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}
</macro>
</line>
<text><html><font size=1 color=#66666f>
<text><html><font size=3 color=#66666f> Montage Settings
<line>
<button>
label= Montage Options
icon=noicon
arg=<macro>
montageOptions();
</macro>
</line>
<line>
<button>
label= Apply to Image
icon=noicon
arg=<macro>
setBatchMode(true);
montageApply();
setBatchMode(false);
</macro>
<button>
label= Apply To Folder...
icon=noicon
arg=<macro>
dir = getDirectory("Please , select a folder containing images");			//get the folder
file = getFileList(dir);
savingDir = dir+"saving_montage"+File.separator;
File.makeDirectory(savingDir);

for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);						// open the image
		fileNameNoExt = File.nameWithoutExtension;			// get the file name without the extension
		
		montageApply();
		
		saveAs("Tiff", savingDir+fileNameNoExt+"_Montage.tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
}
</macro>
</line>
<text><html><font size=1 color=#66666f>
<text><html><font size=2.5 color=#66666f>All at once...
<line>
<button>
label= ... on the current image
icon=noicon
arg=<macro>
setBatchMode(true);
checkLUT = getData("color channel 1 using LUT");
checkBC = getData("min ch1");
checkMontage = getData("Channel Merge Position");

//Check process to do
if(checkLUT!="") {
	
	channelsLUTApply();				// action to perform, HERE!
}
if(checkBC!="") {
	
	brightnessAndContrastSettingApply();
}
if(checkMontage!="") {
	
	montageApply();
}
setBatchMode(false);
</macro>

<button>
label= ... on a folder
icon=noicon
arg=<macro>
dir = getDirectory("Please , select a folder containing images");	//get the folder
setBatchMode(true);
file = getFileList(dir);
savingDir = dir+"Processed"+File.separator;
File.makeDirectory(savingDir);

checkLUT = getData("color channel 1 using LUT");
checkBC = getData("min ch1");
checkMontage = getData("Channel Merge Position");


for (i=0; i<lengthOf(file); i++) {
	if (isImage(file[i])){
		open(dir+file[i]);							// open the image
		fileNameNoExt = File.nameWithoutExtension;	// get the file name without the extension
		process="";

		
		//Check process to do
		if(checkLUT!="") {
			process+="_LUT";
			channelsLUTApply();				// action to perform, HERE!
		}
		if(checkBC!="") {
			process+="_BC";
			brightnessAndContrastSettingApply();
		}
		if(checkMontage!="") {
			process+="_Montage";
			montageApply();
		}
		
		
		
		//print(savingDir+fileNameNoExt+process+".tif");
		saveAs("Tiff", savingDir+fileNameNoExt+process+".tif");	// save the file
		run("Close All");						// Close the image before going to the next one
	}
	setBatchMode(false);
}
</macro>
</line>
<text><html><font size=2.5 color=#66666f>Help
<line>
<button>
label=Infos & Contact
icon=noicon
arg=<macro>
theUrl = "https://c4science.ch/w/bioimaging_and_optics_platform_biop/image-processing/imagej_tools/ijab-biop_channel_tools/";
run("URL...", "url="+theUrl);
</macro>
</line>