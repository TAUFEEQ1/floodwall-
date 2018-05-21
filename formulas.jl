#Assumptions for dimensions
base_len(x)=0.40*x #formula for base length
base_thick(x)=0.45*x #formula for base width
heel(x,z)=(2/3)*(x-z)
toe(x,z)=(1/3)*(x-z)
ecentricity(B,Mr,Mo,fv)=(B/2) - ((Mr-Mo)/fv)
tst(blen,wlt)=blen+(2*wlt)

#Vertical Forces
weight(spec_wt,leng,width,height)=spec_wt*leng*width*height
fboy1(a,H,twall,ah,t,len)= a*((H)*(0.5*twall)+(ah*(twall/2)*(t)))*len
fboy2(gm,c,twall,tf,lent)= lent*gm*((c+(twall/2)*tf))
Fbuoy(spec_wt,leng,width,height)=spec_wt*leng*width*height
Fv(wall,basew,Wwat,fb)=basew+wall+Wwat-fb

#sliding Forces
F_sta(sp,H,len)=len*0.5*0.5*sp*(H^2)

#Resisting Forces(horizontal)
Fr(Cf,fv)=Cf*fv
Fc(Cb,B)=Cb*B
Fp(kp,spec_soil,spec_water,t,len)=len*0.5*(kp*(spec_soil-spec_water)+spec_water)*(t^2)
Fkey(kp,spec_soil,spec_water,tkey,len)=len*0.5*(kp*(spec_soil-spec_water)+spec_water)*(tkey^2)
Fwall(kp,spec_soil,spec_water,tbase,len,t)=0.5*0.5*(len-t)*(kp*(spec_soil-spec_water)+spec_water)*(tbase^2)

#moments
M_sta(fst,H,t)= fst*((H+t)/3)
M_fp(fpee,t)= fpee*(t/3)
M_bouy(fb1,fb2,B) = (fb1*(B/3)) + (fb2*(2/3)*B)
Mbse(bw,B)=bw*(B/2)
Mwallwt(Fwt,C,twall)= Fwt*(C+(twall/2))
Mwh(waterw,B,Ah)=waterw*(B-(Ah/2))
Mfwall(fwall,t)=fwall*(t/3)
Mfkey(fkey,t)=fkey*((2/3)*t)

#soil pressure
soil_p(fv,blen,bwidth,ece)=(fv/(bwidth*blen))*(1+((6*ece)/bwidth))
soil_p1(fv,blen,bwidth,ece) =(fv/(bwidth*blen))*(1-((6*ece)/bwidth))
#forces on bolt
Tensr(Ae,fuk)=Ae*fuk
des_t(movert,bwallt,coeff)=movert/(coeff*bwallt*304.5)
Yms(fuk,fyk) = 1.2*(fuk/fyk)

#force on concrete
cconr(kc,he,fc)=kc*(sqrt(fc))*((he)^1.5)

#shear forces on concrete
edge_res(k1,dnom,alph,le,bet,fc,c1)=k1*(dnom^alph)*(le^bet)*sqrt(fc)*(c1^1.5)

#design wall span
Ph(Y,H)=Y*H
thickness(ph,wc,bet,stress)=sqrt((ph*(wc^2)*bet)/stress)
thicknes(alph,P,wc,E)=sqrt(360*alph*P*(wc^3))/E

#reinforcement
Are_a(Mb,df)=(Mb/1000)/(1.76*df)

#supports
ismall(coef,h) = 2*((coef*(h^4))/12)
ibig(coef,h) = (coef*(h^3))/12

#seals
Wm1(b,j,m,p)=2*b*j*m*p
Wm2(b,j,y)=b*j*y
Fi(Sp,At) = 0.9*At*Sp
