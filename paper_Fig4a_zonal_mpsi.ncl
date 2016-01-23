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
varname="V"
startlon=0
endlon=360
startlat=-30
endlat=30

  if(.not.isvar("plottype")) then
    ;print("Plottype not specified")
    plottype="map"
  end if
  ;print ("plottype= "+plottype)
  print ("varname= "+varname)

  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
;  filsExp=systemfunc ("ls /work4/L.r02229011/IRR_B_2000_CAM5_IndiaWinterOnly_New/atm/hist/*.nc |head -n 1199 |tail -n 600")

;  fils=systemfunc ("ls /work4/L.r02229011/E1850_CAM5_Ctrl_f19g16/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work4/L.r02229011/E1850_CAM5_IRRI_f19g16/atm/hist/*.nc |head -n 719 |tail -n 360")
;  fils=systemfunc ("ls /work4/L.r02229011/E2000_CAM5_Ctrl_f19g16/atm/hist/*.nc |head -n 695 |tail -n 324")
;  filsExp=systemfunc ("ls /work4/L.r02229011/E2000_CAM5_IRRI_f19g16/atm/hist/*.nc |head -n 695 |tail -n 324")
;  fils=systemfunc ("ls /work4/L.r02229011/E2000_CAM5_Ctrl_f19g16_CAM5test/atm/hist/*.nc |head -n 719 |tail -n 360")
;  filsExp=systemfunc ("ls /work4/L.r02229011/E2000_CAM5_IRRI_f19g16_CAM5test/atm/hist/*.nc |head -n 719 |tail -n 360")

  in=addfiles(fils,"r")
  inExp=addfiles(filsExp,"r")
  ListSetType (in,"cat")
  ListSetType (inExp,"cat")

  hyam=in[0]->hyam
  hybm=in[0]->hybm
  PS=in[:]->PS
  PSExp=inExp[:]->PS
  P0mb=in[0]->P0*0.01
  ; type of interpolation: 1 = linear, 2 = log, 3 = loglog
  interp = 2 
  ; is extrapolation desired if data is outside the range of PS
  extrap = False
  ;pnew =(/100,150,200,250,300,400,500,600,700,750,800,850,900,925,950/)
  pnew =(/7,10,20,30,50,70,100,125,150,175,200,225,250,300,350,400,450,500,550,600,650,700,750,775,800,825,850,875,900,925,950,975,1000/)
  pnew@units="hpa"
  VarTLLL=vinth2p(in[:]->$varname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  Var = zonal_mpsi_Wrap(VarTLLL,VarTLLL&lat,VarTLLL&lev_p*100,PS)   
  ;Var=dim_avg_n_Wrap(VarTLLL(:,:,:,{startlon:endlon}),3)
  VarExpTLLL=vinth2p(inExp[:]->$varname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
  VarExp=zonal_mpsi_Wrap(VarExpTLLL,VarExpTLLL&lat,VarExpTLLL&lev_p*100,PSExp)
  ;VarExp=dim_avg_n_Wrap(VarExpTLLL(:,:,:,{startlon:endlon}),3)
  VarAno=Var
  VarAno(:,:,:)= VarExp(:,:,:) - Var(:,:,:) 
  
  Var@long_name="zonal_mpsi"
  Var@units="kg/s"

  VarExp@long_name=Var@long_name
  VarExp@units=Var@units
  
  VarAno@long_name=Var@long_name
  VarAno@units=Var@units
  printVarSummary(Var)

  lat = in[0]->lat
  lon = in[0]->lon
  tt = ispan(1,12*100,1)
  ;printVarSummary(Var)
  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight
  ;printVarSummary(gavg)

;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("png","fig/zonal_mpsi"+"_ph_ctrl"+startlon+endlon)  ; open a wks
  wksExp=gsn_open_wks("png","fig/zonal_mpsi"+"_ph_exp"+startlon+endlon)
  ;gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap
  ;gsn_define_colormap(wksExp,"BlAqGrYeOrRe")
  gsn_define_colormap(wks,"BlWhRe")        ; choose colormap
  gsn_define_colormap(wksExp,"BlWhRe")
  res	= True               ; plot mods desired

  if (plottype .eq. "map") then
    ;20 yrs 9_6_0:1199 50yrs 6_0_0:1199
    tavg= dim_avg_n_Wrap(Var(:,:,:),0) ;time avg
    tavgExp= dim_avg_n_Wrap(VarExp(:,:,:),0)
    tavgAno= dim_avg_n_Wrap(VarAno(:,:,:),0)
    
    res@cnFillOn	= True               ; turn on color fill
    res@cnLinesOn	= False              ; turn off contour lines
    res@gsnMaximize	= True
    res@gsnSpreadColors       = True               ; use full range of color map
	res@gsnSpreadColors       = False               ; use full range of color map
	res@cnFillPalette = "MPL_RdBu"
	res@cnSpanFillPalette=True
    ;res@cnLineLabelsOn       = True      
    res@gsnDraw      =  False                   ; do not draw the plot
    res@gsnFrame     =  False                   ; do not advance the frame
    res@lbLabelFontHeightF=.025

    symMinMaxPlt(tavg,20,False,res)
    plot = gsn_csm_pres_hgt(wks,tavg({1000:100},{startlat:endlat}),res)     
    symMinMaxPlt(tavgExp,20,False,res)
    plotExp= gsn_csm_pres_hgt(wksExp,tavgExp({1000:100},{startlat:endlat}),res)

;********seasonal anomaly
    VarClima=clmMonTLL(VarAno(:,:,:))
    DJF= dim_avg_n_Wrap(VarClima((/0,1,2/),:,:),0)
    JFM= dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)

    JFM(:,:)=JFM(:,:)/1000000000.

    JJA= dim_avg_n_Wrap(VarClima((/6,7,8/),:,:),0)
    MAM= dim_avg_n_Wrap(VarClima((/3,4,5/),:,:),0)
    SON= dim_avg_n_Wrap(VarClima((/9,10,11/),:,:),0)
    wksAno=gsn_open_wks ("png","fig/zonal_mpsi"+"_ph_comp"+startlon+endlon)
    wksDJF= gsn_open_wks("png","fig/zonal_mpsi"+"_ph_DJF_a"+startlon+endlon)
   wks_type = "pdf"
   wks_type@wkPaperHeightF = 14.0  ; in inches
   wks_type@wkPaperWidthF = 14.0  ; in inches
    wksJFM= gsn_open_wks(wks_type,"fig/zonal_mpsi"+"_ph_JFM_a"+startlon+endlon)
    wksJJA= gsn_open_wks("png","fig/zonal_mpsi"+"_ph_JJA_a"+startlon+endlon)
    wksMAM= gsn_open_wks("png","fig/zonal_mpsi"+"_ph_MAM_a"+startlon+endlon)
    wksSON= gsn_open_wks("png","fig/zonal_mpsi"+"_ph_SON_a"+startlon+endlon)
    gsn_define_colormap(wksAno,"BlWhRe")
    gsn_define_colormap(wksDJF,"BlWhRe")
    gsn_define_colormap(wksJFM,"BlWhRe")
    gsn_define_colormap(wksJJA,"BlWhRe")
    gsn_define_colormap(wksMAM,"BlWhRe")
    gsn_define_colormap(wksSON,"BlWhRe")
    symMinMaxPlt(DJF,20,False,res)
    plotDJF=gsn_csm_pres_hgt(wksDJF,DJF({1000:100},{startlat:endlat}),res)
    symMinMaxPlt(JFM,20,False,res)
    plotJFM=gsn_csm_pres_hgt(wksJFM,JFM({1000:100},{startlat:endlat}),res)
    symMinMaxPlt(JJA,20,False,res)
    plotJJA=gsn_csm_pres_hgt(wksJJA,JJA({1000:100},{startlat:endlat}),res)
    symMinMaxPlt(MAM,20,False,res)
    plotMAM=gsn_csm_pres_hgt(wksMAM,MAM({1000:100},{startlat:endlat}),res)
    symMinMaxPlt(SON,20,False,res)
    plotSON=gsn_csm_pres_hgt(wksSON,SON({1000:100},{startlat:endlat}),res)
    symMinMaxPlt(tavgAno,20,False,res)
    plotAno=gsn_csm_pres_hgt(wksAno,tavgAno({1000:100},{startlat:endlat}),res)

    month_plot=0
;    do while (month_plot .le. 11)
;	wksMonth= gsn_open_wks("png","fig/zonal_mpsi_"+month_plot+"a")
;;	gsn_define_colormap(wksMonth,"BlWhRe")
;	symMinMaxPlt(VarClima(month_plot,:,:),20,False,res)
;	plotMonth=gsn_csm_pres_hgt(wksMonth,VarClima(month_plot,{1000:100},{startlat:endlat}),res)
;	month_plot=month_plot+1
;    end do

;    res@cnLevelSelectionMode ="ManualLevels"
;    maxLevel=2.
;    minLevel=-2.
;    res@cnMaxLevelValF  = maxLevel
;    res@cnMinLevelValF  = minLevel
;    res@cnLevelSpacingF = (maxLevel-minLevel)/20.
    sres=True
    sres@cnFillOn	= False               ; turn on color fill
    sres@cnLinesOn	= True              ; turn off contour lines
    sres@gsnMaximize	= True
    sres@gsnDraw      =  False                   ; do not draw the plot
    sres@gsnFrame     =  False                   ; do not advance the frame
    sres@cnLineLabelsOn       = False
    sres@cnLineLabelBackgroundColor =-1
    sres@gsnContourLineThicknessesScale=3.0
    sres@gsnContourNegLineDashPattern = 1
    sres@gsnContourZeroLineThicknessF = 6.
    sres@gsnRightString=""
    sres@gsnLeftString=""
    sres@cnInfoLabelOn = True 
;********seasonal climatology
    VarClima=clmMonTLL(VarExp(:,:,:))
    DJF= dim_avg_n_Wrap(VarClima((/0,1,2/),:,:),0)
    JFM= dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)
    JJA= dim_avg_n_Wrap(VarClima((/6,7,8/),:,:),0)
    MAM= dim_avg_n_Wrap(VarClima((/3,4,5/),:,:),0)
    SON= dim_avg_n_Wrap(VarClima((/9,10,11/),:,:),0)
    ;gsn_define_colormap(wksDJF,"BlAqGrYeOrRe")
    ;gsn_define_colormap(wksJJA,"BlAqGrYeOrRe")
    ;gsn_define_colormap(wksMAM,"BlAqGrYeOrRe")
    ;gsn_define_colormap(wksSON,"BlAqGrYeOrRe")
    gsn_define_colormap(wksDJF,"BlWhRe")
    gsn_define_colormap(wksJFM,"BlWhRe")
    gsn_define_colormap(wksJJA,"BlWhRe")
    gsn_define_colormap(wksMAM,"BlWhRe")
    gsn_define_colormap(wksSON,"BlWhRe")
    symMinMaxPlt(DJF,20,False,res)
    plotovDJF=gsn_csm_pres_hgt(wksDJF,DJF({1000:100},{startlat:endlat}),sres)
    symMinMaxPlt(JFM,20,False,res)
    plotovJFM=gsn_csm_pres_hgt(wksJFM,JFM({1000:100},{startlat:endlat}),sres)
    symMinMaxPlt(JJA,20,False,res)
    plotovJJA=gsn_csm_pres_hgt(wksJJA,JJA({1000:100},{startlat:endlat}),sres)
    symMinMaxPlt(MAM,20,False,res)
    plotovMAM=gsn_csm_pres_hgt(wksMAM,MAM({1000:100},{startlat:endlat}),sres)
    symMinMaxPlt(SON,20,False,res)
    plotovSON=gsn_csm_pres_hgt(wksSON,SON({1000:100},{startlat:endlat}),sres)
    month_plot=0
;    do while (month_plot .le. 11)
;	wksMonth= gsn_open_wks("png","fig/zonal_mpsi_"+month_plot)
;;	gsn_define_colormap(wksMonth,"BlWhRe")
;	symMinMaxPlt(VarClima(month_plot,:,:),20,False,res)
;	plotMonth=gsn_csm_pres_hgt(wksMonth,VarClima(month_plot,{1000:100},{startlat:endlat}),res)
;	month_plot=month_plot+1
;    end do
;***********
    overlay(plotJFM,plotovJFM)
    draw(plotJFM)
    frame(wksJFM)
end if

  print("file= zonal_mpsi")
end
