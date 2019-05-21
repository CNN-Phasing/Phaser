function [ iso, x, y, z ] = plotParticle( rho, varargin )

%     varargins:
%     1 = isoval (float) (default = 0.5)
%     2 = skew (3x3 matrix) (real space sampling basis)
%     3 = objSelect (string) ('straight': plots rho(x), 'twin': plots rho*(-x) )

    % first resolving all inputs
    isoval = 0.5;               %
    skew = eye( 3 );            %   defaults
    objSelect = 'straight';     %

    if nargin > 1
        isoval = varargin{1};
    end
    if nargin > 2
        skew = varargin{2};
    end
    if nargin > 3
        objSelect = varargin{3};
    end
    if nargin > 4
        fprintf( 2, 'plotParticle warning: Too many input arguments. \n' );
    end
    
%     setting average phase to zero
    normalizr = sum( abs( rho(:) ) );
    phimean = sum( angle( rho(:) ) .* abs( rho(:) ) ) / normalizr;
    
    if strcmp( objSelect, 'straight' )
        sgn = 1;
    elseif strcmp( objSelect, 'twin' )
        sgn = -1;
    else
        fprintf( 2, 'plotParticle warning: Unrecognized object convention. \n' );
        sgn = 1;
    end
    rhoPlot = abs( rho ) .* exp( 1j * sgn*( angle( rho ) - phimean ) );
    
    [ x, y, z ] = meshgrid( 1:size( rhoPlot, 1 ), 1:size( rhoPlot, 2 ), 1:size( rhoPlot, 3 ) );
    y = max( y(:) ) - y;
    
    x = x - mean( x(:) );
    y = y - mean( y(:) );
    z = z - mean( z(:) );
    
    pts = sgn * skew * [ x(:) y(:) z(:) ]';        
    x = reshape( pts(1,:)', size( rhoPlot ) );
    y = reshape( pts(2,:)', size( rhoPlot ) );
    z = reshape( pts(3,:)', size( rhoPlot ) );
    
    iso = isosurface( ...
        x, y, z, ...
        smooth3( abs( rhoPlot ), 'gaussian', 5 ), ...
        isoval, ...
        sgn * smooth3( angle( rhoPlot ), 'gaussian', 3 ) ...
    );
    patch( iso, 'FaceColor', 'interp', 'EdgeColor', 'none' );
    axis image;
    grid on;
    colormap( 'parula' );
    colorbar;
    tetLighting();
end