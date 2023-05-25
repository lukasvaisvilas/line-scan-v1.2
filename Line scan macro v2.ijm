dir = getDirectory("C:\Users\Pharmacology\Desktop\Nerve fiber scripts Lukas\Images\068");
dir1 = getDirectory("C:\Users\Pharmacology\Desktop\Nerve fiber scripts Lukas\Raw data\068");

//Type coordinates for top left corner of square ROI
tl_x = 1700
tl_y = 1400
//Type in the disired line width in pixels
line_width = 230
//Set min and max 
bg_min = 0
bg_max = 2000


list = getFileList(dir);

setBatchMode(true); 
for (i = 0; i < list.length; i++){   
    processImage(dir,list[i]);
}
setBatchMode("exit and display");

function processImage(dir,image){
    open(dir+image);
    fileNoExtension = File.nameWithoutExtension;
    
    //Add Image Processing
    
    run("Subtract Background...", "rolling=25");
    setMinAndMax(bg_min, bg_max);
    	
 //Parallel line scans
 
     	makeLine(tl_x, tl_y, tl_x+line_width, tl_y);
     	profile = getProfile();
	for (i=0; i<profile.length; i++)
  		setResult("par1", i, profile[i]);
		
		makeLine(tl_x, tl_y+(line_width/2), tl_x+line_width, tl_y+(line_width/2));
		profile = getProfile();
	for (j=0; j<profile.length; j++)
  		setResult("par2", j, profile[j]);
		
		makeLine(tl_x, tl_y+line_width, tl_x+line_width, tl_y+line_width);
		profile = getProfile();
	for (k=0; k<profile.length; k++)
  		setResult("par3", k, profile[k]);
  
  //Perpendicular line scans
  
  		makeLine(tl_x, tl_y, tl_x, tl_y+line_width);
		profile = getProfile();
	for (j=0; j<profile.length; j++)
  		setResult("perp1", j, profile[j]);
    	
    	makeLine(tl_x+(line_width/2), tl_y, tl_x+(line_width/2), tl_y+line_width);
     	profile = getProfile();
	for (i=0; i<profile.length; i++)
  		setResult("perp2", i, profile[i]);
		
		makeLine(tl_x+line_width, tl_y, tl_x+line_width, tl_y+line_width);
		profile = getProfile();
	for (k=0; k<profile.length; k++)
  		setResult("perp3", k, profile[k]);
	
	updateResults(); 
    saveAs("Results", dir1+"Processed_"+fileNoExtension+".csv");

}

	close("*");
	close("Results");
