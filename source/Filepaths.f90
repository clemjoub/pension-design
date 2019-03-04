module filenames
implicit none

character(*), parameter:: path			    =	'C:\Users\clement\Dropbox\JLSrevise3\JLSrevise3\estimation results\ageprof\'
character(*), parameter:: pathdatavsmodel	=	path//'Datavsmodel/'
character(*), parameter:: pathoutput		=	path//'output/'
character(*), parameter:: pathinput		    =	path//'input/'
character(*), parameter:: pathcounterf		=	path
character(*), parameter:: pathbigscratch	=	pathinput
character(*), parameter:: pathsmallscratch	=	path

!character(*), parameter:: path             =   '/home/joubert/JLS/'
!character(*), parameter:: pathdatavsmodel	=	'/home/joubert/JLS/Datavsmodel/'
!character(*), parameter:: pathoutput		=	'/home/joubert/JLS/output/'

!Inputs:
character(*), parameter:: mdatafile			=	pathdatavsmodel//'mdata.txt'
character(*), parameter:: foliofile			=	pathdatavsmodel//'folio.txt'
character(*), parameter:: H_edufile			=	pathdatavsmodel//'H_edugrp.txt'
character(*), parameter:: W_edufile			=	pathdatavsmodel//'W_edugrp.txt'
character(*), parameter:: firstyearfile		=	pathdatavsmodel//'firstyear.txt'
character(*), parameter:: lastyearfile		=	pathdatavsmodel//'lastyear.txt'
character(*), parameter:: wealthfile		=	pathdatavsmodel//'wealth.txt'
character(*), parameter:: H_balancefile		=	pathdatavsmodel//'H_balance.txt'
character(*), parameter:: W_balancefile		=	pathdatavsmodel//'W_balance.txt'
character(*), parameter:: H_Xformalfile		=	pathdatavsmodel//'H_Xformal.txt'
character(*), parameter:: H_Xinformalfile	=	pathdatavsmodel//'H_Xinformal.txt'
character(*), parameter:: H_yrsinactivefile	=	pathdatavsmodel//'H_yrsinactive.txt'
character(*), parameter:: W_Xformalfile		=	pathdatavsmodel//'W_Xformal.txt'
character(*), parameter:: W_Xinformalfile	=	pathdatavsmodel//'W_Xinformal.txt'
character(*), parameter:: W_yrsinactivefile	=	pathdatavsmodel//'W_yrsinactive.txt'
character(*), parameter:: imputedbal04file	=	pathdatavsmodel//'imputedbal04.txt'
character(*), parameter:: nfoliosfile		=	pathdatavsmodel//'nfolios.txt'
character(*), parameter:: sexsampledfile	=	pathdatavsmodel//'sexsampled.txt'
character(*), parameter:: cohortfile		=	pathdatavsmodel//'cohort.txt'
character(*), parameter:: H_agefile			=	pathdatavsmodel//'H_age.txt'
character(*), parameter:: wealthpoolfile	=	pathdatavsmodel//'wealthpool.txt'
character(*), parameter:: W_match1file		=	pathdatavsmodel//'W_match1.txt'
character(*), parameter:: W_match2file		=	pathdatavsmodel//'W_match2.txt'
character(*), parameter:: W_match3file		=	pathdatavsmodel//'W_match3.txt'
character(*), parameter:: W_match4file		=	pathdatavsmodel//'W_match4.txt'
character(*), parameter:: H_match1file		=	pathdatavsmodel//'H_match1.txt'
character(*), parameter:: H_match2file		=	pathdatavsmodel//'H_match2.txt'
character(*), parameter:: H_match3file		=	pathdatavsmodel//'H_match3.txt'
character(*), parameter:: H_match4file		=	pathdatavsmodel//'H_match4.txt'
character(*), parameter:: MPbeneffile		=	'MPbenef.txt'
character(*), parameter:: emaxfile			=	'emax.txt'
character(*), parameter:: afile				=	'a.txt'
character(*), parameter:: Bhfile			=	'Bh.txt'
character(*), parameter:: Bwfile			=	'Bw.txt'
character(*), parameter:: thetafile			=	'theta.txt'
character(*), parameter:: rsqfile			=	'rsq.txt'
character(*), parameter:: adj_rsqfile		=	'adj_rsq.txt'
character(*), parameter:: d1file			=	'd1.txt'
character(*), parameter:: d2file			=	'd2.txt'
character(*), parameter:: d3file			=	'd3.txt'
character(*), parameter:: d4file			=	'd4.txt'
character(*), parameter:: d5file			=	'd5.txt'
character(*), parameter:: d6file			=	'd6.txt'
character(*), parameter:: d7file			=	'd7.txt'
character(*), parameter:: d8file			=	'd8.txt'
character(*), parameter:: d9file			=	'd9.txt'
character(*), parameter:: savingsfile		=	'savings.txt'
character(*), parameter:: incomefile		=	'income.txt'
character(*), parameter:: regressorsfile	=	'regressors.txt'
character(*), parameter:: checkapfile		=	'checkap.txt'
character(*), parameter:: checksavfile		=	'checksav.txt'
character(*), parameter:: checkcfile		=	'checkc.txt'
character(*), parameter:: checkEmaxfile		=	'checkEmax.txt'
character(*), parameter:: std_errorsfile	=	'std_errors.txt'
character(*), parameter:: valuefunctionfile	=	'simvaluefunctions.txt'
character(*), parameter:: simulatedMPfile	=	'simulatedMP.txt'
character(*), parameter:: onehouseholdfile	=	'onehousehold.txt'
character(*), parameter:: simulationfile	=	'simulation.txt'
character(*), parameter:: paramsfile		=	'params.txt'
character(*), parameter:: Xmatfile			=	'Xmat.txt'
character(*), parameter:: Erroranalysis		=	'Erroranalysis.txt'
character(*), parameter:: Erroranalysisold	=	'Erroranalysisold.txt'

	

endmodule

