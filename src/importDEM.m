function [ demGRIDobj ] = importDEM( filepath )
% importDEM.m Function to import a geotiff formatted digital elevation
% model and load it into memory as a topo-toolbox GRIDobj. 
%
% DESCRIPTION:
%
%   Function to import digital elevation model (DEM) for some aribitrary
%   watershed from a geotiff file format into an in memory GRIDobj
%   topo-toolbox grid object. 
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ demGRIDobj ] = importDEM( filepath )
%
% INPUTS:
%
%   filepath =          'text string' containing the valid filepath for a
%                       geotiff based digital elevation model dataset
%
% OUTPUTS:
%
%   demGRIDobj =        [GRIDobj] output topo-toolbox grid object data
%                       structure corresponding to the input DEM
%
% EXAMPLES:
%   
%   Example 1 =         demGRIDobj = ...
%                           importDEM('/Users/JohnSmith/dem.tif');
%
%   Example 2 =         demGRIDobj = ...
%                           importDEM('C:\\Users\JohnSmith\dem.tif');
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
    x == 4);
addRequired(P,'nargout',@(x)...
    x == 1);
addRequired(P,'filepath',@(x)...
    exist(x,'file') ~= 0 &&...
    ~isempty(x));

parse(P,nargin,nargout,filepath);

%% Issue Input File Type Error

[~, ~, ext] = fileparts(filepath);

if strcmp(ext,'.tif') == 0 && strcmp(ext,'.tiff') == 0;
    error('Input DEM dataset must be in GeoTIFF format');
end

%% Import DEM to Grid Object

demGRIDobj = GRIDobj(filepath);

end