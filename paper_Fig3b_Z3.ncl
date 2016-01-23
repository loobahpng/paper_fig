;
;
;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
;************************************************
; create pointer to file and read in data
;************************************************
  if(.not.isvar("plottype")) then
    ;plottype="timeseries"
    plottype="map"
  end if
    years=50
    varname="Z3"
    autolevs=0
    maxLevel=30.
    minLevel=-30.
    pnew = 500 
  print (" "+varname)
;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5_EXP1/atm/hist/*.nc |head -n 719 |tail -n 360")

;  fils=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_USIrriOnly/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_IndiaIrriOnly/atm/hist/*.nc |head -n 719 |tail -n 360")

  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /scratch/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /work4/L.r02229011/IRR_B_2000_CAM5_IndiaWinterOnly_New/atm/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_f09g16_Ctrl/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_f09g16_IRRI/atm/hist/*.nc |head -n 719 |tail -n 360")

  in=addfiles(fils,"r")
  inExp=addfiles(filsExp,"r")
  ListSetType (in,"cat")
  ListSetType (inExp,"cat")
;----------------------------
  hyam=in[0]->hyam
  hybm=in[0]->hybm
  PS=in[:]->PS
  PSExp=inExp[:]->PS
  P0mb=in[0]->P0*0.01
  ; type of interpolation: 1 = linear, 2 = log, 3 = loglog
  interp = 2 
  ; is extrapolation desired if data is outside the range of PS
  extrap = False

 ; pnew =  (/100,150,200,250,300,400,500,700,850,900/)  

  pnew@units="hpa"
  Var=vinth2p(in[:]->$varname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  VarExp=vinth2p(inExp[:]->$varname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
  
  Var@long_name=in[0]->$varname$@long_name
  Var@units=in[0]->$varname$@units
;  Var(:,:,:,:)=Var(:,:,:,:)*86400.
;  Var@units="K/day"

  VarExp@long_name=in[0]->$varname$@long_name
  VarExp@units=in[0]->$varname$@units
;  VarExp(:,:,:,:)=VarExp(:,:,:,:)*86400.
;  VarExp@units="K/day"
  
  VarAno=Var
  VarAno(:,:,:,:)= VarExp(:,:,:,:) - Var(:,:,:,:) 
  VarAno@long_name=Var@long_name
  VarAno@units=Var@units

  lat = in[0]->lat
  lon = in[0]->lon
  ;printVarSummary(Var)
  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight
  ;printVarSummary(gavg)
;**********************************
  siglvl = 0.1
    ;tavg=dim_avg_n_Wrap(Var(600:1199,:,:),0) ;time avg
    ;tavgExp=dim_avg_n_Wrap(VarExp(600:1199,:,:),0)
vdim=dimsizes(Var)
print(vdim)
t=new((/12,years,vdim(2),vdim(3)/),"float")
t!0="month"
tExp=t
;tavg=new((/12,vdim(1),vdim(2)/,"double")
;tavgExp=tavg
month=1-1
do while (month .le. 11)
    t(month,:,:,:)=Var(0+month:12*years-1:12,0,:,:)
    tExp(month,:,:,:)=VarExp(0+month:12*years-1:12,0,:,:)
;    tavg(month,:,:)=dim_avg_n_Wrap(Var(600+month:1199:12,:,:),0) ;time avg
;    tavgExp(month,:,:)=dim_avg_n_Wrap(VarExp(600+month:1199:12,:,:),0)
;    tavgAno(month,:,:)=dim_avg_n_Wrap(VarAno(600+month:1199:12,:,:),0)
    month=month+1
end do
;  t=runave_n_Wrap(t,3,1,1)
;  tExp=runave_n_Wrap(tExp,3,1,1)
;-------------------
month_plot=0
do while(month_plot.ne.12)
normal_CTR=(/0,2,4,6,7,11,15,16,20,21,22,25,26,27,28,30,32,33,34,37,38,39,43,44,45,46,47,48,49/)
normal_IRR=(/1,2,5,6,7,8,9,10,11,12,15,16,17,18,19,23,25,28,33,34,36,38,39,40,41,42,44,45,46,47/)
nino_CTR=(/3,8,12,13,17,18,23,31,35,40/)
nino_IRR=(/3,13,24,29,32,35,48/)
nina_CTR=(/1,5,9,10,14,19,24,29,36,41,42/)
nina_IRR=(/0,4,14,20,21,22,26,27,30,31,37,43,49/)
allmember=ispan(0,years-1,1)
;
composite_CTR=allmember
composite_IRR=allmember
composite_set="allmember"
;
;composite_CTR=nino_CTR
;composite_IRR=nino_IRR
;composite_set="nino"
;
;composite_CTR=nina_CTR
;composite_IRR=nina_IRR
;composite_set="nina"
;
;composite_CTR=normal_CTR
;composite_IRR=normal_IRR
;composite_set="normal"

  Month=dim_avg_n_Wrap(t(month_plot,composite_CTR,:,:),0)
  MonthExp=dim_avg_n_Wrap(tExp(month_plot,composite_IRR,:,:),0)
  Monthvar = dim_variance_n_Wrap(t(month_plot,composite_CTR,:,:),0)
  MonthvarExp = dim_variance_n_Wrap ( tExp(month_plot,composite_IRR,:,:),0)
  sX   = dimsizes(composite_CTR)        ; X and Y can be of
  sY   = dimsizes(composite_IRR)        ; different sizes
  iflag= False               ; population variance similar
  probMonth=Month ;dimension trick
  probMonth(:,:) = ttest(Month,Monthvar,sX,MonthExp,MonthvarExp,sY, iflag, False) 
  ;print(prob)
  ;if(prob.lt.siglvl) then
    ;tavgAno=dim_avg_n_Wrap(VarAno(600:1199,:,:),0)
    ;VarClima=clmMonTLL(VarAno(600:1199,:,:))
;    JFM=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
    ;JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
    Month =MonthExp-Month
  ;end if
  wksMonth=gsn_open_wks("png","fig/"+varname+"_"+pnew+"_"+month_plot+"_comp_ttest_dot_"+composite_set+"_p="+siglvl)
  gsn_define_colormap(wksMonth,"BlWhRe")
  res   = True               ; plot mods desired
    res@cnFillOn        = True               ; turn on color fill
    res@cnLinesOn       = False              ; turn off contour lines
    res@gsnMaximize     = True
    res@gsnSpreadColors = True               ; use full range of color map
;    res@mpMinLatF       = -10;-30;20
;    res@mpMaxLatF       = 70;60
;    res@mpMinLonF       =100;40;30;230
;    res@mpMaxLonF       = 280;180;150
    res@mpOutlineBoundarySets       = "National"
    res@mpDataSetName = "Earth..4"
    res@mpCountyLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF =5.0
    res@gsnDraw=False
    res@gsnFrame=False
    res@cnLevelSelectionMode ="ManualLevels"
    res@cnMaxLevelValF  = maxLevel
    res@cnMinLevelValF  = minLevel
    res@cnLevelSpacingF = (maxLevel-minLevel)/20.
    res@lbLabelFontHeightF=.02
;res@mpPerimOn            = False
res@mpGridAndLimbOn   = True
res@mpGridLatSpacingF = 30.
res@mpGridLonSpacingF = 30.
;res@mpProjection = "Robinson"
res@mpCenterLonF=150
res@mpCenterLonF=270
;res@gsnLeftString=""
;res@gsnRightString=""
res@mpMinLatF=20
	res@gsnSpreadColors       = False               ; use full range of color map
	res@cnFillPalette = "precip4_diff_19lev"
	res@cnFillPalette = "temp_19lev"
	res@cnFillPalette = "BlWhRe"
	res@cnFillPalette = "MPL_RdBu"
	res@cnSpanFillPalette=True
;    res@mpMinLatF       = 0
;    res@mpMaxLatF       = 40
;    res@mpMinLonF       = 30
;    res@mpMaxLonF       = 130
;    res@mpMinLatF       = -30
;    res@mpMaxLatF       = 60
;    res@mpMinLonF       = 40
;    res@mpMaxLonF       = 120
;    res@cnFillMode           = "RasterFill"
    if (autolevs.eq.1 )then
	symMinMaxPlt(Month,20,False,res)
    end if
    plotMonth=gsn_csm_contour_map(wksMonth,Month,res)
    ressig=True
    ressig@gsnLeftString=""
    ressig@gsnRightString=""
    ressig@gsnDraw=False
    ressig@gsnFrame=False
    ressig@cnInfoLabelOn       = False       ; turn off info label
    ressig@cnLinesOn           = False       ; do not draw contour lines
    ressig@cnLineLabelsOn      = False       ; do not draw contour labels
    ressig@cnLevelSelectionMode ="ManualLevels"
    ressig@cnMaxLevelValF  = 1.
    ressig@cnMinLevelValF  = 0.
    ressig@cnLevelSpacingF = (1.-0.)/20.
    ressig@cnFillScaleF=0.7
    ressig@cnFillDotSizeF=0.002
    plotsig=gsn_csm_contour(wksMonth,probMonth,ressig)
    resdot = True
    resdot@gsnShadeFillType = "pattern"        ; color is the default
    resdot@gsnShadeMid = 17                  ; use color index 14
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotMonth,plotsig)
    draw(plotMonth)
    frame(wksMonth)
month_plot=month_plot+1
end do
;-------------------
  JJA=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/6,7,8/),composite_CTR,:,:),0),0)
  JJAExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/6,7,8/),composite_IRR,:,:),0),0)
  JJAvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/6,7,8/),composite_CTR,:,:),0),0)
  JJAvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/6,7,8/),composite_IRR,:,:),0),0)
  sX   = dimsizes(composite_CTR)        ; X and Y can be of
  sY   = dimsizes(composite_IRR)        ; different sizes
  iflag= False               ; population variance similar
  probJJA=JJA
  probJJA(:,:) = ttest(JJA,JJAvar,sX,JJAExp,JJAvarExp,sY, iflag, False)
  ;print(prob)
  ;if(prob.lt.siglvl) then
    ;tavgAno=dim_avg_n_Wrap(VarAno(600:1199,:,:),0)
    ;VarClima=clmMonTLL(VarAno(600:1199,:,:))
;    JFM=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
    ;JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
    JJA =JJAExp-JJA
  ;end if
;----------------
  SON=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/9,10,11/),composite_CTR,:,:),0),0)
  SONExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/9,10,11/),composite_IRR,:,:),0),0)
  SONvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/9,10,11/),composite_CTR,:,:),0),0)
  SONvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/9,10,11/),composite_IRR,:,:),0),0)
  sX   = dimsizes(composite_CTR)        ; X and Y can be of
  sY   = dimsizes(composite_IRR)        ; different sizes
  iflag= False               ; population variance similar
  probSON=SON
  probSON(:,:) = ttest(SON,SONvar,sX,SONExp,SONvarExp,sY, iflag, False)
  SON =SONExp-SON
;----------------
  MAM=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/3,4,5/),composite_CTR,:,:),0),0)
  MAMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/3,4,5/),composite_IRR,:,:),0),0)
  MAMvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/3,4,5/),composite_CTR,:,:),0),0)
  MAMvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/3,4,5/),composite_IRR,:,:),0),0)
  sX   = dimsizes(composite_CTR)        ; X and Y can be of
  sY   = dimsizes(composite_IRR)        ; different sizes
  iflag= False               ; population variance similar
  probMAM=MAM
  probMAM(:,:) = ttest(MAM,MAMvar,sX,MAMExp,MAMvarExp,sY, iflag, False)
  MAM =MAMExp-MAM
;----------------
  JFM=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/1,2,3/),composite_CTR,:,:),0),0)
  JFMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/1,2,3/),composite_IRR,:,:),0),0)
  JFMvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/1,2,3/),composite_CTR,:,:),0),0)
  JFMvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/1,2,3/),composite_IRR,:,:),0),0)
  sX   = dimsizes(composite_CTR)        ; X and Y can be of
  sY   = dimsizes(composite_IRR)        ; different sizes
  iflag= False               ; population variance similar
  probJFM=JFM
  probJFM(:,:) = ttest(JFM,JFMvar,sX,JFMExp,JFMvarExp,sY, iflag, False)
  JFM =JFMExp-JFM
  ;end if
;************************************************
; create default plot
;************************************************
  ;wks = gsn_open_wks("png","fig/"+varname+"_ctrl_"+plottype)  ; open a wks
  ;wksExp=gsn_open_wks("png","fig/"+varname+"_exp_"+plottype)
;  wksAno=gsn_open_wks ("png","fig/"+(month+1)+"_"+varname+"_comp_"+plottype)
  wksJFM= gsn_open_wks("png","fig/"+varname+"_"+pnew+"_JFMcomp_ttest_dot_"+composite_set)
  wksJJA= gsn_open_wks("png","fig/"+varname+"_"+pnew+"_JJAcomp_ttest_dot_"+composite_set)
  wksSON= gsn_open_wks("png","fig/"+varname+"_"+pnew+"_SONcomp_ttest_dot_"+composite_set)
  wksMAM= gsn_open_wks("png","fig/"+varname+"_"+pnew+"_MAMcomp_ttest_dot_"+composite_set)
  ;gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap
  ;gsn_define_colormap(wksExp,"BlAqGrYeOrRe")        ; choose colormap
;  gsn_define_colormap(wksAno,"BlWhRe")
  gsn_define_colormap(wksJFM,"BlWhRe")
  gsn_define_colormap(wksJJA,"BlWhRe")
  gsn_define_colormap(wksSON,"BlWhRe")
  gsn_define_colormap(wksMAM,"BlWhRe")
    if (autolevs.eq.1 )then
	symMinMaxPlt(JJA,20,False,res)
    end if
    plotJJA=gsn_csm_contour_map(wksJJA,JJA,res)
    ;plotAno=gsn_csm_contour_map(wksAno,tavgAno,res)
    if (autolevs.eq.1 )then
	symMinMaxPlt(JFM,20,False,res)
    end if
    plotJFM=gsn_csm_contour_map_polar(wksJFM,JFM,res)
    if (autolevs.eq.1 )then
	symMinMaxPlt(SON,20,False,res)
    end if
    plotSON=gsn_csm_contour_map(wksSON,SON,res)
    if (autolevs.eq.1 )then
	symMinMaxPlt(MAM,20,False,res)
    end if
    plotMAM=gsn_csm_contour_map(wksMAM,MAM,res)

    plotsig=gsn_csm_contour(wksJFM,probJFM,ressig)
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotJFM,plotsig)
    draw(plotJFM)
    frame(wksJFM)

    plotsig=gsn_csm_contour(wksMAM,probMAM,ressig)
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotMAM,plotsig)
    draw(plotMAM)
    frame(wksMAM)
    plotsig=gsn_csm_contour(wksJJA,probJJA,ressig)
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotJJA,plotsig)
    draw(plotJJA)
    frame(wksJJA)

    plotsig=gsn_csm_contour(wksSON,probSON,ressig)
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotSON,plotsig)
    draw(plotSON)
    frame(wksSON)

  print(" "+varname)
end







;;*************************************************
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;;************************************************
;begin
;;************************************************
;; create pointer to file and read in data
;;************************************************
;  varname="Z3"
;
;  if(.not.isvar("plottype")) then
;    ;plottype="timeseries"
;    plottype="map"
;    
;  end if
;;  print ("plottype= "+plottype)
;  print (" "+varname)
;
;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5/atm/hist/*.nc |head -n 719 |tail -n 360")
;  ;filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5_EXP1/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_USIrriOnly/atm/hist/*.nc |head -n 719 |tail -n 360")
;  in=addfiles(fils,"r")
;  inExp=addfiles(filsExp,"r")
;  ListSetType (in,"cat")
;  ListSetType (inExp,"cat")
;
;;----------------------------
;  hyam=in[0]->hyam
;  hybm=in[0]->hybm
;  PS=in[:]->PS
;  PSExp=inExp[:]->PS
;  P0mb=in[0]->P0*0.01
;  ; type of interpolation: 1 = linear, 2 = log, 3 = loglog
;  interp = 2 
;  ; is extrapolation desired if data is outside the range of PS
;  extrap = False
;
;  pnew =500  
; ; pnew =  (/100,150,200,250,300,400,500,700,850,900/)  
;
;  pnew@units="hpa"
;  Var=vinth2p(in[:]->$varname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
;  VarExp=vinth2p(inExp[:]->$varname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
;  
;  Var@long_name=in[0]->$varname$@long_name
;  Var@units=in[0]->$varname$@units
;;  Var(:,:,:,:)=Var(:,:,:,:)*86400.
;;  Var@units="K/day"
;
;  VarExp@long_name=in[0]->$varname$@long_name
;  VarExp@units=in[0]->$varname$@units
;;  VarExp(:,:,:,:)=VarExp(:,:,:,:)*86400.
;;  VarExp@units="K/day"
;  
;  VarAno=Var
;  VarAno(:,:,:,:)= VarExp(:,:,:,:) - Var(:,:,:,:) 
;  VarAno@long_name=Var@long_name
;  VarAno@units=Var@units
;  printVarSummary(Var)
;
;  lat = in[0]->lat
;  lon = in[0]->lon
;  tt = ispan(1,12*100,1)
;  ;printVarSummary(Var)
;
;  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight
;  ;printVarSummary(gavg)
;;**********************************
;  siglvl = 0.05
;    ;tavg=dim_avg_n_Wrap(Var(600:1199,:,:),0) ;time avg
;    ;tavgExp=dim_avg_n_Wrap(VarExp(600:1199,:,:),0)
;vdim=dimsizes(Var)
;t=new((/12,30,vdim(2),vdim(3)/),"float")
;t!0="month"
;tExp=t
;;tavg=new((/12,vdim(1),vdim(2)/,"double")
;;tavgExp=tavg
;month=1-1
;do while (month .le. 11)
;    t(month,:,:,:)=Var(0+month:359:12,0,:,:)
;    tExp(month,:,:,:)=VarExp(0+month:359:12,0,:,:)
;;    tavg(month,:,:)=dim_avg_n_Wrap(Var(600+month:1199:12,:,:),0) ;time avg
;;    tavgExp(month,:,:)=dim_avg_n_Wrap(VarExp(600+month:1199:12,:,:),0)
;;    tavgAno(month,:,:)=dim_avg_n_Wrap(VarAno(600+month:1199:12,:,:),0)
;    month=month+1
;end do
;;  t=runave_n_Wrap(t,5,1,1)
;;  tExp=runave_n_Wrap(tExp,5,1,1)
;;-------------------
;normal_CTR=(/0,2,4,6,7,11,15,16,20,21,22,25,26,27,28,30,32,33,34,37,38,39,43,44,45,46,47,48,49/)
;normal_IRR=(/1,2,5,6,7,8,9,10,11,12,15,16,17,18,19,23,25,28,33,34,36,38,39,40,41,42,44,45,46,47/)
;nino_CTR=(/3,8,12,13,17,18,23,31,35,40/)
;nino_IRR=(/3,13,24,29,32,35,48/)
;nina_CTR=(/1,5,9,10,14,19,24,29,36,41,42/)
;nina_IRR=(/0,4,14,20,21,22,26,27,30,31,37,43,49/)
;allmember=ispan(0,29,1)
;composite_CTR=allmember
;composite_IRR=allmember
;composite_set="all"
;composite_month="Aug"
;print(composite_CTR)
;
;  Month=dim_avg_n_Wrap(t(8,composite_CTR,:,:),0)
;  MonthExp=dim_avg_n_Wrap(tExp(8,composite_IRR,:,:),0)
;  Monthvar = dim_variance_n_Wrap(t(8,composite_CTR,:,:),0)
;  MonthvarExp = dim_variance_n_Wrap ( tExp(8,composite_IRR,:,:),0)
;  sX   = dimsizes(composite_CTR)        ; X and Y can be of
;  sY   = dimsizes(composite_IRR)        ; different sizes
;  iflag= False               ; population variance similar
;  probMonth=Month ;dimension trick
;  probMonth(:,:) = ttest(Month,Monthvar,sX,MonthExp,MonthvarExp,sY, iflag, False) 
;  ;print(prob)
;  ;if(prob.lt.siglvl) then
;    ;tavgAno=dim_avg_n_Wrap(VarAno(600:1199,:,:),0)
;    ;VarClima=clmMonTLL(VarAno(600:1199,:,:))
;;    JFM=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
;    ;JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
;    Month =MonthExp-Month
;  ;end if
;;-------------------
;  JJA=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/6,7,8/),:,:,:),0),0)
;  JJAExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/6,7,8/),:,:,:),0),0)
;  JJAvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/6,7,8/),:,:,:),0),0)
;  JJAvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/6,7,8/),:,:,:),0),0)
;  sX   = 30        ; X and Y can be of
;  sY   = 30        ; different sizes
;  iflag= False               ; population variance similar
;  probJJA=JJA
;  probJJA(:,:) = ttest(JJA,JJAvar,sX,JJAExp,JJAvarExp,sY, iflag, False)
;  ;print(prob)
;  ;if(prob.lt.siglvl) then
;    ;tavgAno=dim_avg_n_Wrap(VarAno(600:1199,:,:),0)
;    ;VarClima=clmMonTLL(VarAno(600:1199,:,:))
;;    JFM=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
;    ;JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
;    JJA =JJAExp-JJA
;  ;end if
;;----------------
;  SON=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/9,10,11/),:,:,:),0),0)
;  SONExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/9,10,11/),:,:,:),0),0)
;  SONvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/9,10,11/),:,:,:),0),0)
;  SONvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/9,10,11/),:,:,:),0),0)
;  sX   = 30        ; X and Y can be of
;  sY   = 30        ; different sizes
;  iflag= False               ; population variance similar
;  probSON=SON
;  probSON(:,:) = ttest(SON,SONvar,sX,SONExp,SONvarExp,sY, iflag, False)
;  SON =SONExp-SON
;;----------------
;  MAM=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/3,4,5/),:,:,:),0),0)
;  MAMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/3,4,5/),:,:,:),0),0)
;  MAMvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/3,4,5/),:,:,:),0),0)
;  MAMvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/3,4,5/),:,:,:),0),0)
;  sX   = 30        ; X and Y can be of
;  sY   = 30        ; different sizes
;  iflag= False               ; population variance similar
;  probMAM=MAM
;  probMAM(:,:) = ttest(MAM,MAMvar,sX,MAMExp,MAMvarExp,sY, iflag, False)
;  MAM =MAMExp-MAM
;;----------------
;  JFM=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/1,2,3/),:,:,:),0),0)
;  JFMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/1,2,3/),:,:,:),0),0)
;  JFMvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/1,2,3/),:,:,:),0),0)
;  JFMvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/1,2,3/),:,:,:),0),0)
;  sX   = 30        ; X and Y can be of
;  sY   = 30        ; different sizes
;  iflag= False               ; population variance similar
;  probJFM=JFM
;  probJFM(:,:) = ttest(JFM,JFMvar,sX,JFMExp,JFMvarExp,sY, iflag, False)
;  JFM =JFMExp-JFM
;  ;end if
;;************************************************
;; create default plot
;;************************************************
;  ;wks = gsn_open_wks("png","fig/"+varname+"_ctrl_"+plottype)  ; open a wks
;  ;wksExp=gsn_open_wks("png","fig/"+varname+"_exp_"+plottype)
;;  wksAno=gsn_open_wks ("png","fig/"+(month+1)+"_"+varname+"_comp_"+plottype)
;  wksJFM= gsn_open_wks("png","fig/"+varname+pnew+"_JFMcomp_ttest_dot")
;  wksJJA= gsn_open_wks("png","fig/"+varname+pnew+"_JJAcomp_ttest_dot")
;  wksSON= gsn_open_wks("png","fig/"+varname+pnew+"_SONcomp_ttest_dot")
;  wksMAM= gsn_open_wks("png","fig/"+varname+pnew+"_MAMcomp_ttest_dot")
;  wksMonth=gsn_open_wks("png","fig/"+varname+pnew+"_"+composite_month+"comp_ttest_dot_"+composite_set+"_p="+siglvl)
;  ;gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap
;  ;gsn_define_colormap(wksExp,"BlAqGrYeOrRe")        ; choose colormap
;;  gsn_define_colormap(wksAno,"BlWhRe")
;  gsn_define_colormap(wksJFM,"BlWhRe")
;  gsn_define_colormap(wksJJA,"BlWhRe")
;  gsn_define_colormap(wksSON,"BlWhRe")
;  gsn_define_colormap(wksMAM,"BlWhRe")
;  gsn_define_colormap(wksMonth,"BlWhRe")
;  res   = True               ; plot mods desired
;
;    ;20 yrs  9 6 0:1199 50yrs 6 0 0:1199
;
;    ;VarClima=clmMonTLL(VarAno(600:1199,:,:))
;    ;JFM=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
;    ;JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
;
;    res@cnFillOn        = True               ; turn on color fill
;    res@cnLinesOn       = False              ; turn off contour lines
;    res@gsnMaximize     = True
;    res@gsnSpreadColors = True               ; use full range of color map
;;    res@mpMinLatF       = 0;-30;20
;;    res@mpMaxLatF       = 70;60
;;    res@mpMinLonF       =200;40;30;230
;;    res@mpMaxLonF       = 300;180;150
;    res@mpOutlineBoundarySets       = "National"
;    res@mpDataSetName = "Earth..4"
;    res@mpGeophysicalLineThicknessF =1.5
;    res@gsnDraw=False
;    res@gsnFrame=False
;;    res@cnLevelSelectionMode ="ManualLevels"
;;    maxLevel=400.
;;    minLevel=-400.
;;    res@cnMaxLevelValF  = maxLevel
;;    res@cnMinLevelValF  = minLevel
;;    res@cnLevelSpacingF = (maxLevel-minLevel)/20.
;    ;res@mpMinLatF       = 0
;    ;res@mpMaxLatF       = 60
;    ;res@mpMinLonF       = 210
;    ;res@mpMaxLonF       = 300
;    symMinMaxPlt(JJA,20,False,res)
;    plotJJA=gsn_csm_contour_map(wksJJA,JJA,res)
;    ;plotAno=gsn_csm_contour_map(wksAno,tavgAno,res)
;    symMinMaxPlt(JFM,20,False,res)
;    plotJFM=gsn_csm_contour_map(wksJFM,JFM,res)
;    symMinMaxPlt(SON,20,False,res)
;    plotSON=gsn_csm_contour_map(wksSON,SON,res)
;    symMinMaxPlt(MAM,20,False,res)
;    plotMAM=gsn_csm_contour_map(wksMAM,MAM,res)
;    symMinMaxPlt(Month,20,False,res)
;    plotMonth=gsn_csm_contour_map(wksMonth,Month,res)
;    ressig=True
;    ressig@gsnLeftString=""
;    ressig@gsnRightString=""
;    ressig@gsnDraw=False
;    ressig@gsnFrame=False
;    ressig@cnInfoLabelOn       = False       ; turn off info label
;    ressig@cnLinesOn           = False       ; do not draw contour lines
;    ressig@cnLineLabelsOn      = False       ; do not draw contour labels
;    ressig@cnLevelSelectionMode ="ManualLevels"
;    maxLevel=1.
;    minLevel=0.
;    ressig@cnMaxLevelValF  = maxLevel
;    ressig@cnMinLevelValF  = minLevel
;    ressig@cnLevelSpacingF = (maxLevel-minLevel)/20.
;    ressig@cnFillScaleF=0.7
;    ressig@cnFillDotSizeF=0.002
;    plotsig=gsn_csm_contour(wksMonth,probMonth,ressig)
;    resdot = True
;    resdot@gsnShadeFillType = "pattern"        ; color is the default
;    resdot@gsnShadeMid = 17                  ; use color index 14
;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;    overlay(plotMonth,plotsig)
;    draw(plotMonth)
;    frame(wksMonth)
;
;    plotsig=gsn_csm_contour(wksJFM,probJFM,ressig)
;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;    overlay(plotJFM,plotsig)
;    draw(plotJFM)
;    frame(wksJFM)
;
;    plotsig=gsn_csm_contour(wksMAM,probMAM,ressig)
;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;    overlay(plotMAM,plotsig)
;    draw(plotMAM)
;    frame(wksMAM)
;    plotsig=gsn_csm_contour(wksJJA,probJJA,ressig)
;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;    overlay(plotJJA,plotsig)
;    draw(plotJJA)
;    frame(wksJJA)
;
;    plotsig=gsn_csm_contour(wksSON,probSON,ressig)
;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;    overlay(plotSON,plotsig)
;    draw(plotSON)
;    frame(wksSON)
;
;  print(" "+varname)
;;;-------------------
;;  JJA=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/6,7,8/),:,:,:),0),0)
;;  JJAExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/6,7,8/),:,:,:),0),0)
;;  JJAvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/6,7,8/),:,:,:),0),0)
;;  JJAvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/6,7,8/),:,:,:),0) ,0)
;;  sX   = 30        ; X and Y can be of
;;  sY   = 30        ; different sizes
;;  iflag= False               ; population variance similar
;;  probJJA = ttest(JJA,JJAvar,sX,JJAExp,JJAvarExp,sY, iflag, False) 
;;  ;print(prob)
;;  ;if(prob.lt.siglvl) then
;;    ;tavgAno=dim_avg_n_Wrap(VarAno(600:1199,:,:),0)
;;    ;VarClima=clmMonTLL(VarAno(600:1199,:,:))
;;;    JFM=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
;;    ;JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
;;    JJA =where(probJJA .gt. siglvl,t@_FillValue,JJAExp-JJA)
;;  ;end if
;;;----------------
;;  SON=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/9,10,11/),:,:,:),0),0)
;;  SONExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/9,10,11/),:,:,:),0),0)
;;  SONvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/9,10,11/),:,:,:),0),0)
;;  SONvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/9,10,11/),:,:,:),0) ,0)
;;  sX   = 30        ; X and Y can be of
;;  sY   = 30        ; different sizes
;;  iflag= False               ; population variance similar
;;  probSON = ttest(SON,SONvar,sX,SONExp,SONvarExp,sY, iflag, False) 
;;  SON =where(probSON .gt. siglvl,t@_FillValue,SONExp-SON)
;;;----------------
;;  MAM=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/3,4,5/),:,:,:),0),0)
;;  MAMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/3,4,5/),:,:,:),0),0)
;;  MAMvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/3,4,5/),:,:,:),0),0)
;;  MAMvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/3,4,5/),:,:,:),0) ,0)
;;  sX   = 30        ; X and Y can be of
;;  sY   = 30        ; different sizes
;;  iflag= False               ; population variance similar
;;  probMAM = ttest(MAM,MAMvar,sX,MAMExp,MAMvarExp,sY, iflag, False) 
;;  MAM =where(probMAM .gt. siglvl,t@_FillValue,MAMExp-MAM)
;;;----------------
;;  JFM=dim_avg_n_Wrap(dim_avg_n_Wrap(t((/1,2,3/),:,:,:),0),0)
;;  JFMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/1,2,3/),:,:,:),0),0)
;;  JFMvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/1,2,3/),:,:,:),0),0)
;;  JFMvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/1,2,3/),:,:,:),0) ,0)
;;  sX   = 30        ; X and Y can be of
;;  sY   = 30        ; different sizes
;;  iflag= False               ; population variance similar
;;  probJFM = ttest(JFM,JFMvar,sX,JFMExp,JFMvarExp,sY, iflag, False) 
;;  JFM =where(probJFM .gt. siglvl,t@_FillValue,JFMExp-JFM)
;;  ;end if
;;;************************************************
;;; create default plot
;;;************************************************
;;  ;wks = gsn_open_wks("png","fig/"+varname+"_ctrl_"+plottype)  ; open a wks
;;  ;wksExp=gsn_open_wks("png","fig/"+varname+"_exp_"+plottype)
;;;  wksAno=gsn_open_wks ("png","fig/"+(month+1)+"_"+varname+"_comp_"+plottype)
;;  wksJFM= gsn_open_wks("png","fig/"+varname+"_JFMcomp_ttest")
;;  wksJJA= gsn_open_wks("png","fig/"+varname+"_JJAcomp_ttest")
;;  wksSON= gsn_open_wks("png","fig/"+varname+"_SONcomp_ttest")
;;  wksMAM= gsn_open_wks("png","fig/"+varname+"_MAMcomp_ttest")
;;  wksMonth= gsn_open_wks("png","fig/"+varname+pnew+"_"+composite_month+"comp_ttest_dot_"+composite_set+"_p="+siglvl)
;;  ;gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap
;;  ;gsn_define_colormap(wksExp,"BlAqGrYeOrRe")        ; choose colormap
;;;  gsn_define_colormap(wksAno,"BlWhRe")
;;  gsn_define_colormap(wksJFM,"BlWhRe")
;;  gsn_define_colormap(wksJJA,"BlWhRe")
;;  gsn_define_colormap(wksSON,"BlWhRe")
;;  gsn_define_colormap(wksMAM,"BlWhRe")
;;  gsn_define_colormap(wksMonth,"BlWhRe")
;;  res	= True               ; plot mods desired
;;
;;  if (plottype .eq. "map") then
;;    ;20 yrs  9 6 0:1199 50yrs 6 0 0:1199
;;
;;    ;VarClima=clmMonTLL(VarAno(600:1199,:,:))
;;    ;JFM=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
;;    ;JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
;;
;;    res@cnFillOn	= True               ; turn on color fill
;;    res@cnLinesOn	= False              ; turn off contour lines
;;    res@gsnMaximize	= True
;;    res@gsnSpreadColors       = True               ; use full range of color map
;;;    res@mpMinLatF       = 0;-30;20
;;;    res@mpMaxLatF       = 70;60
;;;    res@mpMinLonF       =200;40;30;230
;;;    res@mpMaxLonF       = 300;180;150
;;    res@mpOutlineBoundarySets       = "National"
;;    res@mpDataSetName = "Earth..4"
;;    res@mpGeophysicalLineThicknessF =1.5
;;    res@gsnDraw=False
;;    res@gsnFrame=False
;;
;;
;;    ;plot = gsn_csm_contour_map(wks,tavg,res)     
;;    ;plotExp= gsn_csm_contour_map(wksExp,tavgExp,res)
;;	res@cnLevelSelectionMode ="ManualLevels"
;;	res@cnMaxLevelValF  = 2.  ;     400.
;;	res@cnMinLevelValF  = -2.  ; -400. 
;;	res@cnLevelSpacingF = 0.2      ;40.
;;;    symMinMaxPlt(JJA,20,False,res)
;;    plotJJA=gsn_csm_contour_map(wksJJA,JJA,res)
;;    ;plotAno=gsn_csm_contour_map(wksAno,tavgAno,res)
;;;    symMinMaxPlt(JFM,20,False,res)
;;    plotJFM=gsn_csm_contour_map(wksJFM,JFM,res)
;;;    symMinMaxPlt(SON,20,False,res)
;;    plotSON=gsn_csm_contour_map(wksSON,SON,res)
;;;    symMinMaxPlt(MAM,20,False,res)
;;    plotMAM=gsn_csm_contour_map(wksMAM,MAM,res)
;;    symMinMaxPlt(Month,20,False,res)
;;    plotMonth=gsn_csm_contour_map(wksMonth,Month,res)
;;    ressig=True
;;    ressig@gsnLeftString=""
;;    ressig@gsnRightString=""
;;    ressig@gsnDraw=False
;;    ressig@gsnFrame=False
;;    ressig@cnInfoLabelOn       = False       ; turn off info label
;;    ressig@cnLinesOn           = False       ; do not draw contour lines
;;    ressig@cnLineLabelsOn      = False       ; do not draw contour labels
;;    ressig@cnLevelSelectionMode ="ManualLevels"
;;    maxLevel=1.
;;    minLevel=0.
;;    ressig@cnMaxLevelValF  = maxLevel
;;    ressig@cnMinLevelValF  = minLevel
;;    ressig@cnLevelSpacingF = (maxLevel-minLevel)/20.
;;    ressig@cnFillScaleF=0.7
;;    ressig@cnFillDotSizeF=0.002
;;    plotsig=gsn_csm_contour(wksMonth,probMonth,ressig)
;;    resdot = True
;;    resdot@gsnShadeFillType = "pattern"        ; color is the default
;;    resdot@gsnShadeMid = 17                  ; use color index 14
;;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;;    overlay(plotMonth,plotsig)
;;    draw(plotMonth)
;;    frame(wksMonth)
;;
;;    plotsig=gsn_csm_contour(wksJFM,probJFM,ressig)
;;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;;    overlay(plotJFM,plotsig)
;;    draw(plotJFM)
;;    frame(wksJFM)
;;
;;    plotsig=gsn_csm_contour(wksMAM,probMAM,ressig)
;;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;;    overlay(plotMAM,plotsig)
;;    draw(plotMAM)
;;    frame(wksMAM)
;;    plotsig=gsn_csm_contour(wksJJA,probJJA,ressig)
;;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;;    overlay(plotJJA,plotsig)
;;    draw(plotJJA)
;;    frame(wksJJA)
;;
;;    plotsig=gsn_csm_contour(wksSON,probSON,ressig)
;;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;;    overlay(plotSON,plotsig)
;;    draw(plotSON)
;;    frame(wksSON)
;;
;;  end if
;;
;;  if (plottype .eq. "timeseries") then
;;    gavg=wgt_areaave_Wrap(Var(:,:,:),clat,1.0,0)   ; global avg
;;    gavgExp=wgt_areaave_Wrap(VarExp(:,:,:),clat,1.0,0) 
;;    gavgAno=wgt_areaave_Wrap(VarAno(:,:,:),clat,1.0,0) 
;;    ;JFM=VarClima((/0,1,11/)
;;    ;JJA=VarClima((/5,6,7/)
;;
;;    ;res@tiMainString=Var@long_name
;;    ;res@tiXAxisString="time (month)"
;;    ;res@tiYAxisString=Var@units
;;    plot  = gsn_csm_xy (wks,tt,runave_Wrap( gavg,12,0) ,res) ; create plot
;;    plotExp=gsn_csm_xy (wksExp,tt,runave_Wrap( gavgExp,12,0),res)
;;    plotAno=gsn_csm_xy (wksAno,tt,runave_Wrap (gavgAno,12,0),res)
;;    ;plotJFM  = gsn_csm_xy (wksJFM,tt,JFM,res) ; create plot
;;    ;plotJJA=gsn_csm_xy (wksJJA,tt,JJA,res)
;;  end if
;;
;;  print("file= "+varname+"_"+plottype)
;end
