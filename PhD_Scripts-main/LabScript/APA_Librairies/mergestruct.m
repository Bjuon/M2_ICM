function struct=mergestruct(structA,structB)
if nargin==1
    struct=structA;
else
    struct=structA;
    champ=fieldnames(structB);
    for ii=1:length(champ)
        struct.(champ{ii})=structB.(champ{ii});
    end
end