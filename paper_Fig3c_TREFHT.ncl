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
    maskwhat="ocean"
  end if
    years=50
    varname="TREFHT"
    autolevs=0.
    maxLevel=2.
    minLevel=-2.
  print (" "+varname)
  month_abbr = (/"Dec","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov"/)

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5/atm/hist/*.nc |head -n 719 |tail -n 600")
;  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5_irri_test/atm/hist/*.nc |head -n 719 |tail -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5/atm/hist/*.nc |head -n 359 |tail -n 300")
;  filsExp=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_MidEast_irr/atm/hist/*.nc |head -n 359 |tail -n 300")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5_EXP1/atm/hist/*.nc |head -n 719 |tail -n 360")

;  filsExp=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_USIrriOnly/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_IndiaIrriOnly/atm/hist/*.nc |head -n 719 |tail -n 360")

  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5_NCP/atm/hist/*.nc |tail -n 601|head -n 600")

;  fils=asciiread("CTR.txt",600,"string")
  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /scratch/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /work4/L.r02229011/IRR_B_2000_CAM5_IndiaWinterOnly_New/atm/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/lnd/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /work4/L.r02229011/IRR_B_2000_CAM5_IndiaWinterOnly_New/lnd/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_f09g16_Ctrl/lnd/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work4/L.r02229011/F2000_CAM5_f09g16_IRRI/lnd/hist/*.nc |head -n 719 |tail -n 360")

  in=addfiles(fils,"r")
  inExp=addfiles(filsExp,"r")
  ListSetType (in,"cat")
  ListSetType (inExp,"cat")
  Var= in[:]->$varname$
;  Var(:,:,:)=Var(:,:,:)*86400000.
;  Var@units="mm/day"
  VarExp=inExp[:]->$varname$
;  VarExp(:,:,:)=VarExp(:,:,:)*86400000.
;  VarExp@units="mm/day"
;-------------mask
if (maskwhat.ne."no")then
  filsmask=systemfunc("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/lnd/hist/IRR_B_2000_CAM5.clm2.h0.0101-02.nc")
;  filsmask=systemfunc("ls /work3/mlo/cesm1/archive/F2000_CAM5/lnd/hist/F2000_CAM5.clm2.h0.0001-01.nc")
;  filsmask=systemfunc("ls /home/L.r02229011/irr/mask_2x2_IndusGanges.nc")
  inmask=addfiles(filsmask,"r")
 ListSetType(inmask,"cat")
      maskname="landmask"
    if (maskwhat.eq."land") then
      Var=mask(Var,conform(Var,inmask[0]->$maskname$,(/1,2/)),0)
    end if
    if (maskwhat .eq."ocean")then
      Var=mask(Var,conform(Var,inmask[0]->$maskname$,(/1,2/)),1)
    end if
end if
;-------------------
    if (varname.eq."PRECT".or.varname.eq."PRECC".or.varname.eq."PRECL".or.varname.eq."PRECSH".or.varname.eq."PRECCDZM")then
	Var(:,:,:)=Var(:,:,:)*86400000.
	Var@units="mm/day"
	VarExp(:,:,:)=VarExp(:,:,:)*86400000.
	VarExp@units="mm/day"
    end if
;  baseline4d=reshape(Var,(/years,12,192,288/))
;  baselinemap=new((/12,192,288/),"double")
;  baselinemap=dim_avg_n_Wrap(baseline4d,0)
;  baselinemap=where(baselinemap.gt.0,baselinemap,baselinemap@_FillValue)
;  VarAno=in[:]->$varname$
;  VarAno(:,:,:)= inExp[:]->$varname$ - in[:]->$varname$ 
;  VarAno@units="mm/day"
;  Var@long_name="Total precipitation rate"

  lat = in[0]->lat
  lon = in[0]->lon
  tt = ispan(1,12*100,1)
  ;printVarSummary(Var)

  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight
  clat!0="lat"
  clat&lat=lat
  ;printVarSummary(gavg)
;**********************************
  siglvl = 0.1
    ;tavg=dim_avg_n_Wrap(Var(600:1199,:,:),0) ;time avg
    ;tavgExp=dim_avg_n_Wrap(VarExp(600:1199,:,:),0)
vdim=dimsizes(Var)
t=new((/12,years,vdim(1),vdim(2)/),"float")
t!0="month"
tExp=t
;tavg=new((/12,vdim(1),vdim(2)/,"double")
;tavgExp=tavg
month=1-1
do while (month .le. 11)
    t(month,:,:,:)=Var(0+month:12*years-1:12,:,:)
    tExp(month,:,:,:)=VarExp(0+month:12*years-1:12,:,:)
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
  wksMonth=gsn_open_wks("png","fig/"+varname+"_"+month_plot+"_comp_ttest_dot_"+composite_set+"_p="+siglvl)
  gsn_define_colormap(wksMonth,"BlWhRe")
  res   = True               ; plot mods desired
    res@cnFillOn        = True               ; turn on color fill
    res@cnLinesOn       = False              ; turn off contour lines
    res@gsnMaximize     = True
    res@gsnSpreadColors = True               ; use full range of color map
;**********************************
;    res@mpMinLatF       = 0
;    res@mpMaxLatF       = 40
;    res@mpMinLonF       = 30
;    res@mpMaxLonF       = 130
;    res@mpMinLatF       = 20
;    res@mpMaxLatF       = 60
;    res@mpMinLonF       = 220
;    res@mpMaxLonF       = 280
;    res@mpMinLatF       = -20
;    res@mpMaxLatF       = 60
;    res@mpMinLonF       = 120
;    res@mpMaxLonF       = 270
;    res@mpMinLatF       = 20
;    res@mpMaxLatF       = 60
;    res@mpMinLonF       = 220
;    res@mpMaxLonF       = 280
;    res@mpMinLatF       = 0
;    res@mpMaxLatF       = 50
;    res@mpMinLonF       = 30
;    res@mpMaxLonF       = 70
;    res@cnFillMode           = "RasterFill"
;*************************************
    res@mpOutlineBoundarySets       = "National"
    res@mpDataSetName = "Earth..4"
    res@mpCountyLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF =5.0
    res@lbLabelFontHeightF=.02
;res@mpPerimOn            = False
res@mpGridAndLimbOn   = True
res@mpGridLatSpacingF = 30.
res@mpGridLonSpacingF = 30.
;res@mpProjection = "Robinson"

;Polar projection: N. America
res@mpCenterLonF=150
res@mpCenterLonF=270
res@mpMinLatF       = 20
res@gsnLeftString=""
res@gsnRightString=""

    res@gsnDraw=False
    res@gsnFrame=False
    res@cnLevelSelectionMode ="ManualLevels"
    res@cnMaxLevelValF  = maxLevel
    res@cnMinLevelValF  = minLevel
    res@cnLevelSpacingF = (maxLevel-minLevel)/20.
	res@gsnSpreadColors       = False               ; use full range of color map
	res@cnFillPalette = "MPL_RdBu"
if (varname.eq."PRECT".or.varname.eq."PRECC".or.varname.eq."PRECL".or.varname.eq."PRECSH".or.varname.eq."PRECCDZM")
	res@cnFillPalette = "precip4_diff_19lev"
end if
if (varname.eq."TREFHT".or.varname.eq."TS")then
	res@cnFillPalette = "temp_19lev"
end if
	res@cnSpanFillPalette=True
    if (autolevs.eq.1 )then
	symMinMaxPlt(Month,20,False,res)
    end if
    res@gsnLeftString=varname+" "+month_abbr(month_plot)
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
    ressig@mpProjection = "Robinson"
    plotsig=gsn_csm_contour(wksMonth,probMonth,ressig)
    resdot = True
    resdot@gsnShadeFillType = "pattern"        ; color is the default
    resdot@gsnShadeMid = 17                  ; use color index 14
    resdot@mpProjection = "Robinson"
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotMonth,plotsig)
    draw(plotMonth)
    frame(wksMonth)
    wksratio=gsn_open_wks("png","fig/"+varname+"_"+month_plot+"_comp_ttest_dot_ratio_"+composite_set+"_p="+siglvl)
;    ratio=Month/baselinemap(month_plot,:,:)
;    copy_VarCoords(Month,ratio)
;    plotratio=gsn_csm_contour_map(wksratio,ratio,res)
;    plotsig=gsn_csm_contour(wksratio,probMonth,ressig)
;    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
;    overlay(plotratio,plotsig)
;    draw(plotratio)
;    frame(wksratio)
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
;    areamean=wgt_areaave_Wrap(JFM({30:45},{150:210}),clat({30:45}),1.0,0)
;    print("CTR area mean: "+areamean)
;    delete(areamean)
  JFMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/1,2,3/),composite_IRR,:,:),0),0)
;    temp=dim_avg_n_Wrap(tExp((/1,2,3/),composite_IRR,:,:),0)
;    areamean=wgt_areaave_Wrap(temp(:,{30:45},{150:210}),clat({30:45}),1.0,0)
;    delete(temp)
;    print("IRR area mean by year: "+areamean)
;    print(" "+dim_avg_n_Wrap(areamean((/15,16,25,30,45,49/)),0))
;    delete(areamean)
;    areamean=wgt_areaave_Wrap(JFMExp({30:45},{150:210}),clat({30:45}),1.0,0)
;    print("IRR area mean: "+areamean)
;  JFMExp=dim_avg_n_Wrap( dim_avg_n_Wrap(tExp((/1,2,3/),(/15,16,25,30,45,49/),:,:),0),0)

  JFMvar = dim_variance_n_Wrap( dim_avg_n_Wrap(t((/1,2,3/),composite_CTR,:,:),0),0)
  JFMvarExp = dim_variance_n_Wrap ( dim_avg_n_Wrap(tExp((/1,2,3/),composite_IRR,:,:),0),0)
  sX   = dimsizes(composite_CTR)        ; X and Y can be of
  sY   = dimsizes(composite_IRR)        ; different sizes
  iflag= False               ; population variance similar
  probJFM=JFM
  probJFM(:,:) = ttest(JFM,JFMvar,sX,JFMExp,JFMvarExp,sY, iflag, False)
  JFM =JFMExp-JFM
;  JFM =where(abs(JFM) .lt. 2,t@_FillValue,JFM)

  ;end if
;************************************************
; create default plot
;************************************************
  ;wks = gsn_open_wks("png","fig/"+varname+"_ctrl_"+plottype)  ; open a wks
  ;wksExp=gsn_open_wks("png","fig/"+varname+"_exp_"+plottype)
;  wksAno=gsn_open_wks ("png","fig/"+(month+1)+"_"+varname+"_comp_"+plottype)
  wksJFM= gsn_open_wks("png","fig/"+varname+"_JFMcomp_ttest_dot_"+composite_set+"_p="+siglvl)
  wksJJA= gsn_open_wks("png","fig/"+varname+"_JJAcomp_ttest_dot_"+composite_set+"_p="+siglvl)
  wksSON= gsn_open_wks("png","fig/"+varname+"_SONcomp_ttest_dot_"+composite_set+"_p="+siglvl)
  wksMAM= gsn_open_wks("png","fig/"+varname+"_MAMcomp_ttest_dot_"+composite_set+"_p="+siglvl)
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
    res@gsnLeftString=varname+" JJA"
;    plotJJA=gsn_csm_contour_map_polar(wksJJA,JJA,res)
    plotJJA=gsn_csm_contour_map(wksJJA,JJA,res)
    ;plotAno=gsn_csm_contour_map(wksAno,tavgAno,res)
    if (autolevs.eq.1 )then
	symMinMaxPlt(JFM,20,False,res)
    end if
    res@gsnLeftString=varname+" JFM"
;    plotJFM=gsn_csm_contour_map(wksJFM,JFM,res)
    plotJFM=gsn_csm_contour_map_polar(wksJFM,JFM,res)
    if (autolevs.eq.1 )then
	symMinMaxPlt(SON,20,False,res)
    end if
    res@gsnLeftString=varname+" SON"
    plotSON=gsn_csm_contour_map(wksSON,SON,res)
    if (autolevs.eq.1 )then
	symMinMaxPlt(MAM,20,False,res)
    end if
    res@gsnLeftString=varname+" MAM"
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

