/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   
//   Lusca - ImageJ/Fiji-based plugin for automated morphological analysis of neurons and other biological structures
//
//   Author: Iva Simunic
//   Contact - e-mail: iva.simunic25@gmail.com
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//array list
setOption("ExpandableArrays", true);
array_image_type = newArray("Single image", "Channel image");
array_image_dimension = newArray("2D", "3D");
array_channel_number_to_analyse = newArray;
array_channel_name = newArray;
array_colocalization = newArray;

array_classifier_name = newArray;
array_classifer_location = newArray;
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

//image location
waitForUser("Choose the folder where the images are placed")
image_location = getDirectory("Choose the folder where the images are placed");
list_images = getFileList(image_location);


//image type selection
Dialog.create("Image type selection");
Dialog.addMessage("Please select the parameters for image analysis");
Dialog.addMessage(" ");
Dialog.addChoice("Image type:", array_image_type);
Dialog.addChoice("             Image dimension:", array_image_dimension);
Dialog.show();
Image_type = Dialog.getChoice();
Image_dimension = Dialog.getChoice();


if (Image_type == "Channel image") {
	Dialog.create("Channel data");
	Dialog.addNumber("How many channels would you like to analyse?", "1");
	Dialog.show();
	Channel_number = Dialog.getNumber();
	
	for (i = 1; i <= Channel_number; i++) {
		Dialog.create("Channel for analysis");
		Dialog.addNumber("Which channel would you like to analyse?", "1");
		Dialog.addString("What is the name of this channel?", "");
		Dialog.show();
		Channel_for_analysis = Dialog.getNumber();
		Channel_name = Dialog.getString();
		array_channel_number_to_analyse[i] = Channel_for_analysis;
		array_channel_name[i] = Channel_name;
	}
}

else {
	Channel_number = 1;
	array_channel_number_to_analyse[1] = "1";
	array_channel_name[1] = "Results";
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//INPUT PARAMETERS AND TUTORIAL SECTION

//image properties setting
Image_properties = getBoolean("Do you need to set image properties?");

if (Image_properties == 1) {
	Dialog.create("Image properties");
	Dialog.addNumber("Pixel width:", "1");
	Dialog.addNumber("Pixel heith:", "1");
	Dialog.addNumber("Voxel depth:", "1");
	Dialog.show();
	x = Dialog.getNumber();
	y = Dialog.getNumber();
	z = Dialog.getNumber();
}
	
else {
}


//clear outside
Clear_outside_overall = getBoolean("Do you need to analyse just one part of the image/images?");

if (Clear_outside_overall == 1) {
	for (i = 1; i <= Channel_number; i++) {
		Clear_outside = getBoolean("Do you need to analyse just one part of the image/images?");

		if (Image_type == "Channel image") {	
			if (Clear_outside == 1) {
				fullpath_image = image_location + list_images[0];
				open(fullpath_image);
				n = array_channel_number_to_analyse[i];
				setSlice(n);
				run("Duplicate...", "duplicate channels=n");
				setTool("rectangle");
				waitForUser("Please select the area of the image you want to analyse");
				run("ROI Manager...");
				roiManager("Add");
				roiManager("Save", image_location+"ROI.zip");
				if (Image_dimension == "2D") {
					setBackgroundColor(0, 0, 0);
					run("Clear Outside");
				}
				else {
					Stack.getDimensions(width, height, channels, slices, frames);
					slice_number = slices;
					for (j = 1; j < slice_number; j++) {
						setSlice(j);
						roiManager("Select", i-1);
						setBackgroundColor(0, 0, 0);
						run("Clear Outside", "stack");
					}
				}
			}

			else {
				fullpath_image = image_location + list_images[0];
				open(fullpath_image);
				n = array_channel_number_to_analyse[i];
				setSlice(n);
				run("Duplicate...", "duplicate channels=n");
				run("Select All");
				roiManager("Add");
				roiManager("Save", image_location+"ROI.zip");
			}
		}
	
		else {
			if (Clear_outside == 1) {
				fullpath_image = image_location + list_images[0];
				open(fullpath_image);
				n = array_channel_number_to_analyse[i];
				setSlice(n);
				run("Duplicate...", "duplicate channels=n");
				setTool("rectangle");
				waitForUser("Please select the area of the image you want to analyse");
				run("ROI Manager...");
				roiManager("Add");
				roiManager("Save", image_location+"ROI.zip");
				if (Image_dimension == "2D") {
					setBackgroundColor(0, 0, 0);
					run("Clear Outside");
				}
				else {
					Stack.getDimensions(width, height, channels, slices, frames);
					slice_number = slices;
					for (j = 1; j < slice_number; j++) {
						setSlice(j);
						roiManager("Select", i-1);
						setBackgroundColor(0, 0, 0);
						run("Clear Outside", "stack");
					}
				}
			}

			else {	
			}
		}		
	}
}

else {
}


//colocalization
Colocalization = getBoolean("Would you like to do colocalization measurements on your images?");

if (Colocalization == 1) {			
	for (i = 1; i <= Channel_number; i++) {	
		if (Image_type == "Channel image") {	
			Dialog.create("Colocalization");
			Dialog.addNumber("Number of first channel image for colocalization:", "");
			Dialog.addNumber("Number of second channel image for colocalization:", "");
			Dialog.show();
			First_colocalization = Dialog.getNumber();
			Second_colocalization = Dialog.getNumber();
			array_colocalization[3*100+i] = First_colocalization;
			array_colocalization[4*100+i] = Second_colocalization;
			
			fullpath_image = image_location + list_images[0];
			open(fullpath_image);
			colocalization_title = getTitle();
			setSlice(First_colocalization);
			//threshold part
			run("Threshold...");
			waitForUser("Press OK when you found the right threshold");
			Dialog.create("Threshold");
			Dialog.addNumber("Maximum value You chose for colocalization threshold:", "");
			Dialog.show();
			Max_colocalization_threshold = Dialog.getNumber();
			array_colocalization[1*100+i] = Max_colocalization_threshold;
			
			selectWindow(colocalization_title);
			setSlice(Second_colocalization);
			//threshold part
			run("Threshold...");
			waitForUser("Press OK when you found the right threshold");
			Dialog.create("Threshold");
			Dialog.addNumber("Maximum value You chose for colocalization threshold:", "");
			Dialog.show();
			Max_colocalization_threshold = Dialog.getNumber();
			array_colocalization[2*100+i] = Max_colocalization_threshold;
		}

		else {	
			waitForUser("Select the folder where first images for colocalization are placed");
			First_colocalization_image_location = getDirectory("Choose the folder where the images are placed");
			First_colocalization_list_images = getFileList(First_colocalization_image_location);
			fullpath_first_image = First_colocalization_image_location + First_colocalization_list_images[0];
			open(fullpath_first_image);
			//threshold part
			run("Threshold...");
			waitForUser("Press OK when you found the right threshold");
			Dialog.create("Threshold");
			Dialog.addNumber("Maximum value You chose for colocalization threshold:", "");
			Dialog.show();
			Max_colocalization_threshold = Dialog.getNumber();
			array_colocalization[1*100+i] = Max_colocalization_threshold;
			
			waitForUser("Select the folder where second images for colocalization are placed");
			Second_colocalization_image_location = getDirectory("Choose the folder where the images are placed");
			Second_colocalization_list_images = getFileList(Second_colocalization_image_location);
			fullpath_second_image = Second_colocalization_image_location + Second_colocalization_list_images[0];
			open(fullpath_second_image);
			//threshold part
			run("Threshold...");
			waitForUser("Press OK when you found the right threshold");
			Dialog.create("Threshold");
			Dialog.addNumber("Maximum value You chose for colocalization threshold:", "");
			Dialog.show();
			Max_colocalization_threshold = Dialog.getNumber();
			array_colocalization[2*100+i] = Max_colocalization_threshold;
		}
		results_colocalization = image_location + "Channel_" + array_channel_name[i] + " - colocalization";
		File.makeDirectory(results_colocalization);
		array_colocalization[5*100+i] = results_colocalization;
		close("*");	
	}
}

else {
}

Continue_Lusca = getBoolean("Would you like to do more quantifications?");

if (Continue_Lusca == 1) {

	for (i = 1; i <= Channel_number; i++) {
		//tutorial option
		tutorial = getBoolean("Do you have needed data for the analysis?");

		if (tutorial == 0) {
			fullpath_image = image_location + list_images[0];
			open(fullpath_image);
			first_image = getTitle();
			n = array_channel_number_to_analyse[i];
			setSlice(n);
			run("Duplicate...", "duplicate channels=n");
			original_image = getTitle();
		
			if (Image_dimension == "2D") {
				//Trainable Weka Segmentation - classifier formation and saving
				waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
				
				run("Trainable Weka Segmentation");
				wait(2000);
				TWS=getTitle();
				selectWindow(""+TWS+"");
			
				waitForUser("When you have finished making and saving your classifier press OK");

				//classifier name
				Dialog.create("Classifier");
				Dialog.addString("Classifier name:", "");
				Dialog.show();
				Classifier_name = Dialog.getString();
				array_classifier_name[i] = Classifier_name;

				//classifier location
				waitForUser("Choose the folder where classifier is placed");
				Classifier_location = getDirectory("Choose the folder where classifier is placed");
				array_classifer_location[i] = Classifier_location;
			
				//Probability maps - information																
				call("trainableSegmentation.Weka_Segmentation.getProbability");
			
				Dialog.create("Probability maps data");
				Dialog.addNumber("How many classes (image segments) would you like to analyse?", "2");
				Dialog.show();
				Number_images_probmap = Dialog.getNumber();
				array_number_images_probmap[i] = Number_images_probmap;

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					Dialog.create("Probability maps data");
					Dialog.addNumber("Which class (image segment) do You want to analyse?", "1");
					Dialog.addString("Whats the name of the segment for analysis", "");
					Dialog.show();
					number = Dialog.getNumber();
					name = Dialog.getString();
					array_probmap[i*100+j] = number;
					array_probmap_name[i*100+j] = name;
					print(array_probmap[i*100+j]);
				}

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					//formation of the "Results" folder
					results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
					File.makeDirectory(results_location_probmap);
					array_results_location[i*100+j] = results_location_probmap;

					//threshold setting
					selectWindow("Probability maps");
					n = array_probmap[i*100+j];
					setSlice(n);
					run("Duplicate...", "use");
					image = getTitle();
			
					run("Threshold...");
					waitForUser("Press OK when you found the right threshold");
					Dialog.create("Threshold");
					Dialog.addNumber("Minimun value You chose for threshold:", "");
					Dialog.addNumber("Maximum value You chose for threshold:", "");
					Dialog.show();
					Min_threshold = Dialog.getNumber();
					Max_threshold = Dialog.getNumber();
					array_image_quantification[10000+i*100+j] = Min_threshold;
					array_image_quantification[20000+i*100+j] = Max_threshold;

					//min and max object setting
					selectWindow(image);
					setThreshold(Min_threshold, Max_threshold);
					run("Convert to Mask");
					image = getTitle();
					particle_set = getBoolean("Do you have min and max particle dimension?");
	
					while (particle_set == 0) {
						selectWindow(image);
						run("Duplicate...", "duplicate");
						Dialog.create("Area");
						Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
						Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
						Dialog.show();
						Min_particle = Dialog.getNumber();
						Max_particle = Dialog.getNumber();
						Min = Min_particle;
						Max = Max_particle;
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
						run("Analyze Particles...", "size=Min-Max show=Masks");
						waitForUser("Please check the masked image for the result and press 'OK' when done");
						particle_set = getBoolean("Do you have min and max particle dimension?");
					}

					Dialog.create("Area");
					Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
					Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
					Dialog.show();
					Min_particle = Dialog.getNumber();
					Max_particle = Dialog.getNumber();

					array_image_quantification[30000+i*100+j] = Min_particle;
					array_image_quantification[40000+i*100+j] = Max_particle;

					//type of quantification
					Dialog.create("Image quantification");
					Dialog.addMessage("Select the type of quantification for the image");
					Dialog.addCheckbox("	Neural projections", false);
					Dialog.addCheckbox("	Soma and nuclei", false);
					Dialog.addCheckbox("	Area, Number and Intensity",false);
					Dialog.addCheckbox("	Length", false);
					Dialog.addCheckbox("	Width", false);
					Dialog.addCheckbox("	Colocalization with classes", false);
					Dialog.show();
					Neural_projections = Dialog.getCheckbox();
					Soma_and_nuclei = Dialog.getCheckbox();
					Area_Number_Intensity = Dialog.getCheckbox(); 
					Length = Dialog.getCheckbox();
					Width = Dialog.getCheckbox();
					Colocalization_class = Dialog.getCheckbox();

					array_image_quantification[50000+i*100+j] = Neural_projections;
					array_image_quantification[60000+i*100+j] = Soma_and_nuclei;
					array_image_quantification[70000+i*100+j] = Area_Number_Intensity;
					array_image_quantification[80000+i*100+j] = Length;
					array_image_quantification[90000+i*100+j] = Width;
					array_image_quantification[1000000+i*100+j] = Colocalization_class;
				
					if (Soma_and_nuclei == 1) {
						close(TWS);
						if (Image_type == "Single image") {
							waitForUser("Please choose the folder where the images of nuclei are placed");
							DAPI_image_location = getDirectory("Choose the folder where the images are placed");
							DAPI_list_images = getFileList(DAPI_image_location);
							fullpath_DAPI_image = DAPI_image_location + DAPI_list_images[0];
							open(fullpath_DAPI_image);
						}
					
						else {
							Dialog.create("Nuclei channel");
							Dialog.addNumber("Nuclei channel", "");
							Dialog.show();
							nuclei_channel_number = Dialog.getNumber();
							selectWindow(first_image);
							setSlice(nuclei_channel_number);
							run("Duplicate...", "duplicate");
						}

						//Trainable Weka Segmentation - classifier formation and saving
						waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
					
						run("Trainable Weka Segmentation");
						wait(2000);
						TWS=getTitle();
						selectWindow(""+TWS+"");
						call("trainableSegmentation.Weka_Segmentation.changeClassName", "0", "Nuclei");
						call("trainableSegmentation.Weka_Segmentation.changeClassName", "1", "Background");
		
						waitForUser("When you have finished making and saving your classifier press OK");

						//classifier name
						Dialog.create("Classifier");
						Dialog.addString("Classifier name:", "");
						Dialog.show();
						Classifier_name = Dialog.getString();
						array_DAPI[1] = Classifier_name;

						//classifier location
						waitForUser("Choose the folder where classifier is placed");
						Classifier_location = getDirectory("Choose the folder where classifier is placed");
						array_DAPI[2] = Classifier_location;
			
						//Probability maps - information																
						call("trainableSegmentation.Weka_Segmentation.getProbability");

						//threshold setting
						setSlice(1);
						run("Duplicate...", "use");
						DAPI_image = getTitle();
			
						run("Threshold...");
						waitForUser("Press OK when you found the right threshold");
						Dialog.create("Threshold");
						Dialog.addNumber("Minimun value You chose for threshold:", "");
						Dialog.addNumber("Maximum value You chose for threshold:", "");
						Dialog.show();
						Min_threshold = Dialog.getNumber();
						Max_threshold = Dialog.getNumber();
						array_DAPI[3] = Min_threshold;
						array_DAPI[4] = Max_threshold;

						//min and max object setting
						selectWindow(image);
						setThreshold(Min_threshold, Max_threshold);
						run("Convert to Mask");
						DAPI_image = getTitle();
						particle_set = getBoolean("Do you have min and max particle dimension?");
		
						while (particle_set == 0) {
							selectWindow(image);
							run("Duplicate...", "duplicate");
							Dialog.create("Area");
							Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
							Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
							Dialog.show();
							Min_particle = Dialog.getNumber();
							Max_particle = Dialog.getNumber();
							Min = Min_particle;
							Max = Max_particle;
							run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
							run("Analyze Particles...", "size=Min-Max show=Masks");
							waitForUser("Please check the masked image for the result and press 'OK' when done");
							particle_set = getBoolean("Do you have min and max particle dimension?");
						}

						Dialog.create("Area");
						Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
						Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
						Dialog.show();
						Min_particle = Dialog.getNumber();
						Max_particle = Dialog.getNumber();

						array_DAPI[5] = Min_particle;
						array_DAPI[6] = Max_particle;
					}
				
					else {
					}
					
					if (Colocalization_class == 1) {
						close(TWS);
						Dialog.create("Segments for colocalization");
						Dialog.addNumber("Number of colocalization analysis with this segment as the first image:", "");
						Dialog.show();
						Colocalization_class_number = Dialog.getNumber();
						
						for (cs = 1; cs <= Colocalization_class_number; cs++) {
							if (Image_type == "Single image") {
								waitForUser("Please choose the folder where the second images for colocalization are placed");
								Colocalization_image_location = getDirectory("Choose the folder where the images are placed");
								Colocalization_list_images = getFileList(Colocalization_image_location);
								fullpath_Colocalization_image = Colocalization_image_location + Colocalization_list_images[0];
								open(fullpath_Colocalization_image);
								
								array_colocalization_image_location[cs] = Colocalization_image_location;
							}
					
							else {
								Dialog.create("Second colocalization channel");
								Dialog.addNumber("Second colocalization channel", "");
								Dialog.show();
								Colocalization_channel_number = Dialog.getNumber();
								selectWindow(first_image);
								setSlice(Colocalization_channel_number);
								run("Duplicate...", "duplicate");
								
								array_colocalization_channel_number[cs] = Colocalization_channel_number;
							}

							//Trainable Weka Segmentation - classifier formation and saving
							waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
					
							run("Trainable Weka Segmentation");
							wait(2000);
							TWS=getTitle();
							selectWindow(""+TWS+"");
		
							waitForUser("When you have finished making and saving your classifier press OK");

							//classifier name
							Dialog.create("Classifier");
							Dialog.addString("Classifier name:", "");
							Dialog.show();
							Classifier_name = Dialog.getString();
							array_colocalization_class[cs*1000+1] = Classifier_name;

							//classifier location
							waitForUser("Choose the folder where classifier is placed");
							Classifier_location = getDirectory("Choose the folder where classifier is placed");
							array_colocalization_class[cs*1000+2] = Classifier_location;
			
							//Probability maps - information																
							call("trainableSegmentation.Weka_Segmentation.getProbability");

							//probability class channel selection
							Dialog.create("Channel for colocalization");
							Dialog.addNumber("Which channel is the second image for colocalization analysis:", "");
							Dialog.show();
							Colocalization_class_segment_number = Dialog.getNumber();
							setSlice(Colocalization_class_segment_number);
							run("Duplicate...", "use");
							Colocalization_class_segment_image = getTitle();
							
							array_colocalization_class_segment_number[cs] = Colocalization_class_segment_number;
							
							//threshold setting
							run("Threshold...");
							waitForUser("Press OK when you found the right threshold");
							Dialog.create("Threshold");
							Dialog.addNumber("Minimun value You chose for threshold:", "");
							Dialog.addNumber("Maximum value You chose for threshold:", "");
							Dialog.show();
							Min_threshold = Dialog.getNumber();
							Max_threshold = Dialog.getNumber();
							array_colocalization_class[cs*1000+3] = Min_threshold;
							array_colocalization_class[cs*1000+4] = Max_threshold;

							//min and max object setting
							selectWindow(Colocalization_class_segment_image);
							setThreshold(Min_threshold, Max_threshold);
							run("Convert to Mask");
							Colocalization_class_image = getTitle();
							particle_set = getBoolean("Do you have min and max particle dimension?");
		
							while (particle_set == 0) {
								selectWindow(Colocalization_class_image);
								run("Duplicate...", "duplicate");
								Dialog.create("Area");
								Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
								Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
								Dialog.show();
								Min_particle = Dialog.getNumber();
								Max_particle = Dialog.getNumber();
								Min = Min_particle;
								Max = Max_particle;
								run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
								run("Analyze Particles...", "size=Min-Max show=Masks");
								waitForUser("Please check the masked image for the result and press 'OK' when done");
								particle_set = getBoolean("Do you have min and max particle dimension?");
							}
	
							Dialog.create("Area");
							Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
							Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
							Dialog.show();
							Min_particle = Dialog.getNumber();
							Max_particle = Dialog.getNumber();

							array_colocalization_class[cs*1000+5] = Min_particle;
							array_colocalization_class[cs*1000+6] = Max_particle;
						}
					}
					
					else {
					}
				
					if (Neural_projections+Width >= 1) {
						Min = array_image_quantification[30000+i*100+j];
						Max = array_image_quantification[40000+i*100+j];
					
						selectWindow(image);
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
						run("Analyze Particles...", "size=Min-Max show=Masks");					

						run("Duplicate...", "title=W1 duplicate");
						run("Duplicate...", "title=W2 duplicate");

						selectWindow("W1");
						run("Local Thickness (masked, calibrated, silent)");
						W1 = getTitle();
						selectWindow("W2");
						run("Skeletonize (2D/3D)");
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background");
						run("Subtract...", "value=255");
						W2 = getTitle();
						imageCalculator("Add create", W2, W1);			
						selectWindow("Result of W2");
						image = getTitle();

						width_set = getBoolean("Do you have needed data (number of bins, minimum and maximum number for histogram) for width calculation?");
						
						while (width_set == 0) {
							selectWindow(image);
							run("Duplicate...", "duplicate");
							Dialog.create("Width");
							Dialog.addNumber("Number of bins:", "");
							Dialog.addNumber("Minimum histogram number:", "");
							Dialog.addNumber("Maximum histogram number:", "");
							Dialog.show();
							Bin_number = Dialog.getNumber();
							Hist_min = Dialog.getNumber();
							Hist_max = Dialog.getNumber();
							
							nBins = Bin_number;
							histMin = Hist_min;
							histMax = Hist_max;	
							run("Clear Results");
							row = 0;
							getDimensions(width, height, channels, slices, frames);
							n = slices;
							for (p=0; p<nBins; p++) {
								sum = 0;
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
							run("Histogram", "bins=nBins x_min=histMin x_max=histMax y_max=Auto");
							waitForUser("Please check histogram and result table and press 'OK'");
							close("Results");
							width_set = getBoolean("Do you have needed data (number of bins, minimum and maximum number for histogram) for width calculation?");
						}
					
						Dialog.create("Width");
						Dialog.addNumber("Number of bins:", "");
						Dialog.addNumber("Minimum histogram number:", "");
						Dialog.addNumber("Maximum histogram number:", "");
						Dialog.show();
						Bin_number = Dialog.getNumber();
						Hist_min = Dialog.getNumber();
						Hist_max = Dialog.getNumber();
					
						array_width[1] = Bin_number;
						array_width[2] = Hist_min;
						array_width[3] = Hist_max;		
					}
				
					else {
					}
				}
				close("*");
				close("Threshold");
			}
	
			else {
				//Trainable Weka Segmentation - classifier formation and saving
				waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
				
				run("Trainable Weka Segmentation 3D");
				wait(2000);
				TWS=getTitle();
				selectWindow(""+TWS+"");
		
				waitForUser("When you have finished making and saving your classifier press OK");

				//classifier name
				Dialog.create("Classifier");
				Dialog.addString("Classifier name:", "");
				Dialog.show();
				Classifier_name = Dialog.getString();
				array_classifier_name[i] = Classifier_name;

				//classifier location
				waitForUser("Choose the folder where classifier is placed");
				Classifier_location = getDirectory("Choose the folder where classifier is placed");
				array_classifer_location[i] = Classifier_location;
			
				//Probability maps - information																
				call("trainableSegmentation.Weka_Segmentation.getProbability");
			
				Dialog.create("Probability maps data");
				Dialog.addNumber("How many classes (image segments) would you like to analyse?", "2");
				Dialog.show();
				Number_images_probmap = Dialog.getNumber();
				array_number_images_probmap[i] = Number_images_probmap;

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					Dialog.create("Probability maps data");
					Dialog.addNumber("Which class (image segment) do You want to analyse?", "1");
					Dialog.addString("Whats the name of the segment for analysis", "");
					Dialog.show();
					number = Dialog.getNumber();
					name = Dialog.getString();
					array_probmap[i*100+j] = number;
					array_probmap_name[i*100+j] = name;
				}

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					//formation of the "Results" folder
					results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
					File.makeDirectory(results_location_probmap);
					array_results_location[i*100+j] = results_location_probmap;
				
					//threshold setting
					selectWindow("Probability maps");
					n = array_probmap[i*100+j];
					setSlice(n);
					run("Duplicate...", "duplicate channels=n");
					image = getTitle();
			
					run("Threshold...");
					waitForUser("Press OK when you found the right threshold");
					Dialog.create("Threshold");
					Dialog.addNumber("Minimun value You chose for threshold:", "");
					Dialog.addNumber("Maximum value You chose for threshold:", "");
					Dialog.show();
					Min_threshold = Dialog.getNumber();
					Max_threshold = Dialog.getNumber();
					array_image_quantification[10000+i*100+j] = Min_threshold;
					array_image_quantification[20000+i*100+j] = Max_threshold;

					//min and max object setting
					selectWindow(image);
					setThreshold(Min_threshold, Max_threshold);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					image = getTitle();
					particle_set = getBoolean("Do you have min and max particle dimension?");
	
					while (particle_set == 0) {
						selectWindow(image);
						run("Duplicate...", "duplicate");
						run("Duplicate...", "title=duplicate duplicate");
						Dialog.create("Volume");
						Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
						Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
						Dialog.show();
						Min_particle = Dialog.getNumber();
						Max_particle = Dialog.getNumber();
						Min = Min_particle;
						Max = Max_particle;
						run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
						selectWindow(image);
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
						image_to_close = getTitle();
						close(image_to_close);
						waitForUser("Please check the masked image for the result and press 'OK' when done");
						particle_set = getBoolean("Do you have min and max particle dimension?");
					}

					Dialog.create("Volume");
					Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
					Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
					Dialog.show();
					Min_particle = Dialog.getNumber();
					Max_particle = Dialog.getNumber();

					array_image_quantification[30000+i*100+j] = Min_particle;
					array_image_quantification[40000+i*100+j] = Max_particle;

					//type of quantification
					Dialog.create("Image quantification");
					Dialog.addMessage("Select the type of quantification for the image");
					Dialog.addCheckbox("	Neural projections", false);
					Dialog.addCheckbox("	Soma and nuclei", false);
					Dialog.addCheckbox("	Area, Number and Intensity",false);
					Dialog.addCheckbox("	Length", false);
					Dialog.addCheckbox("	Width", false);
					Dialog.addCheckbox("	Colocalization with classes", false);
					Dialog.show();
					Neural_projections = Dialog.getCheckbox();
					Soma_and_nuclei = Dialog.getCheckbox();
					Area_Number_Intensity = Dialog.getCheckbox(); 
					Length = Dialog.getCheckbox();
					Width = Dialog.getCheckbox();
					Colocalization_class = Dialog.getCheckbox();

					array_image_quantification[50000+i*100+j] = Neural_projections;
					array_image_quantification[60000+i*100+j] = Soma_and_nuclei;
					array_image_quantification[70000+i*100+j] = Area_Number_Intensity;
					array_image_quantification[80000+i*100+j] = Length;
					array_image_quantification[90000+i*100+j] = Width;
					array_image_quantification[1000000+i*100+j] = Colocalization_class;
				
					if (Soma_and_nuclei == 1) {
						close(TWS);
						if (Image_type == "Single image") {
							waitForUser("Please choose the folder where the images of nuclei are placed");
							DAPI_image_location = getDirectory("Choose the folder where the images are placed");
							DAPI_list_images = getFileList(DAPI_image_location);
							fullpath_DAPI_image = DAPI_image_location + DAPI_list_images[0];
							open(fullpath_DAPI_image);
						}
					
						else {
							Dialog.create("Nuclei channel");
							Dialog.addNumber("Nuclei channel", "");
							Dialog.show();
							nuclei_channel_number = Dialog.getNumber();
							selectWindow(first_image);
							setSlice(nuclei_channel_number);
							run("Duplicate...", "duplicate");
						}

						//Trainable Weka Segmentation - classifier formation and saving
						waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
					
						run("Trainable Weka Segmentation 3D");
						wait(2000);
						TWS=getTitle();
						selectWindow(""+TWS+"");
						call("trainableSegmentation.Weka_Segmentation.changeClassName", "0", "Nuclei");
						call("trainableSegmentation.Weka_Segmentation.changeClassName", "1", "Background");
		
						waitForUser("When you have finished making and saving your classifier press OK");

						//classifier name
						Dialog.create("Classifier");
						Dialog.addString("Classifier name:", "");
						Dialog.show();
						Classifier_name = Dialog.getString();
						array_DAPI[1] = Classifier_name;

						//classifier location
						waitForUser("Choose the folder where classifier is placed");
						Classifier_location = getDirectory("Choose the folder where classifier is placed");
						array_DAPI[2] = Classifier_location;
			
						//Probability maps - information																
						call("trainableSegmentation.Weka_Segmentation.getProbability");

						//threshold setting
						setSlice(1);
						run("Duplicate...", "use");
						DAPI_image = getTitle();
			
						run("Threshold...");
						waitForUser("Press OK when you found the right threshold");
						Dialog.create("Threshold");
						Dialog.addNumber("Minimun value You chose for threshold:", "");
						Dialog.addNumber("Maximum value You chose for threshold:", "");
						Dialog.show();
						Min_threshold = Dialog.getNumber();
						Max_threshold = Dialog.getNumber();
						array_DAPI[3] = Min_threshold;
						array_DAPI[4] = Max_threshold;

						//min and max object setting
						selectWindow(image);
						setThreshold(Min_threshold, Max_threshold);
						setOption("BlackBackground", true);
						run("Convert to Mask", "method=Default background=Dark black");
						DAPI_image = getTitle();
						particle_set = getBoolean("Do you have min and max particle dimension?");
		
						while (particle_set == 0) {
							selectWindow(image);
							run("Duplicate...", "duplicate");
							run("Duplicate...", "title=duplicate duplicate");
							Dialog.create("Volume");
							Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
							Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
							Dialog.show();
							Min_particle = Dialog.getNumber();
							Max_particle = Dialog.getNumber();
							Min = Min_particle;
							Max = Max_particle;
							run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
							selectWindow(image);
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
							image_to_close = getTitle();
							close(image_to_close);
							waitForUser("Please check the masked image for the result and press 'OK' when done");
							particle_set = getBoolean("Do you have min and max particle dimension?");
						}

						Dialog.create("Volume");
						Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
						Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
						Dialog.show();
						Min_particle = Dialog.getNumber();
						Max_particle = Dialog.getNumber();

						array_DAPI[5] = Min_particle;
						array_DAPI[6] = Max_particle;
					}
				
					else {
					}
				
					if (Colocalization_class == 1) {
						close(TWS);
						Dialog.create("Segments for colocalization");
						Dialog.addNumber("Number of colocalization analysis with this segment as the first image:", "");
						Dialog.show();
						Colocalization_class_number = Dialog.getNumber();
						
						for (cs = 1; cs <= Colocalization_class_number; cs++) {
							if (Image_type == "Single image") {
								waitForUser("Please choose the folder where the second images for colocalization are placed");
								Colocalization_image_location = getDirectory("Choose the folder where the images are placed");
								Colocalization_list_images = getFileList(Colocalization_image_location);
								fullpath_Colocalization_image = Colocalization_image_location + Colocalization_list_images[0];
								open(fullpath_Colocalization_image);
								
								array_colocalization_image_location[cs] = Colocalization_image_location;
							}
					
							else {
								Dialog.create("Second colocalization channel");
								Dialog.addNumber("Second colocalization channel", "");
								Dialog.show();
								Colocalization_channel_number = Dialog.getNumber();
								selectWindow(first_image);
								setSlice(Colocalization_channel_number);
								run("Duplicate...", "duplicate");
								
								array_colocalization_channel_number[cs] = Colocalization_channel_number;
							}

							//Trainable Weka Segmentation - classifier formation and saving
							waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
					
							run("Trainable Weka Segmentation 3D");
							wait(2000);
							TWS=getTitle();
							selectWindow(""+TWS+"");
		
							waitForUser("When you have finished making and saving your classifier press OK");

							//classifier name
							Dialog.create("Classifier");
							Dialog.addString("Classifier name:", "");
							Dialog.show();
							Classifier_name = Dialog.getString();
							array_colocalization_class[cs*1000+1] = Classifier_name;

							//classifier location
							waitForUser("Choose the folder where classifier is placed");
							Classifier_location = getDirectory("Choose the folder where classifier is placed");
							array_colocalization_class[cs*1000+2] = Classifier_location;
			
							//Probability maps - information																
							call("trainableSegmentation.Weka_Segmentation.getProbability");

							//probability class channel selection
							Dialog.create("Channel for colocalization");
							Dialog.addNumber("Which channel is the second image for colocalization analysis:", "");
							Dialog.show();
							Colocalization_class_segment_number = Dialog.getNumber();
							setSlice(Colocalization_class_segment_number);
							run("Duplicate...", "use");
							Colocalization_class_segment_image = getTitle();
							
							array_colocalization_class_segment_number[cs] = Colocalization_class_segment_number;
							
							//threshold setting
							run("Threshold...");
							waitForUser("Press OK when you found the right threshold");
							Dialog.create("Threshold");
							Dialog.addNumber("Minimun value You chose for threshold:", "");
							Dialog.addNumber("Maximum value You chose for threshold:", "");
							Dialog.show();
							Min_threshold = Dialog.getNumber();
							Max_threshold = Dialog.getNumber();
							array_colocalization_class[cs*1000+3] = Min_threshold;
							array_colocalization_class[cs*1000+4] = Max_threshold;

							//min and max object setting
							selectWindow(Colocalization_class_segment_image);
							setThreshold(Min_threshold, Max_threshold);
							setOption("BlackBackground", true);
							run("Convert to Mask", "method=Default background=Dark black");
							Colocalization_class_image = getTitle();
							particle_set = getBoolean("Do you have min and max particle dimension?");
		
							while (particle_set == 0) {
								selectWindow(Colocalization_class_image);
								run("Duplicate...", "duplicate");
								run("Duplicate...", "title=duplicate duplicate");
								Dialog.create("Volume");
								Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
								Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
								Dialog.show();
								Min_particle = Dialog.getNumber();
								Max_particle = Dialog.getNumber();
								Min = Min_particle;
								Max = Max_particle;
								run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
								selectWindow(image);
								run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
								image_to_close = getTitle();
								close(image_to_close);
								waitForUser("Please check the masked image for the result and press 'OK' when done");
								particle_set = getBoolean("Do you have min and max particle dimension?");
							}
	
							Dialog.create("Volume");
							Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
							Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
							Dialog.show();
							Min_particle = Dialog.getNumber();
							Max_particle = Dialog.getNumber();

							array_colocalization_class[cs*1000+5] = Min_particle;
							array_colocalization_class[cs*1000+6] = Max_particle;
						}
					}
					
					else {
					}
				
					if (Neural_projections+Width >= 1) {
						Min = array_image_quantification[30000+i*100+j];
						Max = array_image_quantification[40000+i*100+j];
						
						selectWindow(image);
						run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
						selectWindow(image);
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");				

						run("Duplicate...", "title=W1 duplicate");
						run("Duplicate...", "title=W2 duplicate");

						selectWindow("W1");
						run("Local Thickness (masked, calibrated, silent)");
						W1 = getTitle();
						selectWindow("W2");
						run("Skeletonize (2D/3D)");
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background", "stack");
						run("Subtract...", "value=255 stack");
						W2 = getTitle();
						imageCalculator("Add create stack", W2, W1);			
						selectWindow("Result of W2");
						image = getTitle();

						width_set = getBoolean("Do you have needed data (number of bins, minimum and maximum number for histogram) for width calculation?");
					
						while (width_set == 0) {
							run("Duplicate...", "duplicate");
							selectWindow(image);
							Dialog.create("Width");
							Dialog.addNumber("Number of bins:", "");
							Dialog.addNumber("Minimum histogram number:", "");
							Dialog.addNumber("Maximum histogram number:", "");
							Dialog.show();
							Bin_number = Dialog.getNumber();
							Hist_min = Dialog.getNumber();
							Hist_max = Dialog.getNumber();
							
							nBins = Bin_number;
							histMin = Hist_min;
							histMax = Hist_max;	
							run("Clear Results");
							row = 0;
							getDimensions(width, height, channels, slices, frames);
							n = slices;
							for (p=0; p<nBins; p++) {
								sum = 0;
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
							run("Histogram", "bins=nBins x_min=histMin x_max=histMax y_max=Auto stack");
							waitForUser("Please check histogram and result table and press 'OK'");
							close("Results");
							width_set = getBoolean("Do you have needed data (number of bins, minimum and maximum number for histogram) for width calculation?");
						}
					
						Dialog.create("Width");
						Dialog.addNumber("Number of bins:", "");
						Dialog.addNumber("Minimum histogram number:", "");
						Dialog.addNumber("Maximum histogram number:", "");
						Dialog.show();
						Bin_number = Dialog.getNumber();
						Hist_min = Dialog.getNumber();
						Hist_max = Dialog.getNumber();
					
						array_width[1] = Bin_number;
						array_width[2] = Hist_min;
						array_width[3] = Hist_max;		
					}
				
					else {
					}
				}
				close("*");
			}
		}
	

		else {
			if (Image_dimension == "2D") {
				//classifier name
				Dialog.create("Classifier");
				Dialog.addString("Classifier name:", "");
				Dialog.show();
				Classifier_name = Dialog.getString();
				array_classifier_name[i] = Classifier_name;

				//classifier location
				waitForUser("Choose the folder where classifier is placed");
				Classifier_location = getDirectory("Choose the folder where classifier is placed");
				array_classifer_location[i] = Classifier_location;
			
				//probobiity maps information
				Dialog.create("Probability maps data");
				Dialog.addNumber("How many classes (image segments) would you like to analyse?", "2");
				Dialog.show();
				Number_images_probmap = Dialog.getNumber();
				array_number_images_probmap[i] = Number_images_probmap;

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					Dialog.create("Probability maps data");
					Dialog.addNumber("Which class (image segment) do You want to analyse?", "1");
					Dialog.addString("Whats the name of the segment for analysis", "");
					Dialog.show();
					number = Dialog.getNumber();
					name = Dialog.getString();
					array_probmap[i*100+j] = number;
					array_probmap_name[i*100+j] = name;
				}

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					//formation of the "Results" folder
					results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
					File.makeDirectory(results_location_probmap);
					array_results_location[i*100+j] = results_location_probmap;
				
					//threshold and area setting
					Dialog.create("Threshold and area");
					Dialog.addNumber("Minimun value You chose for threshold:", "");
					Dialog.addNumber("Maximum value You chose for threshold:", "");
					Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
					Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
					Dialog.show();
					Min_threshold = Dialog.getNumber();
					Max_threshold = Dialog.getNumber();
					Min_particle = Dialog.getNumber();
					Max_particle = Dialog.getNumber();
					array_image_quantification[10000+i*100+j] = Min_threshold;
					array_image_quantification[20000+i*100+j] = Max_threshold;
					array_image_quantification[30000+i*100+j] = Min_particle;
					array_image_quantification[40000+i*100+j] = Max_particle;


					//type of quantification
					Dialog.create("Image quantification");
					Dialog.addMessage("Select the type of quantification for the image");
					Dialog.addCheckbox("	Neural projections", false);
					Dialog.addCheckbox("	Soma and nuclei", false);
					Dialog.addCheckbox("	Area, Number and Intensity",false);
					Dialog.addCheckbox("	Length", false);
					Dialog.addCheckbox("	Width", false);
					Dialog.addCheckbox("	Colocalization with classes", false);
					Dialog.show();
					Neural_projections = Dialog.getCheckbox();
					Soma_and_nuclei = Dialog.getCheckbox();
					Area_Number_Intensity = Dialog.getCheckbox(); 
					Length = Dialog.getCheckbox();
					Width = Dialog.getCheckbox();
					Colocalization_class = Dialog.getCheckbox();

					array_image_quantification[50000+i*100+j] = Neural_projections;
					array_image_quantification[60000+i*100+j] = Soma_and_nuclei;
					array_image_quantification[70000+i*100+j] = Area_Number_Intensity;
					array_image_quantification[80000+i*100+j] = Length;
					array_image_quantification[90000+i*100+j] = Width;
					array_image_quantification[1000000+i*100+j] = Colocalization_class;
				
					if (Soma_and_nuclei == 1) {
						if (Image_type == "Single image") {
							waitForUser("Please choose the folder where the images of nuclei are placed");
							DAPI_image_location = getDirectory("Choose the folder where the images are placed");
							DAPI_list_images = getFileList(DAPI_image_location);
						}
						
						else {
							Dialog.create("Nuclei channel");
							Dialog.addNumber("Nuclei channel", "");
							Dialog.show();
							nuclei_channel_number = Dialog.getNumber();
						}
					
						//classifier name
						Dialog.create("Classifier");
						Dialog.addString("Classifier name:", "");
						Dialog.show();
						Classifier_name = Dialog.getString();
						array_DAPI[1] = Classifier_name;

						//classifier location
						waitForUser("Choose the folder where classifier is placed");
						Classifier_location = getDirectory("Choose the folder where classifier is placed");
						array_DAPI[2] = Classifier_location;

						//threshold, min and max object setting
						Dialog.create("Threshold and area");
						Dialog.addNumber("Minimun value You chose for threshold:", "");
						Dialog.addNumber("Maximum value You chose for threshold:", "");
						Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
						Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
						Dialog.show();
						Min_threshold = Dialog.getNumber();
						Max_threshold = Dialog.getNumber();
						Min_particle = Dialog.getNumber();
						Max_particle = Dialog.getNumber();
						array_DAPI[3] = Min_threshold;
						array_DAPI[4] = Max_threshold;
						array_DAPI[5] = Min_particle;
						array_DAPI[6] = Max_particle;
					}
				
					else {
					}
				
					if (Colocalization_class == 1) {
						Dialog.create("Segments for colocalization");
						Dialog.addNumber("Number of colocalization analysis with this segment as the first image:", "");
						Dialog.show();
						Colocalization_class_number = Dialog.getNumber();
						
						for (cs = 1; cs <= Colocalization_class_number; cs++) {
							if (Image_type == "Single image") {
								waitForUser("Please choose the folder where the second images for colocalization are placed");
								Colocalization_image_location = getDirectory("Choose the folder where the images are placed");
								
								array_colocalization_image_location[cs] = Colocalization_image_location;
							}
					
							else {
								Dialog.create("Second colocalization channel");
								Dialog.addNumber("Second colocalization channel", "");
								Dialog.show();
								Colocalization_channel_number = Dialog.getNumber();
								
								array_colocalization_channel_number[cs] = Colocalization_channel_number;
							}

							//classifier name
							Dialog.create("Classifier");
							Dialog.addString("Classifier name:", "");
							Dialog.show();
							Classifier_name = Dialog.getString();
							array_colocalization_class[cs*1000+1] = Classifier_name;

							//classifier location
							waitForUser("Choose the folder where classifier is placed");
							Classifier_location = getDirectory("Choose the folder where classifier is placed");
							array_colocalization_class[cs*1000+2] = Classifier_location;
			
							//probability class channel selection
							Dialog.create("Channel for colocalization");
							Dialog.addNumber("Which channel is the second image for colocalization analysis:", "");
							Dialog.show();
							Colocalization_class_segment_number = Dialog.getNumber();
							
							array_colocalization_class_segment_number[cs] = Colocalization_class_segment_number;
							
							//area and threshold setting
							Dialog.create("Area and Threshold");
							Dialog.addNumber("Minimun value You chose for threshold:", "");
							Dialog.addNumber("Maximum value You chose for threshold:", "");
							Dialog.addNumber("Minimun area value You chose for particle recognition:", "");
							Dialog.addNumber("Maximum area value You chose for particle recognition:", "");
							Dialog.show();
							Min_threshold = Dialog.getNumber();
							Max_threshold = Dialog.getNumber();
							Min_particle = Dialog.getNumber();
							Max_particle = Dialog.getNumber();
							array_colocalization_class[cs*1000+3] = Min_threshold;
							array_colocalization_class[cs*1000+4] = Max_threshold;
							array_colocalization_class[cs*1000+5] = Min_particle;
							array_colocalization_class[cs*1000+6] = Max_particle;				
						}
					}
					
					else {
					}
				
					if (Neural_projections+Width >= 1) {
						Dialog.create("Width");
						Dialog.addNumber("Number of bins:", "");
						Dialog.addNumber("Minimum histogram number:", "");
						Dialog.addNumber("Maximum histogram number:", "");
						Dialog.show();
						Bin_number = Dialog.getNumber();
						Hist_min = Dialog.getNumber();
						Hist_max = Dialog.getNumber();
						
						array_width[1] = Bin_number;
						array_width[2] = Hist_min;
						array_width[3] = Hist_max;		
					}
					
					else {
					}
				}
				close("*");
			}
	
			else {
				//classifier name
				Dialog.create("Classifier");
				Dialog.addString("Classifier name:", "");
				Dialog.show();
				Classifier_name = Dialog.getString();
				array_classifier_name[i] = Classifier_name;

				//classifier location
				waitForUser("Choose the folder where classifier is placed");
				Classifier_location = getDirectory("Choose the folder where classifier is placed");
				array_classifer_location[i] = Classifier_location;
			
				//probobiity maps information
				Dialog.create("Probability maps data");
				Dialog.addNumber("How many classes (image segments) would you like to analyse?", "2");
				Dialog.show();
				Number_images_probmap = Dialog.getNumber();
				array_number_images_probmap[i] = Number_images_probmap;

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					Dialog.create("Probability maps data");
					Dialog.addNumber("Which class (image segment) do You want to analyse?", "1");
					Dialog.addString("Whats the name of the segment for analysis", "");
					Dialog.show();
					number = Dialog.getNumber();
					name = Dialog.getString();
					array_probmap[i*100+j] = number;
					array_probmap_name[i*100+j] = name;
				}

				for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
					//formation of the "Results" folder
					results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
					File.makeDirectory(results_location_probmap);
					array_results_location[i*100+j] = results_location_probmap;
				
					//threshold and volume setting
					Dialog.create("Threshold and area");
					Dialog.addNumber("Minimun value You chose for threshold:", "");
					Dialog.addNumber("Maximum value You chose for threshold:", "");
					Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
					Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
					Dialog.show();
					Min_threshold = Dialog.getNumber();
					Max_threshold = Dialog.getNumber();
					Min_particle = Dialog.getNumber();
					Max_particle = Dialog.getNumber();
					array_image_quantification[10000+i*100+j] = Min_threshold;
					array_image_quantification[20000+i*100+j] = Max_threshold;
					array_image_quantification[30000+i*100+j] = Min_particle;
					array_image_quantification[40000+i*100+j] = Max_particle;


					//type of quantification
					Dialog.create("Image quantification");
					Dialog.addMessage("Select the type of quantification for the image");
					Dialog.addCheckbox("	Neural projections", false);
					Dialog.addCheckbox("	Soma and nuclei", false);
					Dialog.addCheckbox("	Area, Number and Intensity",false);
					Dialog.addCheckbox("	Length", false);
					Dialog.addCheckbox("	Width", false);
					Dialog.addCheckbox("	Colocalization with classes", false);
					Dialog.show();
					Neural_projections = Dialog.getCheckbox();
					Soma_and_nuclei = Dialog.getCheckbox();
					Area_Number_Intensity = Dialog.getCheckbox(); 
					Length = Dialog.getCheckbox();
					Width = Dialog.getCheckbox();
					Colocalization_class = Dialog.getCheckbox();

					array_image_quantification[50000+i*100+j] = Neural_projections;
					array_image_quantification[60000+i*100+j] = Soma_and_nuclei;
					array_image_quantification[70000+i*100+j] = Area_Number_Intensity;
					array_image_quantification[80000+i*100+j] = Length;
					array_image_quantification[90000+i*100+j] = Width;
					array_image_quantification[1000000+i*100+j] = Colocalization_class;
				
					if (Soma_and_nuclei == 1) {
						if (Image_type == "Single image") {
							waitForUser("Please choose the folder where the images of nuclei are placed");
							DAPI_image_location = getDirectory("Choose the folder where the images are placed");
							DAPI_list_images = getFileList(DAPI_image_location);
						}
					
						else {
							Dialog.create("Nuclei channel");
							Dialog.addNumber("Nuclei channel", "");
							Dialog.show();
							nuclei_channel_number = Dialog.getNumber();
						}

						//classifier name
						Dialog.create("Classifier");
						Dialog.addString("Classifier name:", "");
						Dialog.show();
						Classifier_name = Dialog.getString();
						array_DAPI[1] = Classifier_name;

						//classifier location
						waitForUser("Choose the folder where classifier is placed");
						Classifier_location = getDirectory("Choose the folder where classifier is placed");
						array_DAPI[2] = Classifier_location;
	
						//threshold, min and max object setting
						Dialog.create("Threshold and volume");
						Dialog.addNumber("Minimun value You chose for threshold:", "");
						Dialog.addNumber("Maximum value You chose for threshold:", "");
						Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
						Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
						Dialog.show();
						Min_threshold = Dialog.getNumber();
						Max_threshold = Dialog.getNumber();
						Min_particle = Dialog.getNumber();
						Max_particle = Dialog.getNumber();
						array_DAPI[3] = Min_threshold;
						array_DAPI[4] = Max_threshold;
						array_DAPI[5] = Min_particle;
						array_DAPI[6] = Max_particle;
					}
				
					else {
					}
					
					if (Colocalization_class == 1) {
						Dialog.create("Segments for colocalization");
						Dialog.addNumber("Number of colocalization analysis with this segment as the first image:", "");
						Dialog.show();
						Colocalization_class_number = Dialog.getNumber();
						
						for (cs = 1; cs <= Colocalization_class_number; cs++) {
							if (Image_type == "Single image") {
								waitForUser("Please choose the folder where the second images for colocalization are placed");
								Colocalization_image_location = getDirectory("Choose the folder where the images are placed");
								
								array_colocalization_image_location[cs] = Colocalization_image_location;
							}
					
							else {
								Dialog.create("Second colocalization channel");
								Dialog.addNumber("Second colocalization channel", "");
								Dialog.show();
								Colocalization_channel_number = Dialog.getNumber();
								
								array_colocalization_channel_number[cs] = Colocalization_channel_number;
							}

							//classifier name
							Dialog.create("Classifier");
							Dialog.addString("Classifier name:", "");
							Dialog.show();
							Classifier_name = Dialog.getString();
							array_colocalization_class[cs*1000+1] = Classifier_name;

							//classifier location
							waitForUser("Choose the folder where classifier is placed");
							Classifier_location = getDirectory("Choose the folder where classifier is placed");
							array_colocalization_class[cs*1000+2] = Classifier_location;
			
							//probability class channel selection
							Dialog.create("Channel for colocalization");
							Dialog.addNumber("Which channel is the second image for colocalization analysis:", "");
							Dialog.show();
							Colocalization_class_segment_number = Dialog.getNumber();
							
							array_colocalization_class_segment_number[cs] = Colocalization_class_segment_number;
							
							//volume and threshold setting
							Dialog.create("Volume and Threshold");
							Dialog.addNumber("Minimun value You chose for threshold:", "");
							Dialog.addNumber("Maximum value You chose for threshold:", "");
							Dialog.addNumber("Minimun volume value You chose for particle recognition:", "");
							Dialog.addNumber("Maximum volume value You chose for particle recognition:", "");
							Dialog.show();
							Min_threshold = Dialog.getNumber();
							Max_threshold = Dialog.getNumber();
							Min_particle = Dialog.getNumber();
							Max_particle = Dialog.getNumber();
							array_colocalization_class[cs*1000+3] = Min_threshold;
							array_colocalization_class[cs*1000+4] = Max_threshold;
							array_colocalization_class[cs*1000+5] = Min_particle;
							array_colocalization_class[cs*1000+6] = Max_particle;						
						}
					}
					
					else {
					}
										
					if (Neural_projections+Width >= 1) {
						Dialog.create("Width");
						Dialog.addNumber("Number of bins:", "");
						Dialog.addNumber("Minimum histogram number:", "");
						Dialog.addNumber("Maximum histogram number:", "");
						Dialog.show();
						Bin_number = Dialog.getNumber();
						Hist_min = Dialog.getNumber();
						Hist_max = Dialog.getNumber();
					
						array_width[1] = Bin_number;
						array_width[2] = Hist_min;
						array_width[3] = Hist_max;		
					}
				
					else {
					}
				}
				close("*");
			}
		}
	}
}

else {
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//MAIN PROGRAMME LOOP
for (i = 1; i <= list_images.length; i+=1) {
	//opening image
	fullpath_image = image_location + list_images[i-1];
	open(fullpath_image);
	first_image_title = getTitle();
			
	
	//image properties setting
	if (Image_properties == 1) {
		run("Properties...", "pixel_width=x pixel_height=y voxel_depth=z global");
	}
		
	else {
	}


	for (j = 1; j <= Channel_number; j++) {
		selectWindow(first_image_title);
		n = array_channel_number_to_analyse[j];
		setSlice(n);
		run("Duplicate...", "duplicate channels=n");

		//clear outside
		if (Clear_outside_overall == 1) {
			if (Image_dimension == "2D") {
				roiManager("Select", j-1);
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
			}
			else {
				Stack.getDimensions(width, height, channels, slices, frames);
				slice_number = slices;
				for (l = 1; l < slice_number; l++) {
					setSlice(l);
					roiManager("Select", j-1);
					setBackgroundColor(0, 0, 0);
					run("Clear Outside", "stack");
				}
			}
		}
		else {
		}
		
		title_intensity = getTitle();
		run("Duplicate...", "title=IMAGE duplicate");
		start_image_title = getTitle();
		selectWindow(title_intensity);
		run("Duplicate...", "duplicate");
		image_duplicate_title = getTitle();
		
		//colocalization
		if (Colocalization == 1) {
			if (Image_type == "Channel image") {	
				selectWindow(first_image_title);
				First_colocalization = array_colocalization[3*100+j];
				setSlice(First_colocalization);
				n = First_colocalization;
				run("Duplicate...", "duplicate channels=n");
				A_col = getTitle();
				print(A_col);
				selectWindow(first_image_title);
				Second_colocalization = array_colocalization[4*100+j];
				setSlice(Second_colocalization);
				n = Second_colocalization;
				run("Duplicate...", "duplicate channels=n");
				B_col = getTitle();
			}
			else {	
				fullpath_first_image = First_colocalization_image_location + First_colocalization_list_images[i-1];
				open(fullpath_first_image);
				A_col = getTitle();
		
				fullpath_second_image = Second_colocalization_image_location + Second_colocalization_list_images[i-1];
				open(fullpath_second_image);
				B_col = getTitle();
			}
			thrA = array_colocalization[1*100+j];
			thrB = array_colocalization[2*100+j];
			coloc = "imga=[" + A_col + "] imgb=[" + B_col + "] thra=" + thrA + " thrb=" + thrB + " pearson mm";
			run("JACoP ", coloc);
			selectWindow("Log");
			results_coloc = array_colocalization[5*100+j];
			saveAs("Text", results_coloc + "\\" + "(" + A_col + " + " + B_col + ")" + " - colocalization.txt");
			close("Log");
		}

		else {
		}
			
			
		if (Continue_Lusca == 1) {
			if (Image_dimension == "2D") {
				selectWindow(image_duplicate_title);
				run("Trainable Weka Segmentation");
				wait(2000);
				TWS=getTitle();

				selectWindow(""+TWS+"");
				call("trainableSegmentation.Weka_Segmentation.loadClassifier", array_classifer_location[j] + array_classifier_name[j]);
				call("trainableSegmentation.Weka_Segmentation.getProbability");
//				saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
				title_prob_map = getTitle();
	
				for (k = 1; k <= array_number_images_probmap[j]; k++) {
					results_location = array_results_location[j*100+k];
					
					selectWindow(title_prob_map);
					n = array_probmap[j*100+k];
					setSlice(n); 
					run("Duplicate...", "duplicate channels=n");
					setThreshold(array_image_quantification[10000+j*100+k], array_image_quantification[20000+j*100+k]);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					Min = array_image_quantification[30000+j*100+k];
					Max = array_image_quantification[40000+j*100+k];
					run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
					run("Analyze Particles...", "size=Min-Max show=Masks");
					saveAs("Tiff", results_location+"\\"+first_image_title+" - origin image");
					origin_image = getTitle();
				
					//neural projections
					if (array_image_quantification[50000+j*100+k] == 1) {
						Neural_projections_quantification();
					}
					else {
					}
				
					//soma and nuclei
					if (array_image_quantification[60000+j*100+k] == 1) {
						Soma_and_nuclei_quantification();
					}
					else {
					}
				
					//area, number, intensity
					if (array_image_quantification[70000+j*100+k] == 1) {
						Area_Number_Intensity_quantification();
					}
					else {
					}
				
					//length
					if (array_image_quantification[80000+j*100+k] == 1) {
						Length_quantification();
					}
					else {
					}
				
					//width
					if (array_image_quantification[90000+j*100+k] == 1) {
						Width_quantification();
					}
					else {
					}
					
					//colocalization class
					if (array_image_quantification[1000000+j*100+k] == 1) {
						Colocalization_class_quantification();
					}
					else {
					}
					close(origin_image);
				}
			}
			else {
				n = array_channel_number_to_analyse[j];
				setSlice(n);
				run("Duplicate...", "duplicate channels=n");
	
				run("Trainable Weka Segmentation 3D");
				wait(2000);
				TWS=getTitle();

				selectWindow(""+TWS+"");
				call("trainableSegmentation.Weka_Segmentation.loadClassifier", array_classifer_location[j] + array_classifier_name[j]);
				call("trainableSegmentation.Weka_Segmentation.getProbability");
//				saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
				title_prob_map = getTitle();

				for (k = 1; k <= array_number_images_probmap[j]; k++) {
					results_location = array_results_location[j*100+k];
					
					selectWindow(title_prob_map);
					n = array_probmap[j*100+k];
					setSlice(n);
					run("Duplicate...", "duplicate channels=n");
					setThreshold(array_image_quantification[10000+j*100+k], array_image_quantification[20000+j*100+k]);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					title = getTitle();
					run("Duplicate...", "title=dublicate duplicate");
					selectWindow(title);
					Min = array_image_quantification[30000+j*100+k];
					Max = array_image_quantification[40000+j*100+k];
					run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
					selectWindow(title);
					run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
					title_closing = getTitle();
					close(title_closing);
					saveAs("Tiff", results_location+"\\"+first_image_title+" - origin image");
					origin_image = getTitle();
				
					//neural projections
					if (array_image_quantification[50000+j*100+k] == 1) {
						Neural_projections_quantification();
					}
					else {
					}
				
					//soma and nuclei
					if (array_image_quantification[60000+j*100+k] == 1) {
						Soma_and_nuclei_quantification();
					}
					else {
					}
				
					//volume, number, intensity
					if (array_image_quantification[70000+j*100+k] == 1) {
						Volume_Number_Intensity_quantification();
					}
					else {
					}
				
					//length
					if (array_image_quantification[80000+j*100+k] == 1) {
						Length_quantification();
					}
					else {
					}
				
					//width
					if (array_image_quantification[90000+j*100+k] == 1) {
						Width_quantification();
					}
					else {
					}
					
					//colocalization class
					if (array_image_quantification[1000000+j*100+k] == 1) {
						Colocalization_class_quantification();
					}
					else {
					}
					close(origin_image);
				}
			}
		close("Log");
		}
		else {
		}
	}
	close("*");
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//PROGRAMME FUNCTIONS

function Neural_projections_quantification() {
	results_location = array_results_location[j*100+k];
	
	if (Image_dimension == "2D") {
		//area, number and intensity
		results_location = array_results_location[j*100+k];
		selectWindow(origin_image);
		run("Duplicate...", "duplicate");
		x = "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3";
		run("Set Measurements...", x);
		Min = array_image_quantification[30000+j*100+k];
		Max = array_image_quantification[40000+j*100+k];
		run("Analyze Particles...", "size=Min-Max show=Nothing display summarize");
		selectWindow("Results");
		saveAs("Results", results_location+"\\"+first_image_title+" - results of area and number.csv");
		close("Results");
		selectWindow("Summary");
		saveAs("Results", results_location+"\\"+first_image_title+" - summary of area and number.csv");
		close(first_image_title+" - summary of area and number.csv");
	}
	
	else {
		//volume, number and intensity
		results_location = array_results_location[j*100+k];
		selectWindow(origin_image);
		run("Duplicate...", "duplicate");
		volume_image = getTitle();
		setThreshold(1, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Default background=Dark black");
		run("Statistics");
		selectWindow("Results");
		saveAs("Results", results_location+"\\"+first_image_title+" - summary of volume, number and intensity.csv");
		close("Results");
		x = "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=IMAGE";
		run("3D OC Options", x);
		Min = array_image_quantification[30000+j*100+k];
		Max = array_image_quantification[40000+j*100+k];
		selectWindow(volume_image);
		run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
		saveAs("Results", results_location+"\\"+first_image_title+" - results of volume, number and intensity.csv");
		close(first_image_title+" - results of volume, number and intensity.csv");
	}
			
	//length
	results_location = array_results_location[j*100+k];
	selectWindow(origin_image);
	run("Duplicate...", "duplicate");
	run("Skeletonize (2D/3D)");
	run("Summarize Skeleton");
	saveAs("Results", results_location+"\\"+first_image_title+" - skeleton summary.csv");
	close(first_image_title+" - skeleton summary.csv");
	run("Analyze Skeleton (2D/3D)", "prune=none show");
//	saveAs("Tiff", results_location+"\\"+first_image_title+" - skeleton");
	selectWindow("Branch information");
	saveAs("Results", results_location+"\\"+first_image_title+" - branch information.csv");
	close(first_image_title+" - branch information.csv");
	selectWindow("Results");
	saveAs("Results", results_location+"\\"+first_image_title+" - results from skeleton.csv");
	close("Results");

	//width
	results_location = array_results_location[j*100+k];
	selectWindow(origin_image);
	run("Duplicate...", "title=W1 duplicate");
	selectWindow(origin_image);
	run("Duplicate...", "title=W2 duplicate");

	selectWindow("W1");
	run("Local Thickness (masked, calibrated, silent)");
//	saveAs("Tiff", results_location+"\\"+first_image_title+" - Local Thickness");
	W1 = getTitle();
	selectWindow("W2");
	run("Skeletonize (2D/3D)");
	run("32-bit");
	setAutoThreshold("Default dark");
	setThreshold(1.00, 1e30);
	run("NaN Background", "stack");
	run("Subtract...", "value=255 stack");
	W2 = getTitle();
	imageCalculator("Add create stack", W2, W1);
			
	selectWindow("Result of W2");
//	saveAs("Tiff", results_location+"\\"+first_image_title+" - skeletons of Local Thickness");

	//list from histogram
	nBins = array_width[1];
	histMin = array_width[2];
	histMax = array_width[3];
	run("Clear Results");
	row = 0;
	getDimensions(width, height, channels, slices, frames);
	n = slices;
	for (p=0; p<nBins; p++) {
		sum = 0;
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
	saveAs("Results", results_location+"\\"+first_image_title+" - histrogram list.csv");
	close("Results");


	run("Histogram", "bins=nBins x_min=histMin x_max=histMax y_max=Auto stack");
	saveAs("Tiff", results_location+"\\"+first_image_title+" - histogram");
}


function Soma_and_nuclei_quantification() { 
	results_location = array_results_location[j*100+k];
	close(TWS);
	
	//opening nuclei image
	if (Image_type == "Single image") {
		fullpath_DAPI_image = DAPI_image_location + DAPI_list_images[i-1];
		open(fullpath_DAPI_image);
	}
		
	else {
		selectWindow(first_image_title);
		setSlice(nuclei_channel_number);
		n = nuclei_channel_number;
		run("Duplicate...", "duplicate channels=n");
	}
	
	//clear outside
	if (Clear_outside_overall == 1) {
		if (Image_dimension == "2D") {
			roiManager("Select", j-1);
			setBackgroundColor(0, 0, 0);
			run("Clear Outside");
		}
		else {
			Stack.getDimensions(width, height, channels, slices, frames);
			slice_number = slices;
			for (c = 1; c < slice_number; c++) {
				setSlice(c);
				roiManager("Select", j-1);
				setBackgroundColor(0, 0, 0);
				run("Clear Outside", "stack");
			}
		}
	}
	
	else {
	}


	if (Image_dimension == "2D") {		
		title_DAPI_intensity = getTitle();
		run("Duplicate...", "title=DAPI_IMAGE duplicate");
		start_DAPI_image_title = getTitle();
		selectWindow(title_DAPI_intensity);
		run("Duplicate...", "duplicate");
		
		
		run("Trainable Weka Segmentation");
		wait(2000);
		TWS2=getTitle();

		selectWindow(""+TWS2+"");
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", array_DAPI[2] + array_DAPI[1]);
		call("trainableSegmentation.Weka_Segmentation.getProbability");
//		saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
		
		setSlice(1);
		run("Duplicate...", "duplicate channels=n");
		setThreshold(array_DAPI[3], array_DAPI[4]);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Default background=Dark black");
		Min = array_DAPI[5];
		Max = array_DAPI[6];
		run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
		run("Analyze Particles...", "size=Min-Max show=Masks");
//		saveAs("Tiff", results_location+"\\"+first_image_title+" - origin nuclei image");
		origin_DAPI_image = getTitle();
		
		x = "area mean standard modal min fit shape integrated median area_fraction limit redirect=DAPI_IMAGE decimal=3";
		run("Set Measurements...", x);
		Min = array_DAPI[5];
		Max = array_DAPI[6];
		run("Analyze Particles...", "size=Min-Max show=Nothing display summarize");
		selectWindow("Results");
		saveAs("Results", results_location+"\\"+first_image_title+" - results of nuclei area and number.csv");
		close("Results");
		selectWindow("Summary");
		saveAs("Results", results_location+"\\"+first_image_title+" - summary of nuclei area and number.csv");
		close(first_image_title+" - summary of nuclei area and number.csv");
		
		run("Options...", "iterations=2 count=1 black do=Dilate stack");
		imageCalculator("AND create stack", origin_image,origin_DAPI_image);
		
		//area, number and intensity
		results_location = array_results_location[j*100+k];
		run("Duplicate...", "duplicate");
		x = "area mean standard modal min fit shape integrated median area_fraction limit redirect=DAPI_IMAGE decimal=3";
		run("Set Measurements...", x);
		Min = array_image_quantification[30000+j*100+k];
		Max = array_image_quantification[40000+j*100+k];
		run("Analyze Particles...", "size=Min-Max show=Nothing display summarize");
		selectWindow("Results");
		saveAs("Results", results_location+"\\"+first_image_title+" - results of soma area and number.csv");
		close("Results");
		selectWindow("Summary");
		saveAs("Results", results_location+"\\"+first_image_title+" - summary of soma area and number.csv");
		close(first_image_title+" - summary of soma area and number.csv");
	}
	
	else {
		title_DAPI_intensity = getTitle();
		run("Duplicate...", "title=DAPI_IMAGE duplicate");
		start_DAPI_image_title = getTitle();
		selectWindow(title_DAPI_intensity);
		run("Duplicate...", "duplicate");
		
		run("Trainable Weka Segmentation 3D");
		wait(2000);
		TWS2=getTitle();

		selectWindow(""+TWS2+"");
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", array_DAPI[2] + array_DAPI[1]);
		call("trainableSegmentation.Weka_Segmentation.getProbability");
//		saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
				
		setSlice(1);
		run("Duplicate...", "duplicate channels=n");
		setThreshold(array_DAPI[3], array_DAPI[4]);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Default background=Dark black");
		DAPI_title = getTitle();
		run("Duplicate...", "title=duplicate_DAPI duplicate");
		Min = array_DAPI[5];
		Max = array_DAPI[6];
		x = "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate_DAPI";
		run("3D OC Options", x);
		selectWindow(DAPI_title);
		run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
		image_to_close = getTitle();
		close(image_to_close);
//		saveAs("Tiff", results_location+"\\"+first_image_title+" - origin nuclei image");
		origin_DAPI_image = getTitle();
		
		setThreshold(1, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Default background=Dark black");
		run("Statistics");
		selectWindow("Results");
		saveAs("Results", results_location+"\\"+first_image_title+" - summary of nuclei volume, number and intensity.csv");
		close("Results");
		run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=DAPI_IMAGE");
		Min = array_DAPI[5];
		Max = array_DAPI[6];
		run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
		saveAs("Results", results_location+"\\"+first_image_title+" - results of nuclei volume, number and intensity.csv");
		close(first_image_title+" - results of nuclei volume, number and intensity.csv");
		
		run("Options...", "iterations=2 count=1 black do=Dilate stack");
		imageCalculator("AND create stack", origin_image,origin_DAPI_image);
		
		//volume, number and intensity
		results_location = array_results_location[j*100+k];
		selectWindow(origin_image);
		run("Duplicate...", "duplicate");
		volume_image = getTitle();
		setThreshold(1, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Default background=Dark black");
		run("Statistics");
		selectWindow("Results");
		saveAs("Results", results_location+"\\"+first_image_title+" - summary of soma volume, number and intensity.csv");
		close("Results");
		x = "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=IMAGE";
		run("3D OC Options", x);
		Min = array_image_quantification[30000+j*100+k];
		Max = array_image_quantification[40000+j*100+k];
		selectWindow(volume_image);
		run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
		saveAs("Results", results_location+"\\"+first_image_title+" - results of soma volume, number and intensity.csv");
		close(first_image_title+" - results of soma volume, number and intensity.csv");
	}
}


function Area_Number_Intensity_quantification() { 
	results_location = array_results_location[j*100+k];
	selectWindow(origin_image);
	run("Duplicate...", "duplicate");
	x = "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3";
	run("Set Measurements...", x);
	Min = array_image_quantification[30000+j*100+k];
	Max = array_image_quantification[40000+j*100+k];
	run("Analyze Particles...", "size=Min-Max show=Nothing display summarize");
	selectWindow("Results");
	saveAs("Results", results_location+"\\"+first_image_title+" - results of area, number and intensity.csv");
	close("Results");
	selectWindow("Summary");
	saveAs("Results", results_location+"\\"+first_image_title+" - summary of area, number and intensity.csv");
	close(first_image_title+" - summary of area, number and intensity.csv");
}


function Volume_Number_Intensity_quantification() { 
	results_location = array_results_location[j*100+k];
	selectWindow(origin_image);
	run("Duplicate...", "duplicate");
	volume_image = getTitle();
	setThreshold(1, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Default background=Dark black");
	run("Statistics");
	selectWindow("Results");
	saveAs("Results", results_location+"\\"+first_image_title+" - summary of volume, number and intensity.csv");
	close("Results");
	x = "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=IMAGE";
	run("3D OC Options", x);
	Min = array_image_quantification[30000+j*100+k];
	Max = array_image_quantification[40000+j*100+k];
	selectWindow(volume_image);
	run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
	saveAs("Results", results_location+"\\"+first_image_title+" - results of volume, number and intensity.csv");
	close(first_image_title+" - results of volume, number and intensity.csv");
}


function Length_quantification() {
	results_location = array_results_location[j*100+k];
	selectWindow(origin_image);
	run("Duplicate...", "duplicate");
	run("Skeletonize (2D/3D)");
	run("Summarize Skeleton");
	saveAs("Results", results_location+"\\"+first_image_title+" - skeleton summary.csv");
	close(first_image_title+" - skeleton summary.csv");
	run("Analyze Skeleton (2D/3D)", "prune=none show");
//	saveAs("Tiff", results_location+"\\"+first_image_title+" - skeleton");
	selectWindow("Branch information");
	saveAs("Results", results_location+"\\"+first_image_title+" - branch information.csv");
	close(first_image_title+" - branch information.csv");
	selectWindow("Results");
	saveAs("Results", results_location+"\\"+first_image_title+" - results from skeleton.csv");
	close("Results");
}


function Width_quantification() { 
	results_location = array_results_location[j*100+k];
	selectWindow(origin_image);
	run("Duplicate...", "title=W1 duplicate");
	selectWindow(origin_image);
	run("Duplicate...", "title=W2 duplicate");

	selectWindow("W1");
	run("Local Thickness (masked, calibrated, silent)");
//	saveAs("Tiff", results_location+"\\"+first_image_title+" - Local Thickness");
	W1 = getTitle();
	selectWindow("W2");
	run("Skeletonize (2D/3D)");
	run("32-bit");
	setAutoThreshold("Default dark");
	setThreshold(1.00, 1e30);
	run("NaN Background", "stack");
	run("Subtract...", "value=255 stack");
	W2 = getTitle();
	imageCalculator("Add create stack", W2, W1);
			
	selectWindow("Result of W2");
//	saveAs("Tiff", results_location+"\\"+first_image_title+" - skeletons of Local Thickness");

	//list from histogram
	nBins = array_width[1];
	histMin = array_width[2];
	histMax = array_width[3];
	run("Clear Results");
	row = 0;
	getDimensions(width, height, channels, slices, frames);
	n = slices;
	for (p=0; p<nBins; p++) {
		sum = 0;
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
	saveAs("Results", results_location+"\\"+first_image_title+" - histrogram list.csv");
	close("Results");


	run("Histogram", "bins=nBins x_min=histMin x_max=histMax y_max=Auto stack");
	saveAs("Tiff", results_location+"\\"+first_image_title+" - histogram");
}


function Colocalization_class_quantification() { 
	results_location = array_results_location[j*100+k];
	close(TWS);
	
	selectWindow(origin_image);
	origin_title_1 = getTitle();
	run("Duplicate...", "duplicate");
	run("Divide...", "value=255 stack");
	origin_title_A = getTitle();
	selectWindow(start_image_title);
	run("Duplicate...", "duplicate");
	start_title_1 = getTitle();
	imageCalculator("Multiply create stack", start_title_1,origin_title_A);
	title_A = getTitle();
	
	for (cc = 1; cc <= Colocalization_class_number; cc++) {
		//opening second colocalization image		
		if (Image_type == "Single image") {
			Colocalization_list_images = getFileList(array_colocalization_image_location[cc]);
			fullpath_Colocalization_image = array_colocalization_image_location[cc] + Colocalization_list_images[i-1];
			open(fullpath_Colocalization_image);
		}
		
		else {
			selectWindow(first_image_title);
			n = array_colocalization_channel_number[cc];
			setSlice(n);
			run("Duplicate...", "duplicate channels=n");
		}
	
		//clear outside
		if (Clear_outside_overall == 1) {
			if (Image_dimension == "2D") {
				roiManager("Select", j-1);
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
			}
			else {
				Stack.getDimensions(width, height, channels, slices, frames);
				slice_number = slices;
				for (c = 1; c < slice_number; c++) {
					setSlice(c);
					roiManager("Select", j-1);
					setBackgroundColor(0, 0, 0);
					run("Clear Outside", "stack");
				}
			}
		}
	
		else {
		}

	
		if (Image_dimension == "2D") {		
			title_Colocalization_intensity = getTitle();
			run("Duplicate...", "title=COLOC_IMAGE duplicate");
			start_Colocalization_image_title = getTitle();
			selectWindow(title_Colocalization_intensity);
			run("Duplicate...", "duplicate");
					
		
			run("Trainable Weka Segmentation");
			wait(2000);
			TWS2=getTitle();

			selectWindow(""+TWS2+"");
			call("trainableSegmentation.Weka_Segmentation.loadClassifier", array_colocalization_class[cc*1000+2] + array_colocalization_class[cc*1000+1]);
			call("trainableSegmentation.Weka_Segmentation.getProbability");
//			saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
		
			n = array_colocalization_class_segment_number[cc];
			setSlice(n);
			run("Duplicate...", "duplicate channels=n");
			setThreshold(array_colocalization_class[cc*1000+3], array_colocalization_class[cc*1000+4]);
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Default background=Dark black");
			Min = array_colocalization_class[cc*1000+5];
			Max = array_colocalization_class[cc*1000+6];
			run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
			run("Analyze Particles...", "size=Min-Max show=Masks");
//			saveAs("Tiff", results_location+"\\"+first_image_title+" - origin nuclei image");
			origin_title_2 = getTitle();
			run("Duplicate...", "duplicate");
			run("Divide...", "value=255 stack");
			origin_title_B = getTitle();

			//area and number
			imageCalculator("AND create", origin_title_1,origin_title_2);
			run("Analyze Particles...", "size=0-Infinity show=Nothing display summarize");
			selectWindow("Results");
			saveAs("Results", results_location+"\\"+first_image_title+" - results of colocalization segment image.csv");
			close("Results");
			selectWindow("Summary");
			saveAs("Results", results_location+"\\"+first_image_title+" - summary of colocalization segment image.csv");
			close(first_image_title+" - summary of colocalization segment image.csv");

			selectWindow(start_Colocalization_image_title);
			run("Duplicate...", "duplicate");
			start_title_2 = getTitle();
			imageCalculator("Multiply create stack", start_title_2,origin_title_B);
			title_B = getTitle();
				
			//P, M1 and M2
			close("Log");
			thrA = "1";
			thrB = "1";
			coloc = "imga=[" + title_A + "] imgb=[" + title_B + "] thra=" + thrA + " thrb=" + thrB + " pearson mm";
			run("JACoP ", coloc);
			selectWindow("Log");
			saveAs("Text", results_location + "\\" + "(" + title_intensity + " + " + title_Colocalization_intensity + ")" + " - colocalization.txt");
			close("Log");
		}
	
		else {
			title_Colocalization_intensity = getTitle();
			run("Duplicate...", "title=COLOC_IMAGE duplicate");
			start_Colocalization_image_title = getTitle();
			selectWindow(title_Colocalization_intensity);
			run("Duplicate...", "duplicate");
					
		
			run("Trainable Weka Segmentation 3D");
			wait(2000);
			TWS2=getTitle();

			selectWindow(""+TWS2+"");
			call("trainableSegmentation.Weka_Segmentation.loadClassifier", array_colocalization_class[cc*1000+2] + array_colocalization_class[cc*1000+1]);
			call("trainableSegmentation.Weka_Segmentation.getProbability");
//			saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
		
			n = array_colocalization_class_segment_number[cc];
			setSlice(n);
			run("Duplicate...", "duplicate channels=n");
			setThreshold(array_colocalization_class[cc*1000+3], array_colocalization_class[cc*1000+4]);
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Default background=Dark black");
			Colocalization_title = getTitle();
			run("Duplicate...", "title=duplicate_COLOC duplicate");
			Min = array_colocalization_class[cc*1000+5];
			Max = array_colocalization_class[cc*1000+6];
			x = "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate_COLOC";
			run("3D OC Options", x);
			selectWindow(Colocalization_title);
			run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max objects");
			image_to_close = getTitle();
			close(image_to_close);
//			saveAs("Tiff", results_location+"\\"+first_image_title+" - origin nuclei image");
			origin_title_2 = getTitle();
			run("Duplicate...", "duplicate");
			run("Divide...", "value=255 stack");
			origin_title_B = getTitle();

			//volume and number
			imageCalculator("AND create stack", origin_title_1,origin_title_2);
			volume_image = getTitle();
			setThreshold(1, 255);
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Default background=Dark black");
			run("Statistics");
			selectWindow("Results");
			saveAs("Results", results_location+"\\"+first_image_title+" - summary of colocalization segment image.csv");
			close("Results");
			x = "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=IMAGE";
			run("3D OC Options", x);
			Min = array_image_quantification[30000+j*100+k];
			Max = array_image_quantification[40000+j*100+k];
			selectWindow(volume_image);
			run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
			saveAs("Results", results_location+"\\"+first_image_title+" - results of colocalization segment image.csv");
			close(first_image_title+" - results of colocalization segment image.csv");
			
			selectWindow(start_Colocalization_image_title);
			run("Duplicate...", "duplicate");
			start_title_2 = getTitle();
			imageCalculator("Multiply create stack", start_title_2,origin_title_B);
			title_B = getTitle();
				
			//P, M1 and M2
			close("Log");
			thrA = "1";
			thrB = "1";
			coloc = "imga=[" + title_A + "] imgb=[" + title_B + "] thra=" + thrA + " thrb=" + thrB + " pearson mm";
			run("JACoP ", coloc);
			selectWindow("Log");
			saveAs("Text", results_location + "\\" + "(" + title_intensity + " + " + title_Colocalization_intensity + ")" + " - colocalization.txt");
			close("Log");
		}
	}
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////