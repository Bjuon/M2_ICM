function [pval] = correction_pval(pval,Method,plotsPt)
    if strcmp(Method , 'NoCorrection')
        pval = pval ;
    elseif strcmp(Method , 'FDR')
        pval = mafdr(pval,'BHFDR',true) ; 
    elseif strcmp(Method , 'Storey')
        pval = mafdr(pval) ; 
    elseif strcmp(Method , 'Holm')
        s=size(pval);
        if isvector(pval)
            if size(pval,1)>1
               pval=pval'; 
            end
            [sorted_p , sort_ids]=sort(pval);    
        else
            [sorted_p , sort_ids]=sort(reshape(pval,1,prod(s)));
        end
        [~, unsort_ids]=sort(sort_ids); %indices to return sorted_p to pvalues order
        if strcmp(plotsPt,'10kfilt')
            m = 100 ;
        else
            m = length(sorted_p); %number of tests
        end
        mult_fac=m:-1:1;
        cor_p_sorted=sorted_p.*mult_fac;
        cor_p_sorted(2:m)=max([cor_p_sorted(1:m-1); cor_p_sorted(2:m)]); %Bonferroni-Holm adjusted p-value
        corrected_p=cor_p_sorted(unsort_ids);
        pval=reshape(corrected_p,s);
        pval(pval>1)=1;
    else
        error(['Correction Method : ' Method ' unsupported' ])
    end
end