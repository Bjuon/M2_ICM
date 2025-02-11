function [returnMatrix] = ClinicalContacts(varargin)
    %CLINICALCONTACTS 
    % Input : ClinicalData.Old

    if ~nargin
        startpath = 'C:\LustreSync\hypoQAMPPE';
        ClinicalTable = readtable([startpath filesep 'PatientInfo.xlsx']) ;
    else 
        ClinicalTable = varargin{1};
    end
    

    ClinicalTable.C0D(ClinicalTable.C0D == 3) = 0 ;
    ClinicalTable.C0G(ClinicalTable.C0G == 3) = 0 ;
    ClinicalTable.C1D(ClinicalTable.C1D == 3) = 0 ;
    ClinicalTable.C1G(ClinicalTable.C1G == 3) = 0 ;
    ClinicalTable.C2D(ClinicalTable.C2D == 3) = 0 ;
    ClinicalTable.C2G(ClinicalTable.C2G == 3) = 0 ;
    ClinicalTable.C3D(ClinicalTable.C3D == 3) = 0 ;
    ClinicalTable.C3G(ClinicalTable.C3G == 3) = 0 ;

    returnMatrix = {} ;

    for row = 1 : length(ClinicalTable.PATIENTID)
        
        ContactDroit = 0 ;
        NbrContDroit = 0 ;
        ContactGauche = 0 ;
        NbrContGauche = 0 ;

        if ClinicalTable.C0D(row) == 1
            NbrContDroit = NbrContDroit + 1 ;
        end
        if ClinicalTable.C1D(row) == 1
            ContactDroit = 1 ;
            NbrContDroit = NbrContDroit + 1 ;
        end
        if ClinicalTable.C2D(row) == 1
            ContactDroit = ContactDroit + 2 ;
            NbrContDroit = NbrContDroit + 1 ;
        end
        if ClinicalTable.C3D(row) == 1
            ContactDroit = ContactDroit + 3 ;
            NbrContDroit = NbrContDroit + 1 ;
        end
        if ClinicalTable.C0G(row) == 1
            NbrContGauche = NbrContGauche + 1 ;
        end
        if ClinicalTable.C1G(row) == 1
            ContactGauche = 1 ;
            NbrContGauche = NbrContGauche + 1 ;
        end
        if ClinicalTable.C2G(row) == 1
            ContactGauche = ContactGauche + 2 ;
            NbrContGauche = NbrContGauche + 1 ;
        end
        if ClinicalTable.C3G(row) == 1
            ContactGauche = ContactGauche + 3 ;
            NbrContGauche = NbrContGauche + 1 ;
        end
    
    ContactDroit  = ContactDroit  / NbrContDroit  + 0.5 ;
    ContactGauche = ContactGauche / NbrContGauche + 0.5 ;
    
    returnMatrix(row,1) = ClinicalTable.PATIENTID(row) ;
    returnMatrix(row,2) = {ContactDroit} ;
    returnMatrix(row,3) = {ContactGauche} ;

    end

    returnMatrix = cell2table(returnMatrix,"VariableNames",{'name','RightClinicalContact','LeftClinicalContact'}) ;
      
end

