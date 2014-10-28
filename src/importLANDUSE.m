function [ landuseGRIDobj ] = importLANDUSE( filepath )

% importLANDUSE.m Function to import a geotiff formatted landuse data set
% and load it into memory as a topo-toolbox GRIDobj. 
%
% DESCRIPTION:
%
%   Function to import a numerically coded landuse map for some aribitrary
%   watershed from a geotiff file format into an in memory GRIDobj
%   topo-toolbox grid object. 
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ landuseGRIDobj ] = importLANDUSE( filepath )
%
% INPUTS:
%
%   filepath =          'text string' containing the valid filepath for a
%                       geotiff based landuse dataset
%
% OUTPUTS:
%
%   landuseGRIDobj =    [GRIDobj] output topo-toolbox grid object data
%                       structure corresponding to the input landuse map
%
% EXAMPLES:
%   
%   Example 1 =         demGRIDobj = ...
%                           importLANDUSE('/Users/JohnSmith/landuse.tif');
%
%   Example 2 =         demGRIDobj = ...
%                           importLANDUSE(...
%                               'C:\\Users\JohnSmith\landuse.tif');
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
    error('Input LANDUSE dataset must be in GeoTIFF format');
end

%% Import DEM to Grid Object

landuseGRIDobj = GRIDobj(filepath);

end


end

