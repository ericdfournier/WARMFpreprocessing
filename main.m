%% IMPORT DATA

cd '~/Repositories/WARMFpreprocessing';
DEMfilepath = [pwd,'/data/Lower_Hudson/02030101demg.tif'];
LANDUSEfilepath = [pwd,'/data/Lower_Hudson/NLCD_landcover_2001.tif'];

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
maxDepth = 2; % [meters]
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
delineationStreamOrder = 6; % [Unitless]
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

%% COMPUTE STATISTICS

basinIds = unique(basins.Z);
basinIds = basinIds(2:end);
basinCount = max(basinIds);
SLOPE = gradient8(dem,'per');
ASPECT = aspect(dem);
streamsGRID = STREAMobj2GRIDobj(streams);
adjacency = imRAG(basins.Z);

reachUpstreamCatchment = zeros(basinCount,1);
reachDownstreamCatchment = zeros(basinCount,1);
reachMeanSlope = zeros(basinCount,1);
reachModeAspect = zeros(basinCount,1);
catchmentMinElevation = zeros(basinCount,1);
catchmentMaxElevation = zeros(basinCount,1);
catchmentLanduseStats = cell(basinCount,1);

for i = 1:basinCount
    
    currentCatchment = basins.Z == i;
    currentReach = currentCatchment .* streamsGRID.Z;
    
    currentCatchmentElevation = currentCatchment .* dem.Z;
    currentCatchmentLanduse = currentCatchment .* landuse.Z;
    
    reachIDx = find(currentReach);
    catchmentIDx = find(currentCatchment);
    
    reachMeanSlope(i,1) = mean(SLOPE.Z(reachIDx));
    reachModeAspect(i,1) = mode(ASPECT.Z(reachIDx));
    
    catchmentMinElevation(i,1) = min(min(dem.Z(catchmentIDx)));
    catchmentMaxElevation(i,1) = max(max(dem.Z(catchmentIDx)));
    
    catchmentLanduseVec = currentCatchmentLanduse(catchmentIDx);
    bins = unique(catchmentLanduseVec);
    counts = hist(catchmentLanduseVec,bins)';
    fractions = (counts)./sum(counts);
    catchmentLanduseStats{i,1} = horzcat(bins,fractions);
    
    col1Ind_DS = find(adjacency(:,1) == i,1,'first');
    col2Ind_DS = find(adjacency(:,2) == i,2,'first');
    rowInd_DS = min([col1Ind_DS col2Ind_DS]);
    currentRow_DS = adjacency(rowInd_DS,:);
    
    col1Ind_US = find(adjacency(:,1) == i,1,'last');
    col2Ind_US = find(adjacency(:,2) == i,2,'last');
    rowInd_US = max([col1Ind_US col2Ind_US]);
    currentRow_US = adjacency(rowInd_US,:);
    
    if i == 1
        
        reachUpstreamCatchment(i,1) = NaN;
        reachDownstreamCatchment(i,1) = currentRow_DS(...
            adjacency(rowInd_DS,:) ~= i);
    
    elseif i == basinCount
        
        reachUpstreamCatchment(i,1) = currentRow_US(...
            adjacency(rowInd_US,:) ~= i);
        reachDownstreamCatchment(i,1) = NaN;
        
    else
        
        reachUpstreamCatchment(i,1) = currentRow_US(...
            adjacency(rowInd_US,:) ~= i);
        reachDownstreamCatchment(i,1) = currentRow_DS(...
            adjacency(rowInd_DS,:) ~= i);
        
    end
    
end
