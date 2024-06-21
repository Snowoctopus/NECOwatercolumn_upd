
PROGRAM NECO

IMPLICIT NONE

!================
! Set resolution
!================
INTEGER,PARAMETER :: ndays = 2e3
INTEGER,PARAMETER :: Hp = 2000 !change this scale below too
INTEGER,PARAMETER :: dz = 5
INTEGER,PARAMETER :: nz = Hp/dz
REAL*8,PARAMETER ::  dt = 0.02D0
INTEGER,PARAMETER :: nt = ndays/dt
!INTEGER,PARAMETER :: saveall = 1

!=====================================
! define parameters for model running
!=====================================
!CHARACTER(*),PARAMETER :: outdir='Output/'
INTEGER :: startSS = 0      ! 1: load intial files in ICfiles
INTEGER :: recordDaily = 1  ! for recording each dt (for resolution of daily cycle, giving 1D output as a f of time)
INTEGER :: dailycycle = 1   ! for time-variant model resolving daily light cycle
INTEGER :: onep = 2         ! make just one pp type (P3)
REAL*8 :: dayint = 10D0     ! day freq, for recording output in 1D, replacing files every time
REAL*8 :: dayint2 = 10D0    ! day freq, for recording summed output as a f of time (as sumall)
REAL*8 :: dayfa = 1D0
!
!============================
! define parameters for tune
!============================
!============================
! Physical parameters:
!============================
REAL*8,PARAMETER :: H = Hp
REAL*8,PARAMETER :: euz = 80D0       ! [zEU], 80 m, euphotic zone (absorption by water molecules)
REAL*8,PARAMETER :: mlz = 75D0       ! [zML], 75 m, mixed layer depth
REAL*8,PARAMETER :: Kgast = 3D-5     ! m/s
REAL*8,PARAMETER :: kappazmin = 1D-7 ![kZmin], m2/s
REAL*8,PARAMETER :: kappazmax = 1D-3 ![kZmax], m2/s !1D-2
!REAL*8,PARAMETER :: coeffKz = 1D0

!================================
! P: phytoplankton
!      p3: NOX preferred, large; 
!      p2: NH4 preferred, small;
!================================

!------------------------------
! 1. limitation by Temperature
!------------------------------
REAL*8,PARAMETER :: TempAeArr = -4D3       ! [AE], K
REAL*8,PARAMETER :: TemprefArr = 293.15D0  ! [T0], K
REAL*8,PARAMETER :: TempCoeffArr = 0.8D0   ! [tau], 
REAL*8,PARAMETER :: Tkel = 273.15D0
REAL*8,PARAMETER :: TempAeArrP = -8D3

!------------------------
! 2. limitation by light
!------------------------
REAL*8,PARAMETER :: Iinmax = 1400D0     ! [Imax], W/m2
REAL*8,PARAMETER :: a_chl = 0.01D0      ! m2/mg chl a -absorption parameter by chlorophyll 
REAL*8,PARAMETER :: a_chlD = 0.04D3     ! [kChl], m2/g Chl a, for light attenutation: chlorophyll plus CDOM
! REAL*8,PARAMETER :: phimax = 40D0     ! [Phi], mmol C/mol photons/Ein, quantum yield (mol C/mol photons)
! REAL*8,PARAMETER :: a_chlp3 = 0.02D0  ! [a^chl_p3], m2/mg Chl, absorption parameter (in paper as m2/mg chla) avg over all wavelengths
! REAL*8,PARAMETER :: a_chlp2 = 0.02D0  ! [a^chl_p2], m2/mg Chl, absorption parameter
REAL*8,PARAMETER :: chl2cmax = 0.2D0    ! [theta_max], mg Chl/mmol C, from Dutk 2015
REAL*8,PARAMETER :: chl2cmin = 0.02D0   ! [theta_min], min Chl/mmol C
! For unit converting: from MBARI: http://www3.mbari.org/bog/nopp/par.html
! units = W day/Ein: (6.02e23 quanta/Ein)/(86,400 seconds/day * 2.77e18 quanta/s/W)
! NOTE: units for converting is 1/(W day/Ein) in this study
! THUS, convI = 1/(6.02e23 quanta/Ein)/(86,400 seconds/day * 2.77e18 quanta/s/W)
REAL*8,PARAMETER :: convI = 1/(6.02D23/(86400D0*2.77D18))  !{2.77D18/6.02D23*86400D0}

!-----------------------------
! 3. P3: NH4 preferred, small
!-----------------------------
REAL*8,PARAMETER :: umaxp3 = 0.65D0      ![umax,NH4],1/d, statistical results: median
! REAL*8,PARAMETER :: knh4p2 = 0.164D-3  !mol/m3, Litchman scaling, with aV^b with a for knh4 from Ward 2014
! REAL*8,PARAMETER :: kno3p2 = 0.327D-3  ![KNO3,P], mol/m3
! REAL*8,PARAMETER :: kno2p2 = 0.327D-3  ![KNO2,P], mol/m3
REAL*8,PARAMETER :: knh4p3 = 0.1D-3   ! 0.0018D-3 ![KNH4,P],mol/m3, Litchman scaling, with aV^b with a for knh4 from Ward 2014
REAL*8,PARAMETER :: kno3p3 = 1D-1        ! 0.0036D-3! mol/m3, Litchman
REAL*8,PARAMETER :: kno2p3 = 1D-1        ! 0.0036D-3 ! mol/m3, Litchman
REAL*8,PARAMETER :: phimax3 = 40d0       !quantum yield for large phytoplankton
REAL*8,PARAMETER :: mlin3 = 1D-2         !{1D-2}, [mB], linear mortality for b and p

!----------------------------
! 4. P2: NOx preferred, large
!----------------------------
REAL*8,PARAMETER :: umaxp2 = 0.65D0      ![umax, NOx],1/d, -Ward 2014: 1*V^-0.15 for d=0.6 for Pro. max growth rate for p at 20C
! REAL*8,PARAMETER :: knh4p3 = 0.0018D-3 ![KNH4,P],mol/m3, Litchman scaling, with aV^b with a for knh4 from Ward 2014
! REAL*8,PARAMETER :: kno3p3 = 0.0036D-3 !mol/m3, Litchman
! REAL*8,PARAMETER :: kno2p3 = 0.0036D-3 !mol/m3, Litchman
REAL*8,PARAMETER :: knh4p2 = 1D-1        ! 0.164D-3 !mol/m3, Litchman scaling, with aV^b with a for knh4 from Ward 2014
REAL*8,PARAMETER :: kno3p2 = 0.3D-3      ! 0.327D-3  ![KNO3,P], mol/m3
REAL*8,PARAMETER :: kno2p2 = 0.3D-3      ! 0.327D-3  ![KNO2,P], mol/m3
REAL*8,PARAMETER :: phimax2 = 40D0       !quantum yield for large phytoplankton
REAL*8,PARAMETER :: mlin2 = 1D-2         !{1D-2}, [mB], linear mortality for b and p
REAL*8,PARAMETER :: conlim = 1D-12      !<-1D-6(11/27)  !{1D-6}

!--------------
! 5. mortality
!--------------
REAL*8,PARAMETER :: mlin =  1D-2   !{1D-2}, [mB], linear mortality for b and p
REAL*8,PARAMETER :: mquad = 0D3    !{1D3}, [mBq], quadratic mortality for b and p (1 if only mquad, 0.1 if using grazing for stability),

!=============
! Zooplankton
!=============
REAL*8,PARAMETER :: gmax = 1D0  ! [gmax], 1/d  !gmax=0 turns all grazing OFF (quad and linear mort only)
REAL*8,PARAMETER :: kg = 1D-3   ! [Kg], mol/m3
REAL*8,PARAMETER :: gam = 0.5D0 ! [zeta], 1/d, growth yield for zoo
REAL*8,PARAMETER :: mz = 0.7D3  ! [mZ], 1/(mol/m3/d)), quadratic mortality for Z

!==========================================================
! BACTERIA METABOLISMS: Aerobic Heterotroph(bHet)
!==========================================================
REAL*8,PARAMETER :: yd_bo_pa = 0.20D0                     !<-0.14D0(11/27)  !{0.14}, [yD], mol cells/mol Organic matter - aerobic bacteria yield
REAL*8,PARAMETER :: ydon_bo = 0.20D0 
REAL*8,PARAMETER :: pd_max = 1D0                       ![VmaxD], 1/day - normalized max detritus uptake to match nitrate max uptake,
REAL*8,PARAMETER :: pdon_max = 1D0                       
REAL*8,PARAMETER :: kd = 0.05D-3                       ![KD], mol/m3, org matter uptake half sat; used to be 5
REAL*8,PARAMETER :: kdon = 0.05D-3                       ![KD], mol/m3, org matter uptake half sat; used to be 5
REAL*8,PARAMETER :: enh4_bo_pa = (1D0/yd_bo_pa-1D0)          ![1/yD -1], production of ammonia per mol cells produced
REAL*8,PARAMETER :: enh4_bo = (1D0/ydon_bo-1D0)
REAL*8,PARAMETER :: yo_bo_pa = yd_bo_pa/20D0*4D0/(1D0-yd_bo_pa) ![yO2,Het], mol cells/mol O2 -where cells have 1mol N, [yo2_B]
REAL*8,PARAMETER :: yo_bo = ydon_bo/20D0*4D0/(1D0-ydon_bo) 
REAL*8,PARAMETER :: po_coef = 2329100D0                !m3/mol/day

!==========================================================
! BACTERIA METABOLISMS: Ammonia oxidizer(AOO)
!==========================================================
REAL*8,PARAMETER :: ynh4_bnh4 = 1D0/112D0 ![yNH4]
REAL*8,PARAMETER :: pn_max = 50.8D0       ![VmaxNH4, AOO], mol DIN/mol biomass N/day
REAL*8,PARAMETER :: kn = 0.133D-3         ![KNH4,AOO], mol/m3
REAL*8,PARAMETER :: eno2_bnh4 = (1D0/ynh4_bnh4-1D0)   ![1/yNH4-1]
REAL*8,PARAMETER :: yo_bnh4 = 1D0/162D0   ![yO2,AOO]
REAL*8,PARAMETER :: pna = 0.0169D0
REAL*8,PARAMETER :: kna = 2.5D0
REAL*8,PARAMETER :: knb = 0.39D0

!==========================================================
! BACTERIA METABOLISMS: Nitrite oxidizer (NOO)
!==========================================================
REAL*8,PARAMETER :: yno2_bno2 = 1D0/334D0 ![yNO2]
REAL*8,PARAMETER :: pn_max_noo = 40.3D0   !pn_max/2.1544D0   ![VmaxNO2, NOO],1/day , for 10x larger volume
REAL*8,PARAMETER :: kn_noo = 0.168D-3     !kn*2.1544D0       ![KNO2,NOO], mol/m3
REAL*8,PARAMETER :: eno3_bno2 = (1D0/yno2_bno2-1D0)          ![1/yNO2-1]
REAL*8,PARAMETER :: yo_bno2 = 1D0/162D0                      ![yO2,AOO]
REAL*8,PARAMETER :: pn_nooa = 0.01969                        !light inhibition on NOB maximun uptake rate
REAL*8,PARAMETER :: kn_nooa = 2.5                            !light inhibition on NOB 
REAL*8,PARAMETER :: kn_noob = 0.39

!==========================================================
! Oxygen ratio for pp production
!   and zooplankton consumption:
!==========================================================
REAL*8,PARAMETER :: RredO = 467D0/4D0/16D0 ![PO2], 0.2121
REAL*8,PARAMETER :: o2sat = 0.2121D0       ![O2,SAT] mol/m3 from calc_oxsat(25+273,35) in matlab. WOCE clim-avg surf T at 10S, E. Pac.
!deep oxygen relaxation
REAL*8,PARAMETER :: o2satdeep = 0.2D0      ![O2,SAT_DEEP], mol/m3, avg (for ~7 C) and 35
REAL*8,PARAMETER :: t_o2relax = 1D-2       !<-1D-2(11/27)  !{1D-2}[O2,LATRAL]1/day

!------------------
! sinking velocity
!------------------
INTEGER,PARAMETER :: constantW = 1
! method 1: constant
REAL*8,PARAMETER :: Ws = 10D0      ! m/day (range is 1-100)
! method 2: depth/temperature depended
REAL*8,PARAMETER :: ta = 0.07D0    ! 0.13, 0.07,  0.03
REAL*8,PARAMETER :: tb = 1.71D0    ! 1.48, 1.71, 2.15
REAL*8,PARAMETER :: tc = -23.87D0  ! -27.38, -23.87, -24.46
REAL*8,PARAMETER :: v0 = 10D0      ! sinking rate at surface, i.e. the maximum sinking rate

!*****************************************************************************
! POM--DOM , define this process to simulate the POM-consuming Het explicitly
!*****************************************************************************
!REAL*8,PARAMETER :: alpha = 0.5D0     ! 1D0/.5D0: the percent of POM lost to DOM via extracellular hydrol/"sloppy consuming"
REAL*8,PARAMETER :: mortf = 0D0     ! {0.5}, [fm], fraction of dead biomass to DOM vs to POM (if 0, all to POM)
REAL*8,PARAMETER :: fp = 0.8D0        ! {0.8}, [fp], fraction of phytoplankton growth, the remains are exudation, fp-->Phy, (1-fp) -- >DON

!===================================
! Define parameters for calculation
!===================================
INTEGER :: t,mlboxes,j,i,jc,ind
REAL*8 :: zm(nz) = (/(j,j=0+dz/2,Hp-dz/2, dz)/)
REAL*8 :: z(nz+1) = (/(j,j=0,Hp, dz)/)
REAL*8 :: koverh, adv, diff, cputime,Iin
REAL*8,DIMENSION(:),ALLOCATABLE :: time, burial
REAL*8,DIMENSION(:,:),ALLOCATABLE :: sumall
REAL*8,DIMENSION(nz+1) :: wd, Kz, KzO, w, KzP
REAL*8,DIMENSION(nz+4) :: eqmask,inmask,Iz
CHARACTER(len=5) :: varname

!-----------------
! for Chl:C model
!-----------------
REAL*8,DIMENSION(nz+4) :: a_Ip2, a_Ip3, a_I2, a_I3
REAL*8,DIMENSION(nz+4) :: chl2c,chl2c_p1,chl2c_p2,chl2c_p3,Chlt
REAL*8,DIMENSION(nz+4) :: PC1,PCmax1,PC2,PCmax2,PC3,PCmax3

!-----------------
! P: Phytoplankton
!-----------------
REAL*8,DIMENSION(nz+4) :: p1,xp1,p2,xp2,p3,xp3
REAL*8,DIMENSION(nz+4) :: kp1A,kp1B,kp1C,kp1D,p1A,p1B,p1C
REAL*8,DIMENSION(nz+4) :: kxp1A,kxp1B,kxp1C,kxp1D,xp1A,xp1B,xp1C
REAL*8,DIMENSION(nz+4) :: kp2A,kp2B,kp2C,kp2D,p2A,p2B,p2C
REAL*8,DIMENSION(nz+4) :: kxp2A,kxp2B,kxp2C,kxp2D,xp2A,xp2B,xp2C
REAL*8,DIMENSION(nz+4) :: kp3A,kp3B,kp3C,kp3D,p3A,p3B,p3C
REAL*8,DIMENSION(nz+4) :: kxp3A,kxp3B,kxp3C,kxp3D,xp3A,xp3B,xp3C
REAL*8,DIMENSION(nz+4) :: u_p1,u_p2,u_p3,u_p3nolim
REAL*8,DIMENSION(nz+4) :: pt,ptsq
REAL*8,DIMENSION(nz+4) :: no3uptakeP,no2emitP

!--------------
! Z: Zooplankton
!--------------
REAL*8,DIMENSION(nz+4) :: zoo,zoo2,zoo3
REAL*8,DIMENSION(nz+4) :: kzooA,kzooB,kzooC,kzooD,zooA,zooB,zooC
REAL*8,DIMENSION(nz+4) :: kzoo2A,kzoo2B,kzoo2C,kzoo2D,zoo2A,zoo2B,zoo2C
REAL*8,DIMENSION(nz+4) :: kzoo3A,kzoo3B,kzoo3C,kzoo3D,zoo3A,zoo3B,zoo3C
REAL*8,DIMENSION(nz+4) :: gbio,gbio2,gbio3

!----------------------
! BACTERIA METABOLISMS
!----------------------
! 1. Aerobic Heterotroph(bHet);2. Ammonia oxidizer(bAoo, AOO);3. Nitrite oxidizer (bNoo, NOO)
REAL*8,DIMENSION(nz+4) :: bo,bo_pa,bnh4,bno2
REAL*8,DIMENSION(nz+4) :: kboA,kboB,kboC,kboD,boA,boB,boC
REAL*8,DIMENSION(nz+4) :: kbo_paA,kbo_paB,kbo_paC,kbo_paD,bo_paA,bo_paB,bo_paC
REAL*8,DIMENSION(nz+4) :: kbnh4A,kbnh4B,kbnh4C,kbnh4D,bnh4A,bnh4B,bnh4C
REAL*8,DIMENSION(nz+4) :: kbno2A,kbno2B,kbno2C,kbno2D,bno2A,bno2B,bno2C
REAL*8,DIMENSION(nz+4) :: limbnh4,limbno2 !different n lims for the b
REAL*8,DIMENSION(nz+4) :: limdetr, limdon
REAL*8,DIMENSION(nz+4) :: bt,btsq
REAL*8,DIMENSION(nz+4) :: u_bo,u_bo_pa,u_bnh4,u_bno2
REAL*8,DIMENSION(nz+4) :: pbnh4,pbno2

!----------
! DIN & O2
!----------
REAL*8,DIMENSION(nz+4) :: nh4,no2,no3,ntot,o
REAL*8,DIMENSION(nz+4) :: knh4A,knh4B,knh4C,knh4D,nh4A,nh4B,nh4C
REAL*8,DIMENSION(nz+4) :: kno2A,kno2B,kno2C,kno2D,no2A,no2B,no2C
REAL*8,DIMENSION(nz+4) :: kno3A,kno3B,kno3C,kno3D,no3A,no3B,no3C
REAL*8,DIMENSION(nz+4) :: koA,koB,koC,koD,oA,oB,oC
REAL*8,DIMENSION(nz+4) :: limnh4p2,limno2p2,limno3p2,nlimtotp2 !inhibnh4,  explicit limits to ease equations later
REAL*8,DIMENSION(nz+4) :: limnh4p3,limno2p3,limno3p3,nlimtotp3   !different n lims for the b and p3
REAL*8,DIMENSION(nz+4) :: pnh4,pno2,pno3,po

!-----------
! Organic N
!-----------
REAL*8,DIMENSION(nz+4) :: d,dom
REAL*8,DIMENSION(nz+4) :: kdA,kdB,kdC,kdD,dA,dB,dC
REAL*8,DIMENSION(nz+4) :: kdomA,kdomB,kdomC,kdomD,domA,domB,domC
REAL*8,DIMENSION(nz+4) :: pd,pdon,porg
REAL*8,DIMENSION(nz+4) :: morttotal

!------
! Temp
!------
REAL*8,DIMENSION(nz+4) :: Temp,TempFun,TempFunP !Q10r

!------------------
! Sinking velocity
!------------------
REAL*8,DIMENSION(nz+4) :: v_inc, dv_inc, v
REAL*8 :: v_inc_0

!--------------------
! Exported variables
!--------------------
REAL*8,DIMENSION(nz+4) :: p3diff, p2diff, knh4diff,kno2diff,kno3diff, dsinking
REAL*8,DIMENSION(nz+4) :: knh4zoo,knh4_hetp,knh4_hetd,knh4_het,knh4_nh4oxid,P3uptakeNH4,P2uptakeNH4
REAL*8,DIMENSION(nz+4) :: kno2_nh4oxid,kno2_no2oxid,kno2_p3use,kno2_p2use
REAL*8,DIMENSION(nz+4) :: kno3_no2oxid,P3uptakeNO3,P2uptakeNO3, P3uptakeNO2,P2uptakeNO2
REAL*8,DIMENSION(nz+4) :: p3growth,p2growth,p3mortality,p2mortality,p3grazed,p2grazed
REAL*8,DIMENSION(nz+4) :: nh4tt_1, nh4tt_2, no2tt_1, no2tt_2, no3tt_1, no3tt_2

!================
! run preparing
!================
! print
PRINT*,'Run for total n of days:';PRINT*,ndays
PRINT*,'1D version'
PRINT*,'nz is:'; PRINT*,nz
PRINT*,'Number of days:'
PRINT*, ndays
PRINT*,'Number of timesteps:'
PRINT*, nt

!-------------------
! initial variables
!-------------------
CALL INITIAL_VARS()
!--------------------
! create mask files
!--------------------
inmask(:)=0D0
inmask(3:nz+2)=1D0 !mask to zero out ghost cells for tracers and other quantities affecting tracers

!-----------------------------
! grid numbers in mixed layer
!-----------------------------
! mlboxes=100D0/dz !discrete n of boxes in the mixed layer, close to 100m total sum
mlboxes=mlz/dz

! mask for air-sea equilibration
eqmask(:)=0D0
eqmask(3:mlboxes+2)=1D0; !mask for air-sea equilibration

!--------------------------
! Load initial conditions
!--------------------------
IF (startSS.eq.1) THEN
    CALL LOAD_INITIAL()
ELSE
        !!Initial Conditions from simple distributions (may break now bc of steep gradients):
    nh4(:)=0.05D-3
    nh4(1:2)=1D-4
    no2(:)=0.05D-3
    bo(:)=inmask*2D-4
    bo_pa(:)=inmask*2D-4
    bnh4(:)=inmask*0.12D-12! inmask*1D-7% one AOO cell % assumed that 1 cell/L
    bno2(:)=inmask*1.2D-12! inmask*1D-7%one NOO cell %assume that 1 cell/L
    p1(:)=inmask*1D-7
    p2(:)=inmask*0.68D-12  
    p3(:)=inmask*0.68D-12 !cell quota of Pro is estimated to be 0.68 fmol N per cell, thus 1 cell/L here
    !p3(2)=1D-7
    !p3(1)=0D0

    o(:)=0.2D0!inmask*0.2D0 !mol/m3 crude estimate 
    zoo(:)=inmask*1D-6
    zoo2(:)=inmask*1D-6
    zoo3(:)=inmask*2D-5
    
    !no3(3:nz+2)=0.03D0*(1D0-exp(-(zm+300D0)/200D0)) ! n increases with depth
    !no3(:)=250D-6
    !no3(:)=0.03D0
    OPEN(UNIT=3,FILE='ICfiles/no3_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (no3(J),J=1,nz+4)
    !print*, no3
    CLOSE(3)
    
    d(:) = 0D0 !start with none
    dom(:) = 0D0
END IF

! ecotypes of P and Z
if (onep.eq.1) then
    !take out p1 and p2:
    p1(:)=0D0
    p2(:)=0D0
else if (onep.eq.2) then
    p1(:)=0D0 
end if
!take out zoo and zoo2
zoo(:)=0D0
zoo2(:)=0D0
!zoo3(:)=0D0
!
!---------------------
! Create Output files
!---------------------
!
OPEN(UNIT=5,FILE='time_record.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
CLOSE(5)

IF (recordDaily.eq.1) THEN
    CALL CREATE_MOVIE_FILES()
END IF
!
!=========
! running
!=========
!
!--------------------
! Physical variables
!--------------------
!
!---------------------------------------------------------------
! 1. Temperature: T(z) = 12*exp(z/150) + 12*exp(z/500) + 2
!    Temperature effect: rT = tau*exp(AE*(1/(T+273.15) - 1/T0))
!---------------------------------------------------------------
Temp(:) = 0D0 
Temp(3:nz+2) = 12D0*exp(-zm/150D0)+12D0*exp(-zm/500D0)+2D0
TempFun = TempCoeffArr*exp(TempAeArr*(1D0/(Temp+Tkel)-1D0/TemprefArr))
TempFunP = TempCoeffArr*exp(TempAeArrP*(1D0/(Temp+Tkel)-1D0/TemprefArr))

!-------------------------------------------------
! 2. sinking velocity for detritus
!-------------------------------------------------
IF (constantW .eq. 1) THEN
    wd(:) = Ws
ELSE
    v_inc_0 = ta*Temp(3)*Temp(3) + tb*Temp(3) +tc
    v_inc = ta*Temp*Temp + tb*Temp + tc
    dv_inc = v_inc - v_inc_0
    v = v0 + v0*dv_inc/100D0
    wd = v(2:nz+2)
    !v[v<=0.1] = 0.1
END IF
wd(1)=0D0
wd(nz+1)=0D0
!1D model: no advection for other tracers
w(:)=0D0
wd=wd+w; !vertical velocity combination for detritus

!-----------------------------------------------------------------------------------------------
! 3. Diffusion:
!      the mixed layer was imposed by varying the vertical diffusion coefficient KZ with depth,
!      from a maximum Kmax at the surface to a minimum Kmin with a length scale of zmld
!-----------------------------------------------------------------------------------------------
Kz = (kappazmax*exp(-z/mlz)+kappazmin+kappazmax*exp((z-H)/100D0))*3600D0*24D0 !larger at bottom boundary, too
KzO = Kz
KzP = Kz
KzO(1) = 0D0
!for an open boundary: a sink for oxygen:
!KzO(nz+1)=(kappazmin+1D-2*exp((H-H)/100D0))*3600D0*24D0
!for a closed boundary: a fixed o2
KzO(nz+1) = 0D0
Kz(1) = 0D0
Kz(nz+1) = 0D0
!Kz=coeffKz*Kz

!-----------------------------------------------------------------------
! 4. gas transfer coefficient for each of the n boxes comprising the ml
!-----------------------------------------------------------------------

koverh = Kgast/100D0/mlboxes *3600D0*24D0 !gas transfer coefficient for each of the n boxes comprising the ml

!============
! Time loop
!============
PRINT *,'Starting time loop:'
PRINT *,'--------------------------------------'
DO t = 1,nt
!-----------------------------------------------------
! Iin: Incoming irradiance
!-----------------------------------------------------
    IF (dailycycle.eq.1) THEN !Incoming light daily cycle:
        Iin=Iinmax/2D0*(cos(t*dt*2D0*3.1416D0)+1D0) !note-- this is wrong -- see other code
    ELSE !No daily cycle:
        Iin=Iinmax/2D0
    END IF
    
!------------------------------------------------------
! Tchl(z): sum of the concentrations of chlorophyll
!------------------------------------------------------
    Chlt=(p1*chl2c_p1+p2*chl2c_p2+p3*chl2c_p3)*6.6D0 !molN/m3 *gChl/molC *6.6molC/molN = gChl
    
!------------------------------------------------------
! Light energy: I(z) = Iin*exp(-z(kw+M(Tchl(z)*kchl)))
!                      kw = 1/euz
!------------------------------------------------------
    DO j=1,nz
        Iz(j+2)=Iin*exp(-zm(j)*(1/euz + sum(Chlt(3:j+2)*a_chlD))) !this one sums the k at each depth
    END DO
    
!-------------------------------------------------
! water column integration
!-------------------------------------------------

    i=dayint2*1000
    j=t*dt*1000

    IF (MOD(j,i).eq.0) THEN
        !trace the integral:
        ind=t*dt/dayint2
        time(ind)=(t-1)*dt
        ntot=nh4+no2+no3

        sumall(ind,1)=sum(p1)*dz
        sumall(ind,2)=sum(p2)*dz
        sumall(ind,3)=sum(p3)*dz
        sumall(ind,4)=sum(zoo)*dz
        sumall(ind,5)=sum(zoo2)*dz
        sumall(ind,6)=sum(zoo3)*dz
        sumall(ind,7)=sum(bo)*dz
        sumall(ind,8)=sum(bo_pa)*dz
        sumall(ind,9)=sum(bnh4)*dz
        sumall(ind,10)=sum(bno2)*dz
        sumall(ind,11)=sum(o)*dz !mol/m3 times volume (with dx=1,dy=1)
        sumall(ind,12)=sum(d)*dz
        sumall(ind,13)=sum(dom)*dz
        sumall(ind,14)=sum(nh4)*dz
        sumall(ind,15)=sum(no2)*dz
        sumall(ind,16)=sum(no3)*dz
        sumall(ind,17)=sum(ntot)*dz
    END IF


    CALL MYRK(nh4,no3,no2,d,dom,o,zoo,zoo2,zoo3,p1,xp1,p2,xp2,p3,xp3, &
        bo,bo_pa,bnh4,bno2, &
        knh4A,kno3A,kno2A,kdA,kdomA,koA,kzooA,kzoo2A,kzoo3A, &
        kp1A,kxp1A,kp2A,kxp2A,kp3A,kxp3A, &
        kboA,kbo_paA,kbnh4A,kbno2A, &
        nh4A,no3A,no2A,dA,domA,oA,zooA,zoo2A,zoo3A, &
        p1A,xp1A,p2A,xp2A,p3A,xp3A, &
        boA,bo_paA,bnh4A,bno2A)

    ! ** get yA:
    nh4A = nh4 + dt/2D0*knh4A; 
    no2A = no2 + dt/2D0*kno2A; 
    no3A = no3 + dt/2D0*kno3A; 
    boA = bo + dt/2D0*kboA; 
    bo_paA = bo_pa + dt/2D0*kbo_paA;
    bnh4A = bnh4 + dt/2D0*kbnh4A; 
    bno2A = bno2 + dt/2D0*kbno2A; 
    dA = d + dt/2D0*kdA; 
    domA = dom + dt/2D0*kdomA; 
    oA = o + dt/2D0*koA; 
    zooA = zoo + dt/2D0*kzooA; 
    zoo2A = zoo2 + dt/2D0*kzoo2A; 
    zoo3A = zoo3 + dt/2D0*kzoo3A; 
    p1A = p1 + dt/2D0*kp1A;
    p2A = p2 + dt/2D0*kp2A;
    p3A = p3 + dt/2D0*kp3A;

    CALL MYRK(nh4A,no3A,no2A,dA,domA,oA,zooA,zoo2A,zoo3A,p1A,xp1A,p2A,xp2A,p3A,xp3A, &
        boA,bo_paA,bnh4A,bno2A, &
        knh4B,kno3B,kno2B,kdB,kdomB,koB,kzooB,kzoo2B,kzoo3B, &
        kp1B,kxp1B,kp2B,kxp2B,kp3B,kxp3B, &
        kboB,kbo_paB,kbnh4B,kbno2B, &
        nh4B,no3B,no2B,dB,domB,oB,zooB,zoo2B,zoo3B, &
        p1B,xp1B,p2B,xp2B,p3B,xp3B, &
        boB,bo_paB,bnh4B,bno2B)

    ! ** get yB:
    nh4B = nh4 + dt/2D0*knh4B; 
    no2B = no2 + dt/2D0*kno2B; 
    no3B = no3 + dt/2D0*kno3B; 
    boB = bo + dt/2D0*kboB; 
    bo_paB = bo_pa + dt/2D0*kbo_paB; 
    bnh4B = bnh4 + dt/2D0*kbnh4B; 
    bno2B = bno2 + dt/2D0*kbno2B; 
    dB = d + dt/2D0*kdB; 
    domB = dom + dt/2D0*kdomB; 
    oB = o + dt/2D0*koB; 
    zooB = zoo + dt/2D0*kzooB; 
    zoo2B = zoo2 + dt/2D0*kzoo2B; 
    zoo3B = zoo3 + dt/2D0*kzoo3B; 
    p1B = p1 + dt/2D0*kp1B;
    p2B = p2 + dt/2D0*kp2B;
    p3B = p3 + dt/2D0*kp3B;


    CALL MYRK(nh4B,no3B,no2B,dB,domB,oB,zooB,zoo2B,zoo3B,p1B,xp1B,p2B,xp2B,p3B,xp3B, &
        boB,bo_paB,bnh4B,bno2B, &
        knh4C,kno3C,kno2C,kdC,kdomC,koC,kzooC,kzoo2C,kzoo3C, &
        kp1C,kxp1C,kp2C,kxp2C,kp3C,kxp3C, &
        kboC,kbo_paC,kbnh4C,kbno2C, &
        nh4C,no3C,no2C,dC,domC,oC,zooC,zoo2C,zoo3C, &
        p1C,xp1C,p2C,xp2C,p3C,xp3C, &
        boC,bo_paC,bnh4C,bno2C)

    ! ** get yC:
    nh4C = nh4 + dt*knh4C; 
    no2C = no2 + dt*kno2C; 
    no3C = no3 + dt*kno3C; 
    boC = bo + dt*kboC; 
    bo_paC = bo_pa + dt*kbo_paC; 
    bnh4C = bnh4 + dt*kbnh4C; 
    bno2C = bno2 + dt*kbno2C; 
    dC = d + dt*kdC; 
    domC = dom + dt/2D0*kdomC; 
    oC = o + dt*koC; 
    zooC = zoo + dt*kzooC; 
    zoo2C = zoo2 + dt*kzoo2C; 
    zoo3C = zoo3 + dt*kzoo3C; 
    p1C = p1 + dt*kp1C;
    p2C = p2 + dt*kp2C;
    p3C = p3 + dt*kp3C;

    CALL MYRK(nh4C,no3C,no2C,dC,domC,oC,zooC,zoo2C,zoo3C,p1C,xp1C,p2C,xp2C,p3C,xp3C, &
        boC,bo_paC,bnh4C,bno2C, &
        knh4D,kno3D,kno2D,kdD,kdomD,koD,kzooD,kzoo2D,kzoo3D, &
        kp1D,kxp1D,kp2D,kxp2D,kp3D,kxp3D, &
        kboD,kbo_paD,kbnh4D,kbno2D, &
        nh4A,no3A,no2A,dA,domA,oA,zooA,zoo2A,zoo3A, &
        p1A,xp1A,p2A,xp2A,p3A,xp3A, &
        boA,bo_paA,bnh4A,bno2A)

    nh4 = nh4 + dt/6D0*(knh4A + 2D0*knh4B + 2D0*knh4C + knh4D);
    no2 = no2 + dt/6D0*(kno2A + 2D0*kno2B + 2D0*kno2C + kno2D);
    no3 = no3 + dt/6D0*(kno3A + 2D0*kno3B + 2D0*kno3C + kno3D);
    bo = bo + dt/6D0*(kboA + 2D0*kboB + 2D0*kboC + kboD);
    bo_pa = bo_pa + dt/6D0*(kbo_paA + 2D0*kbo_paB + 2D0*kbo_paC + kbo_paD);
    bnh4 = bnh4 + dt/6D0*(kbnh4A + 2D0*kbnh4B + 2D0*kbnh4C + kbnh4D);
    bno2 = bno2 + dt/6D0*(kbno2A + 2D0*kbno2B + 2D0*kbno2C + kbno2D);
    d = d + dt/6D0*(kdA + 2D0*kdB + 2D0*kdC + kdD);
    dom = dom + dt/6D0*(kdomA + 2D0*kdomB + 2D0*kdomC + kdomD);
    o = o + dt/6D0*(koA + 2D0*koB + 2D0*koC + koD);
    zoo = zoo + dt/6D0*(kzooA + 2D0*kzooB + 2D0*kzooC + kzooD);
    zoo2 = zoo2 + dt/6D0*(kzoo2A + 2D0*kzoo2B + 2D0*kzoo2C + kzoo2D);
    zoo3 = zoo3 + dt/6D0*(kzoo3A + 2D0*kzoo3B + 2D0*kzoo3C + kzoo3D);
    if (onep.eq.0) then
        p1 = p1 + dt/6D0*(kp1A + 2D0*kp1B + 2D0*kp1C + kp1D);
    end if
    p2 = p2 + dt/6D0*(kp2A + 2D0*kp2B + 2D0*kp2C + kp2D);
    p3 = p3 + dt/6D0*(kp3A + 2D0*kp3B + 2D0*kp3C + kp3D);

!
!======================
! Write Output files
!======================

!------------------
! Output for movie
!------------------
    !if (recordDaily.eq.1) then
    IF ((MOD(t*dt,dayfa).eq.0).AND.(recordDaily.eq.1)) THEN
        CALL SAVE_MOVIE_FILES()
    END IF

!----------------------
! Output for all time
!----------------------
    IF (MOD(t*dt,1.00).eq.0) THEN
        OPEN(UNIT=7,FILE='time_record.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
        WRITE(7,*) (t*dt)
        CLOSE(7)
    END IF

!-----------------------
! Output for last data
!-----------------------
    IF ((MOD(t*dt,dayint).eq.0).OR.(t*dt.eq.ndays)) THEN
        PRINT*, int(t*dt)
        ! PRINT*, 'DOM',dom(3)
        PRINT*, p3(3)
        
        CALL SAVE_LAST_DATA()
    END IF  !end the mod
END DO !!end time loop

PRINT*,'Total CPU time in seconds:'
CALL CPU_TIME(cputime)
PRINT*,cputime

CONTAINS


!********************
!  Advection module
!********************
SUBROUTINE MYQUICK(C,w,j,dz,nz,adv)
implicit none
REAL*8 :: C(nz+4),w(nz+1),adv
REAL*8 :: wp1,wn1,wp,wn,Dy1,Dy2,Dyn1,Fu,Fd
INTEGER :: j,nz,dz
INTEGER :: jc
    jc=j+2
    !at top face:
    wp1=(w(j+1)+abs(w(j+1)))/2D0;
    wn1=(w(j+1)-abs(w(j+1)))/2D0;
    !at bottom face:
    wp=(w(j)+abs(w(j)))/2D0;
    wn=(w(j)-abs(w(j)))/2D0;
        
    Dy1=C(jc+2)-2D0*C(jc+1)+C(jc);
    Dy2=C(jc+1)-2D0*C(jc)+C(jc-1);
    Dyn1=C(jc)-2D0*C(jc-1)+C(jc-2);

    Fu=w(j+1)/2D0*(C(jc)+C(jc+1)) - wp1/8D0*Dy2 - wn1/8D0*Dy1;
    Fd=w(j)/2D0*(C(jc-1)+C(jc)) - wp/8D0*Dyn1 - wn/8D0*Dy2;
            
    adv=(Fu-Fd)/dz;  
        
END SUBROUTINE MYQUICK


!*********************
!  Diffusion module
!*********************
SUBROUTINE MYDIFF(C,Kz,j,dz,nz,diff)
implicit none
REAL*8 :: C(nz+4),Kz(nz+1),diff
REAL*8 :: Fu,Fd
INTEGER :: j,nz,dz
INTEGER :: jc
    jc=j+2        
    Fu=Kz(j+1)*(C(jc+1)-C(jc))/dz;
    Fd=Kz(j)*(C(jc)-C(jc-1))/dz;            
    diff=(Fu-Fd)/dz;        
END SUBROUTINE MYDIFF


!********************
!  Ecosystem module
!********************
SUBROUTINE MYRK(nh4_one,no3_one,no2_one,d_one,dom_one,o_one, &
    zoo_one,zoo2_one,zoo3_one, &
    p1_one,xp1_one,p2_one,xp2_one,p3_one,xp3_one, &
    bo_one,bo_pa_one,bnh4_one,bno2_one, &
    knh4_two,kno3_two,kno2_two,kd_two,kdom_two,ko_two, &
    kzoo_two,kzoo2_two,kzoo3_two, &
    kp1_two,kxp1_two,kp2_two,kxp2_two,kp3_two,kxp3_two, &
    kbo_two,kbo_pa_two,kbnh4_two,kbno2_two, &
    nh4_two,no3_two,no2_two,d_two,dom_two,o_two, &
    zoo_two,zoo2_two,zoo3_two, &
    p1_two,xp1_two,p2_two,xp2_two,p3_two,xp3_two, &
    bo_two,bo_pa_two,bnh4_two,bno2_two)
    
IMPLICIT NONE
REAL*8, dimension(nz+4), intent(in) :: nh4_one,no3_one,no2_one,d_one,dom_one,o_one, &
    zoo_one,zoo2_one,zoo3_one,p1_one,xp1_one,p2_one,xp2_one,p3_one,xp3_one, &
    bo_one,bo_pa_one,bnh4_one,bno2_one
REAL*8, dimension(nz+4), intent(out) :: knh4_two,kno3_two,kno2_two,kd_two, &
    kdom_two,ko_two,kzoo_two,kzoo2_two,kzoo3_two, &
    kp1_two,kxp1_two,kp2_two,kxp2_two,kp3_two,kxp3_two, &
    kbo_two,kbo_pa_two,kbnh4_two,kbno2_two, &
    nh4_two,no3_two,no2_two,d_two,dom_two,o_two, &
    zoo_two,zoo2_two,zoo3_two, &
    p1_two,xp1_two,p2_two,xp2_two,p3_two,xp3_two, &
    bo_two,bo_pa_two,bnh4_two,bno2_two

do j=1,nz ; jc=j+2;       
call mydiff(nh4_one,Kz,j,dz,nz,diff)
knh4_two(jc)=diff
call mydiff(no2_one,Kz,j,dz,nz,diff)
kno2_two(jc)=diff
call mydiff(no3_one,Kz,j,dz,nz,diff)
kno3_two(jc)=diff
call mydiff(bo_one,Kz,j,dz,nz,diff)
kbo_two(jc)=diff
!call myquick(bo_pa_one,wd,j,dz,nz,adv)
call mydiff(bo_pa_one,Kz,j,dz,nz,diff)
kbo_pa_two(jc)=diff
!kbo_pa_two(jc)=-adv+diff
call mydiff(bnh4_one,Kz,j,dz,nz,diff)
kbnh4_two(jc)=diff
call mydiff(bno2_one,Kz,j,dz,nz,diff)
kbno2_two(jc)=diff
call myquick(d_one,wd,j,dz,nz,adv)
call mydiff(d_one,Kz,j,dz,nz,diff)
kd_two(jc)=-adv+diff
call mydiff(dom_one,Kz,j,dz,nz,diff)
kdom_two(jc)=diff
call mydiff(o_one,KzO,j,dz,nz,diff)
ko_two(jc)=diff
call mydiff(zoo_one,Kz,j,dz,nz,diff)
kzoo_two(jc)=diff
if (onep.eq.0) then
call mydiff(p1_one,Kz,j,dz,nz,diff)
kp1_two(jc)=diff
call mydiff(xp1_one,Kz,j,dz,nz,diff)
kxp1_two(jc)=diff
end if
call mydiff(p2_one,Kz,j,dz,nz,diff)
kp2_two(jc)=diff
call mydiff(xp2_one,Kz,j,dz,nz,diff)
kxp2_two(jc)=diff
call mydiff(p3_one,Kz,j,dz,nz,diff)
kp3_two(jc)=diff
call mydiff(xp3_one,Kz,j,dz,nz,diff)
kxp3_two(jc)=diff
call mydiff(zoo2_one,Kz,j,dz,nz,diff)
kzoo2_two(jc)=diff
call mydiff(zoo3_one,Kz,j,dz,nz,diff)
kzoo3_two(jc)=diff
end do


!==================================================
! Phytoplankton
!
! Phytoplankton growth:
!    grow as as a function of
!    1. limitation by nutrients [rN],
!    2. limitation by light [rI].
!
!==================================================
!
!--------------------------------------------------
! 1. Limitation by nutrients [rN]
!    nutrients uptake limitations for phytoplankton
!    =rN (equ. 21)
!--------------------------------------------------
!phytopl uptake and growth rate:
!inhibnh4 = exp(-amminhib*nh4_one) !from GUD
!
!  P3: uptake NOX
!
! limnh4p2=(nh4_one/(nh4_one+knh4p2))!*TempFun
! limno2p2=(no2_one/(no2_one+kno2p2))!*TempFun
! limno3p2=(no3_one/(no3_one+kno3p2))!*TempFun
! nlimtotp2=limnh4p2+limno2p2+limno3p2

do j=1,nz;jc=j+2;
    if (nh4_one(jc) <= conlim.and. no2_one(jc) <= conlim) then
        if (no3_one(jc) <= conlim) then
            limnh4p3(jc)=0D0
            limno2p3(jc)=0D0
            limno3p3(jc)=0D0
            nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
        else
            limnh4p3(jc)=0D0
            limno2p3(jc)=0D0
            limno3p3(jc)=(no3_one(jc)/(no3_one(jc)+kno3p3))
            nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
        end if
        else if (nh4_one(jc) <= conlim .and. no2_one(jc) > conlim) then
            if (no3_one(jc) <= conlim) then
                limnh4p3(jc)=0D0
                limno2p3(jc)=(no2_one(jc)/(no2_one(jc)+kno2p3))
                limno3p3(jc)=0D0
                nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
            else
                limnh4p3(jc)=0D0
                limno2p3(jc)=(no2_one(jc)/(no2_one(jc)+kno2p3))
                limno3p3(jc)=(no3_one(jc)/(no3_one(jc)+kno3p3))
                nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
        end if
        else if (nh4_one(jc) > conlim .and. no2_one(jc) > conlim) then
            if (no3_one(jc) <= conlim) then
                limnh4p3(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p3))
                limno2p3(jc)=(no2_one(jc)/(no2_one(jc)+kno2p3))
                limno3p3(jc)=0D0
                nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
            else
                limnh4p3(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p3))
                limno2p3(jc)=(no2_one(jc)/(no2_one(jc)+kno2p3))
                limno3p3(jc)=(no3_one(jc)/(no3_one(jc)+kno3p3))
                nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
            end if
        else if (nh4_one(jc) > conlim .and. no2_one(jc) <= conlim) then
            if (no3_one(jc) <= conlim) then
                limnh4p3(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p3))
                limno2p3(jc)=0D0
                limno3p3(jc)=0D0
                nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
            else
                limnh4p3(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p3))
                limno2p3(jc)=0D0
                limno3p3(jc)=(no3_one(jc)/(no3_one(jc)+kno3p3))
                nlimtotp3(jc)=max(0D0,limnh4p3(jc)+limno2p3(jc)+limno3p3(jc))
            end if
    end if
end do

!-----------------
!  P2: uptake NH4
!-----------------
! limnh4p3=(nh4_one/(nh4_one+knh4p3))!*TempFun
! limno2p3=(no2_one/(no2_one+kno2p3))!*TempFun
! limno3p3=(no3_one/(no3_one+kno3p3))!*TempFun
! nlimtotp3=limnh4p3+limno2p3+limno3p3
do j=1,nz;jc=j+2;
    if (nh4_one(jc) <= conlim .and. no2_one(jc) <= conlim) then
            if (no3_one(jc) <= conlim) then
            limnh4p2(jc)=0D0
            limno2p2(jc)=0D0
            limno3p2(jc)=0D0
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        else
            limnh4p2(jc)=0D0
            limno2p2(jc)=0D0
            limno3p2(jc)=(no3_one(jc)/(no3_one(jc)+kno3p2))
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        end if
    else if (nh4_one(jc) <= conlim .and. no2_one(jc) > conlim) then
        if (no3_one(jc) <= conlim) then
            limnh4p2(jc)=0D0
            limno2p2(jc)=(no2_one(jc)/(no2_one(jc)+kno2p2))
            limno3p2(jc)=0D0
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        else
            limnh4p2(jc)=0D0
            limno2p2(jc)=(no2_one(jc)/(no2_one(jc)+kno2p2))
            limno3p2(jc)=(no3_one(jc)/(no3_one(jc)+kno3p2))
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        end if
    else if (nh4_one(jc) > conlim .and. no2_one(jc) > conlim) then
        if (no3_one(jc) <= conlim) then
            limnh4p2(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p2))
            limno2p2(jc)=(no2_one(jc)/(no2_one(jc)+kno2p2))
            limno3p2(jc)=0D0
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        else
            limnh4p2(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p2))
            limno2p2(jc)=(no2_one(jc)/(no2_one(jc)+kno2p2))
            limno3p2(jc)=(no3_one(jc)/(no3_one(jc)+kno3p2))
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        end if
    else if (nh4_one(jc) > conlim .and. no2_one(jc) <= conlim) then
        if (no3_one(jc) <= conlim) then
            limnh4p2(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p2))
            limno2p2(jc)=0D0
            limno3p2(jc)=0D0
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        else
            limnh4p2(jc)=(nh4_one(jc)/(nh4_one(jc)+knh4p2))
            limno2p2(jc)=0D0
            limno3p2(jc)=(no3_one(jc)/(no3_one(jc)+kno3p2))
            nlimtotp2(jc)=max(0D0,limnh4p2(jc)+limno2p2(jc)+limno3p2(jc))
        end if
    end if
end do

!------------------------------------------------------------------------------------------------------
! 2. Limitation by light [rI]
!    Light limitation was parameterized using
!    an exponential form as a function of
!    2.1 the instantaneous photosynthetic rate (r)
!    2.2 and the Chl a to Carbon ratio (theta)
!-------------------------------------------------------------------------------------------------------

!-------------------------------------------------------------------------------------------------------
! 2.1 Instantaneous photosynthetic rate, [r] (equ. 19)
!       r=phi*a*I(z)  for equation for rI
!       phi_max: the maximum quantum yield of carbon fixation
!       a_chlp2: the absorption of light by phytoplankton
!       Iz: photosynthetically active radiation
!--------------------------------------------------------------------------------------------------------
!a_Ip3 = phimax*a_chlp3*Iz*convI !mmol C/(molEin) * m2/(mg.Chl) * W/m2 * 1/(W day/molEin) = mol C/g Chl/d
a_I2 = phimax2*a_chl*Iz*convI    !mmol C/mol Ein * m2/mg chla * Ein/m2/d = mmol C/mg chla/d
a_I3 = phimax3*a_chl*Iz*convI 

!-------------------------------------------------------
! 2.2 Chl to Carbon ratio, [theta] (equ. 20)
!       the Chl:C varies with photoacclimation
!       computed using a steady-state solution
!       theta = theta_max/(1+theta_max*r/2*(umax*rN*rT))
!-------------------------------------------------------

!    PCmax = umax*rT*rN: 1/d*[]*[] = 1/d

!PCmax2 = umaxp2*TempFun*min(1D0,nlimtotp2)
!PCmax3 = umaxp3*TempFun*min(1D0,nlimtotp3)
PCmax1 = max(1D0*umaxp2*TempFun*nlimtotp2,1D-38)
PCmax2 = max(1D0*umaxp2*TempFun*nlimtotp2,1D-38)!min(1D0,limnh4+limno2)
PCmax3 = max(1D0*umaxp3*TempFun*nlimtotp3,1D-38)

!    theta = theta_max/(1+theta_max*r/2*(umax*rN*rT)) : [g Chl/mol C]/(1+[molC/gChl/d]*[g Chl/mol C]/[1/ d]) = gChl/molC

! units
! chl2c_p1 = 0D0!max(chl2cmin, min(chl2cmax, chl2cmax/(1D0+chl2cmax*a_I/2D0/PCmax1)))
! chl2c_p2 = max(chl2cmin, min(chl2cmax, chl2cmax/(1D0 + a_Ip2*chl2cmax/2D0/PCmax2)))*inmask
! chl2c_p3 = max(chl2cmin, min(chl2cmax, chl2cmax/(1D0 + a_Ip3*chl2cmax/2D0/PCmax3)))*inmask
!chl2c = chl2c_p3
chl2c_p1 = max(chl2cmin, min(chl2cmax, chl2cmax/(1D0+chl2cmax*a_I2/2D0/PCmax1)))
chl2c_p2 = max(chl2cmin, min(chl2cmax, chl2cmax/(1D0+chl2cmax*a_I2/2D0/PCmax2)))
chl2c_p3 = max(chl2cmin, min(chl2cmax, chl2cmax/(1D0+chl2cmax*a_I3/2D0/PCmax3)))
chl2c = chl2c_p3

!-------------------------------------------------
! 3. Phytoplankton growth, [up] (equ. 18)
!    u_p = umax*rT*rN(1-exp(-r*theta/umax*rT*rN))
!       =  PCmax(1-exp(-r*theta/PCmax))
!-------------------------------------------------
! units:[1/d]*[molC/gChl/d]*[gChl/molC]/[1/d] = 1/d
! PC1 = PCmax1*(1D0 - exp(-a_I*chl2c_p1/PCmax1))
! PC2 = PCmax2*(1D0 - exp(-a_Ip2*chl2c_p2/PCmax2))
! PC3 = PCmax3*(1D0 - exp(-a_Ip3*chl2c_p3/PCmax3))
! u_p2=umaxp2*TempFun*min(Iz/(Iz+kI),limnh4p2+limno2p2+limno3p2)!*exp(-Iz*.01D0) !multiply by 0.9 for penalty?
! u_p1=0D0!PC1
! u_p2=PC2   ! uP, NOx
! u_p3=PC3   ! uP, NH4

PC1 = PCmax1*(1D0 - exp(-a_I2*chl2c_p1/PCmax1))
PC2 = PCmax2*(1D0 - exp(-a_I2*chl2c_p2/PCmax2))
PC3 = PCmax3*(1D0 - exp(-a_I3*chl2c_p3/PCmax3))

PC3(nz+2:nz+4)=0D0
PC3(1:2)=0D0
PC2(nz+2:nz+4)=0D0
PC2(1:2)=0D0
PC1(nz+2:nz+4)=0D0
PC1(1:2)=0D0

u_p1=PC1
u_p2=PC2
u_p3=PC3

!-------------------------------------------------
! Phytoplankton Equations:
!-------------------------------------------------
! Total Phytoplankton biomass

pt=p1_one+p2_one+p3_one

! parameters rather than phytoplankton
!-------------------------------------------------
!   (a)bacteria total biomass
!-------------------------------------------------

 bt=bo_one+bo_pa_one+bnh4_one+bno2_one !@DON

!-------------------------------------------------
!   (b)Zooplankton grazing: type II
!      equ. 25: g=gmax*rT/(Kg+(P+Bhet+BAOO+BNOO))
!      gbio3 = g*(bTot+pTot)
!-------------------------------------------------
!grazing: type II
! gbio = g*biomass = gmax*rT/(Kg+(P+Bhet+BAOO+BNOO))*(P+Bhet+BAOO+BNOO)
gbio=0D0!gmax*bt/(bt+kg)*TempFun !for zoo
gbio2=0D0!gmax*pt/(pt+kg)*TempFun !for zoo2
gbio3=gmax*(bt+pt)/(bt+pt+kg)*TempFun !for zoo3 (goal: ONLY this one)

! Equations: P(up-mB-gZ) --> P(up-mB*rT-gZ*(bTot+pTot)/(bTot+pTot+1D-38)))

kp1_two = kp1_two &                                
        + p1_one*(fp*u_p1 &                                         ! P*up --> P*up*fp2DON                      
        - mlin2*TempFun - mquad*p1_one*TempFun &                    ! P*mB
        - gbio2*zoo2_one/(pt+1D-38) - gbio3*zoo3_one/(bt+pt+1D-38)) ! P*g*Z = P*gbio*Z/(bTot+pTot+1D-38)

kp2_two = kp2_two &
        + p2_one*(fp*u_p2 &                                         ! P*up --> P*up*fp2DON
        - mlin2*TempFun - mquad*p2_one*TempFun &                    ! P*mB
        - gbio2*zoo2_one/(pt+1D-38) - gbio3*zoo3_one/(bt+pt+1D-38)) ! P*g*Z --> P*gbio*Z*/(bTot+pTot+1D-38)

kp3_two = kp3_two &
        + p3_one*(fp*u_p3 &                                         ! P*up --> P*up*fp2DON
        - mlin3*TempFun - mquad*p3_one*TempFun &                    ! P*mB --> P*mB*rT + P*P*mB2*rT
        - gbio2*zoo2_one/(pt+1D-38) - gbio3*zoo3_one/(bt+pt+1D-38)) ! P*g*Z --> P*gbio*Z*/(bTot+pTot+1D-38)


!==========================================================
! Zooplankton
!==========================================================
!----------------------------------------------------------
! Equations:    zeta*g*z(P+Bhet+BAOO+BNOO) - mz*Z*Z
!            -->zeta*g*z(P+Bhet+BAOO+BNOO) - mz*Z*Z*rT
!----------------------------------------------------------
!gbio3=gmax*(bt+pt)/(bt+pt+kg)*TempFun
kzoo_two=kzoo_two + gam*gbio*zoo_one - mz*zoo_one*zoo_one*TempFun
kzoo2_two=kzoo2_two + gam*gbio2*zoo2_one - mz*zoo2_one*zoo2_one*TempFun

kzoo3_two=kzoo3_two &
        + gam*gbio3*zoo3_one &                ! zeta*gbio3*zoo3_one=zeta*gmax*(bt+pt)/(bt+pt+kg)*TempFun*zoo
        - mz*zoo3_one*zoo3_one*TempFun        ! mz*Z*Z --> mz*Z*Z*rT


!==========================================================
! Bacteria
!==========================================================
!-------------------------------------------------
! heterotrophic bacteria (Bhet)
!-------------------------------------------------

! uptake limitations for bacteria/archaea:

! (a) uO2 = VmaxO2*O2*rT :[m3/mol/day]*[mol/m3]*[] = 1/d
po=po_coef*o_one*TempFun
    
    
! (b) uPON = VmaxD*PON*rT/(PON+KD)
pdon=pd_max*(dom_one/(dom_one+kdon))*TempFun   ! DOM-consuming Het: pdon=pd_max*(don_one/(don_one+kd))*TempFun 
pd=pd_max*(d_one/(d_one+kd))*TempFun         ! POM-consuming Het

! (c) uHet = yD*uPON = yD*VmaxD*D*rT/(D+KD)  !--> uHet = min(uHet, uO2)
u_bo=min(po*yo_bo,pdon*ydon_bo)                ! u_bo=min(po*yo_bo,pd*yd_bo)
u_bo_pa=min(po*yo_bo_pa,pd*yd_bo_pa)

! Equation: --> Bhet(uhet-mB*rT-gZ*(bTot+pTot)/(bTot+pTot+1D-38)))
! related to DON
kbo_two= kbo_two &       
        + bo_one*(u_bo &                                          ! Bhet*uhet        
        - mlin*TempFun - mquad*bo_one*TempFun &                   ! Bhet*mB --> Bhet*mB*rT + Bhet*Bhet*mB2*rT
        - gbio*zoo_one/(bt+1D-38) - gbio3*zoo3_one/(bt+pt+1D-38)) ! Bhet*g*Z: gbio3=g*(bTot+pTot)
 

kbo_pa_two= kbo_pa_two &
         + bo_pa_one*(u_bo_pa &                                    ! Bhet*uhet  
         - mlin*TempFun - mquad*bo_pa_one*TempFun &                ! Bhet*mB --> Bhet*mB*rT + Bhet*Bhet*mB2*rT
         - gbio*zoo_one/(bt+1D-38) - gbio3*zoo3_one/(bt+pt+1D-38)) ! Bhet*g*Z: gbio3=g*(bTot+pTot)


!-------------------------------------------------
! ammonia-oxidizing organisms (AOO)
!-------------------------------------------------
! Equation --> uNH4 = VmaxNH4*NH4/(NH4+KNH4) -->  uNH4 = VmaxNH4*NH4/(NH4+KNH4)*rT
! now with no Temp: Horak 2013
! Equation --> limbnh4=(nh4_one/(nh4_one+kn))!*TempFun
! Equation --> pbnh4=pn_max*limbnh4*TempFun

limbnh4=(nh4_one/(nh4_one+kn*(1+exp(kna*log10(Iz)+knb))))!*TempFun
pbnh4=pn_max*max((1-pna*Iz),0D0)*limbnh4


! Equation --> uAOO = yD*uNH4 = yNH4*VmaxNH4*NH4/(NH4+KNH4) --> uAOO = min(uAOO, uO2)
! Equation --> u_bnh4=min(pbnh4*ynh4_bnh4,po*yo_bnh4)

u_bnh4=max(min(pbnh4*ynh4_bnh4,po*yo_bnh4),0D0)

! Equation --> BAOO(uAOO-mB*rT-gZ*(bTot+pTot)/(bTot+pTot+1D-38)))
kbnh4_two= kbnh4_two &
            + bnh4_one*(u_bnh4 &                                       ! BAOO*uAOO
            - mlin*TempFun - mquad*bnh4_one*TempFun &                  ! BAOO*mB --> BAOO*mB*rT
            - gbio*zoo_one/(bt+1D-38) - gbio3*zoo3_one/(bt+pt+1D-38))  ! BAOO*g*Z: gbio3=g*(bTot+pTot)
!
!-------------------------------------------------
! nitrite-oxidizing organisms(NOO)
!-------------------------------------------------

! Equation --> uNO2 = VmaxNO2*NO2/(NO2+KNO2)
! Equation --> uNO2 = VmaxNO2*NO2/(NO2+KNO2)*rT 
! now with no Temp: Horak 2013
! Equation --> limbno2=(no2_one/(no2_one+kn_noo))!*TempFun
! Equation --> pbno2=pn_max_noo*limbno2*TempFun
limbno2=(no2_one/(no2_one+kn_noo*(1+exp(kn_nooa*log10(Iz)+kn_noob))))!*TempFun
pbno2=pn_max_noo*max((1-pn_nooa*Iz),0D0)*limbno2


! Equation --> uNOO = yN2O*uNO2 = yN2O*VmaxNO2*NO2/(NO2+KNO2)  --> uNOO = min(uNOO, uO2)
u_bno2=min(pbno2*yno2_bno2,po*yo_bno2)


! Equation --> BNOO(uNOO-mB*rT-gZ*(bTot+pTot)/(bTot+pTot+1D-38)))
kbno2_two= kbno2_two &
            + bno2_one*(u_bno2 &                                      ! BNOO*uNOO
            - mlin*TempFun - mquad*bno2_one*TempFun &                 ! BNOO*mB --> BNOO*mB*rT
            - gbio*zoo_one/(bt+1D-38) - gbio3*zoo3_one/(bt+pt+1D-38)) ! BNOO*g*Z: gbio3=g*(bTot+pTot)
!============
! DIN & O2
!============
!------------
! NH4
!------------
! Equation --> gbio3=[gmax*TempFun/(bt+pt+kg)]*(bt+pt)= g*(bt+pt)
knh4_two = knh4_two &
            + enh4_bo*u_bo*bo_one &                   ! (1/yD-1)*uhet*Bhet 
            + enh4_bo*u_bo_pa*bo_pa_one &             ! 2 aerobic hets @DON
            + (1D0-gam)*gbio*zoo_one &
            + (1D0-gam)*gbio2*zoo2_one  &
            + (1D0-gam)*gbio3*zoo3_one &              ! Grazing excretation: (1-)gZ(P+BHet+BAOO+BNOO); gbio3=g*(bTot+pTot)
            - 1D0/ynh4_bnh4*u_bnh4*bnh4_one &         ! NH4 oxidizer consumption: 1/yNH4*uAOO*BAOO
            - u_p1*p1_one & 
            - u_p2*p2_one*limnh4p2/(nlimtotp2+1D-38) &
            - u_p3*p3_one*limnh4p3/(nlimtotp3+1D-38)  ! VNH4*P = up*P*rN = up*P*(NH4/(NH4+KNH4)/(NH4/(NH4+KNH4)+exp(a*NH4)*NO2/(NO2+KNO2)+exp(a*NH4)*NO3/(NO3+KNO3)))

!-------
! NO2
!-------
kno2_two = kno2_two &
            + eno2_bnh4*u_bnh4*bnh4_one &              ! source: NH4 oxidize, (1/yNH4-1)*uAOO*BAOO
            - 1D0/yno2_bno2*u_bno2*bno2_one &          ! sink: aerobic NO2 oxidizer, 1/yN2O*uNOO*BNOO
            - u_p2*p2_one*limno2p2/(nlimtotp2+1D-38) & ! sink: p consumption VNO2*P = up*P*(exp(a*NH4)*NO2/(NO2+KNO2)/(NH4/(NH4+KNH4)+exp(a*NH4)*NO2/(NO2+KNO2)+exp(a*NH4)*NO3/(NO3+KNO3)))
            - u_p3*p3_one*limno2p3/(nlimtotp3+1D-38) 
            
!-------
! NO3
!-------
kno3_two = kno3_two &
            + eno3_bno2*u_bno2*bno2_one & ! source: aerobic NO2 oxidizer, (1/yNO2-1)*uNOO*BNOO                     
            - u_p2*p2_one*limno3p2/(nlimtotp2+1D-38) & ! no3uptakeP, VNO3P = up*P*(exp(a*NH4)*NO3/(NO3+KNO3)/(NH4/(NH4+KNH4)+exp(a*NH4)*NO2/(NO2+KNO2)+exp(a*NH4)*NO3/(NO3+KNO3)))
            - u_p3*p3_one*limno3p3/(nlimtotp3+1D-38)
            
!------
! O2
!------
ko_two = ko_two &
        + RredO*(u_p1*p1_one + u_p2*p2_one + u_p3*p3_one) &  !pp production
        - RredO*(1D0-gam)*gbio*zoo_one &
        - RredO*(1D0-gam)*gbio2*zoo2_one &
        - RredO*(1D0-gam)*gbio3*zoo3_one &   !zoo use
        - 1D0/yo_bo*u_bo*bo_one &            !het B use
        - 1D0/yo_bo*u_bo_pa*bo_pa_one &
        - 1D0/yo_bnh4*u_bnh4*bnh4_one &      !NH4 oxid use
        - 1D0/yo_bno2*u_bno2*bno2_one &      !NO2 oxid use
        + koverh*(o2sat-o_one)*eqmask &      !air-sea
        + t_o2relax*(o2satdeep-o_one)*inmask !relaxation at depth (lateral flux)

!=======
! PON
!=======
ptsq=p1_one**2 + p2_one**2 + p3_one**2
btsq=bo_one**2 + bo_pa_one**2 + bnh4_one**2 + bno2_one**2  !@DON
! Equation --> btsq=bo_one**2 + bnh4_one**2 + bno2_one**2
! Equation --> mB*(P + Bhet + BAOO + BNOO) --> mB*(P+Bhet+BAOO+BNOO)*rT
! morttotal = mlin*(bt+pt) &
!             ! mB2*(P^2 + Bhet^2 + BAOO^2 + BNOO^2)*rT
!             + mquad*(btsq+ptsq) &
!             ! mZ*Z*Z --> mZ*Z*Z*rT        !quadratic
!             + mz*zoo_one*zoo_one &
!             + mz*zoo2_one*zoo2_one &
!             + mz*zoo3_one*zoo3_one
! kd_two= kd_two &
!         ! morf-->DON; 1-morf-->PON
!         + (1D0-mortf)*morttotal*TempFun

morttotal = (mlin*bt + mlin2*p2_one + mlin3*p3_one & 
            + mquad*(btsq+ptsq) & 
            + mz*zoo_one*zoo_one &
            + mz*zoo2_one*zoo2_one &
            + mz*zoo3_one*zoo3_one)*TempFun ! quadratic --> mZ*Z*Z*rT 

kd_two = kd_two &
        + (1D0-mortf)*morttotal &           ! mortf --> DON; 1-mortf --> PON
        !- 1D0/yd_bo*u_bo*bo_one &          ! 1/yD*uhet*Bhet
        - 1D0/yd_bo_pa*u_bo_pa*bo_pa_one       ! sink POM-consuming heterophy 

! kd_two= kd_two &
!       + mlin*bt*TempFun &
!         + (mlin2*p2_one+mlin3*p3_one)*TempFun &
!       + mquad*(btsq+ptsq)*TempFun &
!       + mz*zoo_one*zoo_one*TempFun &!quadratic
!       + mz*zoo2_one*zoo2_one*TempFun &!quadratic
!       + mz*zoo3_one*zoo3_one*TempFun & !quadratic
!       - 1D0/yd_bo*u_bo*bo_one !sink: 1 heterotroph

!======
! DON
!======
kdom_two = kdom_two &
         + mortf*morttotal &     ! morf-->DON; 1-morf-->PON
         !+ 1D0/yd_bo*u_bo_pa*bo_pa_one &  !@DON source: the PA bacteria sloppy feeding
         + (1-fp)*p3_one*u_p3 &  ! phytoplankton exduation 
         + (1-fp)*p2_one*u_p2 &
         + (1-fp)*p1_one*u_p1 &
         - 1D0/ydon_bo*u_bo*bo_one ! sink: 1 heterotroph --> 1/yD*uhet*Bhet

!=============
! for output
!=============
!zeta1=0.25*bo_one/(0.25*bo_one+0.25*bnh4_one+0.25*bno2_one+0.25*p3_one)
!zeta2=0.25*bnh4_one/(0.25*bo_one+0.25*bnh4_one+0.25*bno2_one+0.25*p3_one)
!zeta3=0.25*bno2_one/(0.25*bo_one+0.25*bnh4_one+0.25*bno2_one+0.25*p3_one)
!zeta4=0.25*p3_one/(0.25*bo_one+0.25*bnh4_one+0.25*bno2_one+0.25*p3_one)
!gbio3=gmax*(zeta1*bo_one+zeta2*bnh4_one+zeta3*bno2_one+zeta4*p3_one) &
!(zeta1*bo_one+zeta2*bnh4_one+zeta3*bno2_one+zeta4*p3_one+kg)*TempFun
knh4zoo=(1D0-gam)*gbio3*zoo3_one
knh4_hetp=enh4_bo*u_bo_pa*bo_pa_one
knh4_hetd=enh4_bo*u_bo*bo_one
knh4_het=enh4_bo*u_bo*bo_one+enh4_bo*u_bo_pa*bo_pa_one
knh4_nh4oxid=-1D0/ynh4_bnh4*u_bnh4*bnh4_one
kno2_nh4oxid=eno2_bnh4*u_bnh4*bnh4_one
kno2_no2oxid=-1/yno2_bno2*u_bno2*bno2_one
kno2_p3use=-u_p3*p3_one*limno2p3/(nlimtotp3+1D-38)
kno2_p2use=-u_p2*p2_one*limno2p2/(nlimtotp2+1D-38)
kno3_no2oxid=eno3_bno2*u_bno2*bno2_one
P3uptakeNH4=-u_p3*p3_one*limnh4p3/(nlimtotp3+1D-38)
P3uptakeNO2=-u_p3*p3_one*limno2p3/(nlimtotp3+1D-38)
P3uptakeNO3=-u_p3*p3_one*limno3p3/(nlimtotp3+1D-38)
P2uptakeNH4=-u_p2*p2_one*limnh4p2/(nlimtotp2+1D-38)
P2uptakeNO2=-u_p2*p2_one*limno2p2/(nlimtotp2+1D-38)
P2uptakeNO3=-u_p2*p2_one*limno3p2/(nlimtotp2+1D-38)
P3growth=u_p3*p3_one
P2growth=u_p2*p2_one
!nh4tt_1=nh4_one/(enh4_bo*u_bo*bo_one+ (1D0-gam)*gbio3*zoo3_one)
!nh4tt_2=nh4_one/(P3uptakeNH4+P2uptakeNH4+knh4_nh4oxid) 
!no2tt_1=no2_one/kno2_nh4oxid
!no2tt_2=no2_one/(kno2_p3use+kno2_p2use+kno2_no2oxid) !cal the turnovertime of no2 
!no3tt_1=no3_one/(eno3_bno2*u_bno2*bno2_one)
!no3tt_2=no3_one/(P3uptakeNO3+P2uptakeNO3) 

END SUBROUTINE MYRK

!****************************
!  CREATE FILES FOR MOVIE
!****************************

SUBROUTINE CREATE_MOVIE_FILES()

    OPEN(UNIT=5,FILE='time_all.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'p1_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    !CLOSE(5)
    OPEN(UNIT=5,FILE='p2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='p3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'xp1_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'xp2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'xp3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'zoo_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'zoo2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    !CLOSE(5)
    OPEN(UNIT=5,FILE='zoo3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='bo_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='bo_pa_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='bnh4_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='bno2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='nh4_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',STATUS='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='no2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',STATUS='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='no3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',STATUS='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='o_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='d_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='dom_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='chlt_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='Iz_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='Iin.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='up_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='ubo_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='ubnh4_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
    OPEN(UNIT=5,FILE='ubno2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',status='REPLACE')
    CLOSE(5)
END SUBROUTINE CREATE_MOVIE_FILES


!******************************
!  save date for movie files
!******************************
SUBROUTINE SAVE_MOVIE_FILES()
    OPEN(UNIT=7,FILE='time_all.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(7,*) (t*dt)
    CLOSE(7)
    !OPEN(UNIT=5,FILE=outdir//'p1_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    !WRITE(5,*) (p1)
    !CLOSE(5)
    OPEN(UNIT=5,FILE='p2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (p2)
    CLOSE(5)
    OPEN(UNIT=5,FILE='p3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (p3)
    CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'xp1_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    !WRITE(5,*) (xp1)
    !CLOSE(5)
    !add your statement in the same form of xp1 if xp2 and/or xp2 is needed
    OPEN(UNIT=5,FILE='zoo3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (zoo3)
    CLOSE(5)
    OPEN(UNIT=5,FILE='bo_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (bo)
    CLOSE(5)
    OPEN(UNIT=5,FILE='bo_pa_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (bo_pa)
    CLOSE(5)
    OPEN(UNIT=5,FILE='bnh4_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (bnh4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='bno2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (bno2)
    CLOSE(5)
    OPEN(UNIT=5,FILE='nh4_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (nh4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='no2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (no2)
    CLOSE(5)
    OPEN(UNIT=5,FILE='no3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (no3)
    CLOSE(5)
    OPEN(UNIT=5,FILE='d_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (d)
    CLOSE(5)
    OPEN(UNIT=5,FILE='dom_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (dom)
    CLOSE(5)
    OPEN(UNIT=5,FILE='o_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (o)
    CLOSE(5)
    OPEN(UNIT=5,FILE='chlt_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (Chlt)
    CLOSE(5)
    OPEN(UNIT=5,FILE='Iz_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (Iz)
    CLOSE(5)
    OPEN(UNIT=7,FILE='Iin.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(7,*) (Iin)
    CLOSE(7)
    OPEN(UNIT=5,FILE='up1_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (u_p1)
    CLOSE(5)
    OPEN(UNIT=5,FILE='up2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (u_p2)
    CLOSE(5)
    OPEN(UNIT=5,FILE='up3_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (u_p3)
    CLOSE(5)
    OPEN(UNIT=5,FILE='ubo_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (u_bo)
    CLOSE(5)
    OPEN(UNIT=5,FILE='ubnh4_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (u_bnh4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='ubno2_fa.txt',ACCESS='SEQUENTIAL',BLANK='ZERO',POSITION='APPEND')
    WRITE(5,*) (u_bno2)
    CLOSE(5)
END SUBROUTINE SAVE_MOVIE_FILES


!******************************
!  save data for last output
!******************************
SUBROUTINE SAVE_LAST_DATA()
!-----------
! Time & z
!-----------
    OPEN(UNIT=5,FILE='time_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    DO J=1,ind
        WRITE(5,*) (time(J))
    END DO
    CLOSE(5)

    OPEN(UNIT=5,FILE='z_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    DO I=1,nz
        ! WRITE(5,"(*(g0,:,','))") (zm(I))
        WRITE(5,*) (zm(I))
    END DO
    CLOSE(5)
    OPEN(UNIT=5,FILE='sumall_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    DO I=1,ind
        WRITE(5,*) (sumall(I,J),J=1,17)
    END DO
    CLOSE(5)

!-------------------------------------------------
! Phytoplankton
!-------------------------------------------------
    ! OPEN(UNIT=5,FILE=outdir//'p1_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    ! WRITE(5,*) (p1(J),J=1,nz+4)
    ! CLOSE(5)
    OPEN(UNIT=5,FILE='p2_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (p2(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='p3_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (p3(J),J=1,nz+4)
    CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'xp1_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    !WRITE(5,*) (xp1(J),J=1,nz+4)
    !CLOSE(5)
    !the same as xp2 and xp3

!-------------
! Zooplankton
!-------------
    ! OPEN(UNIT=5,FILE=outdir//'zoo_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    ! WRITE(5,*) (zoo(J),J=1,nz+4)
    ! CLOSE(5)
    ! OPEN(UNIT=5,FILE=outdir//'zoo2_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    ! WRITE(5,*) (zoo2(J),J=1,nz+4)
    ! CLOSE(5)
    OPEN(UNIT=5,FILE='zoo3_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (zoo3(J),J=1,nz+4)
    CLOSE(5)

!----------
! Bacteria
!----------
    OPEN(UNIT=5,FILE='bo_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (bo(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='bo_pa_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (bo_pa(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='bnh4_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (bnh4(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='bno2_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (bno2(J),J=1,nz+4)
    CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'ubo_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    !WRITE(5,*) (u_bo(J),J=1,nz+4)
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'ubnh4_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    !WRITE(5,*) (u_bnh4(J),J=1,nz+4)
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'ubno2_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    !WRITE(5,*) (u_bno2(J),J=1,nz+4)
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'up1_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    !WRITE(5,*) (u_p1(J),J=1,nz+4)
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'up2_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    !WRITE(5,*) (u_p2(J),J=1,nz+4)
    !CLOSE(5)
    !OPEN(UNIT=5,FILE=outdir//'up3_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    !WRITE(5,*) (u_p3(J),J=1,nz+4)
    !CLOSE(5)

!------------------
! DIN & OrgN & O2
!------------------
    OPEN(UNIT=5,FILE='nh4_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (nh4(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='no2_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (no2(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='no3_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (no3(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='d_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (d(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='dom_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (dom(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='o_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (o(J),J=1,nz+4)
    CLOSE(5)

!-------
! chlt
!-------
    OPEN(UNIT=5,FILE='chlt_f.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (Chlt(J),J=1,nz+4)
    CLOSE(5)
    ! OPEN(UNIT=5,FILE=outdir//'chl2c_p1.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    ! WRITE(5,*) (chl2c_p1(J),J=1,nz+4)
    ! CLOSE(5)
    OPEN(UNIT=5,FILE='chl2c_p2.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (chl2c_p2(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='chl2c_p3.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (chl2c_p3(J),J=1,nz+4)
    CLOSE(5)
    OPEN(UNIT=5,FILE='Iz.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    WRITE(5,*) (Iz(J),J=1,nz+4)
    CLOSE(5)

!---------
! others
!---------
        if ((MOD(t*dt,dayint).eq.0).OR.(t*dt.eq.ndays)) then
        OPEN(UNIT=6,FILE='knh4zoo.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (knh4zoo(J),J=1,nz+4)
        CLOSE(6)

        OPEN(UNIT=6,FILE='knh4_hetp.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (knh4_hetp(J),J=1,nz+4)
        CLOSE(6)
    
        OPEN(UNIT=6,FILE='knh4_hetd.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (knh4_hetd(J),J=1,nz+4)
        CLOSE(6)

        OPEN(UNIT=6,FILE='knh4_het.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (knh4_het(J),J=1,nz+4)
        CLOSE(6)
    
        OPEN(UNIT=6,FILE='knh4_nh4oxid.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (knh4_nh4oxid(J),J=1,nz+4)
        CLOSE(6)

        !NOTE: using no3uptakeP as a placeholder for recording multiple quantities for N fluxes:
        !diff
        do j=1,nz
            jc=j+2;
            call mydiff(no2,Kz,j,dz,nz,diff)
            no3uptakeP(jc)=diff
        end do
        OPEN(UNIT=5,FILE='kno2_diff.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(5,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(5)

        !source: NH4 oxidizer:
        no3uptakeP=eno2_bnh4*u_bnh4*bnh4
        OPEN(UNIT=5,FILE='kno2_nh4oxid.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(5,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(5)

        !sink: NO2 oxidizer:
        no3uptakeP=-1/yno2_bno2*u_bno2*bno2
        OPEN(UNIT=5,FILE='kno2_no2oxid.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(5,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(5)
        
        !source: phytopl 3 emit:
        OPEN(UNIT=6,FILE='kno2_p3emit.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (no2emitP(J),J=1,nz+4)
        CLOSE(6)

        !also record diffusion of nitrate:
        do j=1,nz ;
            jc=j+2;
            call mydiff(no3,Kz,j,dz,nz,diff)
            no3uptakeP(jc)=diff
        end do
        OPEN(UNIT=5,FILE='kno3_diff.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(5,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(5)

        OPEN(UNIT=6,FILE='kno3_no2oxid.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (kno3_no2oxid(J),J=1,nz+4)
        CLOSE(6)    

        !record the sinking flux of detritus
        do j=1,nz
            jc=j+2;
            call myquick(d,wd,j,dz,nz,adv)
            dsinking(jc)=-adv
        end do
        OPEN(UNIT=5,FILE='dsinking.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(5,*) (dsinking(J),J=1,nz+4)
        CLOSE(5)

        OPEN(UNIT=5,FILE='wd.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(5,*) (wd(J),J=1,nz+1)
        CLOSE(5)

        OPEN(UNIT=5,FILE='kz.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(5,*) (kz(J),J=1,nz+1)
        CLOSE(5)


        no3uptakeP=-u_p3*p3*limno3p3/(nlimtotp3+1D-38)
        OPEN(UNIT=6,FILE='P3uptakeNO3.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(6)
    
        no3uptakeP=-u_p3*p3*limno2p3/(nlimtotp3+1D-38)
        OPEN(UNIT=6,FILE='P3uptakeNO2.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(6)
    
        !nh4 uptake by pp3: (still using no3uptake as placeholder): (this is redundant with above kno2_puse.txt)
        no3uptakeP=-u_p3*p3*limnh4p3/(nlimtotp3+1D-38)
        OPEN(UNIT=6,FILE='P3uptakeNH4.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(6)
    
        no3uptakeP=-u_p2*p2*limno3p2/(nlimtotp2+1D-38)
        OPEN(UNIT=6,FILE='P2uptakeNO3.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(6)
    
        !no2 uptake by pp2: (still using no3uptake as placeholder): (this is redundant with above kno2_puse.txt)
        no3uptakeP=-u_p2*p2*limno2p2/(nlimtotp2+1D-38)
        OPEN(UNIT=6,FILE='P2uptakeNO2.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(6)
    
        !no2 uptake by pp3: (still using no3uptake as placeholder): (this is redundant with above kno2_puse.txt)
        no3uptakeP=-u_p2*p2*limnh4p2/(nlimtotp2+1D-38)
        OPEN(UNIT=6,FILE='P2uptakeNH4.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (no3uptakeP(J),J=1,nz+4)
        CLOSE(6)
    
        !p3growth
        !P3growth=u_p3*p3!*limnh4/(nlimtot+1D-38)
        OPEN(UNIT=6,FILE='P3growth.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (P3growth(J),J=1,nz+4)
        CLOSE(6)
    
        !p3mortality
        !P3mortality=-p3*mlin3*TempFun!*limnh4/(nlimtot+1D-38)
        !OPEN(UNIT=6,FILE='P3mortality.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        !WRITE(6,*) (P3mortality(J),J=1,nz+4)
        !CLOSE(6)
    
        !p3 grazed by zoo
        !P3grazed=-p3*g3*zoo3/(bt+pt+1D-38)!*limnh4/(nlimtot+1D-38)
        !OPEN(UNIT=6,FILE='P3grazed.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        !WRITE(6,*) (P3grazed(J),J=1,nz+4)
        !CLOSE(6)
    
        !p2growth
        !P2growth=u_p2*p2!*limnh4/(nlimtot+1D-38)
        OPEN(UNIT=6,FILE='P2growth.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        WRITE(6,*) (P2growth(J),J=1,nz+4)
        CLOSE(6)
    
        !p2mortality
        !P2mortality=-p2*mlin3*TempFun!*limnh4/(nlimtot+1D-38)
        !OPEN(UNIT=6,FILE='P3mortality.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        !WRITE(6,*) (P3mortality(J),J=1,nz+4)
        !CLOSE(6)
    
        !p2 grazed by zoo
        !P2grazed=-p2*g3*zoo3/(bt+pt+1D-38)!*limnh4/(nlimtot+1D-38)
        !OPEN(UNIT=6,FILE='P3grazed.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
        !WRITE(6,*) (P3grazed(J),J=1,nz+4)
        !CLOSE(6)
    
    
    end if

END SUBROUTINE SAVE_LAST_DATA


!**********************
!  load initial files
!**********************
SUBROUTINE LOAD_INITIAL()
    OPEN(UNIT=3,FILE='nh4_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (nh4(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='no2_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (no2(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='no3_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (no3(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='d_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (d(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='dom_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (d(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='o_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (o(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='bo_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (bo(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='bo_pa_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (bo_pa(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='bnh4_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (bnh4(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='bno2_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (bno2(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='zoo_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (zoo(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='zoo2_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (zoo2(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='zoo3_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (zoo3(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='p1_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (p1(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='p2_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (p2(J),J=1,nz+4)
    CLOSE(3)

    OPEN(UNIT=3,FILE='p3_fSS.txt',ACCESS='SEQUENTIAL',BLANK='ZERO')
    read(3,*) (p3(J),J=1,nz+4)
    CLOSE(3)
END SUBROUTINE LOAD_INITIAL


!*********************
!  initial variables
!*********************
SUBROUTINE INITIAL_VARS()
    !
    !===========
    ! set zero
    !===========
    ! P: phytoplankton
    kp1A(:)=0D0
    kp1B(:)=0D0
    kp1C(:)=0D0
    kp1D(:)=0D0
    
    kp2A(:)=0D0
    kp2B(:)=0D0
    kp2C(:)=0D0
    kp2D(:)=0D0
    
    kp3A(:)=0D0
    kp3B(:)=0D0
    kp3C(:)=0D0
    kp3D(:)=0D0
    
    ! Zoo-plankton:
    kzooA(:)=0D0
    kzooB(:)=0D0
    kzooC(:)=0D0
    kzooD(:)=0D0
    kzoo2A(:)=0D0
    kzoo2B(:)=0D0
    kzoo2C(:)=0D0
    kzoo2D(:)=0D0
    kzoo3A(:)=0D0
    kzoo3B(:)=0D0
    kzoo3C(:)=0D0
    kzoo3D(:)=0D0
    
    ! BACTERIA METABOLISMS:Het(BHet), AOO(BAOO), NOO(BNOO)
    kboA(:)=0D0
    kboB(:)=0D0
    kboC(:)=0D0
    kboD(:)=0D0
    
    kbo_paA(:)=0D0
    kbo_paB(:)=0D0
    kbo_paC(:)=0D0
    kbo_paD(:)=0D0
    
    kbnh4A(:)=0D0
    kbnh4B(:)=0D0
    kbnh4C(:)=0D0
    kbnh4D(:)=0D0
    kbno2A(:)=0D0
    kbno2B(:)=0D0
    kbno2C(:)=0D0
    kbno2D(:)=0D0
    
    ! DIN & O2
    knh4A(:)=0D0
    knh4B(:)=0D0
    knh4C(:)=0D0
    knh4D(:)=0D0
    kno2A(:)=0D0
    kno2B(:)=0D0
    kno2C(:)=0D0
    kno2D(:)=0D0
    kno3A(:)=0D0
    kno3B(:)=0D0
    kno3C(:)=0D0
    kno3D(:)=0D0

    koA(:)=0D0
    koB(:)=0D0
    koC(:)=0D0
    koD(:)=0D0
    
    ! Organic N
    kdA(:)=0D0
    kdB(:)=0D0
    kdC(:)=0D0
    kdD(:)=0D0
    
    kdomA(:)=0D0
    kdomB(:)=0D0
    kdomC(:)=0D0
    kdomD(:)=0D0
    
    ! Others
    
    ALLOCATE(time(nt))
    ALLOCATE(burial(nt+1))
    ind=ndays/dayint2
    ALLOCATE(sumall(ind,17))
END SUBROUTINE INITIAL_VARS
END PROGRAM NECO
