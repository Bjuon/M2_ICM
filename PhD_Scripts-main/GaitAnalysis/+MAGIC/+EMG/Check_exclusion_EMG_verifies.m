function Included = Check_exclusion_EMG_verifies(Project, Session, Patient ,Cond , num_trial, nt, MinTP)
    
    Included = 'to_define' ;

    if strcmp(Project,'PPN_spon') 
        if strcmp(Patient,'CHADO01') 
            Included = 'Yes' ;
            if strcmp(Cond, "OFF") && strcmp(num_trial{nt}, "012") ; Included = 'No' ; end % Anticipe
            if strcmp(Cond, "OFF") && strcmp(num_trial{nt}, "015") ; Included = 'No' ; end
            if strcmp(Cond, "OFF") && strcmp(num_trial{nt}, "019") ; Included = 'No' ; end
            if strcmp(Cond, "ON" ) && strcmp(num_trial{nt}, "001") ; Included = 'No' ; end
            if strcmp(Cond, "ON" ) && strcmp(num_trial{nt}, "006") ; Included = 'No' ; end % Soleus
            if strcmp(Cond, "ON" ) && strcmp(num_trial{nt}, "015") ; Included = 'No' ; end % Anticipe
        elseif strcmp(Patient,'SOUDA02')
            Included = 'Yes' ;
        elseif strcmp(Patient,'LESNE03')
            Included = 'Yes' ;
            if strcmp(Cond, "OFF") && strcmp(num_trial{nt}, "001") ; Included = 'No' ; end
            if strcmp(Cond, "ON" ) && strcmp(num_trial{nt}, "003") ; Included = 'No' ; end
            if strcmp(Cond, "ON" ) && strcmp(num_trial{nt}, "005") ; Included = 'No' ; end
            if strcmp(Cond, "ON" ) && strcmp(num_trial{nt}, "012") ; Included = 'No' ; end
        elseif strcmp(Patient,'AVALA08')
            Included = 'Yes' ;
        end



        
    end
        


        
if MinTP < 1
    Included = 'No' ;
end
        
end

