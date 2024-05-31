///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   
//   Lusca - FIJI (ImageJ) based tool for automated morphological analysis of cellular and subcellular structures
//
//   Author: Iva Simunic
//   Contact - e-mail: iva.simunic25@gmail.com
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//counter used for text data on input parameters
input_counter = 0;

//arrays created for the analysis
setOption("ExpandableArrays", true);
array_image_type = newArray("Single image", "Channel image");
array_image_dimension = newArray("2D", "3D");
array_channel_number_to_analyse = newArray;
array_channel_name = newArray;
array_colocalization = newArray;
array_classifier_name = newArray;
array_number_images_probmap = newArray;
array_probmap = newArray;
array_probmap_name = newArray;
array_results_location = newArray;
array_image_quantification = newArray;
array_DAPI = newArray;
array_colocalization_class = newArray;
array_width = newArray;
array_colocalization_image_location = newArray;
array_colocalization_channel_number = newArray;
array_colocalization_class_segment_number = newArray;
segmented_location_array = newArray;

//getting and saving image location and saving all the images in a list for the analysis
Dialog.create("Images folder");
Dialog.addMessage("Please, select the folder with images.");
Dialog.show();
image_location = getDirectory("Choose the images folder");
list_images = getFileList(image_location);

//image type selection and quantification type, everything is saved to varibles that control the input and the anaysis
Dialog.create("Image type selection");
Dialog.addMessage("Please select the parameters for image analysis");
Dialog.addMessage("\n");
Dialog.addChoice("Image type:", array_image_type);
Dialog.addChoice("             Image dimension:", array_image_dimension);
Dialog.addMessage("\n");
Dialog.addMessage("Select the type of quantification for the image");
Dialog.addCheckbox("	Set scale", false);
Dialog.addCheckbox("	Crop image", false);
Dialog.addCheckbox("	Image segmentation and other analyses", true);
Dialog.addCheckbox("	Image segmentation and other analyses - interactive", false);
Dialog.addCheckbox("	Other analyses with already segmented images", false);
Dialog.show();
Image_type = Dialog.getChoice();
Image_dimension = Dialog.getChoice();
Image_properties = Dialog.getCheckbox();
Clear_outside_overall = Dialog.getCheckbox();
Lusca = Dialog.getCheckbox();
Lusca_interactive = Dialog.getCheckbox();
Other = Dialog.getCheckbox();

//image properties setting and saving it to variables x, y, and z
if (Image_properties == 1) {
	Dialog.create("Image properties");
	Dialog.addNumber("Pixel width:", "1");
	Dialog.addNumber("Pixel height:", "1");
	Dialog.addNumber("Voxel depth:", "1");
	Dialog.show();
	x = Dialog.getNumber();
	y = Dialog.getNumber();
	z = Dialog.getNumber();
}

//getting classifiers location and saving it to variable
if (Lusca+Lusca_interactive == 1) {
	Dialog.create("Classifiers folder");
	Dialog.addMessage("Please, select the folder where classifiers are/will be placed");
	Dialog.show();
	classifiers_location = getDirectory("Choose the classifiers folder");
}

//channel information, obtaining how many channels need analysis and with for loop obtaining the number and name of each channel important for the analysis and 'Results' folder
if (Image_type == "Channel image") {
	Dialog.create("Channel data");
	Dialog.addNumber("How many channels would you like to analyse?", "2");
	Dialog.show();
	Channel_number = Dialog.getNumber();
	for (i = 1; i <= Channel_number; i++) {
		Dialog.create("Channel for analysis");
		Dialog.addNumber("Channel number:", "1");
		Dialog.addString("Channel name:", "Neural projections");
		Dialog.show();
		Channel_for_analysis = Dialog.getNumber();
		Channel_name = Dialog.getString();
		array_channel_number_to_analyse[i] = Channel_for_analysis;
		array_channel_name[i] = Channel_name;
	}
}
//single images automatically get values for channel number 1 and name 'Results'
else {
	Channel_number = 1;
	array_channel_number_to_analyse[1] = "1";
	array_channel_name[1] = "Results";
}

//crop image option
if (Clear_outside_overall == 1) {
//	opening the image
	fullpath_image = image_location + list_images[0];
	open(fullpath_image);
//	image properties setting
	if (Image_properties == 1) {
		run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
	}
//	selection and saving ROI
	setTool("rectangle");
	waitForUser("Please select the area of the image you want to analyse");
	run("ROI Manager...");
	roiManager("Add");
	roiManager("Save", image_location + "ROI.zip");
//	clear outised is used for cropping the image, on 3D images for loop is used to celar each slice
	if (Image_dimension == "2D") {
		setBackgroundColor(0, 0, 0);
		run("Clear Outside");
	} 
	else {
		Stack.getDimensions(width, height, channels, slices, frames);
		slice_number = slices;
		for (j = 1; j < slice_number; j++) {
			setSlice(j);
			roiManager("Select", 0);
			setBackgroundColor(0, 0, 0);
			run("Clear Outside", "stack");
		}
	}
	close("*");
}


//loop for setting input for each channel
for (i = 1; i <= Channel_number; i++) {
//	Lusca - obtaining imput parameters
	if (Lusca == 1) {
//		classifier name and location
		Dialog.create("Classifier and probability maps");
		Dialog.addString("Classifier name:", "classifier_neurons.model");
		Dialog.addNumber("How many classes would you like to analyse?", "2");
		Dialog.show();
		array_classifier_name[i] = Dialog.getString();
		array_number_images_probmap[i] = Dialog.getNumber();
		
//		loop for setting input for each class
		for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
//			obtaining class number and name, min and max threshold, min and max objects size, circularity, exclude on the edge option and morphological analysis options
			Dialog.create("Quantification data");
			Dialog.addNumber("Class number for the analysis:", "1");
			Dialog.addString("Class name for the analysis:", "Neural projections");
			Dialog.addMessage("\n");
			Dialog.addNumber("Minimum threshold value:", "0.5");
			Dialog.addNumber("Maximum threshold value:", "1");
			Dialog.addNumber("Minimum particle size:", "5");
			Dialog.addNumber("Maximum particle size:", "99999");
			if (Image_dimension == "2D") {
				Dialog.addString("Particle circularity value:", "0.00-1.00");
			}
			Dialog.addCheckbox("	Exclude on the edges", false);
			Dialog.addMessage("\n");
			Dialog.addMessage("Type of quantification:");
			Dialog.addCheckbox("	Neural projections", false);
			Dialog.addCheckbox("	Soma and nuclei", false);
			Dialog.addCheckbox("	Size, Number and Intensity",false);
			Dialog.addCheckbox("	Length and branching", false);
			Dialog.addCheckbox("	Width", false);
			Dialog.addCheckbox("	Colocalization with classes", false);
			Dialog.show();
//			input parameters are saved to array variables, each variable is saved on a place connected with a channel and class number to enable the analysis of multiple channels and classes withing one run
			array_probmap[i*100+j] = Dialog.getNumber();
			array_probmap_name[i*100+j] = Dialog.getString();
			array_image_quantification[10000+i*100+j] = Dialog.getNumber();
			array_image_quantification[20000+i*100+j] = Dialog.getNumber();
			array_image_quantification[30000+i*100+j] = Dialog.getNumber();
			array_image_quantification[40000+i*100+j] = Dialog.getNumber();
			if (Image_dimension == "2D") {
				array_image_quantification[50000+i*100+j] = Dialog.getString();
			}
			array_image_quantification[60000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[70000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[80000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[90000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[100000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[110000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[120000+i*100+j] = Dialog.getCheckbox();
			
//			formation of the "Results" folder
			results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
			File.makeDirectory(results_location_probmap);
			array_results_location[i*100+j] = results_location_probmap;		


//			neural projections and width input parameters
			if (array_image_quantification[70000+i*100+j]+array_image_quantification[110000+i*100+j] >= 1) {
//				input consists of number of bins, min and max histogram number
				Dialog.create("Width quantification data");
				Dialog.addNumber("Number of bins:", "3");
				Dialog.addNumber("Minimum histogram number:", "0");
				Dialog.addNumber("Maximum histogram number:", "9");
				Dialog.show();
//				saving variables to arrays
				array_width[10000+i*100+j] = Dialog.getNumber();
				array_width[20000+i*100+j] = Dialog.getNumber();
				array_width[30000+i*100+j] = Dialog.getNumber();
			}


//			soma and nuclei input parameters
			if (array_image_quantification[80000+i*100+j] == 1) {
//				selecting the folder (single images) or channel (channel images) where nuclei images are placed
				if (Image_type == "Single image") {
					Dialog.create("Nuclei images folder");
					Dialog.addMessage("Please, select the folder with nuclei images.");
					Dialog.show();
					DAPI_image_location = getDirectory("Choose the nuclei images folder");
					DAPI_list_images = getFileList(DAPI_image_location);
				}	
				else {
					Dialog.create("Nuclei channel");
					Dialog.addNumber("Nuclei channel:", "1");
					Dialog.show();
					nuclei_channel_number = Dialog.getNumber();
				}
					
//				input consists of classifier name and location, intensity, size and circularity thresholds
				Dialog.create("Nuclei quantification data");
				Dialog.addString("Classifier name:", "classifier_nuclei.model");
				Dialog.addMessage("\n");
				Dialog.addNumber("Minimun threshold value:", "0.5");
				Dialog.addNumber("Maximum threshold value:", "1");
				Dialog.addNumber("Minimun particle size:", "5");
				Dialog.addNumber("Maximum particle size:", "99999");
				if (Image_dimension == "2D") {
					Dialog.addString("Particle circularity value:", "0.00-1.00");
				}
				Dialog.show();
//				saving variables to arrays
				array_DAPI[1] = Dialog.getString();
				array_DAPI[3] = Dialog.getNumber();
				array_DAPI[4] = Dialog.getNumber();
				array_DAPI[5] = Dialog.getNumber();
				array_DAPI[6] = Dialog.getNumber();
				if (Image_dimension == "2D") {
					array_DAPI[7] = Dialog.getString();
				}
			}

			
//			colocalization input parameters
			if (array_image_quantification[120000+i*100+j] == 1) {
//				number of segmentation analysis information important for the for loop for obtaining the input parameters for second colocalization image
				Dialog.create("Segments for colocalization");
				Dialog.addNumber("How many colocalization analyses would you like to do with this segment as the first image?", "1");
				Dialog.show();
				Colocalization_class_number = Dialog.getNumber();
						
				for (cs = 1; cs <= Colocalization_class_number; cs++) {
//					selecting the folder (single images) or channel (channel images) where second colocalization images are placed
					if (Image_type == "Single image") {
						Dialog.create("Colocalization images folder");
						Dialog.addMessage("Please, select the folder with second colocalization images.");
						Dialog.show();
						array_colocalization_image_location[100+cs] = getDirectory("Choose the second colocalization images folder");
					}
					else {
						Dialog.create("Second colocalization channel");
						Dialog.addNumber("Second colocalization channel:", "1");
						Dialog.show();
						array_colocalization_channel_number[100+cs] = Dialog.getNumber();
					}

//					input consists of classifier name and location, intensity, size and circularity thresholds
					Dialog.create("Colocalization quantification data");
					Dialog.addString("Classifier name:", "classifier_colocalization.model");
					Dialog.addNumber("Channel for second image colocalization:", "1");
					Dialog.addMessage("\n");
					Dialog.addNumber("Minimun threshold value:", "0.5");
					Dialog.addNumber("Maximum threshold value:", "1");
					Dialog.addNumber("Minimun particle size:", "5");
					Dialog.addNumber("Maximum particle size:", "99999");
					if (Image_dimension == "2D") {
						Dialog.addString("Particle circularity value:", "0.00-1.00");
					}	
					Dialog.show();
//					saving variables to arrays
					array_colocalization_class[cs*1000+1] = Dialog.getString();
					array_colocalization_class[cs*1000+2] = Dialog.getNumber();
					array_colocalization_class[cs*1000+3] = Dialog.getNumber();
					array_colocalization_class[cs*1000+4] = Dialog.getNumber();
					array_colocalization_class[cs*1000+5] = Dialog.getNumber();
					array_colocalization_class[cs*1000+6] = Dialog.getNumber();
					if (Image_dimension == "2D") {
						array_colocalization_class[cs*1000+7] = Dialog.getString();
					}
				}
			}
		}
	}



//	Lusca - interactive part
	if (Lusca_interactive == 1) {
//		opening the image
		fullpath_image = image_location + list_images[0];
		open(fullpath_image);
		first_image = getTitle();
		n = array_channel_number_to_analyse[i];
		setSlice(n);
		run("Duplicate...", "duplicate channels=n");
		
//		image properties setting
		if (Image_properties == 1) {
			run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
		}
		
//		clear outside
		if (Clear_outside_overall == 1) {
			if (Image_dimension == "2D") {
				roiManager("Select", 0);
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
			}
			else {
				Stack.getDimensions(width, height, channels, slices, frames);
				slice_number = slices;
				for (c = 1; c < slice_number; c++) {
					setSlice(c);
					roiManager("Select", 0);
					setBackgroundColor(0, 0, 0);
					run("Clear Outside", "stack");
				}
			}
		}
		
//		Trainable Weka Segmentation - classifier formation and saving
		if (Image_dimension == "2D") {	
			run("Trainable Weka Segmentation");
		}	
		else {
			run("Trainable Weka Segmentation 3D");
		}
		wait(2000);
		TWS=getTitle();
		selectWindow(""+TWS+"");
		waitForUser("When you have finished making and saving your classifier press OK");

//		classifier name, location and probability maps formation
		Dialog.create("Classifier name and Probability maps");
		Dialog.addString("Classifier name:", "classifier_neurons.model");
		Dialog.addNumber("How many classes would you like to analyse?", "2");
		Dialog.show();
		array_classifier_name[i] = Dialog.getString();
		array_number_images_probmap[i] = Dialog.getNumber();
		call("trainableSegmentation.Weka_Segmentation.getProbability");
		close(TWS);
		
//		loop for setting input for each class
		for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
			Dialog.create("Probability maps data");
			Dialog.addNumber("Class number for the analysis:", "1");
			Dialog.addString("Class name for the analysis:", "Neural projections");
			Dialog.show();
			array_probmap[i*100+j] = Dialog.getNumber();
			array_probmap_name[i*100+j] = Dialog.getString();
				
//			formation of the 'Results' folder
			results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
			File.makeDirectory(results_location_probmap);
			array_results_location[i*100+j] = results_location_probmap;

			selectWindow("Probability maps");
			n = array_probmap[i*100+j];
			setSlice(n);
			if (Image_dimension == "2D") {
				run("Duplicate...", "use");
			}
			else {
				run("Duplicate...", "duplicate channels=n");
			}
			
//			threshold setting
			run("Threshold...");
			waitForUser("Press OK when you found the right threshold");
			Dialog.create("Threshold");
			Dialog.addNumber("Minimun threshold value:", "0.5");
			Dialog.addNumber("Maximum threshold value:", "1");
			Dialog.show();
			Min_threshold = Dialog.getNumber();
			Max_threshold = Dialog.getNumber();
			array_image_quantification[10000+i*100+j] = Min_threshold;
			array_image_quantification[20000+i*100+j] = Max_threshold;

//			min and max size of the objects setting
			setThreshold(Min_threshold, Max_threshold);
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Default background=Dark black");
			image = getTitle();
//			while loop for determination of min, max size, circularity and edge exclusion is regulated with the bollean input below
			particle_set = getBoolean("Do you have min and max particle dimension?");
//			2D images area, circularity and edge exclusion are analysed by particle analysis
			if (Image_dimension == "2D") {	
				while (particle_set == 0) {
					selectWindow(image);
					Dialog.create("Size");
					Dialog.addNumber("Minimun particle size:", "5");
					Dialog.addNumber("Maximum particle size:", "99999");
					Dialog.addString("Particle circularity value:", "0.00-1.00");
					Dialog.addCheckbox("	Exclude on the edges", false);
					Dialog.show();
					Min = Dialog.getNumber();
					Max = Dialog.getNumber();
					Circularity = Dialog.getString();
					Exclude = Dialog.getCheckbox();
					run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
//					edge exclusion parameter
					if (Exclude == 1) {
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks exclude");
					}
					else {
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks");
					}
					maska = getTitle();
					waitForUser("Please check the masked image for the result and press 'OK' when done");
					particle_set = getBoolean("Do you have min and max particle dimension?");
					close(maska);
				}
			}
//			3D images need volumetric analyses and therefore are analiysed differently with 3DOC
			else {
				while (particle_set == 0) {
					selectWindow(image);
					run("Duplicate...", "title=duplicate duplicate");
					Dialog.create("Size");
					Dialog.addNumber("Minimun particle size:", "5");
					Dialog.addNumber("Maximum particle size:", "99999");
					Dialog.addCheckbox("	Exclude on the edges", false);
					Dialog.show();
					Min = Dialog.getNumber();
					Max = Dialog.getNumber();
					Exclude = Dialog.getCheckbox();
					run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
					selectWindow(image);
//					edge exclusion parameter
					if (Exclude == 1) {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges objects");
					}
					else {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
					}
					image_to_close = getTitle();
					close(image_to_close);
					waitForUser("Please check the masked image for the result and press 'OK' when done");						
					particle_set = getBoolean("Do you have min and max particle dimension?");
					close("duplicate");
					maska = getTitle();
					close(maska);
				}
			}			
//			final size, circularity and edge exclusion input parameters
			Dialog.create("Size");
			Dialog.addNumber("Minimun particle size:", "5");
			Dialog.addNumber("Maximum particle size:", "99999");
			if (Image_dimension == "2D") {
				Dialog.addString("Paricle circularity value:", "0.00-1.00");
			}
			Dialog.addCheckbox("	Exclude on the edges", false);
			Dialog.show();
			array_image_quantification[30000+i*100+j] = Dialog.getNumber();
			array_image_quantification[40000+i*100+j] = Dialog.getNumber();
			if (Image_dimension == "2D") {
				array_image_quantification[50000+i*100+j] = Dialog.getString();
			}
			array_image_quantification[60000+i*100+j] = Dialog.getCheckbox();

//			type of quantification
			Dialog.create("Image quantification");
			Dialog.addMessage("Select the type of quantification for the image");
			Dialog.addCheckbox("	Neural projections", false);
			Dialog.addCheckbox("	Soma and nuclei", false);
			Dialog.addCheckbox("	Size, Number and Intensity",false);
			Dialog.addCheckbox("	Length and branching", false);
			Dialog.addCheckbox("	Width", false);
			Dialog.addCheckbox("	Colocalization with classes", false);
			Dialog.show();
			array_image_quantification[70000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[80000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[90000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[100000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[110000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[120000+i*100+j] = Dialog.getCheckbox();


//			neural projections and width input parameters
			if (array_image_quantification[70000+i*100+j]+array_image_quantification[110000+i*100+j] >= 1) {
				Min = array_image_quantification[30000+i*100+j];
				Max = array_image_quantification[40000+i*100+j];
//				obtaining thresholded mask image 
				selectWindow(image);
				if (Image_dimension == "2D") {
					run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
					if (array_image_quantification[60000+i*100+j] == 1) {
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks exclude");
					}
					else {
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks");
					}
				}
				else {
					run("Duplicate...", "title=duplicate duplicate");
					selectWindow(image);
					run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
					if (array_image_quantification[60000+i*100+j] == 1) {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges objects");
					}
					else {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
					}
					image_to_close = getTitle();
					close(image_to_close);
					close("duplicate");
				}				
				
//				threshold mask image is duplicated twice
				run("Duplicate...", "title=W1 duplicate");
				run("Duplicate...", "title=W2 duplicate");
//				first duplicate is used to asses thickness of segments by Local Thickness
				selectWindow("W1");
				run("Local Thickness (masked, calibrated, silent)");
				W1 = getTitle();
//				second duplicated is used to make skeletons
				selectWindow("W2");
				run("Skeletonize (2D/3D)");
				run("32-bit");
				setAutoThreshold("Default dark");
				setThreshold(1.00, 1e30);
				run("NaN Background", "stack");
				run("Subtract...", "value=255 stack");
				W2 = getTitle();
//				the two images are added to obtain the width measurement of each length segment
				imageCalculator("Add create stack", W2, W1);
//				closing images for the next input parameters or start of the analysis
				close("W1");
				close("W2");
				close(W1);
				selectWindow("Result of W2");
				image = getTitle();
//				while loop for determination of bin number, min and max histogram is regulated with the bollean input below
				width_set = getBoolean("Do you have needed data (number of bins, minimum and maximum number for histogram) for width calculation?");
				while (width_set == 0) {
					selectWindow(image);
					Dialog.create("Width quantification data");
					Dialog.addNumber("Number of bins:", "3");
					Dialog.addNumber("Minimum histogram number:", "0");
					Dialog.addNumber("Maximum histogram number:", "9");
					Dialog.show();
					nBins = Dialog.getNumber();
					histMin = Dialog.getNumber();
					histMax = Dialog.getNumber();
					
//					list from histogram is made with 2 for loops
					run("Clear Results");
					row = 0;
					getDimensions(width, height, channels, slices, frames);
					n = slices;
//					bin loop
					for (p=0; p<nBins; p++) {
						sum = 0;
//						slices in the image loop
						for (r = 1; r <= n; r++) {
							setSlice(r);
							getHistogram(values, counts, nBins, histMin, histMax);
							sum += counts[p];
						}
					    setResult("Value", row, values[p]);
				    	setResult("Count", row, sum);
						row++;
					}
					updateResults();
//					histogram
					run("Histogram", "bins=nBins x_min=histMin x_max=histMax y_max=Auto stack");
					waitForUser("Please check histogram and result table and press 'OK'");
					close("Results");
					close("Histogram of Result");
					width_set = getBoolean("Do you have needed data (number of bins, minimum and maximum number for histogram) for width calculation?");
				}
//				final bin number, min and max histogram input parameters
				Dialog.create("Width quantification data");
				Dialog.addNumber("Number of bins:", "3");
				Dialog.addNumber("Minimum histogram number:", "0");
				Dialog.addNumber("Maximum histogram number:", "9");
				Dialog.show();
				array_width[10000+i*100+j] = Dialog.getNumber();
				array_width[20000+i*100+j] = Dialog.getNumber();
				array_width[30000+i*100+j] = Dialog.getNumber();	
				W1 = "W1";
				close(image);
			}

//			soma and nuclei input parameters
			if (array_image_quantification[80000+i*100+j] == 1) {
//				obtaining image location (single images) or channel number (channel images) for nuclei images and opening
				if (Image_type == "Single image") {
					Dialog.create("Nuclei images folder");
					Dialog.addMessage("Please, select the folder with nuclei images.");
					Dialog.show();
					DAPI_image_location = getDirectory("Choose the nuclei images folder");
					DAPI_list_images = getFileList(DAPI_image_location);
					fullpath_DAPI_image = DAPI_image_location + DAPI_list_images[0];
					open(fullpath_DAPI_image);
				}	
				else {
					Dialog.create("Nuclei channel");
					Dialog.addNumber("Nuclei channel:", "1");
					Dialog.show();
					nuclei_channel_number = Dialog.getNumber();						
					selectWindow(first_image);
					n = nuclei_channel_number;
					setSlice(n);
					run("Duplicate...", "duplicate channels=n");
				}
					
//				clear outside
				if (Clear_outside_overall == 1) {
					if (Image_dimension == "2D") {
						roiManager("Select", 0);
						setBackgroundColor(0, 0, 0);
						run("Clear Outside");
					}
					else {
						Stack.getDimensions(width, height, channels, slices, frames);
						slice_number = slices;
						for (c = 1; c < slice_number; c++) {
							setSlice(c);
							roiManager("Select", 0);
							setBackgroundColor(0, 0, 0);
							run("Clear Outside", "stack");
						}
					}
				}
				
				nuclei_title = getTitle();
//				Trainable Weka Segmentation - classifier formation and saving
				if (Image_dimension == "2D") {	
					run("Trainable Weka Segmentation");
				}	
				else {
					run("Trainable Weka Segmentation 3D");
				}
				wait(2000);
				TWS=getTitle();
				selectWindow(""+TWS+"");
				call("trainableSegmentation.Weka_Segmentation.changeClassName", "0", "Nuclei");
				call("trainableSegmentation.Weka_Segmentation.changeClassName", "1", "Background");
				waitForUser("When you have finished making and saving your classifier press OK");
				
//				classifier name, location and probability maps formation
				Dialog.create("Classifier - nuclei");
				Dialog.addString("Classifier name:", "classifier_nuclei.model");
				Dialog.show();
				array_DAPI[1] = Dialog.getString();																
				call("trainableSegmentation.Weka_Segmentation.getProbability");
				setSlice(1);
				if (Image_dimension == "2D") {
					run("Duplicate...", "title=Nuclei");
				}
				else {
					run("Duplicate...", "title=Nuclei duplicate channels=n");
				}
				
				close(TWS);
				close("Probability maps");

//				threshold setting			
				run("Threshold...");
				waitForUser("Press OK when you found the right threshold");
				Dialog.create("Threshold - nuclei");
				Dialog.addNumber("Minimun threshold value:", "0.5");
				Dialog.addNumber("Maximum threshold value:", "1");
				Dialog.show();
				Min_threshold = Dialog.getNumber();
				Max_threshold = Dialog.getNumber();
				array_DAPI[3] = Min_threshold;
				array_DAPI[4] = Max_threshold;

//				min and max size of the objects setting
				setThreshold(Min_threshold, Max_threshold);
				setOption("BlackBackground", true);
				run("Convert to Mask", "method=Default background=Dark black");
				DAPI_image = getTitle();
//				while loop for determination of min, max size, circularity and edge exclusion is regulated with the bollean input below
				particle_set = getBoolean("Do you have min and max particle dimension?");
//				2D images area, circularity and edge exclusion are analysed by particle analysis
				if (Image_dimension == "2D") {
					while (particle_set == 0) {
						selectWindow(DAPI_image);
						Dialog.create("Size - nuclei");
						Dialog.addNumber("Minimun particle size:", "5");
						Dialog.addNumber("Maximum particle size:", "99999");
						Dialog.addString("Particle circularity value:", "0.00-1.00");
						Dialog.show();
						Min = Dialog.getNumber();
						Max = Dialog.getNumber();
						Circularity = Dialog.getString();
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
//						edge exclusion parameter
						if (array_image_quantification[60000+i*100+j] == 1) {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks exclude");
						}
						else {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks");
						}
						maska = getTitle();
						waitForUser("Please check the masked image for the result and press 'OK' when done");
						particle_set = getBoolean("Do you have min and max particle dimension?");
						close(maska);
					}
				}
//				3D images need volumetric analyses and therefore are analiysed differently with 3DOC
				else {
					while (particle_set == 0) {
						selectWindow(DAPI_image);
						run("Duplicate...", "title=duplicate duplicate");
						Dialog.create("Size - nuclei");
						Dialog.addNumber("Minimun particle size:", "5");
						Dialog.addNumber("Maximum particle size:", "99999");
						Dialog.show();
						Min = Dialog.getNumber();
						Max = Dialog.getNumber();
						run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
						selectWindow(DAPI_image);
//						edge exclusion parameter
						if (array_image_quantification[60000+i*100+j] == 1) {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges objects");
						}
						else {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
						}
						image_to_close = getTitle();
						close(image_to_close);
						waitForUser("Please check the masked image for the result and press 'OK' when done");
						particle_set = getBoolean("Do you have min and max particle dimension?");
						close("duplicate");
						maska = getTitle();
						close(maska);
					}
				}
//				final size, circularity and edge exclusion input parameters
				Dialog.create("Size - nuclei");
				Dialog.addNumber("Minimun particle size:", "5");
				Dialog.addNumber("Maximum particle size:", "99999");
				if (Image_dimension == "2D") {
					Dialog.addString("Particle circularity value:", "0.00-1.00");
				}
				Dialog.show();
				array_DAPI[5] = Dialog.getNumber();
				array_DAPI[6] = Dialog.getNumber();
				if (Image_dimension == "2D") {
					array_DAPI[7] = Dialog.getString();
				}
//				closing images for the next input parameters or start of the analysis
				close(nuclei_title);
				close(DAPI_image);
			}

			
//			colocalization input parameters
			if (array_image_quantification[120000+i*100+j] == 1) {
//				getting the number of analysis for second colocalization image important for loop below
				Dialog.create("Segments for colocalization");
				Dialog.addNumber("How many colocalization analyses would you like to do with this segment as the first image?", "1");
				Dialog.show();
				Colocalization_class_number = Dialog.getNumber();
				
//				obtaining image location (single images) or channel number (channel images) for second colocalization image and opening
				for (cs = 1; cs <= Colocalization_class_number; cs++) {
					if (Image_type == "Single image") {
						Dialog.create("Colocalization images folder");
						Dialog.addMessage("Please, select the folder with second colocalization images.");
						Dialog.show();
						Colocalization_image_location = getDirectory("Choose the second colocalization images folder");
						Colocalization_list_images = getFileList(Colocalization_image_location);
						fullpath_Colocalization_image = Colocalization_image_location + Colocalization_list_images[0];
						open(fullpath_Colocalization_image);
						array_colocalization_image_location[100+cs] = Colocalization_image_location;
					}
					else {
						Dialog.create("Second colocalization channel");
						Dialog.addNumber("Second colocalization channel:", "1");
						Dialog.show();
						array_colocalization_channel_number[100+cs] = Dialog.getNumber();
						selectWindow(first_image);
						n = array_colocalization_channel_number[100+cs];
						setSlice(n);
						run("Duplicate...", "duplicate channels=n");
					}
						
//					clear outside
					if (Clear_outside_overall == 1) {
						if (Image_dimension == "2D") {
							roiManager("Select", 0);
							setBackgroundColor(0, 0, 0);
							run("Clear Outside");
						}
						else {
							Stack.getDimensions(width, height, channels, slices, frames);
							slice_number = slices;
							for (c = 1; c < slice_number; c++) {
								setSlice(c);
								roiManager("Select", 0);
								setBackgroundColor(0, 0, 0);
								run("Clear Outside", "stack");
							}
						}
					}
					
					coloc_title = getTitle();
//					Trainable Weka Segmentation - classifier formation and saving
					if (Image_dimension == "2D") {	
						run("Trainable Weka Segmentation");
					}	
					else {
						run("Trainable Weka Segmentation 3D");
					}
					wait(2000);
					TWS=getTitle();
					selectWindow(""+TWS+"");						
					waitForUser("When you have finished making and saving your classifier press OK");

//					classifier name, location and probability maps formation
					Dialog.create("Classifier - colocalization");
					Dialog.addString("Classifier name:", "classifier_colocalization.model");
					Dialog.show();
					array_colocalization_class[cs*1000+1] = Dialog.getString();	
					call("trainableSegmentation.Weka_Segmentation.getProbability");

//					probability class channel selection
					Dialog.create("Channel for colocalization");
					Dialog.addNumber("Channel for second image colocalization:", "1");
					Dialog.show();
					array_colocalization_class[cs*1000+2] = Dialog.getNumber();
					n = array_colocalization_class[cs*1000+2];
					setSlice(n);						
					if (Image_dimension == "2D") {
						run("Duplicate...", "title=Colocalization");
					}
					else {
						run("Duplicate...", "title=Colocalization duplicate channels=n");
					}
					close(TWS);
					close("Probability maps");
							
//					threshold setting
					run("Threshold...");
					waitForUser("Press OK when you found the right threshold");
					Dialog.create("Threshold - colocalization");
					Dialog.addNumber("Minimun threshold value:", "0.5");
					Dialog.addNumber("Maximum threshold value:", "1");
					Dialog.show();
					Min_threshold = Dialog.getNumber();
					Max_threshold = Dialog.getNumber();
					array_colocalization_class[cs*1000+3] = Min_threshold;
					array_colocalization_class[cs*1000+4] = Max_threshold;

//					min and max size of the objects setting
					setThreshold(Min_threshold, Max_threshold);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					Colocalization_class_image = getTitle();						
//					while loop for determination of min, max size, circularity and edge exclusion is regulated with the bollean input below
					particle_set = getBoolean("Do you have min and max particle dimension?");
//					2D images area, circularity and edge exclusion are analysed by particle analysis
					if (Image_dimension == "2D") {
						while (particle_set == 0) {
							selectWindow(Colocalization_class_image);
							Dialog.create("Size - colocalization");
							Dialog.addNumber("Minimun particle size:", "5");								
							Dialog.addNumber("Maximum particle size:", "99999");
							Dialog.addString("Particle circularity vale:", "0.00-1.00");
							Dialog.show();
							Min = Dialog.getNumber();
							Max = Dialog.getNumber();
							Circularity = Dialog.getString();
							run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
//							edge exclusion parameter
							if (array_image_quantification[60000+i*100+j] == 1) {
								run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks exclude");
							}
							else {
								run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks");
							}
							maska = getTitle();
							waitForUser("Please check the masked image for the result and press 'OK' when done");
							particle_set = getBoolean("Do you have min and max particle dimension?");
							close(maska);
						}	
					}
//					3D images need volumetric analyses and therefore are analiysed differently with 3DOC
					else {
						while (particle_set == 0) {
							selectWindow(Colocalization_class_image);
							run("Duplicate...", "title=duplicate duplicate");
							Dialog.create("Size - colocalization");
							Dialog.addNumber("Minimun particle size:", "5");
							Dialog.addNumber("Maximum particle size:", "99999");
							Dialog.show();
							Min = Dialog.getNumber();
							Max = Dialog.getNumber();
							run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
							selectWindow(Colocalization_class_image);
//							edge exclusion parameter
							if (array_image_quantification[60000+i*100+j] == 1) {
								run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges objects");
							}
							else {
								run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
							}
							image_to_close = getTitle();
							close(image_to_close);
							waitForUser("Please check the masked image for the result and press 'OK' when done");
							particle_set = getBoolean("Do you have min and max particle dimension?");
							close("duplicate");
							maska = getTitle();
							close(maska);
						}
					}
//					final size, circularity and edge exclusion input parameters
					Dialog.create("Size - colocalization");
					Dialog.addNumber("Minimun particle size:", "5");
					Dialog.addNumber("Maximum particle size:", "99999");
					if (Image_dimension == "2D") {
						Dialog.addString("Particle circularity value:", "0.00-1.00");
					}
					Dialog.show();
					array_colocalization_class[cs*1000+5] = Dialog.getNumber();
					array_colocalization_class[cs*1000+6] = Dialog.getNumber();
					if (Image_dimension == "2D") {
						array_colocalization_class[cs*1000+7] = Dialog.getString();
					}
//					closing images for the next input parameters or start of the analysis
					close(coloc_title);
					close(Colocalization_class_image);
				}
			}
		}
		close("*");
		close("Threshold");
		close("Log");
	}
	
	
	
//	input parameters for already segmented images
	if (Other == 1) {
//		obtaining the location where segmented images are
		Dialog.create("Segmented images folder");
		Dialog.addMessage("Please, select the folder with segmented images");
		Dialog.show();
		segmented_location_array[100+i] = getDirectory("Choose the segmented images folder");
		array_number_images_probmap[i] = 1;
		
//		loop is to fit calculations into the code with TWS segmentation
		for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
//			parameters are set in order not to change anything from the loaded images
			array_probmap[i*100+j] = 1;
			array_probmap_name[i*100+j] = "Segmented image analysis";
			array_image_quantification[10000+i*100+j] = 1;
			array_image_quantification[20000+i*100+j] = 255;
			array_image_quantification[30000+i*100+j] = 0;
			array_image_quantification[40000+i*100+j] = 9999999999999999999999999;
			if (Image_dimension == "2D") {
				array_image_quantification[50000+i*100+j] = "0.00-1.00";
			}
			array_image_quantification[60000+i*100+j] = false;
			
//			formation of the "Results" folder
			results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
			File.makeDirectory(results_location_probmap);
			array_results_location[i*100+j] = results_location_probmap;	
		
//			obtaining type of the analysis for segmented images
			Dialog.create("Image quantification");
			Dialog.addMessage("Type of quantification:");
			Dialog.addCheckbox("	Neural projections", false);
			Dialog.addCheckbox("	Soma and nuclei", false);
			Dialog.addCheckbox("	Size, Number and Intensity",false);
			Dialog.addCheckbox("	Length and branching", false);
			Dialog.addCheckbox("	Width", false);
			Dialog.addCheckbox("	Colocalization with classes", false);
			Dialog.show();
			array_image_quantification[70000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[80000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[90000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[100000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[110000+i*100+j] = Dialog.getCheckbox();
			array_image_quantification[120000+i*100+j] = Dialog.getCheckbox();
		
//			neural projections and width input parameters
			if (array_image_quantification[70000+i*100+j]+array_image_quantification[110000+i*100+j] >= 1) {
//				input consists of number of bins, min and max histogram number
				Dialog.create("Width quantification data");
				Dialog.addNumber("Number of bins:", "3");
				Dialog.addNumber("Minimum histogram number:", "0");
				Dialog.addNumber("Maximum histogram number:", "9");
				Dialog.show();
//				saving variables to arrays
				array_width[10000+i*100+j] = Dialog.getNumber();
				array_width[20000+i*100+j] = Dialog.getNumber();
				array_width[30000+i*100+j] = Dialog.getNumber();
			}
			
//			soma and nuclei input
			if (array_image_quantification[80000+i*100+j]==1) {
//				selecting the folder (single images) or channel (channel images) where second colocalization images are placed
				if (Image_type == "Single image") {
					Dialog.create("Nuclei images folder");
					Dialog.addMessage("Please, select the folder with nuclei images.");
					Dialog.show();
					DAPI_image_location = getDirectory("Choose the nuclei images folder");
					DAPI_list_images = getFileList(DAPI_image_location);
				}	
				else {
					Dialog.create("Nuclei channel");
					Dialog.addNumber("Nuclei channel:", "1");
					Dialog.show();
					nuclei_channel_number = Dialog.getNumber();
				}
				
//				segmented nuclei image location
				Dialog.create("Segmented nuclei images folder");
				Dialog.addMessage("Please, select the folder with segmented nuclei images.");
				Dialog.show();
				dapi_segmented_location = getDirectory("Choose the segmented nuclei images folder");
				
//				nuclei parameters are set in order not to change anything from the loaded images
				array_DAPI[3] = 1;
				array_DAPI[4] = 255;
				array_DAPI[5] = 0;
				array_DAPI[6] = 9999999999999999999999999;
				if (Image_dimension == "2D") {
					array_DAPI[7] = "0.00-1.00";
				}
			}
//			colocalization input
			if (array_image_quantification[120000+i*100+j]==1) {
//				getting the number of analysis for second colocalization image important for loop below
				Dialog.create("Segments for colocalization");
				Dialog.addNumber("How many colocalization analyses would you like to do with this segment as the first image?", "1");
				Dialog.show();
				Colocalization_class_number = Dialog.getNumber();
//				segmented second colocalization image location
				for (cs = 1; cs <= Colocalization_class_number; cs++) {
					Dialog.create("Segmented colocalization images folder");
					Dialog.addMessage("Please, select the folder with already segmented second colocalization images.");
					Dialog.show();
					array_colocalization_image_location[100+cs] = getDirectory("Choose the segmented second colocalization images folder");
					
					array_colocalization_class[cs*1000+3] = 1;
					array_colocalization_class[cs*1000+4] = 255;
					array_colocalization_class[cs*1000+5] = 0;
					array_colocalization_class[cs*1000+6] = 9999999999999999999999999;
					if (Image_dimension == "2D") {
						array_colocalization_class[cs*1000+7] = "0.00-1.00";
					}
				}
			}
		}
	}
}



//formation of Log file with input parameters for the analysis
if (Lusca + Lusca_interactive == 1) {
	for (i = 1; i <= Channel_number; i++) {
		for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
//			input parameters for image that is analysed
			NP = "";
			SN = "";
			SNI = "";
			LB = "";
			W = "";
			CWC = "";
			print("INPUT PARAMETERS - Number of analysis: " + j);
			print("Image type: " + Image_type + ", " + Image_dimension);
			if (Image_properties == 1) {
				print("Image properties (pixel width, height, depth): " + x + ", " + y + ", " + z);
			}
			if (Image_type == "Channel image") {
				print("Channel number: " + array_channel_number_to_analyse[i]);
			}
			print("Classifier name: " + array_classifier_name[i]);
			print("Class name and number: " + array_probmap_name[i*100+j] + " (" + array_probmap[i*100+j] + ")");
			print("Minimum and maximum threshold: " + array_image_quantification[10000+i*100+j] + " - " + array_image_quantification[20000+i*100+j]);
			print("Minimum and maximum size: " + array_image_quantification[30000+i*100+j] + " - " + array_image_quantification[40000+i*100+j]);
			if (Image_dimension == "2D") {
				print("Circularity: " + array_image_quantification[50000+i*100+j]);
			}
			if (array_image_quantification[60000+i*100+j] == 1) {
				print("Exclude on the edges: yes");
			}
			else {
				print("Exclude on the edges: no");
			}
			if (array_image_quantification[70000+i*100+j]) {
				NP = "''Neural projections''";
			}
			if (array_image_quantification[80000+i*100+j]) {
				SN = "''Soma and nuclei'' ";
			}
			if (array_image_quantification[90000+i*100+j]) {
				SNI = "''Size, Number and Intensity'' ";
			}
			if (array_image_quantification[100000+i*100+j]) {
				LB = "''Length and branching'' ";
			}
			if (array_image_quantification[110000+i*100+j]) {
				W = "''Width'' ";
			}
			if (array_image_quantification[120000+i*100+j]) {
				CWC = "''Colocalization with classes''";
			}
			print("Morphology analysis: " + NP + SN + SNI + LB + W + CWC);
			
//			neural projections and width input parameters
			if (array_image_quantification[70000+i*100+j] + array_image_quantification[110000+i*100+j] >= 1) {
				print("Number of bins: " + array_width[10000+i*100+j]);
				print("Minimum and maximum histogram number: " + array_width[20000+i*100+j] + " - " + array_width[30000+i*100+j]);
			}
			
//			soma and nuclei input parameters
			if (array_image_quantification[80000+i*100+j] == 1) {
				print("Nuclei classifier name: " + array_DAPI[1]);
				print("Nuclei minimum and maximum threshold: " + array_DAPI[3] + " - " + array_DAPI[4]);
				print("Nuclei minimum and maximum size: " + array_DAPI[5] + " - " + array_DAPI[6]);
				if (Image_dimension == "2D") {
					print("Nuclei circularity: " + array_DAPI[7]);
				}
			}
			
//			colocalization input parameters
			if (array_image_quantification[120000+i*100+j]) {
				for (cs = 1; cs <= Colocalization_class_number; cs++) {
					if (Image_type == "Single image") {
						print("Second colocalization image data for folder: " + array_colocalization_image_location[100+cs]);
					}
					else {
						print("Second colocalization image data for channel: " + array_colocalization_channel_number[100+cs]);
					}
					print("Colocalization classifier name: " + array_colocalization_class[cs*1000+1]);
					print("Colocalzation class channel: " + array_colocalization_class[cs*1000+2]);
					print("Colocalization minimum and maximum threshold: " + array_colocalization_class[cs*1000+3] + " - " + array_colocalization_class[cs*1000+4]);
					print("Colocalization minimum and maximum size: " + array_colocalization_class[cs*1000+5] + " - " + array_colocalization_class[cs*1000+6]);
					if (Image_dimension == "2D") {
						print("Colocalization circularity: " + array_colocalization_class[cs*1000+7]);
					}
				}
			}
//			adding 1 to the counter before the next analysis
			print("");
			input_counter += 1;
		}
	}
//saving the input paarameters file
	saveAs("Text", image_location+"/"+"Input parameters.txt");
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//counters for 'Results' tables for all the analysis parameters and colocalization
counter = 0;
counter_col = 0;

//MAIN PROGRAMME LOOP
//loop for each image in the selected folder
for (i = 1; i <= list_images.length; i+=1) {
//opening image
	fullpath_image = image_location + list_images[i-1];
	open(fullpath_image);
	first_image_title = getTitle();		
	
//image properties setting
	if (Image_properties == 1) {
		run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
	}
	
//loop for each channel user selected to analyse
	for (j = 1; j <= Channel_number; j++) {
//oppening the channel
		selectWindow(first_image_title);
		n = array_channel_number_to_analyse[j];
		setSlice(n);
		run("Duplicate...", "title=IMAGE duplicate channels=n");
		
//clear outside
		if (Clear_outside_overall == 1) {
			if (Image_dimension == "2D") {
				roiManager("Select", 0);
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
			}
			else {
				Stack.getDimensions(width, height, channels, slices, frames);
				slice_number = slices;
				for (c = 1; c < slice_number; c++) {
					setSlice(c);
					roiManager("Select", 0);
					setBackgroundColor(0, 0, 0);
					run("Clear Outside", "stack");
				}
			}
		}
		run("Select None");
		
//condition to chech if morphologicla analysis is choosen at the input parameters
		if (Lusca+Lusca_interactive+Other == 1) {
			selectWindow("IMAGE");
//machine learning segmentation, application of the classifier and obtaining Probability maps
			if (Lusca+Lusca_interactive == 1) {
//TWS
				if (Image_dimension == "2D") {	
					run("Trainable Weka Segmentation");
				}	
				if (Image_dimension == "3D") {
					run("Trainable Weka Segmentation 3D");
				}			
				wait(2000);
				TWS=getTitle();
				selectWindow(""+TWS+"");
				call("trainableSegmentation.Weka_Segmentation.loadClassifier", classifiers_location + array_classifier_name[j]);
				call("trainableSegmentation.Weka_Segmentation.getProbability");
//				saveAs("Tiff", results_location+"/"+first_image_title+" - probability maps");
				run("Duplicate...", "title=Prob_map_Lusca duplicate");
				title_prob_map = getTitle();
				close(TWS);
				close("Probability maps");
			}
//morphological analysis without machine learning segmentation when already segmented image is provided
			else {
//opening segmented image
				list_segmented_images = getFileList(segmented_location_array[100+j]);
				fullpath_segmented_image = segmented_location_array[100+j] + list_segmented_images[i-1];
				open(fullpath_segmented_image);
				
//image properties setting
				if (Image_properties == 1) {
					run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
				}
				
//clear outside
				if (Clear_outside_overall == 1) {
					run("Invert", "stack");
					if (Image_dimension == "2D") {
						roiManager("Select", 0);
						setBackgroundColor(0, 0, 0);
						run("Clear Outside");
					}
					else {
						Stack.getDimensions(width, height, channels, slices, frames);
						slice_number = slices;
						for (c = 1; c < slice_number; c++) {
							setSlice(c);
							roiManager("Select", 0);
							setBackgroundColor(0, 0, 0);
							run("Clear Outside", "stack");
						}
					}
					run("Select None");
					run("Invert", "stack");
				}
				title_prob_map = getTitle();
			}
			
//loop for each class user selected to analyse
			for (k = 1; k <= array_number_images_probmap[j]; k++) {
				results_location = array_results_location[j*100+k];
				selectWindow(title_prob_map);
				n = array_probmap[j*100+k];
				setSlice(n); 
//2D images getting threshold mask image and area, number and intensity results with particle analysis
				if (Image_dimension == "2D") {
//intensity threshold application on probability map class
					run("Duplicate...", "use");
					setThreshold(array_image_quantification[10000+j*100+k], array_image_quantification[20000+j*100+k]);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					threshold_mask = getTitle();
//area and circularity threshold application on threshold binary image
					Min = array_image_quantification[30000+j*100+k];
					Max = array_image_quantification[40000+j*100+k];
					Circularity = array_image_quantification[50000+j*100+k];
//starting the measurements of area, number and intensity
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[90000+j*100+k] >= 1) {
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3");
//exclusion on the edges option
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display exclude summarize");
						}
						else {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display summarize");
						}
						saveAs("Tiff", results_location+"/"+first_image_title+" - origin image");
						origin_image = getTitle();
//						selectWindow("Results");
//						saveAs("Results", results_location+"/"+first_image_title+" - results of area, number and intensity.csv");
						close("Results");
						close(threshold_mask);
						selectWindow("Summary");
//saving result parameters into variables
						IJ.renameResults("Summary","Results");
						Count = getResult("Count", 0);
						Total_Area_Volume = getResult("Total Area", 0);
						Average_Size = getResult("Average Size", 0);
						Percentage_Area_Volume = getResult("%Area", 0);
						Mean = getResult("Mean", 0);
						Median = getResult("Median", 0);
						Mode = getResult("Mode", 0);
						Circ_Sph = getResult("Circ.", 0);
						close("Results");
						close(threshold_mask);
//						saveAs("Results", results_location+"/"+first_image_title+" - summary of area, number and intensity.csv");
//						close(first_image_title+" - summary of area, number and intensity.csv");
					}
//when no measurements of area, number and intensity are needed, just threshold mask image is obrained
					else {
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3");
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks");
						saveAs("Tiff", results_location+"/"+first_image_title+" - origin image");
						origin_image = getTitle();
					}
				}
//3D images getting threshold mask image and volume, number and intensity results with 3DOC
				else {
//intensity threshold application on probability map class
					run("Duplicate...", "duplicate channels=n");
					setThreshold(array_image_quantification[10000+j*100+k], array_image_quantification[20000+j*100+k]);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					threshold_mask = getTitle();
//volume and circularity threshold application on threshold binary image
					Min = array_image_quantification[30000+j*100+k];
					Max = array_image_quantification[40000+j*100+k];
					run("Duplicate...", "title=D duplicate");
					selectImage(threshold_mask);
					run("Set Scale...", "unit=unit");
					run("3D OC Options", "volume surface show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=D");
//exclusion on the edges option
					if (array_image_quantification[60000+j*100+k] == 1) {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges statistics");
					}
					else {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
					}
					table_name = "Statistics for " + threshold_mask + " redirect to D";
//volume, number and intensity measurements
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[90000+j*100+k] >= 1) {
//saving result parameters into variables
						IJ.renameResults(table_name,"Results");
						Count = nResults;
						Total_Surface = 0;
						for(sur=0; sur<nResults; sur++) {
							Total_Surface += getResult("Surface (unit^2)", sur);
						}
						close("Results");
						close(threshold_mask);
						close("D");
						saveAs("Tiff", results_location+"/"+first_image_title+" - origin image");
						origin_image = getTitle();
						run("Duplicate...", "title=D duplicate");
//more result values with stack statistics
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background", "stack");
						run("Subtract...", "value=255 stack");
						imageCalculator("Add create stack", "D","IMAGE");
//saving result parameters into variables
						run("Statistics");
						Total_Area_Volume = getResult("Volume(unit^3)", 0);
						Average_Size = Total_Area_Volume/Count;
						Percentage_Area_Volume = getResult("%Volume", 0);
						Mean = getResult("Mean", 0);
						Median = getResult("Median", 0);
						Mode = getResult("Mode", 0);
						Circ_Sph = (pow(36*3.1415*pow(Total_Area_Volume, 2), 1/3))/Total_Surface;
						close("Results");
						close("D");
						close("Result of D");
//						saveAs("Results", results_location+"/"+first_image_title+" - results of volume, number and intensity.csv");
//						close(first_image_title+" - results of volume, number and intensity.csv");
					}
//when no measurements of area, number and intensity are needed, just threshold mask image is obrained
					else {
						close("Statistics for threshold_mask");
						close(threshold_mask);
						close("D");
						close(table_name);
						saveAs("Tiff", results_location+"/"+first_image_title+" - origin image");
						origin_image = getTitle();
					}
				}


//neural porjections or length
				if (array_image_quantification[70000+j*100+k] + array_image_quantification[100000+j*100+k] >= 1) {
//threshold mask image is turned to skeletons
					selectWindow(origin_image);
					run("Duplicate...", "duplicate");
					run("Skeletonize (2D/3D)");
					skeleton = getTitle();
					run("Summarize Skeleton");
//saving result parameters into variables
					IJ.renameResults("Skeleton Stats","Results");
					Total_Length = getResult("Total length", 0);
					Max_Branch_Length = getResult("Max branch length", 0);
					Mean_Branch_Length = getResult("Mean branch length", 0);
					Number_Of_Branches = getResult("# Branches", 0);
					Number_Of_Junctions = getResult("# Junctions", 0);
					Number_Of_Endpoints = getResult("# End-points", 0);
					close("Results");
					close(skeleton);
//					saveAs("Results", results_location+"/"+first_image_title+" - skeleton summary.csv");
//					close(first_image_title+" - skeleton summary.csv");
//					run("Analyze Skeleton (2D/3D)", "prune=none show");
//					saveAs("Tiff", results_location+"/"+first_image_title+" - skeleton");
//					selectWindow("Branch information");
//					saveAs("Results", results_location+"/"+first_image_title+" - branch information.csv");
//					close(first_image_title+" - branch information.csv");
//					selectWindow("Results");
//					saveAs("Results", results_location+"/"+first_image_title+" - results from skeleton.csv");
//					close("Results");
				}


//neural projections or width
				if (array_image_quantification[70000+j*100+k] + array_image_quantification[110000+j*100+k] >= 1) {
//threshold mask image is duplicated twice
					selectWindow(origin_image);
					run("Duplicate...", "title=W1 duplicate");
					run("Duplicate...", "title=W2 duplicate");
//first duplicate is used to asses thickness of segments by Local Thickness
					selectWindow("W1");
					run("Local Thickness (masked, calibrated, silent)");
//					saveAs("Tiff", results_location+"/"+first_image_title+" - Local Thickness");
					W1 = getTitle();
//second duplicated is used to make skeletons
					selectWindow("W2");
					run("Skeletonize (2D/3D)");
					run("32-bit");
					setAutoThreshold("Default dark");
					setThreshold(1.00, 1e30);
					run("NaN Background", "stack");
					run("Subtract...", "value=255 stack");
					W2 = getTitle();
//the two images are added to obtain the width measurement of each length segment
					imageCalculator("Add create stack", W2, W1);
					selectWindow("Result of W2");
//					saveAs("Tiff", results_location+"/"+first_image_title+" - skeletons of Local Thickness");
					W_F = getTitle();
					run("Set Measurements...", "mean min median redirect=None decimal=3");
//saving result parameters into variables
					run("Statistics");
					Mean_width = getResult("Mean", 0);
					Median_width = getResult("Median", 0);
					Min_width = getResult("Min", 0);
					Max_width = getResult("Max", 0);
					close("Results");
					close("W1");
					close("W2");
					close(W1);
	
//list from histogram
					nBins = array_width[10000+j*100+k];
					histMin = array_width[20000+j*100+k];
					histMax = array_width[30000+j*100+k];
					run("Clear Results");
					row = 0;
					getDimensions(width, height, channels, slices, frames);
					n = slices;
//bin loop
					for (p=0; p<nBins; p++) {
						sum = 0;
//slices in the image loop
						for (r = 1; r <= n; r++) {
							setSlice(r);
							getHistogram(values, counts, nBins, histMin, histMax);
							sum += counts[p];
						}
				    	setResult("Value", row, values[p]);
    					setResult("Count", row, sum);
						row++;
					}
					updateResults();
					selectWindow("Results");
					saveAs("Results", results_location+"/"+first_image_title+" - histrogram list.csv");
					close("Results");
//histogram
					run("Histogram", "bins=nBins x_min=histMin x_max=histMax y_max=Auto stack");
					saveAs("Tiff", results_location+"/"+first_image_title+" - histogram");
					histogram = getTitle();
					close(histogram);
					close("Result of W2");
					W1 = "W1";
				}


//soma and nuclei
				if (array_image_quantification[80000+j*100+k] == 1) {
//opening nuclei image
//single images are opened from a selected folder
					if (Image_type == "Single image") {
						fullpath_DAPI_image = DAPI_image_location + DAPI_list_images[i-1];
						open(fullpath_DAPI_image);
						nuclei = getTitle();
						run("Duplicate...", "title=DAPI_IMAGE duplicate");
						close(nuclei);
					}
//channel images are opened by extracting them with duplication of a certain channel
					else {
						selectWindow(first_image_title);
						setSlice(nuclei_channel_number);
						n = nuclei_channel_number;
						run("Duplicate...", "title=DAPI_IMAGE duplicate channels=n");
					}
					
//image properties setting
					if (Image_properties == 1) {
						run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
					}
	
//clear outside
					if (Clear_outside_overall == 1) {
						if (Image_dimension == "2D") {
							roiManager("Select", 0);
							setBackgroundColor(0, 0, 0);
							run("Clear Outside");
						}
						else {
							Stack.getDimensions(width, height, channels, slices, frames);
							slice_number = slices;
							for (c = 1; c < slice_number; c++) {
								setSlice(c);
								roiManager("Select", 0);
								setBackgroundColor(0, 0, 0);
								run("Clear Outside", "stack");
							}
						}
					}
					run("Select None");
					
//soma and nuclei measurements along with image segmentation
					if (Lusca+Lusca_interactive == 1) {
//TWS
						if (Image_dimension == "2D") {	
							run("Trainable Weka Segmentation");
						}	
						else {
							run("Trainable Weka Segmentation 3D");
						}			
						wait(2000);
						TWS=getTitle();
						selectWindow(""+TWS+"");
						call("trainableSegmentation.Weka_Segmentation.loadClassifier", classifiers_location + array_DAPI[1]);
						call("trainableSegmentation.Weka_Segmentation.getProbability");
//						saveAs("Tiff", results_location+"/"+first_image_title+" - probability maps");
						close(TWS);
						setSlice(1);
					}
//soma and nuclei calculation with already segmented images imported from elsewhere
					else {
//opening segmented nuclei images
						list_segmented_images_dapi = getFileList(dapi_segmented_location);
						fullpath_segmented_image_dapi = dapi_segmented_location + list_segmented_images_dapi[i-1];
						open(fullpath_segmented_image_dapi);
			
//image properties setting
						if (Image_properties == 1) {
							run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
						}
				
//clear outside
						if (Clear_outside_overall == 1) {
							run("Invert", "stack");
							if (Image_dimension == "2D") {
								roiManager("Select", 0);
								setBackgroundColor(0, 0, 0);
								run("Clear Outside");
							}
							else {
								Stack.getDimensions(width, height, channels, slices, frames);
								slice_number = slices;
								for (c = 1; c < slice_number; c++) {
									setSlice(c);
									roiManager("Select", 0);
									setBackgroundColor(0, 0, 0);
									run("Clear Outside", "stack");
								}
							}
							run("Select None");
							run("Invert", "stack");
						}
					}
					
//2D nuclei images getting threshold mask image and area, number and intensity results with particle analysis
					if (Image_dimension == "2D") {
//intensity threshold application on probability map class
						run("Duplicate...", "use");
						setThreshold(array_DAPI[3], array_DAPI[4]);
						setOption("BlackBackground", true);
						run("Convert to Mask", "method=Default background=Dark black");
						threshold_mask_DAPI = getTitle();
//area and circularity threshold application on threshold binary image
						Min = array_DAPI[5];
						Max = array_DAPI[6];
						Circularity = array_DAPI[7];
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=DAPI_IMAGE decimal=3");
//exclusion on the edges option
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display exclude summarize");
						}
						else {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display summarize");
						}
						saveAs("Tiff", results_location+"/"+first_image_title+" - origin nuclei image");
						origin_DAPI_image = getTitle();
//						selectWindow("Results");
//						saveAs("Results", results_location+"/"+first_image_title+" - results of nuclei area and number.csv");
//						close("Results");
						selectWindow("Summary");
//						saving result parameters into variables
						IJ.renameResults("Summary","Results");
						Count_DAPI = getResult("Count", 0);
						Total_Area_Volume_DAPI = getResult("Total Area", 0);
						Average_Size_DAPI = getResult("Average Size", 0);
						Percentage_Area_Volume_DAPI = getResult("%Area", 0);
						Mean_DAPI = getResult("Mean", 0);
						Median_DAPI = getResult("Median", 0);
						Mode_DAPI = getResult("Mode", 0);
						Circ_Sph_DAPI = getResult("Circ.", 0);
						close("Results");
						close(threshold_mask_DAPI);
//						saveAs("Results", results_location+"/"+first_image_title+" - summary of nuclei area and number.csv");
//						close(first_image_title+" - summary of nuclei area and number.csv");
					}
//3D nuclei images getting threshold mask image and volume, number and intensity results with 3DOC
					else {
//intensity threshold application on probability map class
						run("Duplicate...", "duplicate channels=1");
						setThreshold(array_DAPI[3], array_DAPI[4]);
						setOption("BlackBackground", true);
						run("Convert to Mask", "method=Default background=Dark black");
						threshold_mask_DAPI = getTitle();
//volume and circularity threshold application on threshold binary image
						Min = array_DAPI[5];
						Max = array_DAPI[6];
						run("Duplicate...", "title=DAPI_D duplicate");
						selectImage(threshold_mask_DAPI);
						run("Set Scale...", "unit=unit");
						run("3D OC Options", "volume surface show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=DAPI_D");
//exclusion on the edges option
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges statistics");
						}
						else {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
						}
//saving result parameters into variables
						table_name_DAPI = "Statistics for " + threshold_mask_DAPI + " redirect to DAPI_D";
						IJ.renameResults(table_name_DAPI,"Results");
						Count_DAPI = nResults;
						Total_Surface_DAPI = 0;
						for(sur_d=0; sur_d<nResults; sur_d++) {
							Total_Surface_DAPI += getResult("Surface (unit^2)", sur_d);
						}
						close("Results");
						close(threshold_mask_DAPI);
						close("DAPI_D");
						saveAs("Tiff", results_location+"/"+first_image_title+" - origin nuclei image");
						origin_DAPI_image = getTitle();
						run("Duplicate...", "title=DAPI_D duplicate");
//obtaining more result values with stack statistics
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background", "stack");
						run("Subtract...", "value=255 stack");
						imageCalculator("Add create stack", "DAPI_D","DAPI_IMAGE");
						intenzity_mask_DAPI = getTitle();
//saving result parameters into variables
						run("Statistics");
						Total_Area_Volume_DAPI = getResult("Volume(unit^3)", 0);
						Average_Size_DAPI = Total_Area_Volume_DAPI/Count_DAPI;
						Percentage_Area_Volume_DAPI = getResult("%Volume", 0);
						Mean_DAPI = getResult("Mean", 0);
						Median_DAPI = getResult("Median", 0);
						Mode_DAPI = getResult("Mode", 0);
						Circ_Sph_DAPI = (pow(36*3.1415*pow(Total_Area_Volume_DAPI, 2), 1/3))/Total_Surface_DAPI;
						close("Results");
						close("DAPI_D");
						close(intenzity_mask_DAPI);
//						saveAs("Results", results_location+"/"+first_image_title+" - results of volume, number and intensity.csv");
//						close(first_image_title+" - results of volume, number and intensity.csv");
					}
					close("Probability maps");
					close("DAPI_IMAGE");
				
//image calculator
					run("Options...", "iterations=3 count=1 black do=Erode stack");
					origin_DAPI_image = getTitle();
					imageCalculator("AND create stack", origin_image,origin_DAPI_image);
					threshold_mask_soma = getTitle();

//2D soma images area, number and intensity results with particle analysis
					if (Image_dimension == "2D") {
						Min = array_image_quantification[30000+j*100+k];
						Max = array_image_quantification[40000+j*100+k];
						Circularity = array_image_quantification[50000+j*100+k];
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3");
//exclusion on the edges option
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display exclude summarize");
						}
						else {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display summarize");
						}
						saveAs("Tiff", results_location+"/"+first_image_title+" - final soma image");
						origin_soma_image = getTitle();
//						selectWindow("Results");
//						saveAs("Results", results_location+"/"+first_image_title+" - results of soma area and number.csv");
						close("Results");
						close(threshold_mask_soma);
						selectWindow("Summary");
//						saving result parameters into variables
						IJ.renameResults("Summary","Results");
						Count_soma = getResult("Count", 0);
						Total_Area_Volume_soma = getResult("Total Area", 0);
						Average_Size_soma = getResult("Average Size", 0);
						Percentage_Area_Volume_soma = getResult("%Area", 0);
						Mean_soma = getResult("Mean", 0);
						Median_soma = getResult("Median", 0);
						Mode_soma = getResult("Mode", 0);
						Circ_Sph_soma = getResult("Circ.", 0);
						close("Results");
//						saveAs("Results", results_location+"/"+first_image_title+" - summary of soma area and number.csv");
//						close(first_image_title+" - summary of soma area and number.csv");				
					}
//3D soma images volume, number and intensity results with particle analysis
					else {
						Min = array_image_quantification[30000+j*100+k];
						Max = array_image_quantification[40000+j*100+k];
						run("Duplicate...", "title=soma_D duplicate");
						selectImage(threshold_mask_soma);
						run("Set Scale...", "unit=unit");
						run("3D OC Options", "volume surface show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=soma_D");
//exclusion on the edges option
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges statistics");
						}
						else {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
						}
//saving result parameters into variables
						table_name_soma = "Statistics for " + threshold_mask_soma + " redirect to soma_D";
						IJ.renameResults(table_name_soma,"Results");
						Count_soma = nResults;
						Total_Surface_soma = 0;
						for(sur_s=0; sur_s<nResults; sur_s++) {
							Total_Surface_soma += getResult("Surface (unit^2)", sur_s);
						}
						close("Results");
						close(threshold_mask_soma);
						close("soma_D");
						saveAs("Tiff", results_location+"/"+first_image_title+" - final soma image");
						origin_soma_image = getTitle();
						run("Duplicate...", "title=soma_D duplicate");
//obtaining more result values with stack statistics
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background", "stack");
						run("Subtract...", "value=255 stack");
						imageCalculator("Add create stack", "soma_D","IMAGE");
						intenzity_mask_soma = getTitle();
//saving result parameters into variables
						run("Statistics");
						Total_Area_Volume_soma = getResult("Volume(unit^3)", 0);
						Average_Size_soma = Total_Area_Volume_soma/Count_soma;
						Percentage_Area_Volume_soma = getResult("%Volume", 0);
						Mean_soma = getResult("Mean", 0);
						Median_soma = getResult("Median", 0);
						Mode_soma = getResult("Mode", 0);
						Circ_Sph_soma = (pow(36*3.1415*pow(Total_Area_Volume_soma, 2), 1/3))/Total_Surface_soma;
						close("Results");
						close("soma_D");
						close(intenzity_mask_soma);
//						saveAs("Results", results_location+"/"+first_image_title+" - results of volume, number and intensity.csv");
//						close(first_image_title+" - results of volume, number and intensity.csv");
					}
					close(origin_DAPI_image);
					close(origin_soma_image);
				}


//colocalization class
				if (array_image_quantification[120000+j*100+k]) {
//calculations of area (2D)/volume (3D) needed for the Manders coefficient 1 and 2 
					selectWindow(origin_image);
					if (Image_dimension == "2D") {
						run("Set Measurements...", "area redirect=None decimal=3");
						run("Analyze Particles...", "summarize");
						IJ.renameResults("Summary","Results");
						Area_Volume_Segmented_A = getResult("Total Area", 0);
						close("Results");
					}
					else {
						run("Set Scale...", "unit=unit");
						run("3D OC Options", "volume dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
						run("3D Objects Counter", "threshold=1 slice=1 min.=0 max.=9999999999999999999999999 statistics");
						table_name_coloc = "Statistics for " + origin_image;
						IJ.renameResults(table_name_coloc,"Results");
						Area_Volume_Segmented_A = 0;
						for(vol_a=0; vol_a<nResults; vol_a++) {
							Area_Volume_Segmented_A += getResult("Volume (unit^3)", vol_a);
						}
						close("Results");
					}

//colocalization loop
					for (cc = 1; cc <= Colocalization_class_number; cc++) {
//colocalization measurements along with image segmentation
						if (Lusca+Lusca_interactive == 1) {
//opening second colocalization image
//single images are opened from a selected folder
							if (Image_type == "Single image") {
								Colocalization_list_images = getFileList(array_colocalization_image_location[100+cc]);
								fullpath_Colocalization_image = array_colocalization_image_location[100+cc] + Colocalization_list_images[i-1];
								open(fullpath_Colocalization_image);
							}
//channel images are opened by extracting them with duplication of a certain channel
							else {
								selectWindow(first_image_title);
								n = array_colocalization_channel_number[100+cc];
								setSlice(n);
								run("Duplicate...", "duplicate channels=n");
							}

//image properties setting
							if (Image_properties == 1) {
								run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
							}
	
//clear outside
							if (Clear_outside_overall == 1) {
								if (Image_dimension == "2D") {
									roiManager("Select", 0);
									setBackgroundColor(0, 0, 0);
									run("Clear Outside");
								}
								else {
									Stack.getDimensions(width, height, channels, slices, frames);
									slice_number = slices;
									for (c = 1; c < slice_number; c++) {
										setSlice(c);
										roiManager("Select", 0);
										setBackgroundColor(0, 0, 0);
										run("Clear Outside", "stack");
									}
								}
							}
							run("Select None");
							title_Colocalization_intensity = getTitle();
	
//TWS
							if (Image_dimension == "2D") {	
								run("Trainable Weka Segmentation");
							}	
							else {
								run("Trainable Weka Segmentation 3D");
							}
							wait(2000);
							TWS=getTitle();
							selectWindow(""+TWS+"");
							call("trainableSegmentation.Weka_Segmentation.loadClassifier", classifiers_location + array_colocalization_class[cc*1000+1]);
							call("trainableSegmentation.Weka_Segmentation.getProbability");
//							saveAs("Tiff", results_location+"/"+first_image_title+" - probability maps");
							close(TWS);
							n = array_colocalization_class[cc*1000+2];
							setSlice(n);
						}
//colocalization calculation with already segmented images imported from elsewhere
						else {
//opening the segmented second colocalization image
							list_segmented_images_coloc = getFileList(array_colocalization_image_location[100+cc]);
							fullpath_segmented_image_coloc = array_colocalization_image_location[100+cc] + list_segmented_images_coloc[i-1];
							open(fullpath_segmented_image_coloc);
							title_Colocalization_intensity = getTitle();

//image properties setting
							if (Image_properties == 1) {
								run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
							}
				
//clear outside
							if (Clear_outside_overall == 1) {
								run("Invert", "stack");
								if (Image_dimension == "2D") {
									roiManager("Select", 0);
									setBackgroundColor(0, 0, 0);
									run("Clear Outside");
								}
								else {
									Stack.getDimensions(width, height, channels, slices, frames);
									slice_number = slices;
									for (c = 1; c < slice_number; c++) {
										setSlice(c);
										roiManager("Select", 0);
										setBackgroundColor(0, 0, 0);
										run("Clear Outside", "stack");
									}
								}
								run("Select None");
								run("Invert", "stack");
							}
						}
						
//2D colocalization images getting threshold mask image and area, number and intensity results with particle analysis
						if (Image_dimension == "2D") {
//intensity threshold application on probability map class
							run("Duplicate...", "use");
							setThreshold(array_colocalization_class[cc*1000+3], array_colocalization_class[cc*1000+4]);
							setOption("BlackBackground", true);
							run("Convert to Mask", "method=Default background=Dark black");
							threshold_mask_coloc = getTitle();
//area and circularity threshold application on threshold binary image
							Min = array_colocalization_class[cc*1000+5];
							Max = array_colocalization_class[cc*1000+6];
							Circularity = array_colocalization_class[cc*1000+7];
							run("Set Measurements...", "area redirect=None decimal=3");
//exclusion on the edges option
							if (array_image_quantification[60000+j*100+k] == 1) {
								run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks exclude summarize");
							}
							else {
								run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks summarize");
							}
							IJ.renameResults("Summary","Results");
							Area_Volume_Segmented_B = getResult("Total Area", 0);
							close("Results");
							close(threshold_mask_coloc);
						}
//3D colocalization images getting threshold mask image and volume, number and intensity results with 3DOC
						else {
//intensity threshold application on probability map class
							run("Duplicate...", "duplicate channels=n");
							setThreshold(array_colocalization_class[cc*1000+3], array_colocalization_class[cc*1000+4]);
							setOption("BlackBackground", true);
							run("Convert to Mask", "method=Default background=Dark black");
							threshold_mask_coloc = getTitle();						
//volume and circularity threshold application on threshold binary image
							Min = array_colocalization_class[cc*1000+5];
							Max = array_colocalization_class[cc*1000+6];
							Colocalization_title = getTitle();
							run("Duplicate...", "title=duplicate_COLOC duplicate");
							selectWindow(threshold_mask_coloc);
							run("Set Scale...", "unit=unit");
							run("3D OC Options", "volume show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate_COLOC");
//exclusion on the edges option
							if (array_image_quantification[60000+j*100+k] == 1) {
								run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges statistics");
							}
							else {
								run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
							}
							close("duplicate_COLOC");
							close(threshold_mask_coloc);
							
							table_name_coloc = "Statistics for " + threshold_mask_coloc + " redirect to duplicate_COLOC";
							IJ.renameResults(table_name_coloc,"Results");
							Area_Volume_Segmented_B = 0;
							for(vol_b=0; vol_b<nResults; vol_b++) {
								Area_Volume_Segmented_B += getResult("Volume (unit^3)", vol_b);
							}
							close("Results");
						}
						close("Probability maps");
						
//calculation of the pixels that correlate on both images by applying bolean operator "AND"
						origin_image_B = getTitle();
						imageCalculator("AND create stack", origin_image,origin_image_B);
						origin_image_C = getTitle();
//calculating the area (2D)/volume (3D) that correlates on both images, needed for the Manders coefficient 1 and 2 
						if (Image_dimension == "2D") {
							run("Set Measurements...", "area redirect=None decimal=3");
							run("Analyze Particles...", "summarize");
							IJ.renameResults("Summary","Results");
							Area_Volume_Segmented_C = getResult("Total Area", 0);
							close("Results");
						}
						else {
							run("Set Scale...", "unit=unit");
							run("3D OC Options", "volume dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
							run("3D Objects Counter", "threshold=1 slice=1 min.=0 max.=9999999999999999999999999 statistics");
							table_name_coloc = "Statistics for " + origin_image_C;
							IJ.renameResults(table_name_coloc,"Results");
							Area_Volume_Segmented_C = 0;
							for(vol_c=0; vol_c<nResults; vol_c++) {
								Area_Volume_Segmented_C += getResult("Volume (unit^3)", vol_c);
							}
							close("Results");
						}
						
//calculting the Manders coefficient 1 and 2 with the obtained area (2D)/volume (3D) values
						sM1 = Area_Volume_Segmented_C/Area_Volume_Segmented_A;
						sM2 = Area_Volume_Segmented_C/Area_Volume_Segmented_B;
						
//formation of the "Colocalization measurements" result table. The results table is renamed for easier diferentiation from other result tables that open during the analysis
						if (counter_col !=0) {
							IJ.renameResults("Colocalization measurements", "Results");
						}
						setResult("First image", counter_col, first_image_title);
						setResult("Second image", counter_col, title_Colocalization_intensity);
						setResult("segmented M1", counter_col, sM1);
						setResult("segmented M2", counter_col, sM2);
						updateResults();
//name change of the table so that the result tables do not get mixed
						IJ.renameResults("Results","Colocalization measurements");
//closing images from colocaliation analysis and adding plus 1 to counter for next analysis
						counter_col += 1;
						close(title_Colocalization_intensity);
						close(origin_image_B);
						close(origin_image_C);
					}
				}
				
				
//formation of the results table, for each morphological group of parameters the results are added to the "Results" table. The table is renamed to "All measurements" for easier diferentiation from other result tables that open during the analysis
				if (array_image_quantification[70000+j*100+k]+array_image_quantification[80000+j*100+k]+array_image_quantification[90000+j*100+k]+array_image_quantification[100000+j*100+k]+array_image_quantification[110000+j*100+k] >= 1) {
					if (counter != 0) {
						IJ.renameResults("All measurements","Results");
					}
//image information
					counter += 1;
					setResult("No", counter-1, counter);
					setResult("Image", counter-1, first_image_title);
					setResult("Channel number", counter-1, array_channel_number_to_analyse[j]);
					setResult("Probability map class", counter-1, array_probmap[j*100+k]);
//area/volume, number and intensity results
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[90000+j*100+k] >= 1) {
						setResult("Count", counter-1, Count);
						setResult("Total Area/Volume", counter-1, Total_Area_Volume);
						if (Image_dimension == "3D") {
						setResult("Total Surface", counter-1, Total_Surface);
						}
						setResult("Average Area/Volume", counter-1, Average_Size);
						setResult("Percentage Area/Volume", counter-1, Percentage_Area_Volume);
						setResult("Mean Intensity", counter-1, Mean);
						setResult("Median Intensity", counter-1, Median);
						setResult("Mode Intensity", counter-1, Mode);
						setResult("Circularity/Sphericity", counter-1, Circ_Sph);
					}
//soma and nuclei results
					if (array_image_quantification[80000+j*100+k] == 1) {
						setResult("Soma Count", counter-1, Count_soma);
						setResult("Soma Total Area/Volume", counter-1, Total_Area_Volume_soma);
						if (Image_dimension == "3D") {
							setResult("Soma Total Surface", counter-1, Total_Surface_soma);
						}
						setResult("Soma Average Area/Volume", counter-1, Average_Size_soma);
						setResult("Soma Percentage Area/Volume", counter-1, Percentage_Area_Volume_soma);
						setResult("Soma Mean Intensity", counter-1, Mean_soma);
						setResult("Soma Median Intensity", counter-1, Median_soma);
						setResult("Soma Mode Intensity", counter-1, Mode_soma);
						setResult("Soma Circularity/Sphericity", counter-1, Circ_Sph_soma);
						setResult("Nuclei Count", counter-1, Count_DAPI);
						setResult("Nuclei Total Area/Volume", counter-1, Total_Area_Volume_DAPI);
						if (Image_dimension == "3D") {
							setResult("Nuclei Total Surface", counter-1, Total_Surface_DAPI);
						}
						setResult("Nuclei Average Area/Volume", counter-1, Average_Size_DAPI);
						setResult("Nuclei Percentage Area/Volume", counter-1, Percentage_Area_Volume_DAPI);
						setResult("Nuclei Mean Intensity", counter-1, Mean_DAPI);
						setResult("Nuclei Median Intensity", counter-1, Median_DAPI);
						setResult("Nuclei Mode Intensity", counter-1, Mode_DAPI);
						setResult("Nuclei Circularity/Sphericity", counter-1, Circ_Sph_DAPI);
					}
//length and branching results
					if (array_image_quantification[70000+j*100+k] + array_image_quantification[100000+j*100+k] >= 1) {
						setResult("Total length", counter-1, Total_Length);
						setResult("Max branch length", counter-1, Max_Branch_Length);
						setResult("Mean branch length", counter-1, Mean_Branch_Length);
						setResult("Number of branches", counter-1, Number_Of_Branches);
						setResult("Number of junctions", counter-1, Number_Of_Junctions);
						setResult("Number of endpoints", counter-1, Number_Of_Endpoints);
					}
//width results
					if (array_image_quantification[70000+j*100+k] + array_image_quantification[110000+j*100+k] >= 1) {
						setResult("Mean width", counter-1, Mean_width);
						setResult("Median width", counter-1, Median_width);
						setResult("Max width", counter-1, Min_width);
						setResult("Min width", counter-1, Max_width);
					}
//name change of the table so that the result tables do not get mixed
					updateResults();
					IJ.renameResults("Results","All measurements");
				}
//closing segmentated image
				close(origin_image);
			}
//closing Probability maps after the loop for analyssing needed classes from Probability maps ended
			close("Prob_map_Lusca");
			close("IMAGE");
		}
	}
//closing all images so that the next image analysis can start or before the end of the analysis
	close("*");
}

//saving the results table for colocalization measurements
if (counter_col >= 1) {
	IJ.renameResults("Colocalization measurements", "Results");
	saveAs("Results", image_location+"/"+"Colocalization results.csv");
	close("Colocalization results");
	close("Results");
	close("ROI Manager");
	close("Log");
}
//saving the results table for morphology measurements
if (counter >= 1) {
	IJ.renameResults("All measurements","Results");
	saveAs("Results", image_location+"/"+"Results.csv");
	close("Results");
	close("ROI Manager");
	close("Log");
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////