///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   
//   Lusca - FIJI (ImageJ) based tool for automated morphological analysis of cellular and subcellular structures
//
//   Author: Iva Simunic
//   Contact - e-mail: iva.simunic25@gmail.com
//
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//array list
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

//image location
Dialog.create("Images folder");
Dialog.addMessage("Please, select the folder where all images are placed");
Dialog.show();
image_location = getDirectory("Choose the folder where the images are placed");
list_images = getFileList(image_location);

//image type selection and input parameters
Dialog.create("Image type selection");
Dialog.addMessage("Please select the parameters for image analysis");
Dialog.addMessage("\n");
Dialog.addChoice("Image type:", array_image_type);
Dialog.addChoice("             Image dimension:", array_image_dimension);
Dialog.addMessage("\n");
Dialog.addMessage("Select the type of quantification for the image");
Dialog.addCheckbox("	Set scale", false);
Dialog.addCheckbox("	Crop image", false);
Dialog.addCheckbox("	Image segmentetion and other analyses", true);
Dialog.addCheckbox("	Image segmentetion and other analyses - interactive", false);
Dialog.show();
Image_type = Dialog.getChoice();
Image_dimension = Dialog.getChoice();
Image_properties = Dialog.getCheckbox();
Clear_outside_overall = Dialog.getCheckbox();
Lusca = Dialog.getCheckbox();
Lusca_interactive = Dialog.getCheckbox();

//image properties setting
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

//classifiers location
if (Lusca+Lusca_interactive == 1) {
	Dialog.create("Classifiers folder");
	Dialog.addMessage("Please, select the folder where all image segmentation classifiers are/will be placed");
	Dialog.show();
	classifiers_location = getDirectory("Choose the folder where the classifiers are placed");
}

//channel information
if (Image_type == "Channel image") {
	Dialog.create("Channel data");
	Dialog.addNumber("How many channels would you like to analyse?", "");
	Dialog.show();
	Channel_number = Dialog.getNumber();
	for (i = 1; i <= Channel_number; i++) {
		Dialog.create("Channel for analysis");
		Dialog.addNumber("Channel number:", "");
		Dialog.addString("Channel name:", "");
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


//loop for setting input parameters
for (i = 1; i <= Channel_number; i++) {
	fullpath_image = image_location + list_images[0];
	
	if (Clear_outside_overall == 1) {
		open(fullpath_image);
		first_image = getTitle();
		n = array_channel_number_to_analyse[i];
		setSlice(n);
		run("Duplicate...", "duplicate channels=n");
		Clear_outside = getBoolean("Do you need to analyse just one part of this image/images?");
		if (Clear_outside == 1) {
			setTool("rectangle");
			waitForUser("Please select the area of the image you want to analyse");
			run("ROI Manager...");
			roiManager("Add");
			roiManager("Save", image_location + "ROI.zip");
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
			run("Select All");
			roiManager("Add");
			roiManager("Save", image_location + "ROI.zip");
		}
	}


	//Lusca
	if (Lusca == 1) {
		close("*");
		//classifier name and location
		Dialog.create("Classifier and probability maps");
		Dialog.addString("Classifier name:", "");
		Dialog.addNumber("Classe (image segment) count for the analysis?", "");
		Dialog.show();
		array_classifier_name[i] = Dialog.getString();
		array_number_images_probmap[i] = Dialog.getNumber();
			
		for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
			Dialog.create("Quantification data");
			Dialog.addNumber("Class (image segment) for analysis?", "");
			Dialog.addString("Name of the segment for analysis", "");
			Dialog.addMessage("\n");
			Dialog.addNumber("Minimum threshold value:", "");
			Dialog.addNumber("Maximum threshold value:", "");
			Dialog.addNumber("Minimum particle size:", "");
			Dialog.addNumber("Maximum particle size:", "");
			if (Image_dimension == "2D") {
				Dialog.addNumber("Particle circularity value:", "");
			}
			Dialog.addCheckbox("	Exclude on the edges", false);
			Dialog.addMessage("\n");
			Dialog.addMessage("Type of quantification:");
			Dialog.addCheckbox("	Neural projections", false);
			Dialog.addCheckbox("	Soma and nuclei", false);
			Dialog.addCheckbox("	Area, Number and Intensity",false);
			Dialog.addCheckbox("	Length", false);
			Dialog.addCheckbox("	Width", false);
			Dialog.addCheckbox("	Colocalization with classes", false);
			Dialog.show();
				
			array_probmap[i*100+j] = Dialog.getNumber();
			array_probmap_name[i*100+j] = Dialog.getString();
			array_image_quantification[10000 + i * 100 + j] = Dialog.getNumber();
			array_image_quantification[20000 + i * 100 + j] = Dialog.getNumber();
			array_image_quantification[30000 + i * 100 + j] = Dialog.getNumber();
			array_image_quantification[40000 + i * 100 + j] = Dialog.getNumber();
			if (Image_dimension == "2D") {
				array_image_quantification[50000 + i * 100 + j] = Dialog.getNumber();
			}
			array_image_quantification[60000+i*100+j] = Dialog.getCheckbox();
			Neural_projections = Dialog.getCheckbox();
			Soma_and_nuclei = Dialog.getCheckbox();
			Size_Number_Intensity = Dialog.getCheckbox(); 
			Length = Dialog.getCheckbox();
			Width = Dialog.getCheckbox();
			Colocalization_class = Dialog.getCheckbox();
			array_image_quantification[70000+i*100+j] = Neural_projections;
			array_image_quantification[80000+i*100+j] = Soma_and_nuclei;
			array_image_quantification[90000+i*100+j] = Size_Number_Intensity;
			array_image_quantification[100000+i*100+j] = Length;
			array_image_quantification[110000+i*100+j] = Width;
			array_image_quantification[1200000+i*100+j] = Colocalization_class;
			
			//formation of the "Results" folder
			results_location_probmap = image_location + "Channel_" + array_channel_name[i] +"_Image segment_" + array_probmap_name[i*100+j];
			File.makeDirectory(results_location_probmap);
			array_results_location[i*100+j] = results_location_probmap;
			
			
			if (Neural_projections+Width >= 1) {
				Dialog.create("Width quantification data");
				Dialog.addNumber("Number of bins:", "");
				Dialog.addNumber("Minimum histogram number:", "");
				Dialog.addNumber("Maximum histogram number:", "");
				Dialog.show();
				array_width[1] = Dialog.getNumber();
				array_width[2] = Dialog.getNumber();
				array_width[3] = Dialog.getNumber();	
			}


			if (Soma_and_nuclei == 1) {
				if (Image_type == "Single image") {
					Dialog.create("Nuclei images folder");
					Dialog.addMessage("Please, select the folder where nuclei images are placed");
					Dialog.show();
					DAPI_image_location = getDirectory("Choose the folder where the nuclei images are placed");
					DAPI_list_images = getFileList(DAPI_image_location);
				}	
				else {
					Dialog.create("Nuclei channel");
					Dialog.addNumber("Nuclei channel", "");
					Dialog.show();
					nuclei_channel_number = Dialog.getNumber();
				}
					
				//classifier name and location, intensity, size and circularity thresholds
				Dialog.create("Nuclei quantification data");
				Dialog.addString("Classifier name:", "");
				Dialog.addMessage("\n");
				Dialog.addNumber("Minimun threshold value:", "");
				Dialog.addNumber("Maximum threshold value:", "");
				Dialog.addNumber("Minimun particle size:", "");
				Dialog.addNumber("Maximum particle size:", "");
				if (Image_dimension == "2D") {
					Dialog.addNumber("Particle circularity value:", "");
				}
				Dialog.show();
				array_DAPI[1] = Dialog.getString();
				array_DAPI[3] = Dialog.getNumber();
				array_DAPI[4] = Dialog.getNumber();
				array_DAPI[5] = Dialog.getNumber();
				array_DAPI[6] = Dialog.getNumber();
				if (Image_dimension == "2D") {
					array_DAPI[7] = Dialog.getNumber();
				}
			}


			if (Colocalization_class == 1) {
				Dialog.create("Segments for colocalization");
				Dialog.addNumber("Number of colocalization analysis with this segment as the first image:", "");
				Dialog.show();
				Colocalization_class_number = Dialog.getNumber();
						
				for (cs = 1; cs <= Colocalization_class_number; cs++) {
					if (Image_type == "Single image") {
						Dialog.create("Colocalization images folder");
						Dialog.addMessage("Please, select the folder where second colocalization images are placed");
						Dialog.show();
						array_colocalization_image_location[cs] = getDirectory("Choose the folder where the images are placed");
					}
					else {
						Dialog.create("Second colocalization channel");
						Dialog.addNumber("Second colocalization channel", "");
						Dialog.show();
						array_colocalization_channel_number[cs] = Dialog.getNumber();
					}

					//classifier name and location
					Dialog.create("Colocalization quantification data");
					Dialog.addString("Classifier name:", "");
					Dialog.addNumber("Channel for second image colocalization:", "");
					Dialog.addMessage("\n");
					Dialog.addNumber("Minimun threshold value:", "");
					Dialog.addNumber("Maximum threshold value:", "");
					Dialog.addNumber("Minimun particle size:", "");
					Dialog.addNumber("Maximum particle size:", "");
					if (Image_dimension == "2D") {
						Dialog.addNumber("Particle circularity value:", "");
					}	
					Dialog.show();
					array_colocalization_class[cs*1000+1] = Dialog.getString();
					array_colocalization_class_segment_number[cs] = Dialog.getNumber();
					array_colocalization_class[cs*1000+3] = Dialog.getNumber();
					array_colocalization_class[cs*1000+4] = Dialog.getNumber();
					array_colocalization_class[cs*1000+5] = Dialog.getNumber();
					array_colocalization_class[cs*1000+6] = Dialog.getNumber();
					if (Image_dimension == "2D") {
						array_colocalization_class[cs*1000+7] = Dialog.getNumber();
					}
				}
			}
		}
	}



	//Lusca - interactive part
	if (Lusca_interactive == 1) {
		if (Clear_outside_overall == 0) {
			open(fullpath_image);
			first_image = getTitle();
			n = array_channel_number_to_analyse[i];
			setSlice(n);
			run("Duplicate...", "duplicate channels=n");
		}
		
		//Trainable Weka Segmentation - classifier formation and saving
		waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");			
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

		//classifier name, location and probability maps formation
		Dialog.create("Classifier name and Probability maps");
		Dialog.addString("Classifier name:", "");
		Dialog.addNumber("Total count of clases for the analysis?", "");
		Dialog.show();
		array_classifier_name[i] = Dialog.getString();
		array_number_images_probmap[i] = Dialog.getNumber();
		call("trainableSegmentation.Weka_Segmentation.getProbability");
		close(TWS);

		for (j = 1; j <= array_number_images_probmap[i]; j+=1) {
			Dialog.create("Probability maps data");
			Dialog.addNumber("Number of class for the analysis?", "");
			Dialog.addString("Name of segment for the analysis", "");
			Dialog.show();
			array_probmap[i*100+j] = Dialog.getNumber();
			array_probmap_name[i*100+j] = Dialog.getString();
				
			//formation of the "Results" folder
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
			
			//threshold setting
			run("Threshold...");
			waitForUser("Press OK when you found the right threshold");
			Dialog.create("Threshold");
			Dialog.addNumber("Minimun threshold value:", "");
			Dialog.addNumber("Maximum threshold value:", "");
			Dialog.show();
			Min_threshold = Dialog.getNumber();
			Max_threshold = Dialog.getNumber();
			array_image_quantification[10000+i*100+j] = Min_threshold;
			array_image_quantification[20000+i*100+j] = Max_threshold;

			//min and max object setting
			setThreshold(Min_threshold, Max_threshold);
			setOption("BlackBackground", true);
			run("Convert to Mask", "method=Default background=Dark black");
			image = getTitle();
			
			particle_set = getBoolean("Do you have min and max particle dimension?");
				
			if (Image_dimension == "2D") {	
				while (particle_set == 0) {
					selectWindow(image);
					Dialog.create("Area");
					Dialog.addNumber("Minimun particle area:", "");
					Dialog.addNumber("Maximum particle area:", "");
					Dialog.addNumber("Particle circularity value:", "");
					Dialog.addCheckbox("	Exclude on the edges", false);
					Dialog.show();
					Min = Dialog.getNumber();
					Max = Dialog.getNumber();
					Circularity = Dialog.getNumber();
					Exclude = Dialog.getCheckbox();
					run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
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
			else {
				while (particle_set == 0) {
					selectWindow(image);
					run("Duplicate...", "title=duplicate duplicate");
					Dialog.create("Volume");
					Dialog.addNumber("Minimun particle volume:", "");
					Dialog.addNumber("Maximum particle volume:", "");
					Dialog.addCheckbox("	Exclude on the edges", false);
					Dialog.show();
					Min = Dialog.getNumber();
					Max = Dialog.getNumber();
					Exclude = Dialog.getCheckbox();
					run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
					selectWindow(image);
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
					
			Dialog.create("Size");
			Dialog.addNumber("Minimun particle size:", "");
			Dialog.addNumber("Maximum particle size:", "");
			if (Image_dimension == "2D") {
				Dialog.addNumber("Paricle circularity value:", "");
			}
			Dialog.addCheckbox("	Exclude on the edges", false);
			Dialog.show();
			array_image_quantification[30000+i*100+j] = Dialog.getNumber();
			array_image_quantification[40000+i*100+j] = Dialog.getNumber();
			if (Image_dimension == "2D") {
				array_image_quantification[50000+i*100+j] = Dialog.getNumber();
			}
			array_image_quantification[60000+i*100+j] = Dialog.getCheckbox();

			//type of quantification
			Dialog.create("Image quantification");
			Dialog.addMessage("Select the type of quantification for the image");
			Dialog.addCheckbox("	Neural projections", false);
			Dialog.addCheckbox("	Soma and nuclei", false);
			Dialog.addCheckbox("	Size, Number and Intensity",false);
			Dialog.addCheckbox("	Length", false);
			Dialog.addCheckbox("	Width", false);
			Dialog.addCheckbox("	Colocalization with classes", false);
			Dialog.show();
			Neural_projections = Dialog.getCheckbox();
			Soma_and_nuclei = Dialog.getCheckbox();
			Size_Number_Intensity = Dialog.getCheckbox(); 
			Length = Dialog.getCheckbox();
			Width = Dialog.getCheckbox();
			Colocalization_class = Dialog.getCheckbox();
			array_image_quantification[70000+i*100+j] = Neural_projections;
			array_image_quantification[80000+i*100+j] = Soma_and_nuclei;
			array_image_quantification[90000+i*100+j] = Size_Number_Intensity;
			array_image_quantification[100000+i*100+j] = Length;
			array_image_quantification[110000+i*100+j] = Width;
			array_image_quantification[1200000+i*100+j] = Colocalization_class;


			if (Neural_projections+Width >= 1) {
				Min = array_image_quantification[30000+i*100+j];
				Max = array_image_quantification[40000+i*100+j];
					
				//selectWindow(image);
				if (Image_dimension == "2D") {
					selectWindow(image);
					run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
					if (array_image_quantification[60000+i*100+j] == 1) {
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks exclude");
					}
					else {
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks");
					}
				}
				else {
					selectWindow(image);
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
					selectWindow(image);
					run("Duplicate...", "duplicate");
					Dialog.create("Width quantification data");
					Dialog.addNumber("Number of bins:", "");
					Dialog.addNumber("Minimum histogram number:", "");
					Dialog.addNumber("Maximum histogram number:", "");
					Dialog.show();
					nBins = Dialog.getNumber();
					histMin = Dialog.getNumber();
					histMax = Dialog.getNumber();
						
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
					close("Histogram of Result");
					width_set = getBoolean("Do you have needed data (number of bins, minimum and maximum number for histogram) for width calculation?");
				}
					
				Dialog.create("Width quantification data");
				Dialog.addNumber("Number of bins:", "");
				Dialog.addNumber("Minimum histogram number:", "");
				Dialog.addNumber("Maximum histogram number:", "");
				Dialog.show();
				array_width[1] = Dialog.getNumber();
				array_width[2] = Dialog.getNumber();
				array_width[3] = Dialog.getNumber();	
				W1 = "W1";
			}


			if (Soma_and_nuclei == 1) {
				if (Image_type == "Single image") {
					Dialog.create("Nuclei images folder");
					Dialog.addMessage("Please, select the folder where nuclei images are placed");
					Dialog.show();
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
					n = nuclei_channel_number;
					setSlice(n);
					run("Duplicate...", "duplicate channels=n");
				}
					
				//clear outside
				if (Clear_outside_overall == 1) {
					if (Image_dimension == "2D") {
						roiManager("Select", i-1);
						setBackgroundColor(0, 0, 0);
						run("Clear Outside");
					}
					else {
						Stack.getDimensions(width, height, channels, slices, frames);
						slice_number = slices;
						for (c = 1; c < slice_number; c++) {
							setSlice(c);
							roiManager("Select", i-1);
							setBackgroundColor(0, 0, 0);
							run("Clear Outside", "stack");
						}
					}
				}
				
				nuclei_title = getTitle();
				//Trainable Weka Segmentation - classifier formation and saving
				waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
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
				
				//classifier name, location and probability maps formation
				Dialog.create("Classifier - nuclei");
				Dialog.addString("Classifier name:", "");
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

				//threshold setting			
				run("Threshold...");
				waitForUser("Press OK when you found the right threshold");
				Dialog.create("Threshold - nuclei");
				Dialog.addNumber("Minimun threshold value:", "");
				Dialog.addNumber("Maximum threshold value:", "");
				Dialog.show();
				Min_threshold = Dialog.getNumber();
				Max_threshold = Dialog.getNumber();
				array_DAPI[3] = Min_threshold;
				array_DAPI[4] = Max_threshold;

				//min and max object setting
				setThreshold(Min_threshold, Max_threshold);
				setOption("BlackBackground", true);
				run("Convert to Mask", "method=Default background=Dark black");
				DAPI_image = getTitle();
					
				particle_set = getBoolean("Do you have min and max particle dimension?");
					
				if (Image_dimension == "2D") {
					while (particle_set == 0) {
						selectWindow(DAPI_image);
						Dialog.create("Area");
						Dialog.addNumber("Minimun particle area:", "");
						Dialog.addNumber("Maximum particle area:", "");
						Dialog.addNumber("Particle circularity value:", "");
						Dialog.show();
						Min = Dialog.getNumber();
						Max = Dialog.getNumber();
						Circularity = Dialog.getNumber();
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
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
				else {
					while (particle_set == 0) {
						selectWindow(DAPI_image);
						run("Duplicate...", "title=duplicate duplicate");
						Dialog.create("Volume");
						Dialog.addNumber("Minimun particle volume:", "");
						Dialog.addNumber("Maximum particle volume:", "");
						Dialog.show();
						Min = Dialog.getNumber();
						Max = Dialog.getNumber();
						run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
						selectWindow(DAPI_image);
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
						
				Dialog.create("Size - nuclei");
				Dialog.addNumber("Minimun particle size:", "");
				Dialog.addNumber("Maximum particle size:", "");
				if (Image_dimension == "2D") {
					Dialog.addNumber("Particle circularity value:", "");
				}
				Dialog.show();
				array_DAPI[5] = Dialog.getNumber();
				array_DAPI[6] = Dialog.getNumber();
				if (Image_dimension == "2D") {
					array_DAPI[7] = Dialog.getNumber();
				}
				close(nuclei_title);
				close(DAPI_image);
			}


			if (Colocalization_class == 1) {
				Dialog.create("Segments for colocalization");
				Dialog.addNumber("Number of colocalization analysis with this segment as the first image:", "");
				Dialog.show();
				Colocalization_class_number = Dialog.getNumber();
						
				for (cs = 1; cs <= Colocalization_class_number; cs++) {
					if (Image_type == "Single image") {
						Dialog.create("Colocalization images folder");
						Dialog.addMessage("Please, select the folder where second colocalization images are placed");
						Dialog.show();
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
						array_colocalization_channel_number[cs] = Dialog.getNumber();
						selectWindow(first_image);
						n = array_colocalization_channel_number[cs];
						setSlice(n);
						run("Duplicate...", "duplicate channels=n");
					}
						
					//clear outside
					if (Clear_outside_overall == 1) {
						if (Image_dimension == "2D") {
							roiManager("Select", i-1);
							setBackgroundColor(0, 0, 0);
							run("Clear Outside");
						}
						else {
							Stack.getDimensions(width, height, channels, slices, frames);
							slice_number = slices;
							for (c = 1; c < slice_number; c++) {
								setSlice(c);
								roiManager("Select", i-1);
								setBackgroundColor(0, 0, 0);
								run("Clear Outside", "stack");
							}
						}
					}
					
					coloc_title = getTitle();
					//Trainable Weka Segmentation - classifier formation and saving
					waitForUser("Trainable Weka Segmentation will be opened, please make and save your classifier \nPlease adjust input parameters in settings");
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

					//classifier name, location and probability maps formation
					Dialog.create("Classifier - colocalization");
					Dialog.addString("Classifier name:", "");
					Dialog.show();
					array_colocalization_class[cs*1000+1] = Dialog.getString();	
					call("trainableSegmentation.Weka_Segmentation.getProbability");

					//probability class channel selection
					Dialog.create("Channel for colocalization");
					Dialog.addNumber("Channel for second image colocalization:", "");
					Dialog.show();
					array_colocalization_class_segment_number[cs] = Dialog.getNumber();
					n = array_colocalization_class_segment_number[cs];
					setSlice(n);						
					if (Image_dimension == "2D") {
						run("Duplicate...", "title=Colocalization");
					}
					else {
						run("Duplicate...", "title=Colocalization duplicate channels=n");
					}
					close(TWS);
					close("Probability maps");
							
					//threshold setting
					run("Threshold...");
					waitForUser("Press OK when you found the right threshold");
					Dialog.create("Threshold - colocalization");
					Dialog.addNumber("Minimun threshold value:", "");
					Dialog.addNumber("Maximum threshold value:", "");
					Dialog.show();
					Min_threshold = Dialog.getNumber();
					Max_threshold = Dialog.getNumber();
					array_colocalization_class[cs*1000+3] = Min_threshold;
					array_colocalization_class[cs*1000+4] = Max_threshold;

					//min and max object setting
					setThreshold(Min_threshold, Max_threshold);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					Colocalization_class_image = getTitle();						
					particle_set = getBoolean("Do you have min and max particle dimension?");
		
					if (Image_dimension == "2D") {
						while (particle_set == 0) {
							selectWindow(Colocalization_class_image);
							Dialog.create("Area");
							Dialog.addNumber("Minimun particle area:", "");								
							Dialog.addNumber("Maximum particle area:", "");
							Dialog.addNumber("Particle circularity vale:", "");
							Dialog.show();
							Min = Dialog.getNumber();
							Max = Dialog.getNumber();
							Circularity = Dialog.getNumber();
							run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=None decimal=3");
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
					else {
						while (particle_set == 0) {
							selectWindow(Colocalization_class_image);
							run("Duplicate...", "title=duplicate duplicate");
							Dialog.create("Volume");
							Dialog.addNumber("Minimun particle volume:", "");
							Dialog.addNumber("Maximum particle volume:", "");
							Dialog.show();
							Min = Dialog.getNumber();
							Max = Dialog.getNumber();
							run("3D OC Options", "volume surface integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate");
							selectWindow(Colocalization_class_image);
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

					Dialog.create("Colocalization quantification data");
					Dialog.addNumber("Minimun particle size:", "");
					Dialog.addNumber("Maximum particle size:", "");
					if (Image_dimension == "2D") {
						Dialog.addNumber("Particle circularity value:", "");
					}
					Dialog.show();
					array_colocalization_class[cs*1000+5] = Dialog.getNumber();
					array_colocalization_class[cs*1000+6] = Dialog.getNumber();
					if (Image_dimension == "2D") {
						array_colocalization_class[cs*1000+7] = Dialog.getNumber();
					}
					close(coloc_title);
					close(Colocalization_class_image);
				}
			}
		}
		close("*");
		close("Threshold");
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

counter = 0;
counter_col = 0;

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

	for (j = 1; j <= Channel_number; j++) {
		selectWindow(first_image_title);
		n = array_channel_number_to_analyse[j];
		setSlice(n);
		run("Duplicate...", "title=IMAGE duplicate channels=n");
		
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
		run("Select None");
		
			
		if (Lusca+Lusca_interactive == 1) {
			selectWindow("IMAGE");
			
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
//			saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
			run("Duplicate...", "title=Prob_map_Lusca duplicate");
			title_prob_map = getTitle();
			close(TWS);
			close("Probability maps");
	
			for (k = 1; k <= array_number_images_probmap[j]; k++) {
				results_location = array_results_location[j*100+k];
				selectWindow(title_prob_map);
				n = array_probmap[j*100+k];
				setSlice(n); 
				if (Image_dimension == "2D") {
					run("Duplicate...", "use");
					setThreshold(array_image_quantification[10000+j*100+k], array_image_quantification[20000+j*100+k]);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					threshold_mask = getTitle();
					Min = array_image_quantification[30000+j*100+k];
					Max = array_image_quantification[40000+j*100+k];
					Circularity = array_image_quantification[50000+j*100+k];
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[90000+j*100+k] >= 1) {
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3");
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display exclude summarize");
						}
						else {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display summarize");
						}
						saveAs("Tiff", results_location+"\\"+first_image_title+" - origin image");
						origin_image = getTitle();
						//selectWindow("Results");
						//saveAs("Results", results_location+"\\"+first_image_title+" - results of area, number and intensity.csv");
						close("Results");
						close(threshold_mask);
						selectWindow("Summary");
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
//						saveAs("Results", results_location+"\\"+first_image_title+" - summary of area, number and intensity.csv");
//						close(first_image_title+" - summary of area, number and intensity.csv");
					}	
					else {
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3");
						run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks");
						saveAs("Tiff", results_location+"\\"+first_image_title+" - origin image");
						origin_image = getTitle();
					}
				}
				else {
					run("Duplicate...", "duplicate channels=n");
					setThreshold(array_image_quantification[10000+j*100+k], array_image_quantification[20000+j*100+k]);
					setOption("BlackBackground", true);
					run("Convert to Mask", "method=Default background=Dark black");
					threshold_mask = getTitle();
					Min = array_image_quantification[30000+j*100+k];
					Max = array_image_quantification[40000+j*100+k];
					run("Duplicate...", "title=D duplicate");
					selectImage(threshold_mask);
					run("Set Scale...", "unit=unit");
					run("3D OC Options", "volume surface show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=D");
					if (array_image_quantification[60000+j*100+k] == 1) {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges statistics");
					}
					else {
						run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
					}
					table_name = "Statistics for " + threshold_mask + " redirect to D";
					
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[90000+j*100+k] >= 1) {
						IJ.renameResults(table_name,"Results");
						Count = nResults;
						Total_Surface = 0;
						for(sur=0; sur<nResults; sur++) {
							Total_Surface += getResult("Surface (unit^2)", sur);
						}
						close("Results");
						close(threshold_mask);
						close("D");
						saveAs("Tiff", results_location+"\\"+first_image_title+" - origin image");
						origin_image = getTitle();
						run("Duplicate...", "title=D duplicate");
						
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background", "stack");
						run("Subtract...", "value=255 stack");
						imageCalculator("Add create stack", "D","IMAGE");
						
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
//						saveAs("Results", results_location+"\\"+first_image_title+" - results of volume, number and intensity.csv");
//						close(first_image_title+" - results of volume, number and intensity.csv");
					}
					else {
						close("Statistics for threshold_mask");
						close(threshold_mask);
						close("D");
						close(table_name);
						saveAs("Tiff", results_location+"\\"+first_image_title+" - origin image");
						origin_image = getTitle();
					}
				}


				//neural porjections or length
				if (array_image_quantification[70000+j*100+k] + array_image_quantification[100000+j*100+k] >= 1) {
					selectWindow(origin_image);
					run("Duplicate...", "duplicate");
					run("Skeletonize (2D/3D)");
					skeleton = getTitle();
					run("Summarize Skeleton");
					IJ.renameResults("Skeleton Stats","Results");
					Total_Length = getResult("Total length", 0);
					Max_Branch_Length = getResult("Max branch length", 0);
					Mean_Branch_Length = getResult("Mean branch length", 0);
					Number_Of_Branches = getResult("# Branches", 0);
					Number_Of_Junctions = getResult("# Junctions", 0);
					Number_Of_Endpoints = getResult("# End-points", 0);
					close("Results");
					close(skeleton);
//					saveAs("Results", results_location+"\\"+first_image_title+" - skeleton summary.csv");
//					close(first_image_title+" - skeleton summary.csv");
//					run("Analyze Skeleton (2D/3D)", "prune=none show");
//					saveAs("Tiff", results_location+"\\"+first_image_title+" - skeleton");
//					selectWindow("Branch information");
//					saveAs("Results", results_location+"\\"+first_image_title+" - branch information.csv");
//					close(first_image_title+" - branch information.csv");
//					selectWindow("Results");
//					saveAs("Results", results_location+"\\"+first_image_title+" - results from skeleton.csv");
//					close("Results");
				}


				//neural projections or width
				if (array_image_quantification[70000+j*100+k] + array_image_quantification[110000+j*100+k] >= 1) {
					selectWindow(origin_image);
					run("Duplicate...", "title=W1 duplicate");
					run("Duplicate...", "title=W2 duplicate");
					selectWindow("W1");
					run("Local Thickness (masked, calibrated, silent)");
//					saveAs("Tiff", results_location+"\\"+first_image_title+" - Local Thickness");
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
//					saveAs("Tiff", results_location+"\\"+first_image_title+" - skeletons of Local Thickness");
					W_F = getTitle();
					run("Set Measurements...", "mean min median redirect=None decimal=3");
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
					histogram = getTitle();
					close(histogram);
					close("Result of W2");
					W1 = "W1";
				}


				//soma and nuclei
				if (array_image_quantification[80000+j*100+k] == 1) {
					//opening nuclei image
					if (Image_type == "Single image") {
						fullpath_DAPI_image = DAPI_image_location + DAPI_list_images[i-1];
						open(fullpath_DAPI_image);
						nuclei = getTitle();
						run("Duplicate...", "title=DAPI_IMAGE duplicate");
						close(nuclei);
					}
					else {
						selectWindow(first_image_title);
						setSlice(nuclei_channel_number);
						n = nuclei_channel_number;
						run("Duplicate...", "title=DAPI_IMAGE duplicate channels=n");
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
					run("Select None");
	
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
//					saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
					close(TWS);
		
					setSlice(1);
					if (Image_dimension == "2D") {
						run("Duplicate...", "use");
						setThreshold(array_DAPI[3], array_DAPI[4]);
						setOption("BlackBackground", true);
						run("Convert to Mask", "method=Default background=Dark black");
						threshold_mask_DAPI = getTitle();
						Min = array_DAPI[5];
						Max = array_DAPI[6];
						Circularity = array_DAPI[7];
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=DAPI_IMAGE decimal=3");
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display exclude summarize");
						}
						else {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display summarize");
						}
						saveAs("Tiff", results_location+"\\"+first_image_title+" - origin nuclei image");
						origin_DAPI_image = getTitle();
						//selectWindow("Results");
						//saveAs("Results", results_location+"\\"+first_image_title+" - results of nuclei area and number.csv");
						//close("Results");
						selectWindow("Summary");
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
//						saveAs("Results", results_location+"\\"+first_image_title+" - summary of nuclei area and number.csv");
//						close(first_image_title+" - summary of nuclei area and number.csv");
					}			
					else {
						run("Duplicate...", "duplicate channels=1");
						setThreshold(array_DAPI[3], array_DAPI[4]);
						setOption("BlackBackground", true);
						run("Convert to Mask", "method=Default background=Dark black");
						threshold_mask_DAPI = getTitle();
						Min = array_DAPI[5];
						Max = array_DAPI[6];
						run("Duplicate...", "title=DAPI_D duplicate");
						selectImage(threshold_mask_DAPI);
						run("Set Scale...", "unit=unit");
						run("3D OC Options", "volume surface show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=DAPI_D");
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges statistics");
						}
						else {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
						}

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
						saveAs("Tiff", results_location+"\\"+first_image_title+" - origin nuclei image");
						origin_DAPI_image = getTitle();
						run("Duplicate...", "title=DAPI_D duplicate");
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background", "stack");
						run("Subtract...", "value=255 stack");
						imageCalculator("Add create stack", "DAPI_D","DAPI_IMAGE");
						intenzity_mask_DAPI = getTitle();
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
//						saveAs("Results", results_location+"\\"+first_image_title+" - results of volume, number and intensity.csv");
//						close(first_image_title+" - results of volume, number and intensity.csv");
					}
					close("Probability maps");
					close("DAPI_IMAGE");
				
					//image calculator
					run("Options...", "iterations=2 count=1 black do=Erode stack");
					origin_DAPI_image = getTitle();;
					imageCalculator("AND create stack", origin_image,origin_DAPI_image);
					threshold_mask_soma = getTitle();
	
					if (Image_dimension == "2D") {
						Min = array_image_quantification[30000+j*100+k];
						Max = array_image_quantification[40000+j*100+k];
						Circularity = array_image_quantification[50000+j*100+k];
						run("Set Measurements...", "area mean standard modal min fit shape integrated median area_fraction limit redirect=IMAGE decimal=3");
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display exclude summarize");
						}
						else {
							run("Analyze Particles...", "size=Min-Max circularity=Circularity show=Masks display summarize");
						}
						saveAs("Tiff", results_location+"\\"+first_image_title+" - final soma image");
						origin_soma_image = getTitle();
						//selectWindow("Results");
						//saveAs("Results", results_location+"\\"+first_image_title+" - results of soma area and number.csv");
						close("Results");
						close(threshold_mask_soma);
						selectWindow("Summary");
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
//						saveAs("Results", results_location+"\\"+first_image_title+" - summary of soma area and number.csv");
//						close(first_image_title+" - summary of soma area and number.csv");				
					}			
					else {
						Min = array_image_quantification[30000+j*100+k];
						Max = array_image_quantification[40000+j*100+k];
						run("Duplicate...", "title=soma_D duplicate");
						selectImage(threshold_mask_soma);
						run("Set Scale...", "unit=unit");
						run("3D OC Options", "volume surface show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=soma_D");
						if (array_image_quantification[60000+j*100+k] == 1) {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max exclude_objects_on_edges statistics");
						}
						else {
							run("3D Objects Counter", "threshold=1 slice=1 min.=Min max.=Max statistics");
						}

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
						saveAs("Tiff", results_location+"\\"+first_image_title+" - final soma image");
						origin_soma_image = getTitle();
						run("Duplicate...", "title=soma_D duplicate");
						run("32-bit");
						setAutoThreshold("Default dark");
						setThreshold(1.00, 1e30);
						run("NaN Background", "stack");
						run("Subtract...", "value=255 stack");
						imageCalculator("Add create stack", "soma_D","IMAGE");
						intenzity_mask_soma = getTitle();
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
//						saveAs("Results", results_location+"\\"+first_image_title+" - results of volume, number and intensity.csv");
//						close(first_image_title+" - results of volume, number and intensity.csv");
					}
					close(origin_DAPI_image);
					close(origin_soma_image);
				}


				//colocalization class
				if (array_image_quantification[1200000+j*100+k] == 1) {
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
					
					//coloc loop
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
//						saveAs("Tiff", results_location+"\\"+first_image_title+" - probability maps");
						close(TWS);
						n = array_colocalization_class_segment_number[cc];
						setSlice(n);
			
						if (Image_dimension == "2D") {
							run("Duplicate...", "use");
							setThreshold(array_colocalization_class[cc*1000+3], array_colocalization_class[cc*1000+4]);
							setOption("BlackBackground", true);
							run("Convert to Mask", "method=Default background=Dark black");
							threshold_mask_coloc = getTitle();
							Min = array_colocalization_class[cc*1000+5];
							Max = array_colocalization_class[cc*1000+6];
							Circularity = array_colocalization_class[cc*1000+7];
							run("Set Measurements...", "area redirect=None decimal=3");
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
						else {
							run("Duplicate...", "duplicate channels=n");
							setThreshold(array_colocalization_class[cc*1000+3], array_colocalization_class[cc*1000+4]);
							setOption("BlackBackground", true);
							run("Convert to Mask", "method=Default background=Dark black");
							threshold_mask_coloc = getTitle();						
							Min = array_colocalization_class[cc*1000+5];
							Max = array_colocalization_class[cc*1000+6];
							Colocalization_title = getTitle();
							run("Duplicate...", "title=duplicate_COLOC duplicate");
							selectWindow(threshold_mask_coloc);
							run("Set Scale...", "unit=unit");
							run("3D OC Options", "volume show_masked_image_(redirection_requiered) dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=duplicate_COLOC");
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
						
						origin_image_B = getTitle();
						imageCalculator("AND create stack", origin_image,origin_image_B);
						origin_image_C = getTitle();
			
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
						
						sM1 = Area_Volume_Segmented_C/Area_Volume_Segmented_A;
						sM2 = Area_Volume_Segmented_C/Area_Volume_Segmented_B;
						
						if (counter_col ==0) {
							setResult("First image", counter_col, first_image_title);
							setResult("Second image", counter_col, title_Colocalization_intensity);
							setResult("segmented M1", counter_col, sM1);
							setResult("segmented M2", counter_col, sM2);
							updateResults();
							IJ.renameResults("Results","Colocalization measurements");
						}
						else {
							IJ.renameResults("Colocalization measurements", "Results");
							setResult("First image", counter_col, first_image_title);
							setResult("Second image", counter_col, title_Colocalization_intensity);
							setResult("segmented M1", counter_col, sM1);
							setResult("segmented M2", counter_col, sM2);
							updateResults();
							IJ.renameResults("Results","Colocalization measurements");
						}
						counter_col += 1;
						close(title_Colocalization_intensity);
						close(origin_image_B);
						close(origin_image_C);
					}
				}
				
				
				//formation of results table
				if (counter == 0) {		
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[80000+j*100+k]+array_image_quantification[90000+j*100+k]+array_image_quantification[100000+j*100+k]+array_image_quantification[110000+j*100+k] >= 1) {
						setResult("No", counter, counter+1);
						setResult("Image", counter, first_image_title);
						setResult("Channel number", counter, array_channel_number_to_analyse[j]);
						setResult("Probability map class", counter, array_probmap[j*100+k]);
					}		
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[90000+j*100+k] >= 1) {
						setResult("Count", counter, Count);
						setResult("Total Area/Volume", counter, Total_Area_Volume);
						if (Image_dimension == "3D") {
							setResult("Total Surface", counter, Total_Surface);
						}
						setResult("Average Area/Volume", counter, Average_Size);
						setResult("Percentage Area/Volume", counter, Percentage_Area_Volume);
						setResult("Mean Intensity", counter, Mean);
						setResult("Median Intensity", counter, Median);
						setResult("Mode Intensity", counter, Mode);
						setResult("Circularity/Sphericity", counter, Circ_Sph);
					}
					if (array_image_quantification[80000+j*100+k] == 1) {
						setResult("Soma Count", counter, Count_soma);
						setResult("Soma Total Area/Volume", counter, Total_Area_Volume_soma);
						if (Image_dimension == "3D") {
							setResult("Soma Total Surface", counter, Total_Surface_soma);
						}
						setResult("Soma Average Area/Volume", counter, Average_Size_soma);
						setResult("Soma Percentage Area/Volume", counter, Percentage_Area_Volume_soma);
						setResult("Soma Mean Intensity", counter, Mean_soma);
						setResult("Soma Median Intensity", counter, Median_soma);
						setResult("Soma Mode Intensity", counter, Mode_soma);
						setResult("Soma Circularity/Sphericity", counter, Circ_Sph_soma);
						setResult("Nuclei Count", counter, Count_DAPI);
						setResult("Nuclei Total Area/Volume", counter, Total_Area_Volume_DAPI);
						if (Image_dimension == "3D") {
							setResult("Nuclei Total Surface", counter, Total_Surface_DAPI);
						}
						setResult("Nuclei Average Area/Volume", counter, Average_Size_DAPI);
						setResult("Nuclei Percentage Area/Volume", counter, Percentage_Area_Volume_DAPI);
						setResult("Nuclei Mean Intensity", counter, Mean_DAPI);
						setResult("Nuclei Median Intensity", counter, Median_DAPI);
						setResult("Nuclei Mode Intensity", counter, Mode_DAPI);
						setResult("Nuclei Circularity/Sphericity", counter, Circ_Sph_DAPI);
					}
					if (array_image_quantification[70000+j*100+k] + array_image_quantification[100000+j*100+k] >= 1) {
						setResult("Total length", counter, Total_Length);
						setResult("Max branch length", counter, Max_Branch_Length);
						setResult("Mean branch length", counter, Mean_Branch_Length);
						setResult("Number of branches", counter, Number_Of_Junctions);
						setResult("Number of junctions", counter, Number_Of_Junctions);
						setResult("Number of endpoints", counter, Number_Of_Endpoints);
					}
					if (array_image_quantification[70000+j*100+k] + array_image_quantification[110000+j*100+k] >= 1) {
						setResult("Mean width", counter, Mean_width);
						setResult("Median width", counter, Median_width);
						setResult("Max width", counter, Min_width);
						setResult("Min width", counter, Max_width);
					}
					updateResults();
					IJ.renameResults("Results","All measurements");
				}
				else {
					IJ.renameResults("All measurements","Results");
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[80000+j*100+k]+array_image_quantification[90000+j*100+k]+array_image_quantification[100000+j*100+k]+array_image_quantification[110000+j*100+k] >= 1) {
						setResult("No", counter, counter+1);
						setResult("Image", counter, first_image_title);
						setResult("Channel number", counter, array_channel_number_to_analyse[j]);
						setResult("Probability map class", counter, array_probmap[j*100+k]);
					}	
					if (array_image_quantification[70000+j*100+k]+array_image_quantification[90000+j*100+k] >= 1) {
						setResult("Count", counter, Count);
						setResult("Total Area/Volume", counter, Total_Area_Volume);
						if (Image_dimension == "3D") {
							setResult("Total Surface", counter, Total_Surface);
						}
						setResult("Average Area/Volume", counter, Average_Size);
						setResult("Percentage Area/Volume", counter, Percentage_Area_Volume);
						setResult("Mean Intensity", counter, Mean);
						setResult("Median Intensity", counter, Median);
						setResult("Mode Intensity", counter, Mode);
						setResult("Circularity/Sphericity", counter, Circ_Sph);
					}
					if (array_image_quantification[80000+j*100+k] == 1) {
						setResult("Soma Count", counter, Count_soma);
						setResult("Soma Total Area/Volume", counter, Total_Area_Volume_soma);
						if (Image_dimension == "3D") {
							setResult("Soma Total Surface", counter, Total_Surface_soma);
						}
						setResult("Soma Average Area/Volume", counter, Average_Size_soma);
						setResult("Soma Percentage Area/Volume", counter, Percentage_Area_Volume_soma);
						setResult("Soma Mean Intensity", counter, Mean_soma);
						setResult("Soma Median Intensity", counter, Median_soma);
						setResult("Soma Mode Intensity", counter, Mode_soma);
						setResult("Soma Circularity/Sphericity", counter, Circ_Sph_soma);
						setResult("Nuclei Count", counter, Count_DAPI);
						setResult("Nuclei Total Area/Volume", counter, Total_Area_Volume_DAPI);
						if (Image_dimension == "3D") {
							setResult("Nuclei Total Surface", counter, Total_Surface_DAPI);
						}
						setResult("Nuclei Average Area/Volume", counter, Average_Size_DAPI);
						setResult("Nuclei Percentage Area/Volume", counter, Percentage_Area_Volume_DAPI);
						setResult("Nuclei Mean Intensity", counter, Mean_DAPI);
						setResult("Nuclei Median Intensity", counter, Median_DAPI);
						setResult("Nuclei Mode Intensity", counter, Mode_DAPI);
						setResult("Nuclei Circularity/Sphericity", counter, Circ_Sph_DAPI);
					}
					if (array_image_quantification[70000+j*100+k] + array_image_quantification[100000+j*100+k] >= 1) {
						setResult("Total length", counter, Total_Length);
						setResult("Max branch length", counter, Max_Branch_Length);
						setResult("Mean branch length", counter, Mean_Branch_Length);
						setResult("Number of branches", counter, Number_Of_Junctions);
						setResult("Number of junctions", counter, Number_Of_Junctions);
						setResult("Number of endpoints", counter, Number_Of_Endpoints);
					}
					if (array_image_quantification[70000+j*100+k] + array_image_quantification[110000+j*100+k] >= 1) {
						setResult("Mean width", counter, Mean_width);
						setResult("Median width", counter, Median_width);
						setResult("Max width", counter, Min_width);
						setResult("Min width", counter, Max_width);
					}
					updateResults();
					IJ.renameResults("Results","All measurements");
				}
				counter += 1;
				close(origin_image);
			}
			close("Prob_map_Lusca");
			close("IMAGE");
		}
	}
	close("*");
}

if (Colocalization_class == 1) {
	IJ.renameResults("Colocalization measurements", "Results");
	saveAs("Results", image_location+"\\"+"Colocalization results.csv");
	close("Colocalization results");
}
if (Lusca+Lusca_interactive == 1) {
	IJ.renameResults("All measurements","Results");
	saveAs("Results", image_location+"\\"+"Results.csv");
	close("Results");
	close("ROI Manager");
	close("Log");
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
