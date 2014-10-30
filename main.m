%% Initialize Filesystem Parameters

workingDirectory = ['/Users/ericfournier/Google Drive/Personal/',...
     'Miscellaneous/Kendra/DEM Delineation/'];
cd(workingDirectory);
DEMfilepath = [pwd,'/18040009demg.tif'];
LANDUSEfilepath = [pwd,'/NLCD_landcover_2001.tif'];

%% IMPORT DATA

% Read data into memory
demRAW = importDEM(DEMfilepath);
landuseRAW = importLANDUSE(LANDUSEfilepath);

% Resize and Crop Landuse to DEM
landuse = cropResizeGRIDobj(landuseRAW,demRAW);

% View Input Data
inputDataPlot(demRAW,landuse);

%% CLEAN THE DATA

% Fill Sinks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxDepth = 10; % [meters]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dem = fillsinks(demRAW,maxDepth);

% Check for Flats
[flats, sills, closedBasins] = identifyflats(dem);

% View Flats
flatsPlot(dem, flats, sills, closedBasins);

%% ROUTE STREAMS

% Compute flow direction
flowDirection = FLOWobj(dem,'preprocess','carve');

% Compute flow accumulation
flowAccumulation = flowacc(flowDirection);

% View flow accumulation
flowAccumulationPlot(dem,flowAccumulation);

%% DEFINE SUB-CATCHMENTS

% Set drainage area threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drainageAreaThreshold = 1e6; % [meters^2]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert to pixels based on dem resolution
resolution = dem.refmat(2,1);
minApix = ceil(drainageAreaThreshold/(resolution*resolution));
flowAccumulationThreshold = flowAccumulation > minApix;

% Compute Streams from thresholded flow accumulation
streamsRaw = STREAMobj(flowDirection,flowAccumulationThreshold);

%% SELECT STREAM COMPONENTS

% Limit to top ten connected components
streamsRaw = klargestconncomps(streamsRaw,10);

% Extract large streams
streams = extractconncomps(streamsRaw); close;

%% DEFINE DRAINAGE BASINS

% Set stream order threshold for basin delination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delineationStreamOrder = 6; % [Unitless]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the minimum flow accumulation threshold to define stream order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flowAccumulationThreshold = 1e1; % [Unitless]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute stream order
streamOrder = streamorder(flowDirection,...
    flowAccumulation > flowAccumulationThreshold);

% Define drainage basins
[basins, basinOutles] = drainagebasins(flowDirection,streamOrder,...
    delineationStreamOrder);

% View drainage basins
imageschs(dem,basins);