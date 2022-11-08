function [Rx,Ry,Rz] = xyzAng2RotMat(xyzAng)
% creates rotation matrices about x, y, and z, given the angles about
% x, y and z.

rx = xyzAng(1);
ry = xyzAng(2);
rz = xyzAng(3);

Rx = [1 0 0; 0 cos(rx) -sin(rx); 0 sin(rx) cos(rx)];
Ry = [cos(ry) 0 sin(ry); 0 1 0; -sin(ry) 0 cos(ry)];
Rz = [cos(rz) -sin(rz) 0; sin(rz) cos(rz) 0; 0 0 1];