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
  varname="OMEGA"
;startlon=70
;endlon=110
startlon=40
endlon=90
startlat=-60
endlat=60

    autolevs=0
    maxLevel=5.
    minLevel=-5.
    ;maxLevel=2.;0.01
    ;minLevel=-2.;-0.01
    autolevsCli=0
    maxLevelCli=40.
    minLevelCli=-40.

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
  pnew =(/1,2,3,5,7,10,20,30,50,70,100,125,150,175,200,225,250,300,350,400,450,500,550,600,650,700,750,775,800,825,850,875,900,925,950,975,1000/)
  pnew@units="hpa"
  VarTLLL=vinth2p(in[:]->$varname$,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  Var=dim_avg_n_Wrap(VarTLLL(:,:,:,{startlon:endlon}),3)
  VarExpTLLL=vinth2p(inExp[:]->$varname$,hyam,hybm,pnew,PSExp,interp,P0mb,1,extrap)
  VarExp=dim_avg_n_Wrap(VarExpTLLL(:,:,:,{startlon:endlon}),3)
  VarAno=Var
  VarAno(:,:,:)= VarExp(:,:,:) - Var(:,:,:) 
  
  Var@long_name=in[0]->$varname$@long_name
  Var@units=in[0]->$varname$@units

  VarExp@long_name=in[0]->$varname$@long_name
  VarExp@units=in[0]->$varname$@units
  
  VarAno@long_name=in[0]->$varname$@long_name
  VarAno@units=in[0]->$varname$@units
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
  wks = gsn_open_wks("png","fig/"+varname+"_ph_ctrl"+startlon+endlon)  ; open a wks
  wksExp=gsn_open_wks("png","fig/"+varname+"_ph_exp"+startlon+endlon)
  gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap
  gsn_define_colormap(wksExp,"BlAqGrYeOrRe")
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
    ;res@cnLineLabelsOn       = True      
	res@gsnSpreadColors       = False 
	res@cnFillPalette = "precip4_diff_19lev"
	res@cnFillPalette = "MPL_RdBu"
	res@cnSpanFillPalette=True

    if (autolevsCli.eq.0)then
    res@cnLevelSelectionMode ="ManualLevels"
    res@cnMaxLevelValF  = maxLevelCli
    res@cnMinLevelValF  = minLevelCli
    res@cnLevelSpacingF = (maxLevelCli-minLevelCli)/20.
    end if

    ;symMinMaxPlt(tavg,20,False,res)
    plot = gsn_csm_pres_hgt(wks,tavg({1000:100},{startlat:endlat}),res)     
    ;symMinMaxPlt(tavgExp,20,False,res)
    plotExp= gsn_csm_pres_hgt(wksExp,tavgExp({1000:100},{startlat:endlat}),res)

;********seasonal climatology
    VarClima=clmMonTLL(Var(:,:,:))
    JFM= dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)
    JJA= dim_avg_n_Wrap(VarClima((/6,7,8/),:,:),0)
    MAM= dim_avg_n_Wrap(VarClima((/3,4,5/),:,:),0)
    SON= dim_avg_n_Wrap(VarClima((/9,10,11/),:,:),0)
    wksJFM= gsn_open_wks("png","fig/"+varname+"_ph_JFM_"+startlon+endlon)
    wksJJA= gsn_open_wks("png","fig/"+varname+"_ph_JJA_"+startlon+endlon)
    wksMAM= gsn_open_wks("png","fig/"+varname+"_ph_MAM_"+startlon+endlon)
    wksSON= gsn_open_wks("png","fig/"+varname+"_ph_SON_"+startlon+endlon)
    gsn_define_colormap(wksJFM,"BlAqGrYeOrRe")
    gsn_define_colormap(wksJJA,"BlAqGrYeOrRe")
    gsn_define_colormap(wksMAM,"BlAqGrYeOrRe")
    gsn_define_colormap(wksSON,"BlAqGrYeOrRe")
    plotJFM=gsn_csm_pres_hgt(wksJFM,JFM({1000:100},{startlat:endlat}),res)
    plotJJA=gsn_csm_pres_hgt(wksJJA,JJA({1000:100},{startlat:endlat}),res)
    plotMAM=gsn_csm_pres_hgt(wksMAM,MAM({1000:100},{startlat:endlat}),res)
    plotSON=gsn_csm_pres_hgt(wksSON,SON({1000:100},{startlat:endlat}),res)
month_plot=0
    do while (month_plot .le. 11)
	wksMonth= gsn_open_wks("png","fig/"+varname+"_ph_"+month_plot)
	gsn_define_colormap(wksMonth,"BlAqGrYeOrRe")
	;symMinMaxPlt(VarClima(month_plot,:,:)*plotscale,20,False,res)
	plotMonth=gsn_csm_pres_hgt(wksMonth,VarClima(month_plot,{1000:100},{startlat:endlat}),res)
	month_plot=month_plot+1
    end do
;***********

    res@cnLevelSelectionMode ="ManualLevels"
    res@cnMaxLevelValF  = maxLevel
    res@cnMinLevelValF  = minLevel
    res@cnLevelSpacingF = (maxLevel-minLevel)/20.

;********seasonal anomaly
    VarClima=clmMonTLL(VarAno(:,:,:))
    JFM= dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)

    JFM(:,:)=JFM(:,:)*1000.

    JJA= dim_avg_n_Wrap(VarClima((/6,7,8/),:,:),0)
    MAM= dim_avg_n_Wrap(VarClima((/3,4,5/),:,:),0)
    SON= dim_avg_n_Wrap(VarClima((/9,10,11/),:,:),0)
    wksAno=gsn_open_wks ("png","fig/"+varname+"_ph_comp"+startlon+endlon)
    wksJFM= gsn_open_wks("png","fig/"+varname+"_ph_JFM_a"+startlon+endlon)
    wksJJA= gsn_open_wks("png","fig/"+varname+"_ph_JJA_a"+startlon+endlon)
    wksMAM= gsn_open_wks("png","fig/"+varname+"_ph_MAM_a"+startlon+endlon)
    wksSON= gsn_open_wks("png","fig/"+varname+"_ph_SON_a"+startlon+endlon)
    gsn_define_colormap(wksAno,"BlWhRe")
    gsn_define_colormap(wksJFM,"BlWhRe")
    gsn_define_colormap(wksJJA,"BlWhRe")
    gsn_define_colormap(wksMAM,"BlWhRe")
    gsn_define_colormap(wksSON,"BlWhRe")
    if (autolevs.eq.1 )then
    symMinMaxPlt(JFM,20,False,res)
    end if
    plotJFM=gsn_csm_pres_hgt(wksJFM,JFM({1000:100},{startlat:endlat}),res)
    if (autolevs.eq.1 )then
        symMinMaxPlt(JJA,20,False,res)
    end if
    plotJJA=gsn_csm_pres_hgt(wksJJA,JJA({1000:100},{startlat:endlat}),res)
    if (autolevs.eq.1 )then
        symMinMaxPlt(MAM,20,False,res)
    end if
    plotMAM=gsn_csm_pres_hgt(wksMAM,MAM({1000:100},{startlat:endlat}),res)
    if (autolevs.eq.1 )then
        symMinMaxPlt(SON,20,False,res)
    end if
    plotSON=gsn_csm_pres_hgt(wksSON,SON({1000:100},{startlat:endlat}),res)
    if (autolevs.eq.1 )then
	symMinMaxPlt(tavgAno,20,False,res)
    end if
    plotAno=gsn_csm_pres_hgt(wksAno,tavgAno({1000:100},{startlat:endlat}),res)
month_plot=0
    do while (month_plot .le. 11)
	wksMonth= gsn_open_wks("png","fig/"+varname+"_ph_"+month_plot+"a")
	gsn_define_colormap(wksMonth,"BlWhRe")
	if (autolevs.eq.1 )then
	    symMinMaxPlt(VarClima(month_plot,:,:),20,False,res)
	end if
	plotMonth=gsn_csm_pres_hgt(wksMonth,VarClima(month_plot,{1000:100},{startlat:endlat}),res)
	month_plot=month_plot+1
    end do

  end if

  if (plottype .eq. "timeseries") then
    gavg=wgt_areaave_Wrap(Var(:,ilat(0):ilat(1),ilon(0):ilon(1)),clat(ilat(0):ilat(1)),1.0,0)   ; global avg
    gavgExp=wgt_areaave_Wrap(VarExp(:,ilat(0):ilat(1),ilon(0):ilon(1)),clat(ilat(0):ilat(1)),1.0,0)
    gavgAno=wgt_areaave_Wrap(VarAno(:,ilat(0):ilat(1),ilon(0):ilon(1)),clat(ilat(0):ilat(1)),1.0,0)
    ;JFM=VarClima((/0,1,11/)
    ;JJA=VarClima((/5,6,7/)

    ;res@tiMainString=Var@long_name
    ;res@tiXAxisString="time (month)"
    ;res@tiYAxisString=Var@units
    plot  = gsn_csm_xy (wks,tt,runave_Wrap( gavg,12,0) ,res) ; create plot
    plotExp=gsn_csm_xy (wksExp,tt,runave_Wrap( gavgExp,12,0),res)
    plotAno=gsn_csm_xy (wksAno,tt,runave_Wrap (gavgAno,12,0),res)
    ;plotJFM  = gsn_csm_xy (wksJFM,tt,JFM,res) ; create plot
    ;plotJJA=gsn_csm_xy (wksJJA,tt,JJA,res)
  end if


  print("file= "+varname+"_"+plottype)
end
