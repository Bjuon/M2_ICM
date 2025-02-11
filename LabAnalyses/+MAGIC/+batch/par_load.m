function [loadedVar] = par_load(filename,varname)
%PAR_LOAD Load inside a parfor loop : arg = filename,varname 
loadedVar = load(filename,varname) ;
end

