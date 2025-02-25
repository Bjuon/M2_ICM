%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specifier les patients 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cond = "FOG" ; % FOG ou OFF ou ON ou SAIN
folder = 'Z:\DATA\' ; 
ColorFOG = [1 0 0] ; 
ColorNor = [.5 .5 .5] ;

cut_FOGst = 0;
cut_FOGnd = 0;

if strcmp(Cond,'FOG')
    h = btkReadAcquisition([folder 'ALb\' 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_053.c3d']);
    cut_st  = 550;
    cut_end = 3000;
    cut_FOGst = 1196;
    cut_FOGnd = 1743;
elseif strcmp(Cond,'OFF')
    h = btkReadAcquisition([folder 'ALb\' 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_OFF_GNG_GAIT_012.c3d']);
    cut_st  = 550;
    cut_end = 2050;
elseif strcmp(Cond,'ON')
    h = btkReadAcquisition([folder 'ALb\' 'ParkPitie_2020_06_25_ALb_MAGIC_POSTOP_ON_GNG_GAIT_002.c3d']);
    cut_st  = 520;
    cut_end = 1760;
end



Step = 10; % step between each frame



Coord = btkGetMarkers(h);
f = btkGetPointFrequency(h);

max = cut_end/f ; % + 0.1*(cut_end-cut_st)/f ;
figure;

% RIGHT SPATIAL
RASI = [(1:size(Coord.RASI,1))'*(1/f),Coord.RASI(:,3),Coord.RASI(:,2),Coord.RASI(:,1)*10e-3];
RPSI = [(1:size(Coord.RPSI,1))'*(1/f),Coord.RPSI(:,3),Coord.RPSI(:,2),Coord.RPSI(:,1)*10e-3];
RPER = [(1:size(Coord.RPER,1))'*(1/f),Coord.RPER(:,3),Coord.RPER(:,2),Coord.RPER(:,1)*10e-3];
RMALE= [(1:size(Coord.RMALE,1))'*(1/f),Coord.RMALE(:,3),Coord.RMALE(:,2),Coord.RMALE(:,1)*10e-3];
RHEE = [(1:size(Coord.RHEE,1))'*(1/f),Coord.RHEE(:,3),Coord.RHEE(:,2),Coord.RHEE(:,1)*10e-3];
RHLX = [(1:size(Coord.RHLX,1))'*(1/f),Coord.RHLX(:,3),Coord.RHLX(:,2),Coord.RHLX(:,1)*10e-3];
% Unused : RSHO, RELB, RWRA
RSHO = [(1:size(Coord.RSHO,1))'*(1/f),Coord.RSHO(:,3),Coord.RSHO(:,2),Coord.RSHO(:,1)*10e-3];
RELB = [(1:size(Coord.RELB,1))'*(1/f),Coord.RELB(:,3),Coord.RELB(:,2),Coord.RELB(:,1)*10e-3];
RWRA = [(1:size(Coord.RWRA,1))'*(1/f),Coord.RWRA(:,3),Coord.RWRA(:,2),Coord.RWRA(:,1)*10e-3];

HIP  = [(1:size(Coord.RASI,1))'*(1/f),(RASI(:,2)+RPSI(:,2))/2,(RASI(:,3)+RPSI(:,3))/2,(RASI(:,4)+RPSI(:,4))/2];

subplot(6,1,1);

for n=1:Step:max*f  % number of times steps
    if n > cut_FOGst && n < cut_FOGnd
        plot([HIP(n,3)-HIP(n,3)+n*5 RPER(n,3)-HIP(n,3)+n*5 RMALE(n,3)-HIP(n,3)+n*5 RHEE(n,3)-HIP(n,3)+n*5 RHLX(n,3)-HIP(n,3)+n*5],...
            [HIP(n,2) RPER(n,2) RMALE(n,2) RHEE(n,2) RHLX(n,2)],'Color',ColorFOG);
    else
        plot([HIP(n,3)-HIP(n,3)+n*5 RPER(n,3)-HIP(n,3)+n*5 RMALE(n,3)-HIP(n,3)+n*5 RHEE(n,3)-HIP(n,3)+n*5 RHLX(n,3)-HIP(n,3)+n*5],...
            [HIP(n,2) RPER(n,2) RMALE(n,2) RHEE(n,2) RHLX(n,2)],'Color',ColorNor);
    end
    hold on
end
axis equal
axis image
xlim ([cut_st*5 cut_end*5])

% LEFT SPATIAL
LASI = [(1:size(Coord.LASI,1))'*(1/f),Coord.LASI(:,3),Coord.LASI(:,2),Coord.LASI(:,1)*10e-3];
LPSI = [(1:size(Coord.LPSI,1))'*(1/f),Coord.LPSI(:,3),Coord.LPSI(:,2),Coord.LPSI(:,1)*10e-3];
LPER = [(1:size(Coord.LPER,1))'*(1/f),Coord.LPER(:,3),Coord.LPER(:,2),Coord.LPER(:,1)*10e-3];
LMALE = [(1:size(Coord.LMALE,1))'*(1/f),Coord.LMALE(:,3),Coord.LMALE(:,2),Coord.LMALE(:,1)*10e-3];
LHEE = [(1:size(Coord.LHEE,1))'*(1/f),Coord.LHEE(:,3),Coord.LHEE(:,2),Coord.LHEE(:,1)*10e-3];
LHLX = [(1:size(Coord.LHLX,1))'*(1/f),Coord.LHLX(:,3),Coord.LHLX(:,2),Coord.LHLX(:,1)*10e-3];
% Unused : LSHO, LELB, LWRA
LSHO = [(1:size(Coord.LSHO,1))'*(1/f),Coord.LSHO(:,3),Coord.LSHO(:,2),Coord.LSHO(:,1)*10e-3];
LELB = [(1:size(Coord.LELB,1))'*(1/f),Coord.LELB(:,3),Coord.LELB(:,2),Coord.LELB(:,1)*10e-3];
LWRA = [(1:size(Coord.LWRA,1))'*(1/f),Coord.LWRA(:,3),Coord.LWRA(:,2),Coord.LWRA(:,1)*10e-3];

HIP  = [(1:size(Coord.LASI,1))'*(1/f),(LASI(:,2)+LPSI(:,2))/2,(LASI(:,3)+LPSI(:,3))/2,(LASI(:,4)+LPSI(:,4))/2];
subplot(6,1,2);

for n=1:Step:max*f % numbeL of times steps
    if n > cut_FOGst && n < cut_FOGnd  %506 435
        plot([HIP(n,3)-HIP(n,3)+n*5 LPER(n,3)-HIP(n,3)+n*5 LMALE(n,3)-HIP(n,3)+n*5 LHEE(n,3)-HIP(n,3)+n*5 LHLX(n,3)-HIP(n,3)+n*5],...
            [HIP(n,2) LPER(n,2) LMALE(n,2) LHEE(n,2) LHLX(n,2)],'Color',ColorFOG);
    else
         plot([HIP(n,3)-HIP(n,3)+n*5 LPER(n,3)-HIP(n,3)+n*5 LMALE(n,3)-HIP(n,3)+n*5 LHEE(n,3)-HIP(n,3)+n*5 LHLX(n,3)-HIP(n,3)+n*5],...
            [HIP(n,2) LPER(n,2) LMALE(n,2) LHEE(n,2) LHLX(n,2)],'Color',ColorNor);
   
    end
    hold on
end
axis equal
axis image
xlim ([cut_st*5 cut_end*5])

% EMG
EMG     = btkGetAnalogs(h);
Fech    = btkGetAnalogFrequency(h);
RTA     = EMG.Voltage_RTA(1:round(max*Fech));
LTA     = EMG.Voltage_LTA(1:round(max*Fech));
RSOL    = EMG.Voltage_RSOL(1:round(max*Fech));
LSOL    = EMG.Voltage_LSOL(1:round(max*Fech));

% Sample and filter
emg = SampledProcess('values',[RTA, RSOL, LTA,LSOL],'Fs',Fech,'tStart',0,...
    'labels',[metadata.Label('name','RTA'),metadata.Label('name','RSOL'),metadata.Label('name','LTA'),metadata.Label('name','LSOL')]);
emg.bandpass('Fstop1',25,'Fpass1',30,'Fpass2',300,'Fstop2',305);emg.fix();
emg = SampledProcess('values',abs(emg.values{:}),'Fs',emg.Fs,'tStart',emg.tStart,...
    'labels',emg.labels);
emg.lowpass('Fpass',30,'Fstop',35);emg.fix();

for i = 1:4
    subplot(6,1,i+2);
    plot(emg.times{1}(1:cut_FOGst*(Fech/f)),emg.values{1}(1:cut_FOGst*(Fech/f),i),'Color',ColorNor);hold on;
    plot(emg.times{1}(cut_FOGst*(Fech/f):cut_FOGnd*(Fech/f)),emg.values{1}(cut_FOGst*(Fech/f):cut_FOGnd*(Fech/f),i),'Color',ColorFOG);hold on;
    plot(emg.times{1}(cut_FOGnd*(Fech/f):end),emg.values{1}(cut_FOGnd*(Fech/f):end,i),'Color',ColorNor);
    %linkaxes(h,'y')
    %ylim(h(1),[0 0.2])
    %axis tight
    xlim([cut_st/f cut_end/f])
    hold off
end
