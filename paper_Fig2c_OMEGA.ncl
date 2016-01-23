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
startlon=40
endlon=90
startlat=-60
endlat=60
    autolevs=0
    maxLevel=5.
    minLevel=-5.
    autolevsCli=0
    maxLevelCli=40.
    minLevelCli=-40.

  if(.not.isvar("plottype")) then
    plottype="map"
  end if
  print ("varname= "+varname)

  fils=systemfunc ("ls /work3/mlo/cesm1/archive/CTR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")
  filsExp=systemfunc ("ls /work3/mlo/cesm1/archive/IRR_B_2000_CAM5/atm/hist/*.nc |head -n 1199 |tail -n 600")

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
  clat = cos(lat*4.0*atan(1.0)/180.0)  ; lat weight

;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("png","fig/"+varname+"_ph_ctrl"+startlon+endlon)  ; open a wks
  wksExp=gsn_open_wks("png","fig/"+varname+"_ph_exp"+startlon+endlon)
  gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap
  gsn_define_colormap(wksExp,"BlAqGrYeOrRe")
  res	= True               ; plot mods desired

  if (plottype .eq. "map") then
    tavg= dim_avg_n_Wrap(Var(:,:,:),0) ;time avg
    tavgExp= dim_avg_n_Wrap(VarExp(:,:,:),0)
    tavgAno= dim_avg_n_Wrap(VarAno(:,:,:),0)
    
    res@cnFillOn	= True               ; turn on color fill
    res@cnLinesOn	= False              ; turn off contour lines
    res@gsnMaximize	= True
    res@gsnSpreadColors       = True               ; use full range of color map
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
;********seasonal climatology
    VarClima=clmMonTLL(Var(:,:,:))
    JFM= dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)
    JFM(:,:)=JFM(:,:)*1000.
    JFM@units="10~S~-3~N~"+JFM@units
    wksJFM= gsn_open_wks("png","fig/"+varname+"_ph_JFM_"+startlon+endlon)
    gsn_define_colormap(wksJFM,"BlAqGrYeOrRe")
    plotJFM=gsn_csm_pres_hgt(wksJFM,JFM({1000:100},{startlat:endlat}),res)
;***********
    res@cnLevelSelectionMode ="ManualLevels"
    res@cnMaxLevelValF  = maxLevel
    res@cnMinLevelValF  = minLevel
    res@cnLevelSpacingF = (maxLevel-minLevel)/20.
;********seasonal anomaly
    VarClima=clmMonTLL(VarAno(:,:,:))
    JFM= dim_avg_n_Wrap(VarClima((/1,2,3/),:,:),0)
    JFM(:,:)=JFM(:,:)*1000.
    JFM@units="10~S~-3~N~"+JFM@units
    wksJFM= gsn_open_wks("png","fig/"+varname+"_ph_JFM_a"+startlon+endlon)
    gsn_define_colormap(wksJFM,"BlWhRe")
    if (autolevs.eq.1 )then
    symMinMaxPlt(JFM,20,False,res)
    end if
    plotJFM=gsn_csm_pres_hgt(wksJFM,JFM({1000:100},{startlat:endlat}),res)
  end if
  print("file= "+varname+"_"+plottype)
end
