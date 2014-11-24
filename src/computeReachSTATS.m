function [ reachSTATS ] = computeReachSTATS( ...    
                                            reachFLOWobj, ...
                                            reachSTREAMobj,...
                                            reachFileSHAPEstruct, ...
                                            demGRIDobj, ...
                                            flowAccumulationFLOWobj, ...
                                            flowDirectionFLOWobj, ...
                                            basinsGRIDobj, ...
                                            slopeGRIDobj, ...
                                            aspectGRIDobj )
% computeReachStats.m Function to compute a variety of reach statistics 
% that are required to populate the attribute fields of the output reach 
% delineation shapefile that is taken as an input to the WARMF model.
%
% DESCRIPTION:
%
%   Function to compute a variety of reach statistics that are required to
%   populate the attribute fields of the output reach delineation shapefile
%   that is taken as an input to the WARMF model. 
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ reachSTATS ] = computeReachSTATS( reachFLOWobj,reachFileSHAPEstruct,...
%                                       demGRIDobj,flowAccumulationFLOWobj,
%                                       flowDirectionFLOWobj,basinsGRIDobj,
%                                       slopeGRIDobj,aspectGRIDobj )
%
% INPUTS:
%
%   reachFLOWobj =      [FLOWobj] Flow object corresponding to the
%                       automatically delineated stream reaches from the 
%                       topo-toolbox delineation routines
%
%   reachSTREAMobj =    [STREAMobj] Stream object corresponding to the
%                       automatically delineated streamreaches from the 
%                       topo-toolbox delineation routines
%
%   reachFileSHAPEstruct = [SHAPESstruct] shapefile structure array
%                       corresponding to the reference reachfile (RF1) 
%                       obtained for the study area
%
%   demGRIDobj =        [GRIDobj] Grid object digital elevation grid model 
%                       for the study area
%
%   flowAccumulationFLOWobj = [FLOWobj] Flow object corresponding to the
%                       computed flow accumulation values for each reach 
%                       component
%
%   flowDirectionFLOWobj = [FLOWobj] Flow object corresponding to the 
%                       computed flow direction values for each reach 
%                       component
%
%   basinsGRIDobj =     [GRIDobj] Grid object formatted basin delineation 
%                       grid object generated from the topo-toolbox 
%                       automated workflow
%
%   slopeGRIDobj =      [GRIDobj] Grid object formatted slope raster
%
%   aspectGRIDobj =     [GRIDobj] Grid object formatted aspect raster
%
%
% OUTPUTS:
%
%   reachSTATS =        [n x q] cell array in which n corresponds to the
%                       number of input basins and each column corresponds 
%                       to one of q reach attributes
%
% EXAMPLES:
%   
%   Example 1 =         
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
    x == 9);
addRequired(P,'nargout',@(x)...
    x == 1);
addRequired(P,'reachFLOWobj',@(x)...
    isa(x,'FLOWobj') &&...
    ~isempty(x));
addRequired(P,'reachSTREAMobj',@(x)...
    isa(x,'STREAMobj') &&...
    ~isempty(x));
addRequired(P,'reachFileSHAPEstruct',@(x)...
    isstruct(x) &&...
    ~isempty(x));
addRequired(P,'demGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'flowAccumulationFLOWobj',@(x)...
    isa(x,'FLOWobj') &&...
    ~isempty(x));
addRequired(P,'flowDirectionFLOWobj',@(x)...
    isa(x,'FLOWobj') &&...
    ~isempty(x));
addRequired(P,'basinsGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'slopeGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'aspectGRIDobj',@(x)...
    ~isempty(x));

parse(P,nargin,nargout,reachFLOWobj,reachSTREAMobj,reachFileSHAPEstruct,...
    demGRIDobj,flowAccumulationFLOWobj,flowDirectionFLOWobj,...
    basinsGRIDobj,slopeGRIDobj,aspectGRIDobj);

%% Function Parameters

streamsGRIDobj = STREAMobj2GRIDobj(streams);
adjacency = imRAG(basinsGRIDobj.Z);
basinIds = unique(basinsGRIDobj.Z);
basinIds = basinIds(2:end);
basinCount = max(basinIds);
reachUpstreamCatchment = zeros(basinCount,1);
reachDownstreamCatchment = zeros(basinCount,1);
reachMeanSlope = zeros(basinCount,1);
reachModeAspect = zeros(basinCount,1);

%% Compute Reach Statistics

for i = 1:basinCount
    
    currentCatchment = basinsGRIDobj.Z == i;
    currentReach = currentCatchment .* streamsGRIDobj.Z;
    reachIDx = find(currentReach);
    
    reachMeanSlope(i,1) = mean(SLOPE.Z(reachIDx));
    reachModeAspect(i,1) = mode(ASPECT.Z(reachIDx));

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

%% Assemble Final Outputs

reachSTATS = [];

end