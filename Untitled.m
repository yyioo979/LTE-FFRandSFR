clear;
loop=1;
num=6;
r=1;
rc=0.6;
bbc=0;
bc=0;
bsnum=1;
At=-pi/2-pi/3*[0:6];
A=pi/3*[0:6];
aa=linspace(0,pi*2,80);

for k=1:loop
    bbc=bbc+sqrt(3)*r*exp(i*pi/6);
    for pp=1:num
        for p=1:k
            bsnum=bsnum+1;
            bc(1,bsnum)=bbc;
            bbc=bbc+sqrt(3)*r*exp(i*At(pp));
        end
    end
end

hold on;
axis square;
for k=1:bsnum;
    zp=bc(1,k)+r*exp(i*A);
    g1=fill(real(zp),imag(zp),'k');
    set(g1,'FaceColor',[1,0.5,0],'edgecolor',[1,0,0]);
    zr=bc(1,k)+rc*exp(i*aa);
    g2=fill(real(zr),imag(zr),'k');
    set(g2,'FaceColor',[1,0.5,0],'edgecolor',[1,0.5,0],'EraseMode','xor');
    text(real(bc(1,k)),imag(bc(1,k)),'fc','fontsize',10);
end