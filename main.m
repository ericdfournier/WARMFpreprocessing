%% IMPORT DATA

cd '~/Repositories/WARMFpreprocessing';
DEMfilepath = [pwd,'/data/Pajaro/18060002demg.tif'];
LANDUSEfilepath = [pwd,'/data/Pajaro/NLCD_landcover_2001.tif'];
REACHfilepath = [pwd,'/data/Pajaro/rf1.shp'];

% Read data into memory
demRAW = importDEM(DEMfilepath);
landuseRAW = importLANDUSE(LANDUSEfilepath);
reaches = shaperead(REACHfilepath);

% Resize and Crop Landuse to DEM
landuse = cropResizeGRIDobj(landuseRAW,demRAW);

% View Input Data
inputDataPlot(demRAW,landuse,reaches);

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
drainageAreaThreshold = 1e7; % [meters^2]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Convert to pixels based on dem resolution
resolution = dem.refmat(2,1);
minApix = ceil(drainageAreaThreshold/(resolution*resolution));
flowAccumulationThreshold = flowAccumulation > minApix;

% Compute Streams from thresholded flow accumulation
streamsRaw = STREAMobj(flowDirection,flowAccumulationThreshold);

% Set stream order threshold for basin delination
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delineationStreamOrder = 7; % [Unitless]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the minimum flow accumulation threshold to define stream order
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flowAccumulationThreshold = 1e1; % [Unitless]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Limit to top ten connected components
streams = klargestconncomps(streamsRaw,1);

% Compute stream order
streamOrder = streamorder(flowDirection,...
    flowAccumulation > flowAccumulationThreshold);

% Define drainage basins
[basins, basinOutles] = drainagebasins(flowDirection,streamOrder,...
    delineationStreamOrder);

% View drainage basins
imageschs(dem,basins);

%% COMPUTE BASIN STATISTICS

% Compute required inputs
slopeLayer = gradient8(dem,'per');
aspectLayer = aspect(dem);
streamsGRID = STREAMobj2GRIDobj(streams);

% Compute basin stats
basinSTATS = computeBasinSTATS( ...
    dem, ...
    landuse, ...
    basins, ...
    slopeLayer, ...
    aspectLayer);

%% COMPUTE REACH STATISTICS 

% Compute required inputs
reachSTATS = computeReachSTATS( ...
    streams, ...
    reaches, ...
    dem, ...
    basins, ...
    slopeLayer, ...
    aspectLayer );
