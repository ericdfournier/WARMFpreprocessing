function [ plotHandle ] = inputDataPlot( demGRIDobj, landuseGRIDobj )
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
% OUTPUTS:
%
%   plotHandle =        Arbitrary variable assignment value for the 
%                       output figure
%
% EXAMPLES:
%   
%   Example 1 =         plot1 = inputDataPlot(dem, landuse);
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
    x >= 0);
addRequired(P,'demGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'landuseGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));

parse(P,nargin,nargout,demGRIDobj,landuseGRIDobj);

%% Generate Plot

plotHandle = figure();
scrn = get(0,'ScreenSize');
set(gca,'Position',scrn);

subplot(1,2,1);
imageschs(demGRIDobj);
title('Digital Elevation Model');
xlabel('Easting (meters)');
ylabel('Northing (meters)')

subplot(1,2,2);
imageschs(landuseGRIDobj);
title('Landuse');
xlabel('Easting (meters)');
ylabel('Northing (meters)')

end