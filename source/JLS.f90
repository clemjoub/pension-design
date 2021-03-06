program JLS

!***********************************************************************************************************
!Notes:
!
!
!
!
!
!***********************************************************************************************************
use params
use filenames
!use DFLIB
!use IMSL

!***********************************************************************************************************

implicit none

!!	UTILITAIRES
double precision::								ut,mut,co									!Generic utility calculation variables
double precision::								test									
integer::										i, temp
integer::										nreg_tog, ntog 
double precision::								V(1,1)

!! MAXU ARGUMENTS
double precision::								a											! non-retirement savings
double precision::								Bh,Bw										! retirement savings
integer::										edu_h,edu_w,grad_h,grad_w					! Completed schooling levels
integer::										cohort										! Birth cohort
double precision::								Eps_Fh, Eps_Ih, Eps_Fw, Eps_Iw				! Wage Offer shocks
double precision::								XP_Fh_comp,XP_Ih_comp,XP_Fw_comp,XP_Iw_comp	! Sector-specific experience component in wage offer equation
integer::										pastd_h,pastd_w								! Previous period labor choice
integer::	                					XP_Fh,XP_Ih,XP_Fw,XP_Iw								! Sector-specific experience

!***********************************************************************************************************

!!	Start clock
call date_and_time(values=time_array_0)
start_time = time_array_0 (5) * 3600 + time_array_0 (6) * 60 + time_array_0 (7) + 0.001 * time_array_0 (8)

!! OPTIONS:
lenovo=1
kure=0
nemeth		=0

specification="ageprof"
runsolution=1
estimation=0

runcounterf	=1
ncounterf=1
allocate(counterset(ncounterf))
counterset=(/1011/)

runsimul	=1 
rungradient	=0  
runvarcov	=0
verbose1=1
verbose2=0
checkprecision=0
checknumemax=0
quick=0

ctag=""



GRADIENTLOOP: do gradient=0,size(counterset)-1,1


counterfactual=counterset(gradient+1)


if (verbose2==1) then 
write(charac,1000) gradient
1000 format(I3)
open(unit=323,file=pathoutput//adjustl(trim(ctag))//'sigma'//adjustl(trim(charac))//'.txt',position='rewind')
endif

!!														MAIN PROGRAM

firstreg=1


!! Read in parameters
call AppspackIn
if (quick==1) then
nsav=5
ndraws_st=300           
nspl=300                
ndraws_eps=5  
endif

!if (rungradient==1) call Bump

if (runcounterf==1) call Counterfactuals

call Grids
do typ=1,ntypes
call Constants(ntypes,typ,rho,sigma,betaa,r,raw_delta,delta,raw_h_switch_act,raw_w_switch_act,raw_h_switch_sect,raw_w_switch_sect, h_switch_act, w_switch_act,h_switch_sect, w_switch_sect, raison,raison2,c_mult,alpha)
enddo


!!	Draw Shocks
idum=-1*abs(seedran1)

allocate(evec(nEps*ndraws_eps*death))
call get_eps(evec,evcv,neps,ndraws_eps,idum,death)
allocate(emat(nEps,ndraws_eps,death))
emat=reshape(evec,(/nEps,ndraws_eps,death/))
deallocate(evec)
 
!!	Draw States
call draw_states
!call get_intmat



TYPELOOP:	do typ=ntypes,1,-1
!!  Determine the number of regressors and allocate arrays
call regressors1(26,1,1,1)
if (runsolution==0) goto 666

TIMELOOP:	do age=startrec,endrec,-1
            !!  Determine regressors to be toggled-off at that age
			call get_toggle
	
			!!	Update Approximation Coefficients
			if (age.lt.startrec) theta_Vp(1,:)=theta_V(1,:)

			STATELOOP:	do state=1,ndraws_st
						
				 		a			= statemat_a		(state,age)
						Bh			= statemat_Bh		(state,age)
						Bw			= statemat_Bw		(state,age)
						edu_h		= statemat_edu_h	(state,age)
						edu_w		= statemat_edu_w	(state,age)
						XP_Fh		= statemat_XP_Fh	(state,age)
						XP_Ih		= statemat_XP_Ih	(state,age)
						XP_Fw		= statemat_XP_Fw	(state,age)
						XP_Iw		= statemat_XP_Iw	(state,age)
						pastd_h		= statemat_pastd_h	(state,age)
						pastd_w		= statemat_pastd_w	(state,age)
!						typ			= statemat_type		(state,age)
						cohort		= statemat_cohort	(state,age)

						if (edu_h==4) then
							grad_h		= 1
						else
							grad_h		= 0
						endif
						if (edu_w==4) then
							grad_w		= 1
						else
							grad_w		= 0
						endif

						XP_Fh_comp	= XP_Fh				* theta_FhFh		&
						&			+ XP_Fh	* XP_Fh		* theta_FhFh2		&
						&			+ XP_Ih				* theta_FhIh		&
						&			+ XP_Ih	* XP_Ih		* theta_FhIh2		&
						&			+ XP_Fh * grad_h	* theta_grad_Fh		&
						&			+ XP_Fh * edu_h		* theta_eduXPh

						XP_Ih_comp	= XP_Fh				* theta_IhFh		&
						&			+ XP_Fh	* XP_Fh		* theta_IhFh2		&
						&			+ XP_Ih				* theta_IhIh		&
						&			+ XP_Ih	* XP_Ih		* theta_IhIh2		&
						&			+ XP_Ih * edu_h		* theta_eduXPh

						XP_Fw_comp	= XP_Fw				* theta_FwFw		&
						&			+ XP_Fw	* XP_Fw		* theta_FwFw2		&
						&			+ XP_Iw				* theta_FwIw		&
						&			+ XP_Iw	* XP_Iw		* theta_FwIw2		&
						&			+ XP_Fw * grad_w	* theta_grad_Fw		&
						&			+ XP_Fw * edu_w		* theta_eduXPw

						XP_Iw_comp	= XP_Fw				* theta_IwFw		&
						&			+ XP_Fw	* XP_Fw		* theta_IwFw2		&
						&			+ XP_Iw				* theta_IwIw		&
						&			+ XP_Iw	* XP_Iw		* theta_IwIw2		&
						&			+ XP_Iw * edu_w		* theta_eduXPw
                        
                        !! Compute shock/decision-independent part of the continuation value
						if (age<startrec) then
							call regressors1(age+1,edu_h,edu_w,cohort)
							call matpd(1,nreg1,1,theta_Vp(1,1:nreg1),reg_mat(1:nreg1),EV1(1,1))
						endif

						SHOCKLOOP:	do iEps=1,ndraws_eps
                                    
                                    !! Wage shocks
									Eps_Fh	=	emat(1,iEps,age-startwork+1)
									Eps_Ih	=	emat(2,iEps,age-startwork+1)
									Eps_Fw	=	emat(3,iEps,age-startwork+1)
									Eps_Iw	=	emat(4,iEps,age-startwork+1)
									
									!! Choice-specific nonpecuniary rewards
									pref_shock(1)=delta(typ,1)
									pref_shock(2)=delta(typ,2)                              +emat(5,iEps,age-startwork+1)
									pref_shock(3)=delta(typ,3)                              +emat(6,iEps,age-startwork+1)+small_kids*delta_kids
									pref_shock(4)=delta(typ,4)+emat(7,iEps,age-startwork+1)
									pref_shock(5)=delta(typ,5)+emat(7,iEps,age-startwork+1) +emat(5,iEps,age-startwork+1)
									pref_shock(6)=delta(typ,6)+emat(7,iEps,age-startwork+1) +emat(6,iEps,age-startwork+1)+small_kids*delta_kids
									pref_shock(7)=delta(typ,7)+emat(8,iEps,age-startwork+1)
									pref_shock(8)=delta(typ,8)+emat(8,iEps,age-startwork+1) +emat(5,iEps,age-startwork+1)
									pref_shock(9)=delta(typ,9)+emat(8,iEps,age-startwork+1) +emat(6,iEps,age-startwork+1)+small_kids*delta_kids
									
									!! Asset return shock
									r_B=r_B_bar+emat(10,iEps,age-startwork+1)

!									theta=theta_Vp

									call maxu(a,Bh,Bw,edu_h,edu_w,cohort,XP_Fh,XP_Ih,XP_Fw,XP_Iw,&
									&XP_Fh_comp,XP_Ih_comp,XP_Fw_comp,XP_Iw_comp,Eps_Fh,Eps_Ih,Eps_Fw,Eps_Iw,pastd_h,pastd_w) 
										
									if (checkprecision==1) call checkprec(a,Bh,Bw)

									!!	Store maximization results 
									!(Vmax: value function, d: labor supply decision, savdum: saving decision,y_out: income)
									Vmax(iEps)=bestV
									do i=1,nds
									temp=(bestd==i)
									d(i,iEps)=temp*temp
									enddo
									sav_out	(iEps)=bestsav
									do i=1,nsav
									temp=(bestsav==grid_sav(i))
									savdum(i,iEps)=temp*temp
									enddo
									y_out	(iEps)=besty
									
									!! Store analytical value function to check solution error
									if (age>=retirement) then
									call analytical_V(a,Bh,Bw,age,death,betaa(typ),r,raison(typ),raison2(typ),sigma(typ),delta(typ,9),V(1,1))
									an_Vmax(iEps)=V(1,1)
									endif

						enddo SHOCKLOOP


						!!	Expected Maximized Value and Decision Probabilities
						do i=1,nds
!						d_out	  (i,typ,state,age)	=	sum(d(i,:))*1.0/ndraws_eps
						d_out	  (i,state,age) =	sum(d(i,:))*1.0/ndraws_eps
						enddo
!						avsav_out	(typ,state,age)	=	sum(sav_out)*1.0/ndraws_eps
						avsav_out	(state,age)	=	sum(sav_out)*1.0/ndraws_eps
						do i=1,nsav
						!savprob_out	(i,typ,state,age)=	sum(savdum(i,:))*1.0/ndraws_eps
						enddo
!						avy_out		(typ,state,age)	=	sum(y_out)*1.0/ndraws_eps
						avy_out		(state,age)	=	sum(y_out)*1.0/ndraws_eps
						
						!! Store analytical and numerical emax
						Emax		(state,age)	=	sum(Vmax)/ndraws_eps
						an_Emax		(state,age)	=	sum(an_Vmax)/ndraws_eps !+delta

						!!	Store all Regressors in one Matrix
						call regressors1(age,edu_h,edu_w,cohort)
						call regressors2(Bh,Bw,age,edu_h,edu_w,cohort,XP_Fh,XP_Ih,XP_Fw,XP_Iw,pastd_h,pastd_w)
						call regressors3(a,Bh,Bw,age,edu_h,edu_w,cohort,XP_Fh,XP_Ih,XP_Fw,XP_Iw,pastd_h,pastd_w)
						reg(state,:,age)=reg_mat(:)

			enddo STATELOOP	
			

			!! Check numerical error
			Num_Error						=	Emax-an_Emax

!			open(2400,file=Xmatfile,position='rewind')
!			writete(2400,*) reg(typ,:,:,age)
!			close(2400)
			
			if (age.gt.startwork) then

				!!	Regress emax over drawn states
				ntog=sum(toggle)
				nreg_tog=nreg-ntog
				Emaxspl=Emax(1:nspl,age)
				regspl=reg(1:nspl,:,age)
				call get_theta(theta_V,std_errors,Emaxspl,regspl,toggle,nspl,nreg,nreg_tog,rsq,adj_rsq)
				
				!!	Store regression coefficients and rsq
!				theta_out		(age,:)	=theta_V	(1,:)
				theta_out		(typ,age,:)	=theta_V	(1,:)
				std_errors_out	(age,:)	=std_errors	(1,:)
				rsq_out			(age)	=rsq
!				adj_rsq_out		(age)	=adj_rsq

				if (verbose1==1 .and. age>startwork) then
				print*,'tag:',tag, 'gradient', gradient,'age:',age, 'type:',typ,':',rsq
				endif
				

				!!	Output Emax, interpolated Emax and state variables
                if (verbose2==1) then
				if (age==64) then
				open(7000,file=Erroranalysisold,position='rewind')
				do i=1,ndraws_st
					call regressors1(age,statemat_edu_h(i,age),statemat_edu_w(i,age),statemat_cohort(i,age))
					call regressors2(statemat_Bh(i,age),statemat_Bw(i,age),age,statemat_edu_h(i,age),statemat_edu_w(i,age) &
					&,statemat_cohort(i,age),statemat_XP_Fh(i,age),statemat_XP_Ih(i,age),statemat_XP_Fw(i,age),&
					&statemat_XP_Iw(i,age),statemat_pastd_h(i,age),statemat_pastd_w(i,age))
					call regressors3(statemat_a(i,age),statemat_Bh(i,age),statemat_Bw(i,age),age,statemat_edu_h(i,age),statemat_edu_w(i,age) &
					&,statemat_cohort(i,age),statemat_XP_Fh(i,age),statemat_XP_Ih(i,age),statemat_XP_Fw(i,age),&
					&statemat_XP_Iw(i,age),statemat_pastd_h(i,age),statemat_pastd_w(i,age))
					
					call matpd(1,nreg,1,theta_V,reg_mat,V(1,1))

					Interp_Emax(i,age)=V(1,1)
					Interp_Error(i,age)=Emax(i,age)-V(1,1)
				enddo

				do state=1,ndraws_st
				    write(7000,'(6f30.20,10I6)')	Emax		(state,age),Interp_Emax		(state,age),Interp_Error	(state,age),&
				    &statemat_a		(state,age),statemat_Bh		(state,age),statemat_Bw		(state,age),statemat_edu_H	(state,age),&
				    &statemat_edu_W	(state,age),statemat_XP_Fh	(state,age),statemat_XP_Ih	(state,age),statemat_XP_Fw	(state,age),&
				    &statemat_XP_Iw	(state,age),statemat_pastd_h(state,age),statemat_pastd_w(state,age),statemat_cohort	(state,age),&
				    &statemat_type	(state,age)		
				enddo
				close(7000)
				endif
				endif
			endif
enddo TIMELOOP
enddo TYPELOOP

if (verbose2==1) then
!call sol_output1
!call sol_output2
!!call sol_output3
!!call sol_output4
!!call sol_output5
!call sol_output6
!call sol_output7
endif

if (runsolution==1.and.estimation==0) then
    open(8987,file=pathoutput//adjustl(trim(ctag))//'theta_out_'//adjustl(trim(specification))//'.txt', position='rewind')
    write(8987,*) theta_out
    close(8987)
endif

if (verbose2==1) then
    call date_and_time(values=time_array_1)
    finish_time = time_array_1 (5) * 3600 + time_array_1 (6) * 60+ time_array_1 (7) + 0.001 * time_array_1 (8)
    !write (6, '(8x, 1a, 1f16.6)') 'elapsed wall clock time:',finish_time - start_time    
     write (*,*) 'Simulation starts - elapsed wall clock time:',finish_time - start_time    
endif

666 if (runsimul==1) then
        call simulation
    endif
    
if (verbose2==1) then
    call date_and_time(values=time_array_1)
    finish_time = time_array_1 (5) * 3600 + time_array_1 (6) * 60+ time_array_1 (7) + 0.001 * time_array_1 (8)
    write (*,*) 'Simulation ends - elapsed wall clock time:',finish_time - start_time    
endif

!call Save_bumped_moments

call AppspackOut

if (rungradient==1.and.verbose2==1) then 
    do i=1,nmoments
        write (323,*) m(i)
    enddo
    close(323)
endif

!!	Stop the clock
call date_and_time(values=time_array_1)
finish_time = time_array_1 (5) * 3600 + time_array_1 (6) * 60+ time_array_1 (7) + 0.001 * time_array_1 (8)
write (*,'(a4,a7,a10,f13.2,a10,f4.2,a6,5I4,a26,f10.5)') 'tag=',tag,'criterion=',criterion,'min R2',minval(rsq_out),'date:',time_array_1(1),time_array_1(2),time_array_1(3),time_array_1(5),time_array_1(6),'elapsed wall clock time:',finish_time - start_time    
close(2000)

print*,'counterfactual=',counterfactual



deallocate(emat)
deallocate(grid_sav)
deallocate(Vfun)
deallocate(statemat_a)
deallocate(statemat_Bh)
deallocate(statemat_Bw)
deallocate(statemat_XP_Fh)
deallocate(statemat_XP_Fw)
deallocate(statemat_XP_Ih)
deallocate(statemat_XP_Iw)
deallocate(statemat_edu_h)
deallocate(statemat_edu_w)
deallocate(statemat_cohort)
deallocate(statemat_type)
deallocate(statemat_pastd_h)
deallocate(statemat_pastd_w)
deallocate(Emax)
deallocate(Emaxspl)
deallocate(an_Emax)
deallocate(Num_Error)
deallocate(Interp_Emax)
deallocate(Interp_Error)
deallocate(avsav_out)
deallocate(avy_out)
deallocate(d_out)
!deallocate(Emax)
!deallocate(an_Emax)
!deallocate(Num_Error)
!deallocate(Interp_Emax)
!deallocate(Interp_Error)
!deallocate(avsav_out)
!deallocate(avy_out)
!deallocate(d_out)
!deallocate(savprob_out)
deallocate(sav_out)
deallocate(y_out)
deallocate(Vmax)
deallocate(an_Vmax)
deallocate(d)
deallocate(savdum)

deallocate(reg)
deallocate(regspl)
deallocate(reg_mat)
deallocate(theta_Vp)
deallocate(theta_V)
deallocate(std_errors)
deallocate(theta_out)
deallocate(std_errors_out)

enddo GRADIENTLOOP


!if (rungradient==1)  call Diff_gradient
!if (rungradient==1)  call Varcov


endprogram JLS



!*********************************************************************************************************************************



subroutine Constants(ntypes,typ,rho,sigma,betaa,r,raw_del,del,raw_switch_act_h, raw_switch_act_w,raw_switch_sect_h, &
& raw_switch_sect_w, switch_act_h, switch_act_w,  switch_sect_h, switch_sect_w, raison,raison2,c_mult,alpha)


implicit none


integer, intent(IN)	::				ntypes							
double precision,intent(IN)::		alpha		(ntypes,3)
double precision,intent(IN)::		sigma		(ntypes)
double precision,intent(IN)::		r
double precision,intent(IN)::		rho			(ntypes)
double precision,intent(OUT)::		betaa		(ntypes)
double precision,intent(OUT)::		c_mult		(ntypes)
double precision,intent(OUT)::		raison		(ntypes)	 
double precision,intent(OUT)::		raison2		(ntypes)
double precision,intent(IN)::		raw_del		(ntypes,9)
double precision,intent(OUT)::		del			(ntypes,9)
double precision,intent(IN)::		raw_switch_sect_h,raw_switch_sect_w
double precision,intent(OUT)::		switch_sect_h,switch_sect_w
double precision,intent(IN)::		raw_switch_act_h,raw_switch_act_w
double precision,intent(OUT)::		switch_act_h,switch_act_w

!! LOCAL VARIABLES
integer::							typ
integer::							i
double precision::					utC,ut, mut,C



!	Discount Factor
betaa	(typ)	=	1.0/(1.0+rho(typ))	

!	Non-pecuniary benefits and costs
C=exp(-1.2)
call util(C,utC,mut)		
do i=1,9
call util(C+raw_del(typ,i),ut,mut)
del(typ,i) =ut-utC
enddo
call util(C+raw_switch_sect_h,ut,mut)
switch_sect_h=ut-utC
call util(C+raw_switch_sect_w,ut,mut)
switch_sect_w=ut-utC
call util(C+raw_switch_act_h,ut,mut)
switch_act_h=ut-utC
call util(C+raw_switch_act_w,ut,mut)
switch_act_w=ut-utC

!	Terminal value constants
c_mult	(typ)	=	(betaa(typ)*(1+r))**(1/sigma(typ))
raison	(typ)	=	c_mult(typ)/(1+r)
raison2	(typ)	=	betaa(typ)*c_mult(typ)**(1-sigma(typ))


endsubroutine Constants


subroutine checkprec(a,Bh,Bw)

use params
!use DFLIB
implicit none

double precision:: tempo(nd),a,Bh,Bw


!!	Check degree of precision needed to distinguish closest 2 decisions
tempo=Vfun
!call SORTQQ(LOC(tempo),nd,SRT$REAL8)
endsubroutine checkprec

subroutine analytical_sol(a,Bh,Bw,age,death,betaa,r,sigma,raison,raison2,ap,sav,c,V)

implicit none

double precision::a,Bh,Bw,betaa,r,sigma,ap,Bhp,Bwp,c,V,sav
integer::age,death
double precision::cons_rate,holdings,raison,raison2,u_mult

cons_rate=(1-raison)/(1-raison**(death-age+1))
holdings=(a+Bh+Bw)*(1+r)
c=holdings*cons_rate
ap=holdings*(1-cons_rate)
Bhp=0.0
Bwp=0.0
sav=1-cons_rate
u_mult=(1-(raison2)**(death-age+1))/(1-raison2)
V=((1-betaa)/(1-sigma))*((holdings*cons_rate)**(1-sigma))*u_mult -(1-betaa**(death-age+1))/(1-sigma)

endsubroutine analytical_sol

subroutine analytical_V(a,Bh,Bw,age,death,betaa,r,raison,raison2,sigma,delta,V2)

double precision::a,Bh,Bw,betaa,r,sigma,V,V2,cons,c_rate,c_slope,disc
integer::age,death,t
double precision::cons_rate,holdings,u_mult,raison,raison2,ut,mut,delta

V2=0.0

if (age==death+1) then
	V=0.0
else
	cons_rate=(1-raison)/(1-raison**(death-age+1))
	holdings=(a+Bh+Bw)*(1+r)
	u_mult=(1-(raison2)**(death-age+1))/(1-raison2)
	V=((1-betaa)/(1-sigma))*((holdings*cons_rate)**(1-sigma))*u_mult-(1-betaa**(death-age+1))/(1-sigma)
	
	c_slope=(betaa*(1+r))**(1/sigma)								! ratio ct/ct+1
	c_rate=(1-c_slope/(1+r))/(1-(c_slope/(1+r))**(death-age+1))		! fraction of current holdings consumed
	do t=age,death
		disc=betaa**(t-age)
		c_rate=(1-c_slope/(1+r))/(1-(c_slope/(1+r))**(death-t+1))		! fraction of current holdings consumed
		cons=holdings*c_rate										! consumption at t
		call util(cons,ut,mut)										! u(ct)
		holdings=(holdings-cons)*(1+r)								! holdings at t+1
		V2=V2+disc*(ut+delta)										
	enddo
endif

if (betaa==0.0-d0) then
V2=0.0-d0
endif


endsubroutine analytical_V
