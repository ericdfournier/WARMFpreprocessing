function [ reachDepth, reachWidth ] = computeReachProfile( ...
                                                    currentCatchment, ...
                                                    demGRIDobj, ...
                                                    reachFileSHAPEstruct )
% computeReachProfile.m Function to generate stream reach depth and width 
% attributes for a given input subcatchment and stream reach reference
% shape struct
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
% [ reachSTATS ] = computeReachProfile( currentCatchment, demGRIDobj, ...
%                                           reachFileSHAPEstruct )
%
% INPUTS:
%
%   currentCatchment    [LOGICAL] 2-d logical array with the same
%                       dimensions as the demGRIDobj Z array with values 
%                       of 1 at the location of the current subcatchment 
%                       and zeros at all other locations
%
%   demGRIDobj =        [GRIDobj] Grid object digital elevation grid model 
%                       for the study area
%
%   reachFileSHAPEstruct = [SHAPESstruct] shapefile structure array
%                       corresponding to the reference reachfile (RF1) 
%                       obtained for the study area
%
% OUTPUTS:
%
%   reachDepth =        [SCALAR] scalar value indicating the average reach
%                       depth for all of the reach sections in the input 
%                       reachSHAPEstruct that intersect the current 
%                       subcatchment
%
%   reachWidth =        [SCALAR] scalar value indicating the average reach
%                       width for all of the reach sections in the input
%                       reachSHAPEstruct that intersect the current
%                       subcatchment
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
    x == 3);
addRequired(P,'nargout',@(x)...
    x == 2);
addRequired(P,'currentCatchment',@(x)...
    ismatrix(x) &&...
    ~isempty(x));
addRequired(P,'demGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'reachFileSHAPEstruct',@(x)...
    isstruct(x) &&...
    ~isempty(x));

parse(P,nargin,nargout,currentCatchment,demGRIDobj,reachFileSHAPEstruct);

%% Function Parameters

reachCount = size(reachFileSHAPEstruct,1);

%% Extract Catchment Geometry

catchmentPerim = bwperim(currentCatchment);
[X, Y] = getcoordinates(demGRIDobj);
[meshX, meshY] = meshgrid(X,Y);
cpX = catchmentPerim .* meshX;
cpY = catchmentPerim .* meshY;
[pX, pY] = find(cpX);
X1 = pX(1);
Y1 = pY(1);
p = [X1, Y1];
fstep = 'E';
boundaryTrace = bwtraceboundary(catchmentPerim,p,fstep);
pInd = sub2ind(size(currentCatchment),boundaryTrace(:,1),boundaryTrace(:,2));
cX = cpX(pInd);
cY = cpY(pInd);

%% Extract Reach Geometries

rX = extractfield(reachFileSHAPEstruct,'X')';
rY = extractfield(reachFileSHAPEstruct,'Y')';

%% Perform Reach and Catchment Geometry Set Intersection

[riX, riY] = polybool('&',rX,rY,cX,cY);
matches = zeros(reachCount,1);

for i = 1:reachCount
    mX = intersect(riX,reachFileSHAPEstruct(i,1).X);
    mY = intersect(riY,reachFileSHAPEstruct(i,1).Y);
    if ~isempty(mX) && ~isempty(mY)
        matches(i,1) = 1;
    end
end

%% Extract Matching Reach Segments and Compute Average Width and Depth

reachSections = reachFileSHAPEstruct(logical(matches),:);
reachDepth = mean(reachSections.PDEPTH);
reachWidth = mean(reachSections.PWIDTH);

end