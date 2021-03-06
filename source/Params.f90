module params
implicit none

integer::						simuldum


!! OPTIONS
integer::                       lenovo,x201,kure,nemeth                                                                ! machine on which code is running 
integer::                       runsolution,runcounterf,rungradient,estimation, runsimul,runvarcov, verbose1,verbose2, checkprecision, checknumemax    ! control which part of the code to run 
integer::                       quick                                                                                   !runs the code with few states and decisions for speed
character*20::                   specification,ctag                                                                           !suffix that identifies current specification

!! Standard errors computation
integer::						gradient	
character*80                    charac
double precision::				firstdiff_mat(953,118)
double precision::				gradient_mat(953,59)
double precision::				sigma1_inv(59,59)
double precision::				sigma1(59,59)
double precision,parameter::	hdiff=0.01
double precision::				h_mat(59)
double precision::              bump
double precision, allocatable:: 	estparms(:,:),parms(:,:),scale1(:,:),upper(:,:),lower(:,:)
integer,allocatable :: 			inest(:,:)
character(20),allocatable::		nameparams(:,:)

!! Gridsizes
integer,parameter::				ntypes			=	3							! Number of unbobserved types
integer,parameter::				nclones			=	10
integer,parameter::				na				=   10000						! Size of the private savings grid
integer,parameter::				nB				=   10000						! Size of the pension savings grid	
integer,parameter::				ns				=	na*nB						! Number of predetermined states
integer,parameter::				nhh1 			=   2097						! Number of households in sample
integer,parameter::             nhh             =   3846                         ! Total number of simulated households in counterfactuals
integer,parameter::				nEps			=   10							! Number of shocks
integer,parameter::				nds				=	9							! Number of sector decisions
integer,parameter::				nagegrp			=	8							! Number of agegroups
integer,parameter::				nedu			=	4							! Number of education groups
integer::						nd												! Number of decisions
integer,parameter::				ncohort			=	5							! Number of cohorts
integer::						nmoments
integer,parameter::				nXPgroups		=	7

integer          ::             totnumparms, numestparms
integer          ::             maxparams       =   400
!! Counterfactuals::
double precision				counterfactual									! Toggle to signal counterfactual
real,allocatable::              counterset(:)
integer::                       ncounterf
!! Mandatory Contributions
double precision::				tao												! Mandatory contribution rate		
double precision::				contr_h,contr_w									! Contributions to the pension accounts

!Minimum Pension
integer::						MPyrs
double precision::				MP				
double precision::				WP			
double precision::				PBS
double precision::				PMAS
double precision::				p60
double precision::				APS_h
double precision::				APS_w

!! Tope imponible::
double precision::				tope			= 12.24
!double precision::				tope			= 0.0

double precision::				retbal_h,retbal_w

!! Commissions
double precision::				fixedcom
double precision::				fixedbalcom(ncohort,100)
double precision::				varcom
double precision::				varbalcomrt(ncohort,100)
double precision::				varcomrt
double precision::				varcom_h, varcom_w


!! Preferences
double precision::              probamyop       (ntypes)                        ! Type-specific probability of behaving myopically
double precision::				alpha			(ntypes,3)						! Coefficients of Wage Offer Age Polynomial
double precision::				raw_delta		(ntypes,9)						! Sector-specific taste parameter (in consumption units)
double precision::              leis_comp                                       ! Complementarity in leisure btw wife and husband
double precision::				delta			(ntypes,9)						! Sector-specific taste parameter (in utility units)
double precision::				sigma			(ntypes)						! Discount factor
double precision::				rho				(ntypes)						! Discount rate
double precision::				betaa			(ntypes)
double precision::				cmin											! Minimum Consumption Level
double precision::				scale											! Computational Penalty
double precision::				s_cost											! Sum of switching costs for the household
double precision::				raw_h_switch_sect,raw_w_switch_sect						! Cost of switching sectors (in consumption units)
double precision::				raw_h_switch_act,raw_w_switch_act						! Cost of switching sectors (in consumption units)
double precision::				h_switch_sect,w_switch_sect								! Cost of switching sectors	(in utility units)
double precision::				h_switch_act,w_switch_act								! Cost of switching sectors	(in utility units)
double precision::				EV1(1,1),EV2(1,1),EV3(1,1),EV(1,1)								! Continuation Value
double precision::				sig_pref
double precision::				sig_pref_h
double precision::				sig_pref_w
double precision::				pref_shock		(9)
double precision::				delta_kids								
double precision::				small_kids							
double precision::              leisut_h        (ntypes)
double precision::              leisut_w        (ntypes)
double precision::              leiscomp        (ntypes)
double precision::              NPB_Fh,NPB_Fw
integer::                       sameshocks,notax                                      ! Force earnings shocks to be the same across sectors

!! Type distribution
integer::						typ												! Type index
double precision::				lambdaedu_h		(ntypes)						! Education coefficient in type distribution
double precision::				lambdaedu_w		(ntypes)						! Education coefficient in type distribution
double precision::				lambdacohort	(ntypes)						! Cohort coefficient in type distribution
double precision::				alphatyp		(ntypes)						! Constant
!! Lifecycle
integer::						death											! Age of death (death occurs at the end of that age)
integer::						retirement										! Legal Retirement Age
integer::						startwork										! Model starting age
integer::						startrec										! First age for backward recursion
integer::						endrec											! Last age for backward recursion					
integer::						age												! Age
integer::					 	nret											! Number of retirement Periods
integer::						nwork											! Number of Working Periods
			
!! Wage offers
double precision::				w,lnw_h,lnw_w,w_h,w_w							! Household, husband, wife wage
double precision::				y												! Household disposable income
!double precision::				dispw_h,dispw_w									! Household, husband, wife wage
integer::						iEps											! Joint Wage Offer Shock counter
double precision, allocatable ::emat			(:,:,:)							! Shock draws matrix
double precision, allocatable ::evec			(:)								! Shock draws vector
double precision::				evcv			(nEps,nEps)						! Wage shocks varcovar matrix
double precision::				age_comp		(ntypes,100)					! Wage offer Age polynomial 
double precision::				lny_min											! Minimum log earnings (welfare)
double precision::				SR_I											! Sector-specific skill rental price	
double precision::				SR_F											! Sector-specific skill rental price
double precision::				SR_Fh		    (ntypes)						! Sector-specific skill rental price
double precision::				SR_Fw			(ntypes)						! Sector-specific skill rental price
double precision::				SR_Ih			(ntypes)						! Sector-specific skill rental price
double precision::				SR_Iw			(ntypes)						! Sector-specific skill rental price
double precision::				g_gap											! Gender wage gap
double precision::				theta_FhFh										! Sector-specific experience coefficients
double precision::				theta_FhIh										! Sector-specific experience coefficients
double precision::				theta_IhIh	 									! Sector-specific experience coefficients
double precision::				theta_IhFh										! Sector-specific experience coefficients
double precision::				theta_FhFh2										! Sector-specific experience coefficients
double precision::				theta_FhIh2										! Sector-specific experience coefficients
double precision::				theta_IhFh2	 									! Sector-specific experience coefficients
double precision::				theta_IhIh2										! Sector-specific experience coefficients
double precision::				theta_FwFw										! Sector-specific experience coefficients
double precision::				theta_FwIw										! Sector-specific experience coefficients
double precision::				theta_IwIw										! Sector-specific experience coefficients
double precision::				theta_IwFw										! Sector-specific experience coefficients
double precision::				theta_FwFw2										! Sector-specific experience coefficients
double precision::				theta_FwIw2										! Sector-specific experience coefficients
double precision::				theta_IwFw2										! Sector-specific experience coefficients
double precision::				theta_IwIw2										! Sector-specific experience coefficients
double precision::	            XPtransfer
double precision::				theta_eduFh 									! Sector-specific returns to education
double precision::				theta_eduIh 									! Sector-specific returns to education
double precision::				theta_eduFw 									! Sector-specific returns to education
double precision::				theta_eduIw 									! Sector-specific returns to education
double precision::				sig_Fh											! Sd of wage offer shocks
double precision::				sig_Ih											! Sd of wage offer shocks
double precision::				sig_Fw											! Sd of wage offer shocks
double precision::				sig_Iw											! Sd of wage offer shocks
double precision::				theta_grad_F									! Additional returns to experience for college graduates
double precision::				theta_grad_Fh									! Additional returns to experience for college graduates
double precision::				theta_grad_Fw									! Additional returns to experience for college graduates
double precision::				theta_cohort									! Cohort effect
double precision::				theta_cohort_F									! Cohort effect
double precision::				theta_cohort_I									! Cohort effect
double precision::				theta_eduXPh
double precision::				theta_eduXPw
double precision::				gamma(2)
double precision::				gammaXP(2)
double precision::				gammaedu(2)
double precision::				gammaage(2)
double precision::				gammacov(2)
integer::						offer(2)


!! Saving decision
double precision::				c												! Consumption
double precision::				holdings										! Current income+assets before saving and consumption
double precision::				sav												! Saving rate
integer::						isav											! Saving rate counter
double precision, allocatable::	grid_sav(:)										! Saving rates grid
double precision::				sav_min											! Minimum saving rate
integer::						nsav											! Number of Points in Saving rates grid

!! Labor decision
integer::						ds												! Choice of sector
integer::						H_formal, H_informal, H_inactive				! Sector choice dummies
integer::						W_formal, W_informal, W_inactive				! Sector choice dummies

!! Asset holdings
double precision::				ap												! Next period savings
double precision::				Bhp,Bwp											! Next period pension balances
double precision::				r												! Risk-free rate
double precision::				r_B_bar											! Expected Return on the pension acccount
double precision::				r_B												! Return on the pension acccount
double precision::				sig_ret
double precision::				realizedret(100)
integer::						ia												! Savings counter
integer::						iB,iBh,iBw,iBp									! Pension balance counters
double precision::				grid_a(100,na)									! Savings Grid
double precision::				grid_B(100,nB)									! Pension Balance Grid
double precision::				curv_a											! Curvature of the Savings Grid
double precision::				curv_B											! Curvature of the Pension Balance Grid
double precision::				a_min0											! Minimum private savings in asset grid at 25
double precision::				B_min0											! Minimum private savings in asset grid at 25
double precision::				a_min(100)										! Minimum private savings in asset grid
double precision::				B_min(100)										! Minimum pension balance in asset grid
double precision::				a_max(100)										! Maximum asset holdings
double precision::				B_max(100)										! Maximum pension balance
double precision::				Bh_max(100)										! Maximum pension balance
double precision::				Bw_max(100)										! Maximum pension balance
double precision::				wealth_min(100)									! Lowest holdings among state point draws (to prevent extrapolation)
double precision::				wealth_max(100)									! Highest holdings among state point draws (to prevent extrapolation)
double precision::              earlycut(100)

!! Maximization loop
double precision, allocatable::	Vfun			(:)								! Decision-specific value function
double precision, allocatable::	sav_out			(:)								! Stores saving choice for each shock draw at current state
double precision, allocatable::	avsav_out		(:,:)							! Average Saving Decisions
double precision, allocatable::	y_out			(:)								! Stores household income for each shock draw at current state
double precision, allocatable::	avy_out			(:,:)							! Average Disposable Income 
double precision, allocatable::	d				(:,:)							! Stores sector decision for each shock draw at current state
double precision, allocatable::	d_out			(:,:,:)							! Sector Choice Probabilities
double precision, allocatable::	Vmax(:)											! Store the highest value accross decisions for each shock draw
double precision, allocatable::	an_Vmax(:)										! Analytical Vmax (when available)
double precision, allocatable::	savdum(:,:),savprob_out(:,:,:,:)				! Saving decision probabilities
double precision::				bestV											! Maximum of the Value Function (over decisions)
double precision::				besty,bestw_h,bestw_w,bestlnw_h,bestlnw_w		! Income variables at best solution
double precision::				bestsav											! Saving decision at best solution
double precision::				bestap,bestBhp,bestBwp							! Asset variables at best solution
double precision::				bestc											! Consumption at best solution
integer::						bestd											! Best decision
double precision::              besttax_paid                                    ! Taxes paid at best decision

!! State draws
integer, parameter::			startdraw		=	16
!integer, parameter::			startdraw		=	25
double precision, allocatable::	statemat_a		(:,:)							! private savings state draws
double precision, allocatable::	statemat_Bh		(:,:)							! Husband pension state draws
double precision, allocatable::	statemat_Bw		(:,:)							! Wife's pension state draws
integer, allocatable::			statemat_XP_Fh	(:,:)							! Husband formal experience state draws
integer, allocatable::			statemat_XP_Fw	(:,:)							! Wife's formal experience state draws
integer, allocatable::			statemat_XP_Ih	(:,:)							! Husband informal experience state draws
integer, allocatable::			statemat_XP_Iw	(:,:)							! Wife's informal experience state draws
integer, allocatable::			statemat_edu_h	(:,:)							! Husband's education draws
integer, allocatable::			statemat_edu_w	(:,:)							! Wife's education draws
integer, allocatable::			statemat_cohort	(:,:)							! Wife's education draws
integer, allocatable::			statemat_pastd_h(:,:)							! Husband's previous period status draw
integer, allocatable::			statemat_pastd_w(:,:)							! Wife's previous period status draw
integer, allocatable::			statemat_type	(:,:)							! Wife's education draws
integer::					    XP_Fh_max(100)
integer::					    XP_Fh_min(100)
integer::					    XP_Ih_max(100)
integer::					    XP_Ih_min(100)
integer::					    XP_Fw_max(100)
integer::					    XP_Fw_min(100)
integer::					    XP_Iw_max(100)
integer::					    XP_Iw_min(100)
integer::					    XP_hh_max(100)


!! Emax interpolation
integer::						ndraws_st										! Number predetermined states draws used in Emax calculation
integer::						state											! Counter for state draws
integer::						nspl,noutspl									! Number of state draws used for regression / errorchecking
integer::						ndraws_eps										! Number of shock draws used in the Emax integration
integer::						nreg,nreg1,nreg2								! Number of regressors including interactions
integer::						nst_reg											! Number of regressors excluding interactions

double precision::				bar0											! Poverty threshold
double precision::				abar1											! Poverty threshold
double precision::				abar2											! Poverty threshold
double precision::				Bbar1											! Poverty threshold
double precision::				Bbar2											! Poverty threshold

double precision, allocatable::	Emax			(:,:)							! Stores Emax Values	
double precision, allocatable::	Emaxspl			(:)							! Stores Emax Values	
double precision, allocatable::	Interp_Emax		(:,:)							! Stores Interpolated Emax Values
double precision, allocatable::	Interp_Error	(:,:)							! Stores Emax Interpolation error
double precision, allocatable::	an_Emax			(:,:)							! Analytical Emax (when available)			
double precision, allocatable::	Num_Error		(:,:)							! Difference between numerical and Analytical Emax (when available)			

!double precision, allocatable::	Emax			(:,:,:)							! Stores Emax Values	
!double precision, allocatable::	Interp_Emax		(:,:,:)							! Stores Interpolated Emax Values
!double precision, allocatable::	Interp_Error	(:,:,:)							! Stores Emax Interpolation error
!double precision, allocatable::	an_Emax			(:,:,:)							! Analytical Emax (when available)			
!double precision, allocatable::	Num_Error		(:,:,:)							! Difference between numerical and Analytical Emax (when available)			

double precision,allocatable::	reg_mat				(:)							! Next period's regressors
!double precision,allocatable::	newreg				(:)							! DONT NEED THIS
double precision,allocatable::	reg					(:,:,:)						! Regressors evaluated at current state
double precision,allocatable::	regspl				(:,:)						! Regressors evaluated at current state
integer::						toggle				(100)						! Vector with dummies for regressors to be excluded

integer:: sumedu,sumedu2,sumedu3,sumedu4,sumedu5,sumedu6,sumedu7,sumedu8		! Dummies for the sum of the education attainments
integer::						maxedu											! Maximum education attainment in household
integer::						highhhedu										! Dummy for maximum education attainment> 3
integer:: edu_h1,edu_w1,edu_h2,edu_w2,edu_h3,edu_w3,edu_h4,edu_w4				! Dummies for each spouse's education attainment
integer:: cohort1,cohort2,cohort3,cohort4,cohort5
double precision,allocatable::	theta_V				(:,:)						! Emax Regression Coefficients for the current period
double precision,allocatable::	theta_Vp			(:,:)						! Emax Regression Coefficients for the next period
!double precision,allocatable::	theta				(:,:)						! MISTAKE HERE??
real,allocatable::				theta_out			(:,:,:)						! Stores Emax Regression Coefficients for the simulation part

double precision,allocatable::	std_errors			(:,:)						! Emax Regression Coefficients standard errors
real,allocatable::				std_errors_out		(:,:)						! Stores Emax Regression Coefficients
double precision::				rsq,adj_rsq										! Current period's regression's R squares
!real::							rsq_out				(ntypes,100)				! Stores Emax Regression R squares
!real::							adj_rsq_out			(ntypes,100)				! Stores Emax Regression R squares
real::							rsq_out				(100)						! Stores Emax Regression R squares
real::							adj_rsq_out			(100)						! Stores Emax Regression R squares
integer::						firstreg										! Dummy that signals the first time the regression subroutine is called


!! Taxes
double precision::              tax_paid                                        ! Taxes paid in a given period
integer, parameter::			tax_toggle		=	2							! Switches from proportional to progressive taxation
double precision, parameter::	tax_rate		=	0.2							! Rate used in proportional taxation
integer, parameter::			nbracket		=	8							! Number of progressive taxation brackets 
double precision::				bracket_min		(nbracket)						! Bracket lower bounds
double precision::				bracket_max		(nbracket)						! Bracket upper bounds
double precision::				bracket_rate	(nbracket)						! Marginal tax rates
double precision::				bracket_adj		(nbracket)						! Taxes due are obtained by multiplying the taxable income with the marginal tax rate and subtracting a bracket specific "adjustment"
data							bracket_min(:)	/0		,4.909	,10.910	,18.184	,25.458	,32.732	,43.643	,54.554/ &
								bracket_max(:)	/4.909	,10.910	,18.184	,25.458	,32.732	,43.643	,54.554	,9999999/ &
								bracket_rate(:)	/0		,0.05	,0.1	,0.15	,0.25	,0.32	,0.37	,0.4/	&
								bracket_adj(:)	/0		,.245	,.791	,1.700	,4.246	,6.537	,8.719	,10.356/ 

!! Simulations
double precision::				init_wealth(nhh)								! Wealth at initial period
integer, parameter::			folioex			=	222401
integer::						h												! Household counter
integer::						year		
integer::						folio			(nhh)							! Unique household identifier
integer::						first_year		(nhh)							! Year in which husband turns 25
integer::						last_year		(nhh)							! Year in which husband turns 25
integer::						sexsampled		(nhh)							! Sex of the interviewee
integer::						H_edu			(nhh)							! Husband education attainment
integer::						W_edu			(nhh)							! Wife education
integer::						simage			(nhh,nclones,100)
double precision::				sima			(nhh,nclones,100)						! Simulated Non-Pension Wealth
double precision::				simBh			(nhh,nclones,100)						! Simulated Pension Wealth
double precision::				simBw			(nhh,nclones,100)						! Simulated Pension Wealth
double precision::				simsav			(nhh,nclones,100)						! Simulated Saving Rate
double precision::				simy			(nhh,nclones,100)						! Simulated Household Income
double precision::				simw_h			(nhh,nclones,100)						! Simulated Household Income
double precision::				simw_w			(nhh,nclones,100)						! Simulated Household Income
double precision::				simlnw_h		(nhh,nclones,100)
double precision::				simlnw_w		(nhh,nclones,100)						
double precision::				simc			(nhh,nclones,100)						! Simulated Consumption Decision
integer::						simd			(nhh,nclones,100)						! Simulated Joint Sector Decision
integer::						simd_H			(nhh,nclones,100)						! Simulated Husband Sector Decision
integer::						simd_W			(nhh,nclones,100)						! Simulated Wife Sector Decision
integer::						simedu_h		(nhh,nclones,100)						! Simulated Husband educational attainment
integer::						simedu_w		(nhh,nclones,100)						! Simulated Wife educational attainment
integer::						simcohort		(nhh,nclones,100)						! Simulated Birth Cohort
integer::						simtype			(nhh,nclones,100)						! Simulated type
integer::						simXP_Fh		(nhh,nclones,100)						! Simulated Husband formal experience
integer::						simXP_Ih		(nhh,nclones,100)						! Simulated Husband informal experience
integer::						siminact_H		(nhh,nclones,100)						! Simulated Husband inactive years
integer::						simXP_Fw		(nhh,nclones,100)						! Simulated Wife formal experience
integer::						simXP_Iw		(nhh,nclones,100)						! Simulated Wife informal experience
integer::						siminact_W		(nhh,nclones,100)						! Simulated Wife inactive years
integer::						simH_formal		(nhh,nclones,100)						! Simulated Husband formal current choice dummy
integer::						simH_informal	(nhh,nclones,100)						! Simulated Husband informal current choice dummy
integer::						simH_inactive	(nhh,nclones,100)						! Simulated Husband formal current choice dummy
integer::						simW_formal		(nhh,nclones,100)						! Simulated Wife formal current choice dummy
integer::						simW_informal	(nhh,nclones,100)						! Simulated Wife informal current choice dummy
integer::						simW_inactive	(nhh,nclones,100)						! Simulated Wife inactive current choice dummy
double precision::				simv			(nhh,nclones,100)						! Simulated value function
double precision::              simtax          (nhh,nclones,100)                       ! Simulated taxes paid
integer::						H_elig													! Husband eligibility for minimum pension dummy
integer::						W_elig													! Wife eligibility for minimum pension dummy
integer::						H_nonel													! Husband noneligibility for minimum pension dummy
integer::						W_nonel											! Wife noneligibility for minimum pension dummy
integer::						H_overMP												! Husband dummy for pension savings above minimum pension
integer::						W_overMP										! Wife dummy for pension savings above minimum pension
double precision::				H_MPbenef										! Husband minimum pension benefit
double precision::				W_MPbenef										! Wife minimum pension benefit
double precision::				H_WPbenef										! Husband minimum pension benefit
double precision::				W_WPbenef										! Wife minimum pension benefit
integer::						bestH_elig													! Husband eligibility for minimum pension dummy
integer::						bestW_elig													! Wife eligibility for minimum pension dummy
integer::						bestH_nonel													! Husband noneligibility for minimum pension dummy
integer::						bestW_nonel											! Wife noneligibility for minimum pension dummy
integer::						bestH_overMP												! Husband dummy for pension savings above minimum pension
integer::						bestW_overMP										! Wife dummy for pension savings above minimum pension
double precision::				bestH_MPbenef										! Husband minimum pension benefit
double precision::				bestW_MPbenef										! Wife minimum pension benefit
double precision::				bestH_WPbenef										! Husband minimum pension benefit
double precision::				bestW_WPbenef	
double precision::				bestAPS_h	
double precision::				bestAPS_w	
integer::						simH_elig		(nhh,nclones,100)							! Stores Husband eligibility for minimum pension dummy
integer::						simW_elig		(nhh,nclones,100)							! Stores Wife eligibility for minimum pension dummy
integer::						simH_nonel		(nhh,nclones,100)							! Stores Husband noneligibility for minimum pension dummy
integer::						simW_nonel		(nhh,nclones,100)							! Stores Wife noneligibility for minimum pension dummy
integer::						simH_overMP		(nhh,nclones,100)							! Stores Husband dummy for pension savings above minimum pension
integer::						simW_overMP		(nhh,nclones,100)							! Stores Wife dummy for pension savings above minimum pension
double precision::				simH_MPbenef	(nhh,nclones,100)							! Stores Husband minimum pension benefit
double precision::				simW_MPbenef	(nhh,nclones,100)							! Stores Wife minimum pension benefit
double precision::				simH_WPbenef	(nhh,nclones,100)							! Stores Husband minimum pension benefit
double precision::				simW_WPbenef	(nhh,nclones,100)							! Stores Wife minimum pension benefit
double precision::				simH_APS		(nhh,nclones,100)							! Stores Husband minimum pension benefit
double precision::				simW_APS		(nhh,nclones,100)							! Stores Wife minimum pension benefit
integer::						birthcohort		(nhh)							! Cohort 

!! Moment computation
!double precision::				a_ageeduh(nagegrp,nedu),		a_ageeduw(nagegrp,nedu)
double precision::				a_ageeduh(nagegrp,nedu,30000),a_ageeduw(nagegrp,nedu,30000),m(1000),mdata(1000)
double precision::				Bh_ageeduh(nagegrp,nedu,30000,ncohort),Bw_ageeduw(nagegrp,nedu,30000,ncohort)
integer::						i_ageeduh0406(nagegrp,nedu)
integer::						i_ageeduw0406(nagegrp,nedu)
integer::						i_ageeduh8801(nagegrp,nedu,ncohort)
integer::						i_ageeduw8801(nagegrp,nedu,ncohort)
integer::						i_ageedu2002(nagegrp,nedu,2,2)
integer::						i_agesex(nagegrp,2)
integer::						i_lnwdfce(2,2,2)
integer::						i_lnwdfce_age(2,nagegrp,2)
double precision::				JLS_ageedu(nagegrp,nedu,nedu,nds) !,JLS_ageeduw(nagegrp,nedu,nds)
!double precision::				lnw_ageedu(nagegrp,nedu,2,2)
double precision::				lnw_ageedu(nagegrp,nedu,3,2,30000)
double precision::				lnw_XP	(nXPgroups,3,2,2,100000)
double precision::				lnwdfce(2,2,2)
double precision::				lnwdfce_age(2,nagegrp,2)
integer::						agegrp 
integer::						twoyrtrans(nds,nds),trans(nagegrp,2,3,3),nb_inc(3,3)
double precision,allocatable::	loss(:,:), lossP(:,:)
double precision::				weights(1000)
double precision::				nbobs(1000)
integer::						XPFhgroup
integer::						XPIhgroup
integer::						XPFwgroup
integer::						XPIwgroup
integer::						status_ageedu02	(nagegrp,nedu,3,2)
integer::						status_XP02		(nXPgroups,3,2,2)
integer::						status_ageedu	(nagegrp,nedu,3,2,ncohort)
integer::						status_XP		(nXPgroups,3,2,2)
integer::						labhistory		(nagegrp,3,2,30000)
integer::						fraccov(nagegrp,2,5), fracinac(nagegrp,2,5)
integer::						nan(1000), inan
integer::						nowealth_age(nagegrp), wealthunder6_age(nagegrp), wealthover6_age(nagegrp)
integer::						i_agestatush0406(nagegrp,2),i_agestatusw0406(nagegrp,2)
double precision::				a_agestatush(nagegrp,2,30000), a_agestatusw(nagegrp,2,30000)

!! Analytical value function 
double precision::				raison(ntypes), raison2(ntypes), c_mult(ntypes)	! Analytical Value Function components

!! Appspack interface

character(len=50)				JLSin, JLSout, tag, tagest
double precision				criterion,eval, minrsq
double precision, parameter::	decentrsq		=	0.98
double precision, parameter::	curv_penal		=	11.0
double precision::				rsq_penal
integer							eval_flag,inv_flag,nparams

!! Random number generator   						
integer,parameter::				seedran1		=	10							
integer::						seedrandom_num	(2)
data							seedrandom_num	/2147483562,2147483398/							
integer::       				idum											

!! Initial conditions
double precision::				wealth_draw(nhh,nclones)
integer::						match_draw(nhh,nclones)
double precision::				init_H_bal(nhh)
double precision::				init_W_bal(nhh)
double precision::				init_H_Xformal(nhh)
double precision::				init_H_Xinformal(nhh)
double precision::				init_H_yrsinactive(nhh)
double precision::				init_W_Xformal(nhh)
double precision::				init_W_Xinformal(nhh)
double precision::				init_W_yrsinactive(nhh)
integer::						init_wealth_dum(nhh)
integer::						init_age(nhh)
double precision::				wealthpool(nhh)
integer::						nwealthpool
double precision::				draw_init(nhh*nclones)
double precision::				init_draw(nhh,nclones)
integer::						H_match1(nhh)
integer::						H_match2(nhh)
integer::						H_match3(nhh)
integer::						H_match4(nhh)
integer::						W_match1(nhh)
integer::						W_match2(nhh)
integer::						W_match3(nhh)
integer::						W_match4(nhh)
integer::						H_match1_dum(nhh)
integer::						H_match2_dum(nhh)
integer::						H_match3_dum(nhh)
integer::						H_match4_dum(nhh)
integer::						W_match1_dum(nhh)
integer::						W_match2_dum(nhh)
integer::						W_match3_dum(nhh)
integer::						W_match4_dum(nhh)
integer::						nW_match1
integer::						nW_match2
integer::						nW_match3
integer::						nW_match4
integer::						nH_match1
integer::						nH_match2
integer::						nH_match3
integer::						nH_match4
integer::                       futurecohort(243)

!! Clock variables
integer::						time_array_0(8), time_array_1(8)
real::							start_time, finish_time



!					**************************************************************************
!							
!												CEMETERY
!
!					**************************************************************************





integer::						nnowealth(100),nnowealthatall(100),nabar1(100),nabar2(100),nBhbar1(100),nBhbar2(100),nBwbar1(100),nBwbar2(100)

! Types




!! maxu arguments
!double precision::								a											! non-retirement savings
!double precision::								Bh,Bw										! retirement savings
!double precision::								Eps_Fh, Eps_Ih, Eps_Fw, Eps_Iw				! Wage Offer shocks
!integer::										edu_h,edu_w									! Education attainments
!integer::										XP_Fh,XP_Ih,XP_Fw,XP_Iw						! Sector-specific experience (in years)
!double precision::								XP_Fh_comp,XP_Ih_comp,XP_Fw_comp,XP_Iw_comp	! Sector-specific experience component in wage offer equation

!! Moment calculations
!integer::						agegrp
!integer::						i_wealth(nagegrp),n_wealth(nagegrp)
!double precision::				wealth_vec(nagegrp,3000)
!double precision::				medianwealth(nagegrp)

! Data
!integer::						JLSdecision06(nhh)							! Joint Sector Decisions in 2006
!integer::						H_agegrp06	(nhh)							! Husband agegroup in 2006	
!integer::						H_age06		(nhh)							! Husband Age in 2006
!integer::						H_age04		(nhh)							! Husband Age in 2006
!double precision::				H_bal04		(nhh)							! Husband Balance in 2004
!double precision::				H_bal06		(nhh)							! Husband Balance in 2006
!double precision::				W_bal04		(nhh)							! Wife Balance in 2004		
!double precision::				W_bal06		(nhh)							! Wife Balance in 2006
!double precision::				wealth04	(nhh)							! Non Pension Wealth in 2004
!double precision::				wealth06	(nhh)							! Non Pension Wealth in 2006
!double precision::				imputedbal04(nhh)							! Imputed balance for spouses in 2004
!integer::						intmat			(100,100)						! Indicator matrix for interactions

integer::					wealth2,maxXP,maxXPhh, maxearncapa,maxearncapa2, maxhhearncapa,maxhhearncapa2, maxearncapahigh, lowhhearnings, highhhearnings
double precision::			uwealthp1m1xsumedu, maxearncapaxlogwealthp5,maxearncapaxlogwealthp52
end module params	


