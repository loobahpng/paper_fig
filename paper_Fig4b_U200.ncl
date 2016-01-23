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
    varname="U"
    autolevs=1
    maxLevel=30.
    minLevel=-30.
    pnew = 200 
  print (" "+varname)

  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")

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

  pnew@units="hpa"
  Var=vinth2p(in[:]->$varname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  VarExp=vinth2p(inExp[:]->$varname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
  
  Var@long_name=in[0]->$varname$@long_name
  Var@units=in[0]->$varname$@units

  VarExp@long_name=in[0]->$varname$@long_name
  VarExp@units=in[0]->$varname$@units
  
  VarAno=Var
  VarAno(:,:,:,:)= VarExp(:,:,:,:) - Var(:,:,:,:) 
  VarAno@long_name=Var@long_name
  VarAno@units=Var@units

  lat = in[0]->lat
  lon = in[0]->lon
  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight
;**********************************
  siglvl = 0.1
vdim=dimsizes(Var)
print(vdim)
t=new((/12,years,vdim(2),vdim(3)/),"float")
t!0="month"
tExp=t
month=1-1
do while (month .le. 11)
    t(month,:,:,:)=Var(0+month:12*years-1:12,0,:,:)
    tExp(month,:,:,:)=VarExp(0+month:12*years-1:12,0,:,:)
    month=month+1
end do
;-------------------
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
  res   = True               ; plot mods desired
    res@cnFillOn        = True               ; turn on color fill
    res@cnLinesOn       = False              ; turn off contour lines
    res@gsnMaximize     = True
    res@gsnSpreadColors = True               ; use full range of color map
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
res@mpPerimOn            = False
res@mpGridAndLimbOn   = True
res@mpGridLatSpacingF = 30.
res@mpGridLonSpacingF = 30.
res@mpProjection = "Robinson"
res@mpCenterLonF=150
	res@gsnSpreadColors       = False               ; use full range of color map
	res@cnFillPalette = "precip4_diff_19lev"
	res@cnFillPalette = "temp_19lev"
	res@cnFillPalette = "BlWhRe"
	res@cnFillPalette = "MPL_RdBu"
	res@cnSpanFillPalette=True
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
    resdot = True
    resdot@gsnShadeFillType = "pattern"        ; color is the default
    resdot@gsnShadeMid = 17                  ; use color index 14
;-------------------
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
;************************************************
; create default plot
;************************************************
  wksJFM= gsn_open_wks("png","fig/"+varname+"_"+pnew+"_JFMcomp_ttest_dot_"+composite_set)
  gsn_define_colormap(wksJFM,"BlWhRe")
    if (autolevs.eq.1 )then
	symMinMaxPlt(JFM,20,False,res)
    end if
    plotJFM=gsn_csm_contour_map(wksJFM,JFM,res)
    plotsig=gsn_csm_contour(wksJFM,probJFM,ressig)
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotJFM,plotsig)
    draw(plotJFM)
    frame(wksJFM)
  print(" "+varname)
end
