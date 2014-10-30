function [ plotHandle ] = flatsPlot(    demGRIDobj, ...
                                        flatsGRIDobj, ...
                                        sillsGRIDobj, ...
                                        closedBasinsGRIDobj )
% flatsPlot.m Function to generate a three plot component figure for the
% lcoations fo flatsGRIDobj, sillsGRIDobj, and closed basins computed 
% from an input demGRIDobj.
%
% DESCRIPTION:
%
%   Function to generate a three plot component figure for the locations of
%   flatsGRIDobj, sillsGRIDobj, and closed basins computed from an input 
%   demGRIDobj.
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ plotHandle ] = flatsPlot( demGRIDobj, flatsGRIDobj, sillsGRIDobj, ...
%                               closedBasinsGRIDobj )
%
% INPUTS:
%
%   demGRIDobj =    [GRIDobj] for the digital elevation model that will be
%                   used to produce the hillshaded rendering in the image 
%                   plot
%
%   flatsGRIDobj =  [GRIDobj] for the location of flat regions in the basin
%
%   sillsGRIDobj =  [GRIDobj] for the location of sillsGRIDobj within the 
%                   basin
%
%   closedBasinsGRIDobj = [GRIDobj] for the location of closed sub-basins
%
% OUTPUTS:
%
%   plotHandle =        Arbitrary variable assignment value for the 
%                       output figure
%
% EXAMPLES:
%   
%   Example 1:          plot1 = flatsPlot(demGRIDobj, flatsGRIDobj, 
%                                           sillsGRIDobj, closdedBasins);
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
    x >= 0);
addRequired(P,'demGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'flatsGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'sillsGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));
addRequired(P,'closedBasinsGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));

parse(P,nargin,nargout,demGRIDobj,flatsGRIDobj,sillsGRIDobj,...
    closedBasinsGRIDobj);

%% Function Parameters

nanMask = isnan(demGRIDobj.Z);
plotGRID = flatsGRIDobj+2.*sillsGRIDobj+3.*closedBasinsGRIDobj;
plotGRID.Z(nanMask) = NaN;

%% Generate Plot

plotHandle = figure();

imageschs(demGRIDobj,plotGRID);
title('Flats, Sills, & Closed Basins');
xlabel('Easting (meters)');
ylabel('Northing (meters)')

end