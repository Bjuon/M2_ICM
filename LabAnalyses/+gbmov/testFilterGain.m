f = 0:1688;
fs = 278;

v = f./fs;
R = 4;
M = 1;
N = 4;
H = abs((sin(R*M*pi*v)) ./ (R*M*sin(pi*v))).^3;
%H = abs((sin(pi*f./fs)) ./ (sin(pi*f./fs))).^3;


load WARJe_25012016_LFP_PILOT_BASELINEASSIS_ON_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
hold
plot(f,10*log10(p(:,6)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-23.5)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,6)));
plot(f,10*log10( p(:,6)./H' ) );

load WARJe_25012016_LFP_PILOT_BASELINEASSIS_OFF_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
hold
plot(f,10*log10(p(:,6)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-23.5)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,6)));
plot(f,10*log10( p(:,6)./H' ) );

load ROYEs_25032013_LFP_GBMOV_BASELINEASSIS_OFF_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 512;
hold
plot(f,10*log10(abs(sinc(f./Fs).^3.^2))-26.5)
plot(f,10*log10(p(:,1)))
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );


load PASEl_27052013_LFP_GBMOV_BASELINEASSIS_OFF_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-24.5)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );

load PASEl_27052013_LFP_GBMOV_BASELINEASSIS_ON_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 512;
figure; hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs).^3.^2))-26.75)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );

load SOUJo_10062013_LFP_GBMOV_BASELINEASSIS_ON_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-23.5)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );

load SOUJo_10062013_LFP_GBMOV_BASELINEASSIS_ON_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
figure; hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-23.5)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );

load RICDi_28042014_LFP_GBMOV_BASELINEASSIS_OFF_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-22)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );

load PHIJe_19122016_LFP_GBMOV_BASELINEASSIS_OFF_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-22)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );

load GONFi_11102016_LFP_GBMOV_BASELINEASSIS_OFF_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
figure; hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-22)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );

load GONFi_11102016_LFP_GBMOV_BASELINEASSIS_ON_PSD.mat
p = squeeze(PSD.raw.values{1});
f = PSD.raw.f;
Fs = 2048;
figure; hold
plot(f,10*log10(p(:,1)))
plot(f,10*log10(abs(sinc(f./Fs)).^3.^2)-22)
set(gca,'xscale','log')

figure; hold on
H = abs(sinc(f./Fs)).^3.^2;
plot(f,10*log10(p(:,1)));
plot(f,10*log10( p(:,1)./H' ) );
