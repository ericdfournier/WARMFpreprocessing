function [ reachSTATS ] = computeReachSTATS( ...    
                                            reachSTREAMobj,...
                                            reachFileSHAPEstruct, ...
                                            demGRIDobj, ...
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
% [ reachSTATS ] = computeReachSTATS( reachFileSHAPEstruct,...
%                                       demGRIDobj,basinsGRIDobj,
%                                       slopeGRIDobj,aspectGRIDobj )
%
% INPUTS:
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
    x == 6);
addRequired(P,'nargout',@(x)...
    x == 1);
addRequired(P,'reachSTREAMobj',@(x)...
    isa(x,'STREAMobj') &&...
    ~isempty(x));
addRequired(P,'reachFileSHAPEstruct',@(x)...
    isstruct(x) &&...
    ~isempty(x));
addRequired(P,'demGRIDobj',@(x)...
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

parse(P,nargin,nargout,reachSTREAMobj,reachFileSHAPEstruct,...
    demGRIDobj,basinsGRIDobj,slopeGRIDobj,aspectGRIDobj);

%% Function Parameters

reachGRIDobj = STREAMobj2GRIDobj(reachSTREAMobj);
adjacency = imRAG(basinsGRIDobj.Z);
basinIds = unique(basinsGRIDobj.Z);
basinIds = basinIds(2:end);
basinCount = max(basinIds);
reachUpstreamCatchment = zeros(basinCount,1);
reachDownstreamCatchment = zeros(basinCount,1);
reachMinElevation = zeros(basinCount,1);
reachMaxElevation = zeros(basinCount,1);
reachMeanSlope = zeros(basinCount,1);
reachMeanAspect = zeros(basinCount,1);
reachDepth = zeros(basinCount,1);
reachWidth = zeros(basinCount,1);

%% Compute Reach Statistics

for i = 1:basinCount
    
    % Extract Current Basin/Reach Mask Indexes
    
    currentCatchment = basinsGRIDobj.Z == i;
    currentReach = currentCatchment .* reachGRIDobj.Z;
    reachIDx = find(currentReach);
    
    % Compute Topographic Attribute Components
    
    reachMinElevation(i,1) = min(demGRIDobj.Z(reachIDx));
    reachMaxElevation(i,1) = max(demGRIDobj.Z(reachIDx));
    reachMeanSlope(i,1) = mean(slopeGRIDobj.Z(reachIDx));
    reachMeanAspect(i,1) = ...
        wrapTo360( ...
        radtodeg(circ_mean(degtorad(aspectGRIDobj.Z(reachIDx)))));
    
    % Compute Upstream and Downstream Attribute Components

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
        
        if isempty(currentRow_US(adjacency(rowInd_US,:) ~= 1))
        
            reachUpstreamCatchment(i,1) = NaN;
        
        else
            
            reachUpstreamCatchment(i,1) = currentRow_US(...
                adjacency(rowInd_US,:) ~= i);
            
        end
            
        if isempty(currentRow_DS(adjacency(rowInd_DS,:) ~= 1))
            
            reachDownstreamCatchment(i,1) = NaN;
            
        else

            reachDownstreamCatchment(i,1) = currentRow_DS(...
                adjacency(rowInd_DS,:) ~= i);
            
        end
        
    end
    
    % Assign Reach Depth and Width on the Basis of Subcatchment Membership
    
    [reachDepth(i,1), reachWidth(i,1)] = computeReachProfile( ...
        currentCatchment, demGRIDobj, reachFileSHAPEstruct);
    
end

%% Generate Headers

headers = {'CatchmentID', ...
    'MinElevation', ...
    'MaxElevation', ...
    'MeanSlope', ...
    'MeanAspect', ...
    'UpstreamCatchment', ...
    'DownstreamCatchment', ...
    'Depth', ...
    'Width' };

%% Assemble Final Outputs

reachSTATS = vertcat(headers, ...
    horzcat( ...
        num2cell(basinIds), ...
        num2cell(reachMinElevation), ...
        num2cell(reachMaxElevation), ...
        num2cell(reachMeanSlope), ...
        num2cell(reachMeanAspect), ...
        num2cell(reachUpstreamCatchment), ...
        num2cell(reachDownstreamCatchment), ...
        num2cell(reachDepth), ...
        num2cell(reachWidth) ) );

end