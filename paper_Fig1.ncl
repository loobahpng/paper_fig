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

;  fils=systemfunc ("ls surfdata/surfdata_1.9x2.5_simyr2000_c091005_IRRI_global.nc")
;  fils=systemfunc ("ls surfdata/surfdata_1.9x2.5_simyr2000_c091005_IRRI_NCP.nc")
;  fils=systemfunc ("ls surfdata/surfdata_1.9x2.5_simyr2000_c091005_IRRI_LowLats.nc")
;  filsExp=systemfunc ("ls surfdata/IRR_B_2000.clm2.h0.0001-01.nc")
  fils=systemfunc ("ls /home/L.r02229011/bnd_condition/surfdata/surfdata_0.9x1.25_global_irri_10yrmean_20131205.nc")
  filsExp=systemfunc ("ls /home/L.r02229011/bnd_condition/surfdata/F2000_CAM5.clm2.h0.0001-01.nc")

;  fils=systemfunc ("ls surfdata/surfdata_1.9x2.5_simyr1850_c091108_Global_IRR.nc")
;  fils=systemfunc ("ls surfdata/surfdata_0.9x1.25_global_irri_10yrmean_indiaonly_20140129.nc")
;  filsExp=systemfunc ("ls /raid2/r02229011/irr/F2000_CAM5.clm2.h0.0001-01.nc")
;  fils=systemfunc ("ls /raid2/r02229011/surfdata_0.9x1.25_global_irri_10yrmean_20131205.nc")
;  filsExp=systemfunc ("ls /raid2/share/mlo/IRR_B_2000/lnd/hist/IRR_B_2000.clm2.h0.0001-01.nc")

  in = addfiles(fils,"r")
  inExp = addfiles(filsExp,"r")

  ListSetType (in,"cat")
  ListSetType (inExp,"cat")
  Var=in[:]->IRRI4d
  Var@long_name="irrigation"
  Var@units="mm/month"
  printVarSummary(Var)
  Var&lsmlat= inExp[0]->lat
  Var&lsmlon= inExp[0]->lon
;-----------mask
    maskname="mask"
    inmask=addfile("/home/L.r02229011/irr/mask_0.9x1.25_IndusGanges.nc","r")
;    Var=mask(Var,conform(Var,inmask->$maskname$,(/1,2/)),1);+in[:]->SWCF(:,:,:)
;------------
  VarClima=clmMonTLL(Var)
  ;VarClima(:,:,:)=clmMonTLL(Var(0:11,:,:))
  annual=dim_avg_n_Wrap(VarClima,0)*12.
  annual=annual*inExp[0]->area/1000./1000.
  total=dim_sum_n_Wrap(dim_sum_n_Wrap(annual,0),0)
  printVarSummary(VarClima)
  print(total+"km3")
  VarClima@_FillValue=9.96921e+36
;  VarClima(:,:,:)=where(VarClima.ne.0,VarClima,VarClima@_FillValue)
  DJF=dim_avg_n_Wrap(VarClima((/0,1,11/),:,:),0)
  JFM=dim_avg_n_Wrap(VarClima((/0,1,2/),:,:),0)
  MAM=dim_avg_n_Wrap(VarClima((/2,3,4/),:,:),0)
  JJA=dim_avg_n_Wrap(VarClima((/5,6,7/),:,:),0)
  SON=dim_avg_n_Wrap(VarClima((/8,9,10/),:,:),0)



;************************************************
; create default plot
;************************************************
    wks = gsn_open_wks("png","fig/irramount")      ; open a wks
    wksDJF=gsn_open_wks("png","fig/irramount_DJF")
    wksJFM=gsn_open_wks("pdf","fig/irramount_JFM")
    wksMAM=gsn_open_wks("png","fig/irramount_MAM")
    wksJJA=gsn_open_wks("png","fig/irramount_JJA")
    wksSON=gsn_open_wks("png","fig/irramount_SON")

;    gsn_define_colormap(wks,"BlAqGrYeOrRe")        ; choose colormap
;    gsn_define_colormap(wksDJF,"BlAqGrYeOrRe")        ; choose colormap
;    gsn_define_colormap(wksMAM,"BlAqGrYeOrRe")        ; choose colormap
;    gsn_define_colormap(wksSON,"BlAqGrYeOrRe")        ; choose colormap
;    gsn_define_colormap(wksJJA,"BlAqGrYeOrRe")        ; choose colormap
;    gsn_define_colormap(wks,"WhiteBlue")        ; choose colormap
    ;gsn_define_colormap(wksDJF,"WhiteBlue")        ; choose colormap
    ;gsn_define_colormap(wksMAM,"WhiteBlue")        ; choose colormap
    ;gsn_define_colormap(wksSON,"WhiteBlue")        ; choose colormap
    ;gsn_define_colormap(wksJJA,"WhiteBlue")        ; choose colormap
    res                = True               ; plot mods desired
    res@cnFillOn	= True               ; turn on color fill
    res@cnLinesOn	= False              ; turn off contour lines
    res@gsnMaximize	= True
;    res@gsnSpreadColors       = True               ; use full range of color map
;    res@mpProjection = "Robinson"       
    res@mpOutlineBoundarySets       = "National"
    res@mpDataSetName = "Earth..4"
    res@mpCountyLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF =5.0
    res@lbLabelFontHeightF=.02

;res@mpPerimOn            = False
;res@mpGridAndLimbOn   = True
;res@mpGridLatSpacingF = 30.
;res@mpGridLonSpacingF = 30.
;res@mpProjection = "Robinson"
;res@mpCenterLonF=150

;  res@cnFillMode           = "RasterFill"
    res@cnLevelSelectionMode ="ManualLevels"
    res@cnMaxLevelValF  = 100
    res@cnMinLevelValF  = 10 
    res@cnLevelSpacingF = 10
res@cnLevelSelectionMode="ExplicitLevels"
res@cnLevels=(/1,2,3,4,5,10,15,20,25,50,100,150/)

    res@cnFillPalette = "precip3_16lev"


    res@mpMinLatF       = 0
    res@mpMaxLatF       = 60
    res@mpMinLonF       = 60 
    res@mpMaxLonF       = 120

    res@gsnDraw=False
    res@gsnFrame=False

    res2=True
    res2@gsnLeftString=""
    res2@gsnRightString=""
    res2@gsnDraw=False
    res2@gsnFrame=False
    res2@cnInfoLabelOn       = False       ; turn off info label
    res2@cnLinesOn           = True       ; do not draw contour lines
    res2@cnLineLabelsOn      = False       ; do not draw contour labels
    res2@cnLevelSelectionMode="ExplicitLevels"
    res2@cnLevels = (/0/)
    res2@gsnContourZeroLineThicknessF=10.
    res2@cnLineColor="red"

    IGP=inmask->$maskname$
    delete(IGP@_FillValue)
    plotIGP=gsn_csm_contour(wksJFM,IGP,res2)



    plotDJF=gsn_csm_contour_map(wksDJF,DJF,res)
    plotJFM=gsn_csm_contour_map(wksJFM,JFM,res)
    overlay(plotJFM,plotIGP)
    draw(plotJFM)
    frame(wksJFM)
    plotMAM=gsn_csm_contour_map(wksMAM,MAM,res)
    plotSON=gsn_csm_contour_map(wksSON,SON,res)
    plotJJA=gsn_csm_contour_map(wksJJA,JJA,res)
    month_plot=0
    do while (month_plot.ne.12)
	wksMonth= gsn_open_wks("png","fig/irramount_"+month_plot)
;	gsn_define_colormap(wksMonth,"WhiteBlue")
	;symMinMaxPlt(VarClima(month_plot,:,:)*plotscale,20,False,res)
	plotMonth=gsn_csm_contour_map(wksMonth,VarClima(month_plot,:,:),res)
	month_plot=month_plot+1
    end do

    Var@units="mm/yr"
    annualtotal=dim_avg_n_Wrap(Var,0)
    annualtotal(:,:)=12.*annualtotal
    res@cnMaxLevelValF  = 200
    res@cnMinLevelValF  = 0 
    res@cnLevelSpacingF = 10
;    res@mpMinLatF       = 0
;    res@mpMaxLatF       = 40
;    res@mpMinLonF       = 60 
;    res@mpMaxLonF       = 90
    plot = gsn_csm_contour_map(wks,annualtotal,res)     
    delete(Var)

end
