function [Image] = makeImages_universal(varargin)
%[Image] = makeImages2(varargin)
% Seed the number generator
rng(1);

% Input parser
p = inputParser;

% Add optional inputs
addParameter(p, 'cameras', defaultCameraArrangement(), @isstruct);
addParameter(p, 'outdir', '.', @isstr); % Where to Save 
addParameter(p, 'outbase', 'frame_1', @isstr); % Base Name 
addParameter(p, 'extension', 'tiff', @isstr);
addParameter(p, 'zeros', 4, @isnumeric);
% addParameter(p, 'velocityFunction', @burgersVortex, @isFunctionHandle); % Our Velocity function 
% addParameter(p, 'xrange', [-.25, .25]); % 
% addParameter(p, 'yrange', [-.25, .25]);
% addParameter(p, 'zrange', [-.2, 0.2]);
% addParameter(p, 'particleConcentration', 1.5e4, @isnumeric);
% addParameter(p, 'tspan', linspace(0,0.01, 75), @isnumeric);
addParameter(p, 'particleDiameterMean', 2*sqrt(8), @isnumeric); % 1.5
addParameter(p, 'particleDiameterStdDev', 0.10 * sqrt(8), @isnumeric);
addParameter(p, 'beamStdDev', 0.05, @isnumeric);
addParameter(p, 'BeamPlaneZ', 0, @isnumeric);
addParameter(p, 'velocityFunctionParams', [], @isstruct);
addParameter(p, 'save', false, @islogical);
addParameter(p, 'plot', true, @islogical);
addParameter(p, 'data', [], @isstruct);

% addParameter(p, 'write_to_work', false, @islogical); % does nothing RN
% addParameter(p, 'save_positions', false, @islogical);
% Parse the arguments
parse(p, varargin{:});
dataset = p.Results.data;
% Save_particle_trajctories = p.Results.save_positions;
Cameras = p.Results.cameras;
out_root = p.Results.outdir;
out_base = p.Results.outbase;
out_ext = p.Results.extension;
nZeros = p.Results.zeros;
% velocityFunction = p.Results.velocityFunction;
% xrange = p.Results.xrange;
% yrange = p.Results.yrange;
% zrange = p.Results.zrange;
% particle_concentration = p.Results.particleConcentration;
% tSpan = p.Results.tspan;
particle_diameter_mean = p.Results.particleDiameterMean;
particle_diameter_std = p.Results.particleDiameterStdDev;
beam_plane_std_dev = p.Results.beamStdDev;
beam_plane_z = p.Results.BeamPlaneZ;
velFnParams = p.Results.velocityFunctionParams;
saveImages = p.Results.save;
makePlots = p.Results.plot;
% write_to_work = p.Results.write_to_work;

% Format string
fmtStr = sprintf('%%0%dd', nZeros);
outNameFmt = sprintf('%s%s.%s', out_base, fmtStr, out_ext);


X = dataset.x ;
Y = dataset.y ;
Z = dataset.z ; 
[ndim,mdim ] = size(X)
tSpan = ndim;
n_particles = mdim ; 
particleDiameters = abs(particle_diameter_std * randn(n_particles, 1) ...
    + particle_diameter_mean);

disp(tSpan)
% use_existing_pos = false ;
% turb_data = true ; 
% generate_data = false ; 
% if use_existing_pos
%     load('Pos.mat');
%     X = Pos.x ;
%     Y = Pos.y ;
%     Z = Pos.z ;
%     disp('USEING EXISTING')
% elseif turb_data
%     [X,Y,Z] = Get_turb_data('test');
%     disp('USEING TURB DATA')
% elseif generate_data
%     % Calculate the particle trajectories
%     [X, Y, Z] = velocityFunction(xo, yo, zo, tSpan, velFnParams);
%     disp('GEN NEW POS')
% end



% Count the number of cameras
num_cameras = length(Cameras);

% Open a new figure
if makePlots
    figure;
end

% Loop over all the time steps
for t = 1 : tSpan

    % [x,y,z] positions at this time point
    % in world coordinates (lab frame, meters)
    x = X(t, :);
    y = Y(t, :);
    z = Z(t, :);
    
    % Calculate particle max intensities from beam profile
    particleMaxIntensities = exp(-(z - beam_plane_z).^2 ./ ...
    (2 * beam_plane_std_dev ^ 2));

    % Inform the user
    fprintf('On frame %d of %d\n', t, tSpan);
    
    % Loop over cameras
    for k = 1 : num_cameras

        % Ger the current camera
        Camera = Cameras(k);
        
        % Calculate image coordinates
        [x_cam, y_cam] = pinholeTransform(x, y, z, getCameraMatrix(Camera));
        
        % Render the image and add noise
        particle_image = (...
            generateParticleImage(Camera.PixelRows, Camera.PixelColumns, ...
              x_cam, y_cam, particleDiameters, particleMaxIntensities)) ...
              + getSensorNoise(Camera);
        
        % Apply sensor gain
        particle_image_uint16 = uint16(Camera.SensorGain * double(intmax('uint16')) * particle_image);
        
        if makePlots        
            % Make a plot
            subtightplot(2, 2, k, [0.1, 0.1]);
            imagesc(particle_image_uint16);
            axis image;
            set(gca, 'fontsize', 16);
            title(sprintf('Camera %d', k), 'interpreter', 'latex', 'fontsize', 20);
            colormap gray;
            caxis([0, intmax('uint16')]);
            set(gcf, 'color', 'white');
            % this was missing , you can either flip image of set ydir
            % reverse
            set(gca, 'xdir', 'Reverse');
%             set(gca, 'ydir', 'normal');
        end
        
%         % Output path
%         out_dir = fullfile(out_root, sprintf('Cam%d', k));
%         if(~exist(out_dir, 'dir'))
%             mkdir(out_dir);
%         end
%         
%         % Where to save the image
%         out_path = fullfile(out_dir, sprintf(outNameFmt, t));
        
        % Save the image % we shouldnt make the folders if we dont want to
        % save
        if saveImages
            out_dir = fullfile(out_root, sprintf('Cam%d', k));
            if(~exist(out_dir, 'dir'))
                mkdir(out_dir);
            end
            % Where to save the image
            out_path = fullfile(out_dir, sprintf(outNameFmt, t));
            Eight_BIT = im2uint8(particle_image_uint16);%uint8(particle_image_uint16/256);
%             flip_image = flipud(Eight_BIT);
            flip_image = fliplr(Eight_BIT);
            imwrite(flip_image, out_path);
%             imwrite(uint8(particle_image_uint16/256), out_path);
        end
        % uncomment to output image to workspace 
        % playback using implay
       Image(:,:,:,t,k) = fliplr(particle_image_uint16);
       
            
    %Draw the frame
    drawnow();

    end



end


% implay(Image(:,:,:,:,1))
% v = VideoWriter('Turb.avi');
% open(v)
% writeVideo(v,Image(:,:,:,:,1))
% Error using VideoWriter/writeVideo (line 410)
% IMG must be of one of the following classes: double, single, uint8
%  
% writeVideo(v,im2uint8(Image(:,:,:,:,1)))
% close(v)


