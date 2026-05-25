function [img_directory, output_directory, group] = NM_samples(sample, save_flag)
%--------------------------------------------------------------------------
% Record sample specific information here. Additionally, any default
% processing and/or analysis parameters can be overwritten as this function
% is called after defaults are loaded.
%--------------------------------------------------------------------------

switch sample

    case 'SAMPLE2'
        img_directory = "X:\Ryan\12-16-2024\OC3-T7-TAIL\numorph";
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["488nm", "561nm"];
        markers = ["GFP","RFP"];
        position_exp = [];        
        resolution = [0.65, 0.65, 20];
        ls_width = 50;
        overlap = 0.15;
        orientation = "";
        hemisphere = "";
    % only parameters required are noted 
        
    case 'TEST1'
        % Image directory can be specified as single location if able to
        % dismabiguate channels or as multiple locations pointing to each
        % individual channel
        img_directory = "/test_images";                 % Input image directory        
        output_directory = "/test_images/output";       % Directory to save results
        use_processed_images = false;
        group = ["TEST","WT","R1"];                     % Group name/id
        
        % Specify markers or channel_num or both based on which one is specified in the filename
        channel_num = ["C01","C00"];                         % Channel id
        markers = ["topro","ctip2"];                         % Name of markers present
        
        % If one tile, row/slice positions will be ignored if expression is not located in the filename
        position_exp = ["[\d*", "\d*]","Z\d*"];              % 1x3 string of regular expression specifying image row(y), column(x), slice(z)
        
        % If different resolutions, specify as cell array for each marker
        % (i.e. {[1.21, 1.21, 4], [3.86, 3.86, 4]} 
        resolution = [1.21, 1.21, 4];                        % Image reolution in um/voxel
        ls_width = 50;                                       % Light sheet width as percentage
        overlap = 0.15;                                      % Overlap between tiles as fraction
        
        % Orientation key: anterior(a)/posterior(p), superior(s)/inferior(i), left(l)/right(r)
        % Specified as location at row(y)=0, column(x)=0, slice(z)=0
        orientation = "ail";                                 % 1x3 string specifying sample orientation
        hemisphere = "left";                                 % "left","right","both","none"
   

    case 'TSC_10'    % sample name
        img_directory = "Y:/Fengyi/TSC_brain/sample10_reimg";    % path to dataset
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["730nm","561nm","640nm_30","640nm_5"];    % channel folder name for hierarchy input
        markers = ["Sox9","RFP","GFP_30","GFP_5"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    case 'TSC_11'    % sample name
        img_directory = "Y:/Fengyi/TSC_brain/sample11";    % path to dataset
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["730nm","561nm","640nm_20"];    % channel folder name for hierarchy input
        markers = ["Sox9","RFP","GFP_20"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    case 'TSC_12t'    % sample name
        img_directory = "Y:/Fengyi/TSC_brain/sample12_410t";    % path to dataset
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["730nm","561nm","640nm_25","640nm_5"];    % channel folder name for hierarchy input
        markers = ["Sox9","RFP","GFP_25","GFP_5"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    case 'TSC_18'    % sample name
        img_directory = "Y:/Fengyi/TSC_brain/sample18";    % path to dataset
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["730nm","561nm","640nm_20","640nm_2"];    % channel folder name for hierarchy input
        markers = ["Sox9","RFP","GFP_20","GFP_2"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    case 'TSC_8'    % sample name
        img_directory = "I:/TSC_brain/sample8";    
        output_directory = fullfile(img_directory, 'numorph_align2');
        group = ["brain"];
        channel_num = ["561nm","640nm_20","640nm_5","730nm"];    % channel folder name for hierarchy input
        markers = ["RFP","GFP_20","GFP_5","Sox9"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    case 'TSC_12q'    % sample name
        img_directory = "Y:/Fengyi/TSC_brain/sample12_q";   
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["730nm","561nm","640nm_25","640nm_3"];    % channel folder name for hierarchy input
        markers = ["Sox9","RFP","GFP_25","GFP_3"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    case 'EGFR_sample4'    % sample name
        img_directory = "Y:/Fengyi/EGFR_brain/batch4/sample4";   
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["561nm","488nm","640nm_3","640nm_15","730nm"];    % channel folder name for hierarchy input
        markers = ["RFP","Olig2","GFP_3","GFP_15","Sox9"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    case 'EGFR_sample5'    % sample name
        img_directory = "Y:/Fengyi/EGFR_brain/batch4/sample5";   
        output_directory = fullfile(img_directory, 'numorph_align');
        group = ["brain"];
        channel_num = ["561nm","488nm","640nm_3","640nm_15","730nm"];    % channel folder name for hierarchy input
        markers = ["RFP","Olig2","GFP_3","GFP_15","Sox9"];          % marker <--> channel
        position_exp = [];                  % empty if dataset contains two-level hierarchy folders
        resolution = [0.65, 0.65, 8];       % voxel size (um)
        overlap = 0.15;                     % overlap fraction between tiles
    
    otherwise
        error("Sample %s does not exist in NM_samples.",sample)
end

%--------------------------------------------------------------------------
% Do not edit
% Append sample info to variable structure
sample_id = sample;
if save_flag
    save(fullfile('data','tmp','NM_variables.mat'),'-mat','-append')
end
end

