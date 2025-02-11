function output = Artefact_in_this_event_per_channel(time_event, LFPtrial_start, encode_or_decode, Artefacts_Detected_per_Sample, Encrypted_String, Size_around_event, Acceptable_Artefacted_Sample_In_Window)
        %ARTEFACT_IN_THIS_EVENT_PER_CHANNEL Write in event description the
        %score for each channel, centered on the event (before ';') or the
        %whole window (extended, -1 ; +1 arround the event)
    
        global tBlock


if strcmp('encode',encode_or_decode)
    time = time_event + LFPtrial_start ;
    Fs = Artefacts_Detected_per_Sample(1,1) ;
    Artefacts_Detected_per_Sample(1,1) = 0 ;
    Local     = '' ; 
    Extended  = '' ; 
    for ch = 1:size(Artefacts_Detected_per_Sample,2)
        Art_Local    = sum(Artefacts_Detected_per_Sample(round(Fs*(time-tBlock))   : round(Fs*(time+tBlock))  ,ch));
        Art_Extended = sum(Artefacts_Detected_per_Sample(round(Fs*(time-tBlock-1)) : round(Fs*(time+tBlock+1)),ch));
        Local    = [Local    num2str(Art_Local   ) '_'] ;
        Extended = [Extended num2str(Art_Extended) '_'] ;
    end
    Description_String = [Local(1:end-1) '-' Extended(1:end-1)] ;
    output = Description_String ;
%     if ~strcmp(output,'0_0_0_0_0_0_0_0_0_0_0_0_0_0-0_0_0_0_0_0_0_0_0_0_0_0_0_0')
%         disp(output)
%     end


elseif strcmp('decode',encode_or_decode)
    ListeQual = [];
    temp = strsplit(Encrypted_String,'-');
    Local    = temp{1} ;
    Extended = temp{2} ;
    if     Size_around_event == 0
        Interest = Local ;
    elseif Size_around_event == 1
        Interest = Extended ;
    end
    temp1 = strsplit(Interest,'_');
    if Acceptable_Artefacted_Sample_In_Window < 9970
        for ch = 1:length(temp1)
            value = str2num(temp1{ch}) ;
            if value > Acceptable_Artefacted_Sample_In_Window
                ListeQual(ch) = 0 ;
            else
                ListeQual(ch) = 1 ;
            end
        end
        output = ListeQual ;
    elseif Acceptable_Artefacted_Sample_In_Window == 9979
        output = temp1 ;
    end


end