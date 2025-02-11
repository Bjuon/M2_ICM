function par_save(varin)
%PAR_SAVE Save inside a parfor loop : arg = filename,var kwarg = extention
if numel(varin) > 2
save(varin{1},varin{2},varin{3});
elseif numel(varin) == 2
save(varin{1},varin{2});
else
    fprintf(2, ["error parsave :" varin ])
end
end

