function [xx,yy,zz] = uniformgrid(min,max,n_lines,n_points)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% INPUT 
% min value of domain
% max value of domain 
% Number of grid lines to generate 

% Establish xo yo 
% x = [-1 , 1] ; 
% y = [-1 , 1] ;

x = [min , max] ; 
y = [min , max] ;
% Number of points to generate
nx = n_lines ;
ny = n_points ; 
x_vect = linspace(x(1),x(2),nx) ; 
y_vect = linspace(y(1),y(2),ny) ;
% Generate Mesh 
[X,Y] = meshgrid(x_vect,y_vect);

% Put it into an array 
x_values = cat(1,X(:),Y(:));
y_values = cat(1,Y(:),X(:));
z_values = zeros(size(x_values));
image_values = [x_values,y_values,z_values]
% Check to see if the output is correct 
% plot(image_values(:,1),image_values(:,2),'.')
uniform_grid = image_values ; 

xx = x_values ;
yy = y_values ;
zz = z_values ;
end

