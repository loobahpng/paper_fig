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
  scalarname="Z3"
  vect_xname="U"
  vect_yname="V"

  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")

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

  pnew =  (/200,925/)  

  pnew@units="hpa"

  print ("scalarname= "+scalarname)
  Scalar=vinth2p(in[:]->$scalarname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  ScalarExp=vinth2p(inExp[:]->$scalarname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
  ScalarAno=Scalar
  ScalarAno(:,:,:,:)= ScalarExp(:,:,:,:) - Scalar(:,:,:,:) 
  Scalar@long_name=in[0]->$scalarname$@long_name
  Scalar@units=in[0]->$scalarname$@units
  ScalarExp@long_name=in[0]->$scalarname$@long_name
  ScalarExp@units=in[0]->$scalarname$@units  
  ScalarAno@long_name=in[0]->$scalarname$@long_name
  ScalarAno@units=in[0]->$scalarname$@units

  print ("vect_xname= "+vect_xname)
  vect_x=vinth2p(in[:]->$vect_xname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  vect_xExp=vinth2p(inExp[:]->$vect_xname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
  vect_xAno=vect_x
  vect_xAno(:,:,:,:)=vect_xExp(:,:,:,:)-vect_x(:,:,:,:)
  vect_x@long_name=in[0]->$vect_xname$@long_name
  vect_x@units=in[0]->$vect_xname$@units
  vect_xExp@long_name=in[0]->$vect_xname$@long_name
  vect_xExp@units=in[0]->$vect_xname$@units
  vect_xAno@long_name=in[0]->$vect_xname$@long_name
  vect_xAno@units=in[0]->$vect_xname$@units
 
  print ("vect_yname= "+vect_yname)
  vect_y=vinth2p(in[:]->$vect_yname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  vect_yExp=vinth2p(inExp[:]->$vect_yname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
  vect_yAno=vect_y
  vect_yAno(:,:,:,:)=vect_yExp(:,:,:,:)-vect_y(:,:,:,:)
  vect_y@long_name=in[0]->$vect_yname$@long_name
  vect_y@units=in[0]->$vect_yname$@units
  vect_yExp@long_name=in[0]->$vect_yname$@long_name
  vect_yExp@units=in[0]->$vect_yname$@units
  vect_yAno@long_name=in[0]->$vect_yname$@long_name
  vect_yAno@units=in[0]->$vect_yname$@units
;-----------------------------------
  lat = in[0]->lat
  lon = in[0]->lon
  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight
;************************************************
; create default plot
;************************************************

    plotlevel=0
    do while (plotlevel .ne. 2)
    
    Scalartavg=dim_avg_n_Wrap(Scalar(:,plotlevel,:,:),0) ;time avg
    ScalartavgExp=dim_avg_n_Wrap(ScalarExp(:,plotlevel,:,:),0)
    ScalartavgAno=dim_avg_n_Wrap(ScalarAno(:,plotlevel,:,:),0)
    vect_xtavg=dim_avg_n_Wrap(vect_x(:,plotlevel,:,:),0) ;time avg
    vect_xtavgExp=dim_avg_n_Wrap(vect_xExp(:,plotlevel,:,:),0)
    vect_xtavgAno=dim_avg_n_Wrap(vect_xAno(:,plotlevel,:,:),0)
    vect_ytavg=dim_avg_n_Wrap(vect_y(:,plotlevel,:,:),0) ;time avg
    vect_ytavgExp=dim_avg_n_Wrap(vect_yExp(:,plotlevel,:,:),0)
    vect_ytavgAno=dim_avg_n_Wrap(vect_yAno(:,plotlevel,:,:),0)
    print("level= "+pnew(plotlevel)+" hpa")

    ScalarClima=clmMonTLL(Scalar(:,plotlevel,:,:))
    ScalarJFM=dim_avg_n_Wrap(ScalarClima((/1,2,3/),:,:),0)

    ScalarAnoClima=clmMonTLL(ScalarAno(:,plotlevel,:,:))
    ScalarAnoJFM=dim_avg_n_Wrap(ScalarAnoClima((/1,2,3/),:,:),0)

    vect_xClima=clmMonTLL(vect_xAno(:,plotlevel,:,:))
    vect_xJFM=dim_avg_n_Wrap(vect_xClima((/1,2,3/),:,:),0)
    vect_yClima=clmMonTLL(vect_yAno(:,plotlevel,:,:))
    vect_yJFM=dim_avg_n_Wrap(vect_yClima((/1,2,3/),:,:),0)

  wksJFM= gsn_open_wks("pdf","fig/"+vect_xname+vect_yname+scalarname+pnew(plotlevel)+"_JFM_a")
  gsn_define_colormap(wksJFM,"BlWhRe")
    res	= True               ; plot mods desired
    res@cnFillOn	= True               ; turn on color fill
    res@cnLinesOn	= False              ; turn off contour lines
    res@gsnMaximize	= True
    res@gsnSpreadColors       = True               ; use full range of color map
    res@gsnDraw      =  False                   ; do not draw the plot
    res@gsnFrame     =  False                   ; do not advance the frame
;**********************************
    res@mpMinLatF       = -30
    res@mpMaxLatF       = 60
    res@mpMinLonF       = 40
    res@mpMaxLonF       = 120
;*********************************
    res@mpOutlineBoundarySets       = "National"
    res@mpDataSetName = "Earth..4"
    res@mpCountyLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF =5.0
    res@lbLabelFontHeightF=.02
    res@cnFillMode           = "RasterFill"

	res@gsnSpreadColors       = False 
	res@cnFillPalette = "MPL_RdBu"
	res@cnSpanFillPalette=True

    res@cnLevelSelectionMode ="ManualLevels"
if (plotlevel.eq.0)
    maxLevel=15.
    minLevel=-15.
end if
if (plotlevel.eq.1)
    maxLevel=5.
    minLevel=-5.
end if
    res@cnMaxLevelValF  = maxLevel
    res@cnMinLevelValF  = minLevel
    res@cnLevelSpacingF = (maxLevel-minLevel)/20.

    sres	= True               ; plot mods desired
    sres@cnFillOn	= False;True               ; turn on color fill
    sres@cnLinesOn	= True;False              ; turn off contour lines
    sres@gsnMaximize	= True
    sres@gsnSpreadColors       = True               ; use full range of color map
    sres@gsnDraw      =  False                   ; do not draw the plot
    sres@gsnFrame     =  False                   ; do not advance the frame
    sres@gsnContourNegLineDashPattern = 1
    sres@gsnContourZeroLineThicknessF = 2.
    sres@cnLineLabelsOn       = True
    sres@cnLineLabelBackgroundColor =-1
    sres@gsnContourLineThicknessesScale=2.0
    sres@gsnRightString=""
    sres@gsnLeftString=""

    vecres=True
    vecres@gsnDraw          = False           ; don't draw
    vecres@gsnFrame         = False           ; don't advance frame
    ;vecres@vcGlyphStyle     = "CurlyVector"   ; curly vectors
    vecres@vcRefMagnitudeF  = 20.              ; define vector ref mag
    vecres@vcRefLengthF     = 0.045           ; define length of vec ref
    vecres@gsnRightString   = " "             ; turn off right string
    vecres@gsnLeftString    = " "             ; turn off left string
    vecres@tiXAxisString    = " "             ; turn off axis label 
    vecres@vcMinDistanceF   = 0.03;15           ; thin out windbarbs
    vecres@vcLineArrowThicknessF=2.0 
    vecres@vcLineArrowColor="darkgreen" 
    vecres@vcRefAnnoOrthogonalPosF = -.535    ; move ref vector into plot

    if (plotlevel.eq.0)
        vecres@vcRefMagnitudeF  = 1.              ; define vector ref mag
    end if
    if (plotlevel.eq.1)
        vecres@vcRefMagnitudeF  = 1.              ; define vector ref mag
    end if
    plotJFM=gsn_csm_contour_map_ce(wksJFM,ScalarAnoJFM,res)
    plot_ov=gsn_csm_vector(wksJFM,vect_xJFM,vect_yJFM,vecres)
    overlay(plotJFM,plot_ov)

  print("file= "+scalarname+"_map")

    res@gsnDraw=False
    res@gsnFrame=False

;**********************************
  varname=scalarname
  siglvl = 0.1
    years=50
vdim=dimsizes(Scalar)
t=new((/12,years,vdim(2),vdim(3)/),"float")
t!0="month"
tExp=t
month=1-1
do while (month .le. 11)
    t(month,:,:,:)=Scalar(0+month:12*years-1:12,plotlevel,:,:)
    tExp(month,:,:,:)=ScalarExp(0+month:12*years-1:12,plotlevel,:,:)
    month=month+1
end do
;  t=runave_n_Wrap(t,3,1,1)
;  tExp=runave_n_Wrap(tExp,3,1,1)
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
    plotsig=gsn_csm_contour(wksJFM,probJFM,ressig)
    plotsig=gsn_contour_shade(plotsig,0.,siglvl,resdot)
    overlay(plotJFM,plotsig)
    draw(plotJFM)
    frame(wksJFM)
    plotlevel=plotlevel+1
    end do
end
