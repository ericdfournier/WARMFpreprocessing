%% Initialize Filesystem Parameters

workingDirectory = ['/Users/ericfournier/Google Drive/Personal/',...
     'Miscellaneous/Kendra/DEM Delineation/'];
cd(workingDirectory);
DEMfilepath = [pwd,'/18040009demg.tif'];
LANDUSEfilepath = [pwd,'/NLCD_landcover_2001.tif'];

%% Import Data

demRAW = importDEM(DEMfilepath);
landuseRAW = importLANDUSE(LANDUSEfilepath);

%% Resize and Crop Landuse to DEM

landuse = cropResizeGRIDobj(landuseRAW,demRAW);
dem = demRAW;
clearvars -EXCEPT landuse dem

%% View Input Data

inputDataPlot(dem,landuse);

%% 