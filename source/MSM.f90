subroutine MSM

use params
use filenames
implicit none

!*********************************************************************************************************************************
integer::								edu,eduh,eduw,i,sex, sector, sector_1,jls,jls_2,status, lagsect,cursect,XPgr,sectorXP,gr
double precision::						denom
double precision, allocatable::			temp(:,:)
character(len=40)			name			! A variable that "absorbs" the parameter name in the read statement
integer number, j, k,nbinc, nbinc_l, temp2(9,3), temp5
double precision:: temp4, realnumber
character(len=4):: crap
double precision:: temp3(1000)
double precision:: meanbyedu, meanbyage
integer:: nbedu, nbage,cohort
!*********************************************************************************************************************************


i=1
inan=1 !counts the number of NAN in moments list
nan(:)=0
open (unit=1431,file=pathoutput//adjustl(trim(ctag))//'Momentgroups.txt',position='rewind')
open (unit=10001, file=pathdatavsmodel//'mdata.txt',position='rewind')
read(fmt=*,unit=10001) name

!! JLS
!******

!!open (unit=10001, file=pathdatavsmodel//'JLS_data.txt')

write(unit=1431,fmt=*),i,'  !! The prop of hh choosing each of the 9 joint occup, by age '
do jls=1,9
do agegrp=2,nagegrp-1
	m(i)=sum(JLS_ageedu(agegrp,:,:,jls))/sum(JLS_ageedu(agegrp,:,:,:))
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

write(unit=1431,fmt=*),i,'  !! The prop of hh choosing each of the 9 joint occup, by schooling level of the husband '

do jls=1,9
!!read(fmt=*,unit=10001) name
do eduh=1,4
	m(i)=sum(JLS_ageedu(:,eduh,:,jls))/sum(JLS_ageedu(:,eduh,:,:))
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

write(unit=1431,fmt=*),i,'  !! The prop of hh choosing each of the 9 joint occup, by schooling level of the wife '
do jls=1,9
!!read(fmt=*,unit=10001) name
do eduw=1,4
	m(i)=sum(JLS_ageedu(:,:,eduw,jls))/sum(JLS_ageedu(:,:,eduw,:))
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo


!! Nb of incomes
!! *************

!print*, 'nbincomes',i
!open (unit=10001, file=pathdatavsmodel//'nbinc_data.txt',position='rewind')

write(unit=1431,fmt=*),i,'  !! The prop of two-income hh by age '
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=(sum(JLS_ageedu(agegrp,:,:,1))+sum(JLS_ageedu(agegrp,:,:,2))+sum(JLS_ageedu(agegrp,:,:,4))+&
	& sum(JLS_ageedu(agegrp,:,:,5)))/sum(JLS_ageedu(agegrp,:,:,:))
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

write(unit=1431,fmt=*),i,'  !! The prop of two-income hh by schooling level of the husband and by age '
!read(fmt=*,unit=10001) name
do eduh=1,4
	
	m(i)=(sum(JLS_ageedu(:,eduh,:,1))+sum(JLS_ageedu(:,eduh,:,2))+sum(JLS_ageedu(:,eduh,:,4))+&
	& sum(JLS_ageedu(:,eduh,:,5)))/sum(JLS_ageedu(:,eduh,:,:))
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

write(unit=1431,fmt=*),i,'  !! The prop of two-income hh by schooling level of the wife and by age '
!read(fmt=*,unit=10001) name
do eduw=1,4
	
	m(i)=(sum(JLS_ageedu(:,:,eduw,1))+sum(JLS_ageedu(:,:,eduw,2))+sum(JLS_ageedu(:,:,eduw,4))+&
	& sum(JLS_ageedu(:,:,eduw,5)))/sum(JLS_ageedu(:,:,eduw,:))
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

write(unit=1431,fmt=*),i,'  !! The prop of one-income hh by age '
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=(sum(JLS_ageedu(agegrp,:,:,3))+sum(JLS_ageedu(agegrp,:,:,6))+sum(JLS_ageedu(agegrp,:,:,7))+&
	& sum(JLS_ageedu(agegrp,:,:,8)))/sum(JLS_ageedu(agegrp,:,:,:))
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

write(unit=1431,fmt=*),i,'  !! The prop of one-income hh by schooling level of the husband '
!read(fmt=*,unit=10001) name
do eduh=1,4
	
	m(i)=(sum(JLS_ageedu(:,eduh,:,3))+sum(JLS_ageedu(:,eduh,:,6))+sum(JLS_ageedu(:,eduh,:,7))+&
	& sum(JLS_ageedu(:,eduh,:,8)))/sum(JLS_ageedu(:,eduh,:,:))
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

write(unit=1431,fmt=*),i,'  !! The prop of one-income hh by schooling level of the wife ' 
!read(fmt=*,unit=10001) name
do eduw=1,4
	
	m(i)=(sum(JLS_ageedu(:,:,eduw,3))+sum(JLS_ageedu(:,:,eduw,6))+sum(JLS_ageedu(:,:,eduw,7))+&
	& sum(JLS_ageedu(:,:,eduw,8)))/sum(JLS_ageedu(:,:,eduw,:))
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo


!! LS
!! ***
!print*,'LS',i
!open (unit=10001, file=pathdatavsmodel//'LS_data.txt',position='rewind')

write(unit=1431,fmt=*),i,'  !! The fraction of Husbands/Wives in each employment status by age and education '
do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=sum(status_ageedu(agegrp,:,status,1,:))*1.0/sum(status_ageedu (agegrp,:,:,1,:))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=sum(status_ageedu(agegrp,:,status,2,:))*1.0/sum(status_ageedu (agegrp,:,:,2,:))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

do status=1,3
!read(fmt=*,unit=10001) name
do edu=1,4
	
	m(i)=sum(status_ageedu(:,edu,status,1,:))*1.0/sum(status_ageedu (:,edu,:,1,:))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

do status=1,3
!read(fmt=*,unit=10001) name
do edu=1,4
	
	m(i)=sum(status_ageedu(:,edu,status,2,:))*1.0/sum(status_ageedu (:,edu,:,2,:))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

write(unit=1431,fmt=*),i,'  !! The fraction of Husbands/Wives in each employment status by sector-specific experience '
do sex=1,2
do sector=1,2
do status=1,3
!read(fmt=*,unit=10001) name
do XPgr=1,6
	
	if (sum(status_XP (XPgr,:,sector,sex))>0) then
		m(i)=status_XP(XPgr,status,sector,sex)*1.0/sum(status_XP (XPgr,:,sector,sex))*1.0
		
		read(fmt=*,unit=10001) name,mdata(i)
		i=i+1
	elseif (sum(status_XP (XPgr,:,sector,sex))==0) then
		nan(inan)=i
		inan=inan+1
		
		read(fmt=*,unit=10001) name,mdata(i)
		m(i)=1
		mdata(i)=0
		i=i+1
	endif
enddo
enddo
enddo
enddo


!! Wealth
!! ******

write(unit=1431,fmt=*),i,'  !! The mean of private savings by age and schooling level of the husband/wife'
!print*,'wealth',i
!open (unit=10001, file=pathdatavsmodel//'wealth_data.txt',position='rewind')

do edu=1,4
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=sum(a_ageeduh(agegrp,edu,1:i_ageeduh0406(agegrp,edu)))/i_ageeduh0406(agegrp,edu)
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

do edu=1,4
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=sum(a_ageeduw(agegrp,edu,1:i_ageeduw0406(agegrp,edu)))/i_ageeduw0406(agegrp,edu)
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

!! The variance of private savings by schooling level of the husband/wife regardless of age

!read(fmt=*,unit=10001) name
do edu=1,4
	meanbyedu=0.0
	! Get the mean private savings for that level of edu regardless of age
	do agegrp=2,nagegrp-1
		meanbyedu=meanbyedu+sum(a_ageeduh(agegrp,edu,1:i_ageeduh0406(agegrp,edu)))
	enddo
	nbedu=sum(i_ageeduh0406(:,edu))
	meanbyedu=meanbyedu/nbedu
	
	! Sum deviations from the mean, one agegrp at a time
	do agegrp=2,nagegrp-1
		m(i)=m(i)+sum((a_ageeduh(agegrp,edu,1:i_ageeduh0406(agegrp,edu))-meanbyedu)* &
		&		 (a_ageeduh(agegrp,edu,1:i_ageeduh0406(agegrp,edu))-meanbyedu)) 
	enddo
	m(i)=m(i)/(nbedu-1)

	! Read data moment
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!read(fmt=*,unit=10001) name
do edu=1,4
	meanbyedu=0.0

	! Get the mean private savings for that level of edu regardless of age
	do agegrp=2,nagegrp-1
		meanbyedu=meanbyedu+sum(a_ageeduw(agegrp,edu,1:i_ageeduw0406(agegrp,edu)))
	enddo
	nbedu=sum(i_ageeduw0406(:,edu))
	meanbyedu=meanbyedu/nbedu
	
	! Sum deviations from the mean, one agegrp at a time
	do agegrp=2,nagegrp-1
		m(i)=m(i)+sum((a_ageeduw(agegrp,edu,1:i_ageeduw0406(agegrp,edu))-meanbyedu)* &
		&		 (a_ageeduw(agegrp,edu,1:i_ageeduw0406(agegrp,edu))-meanbyedu)) 
	enddo
	m(i)=m(i)/(nbedu-1)

	! Read data moment
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!! The variance of private savings by agegrp of the household regardless of education

!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	meanbyage=0.0
	! Get the mean private savings for that agegrp regardless of education
	do edu=1,4
		meanbyage=meanbyage+sum(a_ageeduw(agegrp,edu,1:i_ageeduw0406(agegrp,edu)))
	enddo
	nbage=sum(i_ageeduw0406(agegrp,:))
	meanbyage=meanbyage/nbage
	
	! Sum deviations from the mean, one education level at a time
	do edu=1,4
		m(i)=m(i)+sum((a_ageeduw(agegrp,edu,1:i_ageeduw0406(agegrp,edu))-meanbyage)* &
		&		 (a_ageeduw(agegrp,edu,1:i_ageeduw0406(agegrp,edu))-meanbyage)) 
	enddo
	m(i)=m(i)/(nbage-1)

	! Read data moment
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo



write(unit=1431,fmt=*),i,'  !! The mean of pension savings by age and schooling level of the husband/wife'
!print*,'wealth',i
!open (unit=10001, file=pathdatavsmodel//'wealth_data.txt')
do edu=1,4
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	do cohort=1,ncohort
	m(i)=m(i)+sum(Bh_ageeduh(agegrp,edu,1:i_ageeduh8801(agegrp,edu,cohort),cohort))
	enddo
	m(i)=m(i)/sum(i_ageeduh8801(agegrp,edu,:))
	read(fmt=*,unit=10001) name,mdata(i)	
	i=i+1
enddo
enddo

do edu=1,4
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	do cohort=1,ncohort
	m(i)=m(i)+sum(Bw_ageeduw(agegrp,edu,1:i_ageeduw8801(agegrp,edu,cohort),cohort))
	enddo
	m(i)=m(i)/sum(i_ageeduw8801(agegrp,edu,:))
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

!! The variance of pension savings by schooling level of the husband/wife regardless of age

!read(fmt=*,unit=10001) name
do edu=1,4
	meanbyedu=0.0
	! Get the mean pension savings for that level of edu regardless of age
	do agegrp=2,nagegrp-1
	do cohort=1,ncohort
		meanbyedu=meanbyedu+sum(Bh_ageeduh(agegrp,edu,1:i_ageeduh8801(agegrp,edu,cohort),cohort))
	enddo
	enddo
	nbedu=sum(i_ageeduh8801(:,edu,:))
	meanbyedu=meanbyedu/nbedu
	
	! Sum deviations from the mean, one agegrp at a time
	do agegrp=2,nagegrp-1
	do cohort=1,ncohort
		m(i)=m(i)+sum((Bh_ageeduh(agegrp,edu,1:i_ageeduh8801(agegrp,edu,cohort),cohort)-meanbyedu)* &
		&		 (Bh_ageeduh(agegrp,edu,1:i_ageeduh8801(agegrp,edu,cohort),cohort)-meanbyedu)) 
	enddo
	enddo
	m(i)=m(i)/(nbedu-1)

	! Read data moment
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!read(fmt=*,unit=10001) name
do edu=1,4
	meanbyedu=0.0
	! Get the mean pension savings for that level of edu regardless of age
	do agegrp=2,nagegrp-1
	do cohort=1,ncohort
		meanbyedu=meanbyedu+sum(Bw_ageeduw(agegrp,edu,1:i_ageeduw8801(agegrp,edu,cohort),cohort))
	enddo
	enddo
	nbedu=sum(i_ageeduw8801(:,edu,:))
	meanbyedu=meanbyedu/nbedu
	
	! Sum deviations from the mean, one agegrp at a time
	do agegrp=2,nagegrp-1
	do cohort=1,ncohort
		m(i)=m(i)+sum((Bw_ageeduw(agegrp,edu,1:i_ageeduw8801(agegrp,edu,cohort),cohort)-meanbyedu)* &
		&		 (Bw_ageeduw(agegrp,edu,1:i_ageeduw8801(agegrp,edu,cohort),cohort)-meanbyedu)) 
	enddo
	enddo
	m(i)=m(i)/(nbedu-1)

	! Read data moment
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!! The variance of husband pension savings by agegrp of the household regardless of education


!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	meanbyage=0.0
	! Get the mean pension savings for that agegrp regardless of education
	do edu=1,4
	do cohort=1,ncohort
		meanbyage=meanbyage+sum(Bh_ageeduh(agegrp,edu,1:i_ageeduh8801(agegrp,edu,cohort),cohort))
	enddo
	enddo
	nbage=sum(i_ageeduh8801(agegrp,:,:))
	meanbyage=meanbyage/nbage
	
	! Sum deviations from the mean, one education level at a time
	do edu=1,4
	do cohort=1,ncohort
		m(i)=m(i)+sum((Bh_ageeduh(agegrp,edu,1:i_ageeduh8801(agegrp,edu,cohort),cohort)-meanbyage)* &
		&		 (Bh_ageeduh(agegrp,edu,1:i_ageeduh8801(agegrp,edu,cohort),cohort)-meanbyage)) 
	enddo
	enddo
	m(i)=m(i)/(nbage-1)

	! Read data moment
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!! The variance of wife pension savings by agegrp of the household regardless of education


!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	meanbyage=0.0

	! Get the mean pension savings for that agegrp regardless of education
	do edu=1,4
	do cohort=1,ncohort
		meanbyage=meanbyage+sum(Bw_ageeduw(agegrp,edu,1:i_ageeduw8801(agegrp,edu,cohort),cohort))
	enddo
	enddo
	nbage=sum(i_ageeduw8801(agegrp,:,:))
	meanbyage=meanbyage/nbage
	
	! Sum deviations from the mean, one education level at a time
	do edu=1,4
	do cohort=1,ncohort
		m(i)=m(i)+sum((Bw_ageeduw(agegrp,edu,1:i_ageeduw8801(agegrp,edu,cohort),cohort)-meanbyage)* &
		&		 (Bw_ageeduw(agegrp,edu,1:i_ageeduw8801(agegrp,edu,cohort),cohort)-meanbyage)) 
	enddo
	enddo
	m(i)=m(i)/(nbage-1)

	! Read data moment
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo



!! Wages
!! *****

write(unit=1431,fmt=*),i,'  !! Mean and variance of log wage by sector, sex and age '
!print*,'wages',i
!open (unit=10001, file=pathdatavsmodel//'wages_data.txt')

do sex=1,2
j=0
do sector=1,2
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	do edu=1,4
	m(i)=m(i)+sum(lnw_ageedu(agegrp,edu,sector,sex,1:status_ageedu02(agegrp,edu,sector,sex)))
	enddo
	m(i)=m(i) /sum(status_ageedu02(agegrp,:,sector,sex))
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
	j=j+1
enddo
enddo
do sector=1,2
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	temp4=0.0
	do edu=1,4
	do k=1,status_ageedu02(agegrp,edu,sector,sex)
	temp4=temp4+(lnw_ageedu(agegrp,edu,sector,sex,k)-m(i-j))**2
	enddo
	enddo
	m(i)=temp4/(sum(status_ageedu02(agegrp,:,sector,sex))-1)
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo


write(unit=1431,fmt=*),i,'  !! Mean and variance of log wage by sector, sex and education '

do sex=1,2
j=0
do sector=1,2
!read(fmt=*,unit=10001) name
do edu=1,4
	do agegrp=2,nagegrp-1
	m(i)=m(i)+sum(lnw_ageedu(agegrp,edu,sector,sex,1:status_ageedu02(agegrp,edu,sector,sex)))	
	enddo
	m(i)=m(i)/sum(status_ageedu02(:,edu,sector,sex))
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
	j=j+1
enddo
enddo
do sector=1,2
!read(fmt=*,unit=10001) name

do edu=1,4
	temp4=0.0
	do agegrp=2,nagegrp-1
	do k=1,status_ageedu02(agegrp,edu,sector,sex)
	temp4=temp4+(lnw_ageedu(agegrp,edu,sector,sex,k)-m(i-j))**2
	enddo
	enddo
	m(i)=temp4/(sum(status_ageedu02(:,edu,sector,sex))-1)
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo

write(unit=1431,fmt=*),i,'  !! Mean log wage by sector, sector-specific experience and sex'
do sectorXP=1,2
do sex=1,2
!read(fmt=*,unit=10001) name
do XPgr=1,6
	if     (sum(status_XP02 (XPgr,1:2,sectorXP,sex))>0) then
		do sector=1,2
		m(i)=m(i)+sum(lnw_XP(XPgr,sector,sectorXP,sex,1:status_XP02(XPgr,sector,sectorXP,sex)))
		enddo
		m(i)=m(i)/sum(status_XP02(XPgr,1:2,sectorXP,sex))
		read(fmt=*,unit=10001) name,mdata(i)
		i=i+1
	elseif (sum(status_XP02 (XPgr,1:2,sectorXP,sex))==0) then
		nan(inan)=i
		inan=inan+1
		m(i)=0      !!change this!! also must have a read statement once done with test
		read(fmt=*,unit=10001) name,mdata(i)
		i=i+1
	endif
	
	
enddo
enddo
enddo


!! Transitions
!! ************
!print*,'transitions',i
!open (unit=10001, file=pathdatavsmodel//'transition_data.txt')


write(unit=1431,fmt=*),i,'  !! Mean logwage first difference by current and lagged sector '

lnwdfce=lnwdfce/i_lnwdfce
do sex=1,2
do lagsect=1,2
!read(fmt=*,unit=10001) name
do cursect=1,2
	if (i_lnwdfce(cursect,lagsect,sex)>0) then
	m(i)=lnwdfce(cursect,lagsect,sex)
	else if (i_lnwdfce(cursect,lagsect,sex)==0) then
	m(i)=0 !!Change this???
	nan(inan)=i
	inan=inan+1
	endif
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo

write(unit=1431,fmt=*),i,'  !! Mean logwage first differences by age '

lnwdfce_age=lnwdfce_age/i_lnwdfce_age
do sex=1,2
do cursect=1,2
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	m(i)=lnwdfce_age(cursect,agegrp,sex)
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo


write(unit=1431,fmt=*),i,'  !! Two period joint transitions between nb of incomes in the hh'

temp2(:,3)=twoyrtrans(:,1)+twoyrtrans(:,2)+twoyrtrans(:,4)+twoyrtrans(:,5)
temp2(:,2)=twoyrtrans(:,3)+twoyrtrans(:,6)+twoyrtrans(:,7)+twoyrtrans(:,8)
temp2(:,1)=twoyrtrans(:,9)
nb_inc(3,:)=temp2(1,:)+temp2(2,:)+temp2(4,:)+temp2(5,:)
nb_inc(2,:)=temp2(3,:)+temp2(6,:)+temp2(7,:)+temp2(8,:)
nb_inc(1,:)=temp2(9,:)

do nbinc=1,3
!read(fmt=*,unit=10001) name
do nbinc_l=1,3
	denom=sum(nb_inc(:,nbinc_l))*1.0
	m(i)=nb_inc(nbinc,nbinc_l)*1.0/denom
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

!print*,i

write(unit=1431,fmt=*),i,'  !! 1-period individual transitions between the 3 employment status by age and sex'
do agegrp=3,nagegrp-1
do sex=1,2
do sector=1,3
!read(fmt=*,unit=10001) name
do sector_1=1,3
	denom=sum(trans(agegrp,sex,:,sector_1))*1.0
	if (denom>0) then
		m(i)=trans(agegrp,sex,sector,sector_1)*1.0/denom
		
		
		read(fmt=*,unit=10001) name,mdata(i)
		i=i+1
	elseif (denom==0) then
		nan(inan)=i
		inan=inan+1
		
		
		m(i)=0.0
		read(fmt=*,unit=10001) name,mdata(i)
		i=i+1
	endif

enddo
enddo
enddo
enddo

write(unit=1431,fmt=*),i,'  !! Mean nb of years in each employment status by agegrp and sex'

do sex=1,2
do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	m(i)=sum(labhistory (agegrp,status,sex,1:i_agesex(agegrp,sex)))*1.0/i_agesex(agegrp,sex)*1.0
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo

write(unit=1431,fmt=*),i,'  !! Fraction of total years in covered jobs by sex'

do sex=1,2
!read(fmt=*,unit=10001) name
do gr=1,5
	m(i)=(fraccov(5,sex,gr)+fraccov(6,sex,gr)+fraccov(7,sex,gr))*1.0/(sum(fraccov(5,sex,:))+sum(fraccov(6,sex,:))+sum(fraccov(7,sex,:)))*1.0
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
!read(fmt=*,unit=10001) name
do gr=1,5
		m(i)=(fraccov(2,sex,gr)+fraccov(3,sex,gr)+fraccov(4,sex,gr))*1.0/(sum(fraccov(2,sex,:))+sum(fraccov(3,sex,:))+sum(fraccov(4,sex,:)))*1.0
		
		
		read(fmt=*,unit=10001) name,mdata(i)
		i=i+1
enddo
enddo

write(unit=1431,fmt=*),i,'  !! Fraction of total years inactive by sex'

do sex=1,2
!read(fmt=*,unit=10001) name
do gr=1,5
	m(i)=(fracinac(5,sex,gr)+fracinac(6,sex,gr)+fracinac(7,sex,gr))*1.0/(sum(fracinac(5,sex,:))+sum(fracinac(6,sex,:))+sum(fracinac(7,sex,:)))*1.0
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
!read(fmt=*,unit=10001) name
do gr=1,5
	m(i)=(fracinac(2,sex,gr)+fracinac(3,sex,gr)+fracinac(4,sex,gr))*1.0/(sum(fracinac(2,sex,:))+sum(fracinac(3,sex,:))+sum(fracinac(4,sex,:)))*1.0
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo


!! Extra moments
!***************

write(unit=1431,fmt=*),i,'  !! The distribution of wealth by age '
do agegrp=2,nagegrp-1

	m(i)=nowealth_age(agegrp)*1.0/sum(i_ageeduh0406(agegrp,:))
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
do agegrp=2,nagegrp-1

	m(i)=wealthunder6_age(agegrp)*1.0/sum(i_ageeduh0406(agegrp,:))
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
do agegrp=2,nagegrp-1

	m(i)=wealthover6_age(agegrp)*1.0/sum(i_ageeduh0406(agegrp,:))
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

write(unit=1431,fmt=*),i,'  !! The mean wealth by age and current work sector of the husband'
do sector=1,2
do agegrp=2,nagegrp-1

	m(i)=sum(a_agestatush(agegrp,sector,:))/(i_agestatush0406(agegrp,sector)*1.0)
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo

write(unit=1431,fmt=*),i,'  !! The mean wealth by age and current work sector of the wife'
do sector=1,2
do agegrp=2,nagegrp-1

	m(i)=sum(a_agestatusw(agegrp,sector,:))/(i_agestatusw0406(agegrp,sector)*1.0)
	
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo


write(unit=1431,fmt=*),i,'  !! The fraction of Husbands/Wives in each employment status by age and cohort '

!cohort 1, ages 20-49
do sex=1,2
do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=sum(status_ageedu(agegrp,:,status,sex,1))*1.0/sum(status_ageedu (agegrp,:,:,sex,1))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo

!cohort 2, ages 20-46
do sex=1,2
do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-1
	
	m(i)=sum(status_ageedu(agegrp,:,status,sex,2))*1.0/sum(status_ageedu (agegrp,:,:,sex,2))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo

!cohort 3, ages 20-41
do sex=1,2
do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-2
	
	m(i)=sum(status_ageedu(agegrp,:,status,sex,3))*1.0/sum(status_ageedu (agegrp,:,:,sex,3))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo

!cohort 4, ages 20-36
do sex=1,2
do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-3
	
	m(i)=sum(status_ageedu(agegrp,:,status,sex,4))*1.0/sum(status_ageedu (agegrp,:,:,sex,4))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo


!cohort 5, ages 20-31
do sex=1,2
do status=1,3
!read(fmt=*,unit=10001) name
do agegrp=2,nagegrp-4
	
	m(i)=sum(status_ageedu(agegrp,:,status,sex,5))*1.0/sum(status_ageedu (agegrp,:,:,sex,5))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo
enddo
enddo


write(unit=1431,fmt=*),i,'  !! The mean pension savings of Husbands/Wives by age and cohort '

!cohort 1, ages 20-46
do agegrp=2,nagegrp-1
	
	m(i)=sum(Bh_ageeduh	 (agegrp,:,:,1))*1.0/sum(i_ageeduh8801(agegrp,:,1))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 2, ages 20-41
do agegrp=2,nagegrp-2
	
	m(i)=sum(Bh_ageeduh	 (agegrp,:,:,2))*1.0/sum(i_ageeduh8801(agegrp,:,2))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 3, ages 20-36
do agegrp=2,nagegrp-3
	
	m(i)=sum(Bh_ageeduh	 (agegrp,:,:,3))*1.0/sum(i_ageeduh8801(agegrp,:,3))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 4, ages 20-31
do agegrp=2,nagegrp-4
	
	m(i)=sum(Bh_ageeduh	 (agegrp,:,:,4))*1.0/sum(i_ageeduh8801(agegrp,:,4))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 5, ages 20-26
do agegrp=2,nagegrp-5
	
	m(i)=sum(Bh_ageeduh	 (agegrp,:,:,5))*1.0/sum(i_ageeduh8801(agegrp,:,5))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo


!cohort 1, ages 20-46
do agegrp=2,nagegrp-1
	
	m(i)=sum(Bw_ageeduw	 (agegrp,:,:,1))*1.0/sum(i_ageeduw8801(agegrp,:,1))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 2, ages 20-41
do agegrp=2,nagegrp-2
	
	m(i)=sum(Bw_ageeduw	 (agegrp,:,:,2))*1.0/sum(i_ageeduw8801(agegrp,:,2))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 3, ages 20-36
do agegrp=2,nagegrp-3
	
	m(i)=sum(Bw_ageeduw	 (agegrp,:,:,3))*1.0/sum(i_ageeduw8801(agegrp,:,3))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 4, ages 20-31
do agegrp=2,nagegrp-4
	
	m(i)=sum(Bw_ageeduw	 (agegrp,:,:,4))*1.0/sum(i_ageeduw8801(agegrp,:,4))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

!cohort 5, ages 20-26
do agegrp=2,nagegrp-5
	
	m(i)=sum(Bw_ageeduw	 (agegrp,:,:,5))*1.0/sum(i_ageeduw8801(agegrp,:,5))*1.0
	
	read(fmt=*,unit=10001) name,mdata(i)
	i=i+1
enddo

close(10001)
nmoments=i-1


!! Compute difference between data and simulated moments, store in loss()
allocate (loss (1,nmoments))
allocate (temp(1,nmoments))
loss(1,:)= mdata(1:nmoments) - m(1:nmoments)


open(unit=13201,file=pathdatavsmodel//'weights.txt',position='rewind')
open(unit=13204,file=pathdatavsmodel//'nbobs.txt',position='rewind')
read(unit=13201,fmt=*) crap
read(unit=13204,fmt=*) crap

!print*, crap
do i=1,nmoments
read(unit=13201,fmt=*) crap, weights(i)
read(unit=13204,fmt=*) crap, nbobs(i)
if (weights(i)>0) weights(i)=1/(weights(i)*weights(i))
if (nbobs(i)<30) weights(i)=0.0
if (i.ge.155.and.i.lt.191) weights(i)=50.0*weights(i)
if (i.ge.522.and.i.lt.530) weights(i)=50.0*weights(i)
if (i.ge.288.and.i.lt.312) weights(i)=50.0*weights(i)
!if (i.ge.287) weights(i)=0.0*weights(i)
!if (i.ge.349 .and. i.lt.397) weights(i)=10*weights(i)
!if (i.ge.417 .and. i.lt.553) weights(i)=10*weights(i)
!if (i.ge.728 .and. i.lt.756) weights(i)=10*weights(i)
!print*,i,weights(i), m(i), mdata(i)
enddo
close(13201)
close(13204)

do i=1,nmoments
temp(1,i)=loss(1,i)*loss(1,i)*weights(i)
!if (loss(1,i)=='NaN') temp(1,i)=5.0
!if (loss(1,i)=='nan') temp(1,i)=5.0
if (isnan(temp(1,i))) temp(1,i)=5.0
enddo

if (lenovo==1) then 

open(unit=1655, file=pathoutput//adjustl(trim(ctag))//'moments.txt',position='rewind')
do i=1,nmoments
write(1655,*) m(i)
enddo
close(1655)

open(unit=1654, file=pathoutput//adjustl(trim(ctag))//'criterion.txt',position='rewind')
write(1654,*) ' m(i) ', ' mdata(i) ', ' weights(i) ', ' loss(1,i) ',' nbobs(i) '
do i=1,nmoments
write(1654,'(4f20.8,f9.1)') m(i), mdata(i), weights(i), loss(1,i),nbobs(i)
enddo
close(1654)

endif

criterion=sum(temp)  !sum(weights*loss(1,:)**2)
!if (criterion=='NaN') criterion=9999999999
!if (criterion=='nan') criterion=9999999999
if (isnan(criterion)) criterion=9999999999
!print*,'criterion',criterion, '# nan:',inan-1
!call matpd(1,nmoments,nmoments,loss,weights(1:nmoments,1:nmoments),criterion)
!call matpd(1,nmoments,1,criterion,lossP,criterion)



call date_and_time(values=time_array_1)
finish_time = time_array_1 (5) * 3600 + time_array_1 (6) * 60+ time_array_1 (7) + 0.001 * time_array_1 (8)
!write (*,*) 'tag:',tag,',elapsed wall clock time:',finish_time - start_time    

close(1431)
deallocate(temp)
deallocate(loss)
end subroutine MSM
