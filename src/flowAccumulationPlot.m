function [ plotHandle ] = flowAccumulationPlot( demGRIDobj, ...
                                                flowAccumulationGRIDobj )
% flowAccumulationPlot.m Function to generate a figure plot for a flow 
% accumulationGRIDobj
%
% DESCRIPTION:
%
%   Function to generate a figure plot for an input flow
%   accumulationGRIDobj
%
%   Warning: minimal error checking is performed.
%
% SYNTAX:
%
% [ plotHandle ] = flowAccumulationPlot(demGRIDobj, ...
%                                           flowAccumulationGRIDobj )
%
% INPUTS:
%
%   demGRIDobj =    [GRIDobj] for the digital elevation model that will be
%                   used to produce the hillshaded rendering in the image 
%                   plot
%
%   flowAccumulationGRIDobj = [GRIDobj] flow accumulation object computed 
%                   for some arbitary digital elevation model
%
% OUTPUTS:
%
%   plotHandle =    Arbitrary variable assignment value for the output 
%                   figure
%
% EXAMPLES:
%   
%   Example 1:      plot1 = flowAccumulationPlot(flowAccumulationGRIDobj);
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
addRequired(P,'flowAccumulationGRIDobj',@(x)...
    isa(x,'GRIDobj') &&...
    ~isempty(x));

parse(P,nargin,nargout,demGRIDobj,flowAccumulationGRIDobj);

%% Function Parameters

nanMask = isnan(demGRIDobj.Z);
plotGRID = flowAccumulationGRIDobj;
plotGRID.Z(nanMask) = NaN;

%% Generate Plot

plotHandle = figure();

imageschs(demGRIDobj,plotGRID);
title('Flow Accumulation');
xlabel('Easting (meters)');
ylabel('Northing (meters)')

end