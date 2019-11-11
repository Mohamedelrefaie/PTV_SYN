function [x,y,z, xc, yc, zc] = calibrationTarget(varargin)
% Makes [x,y,z] coordinates that can be passed to generateParticleImage 
% to create an image of a camera calibration target.

    % Input parser
    p = inputParser;

    % Add optional inputs
    addParameter(p, 'dotSpacing', 0.0254, @isnumeric);
    addParameter(p, 'dotDiameter', 0.0005, @isnumeric); % changed 0.005
    addParameter(p, 'rows', 5, @isnumeric); % changed 9
    addParameter(p, 'columns', 5, @isnumeric); % changed 9
    addParameter(p, 'origin', [0,0,0], @isnumeric);
    addParameter(p, 'particlesPerDot', 1e3, @isnumeric);
    
    % Parse the arguments
    parse(p, varargin{:});

    % Results structure
    dot_spacing_m = p.Results.dotSpacing;
    dot_diameter_m   = p.Results.dotDiameter;
    dot_rows = p.Results.rows;
    dot_cols = p.Results.columns;
    target_origin   = p.Results.origin;
    particles_per_dot = p.Results.particlesPerDot;
 
    % Number of dots
    nDots = dot_rows * dot_cols;
    
    % Width of target (center of first dot to center of last dot)
    targetWidth =  (dot_cols - 1) * dot_spacing_m;
    targetHeight = (dot_rows - 1) * dot_spacing_m;
    
    % Dot centers
    xv = linspace(-targetWidth/2, targetWidth/2, dot_cols)   + target_origin(1);
    % lets flip yv here so our points are in the same order for PTV
    % that is left to right top to bottom
    %yv = linspace(-targetHeight/2, targetHeight/2, dot_rows) + target_origin(2);
    yv = linspace(targetHeight/2, -targetHeight/2, dot_rows) + target_origin(2);
    zv = target_origin(3);
    
    % Make a grid of dot centers
    % lets flip yv here so our points are in the same order for PTV
    % that is left to right top to bottom
%     [xdots, ydots, zdots] = meshgrid(xv, yv, zv);
    % Better to use ndgrid
    [xdots, ydots, zdots] = ndgrid(xv, yv, zv);
    
    % Reshape the dot center arrays into vectors
    xc = xdots(:);
    yc = ydots(:);
    zc = zdots(:);
    
    % Allocate array to hold all the [x,y,z] points
    x = zeros(particles_per_dot, nDots);
    y = zeros(particles_per_dot, nDots);
    z = zeros(particles_per_dot, nDots);
    
    % Make all the dots
    for n = 1 : nDots
        
        % Random angle from dot center
        th = 2 * pi * rand(particles_per_dot, 1);
        r = dot_diameter_m/2  * rand(particles_per_dot, 1);
        zraw = zeros(particles_per_dot, 1);
        [xraw, yraw, ~] = pol2cart(th, r, zraw);
        x(:, n) = xraw + xc(n);
        y(:, n) = yraw + yc(n);
        z(:, n) = zraw + zc(n);
    end
    
end
