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
  xcompname="U"
  ycompname="V"
  
    plottype="velocityp"
    plottype="streamf"
  pnew =200  
    print("plot "+plottype)
  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/F2000_CAM5_EXP1/atm/hist/*.nc |head -n 719 |tail -n 360")
;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /work4/L.r02229011/IRR_B_2000_CAM5_IndiaWinterOnly_New/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  fils=systemfunc ("ls /raid2/share/mlo/CTR_B_2000_CAM5/lnd/hist/*.nc |tail -n 253|head -n 240")
;  filsExp=systemfunc ("ls /raid2/share/mlo/IRR_B_2000_CAM5/lnd/hist/*.nc |tail -n 247|head -n 240")
;  fils=systemfunc ("ls /work4/L.r02229011/CTR_B_2000_CAM5_IndiaWinterOnly/atm/hist/*.nc |tail -n 241 |head -n 240")
;  filsExp=systemfunc ("ls /work4/L.r02229011/IRR_B_2000_CAM5_IndiaWinterOnly/atm/hist/*.nc |tail -n 601 |head -n 240")

  in=addfiles(fils,"r")
  inExp=addfiles(filsExp,"r")
  ListSetType (in,"cat")
  ListSetType (inExp,"cat")
;-------------------------
  hyam=in[0]->hyam
  hybm=in[0]->hybm
  PS=in[:]->PS
  PSExp=inExp[:]->PS
  P0mb=in[0]->P0*0.01
  ; type of interpolation: 1 = linear, 2 = log, 3 = loglog
  interp = 2 
  ; is extrapolation desired if data is outside the range of PS
  extrap = False

  pnew@units="hpa"
  print ("xcompname= "+xcompname)
  XComp=vinth2p(in[:]->$xcompname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  XCompExp=vinth2p(inExp[:]->$xcompname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
;  XCompAno=XComp
;  XCompAno(:,:,:,:)= XCompExp(:,:,:,:) - XComp(:,:,:,:) 
  
  XComp@long_name=in[0]->$xcompname$@long_name
  XComp@units=in[0]->$xcompname$@units

  XCompExp@long_name=in[0]->$xcompname$@long_name
  XCompExp@units=in[0]->$xcompname$@units
  
;  XCompAno@long_name=in[0]->$xcompname$@long_name
;  XCompAno@units=in[0]->$xcompname$@units


  print ("ycompname= "+ycompname)
  YComp=vinth2p(in[:]->$ycompname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  YCompExp=vinth2p(inExp[:]->$ycompname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
;  YCompAno=YComp
;  YCompAno(:,:,:,:)= YCompExp(:,:,:,:) - YComp(:,:,:,:) 
  
  YComp@long_name=in[0]->$ycompname$@long_name
  YComp@units=in[0]->$ycompname$@units

  YCompExp@long_name=in[0]->$ycompname$@long_name
  YCompExp@units=in[0]->$ycompname$@units
  
;  YCompAno@long_name=in[0]->$ycompname$@long_name
;  YCompAno@units=in[0]->$ycompname$@units
;-----------------------------------

  lat = in[0]->lat
  lon = in[0]->lon
  tt = ispan(1,12*100,1)
  ;printVarSummary(Var)
  temp=uv2sfvpF(XComp,YComp)
  printVarSummary(temp)

if (plottype.eq."streamf")then
  Var = temp(0,:,:,:,:)
  temp=uv2sfvpF(XCompExp,YCompExp)
  VarExp=temp(0,:,:,:,:)
end if
if (plottype.eq."velocityp")then
  Var = temp(1,:,:,:,:)
  temp=uv2sfvpF(XCompExp,YCompExp)
  VarExp=temp(1,:,:,:,:)
end if
  copy_VarCoords(XComp,Var)
  copy_VarCoords(XComp,VarExp)
if (plottype.eq."streamf")then
  Var@long_name="Stream function"  
  VarExp@long_name="Stream function"
end if
if (plottype.eq."velocityp")then
  Var@long_name="Velocity potential"  
  VarExp@long_name="Velocity potential"
end if
  VarAno=VarExp-Var
  copy_VarCoords(XComp,VarAno)

  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight
  ;printVarSummary(gavg)
printVarSummary(Var)
;************************************************
; create default plot
;************************************************

    res	= True               ; plot mods desired
    res@cnFillOn	= True               ; turn on color fill
    res@cnLinesOn	= False              ; turn off contour lines
    res@gsnMaximize	= True
    res@gsnSpreadColors       = True               ; use full range of color map
;*****************************
;    res@mpMinLatF       = -60
;    res@mpMaxLatF       = 60
;    res@mpMinLonF       = 30
;    res@mpMaxLonF       = 120
;    res@mpMinLatF       = -30
;    res@mpMaxLatF       = 60
;    res@mpMinLonF       = 40
;    res@mpMaxLonF       = 120
;    res@cnFillMode           = "RasterFill"
;***************************
    res@mpOutlineBoundarySets       = "National"
    res@mpDataSetName = "Earth..4"
    res@mpCountyLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF =2.5
;res@mpPerimOn            = False
res@mpGridAndLimbOn   = True
res@mpGridLatSpacingF = 30.
res@mpGridLonSpacingF = 30.
;res@mpProjection = "Robinson"
;res@mpCenterLonF=150
	res@gsnSpreadColors       = False               ; use full range of color map
	res@cnFillPalette = "BlWhRe"
	res@cnFillPalette = "MPL_RdBu"
	res@cnSpanFillPalette=True
    res@mpGeophysicalLineThicknessF =5.0
    res@lbLabelFontHeightF=.02

    res@gsnDraw      =  False                   ; do not draw the plot
    res@gsnFrame     =  False                   ; do not advance the frame

res@mpCenterLonF=0
res@mpMinLatF       = 20
    res@gsnLeftString=""
    res@gsnRightString=""
;    res@gsnPolar   = "SH"

    res@cnLevelSelectionMode="AutomaticLevels"
    tavg=dim_avg_n_Wrap(Var(:,0,:,:),0) ;time avg
    tavgExp=dim_avg_n_Wrap(VarExp(:,0,:,:),0)
    tavgAno=dim_avg_n_Wrap(VarAno(:,0,:,:),0)
    print("level= "+pnew(0)+" hpa")
    wks = gsn_open_wks("png","fig/"+plottype+pnew(0)+"_ctrl")  ; open a wks
    wksExp=gsn_open_wks("png","fig/"+plottype+pnew(0)+"_exp")

;    gsn_define_colormap(wks,"BlAqGrYeOrRe")
;    gsn_define_colormap(wksExp,"BlAqGrYeOrRe")
    plotscale=1
;  gsn_define_colormap(wks,"BlWhRe")        ; choose colormap
;  gsn_define_colormap(wksExp,"BlWhRe")        ; choose colormap
   ;symMinMaxPlt(tavg*plotscale,20,False,res)
    plot = gsn_csm_contour_map(wks,tavg,res)     
   ;symMinMaxPlt(tavgExp*plotscale,20,False,res)
    plotExp= gsn_csm_contour_map(wksExp,tavgExp,res)

;******seasonal climatology
    VarClima=clmMonTLL(Var(:,0,:,:))
    DJF=dim_avg_n_Wrap(VarClima((/0,1,2/),:,:),0)
    JFM=dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)
    JJA=dim_avg_n_Wrap(VarClima((/6,7,8/),:,:),0)
    MAM=dim_avg_n_Wrap(VarClima((/3,4,5/),:,:),0)
    SON=dim_avg_n_Wrap(VarClima((/9,10,11/),:,:),0)
    DJF@long_name=DJF@long_name+" DJF"
    JFM@long_name=JFM@long_name+" JFM"
    JJA@long_name=JJA@long_name+" JJA"
    MAM@long_name=MAM@long_name+" MAM"
    SON@long_name=SON@long_name+" SON"
    wksDJF= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_DJF")
    wksJFM= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_JFM")
    wksJJA= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_JJA")
    wksMAM= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_MAM")
    wksSON= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_SON")
    ;symMinMaxPlt(DJF*plotscale,20,False,res)
    plotDJF=gsn_csm_contour_map(wksDJF,DJF,res)
    ;symMinMaxPlt(DJF*plotscale,20,False,res)
    plotJFM=gsn_csm_contour_map(wksJFM,JFM,res)
    ;symMinMaxPlt(JJA*plotscale,20,False,res)
    plotJJA=gsn_csm_contour_map(wksJJA,JJA,res)
    ;symMinMaxPlt(MAM*plotscale,20,False,res)
    plotMAM=gsn_csm_contour_map(wksMAM,MAM,res)
    ;symMinMaxPlt(SON*plotscale,20,False,res)
    plotSON=gsn_csm_contour_map(wksSON,SON,res)
    month_plot=0
    do while (month_plot .le. 11)
	wksMonth= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_"+month_plot)
;	gsn_define_colormap(wksMonth,"BlAqGrYeOrRe")
	;gsn_define_colormap(wksMonth,"BlWhRe")
	;symMinMaxPlt(VarClima(month_plot,:,:)*plotscale,20,False,res)
	plotMonth=gsn_csm_contour_map(wksMonth,VarClima(month_plot,:,:),res)
	month_plot=month_plot+1
    end do
;*****************

;    res@cnLevelSelectionMode ="ManualLevels"
;    res@cnMaxLevelValF  = 0.1/10.
;    res@cnMinLevelValF  = -0.1/10.
;    res@cnLevelSpacingF = 0.01/10.

;**************seasonal anomaly
    VarClima=clmMonTLL(VarAno(:,0,:,:))
    DJF=dim_avg_n_Wrap(VarClima((/0,1,2/),:,:),0)
    JFM=dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)

    JFM(:,:)=JFM(:,:)/100000

    JJA=dim_avg_n_Wrap(VarClima((/6,7,8/),:,:),0)
    MAM=dim_avg_n_Wrap(VarClima((/3,4,5/),:,:),0)
    SON=dim_avg_n_Wrap(VarClima((/9,10,11/),:,:),0)
    DJF@long_name=DJF@long_name+" DJF"
    JFM@long_name=JFM@long_name+" JFM"
    JJA@long_name=JJA@long_name+" JJA"
    MAM@long_name=MAM@long_name+" MAM"
    SON@long_name=SON@long_name+" SON"
    wksAno=gsn_open_wks ("png","fig/"+plottype+pnew(0)+"_comp")
    wksDJF= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_DJFa")
    wksJFM= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_JFMa")
    wksJJA= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_JJAa")
    wksMAM= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_MAMa")
    wksSON= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_SONa")
    month_plot=0
    do while (month_plot .le. 11)
	wksMonth= gsn_open_wks("png","fig/"+plottype+pnew(0)+"_"+month_plot+"a")
;	gsn_define_colormap(wksMonth,"BlWhRe")
	symMinMaxPlt(VarClima(month_plot,:,:)*plotscale,20,False,res)
	plotMonth=gsn_csm_contour_map(wksMonth,VarClima(month_plot,:,:),res)
	month_plot=month_plot+1
    end do

    symMinMaxPlt(JFM,20,False,res)
    JFMmap=JFM
;    plotJFM=gsn_csm_contour_map(wksJFM,JFMmap,res)
;    symMinMaxPlt(DJF*plotscale,20,False,res)
;    plotDJF=gsn_csm_contour_map(wksDJF,DJF,res)
;    symMinMaxPlt(JJA*plotscale,20,False,res)
;    plotJJA=gsn_csm_contour_map(wksJJA,JJA,res)
;    symMinMaxPlt(MAM*plotscale,20,False,res)
;    plotMAM=gsn_csm_contour_map(wksMAM,MAM,res)
;    symMinMaxPlt(SON*plotscale,20,False,res)
;    plotSON=gsn_csm_contour_map(wksSON,SON,res)
;    symMinMaxPlt(tavgAno*plotscale,20,False,res)
;    plotAno=gsn_csm_contour_map(wksAno,tavgAno,res)


;**********************************
  siglvl = 0.1
    ;tavg=dim_avg_n_Wrap(Var(600:1199,:,:),0) ;time avg
    ;tavgExp=dim_avg_n_Wrap(VarExp(600:1199,:,:),0)
    years=50
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
  wksMonth=gsn_open_wks("png","fig/"+plottype+"_"+pnew(0)+"_"+month_plot+"_comp_ttest_dot_"+composite_set+"_p="+siglvl)
  gsn_define_colormap(wksMonth,"BlWhRe")

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

;    overlay(plotMonth,plotsig)
;    draw(plotMonth)
;    frame(wksMonth)
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

    plotsig=gsn_csm_contour(wksJFM,probJFM,ressig)
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)

    res@cnLevelSelectionMode ="ManualLevels"
    maxLevel=50.
    minLevel=-50.
    res@cnMaxLevelValF  = maxLevel
    res@cnMinLevelValF  = minLevel
    res@cnLevelSpacingF = (maxLevel-minLevel)/20.
    plotJFM=gsn_csm_contour_map_polar(wksJFM,JFMmap,res)
    overlay(plotJFM,plotsig)
    draw(plotJFM)
    frame(wksJFM)
;***************************







end
