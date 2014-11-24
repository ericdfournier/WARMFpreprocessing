function [ basinSTATS ] = computeBasinSTATS(    demGRIDobj, ...
                                                landuseGRIDobj, ...
                                                basinsGRIDobj,...
                                                slopeGRIDobj,...
                                                aspectGRIDobj )
% computeBasinStats.m Function to compute a variety of basin statistics that are
% required to populate the attribute fields of the output basin delineation
% shapefile that is taken as an input to the WARMF model.
%
% DESCRIPTION:
%
%   Function to compute a variety of basin statistics that are required to
%   populate the attribute fields of the output basin delineation shapefile
%   that is taken as an input to the WARMF model. 
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ basinSTATS ] = computeBasinSTATS( demGRIDobj, landuseGRIDobj, ...
%                                       basinsGRIDobj, slopeGRIDobj, ...
%                                       aspectGRIDobj )
%
% INPUTS:
%
%   demGRIDobj =        [GRIDobj] grid object data structure corresponding 
%                       to the input DEM
%
%   landuseGRIDobj =    [GRIDobj] grid object data structure corresponding
%                       to the input landuse dataset
%
%   basinsGRIDobj =     [GRIDobj] grid object data structure corresponding
%                       to the topo-toolbox based basin delineations
%
%   slopeGRIDobj =      [GRIDobj] grid object data structure corresponding
%                       to the 8-way neighborhood slope computed for each 
%                       pixel in the input DEM
%
%   aspectGRIDobj =     [GRIDobj] grid object data structure corresponding
%                       to the 8-way neighborhood aspect computed for each
%                       pixel in the input DEM
%
% OUTPUTS:
%
%   basinSTATS =        [n x 5] cell array in which n corresponds to the
%                       number of input basins and each column corresponds 
%                       to a basin attribute
%
% EXAMPLES:
%   
%   Example 1 =         demGRIDobj = computBasinStats(dem,landuse, ...
%                                       basins,slope,aspect);
%                                            
% CREDITS:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                      %%
%%%                          Eric Daniel Fournier                        %%
%%%                  Bren School of Environmental Science                %%
%%%                 University of California Santa Barbara               %%
%%%                                                                      %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse Inputs

P = inputParser;

addRequired(P,'nargin',@(x)...
    x == 5);
addRequired(P,'nargout',@(x)...
    x == 1);
addRequired(P,'demGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'landuseGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'basinsGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'slopeGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'aspectGRIDobj',@(x)...
    ~isempty(x));

parse(P,nargin,nargout,demGRIDobj,landuseGRIDobj,basinsGRIDobj, ...
    slopeGRIDobj,aspectGRIDobj);

%% Function Parameters

catchmentIds = unique(basinsGRIDobj.Z);
catchmentIds = catchmentIds(2:end);
catchmentCount = max(catchmentIds);
catchmentMinElevation = zeros(catchmentCount,1);
catchmentMaxElevation = zeros(catchmentCount,1);
catchmentLanduseStats = cell(catchmentCount,1);

%% Compute Statistics

for i = 1:catchmentCount
    
    currentCatchment = basinsGRIDobj.Z == i;
    currentCatchmentLanduse = currentCatchment .* landuseGRIDobj.Z;
    catchmentIDx = find(currentCatchment);
    catchmentMinElevation(i,1) = min(min(demGRIDobj.Z(catchmentIDx)));
    catchmentMaxElevation(i,1) = max(max(demGRIDobj.Z(catchmentIDx)));
    catchmentLanduseVec = currentCatchmentLanduse(catchmentIDx);
    bins = unique(catchmentLanduseVec);
    counts = hist(catchmentLanduseVec,bins)';
    fractions = (counts)./sum(counts);
    catchmentLanduseStats{i,1} = horzcat(bins,fractions);
    
end

%% Assemble Output

basinSTATS = horzcat( ...
    num2cell(catchmentIds), ...
    num2cell(catchmentMinElevation), ...
    num2cell(catchmentMaxElevation), ...
    catchmentLanduseStats );

end
