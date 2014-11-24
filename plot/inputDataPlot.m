function [ plotHandle ] = inputDataPlot(    demGRIDobj, ...
                                            landuseGRIDobj, ...
                                            reachFileSHAPEstruct )
% inputDataPlot.m Function to generate a figure with two subplots showing
% the raw input digital elevation model data and the landuse data side by
% side
%
% DESCRIPTION:
%
%   Function to generate a figure with two subplots showing the raw input 
%   digital elevation model data and the landuse data side by side
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ plotHandle ] = inputDataPlot( demGRIDobj, landuseGRIDobj )
%
% INPUTS:
%
%   demGRIDobj =        [GRIDobj] for the digital elevation model
%
%   landuseGRIDobj =    [GRIDobj] for the landuse dataset
%
%   reachFileSHAPEstruct = [SHAPESstruct] shapefile structure array
%                       corresponding to the reference reachfile (RF1) 
%                       obtained for the study area
%
% OUTPUTS:
%
%   plotHandle =        Arbitrary variable assignment value for the 
%                       output figure
%
% EXAMPLES:
%   
%   Example 1 =         plot1 = inputDataPlot(dem, landuse, reaches);
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
    x >= 0);
addRequired(P,'demGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'landuseGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'reachFileSHAPEstruct',@(x)...
    isstruct(x) &&...
    ~isempty(x));

parse(P,nargin,nargout,demGRIDobj,landuseGRIDobj,reachFileSHAPEstruct);

%% Generate Plot

plotHandle = figure();

subplot(1,2,1);
hold on
imageschs(demGRIDobj);
mapshow(reachFileSHAPEstruct,'Color','black','LineWidth',1);
title('Raw Digital Elevation Model With Reference Reach Delineations');
xlabel('Easting (meters)');
ylabel('Northing (meters)')

subplot(1,2,2);
imageschs(landuseGRIDobj);
title('Landuse');
xlabel('Easting (meters)');
ylabel('Northing (meters)')

end