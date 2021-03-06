subroutine simulation
use params
use filenames
implicit none

!*********************************************************************************************************************************
double precision, dimension(nEps)::		yemat
integer, dimension(nhh)::				d1,d2,d3,d4,d5,d6,d7,d8,d9
double precision::						ap_star,Bhp_star,Bwp_star,sav_star
integer::								s1,s2, idec,d_star,i
double precision::						ut, mut
double precision::						a													! non-retirement savings
double precision::						Bh,Bw												! retirement savings
double precision::						Eps_Fh, Eps_Ih, Eps_Fw, Eps_Iw						! Wage Offer shocks
integer::								edu_h,edu_w,grad_h,grad_w							! Completed schooling level
integer::								cohort												! Birth cohort
integer::	        					XP_Fh,XP_Ih,XP_Fw,XP_Iw								! Sector-specific experience
double precision::						XP_Fh_comp,XP_Ih_comp,XP_Fw_comp,XP_Iw_comp			! Sector-specific experience component in wage offer equation
integer::								pastd_h,pastd_w										! Previous period labor choice
integer::								XPmat_h(4,1),XPmat_w(4,1)		
double precision::						cons_rate	
double precision::						covgr,gr,inacgr
integer::                               g
integer::                               hmatch
double precision::                      id_draw(nhh)
!*********************************************************************************************************************************

Vfun		= 0.0
simuldum	= 1.0

a_ageeduh = 0
a_ageeduw = 0 
Bh_ageeduh = 0
Bw_ageeduw = 0
JLS_ageedu = 0
lnw_ageedu = 0
lnw_XP = 0
lnwdfce = 0
lnwdfce_age = 0
twoyrtrans = 0
trans = 0 
nb_inc = 0 
status_XP02 = 0
status_ageedu = 0
status_XP = 0
labhistory = 0
fraccov = 0
fracinac = 0
nowealth_age = 0
wealthover6_age = 0
wealthunder6_age = 0
a_agestatush = 0 
a_agestatusw = 0
i_ageeduh0406 = 0
i_ageeduw0406 = 0
i_ageeduh8801 = 0
i_ageeduw8801 = 0
i_ageedu2002 = 0
i_agesex = 0
i_lnwdfce = 0
i_lnwdfce_age = 0
i_agestatush0406 = 0
i_agestatusw0406 = 0
status_ageedu02 = 0

call get_init


!! Get emax interpolation parameters from txt file
if (runsolution==0) then
open(unit=98708,file=pathoutput//adjustl(trim(ctag))//'theta_out_'//adjustl(trim(specification))//'.txt',position='rewind')
read(fmt=*,unit=98708) theta_out
close(98708)
endif

!! Draw randomly from the younger cohorts to simulate future couples
call ran1(idum,id_draw,nhh)

HOUSEHOLDLOOP:	do h=1,nhh1
CLONESLOOP:		do i=1,nclones

if (h>nhh1) then
!draw h from the more recent cohort folios. For now resimulate the first folio
hmatch=futurecohort(1+int(241*id_draw(h)))
!move its initial year and end year forward a couple of years
first_year(h)=int((h-nhh1)/50)+2004
init_age(h)=init_age(hmatch)
wealth_draw(h,i)=wealth_draw(hmatch,i)
match_draw(h,i)=match_draw(hmatch,i)
init_H_bal(h)=init_H_bal(hmatch)
init_W_bal(h)=init_W_bal(hmatch)
init_H_Xformal(h)=init_H_Xformal(hmatch)
init_H_Xinformal(h)=init_H_Xinformal(hmatch)
init_W_Xformal(h)=init_W_Xformal(hmatch)
init_W_Xinformal(h)=init_W_Xinformal(hmatch)
init_H_yrsinactive(h)=init_H_yrsinactive(hmatch)
init_W_yrsinactive(h)=init_W_yrsinactive(hmatch)
H_edu(h)=H_edu(hmatch)
W_edu(h)=W_edu(hmatch)
birthcohort(h)=birthcohort(hmatch)
sexsampled(h)=sexsampled(hmatch)
folio(h)=folio(hmatch)*1000000000
endif

last_year(h)=min(2041,first_year(h)+85-init_age(h))

				!Reset minimum pension variables
				H_elig=0
				W_elig=0
				H_nonel=0
				W_nonel=0
				H_overMP=0
				W_overMP=0
				H_MPbenef=0.0
				W_MPbenef=0.0
				

				!! Draw shocks for the household


                allocate	(evec(nEps*1*death))
                deallocate	(emat)
                allocate	(emat(nEps,1,death)) 

				call get_eps(evec,evcv,nEps,1,idum,death)
				emat=reshape(evec,(/nEps,1,death/))
                deallocate(evec)
!				write(*,*) 'household #',h,'of',nhh
!				write(*,*) 'folio #', folio(h)
				

				!!Initial Conditions

				simage	(h,i,first_year(h)-1979)	=	init_age(h)
				age									=	init_age(h)-1
				sima	(h,i,first_year(h)-1979)	=	wealth_draw(h,i)

				if (sexsampled(h)==1) then
					simBh	(h,i,first_year(h)-1979)	=	init_H_bal(h)
					simBw	(h,i,first_year(h)-1979)	=	init_W_bal(match_draw(h,i))
					simXP_Fh(h,i,first_year(h)-1979)	=	init_H_Xformal(h)
					simXP_Ih(h,i,first_year(h)-1979)	=	init_H_Xinformal(h)
					simXP_Fw(h,i,first_year(h)-1979)	=	init_W_Xformal(match_draw(h,i))
					simXP_Iw(h,i,first_year(h)-1979)	=	init_W_Xinformal(match_draw(h,i))
					siminact_H(h,i,first_year(h)-1979)	=	init_H_yrsinactive(h)
					siminact_W(h,i,first_year(h)-1979)	=	init_W_yrsinactive(match_draw(h,i))
				elseif (sexsampled(h)==2) then
					simBh	(h,i,first_year(h)-1979)	=	init_H_bal(match_draw(h,i))
					simBw	(h,i,first_year(h)-1979)	=	init_W_bal(h)
					simXP_Fh(h,i,first_year(h)-1979)	=	init_H_Xformal(match_draw(h,i))
					simXP_Ih(h,i,first_year(h)-1979)	=	init_H_Xinformal(match_draw(h,i))
					simXP_Fw(h,i,first_year(h)-1979)	=	init_W_Xformal(h)
					simXP_Iw(h,i,first_year(h)-1979)	=	init_W_Xinformal(h)
					siminact_H(h,i,first_year(h)-1979)	=	init_H_yrsinactive(match_draw(h,i))
					siminact_W(h,i,first_year(h)-1979)	=	init_W_yrsinactive(h)
				endif

				simedu_h(h,i,first_year(h)-1979)	=	H_edu(h)
				simedu_w(h,i,first_year(h)-1979)	=	W_edu(h)
				simcohort(h,i,first_year(h)-1979)	=	birthcohort(h)

				edu_h	=	simedu_h(h,i,first_year(h)-1979)
				edu_w	=	simedu_w(h,i,first_year(h)-1979)
				cohort	=	simcohort(h,i,first_year(h)-1979)

				call draw_type(edu_h,edu_w,cohort,typ)
				
				simtype(h,i,first_year(h)-1979) =	typ

				XP_Fh_comp		=	0.0
				XP_Ih_comp		=	0.0
				XP_Fw_comp		=	0.0
				XP_Iw_comp		=	0.0


				!! Compute some functions of the schooling level for use in Emax regression

				maxedu=max(edu_h,edu_w)
				sumedu=edu_h+edu_w
				sumedu2=(sumedu==2)
				sumedu3=(sumedu==3)
				sumedu4=(sumedu==4)
				sumedu5=(sumedu==5)
				sumedu6=(sumedu==6)
				sumedu7=(sumedu==7)
				sumedu8=(sumedu==8)
				highhhedu=(sumedu>5)
				edu_h1=(edu_h==1)
				edu_h2=(edu_h==2)
				edu_h3=(edu_h==3)
				edu_h4=(edu_h==4)
				edu_w1=(edu_w==1)
				edu_w2=(edu_w==2)
				edu_w3=(edu_w==3)
				edu_w4=(edu_w==4)



				last_year(h)=first_year(h)+retirement-startwork+1
				YEARLOOP:	do year=first_year(h),last_year(h),1


!							write(*,*) 'year',year
							age	=	age+1
							agegrp=int(age/5)-2
							call get_toggle


							!! Update state variables

							a		=	sima	(h,i,year-1979)
							Bh		=	simBh	(h,i,year-1979)
							Bw		=	simBw	(h,i,year-1979)
							XP_Fh	=	simXP_Fh(h,i,year-1979)
							XP_Ih	=	simXP_Ih(h,i,year-1979)
							XP_Fw	=	simXP_Fw(h,i,year-1979)
							XP_Iw	=	simXP_Iw(h,i,year-1979)
						
							if (year>first_year(h)) then
								pastd_h	=	simd_h	(h,i,year-1-1979)
								pastd_w	=	simd_w	(h,i,year-1-1979)
							else
								pastd_h =	3
								pastd_w	=	3
							endif 

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

							
							!! Simulate the household decisions 

							if (age .ge. retirement) then

								!! Decisions after retirement

								simd	(h,i,year-1979)	    =	9
								simd_H	(h,i,year-1979)	    =	3
								simd_W	(h,i,year-1979)	    =	3
								simBh	(h,i,year-1979+1)	=	0.0
								simBw	(h,i,year-1979+1)	=	0.0
								simy	(h,i,year-1979)	    =	0.0
								simw_h	(h,i,year-1979)	    =	0.0
								simw_w	(h,i,year-1979)	    =	0.0
								simsav	(h,i,year-1979)	    =	1-c_mult(typ) !SHOULD BE 1-CONS_RATE
								cons_rate				    =	(1-raison(typ))/(1-raison(typ)**(death-age+1))
								simc	(h,i,year-1979)	    =	cons_rate*(1+r)*(a+Bh+Bw)
								sima	(h,i,year-1979+1)	=	(a+Bh+Bw)*(1+r)-simc(h,i,year-1979) !SHOULDN'T GO TO 0
								simv    (h,i,year-1979)     =   -99
								simage	(h,i,year-1979+1)	=	age+1
								simcohort(h,i,year-1979+1)	=	cohort


							else								

								
								!! Decisions before retirement


								! Update shock variables
								Eps_Fh=	emat(1,1,age-startwork+1)
								Eps_Ih=	emat(2,1,age-startwork+1)
								Eps_Fw=	emat(3,1,age-startwork+1)
								Eps_Iw=	emat(4,1,age-startwork+1)

								pref_shock(1)=delta(typ,1)
								pref_shock(2)=delta(typ,2)+emat(5,1,age-startwork+1)
								pref_shock(3)=delta(typ,3)+emat(6,1,age-startwork+1)+small_kids*delta_kids
								pref_shock(4)=delta(typ,4)+emat(7,1,age-startwork+1)
								pref_shock(5)=delta(typ,5)+emat(7,1,age-startwork+1)+emat(5,1,age-startwork+1)
								pref_shock(6)=delta(typ,6)+emat(7,1,age-startwork+1)+emat(6,1,age-startwork+1)+small_kids*delta_kids
								pref_shock(7)=delta(typ,7)+emat(8,1,age-startwork+1)
								pref_shock(8)=delta(typ,8)+emat(8,1,age-startwork+1)+emat(5,1,age-startwork+1)
								pref_shock(9)=delta(typ,9)+emat(8,1,age-startwork+1)+emat(6,1,age-startwork+1)+small_kids*delta_kids
								
								r_B=realizedret(year-1979)

						
								! Determine and store optimal decision
								if (age==death) then
									theta_Vp		=	0.0
								else 
									theta_Vp(1,:)	=	theta_out(typ,age+1,:)
								endif

								call maxu(a,Bh,Bw,edu_h,edu_w,cohort,XP_Fh,XP_Ih,XP_Fw,XP_Iw,&
								&XP_Fh_comp,XP_Ih_comp,XP_Fw_comp,XP_Iw_comp,Eps_Fh,Eps_Ih,Eps_Fw,Eps_Iw,pastd_h,pastd_w)
							
								H_formal	=(bestd==1.or.bestd==2.or.bestd==3)
								H_informal	=(bestd==4.or.bestd==5.or.bestd==6)
								H_inactive	=(bestd==7.or.bestd==8.or.bestd==9)
								W_formal	=(bestd==1.or.bestd==4.or.bestd==7)
								W_informal	=(bestd==2.or.bestd==5.or.bestd==8)
								W_inactive	=(bestd==3.or.bestd==6.or.bestd==9)
								H_formal	=H_formal	*H_formal
								H_informal	=H_informal	*H_informal
								H_inactive	=H_inactive	*H_inactive
								W_formal	=W_formal	*W_formal
								W_informal	=W_informal	*W_informal
								W_inactive	=W_inactive	*W_inactive
                                
								simd			(h,i,year-1979)	=	bestd
								simH_formal		(h,i,year-1979)	=	H_formal
								simH_informal	(h,i,year-1979)	=	H_informal
								simH_inactive	(h,i,year-1979)	=	H_inactive
								simW_formal		(h,i,year-1979)	=	W_formal
								simW_informal	(h,i,year-1979)	=	W_informal
								simW_inactive	(h,i,year-1979)	=	W_inactive
								simy			(h,i,year-1979)	=	besty
								simw_h			(h,i,year-1979)	=	bestw_h
								simw_w			(h,i,year-1979)	=	bestw_w
								simlnw_h		(h,i,year-1979)	=	bestlnw_h
								simlnw_w		(h,i,year-1979)	=	bestlnw_w
								simsav			(h,i,year-1979)	=	bestsav
								simc			(h,i,year-1979)	=	bestc
								simv			(h,i,year-1979)	=	bestv

								simd_H			(h,i,year-1979)	=	H_formal+2*H_informal+3*H_inactive
								simd_W			(h,i,year-1979)	=	W_formal+2*W_informal+3*W_inactive
								sima			(h,i,year-1979+1)	=	bestap
								simBh			(h,i,year-1979+1)	=	bestBhp
								simBw			(h,i,year-1979+1)	=	bestBwp
								simedu_H		(h,i,year-1979+1)	=	simedu_H(h,i,year-1979)
								simedu_W		(h,i,year-1979+1)	=	simedu_W(h,i,year-1979)
								simtype			(h,i,year-1979+1)	=	simtype (h,i,year-1979)
								simXP_Fh		(h,i,year-1979+1)	=	simXP_Fh(h,i,year-1979)+H_formal
								simXP_Ih		(h,i,year-1979+1)	=	simXP_Ih(h,i,year-1979)+H_informal
								simXP_Fw		(h,i,year-1979+1)	=	simXP_Fw(h,i,year-1979)+W_formal
								simXP_Iw		(h,i,year-1979+1)	=	simXP_Iw(h,i,year-1979)+W_informal
								siminact_H		(h,i,year-1979+1)	=	siminact_H(h,i,year-1979)+H_inactive
								siminact_W		(h,i,year-1979+1)	=	siminact_W(h,i,year-1979)+W_inactive
								simage			(h,i,year-1979+1)	=	age+1
								simcohort		(h,i,year-1979+1)	=	cohort
                                simtax          (h,i,year-1979)     =   besttax_paid
                                
                                simH_elig	    (h,i,year-1979+1)	=	bestH_elig
							    simW_elig	    (h,i,year-1979+1)	=	bestW_elig
							    simH_nonel	    (h,i,year-1979+1)	=	bestH_nonel
							    simW_nonel	    (h,i,year-1979+1)	=	bestW_nonel
							    simH_overMP	    (h,i,year-1979+1)	=	bestH_overMP
							    simW_overMP	    (h,i,year-1979+1)	=	bestW_overMP
							    simH_MPbenef    (h,i,year-1979+1)	=	bestH_MPbenef
							    simW_MPbenef    (h,i,year-1979+1)	=	bestW_MPbenef
							    simH_WPbenef    (h,i,year-1979+1)	=	bestH_WPbenef
							    simW_WPbenef    (h,i,year-1979+1)	=	bestW_WPbenef
							    simH_APS	    (h,i,year-1979+1)	=	bestAPS_h
							    simW_APS	    (h,i,year-1979+1)	=	bestAPS_w

                                
   		
						        
                          

								!! Add contribution of current simulation to each moment

								! Determine experience group of household
								XPFhgroup=int(simXP_Fh(h,i,year-1979)/5)+1
								XPIhgroup=int(simXP_Ih(h,i,year-1979)/5)+1
								XPFwgroup=int(simXP_Fw(h,i,year-1979)/5)+1
								XPIwgroup=int(simXP_Iw(h,i,year-1979)/5)+1

								if ((year==2004.or.year==2006) .and. (agegrp.lt.8) .and. (agegrp.gt.1)) then

									!! The prop of hh choosing each of the 9 joint occup, by age and schooling level 
									JLS_ageedu		(agegrp,edu_h,edu_w,1)	=	JLS_ageedu		(agegrp,edu_h,edu_w,1)	+ H_formal*W_formal
									JLS_ageedu		(agegrp,edu_h,edu_w,2)	=	JLS_ageedu		(agegrp,edu_h,edu_w,2)	+ H_formal*W_informal
									JLS_ageedu		(agegrp,edu_h,edu_w,3)	=	JLS_ageedu		(agegrp,edu_h,edu_w,3)	+ H_formal*W_inactive
									JLS_ageedu		(agegrp,edu_h,edu_w,4)	=	JLS_ageedu		(agegrp,edu_h,edu_w,4)	+ H_informal*W_formal
									JLS_ageedu		(agegrp,edu_h,edu_w,5)	=	JLS_ageedu		(agegrp,edu_h,edu_w,5)	+ H_informal*W_informal
									JLS_ageedu		(agegrp,edu_h,edu_w,6)	=	JLS_ageedu		(agegrp,edu_h,edu_w,6)	+ H_informal*W_inactive
									JLS_ageedu		(agegrp,edu_h,edu_w,7)	=	JLS_ageedu		(agegrp,edu_h,edu_w,7)	+ H_inactive*W_formal
									JLS_ageedu		(agegrp,edu_h,edu_w,8)	=	JLS_ageedu		(agegrp,edu_h,edu_w,8)	+ H_inactive*W_informal
									JLS_ageedu		(agegrp,edu_h,edu_w,9)	=	JLS_ageedu		(agegrp,edu_h,edu_w,9)	+ H_inactive*W_inactive

									!! The mean private savings by age and schooling level
									i_ageeduh0406	(agegrp,edu_h)			=	i_ageeduh0406	(agegrp,edu_h)			+1
									i_ageeduw0406	(agegrp,edu_w)			=	i_ageeduw0406	(agegrp,edu_w)			+1
									a_ageeduh		(agegrp,edu_h,i_ageeduh0406	(agegrp,edu_h)) = sima(h,i,year-1979)
									a_ageeduw		(agegrp,edu_w,i_ageeduw0406	(agegrp,edu_w)) = sima(h,i,year-1979)
									
									!! Distribution of wealth by age
									if (a<0.001)					nowealth_age	(agegrp)=Nowealth_age		(agegrp)+1
									if (a.ge.0.001 .and. a.lt.6)	wealthunder6_age(agegrp)=wealthunder6_age	(agegrp)+1
									if (a .ge.6)					wealthover6_age	(agegrp)=wealthover6_age	(agegrp)+1


									!! The mean private savings by age and current work status
									if (simd_H(h,i,year-1979)<3) then
									i_agestatush0406(agegrp,simd_H(h,i,year-1979))=i_agestatush0406(agegrp,simd_H(h,i,year-1979))+1
									a_agestatush	(agegrp,simd_H(h,i,year-1979), i_agestatush0406(agegrp,simd_H(h,i,year-1979))) = &
									& sima(h,i,year-1979)
									endif
									if (simd_W(h,i,year-1979)<3) then									
									i_agestatusw0406(agegrp,simd_W(h,i,year-1979))=i_agestatusw0406(agegrp,simd_W(h,i,year-1979))+1
									a_agestatusw	(agegrp,simd_W(h,i,year-1979), i_agestatusw0406(agegrp,simd_W(h,i,year-1979))) = &
									& sima(h,i,year-1979)
									endif
								endif
								

								if ((year>1980.and.year<2002) .and. (agegrp.lt.8).and. (agegrp.gt.1)) then
									!! The mean pension savings by age and schooling level
									if (sexsampled(h)==1) then
										i_ageeduh8801(agegrp,edu_h,cohort)=i_ageeduh8801(agegrp,edu_h,cohort)+1
										Bh_ageeduh	 (agegrp,edu_h, i_ageeduh8801(agegrp,edu_h,cohort),cohort) = simBh(h,i,year-1979)
									elseif (sexsampled(h)==2) then
										i_ageeduw8801(agegrp,edu_w,cohort)=i_ageeduw8801(agegrp,edu_w,cohort)+1
										Bw_ageeduw	 (agegrp,edu_w, i_ageeduw8801(agegrp,edu_w,cohort),cohort) = simBw(h,i,year-1979)
									endif
								endif
								

	
								!! Mean logwage by sector, age and education (husbands)
								!! Fraction of husbands in each experience group by sector and age
								!! Fraction of husbands in each employment status by age and education
								!! Fraction of husbands in each employment status by sector-specific experience
								if (((	year	.ge.2002	.and.	year <	2007		.and. sexsampled(h)==1	) &
							&	.or.	year	==	2004	.or.	year ==	2006								) &
							&	.and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then 
										
										status_ageedu02		(agegrp,edu_h,simd_H(h,i,year-1979),1) =	&
									&	  status_ageedu02	(agegrp,edu_h,simd_H(h,i,year-1979),1) + 1
										
										lnw_ageedu			(agegrp,edu_h,simd_H(h,i,year-1979),1,	&
									&	  status_ageedu02	(agegrp,edu_h,simd_H(h,i,year-1979),1)) = bestlnw_h
										
								endif
								
								if (year .ge. 2002 .and.	year <	2007 .and.  sexsampled(h)==1 .and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then 

										status_XP02			(XPFhgroup,simd_H(h,i,year-1979),1,1) = &
									&	  status_XP02		(XPFhgroup,simd_H(h,i,year-1979),1,1) + 1
										status_XP02			(XPIhgroup,simd_H(h,i,year-1979),2,1) = &
									&	  status_XP02		(XPIhgroup,simd_H(h,i,year-1979),2,1) + 1	
										
										lnw_XP				(XPFhgroup,simd_H(h,i,year-1979),1,1,		 &
									&	  status_XP02		(XPFhgroup,simd_H(h,i,year-1979),1,1)) = bestlnw_h
										lnw_XP				(XPIhgroup,simd_H(h,i,year-1979),2,1,		 &
									&	  status_XP02		(XPIhgroup,simd_H(h,i,year-1979),2,1)) = bestlnw_h
										
								endif

								if (((year <	2007		.and. sexsampled(h)==1	) &
							&	.or.	year	==	2004	.or.	year ==	2006								) &
							&	.and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then 
										
										status_ageedu		(agegrp,edu_h,simd_H(h,i,year-1979),1,cohort) =	&
									&	  status_ageedu		(agegrp,edu_h,simd_H(h,i,year-1979),1,cohort) + 1
								endif
								
								if (year <	2007 .and.  sexsampled(h)==1 .and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then 

										status_XP			(XPFhgroup,simd_H(h,i,year-1979),1,1) = &
									&	  status_XP			(XPFhgroup,simd_H(h,i,year-1979),1,1) + 1
										status_XP			(XPIhgroup,simd_H(h,i,year-1979),2,1) = &
									&	  status_XP			(XPIhgroup,simd_H(h,i,year-1979),2,1) + 1											
								endif

								!! Mean logwage by sector,age and education (wives)
								!! Fraction of wives in each employment status by age and education
								!! Fraction of wives in each employment status by age and education
								!! Fraction of wives in each employment status by sector-specific experience
								if (((	year	.ge. 2002	.and.	year <	2007		.and. sexsampled(h)==2	) &
							&	.or.	year	==	2004	.or.	year ==	2006								) &
							&	.and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then	
										
										status_ageedu02	(agegrp,edu_w,simd_W(h,i,year-1979),2) =	&
									&	status_ageedu02	(agegrp,edu_w,simd_W(h,i,year-1979),2) + 1
										
										lnw_ageedu		(agegrp,edu_w,simd_W(h,i,year-1979),2,	&
									&	status_ageedu02	(agegrp,edu_w,simd_W(h,i,year-1979),2)) = bestlnw_w	
								endif

								if (year	.ge.2002	.and.	year <	2007	.and. sexsampled(h)==2	.and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then 
									
										status_XP02		(XPFwgroup,simd_W(h,i,year-1979),1,2) = &
									&	status_XP02		(XPFwgroup,simd_W(h,i,year-1979),1,2) + 1
										status_XP02		(XPIwgroup,simd_W(h,i,year-1979),2,2) = &
									&	status_XP02		(XPIwgroup,simd_W(h,i,year-1979),2,2) + 1
										
										lnw_XP			(XPFwgroup,simd_W(h,i,year-1979),1,2,		 &
									&	status_XP02		(XPFwgroup,simd_W(h,i,year-1979),1,2)) = bestlnw_w
										lnw_XP			(XPIwgroup,simd_W(h,i,year-1979),2,2,		 &
									&	status_XP02		(XPIwgroup,simd_W(h,i,year-1979),2,2)) = bestlnw_w

								endif

								if (((year <	2007		.and. sexsampled(h)==2	) &
							&	.or.	year	==	2004	.or.	year ==	2006								) &
							&	.and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then	
										
										status_ageedu	(agegrp,edu_w,simd_W(h,i,year-1979),2,cohort) =	&
									&	status_ageedu	(agegrp,edu_w,simd_W(h,i,year-1979),2,cohort) + 1
								endif

								if (year <	2007	.and. sexsampled(h)==2	.and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then 
									
										status_XP		(XPFwgroup,simd_W(h,i,year-1979),1,2) = &
									&	status_XP		(XPFwgroup,simd_W(h,i,year-1979),1,2) + 1
										status_XP		(XPIwgroup,simd_W(h,i,year-1979),2,2) = &
									&	status_XP		(XPIwgroup,simd_W(h,i,year-1979),2,2) + 1
								endif


								if (year.gt.2002.and.year<2007.and.year>first_year(h).and.agegrp.lt.8.and. (agegrp.gt.1)) then
									if (sexsampled(h)==1.and.simd_H(h,i,year-1979)<3.and.simd_H(h,i,year-1-1979)<3 ) then
									
										!! Mean logwage difference by current and lagged sector (husbands)
											i_lnwdfce(simd_H(h,i,year-1979),simd_H(h,i,year-1-1979),1)	= &
										&	i_lnwdfce(simd_H(h,i,year-1979),simd_H(h,i,year-1-1979),1)	+ 1
											  lnwdfce(simd_H(h,i,year-1979),simd_H(h,i,year-1-1979),1)	= &
										&	  lnwdfce(simd_H(h,i,year-1979),simd_H(h,i,year-1-1979),1)	+ &
										&	  simlnw_h(h,i,year-1979)-simlnw_h(h,i,year-1-1979)
										!! Mean logwage difference age and  current sector (husbands)
											i_lnwdfce_age(simd_H(h,i,year-1979),agegrp,1)	= &
										&	i_lnwdfce_age(simd_H(h,i,year-1979),agegrp,1)	+ 1
											  lnwdfce_age(simd_H(h,i,year-1979),agegrp,1)	= &
										&	  lnwdfce_age(simd_H(h,i,year-1979),agegrp,1)	+ &
										&	  simlnw_h(h,i,year-1979)-simlnw_h(h,i,year-1-1979)
									
									endif

									if (sexsampled(h)==2.and.simd_W(h,i,year-1979)<3.and.simd_W(h,i,year-1-1979)<3 ) then

										!! Mean logwage difference by current and lagged sector (wives)
											i_lnwdfce(simd_W(h,i,year-1979),simd_W(h,i,year-1-1979),2)	= &
										&	i_lnwdfce(simd_W(h,i,year-1979),simd_W(h,i,year-1-1979),2)	+ 1
											  lnwdfce(simd_W(h,i,year-1979),simd_W(h,i,year-1-1979),2)	= &
										&	  lnwdfce(simd_W(h,i,year-1979),simd_W(h,i,year-1-1979),2)	+ &
										&	  simlnw_w(h,i,year-1979)-simlnw_w(h,i,year-1-1979)
										write(431,*) h,i,year,lnwdfce(simd_W(h,i,year-1979),simd_W(h,i,year-1-1979),2)
										!! Mean logwage difference by age and current sector (wives)
											i_lnwdfce_age(simd_W(h,i,year-1979),agegrp,2)	= &
										&	i_lnwdfce_age(simd_W(h,i,year-1979),agegrp,2)	+ 1
											  lnwdfce_age(simd_W(h,i,year-1979),agegrp,2)	= &
										&	  lnwdfce_age(simd_W(h,i,year-1979),agegrp,2)	+ &
										&	  simlnw_w(h,i,year-1979)-simlnw_w(h,i,year-1-1979)
										write(432,*) h,i,year,lnwdfce(simd_W(h,i,year-1979),simd_W(h,i,year-1-1979),2)
									endif
								endif


								if (year==2006.and.year>first_year(h)+1.and.(agegrp .lt. 8) .and. (agegrp .gt.1)) then
									!! Two period joint transitions between the 9 alternatives 
									twoyrtrans(simd(h,i,year-1979),simd(h,i,year-2-1979)) = &
								&	twoyrtrans(simd(h,i,year-1979),simd(h,i,year-2-1979)) + 1
								endif
									
									!! 1-period individual transitions between the 3 employment status by age and sex
								if (year>first_year(h).and.year<2007.and.(agegrp .lt. 8) .and. (agegrp .gt.1)) then
								if (sexsampled(h)==1) then
									trans(agegrp,1,simd_H(h,i,year-1979),simd_H(h,i,year-1-1979))= &
								&	trans(agegrp,1,simd_H(h,i,year-1979),simd_H(h,i,year-1-1979)) + 1
								endif
								if (sexsampled(h)==2) then
									trans(agegrp,2,simd_W(h,i,year-1979),simd_W(h,i,year-1-1979))= &
								&	trans(agegrp,2,simd_w(h,i,year-1979),simd_W(h,i,year-1-1979)) + 1
								endif
								endif



								if (	year	.ge.2002	.and.	year <	2007		.and. sexsampled(h)==1	.and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then
										i_agesex(agegrp,1) =i_agesex(agegrp,1) + 1
										labhistory		(agegrp,1,1,i_agesex(agegrp,1)) = simXP_Fh(h,i,year-1979)
										labhistory		(agegrp,2,1,i_agesex(agegrp,1)) = simXP_Ih(h,i,year-1979)
										labhistory		(agegrp,3,1,i_agesex(agegrp,1)) = siminact_H(h,i,year-1979)										
										if (sum( labhistory(agegrp,1:2,1,i_agesex(agegrp,1)) ) >0) then
											covgr  = int( 4*labhistory( agegrp,1,1,i_agesex(agegrp,1) )/sum( labhistory(agegrp,1:2,1,i_agesex(agegrp,1)) ) )+1
											do gr=1,5												
												if (gr==covgr) then
												fraccov  (agegrp,1,gr)= fraccov  (agegrp,1,gr) + 1
												endif
											enddo	
										endif
										if (sum( labhistory(agegrp,:,1,i_agesex(agegrp,1)) ) >0) then
											inacgr = int( 4*labhistory( agegrp,3,1,i_agesex(agegrp,1) )/sum(labhistory( agegrp,:,1,i_agesex(agegrp,1))))+1
											do gr=1,5
												if (gr==inacgr) then
												fracinac (agegrp,1,gr)= fracinac (agegrp,1,gr) + 1
												endif
											enddo
										endif
								endif

								if (	year	.ge.2002	.and.	year <	2007		.and. sexsampled(h)==2 .and.	(agegrp .lt. 8) .and. (agegrp .gt.1)) then
										i_agesex(agegrp,2) =i_agesex(agegrp,2) + 1
										labhistory		(agegrp,1,2,i_agesex(agegrp,2)) = simXP_Fw(h,i,year-1979)
										labhistory		(agegrp,2,2,i_agesex(agegrp,2)) = simXP_Iw(h,i,year-1979)
										labhistory		(agegrp,3,2,i_agesex(agegrp,2)) = siminact_W(h,i,year-1979)										
										if (sum( labhistory(agegrp,1:2,2,i_agesex(agegrp,2)) ) >0) then
											covgr  = int( 4*labhistory( agegrp,1,2,i_agesex(agegrp,2) )/sum( labhistory(agegrp,1:2,2,i_agesex(agegrp,2))))+1
											do gr=1,5												
												if (gr==covgr) then
												fraccov  (agegrp,2,gr)= fraccov  (agegrp,2,gr) + 1
												endif
											enddo	
										endif
										if (sum( labhistory(agegrp,:,2,i_agesex(agegrp,2)) ) >0) then
											inacgr = int( 4*labhistory( agegrp,3,2,i_agesex(agegrp,2) )/sum(labhistory( agegrp,:,2,i_agesex(agegrp,2))))+1
											do gr=1,5
												if (gr==inacgr) then
												fracinac (agegrp,2,gr)= fracinac (agegrp,2,gr) + 1
												endif
											enddo
										endif
							    endif

								!call momentdata

							endif
				enddo YEARLOOP
enddo CLONESLOOP
enddo HOUSEHOLDLOOP

!!	Stop the clock
if (lenovo==1) then
call date_and_time(values=time_array_1)
finish_time = time_array_1 (5) * 3600 + time_array_1 (6) * 60+ time_array_1 (7) + 0.001 * time_array_1 (8)
write (6, '(8x, 1a, 1f16.6)') 'elapsed wall clock time:',finish_time - start_time    
write (*,*) 'Simulation output starts: elapsed wall clock time:',finish_time - start_time    
endif

if (verbose1==1) call  sim_output

if (lenovo==1) then
call date_and_time(values=time_array_1)
finish_time = time_array_1 (5) * 3600 + time_array_1 (6) * 60+ time_array_1 (7) + 0.001 * time_array_1 (8)
write (6, '(8x, 1a, 1f16.6)') 'elapsed wall clock time:',finish_time - start_time    
write (*,*) 'Simulation output ends: elapsed wall clock time:',finish_time - start_time    
close (431)
close (432)
endif

call MSM

simuldum	= 0.0

endsubroutine simulation
