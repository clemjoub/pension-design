subroutine AppspackIn

use params
use filenames
implicit none

character(len=40)			name				! A variable that "absorbs" the parameter name in the read statement
integer, allocatable::			paramfile(:)
integer::				 i
integer::				cohort				! Birth cohort
double precision::			raw_h_switch, raw_w_switch

integer     				k, kk
double precision::      maleprob, femaleprob


inest=0


Call getarg(1,JLSin)
call getarg(2,JLSout)
call getarg(3,tag)
call getarg(4,tagest)
! Read parameters that are being estimated

if (lenovo==1) then
JLSin='Newmin.txt'
endif

open (unit=1, file=pathsmallscratch//JLSin,position='rewind')
read(unit=1,fmt=*) name
read(unit=1,fmt=*)numestparms
if (gradient==0) allocate(estparms(1,numestparms))
do i=1,numestparms
	read(unit=1,fmt=*) estparms(1,i)
enddo
close(1)

!! If computing std errors, bump one estimated parameter to compute the gradient
if (rungradient==1) then
    bump=1+hdiff
    h_mat(gradient)=2*hdiff*estparms(1,int((gradient+1)/2))
    if (gradient>numestparms) bump=1-hdiff
    estparms(1,int((gradient+1)/2))=estparms(1,int((gradient+1)/2))*bump
endif

! Read all parameters from input file


open(unit=4,file=pathinput//'input'//adjustl(trim(specification))//'.txt',position='rewind')
read(unit=4,fmt=*) totnumparms
if (gradient==0) then
    allocate(inest		(1,totnumparms))
    allocate(parms		(1,totnumparms))
    allocate(scale1		(1,totnumparms))
    allocate(upper		(1,totnumparms))
    allocate(lower		(1,totnumparms))
    allocate(nameparams	(1,totnumparms))
endif
do i=1,totnumparms
	read(unit=4,fmt=*) parms(1,i),lower(1,i),upper(1,i),scale1(1,i),inest(1,i),nameparams(1,i)
enddo
close(4)


!! Replace estimated parameters by candidate values
k=1
do i=1,totnumparms
if (inest(1,i).eq.1) then
	parms(1,i)=estparms(1,k)
	k=k+1
endif
enddo



!! store parameter values in corresponding variables
i=1
do typ=1,ntypes
lambdaedu_h(typ) = parms(1,i) 
i=i+1
lambdaedu_w(typ) = parms(1,i) 
i=i+1
lambdacohort(typ) = parms(1,i) 
i=i+1
alphatyp(typ) = parms(1,i) 
i=i+1
probamyop(typ)=parms(1,i)
i=i+1
enddo
!print*, 'reading preference parameters'
do typ=1,ntypes
 rho(typ) = parms(1,i)
i=i+1
 sigma(typ) = parms(1,i)
i=i+1
 raw_delta(typ,1) = parms(1,i)
i=i+1
 raw_delta(typ,2) = parms(1,i)
i=i+1
 raw_delta(typ,3) = parms(1,i)
i=i+1
 raw_delta(typ,4) = parms(1,i)
i=i+1
 raw_delta(typ,5) = parms(1,i)
i=i+1
 raw_delta(typ,7) = parms(1,i)
i=i+1
enddo
leis_comp   = parms(1,i)
i=i+1
delta_kids = parms(1,i) 
i=i+1
sig_pref_h = parms(1,i) 
i=i+1
sig_pref_w = parms(1,i) 
i=i+1
raw_h_switch_act = parms(1,i) 
i=i+1
raw_w_switch_act = parms(1,i) 
i=i+1
raw_h_switch_sect = parms(1,i) 
i=i+1
raw_w_switch_sect = parms(1,i) 
i=i+1
!! !print*,'reading wage offer parameters'
do typ=1,ntypes
if (typ==1) then
alpha(typ,1) = parms(1,i) 
i=i+1
alpha(typ,2) = parms(1,i) 
i=i+1
alpha(typ,3) = parms(1,i) 
i=i+1
elseif (typ>1) then
alpha(typ,1) = parms(1,i) 
i=i+1
alpha(typ,2) = parms(1,i) 
i=i+1
alpha(typ,3) = parms(1,i) 
i=i+1
endif
enddo
do typ=1,ntypes
SR_Fh(typ) = parms(1,i) 
i=i+1
SR_Ih(typ) = parms(1,i) 
i=i+1
SR_Fw(typ)= parms(1,i) 
i=i+1
SR_Iw(typ) = parms(1,i) 
i=i+1
enddo
theta_cohort_F = parms(1,i) 
i=i+1
theta_cohort_I = parms(1,i) 
i=i+1
g_gap = parms(1,i) 
i=i+1
theta_FhFh = parms(1,i) 
i=i+1
theta_IhIh = parms(1,i) 
i=i+1
!read (fmt=*,unit=paramfile(i)) theta_IhFh
!i=i+1
theta_FwFw = parms(1,i) 
i=i+1
theta_IwIw = parms(1,i) 
i=i+1
!read (fmt=*,unit=paramfile(i)) theta_FwIw
theta_FhFh2 = parms(1,i) 
i=i+1
theta_FhIh2 = parms(1,i) 
i=i+1
theta_IhFh2 = parms(1,i) 
i=i+1
theta_IhIh2 = parms(1,i) 
i=i+1
theta_FwFw2 = parms(1,i) 
i=i+1
theta_FwIw2 = parms(1,i) 
i=i+1
theta_IwFw2 = parms(1,i) 
i=i+1
theta_IwIw2 = parms(1,i) 
i=i+1
XPtransfer = parms(1,i) 
i=i+1
theta_eduFh = parms(1,i) 
i=i+1
theta_eduIh = parms(1,i) 
i=i+1
theta_eduFw = parms(1,i) 
i=i+1
theta_eduIw = parms(1,i) 
i=i+1
theta_grad_Fh = parms(1,i) 
i=i+1
theta_grad_Fw = parms(1,i) 
i=i+1
theta_eduXPh = parms(1,i) 
i=i+1
theta_eduXPw = parms(1,i) 
i=i+1
sig_Fh = parms(1,i) 
i=i+1
sig_Ih = parms(1,i) 
i=i+1
sig_Fw = parms(1,i) 
i=i+1
sig_Iw = parms(1,i) 
i=i+1
!! !print*, 'reading unemployment logit model parameters'
gamma(1)   = parms(1,i) 
i=i+1
gamma(2) = parms(1,i) 
i=i+1
gammacov(1) = parms(1,i) 
i=i+1
gammacov(2) = parms(1,i)
i=i+1
gammaXP(1) = parms(1,i) 
i=i+1
gammaXP(2) = parms(1,i) 
i=i+1
gammaedu(1) = parms(1,i) 
i=i+1
gammaedu(2) = parms(1,i) 
i=i+1
gammaage(1) = parms(1,i) 
i=i+1
gammaage(2) = parms(1,i) 
i=i+1
!! !!print*, 'reading other parameters'
nparams = parms(1,i) 
i=i+1
ndraws_st = parms(1,i) 
i=i+1
nspl = parms(1,i) 
i=i+1
ndraws_eps = parms(1,i) 
i=i+1
curv_a = parms(1,i) 
i=i+1
curv_B = parms(1,i) 
i=i+1
nsav = parms(1,i) 
i=i+1
death = parms(1,i) 
i=i+1

retirement = parms(1,i) 
i=i+1
startwork = parms(1,i) 
i=i+1



startrec = parms(1,i)
i=i+1
endrec = parms(1,i) 
i=i+1
cmin = parms(1,i) 
i=i+1
scale = parms(1,i) 
i=i+1
sav_min = parms(1,i) 
i=i+1
lny_min = parms(1,i) 
i=i+1
a_min0 = parms(1,i) 
i=i+1
B_min0 = parms(1,i) 
i=i+1
bar0 = parms(1,i) 
i=i+1
abar1 = parms(1,i) 
i=i+1
abar2 = parms(1,i) 
i=i+1
r = parms(1,i) 
i=i+1
r_B_bar = parms(1,i) 
i=i+1
sig_ret = parms(1,i) 
i=i+1



!! Allocate array sizes using the parameters values read from input file

!ndraws_eps	= 1
nret		=	death-retirement+1	
nwork		=	retirement-startwork
noutspl  	=	ndraws_st-nspl
nd			=	nds*nsav


do typ=1,ntypes
!raw_delta(typ,2)=raw_delta(1,2)
!raw_delta(typ,4)=raw_delta(1,4)
raw_delta(typ,5)=raw_delta(typ,2)+raw_delta(typ,4)
raw_delta(typ,6)=raw_delta(typ,3)+raw_delta(typ,4)
raw_delta(typ,8)=raw_delta(typ,7)+raw_delta(typ,2)
raw_delta(typ,9)=raw_delta(typ,3)+raw_delta(typ,7)+leis_comp
alpha(typ,2)=alpha(1,2)
alpha(typ,3)=alpha(1,3)
enddo

!alpha(3,1)			=   -1.0
!alpha(3,2)			=	0.005


!MPyrs		=	int((nwork)/2)
MPyrs       =	20
Bbar1		=	abar1						
Bbar2		=	abar2	


!! Fill in grid with age-specific minimum and maximum asset holdings 

do age=1,death
	if (age<retirement) then
!		a_max(age)=1.5*age
		a_max(age)=2.0*age
		B_max(age)=age*age*age/5000
	elseif (age>=retirement) then
		a_max(age)=6*retirement
		B_max(age)=1.0
	endif
enddo

do age=1,death
	a_min(age)=a_min0
	B_min(age)=B_min0
enddo


realizedret(1)	= 0.128
realizedret(2)	= 0.128
realizedret(3)	= 0.2851
realizedret(4)	= 0.2125
realizedret(5)	= 0.0356
realizedret(6)	= 0.1342
realizedret(7)	= 0.1229
realizedret(8)	= 0.0541
realizedret(9)	= 0.0649
realizedret(10)	= 0.0692
realizedret(11)	= 0.1562
realizedret(12)	= 0.2968
realizedret(13)	= 0.0304
realizedret(14)	= 0.1621
realizedret(15)	= 0.1818
realizedret(16)	=-0.0252
realizedret(17)	= 0.0354
realizedret(18)	= 0.0472
realizedret(19)	=-0.0114
realizedret(20)	= 0.1626
realizedret(21)	= 0.0444
realizedret(22)	= 0.0674
realizedret(23)	= 0.0298
realizedret(24)	= 0.1055
realizedret(25)	= 0.0886
realizedret(26)	= 0.0458
realizedret(27)	= 0.1577
realizedret(28)	=-0.1998
realizedret(29)	= 0.1770


!do i=28,100
!realizedret(i)=r_B_bar
!enddo

close (1)
close (3)

fixedcom=0.00393
varcomrt=0.026

fixedbalcom=0.0
varbalcomrt=0.0

do cohort=1,ncohort
do age=1,100
if ((cohort==1 .and. age.ge.23 .and. age.le.30).or.(cohort==2 .and. age.ge.18.and. age.le.25).or.(cohort==3 .and. age.ge.18.and.age.le.20) )then
	fixedbalcom(cohort,age)=0.014
	varbalcomrt(cohort,age)=0.007
endif
enddo
enddo

allocate(grid_sav           (nsav                                                   ))
allocate(Vfun               (nd                                                     ))
allocate(statemat_a			(			ndraws_st		,death	))
allocate(statemat_Bh    	(			ndraws_st		,death	))
allocate(statemat_Bw    	(			ndraws_st		,death	))
allocate(statemat_XP_Fh  	(			ndraws_st		,death	))
allocate(statemat_XP_Fw 	(			ndraws_st		,death	))
allocate(statemat_XP_Ih 	(			ndraws_st		,death	))
allocate(statemat_XP_Iw 	(			ndraws_st		,death	))
allocate(statemat_edu_h 	(			ndraws_st		,death	))
allocate(statemat_edu_w 	(			ndraws_st		,death	))
allocate(statemat_cohort    (			ndraws_st		,death	))
allocate(statemat_type  	(			ndraws_st		,death	))
allocate(statemat_pastd_h   (			ndraws_st		,death	))
allocate(statemat_pastd_w   (			ndraws_st		,death	))
allocate(Emax				(			ndraws_st		,death	))
allocate(Emaxspl			(nspl	   	                			))
allocate(an_Emax			(			ndraws_st		,death	))
allocate(Num_Error			(			ndraws_st		,death	))
allocate(Interp_Emax	    (			ndraws_st		,death	))
allocate(Interp_Error    	(			ndraws_st		,death	))
allocate(avsav_out			(			ndraws_st		,death	))
allocate(avy_out			(			ndraws_st		,death	))
allocate(d_out				(nds,			ndraws_st		,death	))
!allocate(Emax				(		ntypes,	ndraws_st		,death	))
!allocate(an_Emax			(		ntypes,	ndraws_st		,death	))
!allocate(Num_Error			(		ntypes,	ndraws_st		,death	))
!allocate(Interp_Emax   	(		ntypes,	ndraws_st		,death	))
!allocate(Interp_Error   	(		ntypes,	ndraws_st		,death	))
!allocate(avsav_out			(		ntypes,	ndraws_st		,death	))
!allocate(avy_out			(		ntypes,	ndraws_st		,death	))
!allocate(d_out				(nds,   	ntypes,	ndraws_st		,death	))
!allocate(savprob_out    	(nsav,	        ntypes,	ndraws_st		,death	))
allocate(sav_out			(			 	  ndraws_eps		))
allocate(y_out				(				  ndraws_eps		))
allocate(Vmax				(				  ndraws_eps		))
allocate(an_Vmax			(				  ndraws_eps		))
allocate(d		        	(nds,		        	  ndraws_eps		))
allocate(savdum				(nsav,   			  ndraws_eps		))


if (verbose1==1) then

open (unit=93, file=pathoutput//adjustl(trim(ctag))//'Spec.txt',position='rewind')
write (93,*) 'path'           ,path
write (93,*) 'pathoutput'     ,pathoutput
write (93,*) 'pathdatavsmodel',pathdatavsmodel
write (93,*) 'counterfactual', counterfactual
close(93)

open (unit=98,file=pathoutput//adjustl(trim(ctag))//'checkparams.txt',position='rewind')

write(98,*),'totnumparms',totnumparms

write(98,*) 	lambdaedu_h(1),'	lambdaedu_h(1)'
write(98,*) 	lambdaedu_w(1),'	lambdaedu_w(1)'
write(98,*) 	lambdacohort(1),'	lambdacohort(1)'
write(98,*) 	alphatyp(1),'	alphatyp(1)'
write(98,*) 	probamyop(1),'	probamyop(1)'
write(98,*) 	lambdaedu_h(2),'	lambdaedu_h(2)'
write(98,*) 	lambdacohort(2)	,'lambdacohort(2)'
write(98,*) 	alphatyp(2)	,'alphatyp(2)'
write(98,*) 	probamyop(2),'	probamyop(2)'
write(98,*) 	lambdaedu_h(3)	,'lambdaedu_h(3)'
write(98,*) 	lambdaedu_w(3)	,'lambdaedu_w(3)'
write(98,*) 	lambdacohort(3)	,'lambdacohort(3)'
write(98,*) 	alphatyp(3)	,'alphatyp'
write(98,*) 	probamyop(3),'	probamyop(3)'
write(98,*) 	rho(1)	,'rho(1)'
write(98,*) 	sigma(1),'	sigma(1)'
write(98,*) 	raw_delta(1,1),'	raw_delta(11)'
write(98,*) 	raw_delta(1,2),'	raw_delta(12)'
write(98,*) 	raw_delta(1,3)	,'raw_delta(13)'
write(98,*) 	raw_delta(1,4)	,'raw_delta(14)'
write(98,*) 	raw_delta(1,5)	,'raw_delta(15)'
write(98,*) 	raw_delta(1,7)	,'raw_delta(17)'
write(98,*) 	rho(2)	,'rho(2)'
write(98,*) 	sigma(2),'	sigma(2)'
write(98,*) 	raw_delta(2,1),'	raw_delta(21)'
write(98,*) 	raw_delta(2,2)	,'raw_delta(22)'
write(98,*) 	raw_delta(2,3)	,'raw_delta(23)'
write(98,*) 	raw_delta(2,4)	,'raw_delta(24)'
write(98,*) 	raw_delta(2,5)	,'raw_delta(25)'
write(98,*) 	raw_delta(2,7)	,'raw_delta(27)'
write(98,*) 	rho(3)	,'rho(3)'
write(98,*) 	sigma(3),'	sigma(3)'
write(98,*) 	raw_delta(3,1),'	raw_delta(31)'
write(98,*) 	raw_delta(3,2)	,'raw_delta(32)'
write(98,*) 	raw_delta(3,3)	,'raw_delta(33)'
write(98,*) 	raw_delta(3,4)	,'raw_delta(34)'
write(98,*) 	raw_delta(3,5)	,'raw_delta(35)'
write(98,*) 	raw_delta(3,7)	,'raw_delta(37)'
write(98,*) 	delta_kids	,'delta_kids'
write(98,*) 	sig_pref_h	,'sig_pref_h'
write(98,*) 	sig_pref_w	,'sig_pref_w'
write(98,*) 	raw_h_switch_act,'	raw_h_switch_act'
write(98,*) 	raw_w_switch_act,'	raw_w_switch_act'
write(98,*) 	raw_h_switch_sect,'	raw_h_switch_sect'
write(98,*) 	raw_w_switch_sect,'	raw_w_switch_sect'
write(98,*) 	alpha(1,1)	,'alpha(11)'
write(98,*) 	alpha(1,2)	,'alpha(12)'
write(98,*) 	alpha(1,3)	,'alpha(13)'
write(98,*) 	alpha(2,1),'	alpha(21)'
write(98,*) 	alpha(2,2),'	alpha(22)'
write(98,*) 	alpha(2,3),'	alpha(23)'
write(98,*) 	alpha(3,1),'	alpha(31)'
write(98,*) 	alpha(3,2),'	alpha(32)'
write(98,*) 	alpha(3,3),'	alpha(33)'
write(98,*) 	SR_Fh(1)	,'SR_Fh(1)'
write(98,*) 	SR_Ih(1)	,'SR_Ih(1)'
write(98,*) 	SR_Fw(1)	,'SR_Fw(1)'
write(98,*) 	SR_Iw(1)	,'SR_Iw(1)'
write(98,*) 	SR_Fh(2)	,'SR_Fh(2)'
write(98,*) 	SR_Ih(2)	,'SR_Ih(2)'
write(98,*) 	SR_Fw(2)	,'SR_Fw(2)'
write(98,*) 	SR_Iw(2)	,'SR_Iw(2)'
write(98,*) 	SR_Fh(3)	,'SR_Fh(3)'
write(98,*) 	SR_Ih(3)	,'SR_Ih(3)'
write(98,*) 	SR_Fw(3)	,'SR_Fw(3)'
write(98,*) 	SR_Iw(3)	,'SR_Iw(3)'
write(98,*) 	theta_cohort_F,'	theta_cohort_F'
write(98,*) 	theta_cohort_I	,'theta_cohort_I'
write(98,*) 	g_gap, 'g_gap'	
write(98,*) 	theta_FhFh,'	theta_FhFh'
write(98,*) 	theta_IhIh,'	theta_IhIh'
write(98,*) 	theta_FwFw,'	theta_FwFw'
write(98,*) 	theta_IwIw,'	theta_IwIw'
write(98,*) 	theta_FhFh2,'	theta_FhFh2'
write(98,*) 	theta_FhIh2,'	theta_FhIh2'
write(98,*) 	theta_IhFh2,'	theta_IhFh2'
write(98,*) 	theta_IhIh2,'	theta_IhIh2'
write(98,*) 	theta_FwFw2,'	theta_FwFw2'
write(98,*) 	theta_FwIw2,'	theta_FwIw2'
write(98,*) 	theta_IwFw2,'	theta_IwFw2'
write(98,*) 	theta_IwIw2,'	theta_IwIw2'
write(98,*) 	Xptransfer	,'Xptransfer'
write(98,*) 	theta_eduFh	,'theta_eduFh'
write(98,*) 	theta_eduIh,'	theta_eduIh'
write(98,*) 	theta_eduFw,'	theta_eduFw'
write(98,*) 	theta_eduIw,'	theta_eduIw'
write(98,*) 	theta_grad_Fh,'	theta_grad_Fh'
write(98,*) 	theta_grad_Fw	,'theta_grad_Fw'
write(98,*) 	theta_eduXPh	,'theta_eduXPh'
write(98,*) 	theta_eduXPw	,'theta_eduXPw'
write(98,*) 	sig_Fh,'	sig_Fh'
write(98,*) 	sig_Ih	,'sig_Ih'
write(98,*) 	sig_Fw	,'sig_Fw'
write(98,*) 	sig_Iw	,'sig_Iw'
write(98,*) 	gamma	,'gamma'
write(98,*) 	gamma	,'gamma'
write(98,*) 	gammacov(1),'	gammacov(1)'
write(98,*) 	gammacov(2),'	gammacov(2)'
write(98,*) 	gammaXP,'	gammaXP'
write(98,*) 	gammaXP,'	gammaXP'
write(98,*) 	gammaedu(1),'	gammaedu(1)'
write(98,*) 	gammaedu(2),'	gammaedu(2)'
write(98,*) 	gammaage(1),'	gammaage(1)'
write(98,*) 	gammaage(2),'	gammaage(2)'
write(98,*) 	nparams,'	nparams'
write(98,*) 	ndraws_st,'	ndraws_st'
write(98,*) 	nspl,'	nspl'
write(98,*) 	ndraws_eps,'	ndraws_eps'
write(98,*) 	curv_a,'	curv_a'
write(98,*) 	curv_B,'	curv_B'
write(98,*) 	nsav,'	nsav'
write(98,*) 	death,'	death'
write(98,*) 	retirement,'	retirement'
write(98,*) 	startwork,'	startwork'
write(98,*) 	startrec,'	startrec'
write(98,*) 	endrec,'	endrec'
write(98,*) 	cmin,'	cmin'
write(98,*) 	scale,'	scale'
write(98,*) 	sav_min,'	sav_min'
write(98,*) 	lny_min	,'lny_min'
write(98,*) 	a_min(1),'	a_min'
write(98,*) 	B_min(1),'	B_min'
write(98,*) 	bar0,'	bar0'
write(98,*) 	abar1,'	abar1'
write(98,*) 	abar2,'	abar2'
write(98,*) 	r,'	r'
write(98,*) 	r_B_bar,'	r_B_bar'
write(98,*) 	sig_ret	,'sig_ret'

close(98)

endif


endsubroutine AppspackIn

subroutine AppspackOut

use params
use filenames
implicit none

if (lenovo==1.or.x201==1) then
open(unit=2,file=path//'JLSout.1',position='rewind')
else
open(unit=2,file=pathsmallscratch//JLSout,position='rewind')
endif


write(2,*) 1
write(2,*) criterion
close(2)


endsubroutine AppspackOut
