function [ outputGRIDobj ] = cropResizeGRIDobj( inputGRIDobj, ...
                                                referenceGRIDobj )
% cropGRIDobj.m Function to crop and resize an input GRIDobj array to the 
% spatial extent and cell size of some input reference GRIDobj array.
%
% DESCRIPTION:
%
%   Function to crop and resize an input GRIDobj array to the spatial 
%   extent and cell size of some other external input reference GRIDobj 
%   array.
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ outputGRIDobj ] = cropResizeGRIDobj( inputGRIDobj, referenceGRIDobj )
%
% INPUTS:
%
%   inputGRIDobj =      [GRIDobj] that is to be cropped
%
%   referenceGRIDobj =  [GRIDobj] with the spatial reference that will
%                       be used to perform the crop operation
%
% OUTPUTS:
%
%   outputGRIDobj =     [GRIDobj] output topo-toolbox grid object data
%                       structure corresponding to the input landuse map
%
% EXAMPLES:
%   
%   Example 1 =         landuseCropResize = cropResizeGRIDobj(landuse,dem);
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
    x == 2);
addRequired(P,'nargout',@(x)...
    x == 1);
addRequired(P,'inputGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'referenceGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));

parse(P,nargin,nargout,inputGRIDobj,referenceGRIDobj);

%% Function Parameters

inputREF = inputGRIDobj.georef.RefMatrix;
referenceREF = referenceGRIDobj.georef.RefMatrix;
referenceHeight = referenceGRIDobj.georef.Height;
referenceWidth = referenceGRIDobj.georef.Width;

%% Extract Input Information

referenceRowVec = 1:1:referenceHeight;
referenceColVec = 1:1:referenceWidth;
[referenceRowMesh, referenceColMesh] = meshgrid(referenceRowVec,referenceColVec);
referenceRow = reshape(referenceRowMesh,(size(referenceRowMesh,1)*size(referenceRowMesh,2)),1);
referenceCol = reshape(referenceColMesh,(size(referenceColMesh,1)*size(referenceColMesh,2)),1);
[referenceX, referenceY] = pix2map(referenceREF,referenceRow,referenceCol);

%% Generate Output Information

[outputRow, outputCol] = map2pix(inputREF,referenceX,referenceY);
outputRow = floor(outputRow);
outputCol = floor(outputCol);
outputArray = inputGRIDobj.Z(min(outputRow):max(outputRow),...
    min(outputCol):max(outputCol));
outputArray = resizem(outputArray,[referenceHeight referenceWidth]);
outputGRIDobj = referenceGRIDobj;
outputGRIDobj.Z = outputArray;
outputGRIDobj.Z(isnan(referenceGRIDobj.Z)) = NaN;

end