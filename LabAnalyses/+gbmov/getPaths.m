function [datadir,infodir,savedir] = getPaths(name)

if nargin == 0
   if ispc
      name = 'evinaa';
   else
      [~,name] = system('hostname');
   end
end

switch deblank(name)
   case 'UMR-LAU-MF003'
      %datadir = '/Volumes/Data/Human/STN/TEST2';
      datadir = '/Users/brian/Dropbox/Spectrum4';
      %infodir = '/Volumes/Data/Human/STN';
      infodir = '/Users/brian/Dropbox/Spectrum4';
      savedir = '/Users/brian/Dropbox/Spectrum4';
   case 'UMR-LAU-MF001'
      %datadir = '/Volumes/Data/Human/STN/TEST2';
      datadir = '/Users/brian.lau/Dropbox/Spectrum4';
      infodir = '/Volumes/Data/Human/STN';
      savedir = '/Users/brian.lau/Dropbox/Spectrum4';
   case 'air.local'
      datadir = '/Users/brian/Dropbox/Spectrum4';
      infodir = '/Users/brian/Dropbox/Spectrum4';
      savedir = '/Users/brian/Dropbox/Spectrum4';
   case 'evinaa'
      datadir = 'C:\Users\evinaa.sellaiah\Desktop\DATA_TASK_REST\Spectrum4';
      infodir = '\\192.168.16.180\Data\Human\STN';
      savedir = '';
   otherwise
      error('Undefined computer or path');
end